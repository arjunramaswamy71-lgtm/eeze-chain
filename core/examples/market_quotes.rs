//! Asks the real security-token contract for market quotes at many trade sizes, so the Python
//! analysis can compare the contract against the textbook formula.
//! Run:  cargo run --release --example market_quotes > ../sim/out/market_quotes.json
use eeze_core::abi::{self, Arg};
use eeze_core::state::{Genesis, build_block, mine};
use eeze_core::*;

fn main() {
    let mut g = Genesis::devnet();
    g.initial_bits = 1;
    let bank = Keypair::from_seed("bank");
    let miner = Keypair::from_seed("miner");
    let mut c = Chain::new(g.clone());
    let mut nonce = 0;
    let mut send = |c: &mut Chain, kind: TxKind| -> Receipt {
        let tx = Tx::new_signed(&g.chain_id, &bank, nonce, 15_000_000, 1, kind);
        nonce += 1;
        let p = c.tip_block().header.clone();
        let s = c.tip_state();
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
        c.add_block(b).unwrap();
        let r = c.find_tx(&tx.hash()).unwrap().2;
        assert!(r.ok, "{:?}", r.error);
        r
    };
    let reg = send(
        &mut c,
        TxKind::Deploy {
            code: Bytes(std::fs::read("../contracts/build/identity.wasm").unwrap()),
            args: Bytes(vec![]),
        },
    )
    .contract
    .unwrap();
    let init = abi::encode(&[
        Arg::Str("B".into()),
        Arg::Str("B".into()),
        Arg::Str("property".into()),
        Arg::Addr(reg),
        Arg::U64(0),
        Arg::U64(10 * COIN),
        Arg::U64(1_000_000),
        Arg::Str("d".into()),
    ]);
    let tok = send(
        &mut c,
        TxKind::Deploy {
            code: Bytes(std::fs::read("../contracts/build/security.wasm").unwrap()),
            args: Bytes(init),
        },
    )
    .contract
    .unwrap();
    // Pool: 10,000 shares and 100,000 CTDY, so 10 CTDY a share to start.
    send(
        &mut c,
        TxKind::Call {
            contract: tok,
            amount: 100_000 * COIN,
            args: Bytes(abi::call("add_liquidity", &[Arg::U64(10_000)])),
        },
    );
    let s = c.tip_state();
    let ask = |m: &str, v: u64| -> u64 {
        let out = s
            .query(
                &tok,
                abi::call(m, &[Arg::U64(v)]),
                Address::default(),
                50_000_000,
            )
            .unwrap();
        match abi::decode(&out).unwrap()[0] {
            Arg::U64(x) => x,
            _ => 0,
        }
    };
    let mut rows = Vec::new();
    for pct in [
        0.1, 0.25, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 35.0, 50.0, 75.0, 100.0, 200.0,
    ] {
        let ctdy_in = (100_000.0 * COIN as f64 * pct / 100.0) as u64;
        let out = ask("quote_buy", ctdy_in);
        rows.push(serde_json::json!({ "pct_of_pool": pct, "ctdy_in": ctdy_in, "shares_out": out, "cost": ask("cost_to_buy", out) }));
    }
    let mut sells = Vec::new();
    for pct in [0.1, 1.0, 5.0, 10.0, 25.0, 50.0, 100.0] {
        let shares = (10_000.0 * pct / 100.0) as u64;
        sells.push(serde_json::json!({ "pct_of_pool": pct, "shares_in": shares, "ctdy_out": ask("quote_sell", shares) }));
    }
    println!(
        "{}",
        serde_json::json!({ "pool_ctdy": 100_000 * COIN, "pool_shares": 10_000, "fee": 0.003, "buys": rows, "sells": sells })
    );
}
