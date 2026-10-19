//! Property tests: instead of a few hand-picked cases, generate thousands of random ones and check
//! rules that must ALWAYS hold. When one fails, proptest shrinks it to the smallest failing case.

use eeze_core::abi::{self, Arg};
use eeze_core::state::{Genesis, build_block, mine};
use eeze_core::*;
use proptest::prelude::*;

fn arg() -> impl Strategy<Value = Arg> {
    prop_oneof![
        any::<u64>().prop_map(Arg::U64),
        proptest::collection::vec(any::<u8>(), 0..64).prop_map(Arg::Bytes),
        any::<[u8; 20]>().prop_map(|a| Arg::Addr(Address(a))),
        "[a-zA-Z0-9 ]{0,40}".prop_map(Arg::Str),
    ]
}

proptest! {
    #![proptest_config(ProptestConfig { cases: 2_000, ..ProptestConfig::default() })]

    /// Contract arguments come back exactly as they went in.
    #[test]
    fn abi_round_trips(args in proptest::collection::vec(arg(), 0..12)) {
        prop_assert_eq!(abi::decode(&abi::encode(&args)).unwrap(), args);
    }

    /// Junk bytes never crash the decoder: they're either read or rejected.
    #[test]
    fn abi_never_panics(bytes in proptest::collection::vec(any::<u8>(), 0..300)) {
        let _ = abi::decode(&bytes);
    }

    /// Junk never crashes the parsers for blocks, transactions and votes coming off the network.
    #[test]
    fn network_parsers_never_panic(text in ".{0,400}", bytes in proptest::collection::vec(any::<u8>(), 0..400)) {
        let _ = serde_json::from_str::<Block>(&text);
        let _ = serde_json::from_str::<Tx>(&text);
        let _ = serde_json::from_slice::<Vote>(&bytes);
        let _ = State::from_bytes(&bytes);
    }

    /// Junk never crashes the contract engine. It's rejected before it can run.
    #[test]
    fn wasm_validator_never_panics(bytes in proptest::collection::vec(any::<u8>(), 0..2_000)) {
        let _ = vm::validate(&bytes);
        let mut real = b"\0asm\x01\0\0\0".to_vec();
        real.extend_from_slice(&bytes);
        let _ = vm::validate(&real);
    }

    /// Every leaf has a proof, and a proof only works for its own leaf.
    #[test]
    fn merkle_proofs_hold(n in 1usize..80, pick in any::<prop::sample::Index>(), other in any::<prop::sample::Index>()) {
        let leaves: Vec<Hash> = (0..n).map(|i| hash_with("leaf", &(i as u64).to_le_bytes())).collect();
        let root = merkle_root(&leaves);
        let i = pick.index(n);
        let j = other.index(n);
        let proof = merkle_proof(&leaves, i);
        prop_assert!(merkle_verify(leaves[i], &proof, root));
        if i != j {
            prop_assert!(!merkle_verify(leaves[j], &proof, root));
        }
    }

    /// Changing any field of a signed transaction breaks its signature.
    #[test]
    fn tampering_breaks_signatures(amount in 1u64..1_000_000, nonce in 0u64..1_000, bump in 1u64..1_000) {
        let k = Keypair::from_seed("arjun");
        let to = Keypair::from_seed("bob").address();
        let tx = Tx::new_signed("c", &k, nonce, 21_000, 1, TxKind::Transfer { to, amount });
        prop_assert!(tx.verify("c"));
        let mut t1 = tx.clone();
        t1.nonce += bump;
        prop_assert!(!t1.verify("c"));
        let mut t2 = tx.clone();
        t2.kind = TxKind::Transfer { to, amount: amount + bump };
        prop_assert!(!t2.verify("c"));
        let mut t3 = tx.clone();
        t3.gas_price += bump;
        prop_assert!(!t3.verify("c"));
        prop_assert!(!tx.verify("another-chain"));
        // And it survives a trip through JSON unchanged.
        let back: Tx = serde_json::from_str(&serde_json::to_string(&tx).unwrap()).unwrap();
        prop_assert_eq!(back.hash(), tx.hash());
    }
}

