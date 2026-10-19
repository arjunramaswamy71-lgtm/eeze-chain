//! Random WebAssembly: rejected up front, or run until it finishes or runs out of gas. Never a
//! crash, never an endless loop.
#![no_main]
use eeze_core::vm::{self, CallEnv};
use eeze_core::*;
use libfuzzer_sys::fuzz_target;
use std::sync::Arc;

fuzz_target!(|data: &[u8]| {
    if vm::validate(data).is_ok() {
        let env = CallEnv {
            caller: Address::default(),
            this: Address([1; 20]),
            value: 0,
            balance: 100,
            height: 1,
            time: 1,
        };
        let out = vm::run(
            Arc::new(Default::default()),
            data,
            "call",
            data.to_vec(),
            Default::default(),
            env,
            200_000,
        );
        assert!(out.gas_used <= 200_000);
    }
});
