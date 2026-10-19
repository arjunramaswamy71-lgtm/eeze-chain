//! Random transactions against a real state: must be applied or rejected, never crash.
#![no_main]
use eeze_core::state::{BlockCtx, Genesis};
use eeze_core::*;
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    if let Ok(tx) = serde_json::from_slice::<Tx>(data) {
        let g = Genesis::devnet();
        let (_, mut s) = g.genesis_block();
        let supply = s.supply;
        let ctx = BlockCtx {
            height: 1,
            time: g.time + 1,
            producer: Address::default(),
        };
        let _ = s.apply_tx(&g, &ctx, &tx);
        let held: u64 = s
            .accounts
            .values()
            .map(|a| a.balance + a.stake + a.unbonding.iter().map(|u| u.1).sum::<u64>())
            .sum();
        assert_eq!(held, supply, "a transaction created or destroyed coins");
        let mut c = Chain::new(g);
        let _ = c.submit_tx(tx);
    }
});
