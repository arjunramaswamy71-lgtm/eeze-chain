#![no_main]
use eeze_core::abi;
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    if let Ok(args) = abi::decode(data) {
        assert_eq!(abi::decode(&abi::encode(&args)).unwrap(), args);
    }
});