#[derive(Debug, Clone)]
enum Op {
    Send(usize, usize, u64),
    Stake(usize, u64),
    Unstake(usize, u64),
    Bad(usize),
}

fn op() -> impl Strategy<Value = Op> {
    prop_oneof![
        4 => (0usize..5, 0usize..5, 0u64..30_000).prop_map(|(a, b, v)| Op::Send(a, b, v * COIN / 10)),
        1 => (0usize..5, 0u64..3_000).prop_map(|(a, v)| Op::Stake(a, v * COIN)),
        1 => (0usize..5, 0u64..3_000).prop_map(|(a, v)| Op::Unstake(a, v * COIN)),
        1 => (0usize..5).prop_map(Op::Bad),
    ]
}

proptest! {
    #![proptest_config(ProptestConfig { cases: 120, ..ProptestConfig::default() })]

    /// Whatever people do, no CTDY appears from nowhere or disappears: every coin is in a balance,
    /// a stake, or on its way out of a stake, and the total only grows by block rewards.
    /// Two nodes running the same blocks always end with the same state root.
    #[test]
    fn coins_are_never_created_or_lost(blocks in proptest::collection::vec(proptest::collection::vec(op(), 0..8), 1..12)) {
        let names = ["arjun", "bank", "alice", "bob", "eve"];
        let keys: Vec<Keypair> = names.iter().map(|n| Keypair::from_seed(n)).collect();
        let mut g = Genesis::devnet();
        g.initial_bits = 1;
        g.unbonding_blocks = 3;
        g.alloc.push((keys[4].address(), 5_000 * COIN));
        let miner = Keypair::from_seed("miner");
        let mut c = Chain::new(g.clone());
        let mut twin = Chain::new(g.clone());
        let mut nonces = [0u64; 5];
        let start = c.tip_state().supply;
        for (bi, ops) in blocks.iter().enumerate() {
            let mut txs = Vec::new();
            for o in ops {
                let (who, kind) = match o {
                    Op::Send(a, b, v) => (*a, TxKind::Transfer { to: keys[*b].address(), amount: *v }),
                    Op::Stake(a, v) => (*a, TxKind::Stake { amount: *v }),
                    Op::Unstake(a, v) => (*a, TxKind::Unstake { amount: *v }),
                    // Wrong nonce on purpose: must be left out, not break anything.
                    Op::Bad(a) => (*a, TxKind::Transfer { to: keys[0].address(), amount: 1 }),
                };
                let nonce = if matches!(o, Op::Bad(_)) { nonces[who] + 50 } else { nonces[who] };
                txs.push(Tx::new_signed(&g.chain_id, &keys[who], nonce, 21_000, 1, kind));
                if !matches!(o, Op::Bad(_)) { nonces[who] += 1; }
            }
            let parent = c.tip_block().header.clone();
            let ps = c.tip_state();
            let (mut b, _, _) = build_block(&g, &parent, &ps, &miner, parent.time + 1_000, 0, &txs, None);
            prop_assert!(mine(&mut b.header, &|| false));
            c.add_block(b.clone()).unwrap();
            twin.add_block(b).unwrap();
            // Txs that couldn't go in (overspending, bad nonce) were dropped, so resync nonces.
            let s = c.tip_state();
            for (i, k) in keys.iter().enumerate() {
                nonces[i] = s.account(&k.address()).nonce;
            }
            let held: u64 = s.accounts.values().map(|a| a.balance + a.stake + a.unbonding.iter().map(|u| u.1).sum::<u64>()).sum();
            prop_assert_eq!(held, s.supply, "every coin accounted for after block {}", bi + 1);
            prop_assert_eq!(s.supply, start + (bi as u64 + 1) * g.pow_reward);
            prop_assert_eq!(s.root(), twin.tip_state().root());
        }
    }
}
