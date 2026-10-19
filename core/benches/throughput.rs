//! How fast is it? Run with:  cargo bench -p eeze_core
use criterion::{BatchSize, Criterion, Throughput, criterion_group, criterion_main};
use eeze_core::abi::{self, Arg};
use eeze_core::state::{Genesis, build_block, check_block, mine};
use eeze_core::*;

fn setup(n_senders: usize) -> (Genesis, Vec<Keypair>) {
    let keys: Vec<Keypair> = (0..n_senders)
        .map(|i| Keypair::from_seed(&format!("bench-{i}")))
        .collect();
    let mut g = Genesis::devnet();
    g.initial_bits = 1;
    g.block_gas_limit = u64::MAX / 2;
    for k in &keys {
        g.alloc.push((k.address(), 1_000_000 * COIN));
    }
    (g, keys)
}

fn transfers(g: &Genesis, keys: &[Keypair], per: u64) -> Vec<Tx> {
    let to = Keypair::from_seed("sink").address();
    keys.iter()
        .flat_map(|k| (0..per).map(move |n| (k, n)))
        .map(|(k, n)| {
            Tx::new_signed(
                &g.chain_id,
                k,
                n,
                21_000,
                1,
                TxKind::Transfer { to, amount: 1 },
            )
        })
        .collect()
}

fn bench(c: &mut Criterion) {
    let k = Keypair::from_seed("arjun");
    let tx = Tx::new_signed(
        "eeze",
        &k,
        0,
        21_000,
        1,
        TxKind::Transfer {
            to: k.address(),
            amount: 5,
        },
    );
    c.bench_function("verify one signature", |b| {
        b.iter(|| assert!(tx.verify("eeze")))
    });

    let input = vrf_input(&Hash([3; 32]), 9);
    let vk = k.vrf();
    let (pre, proof, _) = vk.prove(&input);
    let pk = vk.public();
    c.bench_function("VRF prove", |b| b.iter(|| vk.prove(&input)));
    c.bench_function("VRF verify", |b| {
        b.iter(|| vrf_verify(&pk, &input, &pre, &proof).unwrap())
    });

    // A block of 2,000 payments from 200 wallets: build it, then check it the way every node does.
    let (g, keys) = setup(200);
    let txs = transfers(&g, &keys, 10);
    let chain = Chain::new(g.clone());
    let parent = chain.tip_block().header.clone();
    let ps = chain.tip_state();
    let miner = Keypair::from_seed("miner");
    let (mut block, _, _) = build_block(&g, &parent, &ps, &miner, parent.time + 1, 0, &txs, None);
    assert!(mine(&mut block.header, &|| false));
    assert_eq!(block.txs.len(), 2_000);

    let mut grp = c.benchmark_group("block of 2,000 payments");
    grp.throughput(Throughput::Elements(2_000));
    grp.sample_size(20);
    // Each payment's signature check is most of the cost (about 2,000 x one signature).
    grp.bench_function("check and apply (signatures + state + root)", |b| {
        b.iter(|| check_block(&g, &parent, &ps, &block).unwrap())
    });
    grp.finish();

    // Contract calls: a compliant security token transfer, including the read-only KYC check
    // against the identity registry.
    if let (Ok(idw), Ok(secw)) = (
        std::fs::read("../contracts/build/identity.wasm"),
        std::fs::read("../contracts/build/security.wasm"),
    ) {
        let (g, keys) = setup(2);
        let mut ch = Chain::new(g.clone());
        let bank = &keys[0];
        let alice = &keys[1];
        let mut nonce = 0;
        let send = |ch: &mut Chain, k: &Keypair, n: &mut u64, kind: TxKind| -> Receipt {
            let tx = Tx::new_signed(&g.chain_id, k, *n, 30_000_000, 1, kind);
            *n += 1;
            let p = ch.tip_block().header.clone();
            let s = ch.tip_state();
            let (mut b, _, _) = build_block(
                &g,
                &p,
                &s,
                &miner,
                p.time + 1,
                0,
                std::slice::from_ref(&tx),
                None,
            );
            mine(&mut b.header, &|| false);
            ch.add_block(b).unwrap();
            ch.find_tx(&tx.hash()).unwrap().2
        };
        let reg = send(
            &mut ch,
            bank,
            &mut nonce,
            TxKind::Deploy {
                code: Bytes(idw),
                args: Bytes(vec![]),
            },
        )
        .contract
        .unwrap();
        let call = |m: &str, a: &[Arg]| Bytes(abi::call(m, a));
        send(
            &mut ch,
            bank,
            &mut nonce,
            TxKind::Call {
                contract: reg,
                amount: 0,
                args: call("add_issuer", &[Arg::Addr(bank.address()), Arg::U64(5)]),
            },
        );
        send(
            &mut ch,
            bank,
            &mut nonce,
            TxKind::Call {
                contract: reg,
                amount: 0,
                args: call(
                    "register",
                    &[Arg::Addr(alice.address()), Arg::U64(1), Arg::U64(840)],
                ),
            },
        );
        send(
            &mut ch,
            bank,
            &mut nonce,
            TxKind::Call {
                contract: reg,
                amount: 0,
                args: call("add_claim", &[Arg::U64(1), Arg::U64(1), Arg::U64(0)]),
            },
        );
        send(
            &mut ch,
            bank,
            &mut nonce,
            TxKind::Call {
                contract: reg,
                amount: 0,
                args: call("add_claim", &[Arg::U64(1), Arg::U64(4), Arg::U64(0)]),
            },
        );
        let init = abi::encode(&[
            Arg::Str("B".into()),
            Arg::Str("B".into()),
            Arg::Str("property".into()),
            Arg::Addr(reg),
            Arg::U64(5),
            Arg::U64(COIN),
            Arg::U64(1_000_000),
            Arg::Str("d".into()),
        ]);
        let tok = send(
            &mut ch,
            bank,
            &mut nonce,
            TxKind::Deploy {
                code: Bytes(secw),
                args: Bytes(init),
            },
        )
        .contract
        .unwrap();
        let s = ch.tip_state();
        let p = ch.tip_block().header.clone();
        let txs: Vec<Tx> = (0..200)
            .map(|i| {
                Tx::new_signed(
                    &g.chain_id,
                    bank,
                    nonce + i,
                    3_000_000,
                    1,
                    TxKind::Call {
                        contract: tok,
                        amount: 0,
                        args: call("transfer", &[Arg::Addr(alice.address()), Arg::U64(1)]),
                    },
                )
            })
            .collect();
        let mut grp = c.benchmark_group("block of 200 security-token transfers (with KYC check)");
        grp.throughput(Throughput::Elements(200));
        grp.sample_size(10);
        grp.bench_function("apply", |b| {
            b.iter_batched(
                || (*s).clone(),
                |mut st| {
                    let h = Header {
                        height: p.height + 1,
                        prev: p.hash(),
                        time: p.time + 1,
                        ..p.clone()
                    };
                    let (kept, r) = st.execute(&g, &h, &txs, &None, None, true).unwrap();
                    assert_eq!(kept.len(), 200);
                    assert!(r.iter().all(|r| r.ok));
                },
                BatchSize::LargeInput,
            )
        });
        grp.finish();
    }
}

criterion_group!(benches, bench);
criterion_main!(benches);
