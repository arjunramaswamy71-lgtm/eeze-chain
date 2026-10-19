//! Writes real blocks, transactions and contracts for the fuzzer to start from.
use eeze_core::state::{Genesis, build_block, mine};
use eeze_core::*;

fn main() {
    let root = std::path::Path::new("fuzz/corpus");
    for d in ["block", "transaction", "contract", "abi"] {
        std::fs::create_dir_all(root.join(d)).unwrap();
    }
    let g = Genesis::devnet();
    let mut gg = g.clone();
    gg.initial_bits = 1;
    let c = Chain::new(gg.clone());
    let k = Keypair::from_seed("arjun");
    let to = Keypair::from_seed("bob").address();
    let txs = vec![
        Tx::new_signed(
            &g.chain_id,
            &k,
            0,
            21_000,
            1,
            TxKind::Transfer {
                to,
                amount: 5 * COIN,
            },
        ),
        Tx::new_signed(
            &g.chain_id,
            &k,
            1,
            21_000,
            1,
            TxKind::Stake {
                amount: 1_000 * COIN,
            },
        ),
        Tx::new_signed(
            &g.chain_id,
            &k,
            2,
            21_000,
            1,
            TxKind::SetValidatorKey {
                vrf_key: k.vrf().public(),
            },
        ),
        Tx::new_signed(
            &g.chain_id,
            &k,
            3,
            300_000,
            1,
            TxKind::Call {
                contract: to,
                amount: 0,
                args: Bytes(abi::call("buy", &[abi::Arg::U64(3)])),
            },
        ),
    ];
    for (i, t) in txs.iter().enumerate() {
        std::fs::write(
            root.join(format!("transaction/{i}.json")),
            serde_json::to_vec(t).unwrap(),
        )
        .unwrap();
    }
    let parent = c.tip_block().header.clone();
    let (mut b, _, _) = build_block(
        &gg,
        &parent,
        &c.tip_state(),
        &k,
        parent.time + 1,
        0,
        &txs,
        None,
    );
    mine(&mut b.header, &|| false);
    std::fs::write(root.join("block/0.json"), serde_json::to_vec(&b).unwrap()).unwrap();
    for f in ["identity", "security"] {
        if let Ok(code) = std::fs::read(format!("../contracts/build/{f}.wasm")) {
            std::fs::write(root.join(format!("contract/{f}.wasm")), code).unwrap();
        }
    }
    std::fs::write(
        root.join("abi/0"),
        abi::call("transfer", &[abi::Arg::Addr(to), abi::Arg::U64(9)]),
    )
    .unwrap();
    println!("seed inputs written to {}", root.display());
}
