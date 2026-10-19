//! Throw random bytes at the block checker, the way a hostile peer would.
#![no_main]
use eeze_core::state::{Genesis, check_block};
use eeze_core::*;
use libfuzzer_sys::fuzz_target;
use std::sync::OnceLock;

fn base() -> &'static (Genesis, Block, State) {
    static B: OnceLock<(Genesis, Block, State)> = OnceLock::new();
    B.get_or_init(|| {
        let g = Genesis::devnet();
        let (b, s) = g.genesis_block();
        (g, b, s)
    })
}

fuzz_target!(|data: &[u8]| {
    if let Ok(block) = serde_json::from_slice::<Block>(data) {
        let (g, parent, state) = base();
        let _ = check_block(g, &parent.header, state, &block);
        let mut c = Chain::new(g.clone());
        let _ = c.add_block(block);
    }
});
