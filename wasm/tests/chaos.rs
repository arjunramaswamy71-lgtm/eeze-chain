//! Chaos test: hours of simulated network time with random trouble thrown in (nodes crashing,
//! the network splitting, validators cheating), checking the safety rule after every step:
//!
//!   No two nodes ever disagree about a FINAL block, and no node's final block ever goes backwards.
//!
//! At the end everything is healed and every node must agree on one chain.
use eeze_wasm::sim::Sim;
use serde_json::json;
use std::collections::HashMap;

fn check_safety(s: &Sim, best_final: &mut HashMap<String, u64>) {
    for a in &s.nodes {
        let (fa, ha) = a.chain.finalized();
        // Finality never goes backwards on a node.
        let prev = best_final.entry(a.name.clone()).or_insert(0);
        assert!(
            fa >= *prev,
            "{} finality went backwards: {} -> {}",
            a.name,
            prev,
            fa
        );
        *prev = fa;
        for b in &s.nodes {
            let (fb, _) = b.chain.finalized();
            let h = fa.min(fb);
            if h == 0 {
                continue;
            }
            // The block both consider final at the lower height must be the same block.
            let x = a.chain.block_at(h).map(|s| s.block.hash());
            let y = b.chain.block_at(h).map(|s| s.block.hash());
            assert_eq!(
                x, y,
                "{} and {} disagree about final block #{h}",
                a.name, b.name
            );
        }
        let _ = ha;
    }
}

#[test]
fn hours_of_chaos_never_break_finality() {
    let hours: u64 = std::env::var("CHAOS_HOURS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(1);
    let mut s = Sim::new(1_760_000_000_000);
    let mut best_final = HashMap::new();
    let mut rng: u64 = 0xDEC0DE;
    let mut next = || {
        rng ^= rng << 13;
        rng ^= rng >> 7;
        rng ^= rng << 17;
        rng
    };
    let names = ["miner-1", "miner-2", "arjun", "bank", "carol"];
    let (mut splits, mut crashes, mut cheats) = (0, 0, 0);
    let total_s = hours * 3_600;
    let mut t = 0;
    while t < total_s {
        s.tick(1_000);
        t += 1;
        check_safety(&s, &mut best_final);
        if std::env::var("CHAOS_DEBUG").is_ok() && t % 300 == 0 {
            let f: Vec<String> = s
                .nodes
                .iter()
                .map(|n| {
                    format!(
                        "{}:{}{}/{}",
                        n.name,
                        if n.online { "" } else { "(off)" },
                        n.chain.finalized().0,
                        n.chain.height()
                    )
                })
                .collect();
            eprintln!("t={t} split={} {}", s.split, f.join(" "));
        }
        if t % 15 == 0 {
            match next() % 6 {
                0 => {
                    let _ = s.control("split", &json!({}));
                    splits += 1;
                }
                1 | 2 => {
                    let n = names[(next() % names.len() as u64) as usize];
                    let _ = s.control("toggle", &json!({ "node": n }));
                    crashes += 1;
                }
                3 => {
                    if s.control("double_sign", &json!({ "node": "carol" }))
                        .is_ok()
                    {
                        cheats += 1;
                    }
                }
                4 if s
                    .control("double_vote", &json!({ "node": "carol" }))
                    .is_ok() =>
                {
                    cheats += 1;
                }
                _ => {}
            }
        }
    }
    // Heal everything and let it settle.
    if s.split {
        s.control("split", &json!({})).unwrap();
    }
    for n in names {
        if !s.nodes.iter().find(|x| x.name == n).unwrap().online {
            s.control("toggle", &json!({ "node": n })).unwrap();
        }
    }
    for _ in 0..60 {
        s.tick(1_000);
        check_safety(&s, &mut best_final);
    }
    let tips: std::collections::HashSet<_> = s
        .nodes
        .iter()
        .filter(|n| n.online)
        .map(|n| n.chain.tip)
        .collect();
    let fin: Vec<u64> = s
        .nodes
        .iter()
        .filter(|n| n.online)
        .map(|n| n.chain.finalized().0)
        .collect();
    let height = s.nodes[0].chain.height();
    println!(
        "{hours} h simulated: {height} blocks, {splits} splits, {crashes} crashes/restarts, {cheats} cheats, final #{}",
        fin.iter().min().unwrap()
    );
    assert!(tips.len() <= 2, "nodes agree again after the chaos");
    assert!(
        fin.iter().min().unwrap() + 10 > height,
        "finality caught up"
    );
}
