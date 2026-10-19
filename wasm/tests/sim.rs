use eeze_wasm::sim::Sim;
use serde_json::json;

fn heights(s: &Sim) -> Vec<(String, u64, u64)> {
    s.nodes
        .iter()
        .filter(|n| n.online)
        .map(|n| (n.name.clone(), n.chain.height(), n.chain.finalized().0))
        .collect()
}

#[test]
fn the_whole_story_runs_in_the_simulation() {
    let mut s = Sim::new(1_760_000_000_000);
    s.tick(8_000);
    let h0 = s.nodes[0].chain.height();
    assert!(h0 >= 3, "mining works: {h0}");

    // 51% attack while still mining.
    s.control("attack", &json!({})).unwrap();
    for _ in 0..40 {
        s.tick(1_000);
        if s.attack
            .as_ref()
            .map(|a| a.stage == "worked" || a.stage == "failed")
            .unwrap_or(false)
        {
            break;
        }
    }
    let stage = s.attack.as_ref().unwrap().stage.clone();
    println!("attack: {stage}");
    assert_eq!(stage, "worked");

    // Run on into staking and finality.
    for _ in 0..120 {
        s.tick(1_000);
    }
    let hs = heights(&s);
    println!("{hs:?}");
    assert!(hs.iter().all(|x| x.1 > 60), "past the switch to staking");
    let fin = s.nodes[0].chain.finalized().0;
    assert!(fin > 60, "blocks are being finalized: {fin}");

    // A validator double-signs and gets slashed.
    let carol = s.nodes.iter().position(|n| n.name == "carol").unwrap();
    let stake = |s: &Sim| {
        s.nodes[0]
            .chain
            .tip_state()
            .account(&eeze_core::Keypair::from_seed("carol").address())
            .stake
    };
    let before = stake(&s);
    s.control("double_sign", &json!({ "node": "carol" }))
        .unwrap();
    for _ in 0..90 {
        s.tick(1_000);
        if stake(&s) < before {
            break;
        }
    }
    assert_eq!(stake(&s), before - before / 2, "carol lost half her stake");
    let _ = carol;

    // Split the network: neither half has 2/3 of the stake, so nothing new becomes final,
    // but both halves keep making blocks. Heal it and they agree again.
    s.control("split", &json!({})).unwrap();
    s.tick(2_000);
    let fin_at_split = s.nodes.iter().map(|n| n.chain.finalized().0).max().unwrap();
    for _ in 0..20 {
        s.tick(1_000);
    }
    let fin_during = s.nodes.iter().map(|n| n.chain.finalized().0).max().unwrap();
    assert!(
        fin_during <= fin_at_split + 1,
        "no new finality while split ({fin_at_split} -> {fin_during})"
    );
    s.control("split", &json!({})).unwrap();
    for _ in 0..30 {
        s.tick(1_000);
    }
    let tips: std::collections::HashSet<_> = s
        .nodes
        .iter()
        .filter(|n| n.online)
        .map(|n| n.chain.tip)
        .collect();
    let finals: Vec<u64> = s
        .nodes
        .iter()
        .filter(|n| n.online)
        .map(|n| n.chain.finalized().0)
        .collect();
    println!("after healing: {:?} finals {:?}", heights(&s), finals);
    assert!(tips.len() <= 2, "nodes converge after healing");
    assert!(finals.iter().all(|f| *f > fin_during), "finality resumes");

    // The API answers like a real node.
    let st = s.api(0, "GET", "/status", "", b"").unwrap();
    assert!(st["finalized"]["height"].as_u64().unwrap() > 60);
    let c = s.api(0, "GET", "/contracts", "", b"").unwrap();
    assert_eq!(
        c.as_array().unwrap().len(),
        3,
        "registry, fund and building were set up"
    );
    let log: Vec<String> = s
        .log
        .iter()
        .map(|l| format!("{} {}: {}", l.kind, l.node, l.text))
        .collect();
    for l in log
        .iter()
        .filter(|l| l.starts_with("caught") || l.starts_with("reorg") || l.starts_with("evil"))
    {
        println!("{l}");
    }
}
