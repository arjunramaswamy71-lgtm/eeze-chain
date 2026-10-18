use eeze_core::abi::{self, Arg};
use eeze_core::state::{build_block, mine, Genesis};
use eeze_core::*;

fn g() -> Genesis {
    let mut g = Genesis::devnet();
    g.initial_bits = 4;
    g.pos_height = 1_000;
    g
}

/// Makes the next block on the tip: mines it, or signs it if staking has started.
fn next(c: &mut Chain, keys: &[&Keypair], txs: Vec<Tx>) -> Block {
    let parent = c.tip_block().header.clone();
    let ps = c.tip_state();
    let gc = c.genesis.clone();
    let h = parent.height + 1;
    if ps.is_pos(&gc, h) {
        for round in 0..20u32 {
            let who = ps.proposer(&gc, &parent.hash(), h, round).unwrap();
            if let Some(k) = keys.iter().find(|k| k.address() == who) {
                let t = parent.time + gc.target_ms + round as u64 * gc.slot_ms;
                let (mut b, _, _) = build_block(&gc, &parent, &ps, k.public(), t, round, &txs);
                b.sig = Some(k.sign(&b.header.hash().0));
                assert!(matches!(c.add_block(b.clone()).unwrap(), Added::NewTip { .. }));
                return b;
            }
        }
        panic!("none of our validators got a turn");
    }
    let (mut b, _, _) = build_block(&gc, &parent, &ps, keys[0].public(), parent.time + gc.target_ms, 0, &txs);
    assert!(mine(&mut b.header, &|| false));
    let r = c.add_block(b.clone()).unwrap();
    assert!(matches!(r, Added::NewTip { .. }), "{r:?}");
    b
}

#[test]
fn send_coins_and_pay_fees() {
    let arjun = Keypair::from_seed("arjun");
    let bob = Keypair::from_seed("bob");
    let miner = Keypair::from_seed("miner");
    let mut c = Chain::new(g());
    let id = c.genesis.chain_id.clone();
    let tx = Tx::new_signed(&id, &arjun, 0, 21_000, 2, TxKind::Transfer { to: bob.address(), amount: 5 * COIN });
    c.submit_tx(tx.clone()).unwrap();
    let p = c.pending();
    next(&mut c, &[&miner], p);
    let s = c.tip_state();
    assert_eq!(s.account(&bob.address()).balance, 10_005 * COIN);
    assert_eq!(s.account(&arjun.address()).balance, 1_000_000 * COIN - 5 * COIN - 42_000);
    assert_eq!(s.account(&miner.address()).balance, 50 * COIN + 42_000);
    assert!(c.mempool.is_empty());
    let (h, _, r) = c.find_tx(&tx.hash()).unwrap();
    assert_eq!((h, r.ok, r.fee), (1, true, 42_000));

    // The same transaction again is rejected: its nonce is used up.
    assert!(c.submit_tx(tx).is_ok()); // already known, just returns the hash
    let replay = Tx::new_signed(&id, &arjun, 0, 21_000, 3, TxKind::Transfer { to: bob.address(), amount: 1 });
    assert!(c.submit_tx(replay).is_err());

    // A tampered transaction fails its signature check.
    let mut bad = Tx::new_signed(&id, &arjun, 1, 21_000, 1, TxKind::Transfer { to: bob.address(), amount: 1 });
    if let TxKind::Transfer { amount, .. } = &mut bad.kind {
        *amount = 999 * COIN;
    }
    assert_eq!(c.submit_tx(bad).unwrap_err(), "bad signature");

    // A signature from another chain doesn't work here.
    let other = Tx::new_signed("someone-else", &arjun, 1, 21_000, 1, TxKind::Transfer { to: bob.address(), amount: 1 });
    assert!(c.submit_tx(other).is_err());
}

#[test]
fn proof_of_work_rejects_lazy_blocks_and_adjusts() {
    let miner = Keypair::from_seed("miner");
    let mut c = Chain::new(g());
    for _ in 0..3 {
        next(&mut c, &[&miner], vec![]);
    }
    let parent = c.tip_block().header.clone();
    let ps = c.tip_state();
    let gc = c.genesis.clone();
    let (mut b, _, _) = build_block(&gc, &parent, &ps, miner.public(), parent.time + 10, 0, &[]);
    while leading_zero_bits(&b.header.hash()) >= b.header.bits {
        b.header.nonce += 1; // find a hash WITHOUT enough work
    }
    assert_eq!(c.add_block(b).unwrap_err(), "not enough work");

    // Blocks coming 4x too fast: 2 more zero bits (4x the work) at the next 10-block mark.
    let start = c.tip_state().bits;
    let mut c2 = Chain::new(g());
    for _ in 0..10 {
        let parent = c2.tip_block().header.clone();
        let ps = c2.tip_state();
        let (mut b, _, _) = build_block(&gc, &parent, &ps, miner.public(), parent.time + gc.target_ms / 4, 0, &[]);
        assert!(mine(&mut b.header, &|| false));
        c2.add_block(b).unwrap();
    }
    assert_eq!(c2.tip_state().bits, start + 2);
}

#[test]
fn heavier_fork_wins_and_returns_transactions() {
    let a = Keypair::from_seed("miner-a");
    let b = Keypair::from_seed("miner-b");
    let arjun = Keypair::from_seed("arjun");
    let gc = g();
    let mut c = Chain::new(gc.clone());
    next(&mut c, &[&a], vec![]);
    let fork_point = c.tip_block().header.clone();
    let fork_state = c.tip_state();

    // Chain A: one block with a payment in it.
    let pay = Tx::new_signed(&gc.chain_id, &arjun, 0, 21_000, 1, TxKind::Transfer { to: a.address(), amount: COIN });
    next(&mut c, &[&a], vec![pay.clone()]);
    assert!(c.find_tx(&pay.hash()).is_some());

    // Chain B: two blocks from the same fork point, without the payment. More work, so it wins.
    let (mut b1, s1, _) = build_block(&gc, &fork_point, &fork_state, b.public(), fork_point.time + 5, 0, &[]);
    assert!(mine(&mut b1.header, &|| false));
    assert_eq!(c.add_block(b1.clone()).unwrap(), Added::SideChain);
    let (mut b2, _, _) = build_block(&gc, &b1.header, &s1, b.public(), b1.header.time + 5, 0, &[]);
    assert!(mine(&mut b2.header, &|| false));
    assert_eq!(c.add_block(b2.clone()).unwrap(), Added::NewTip { reorg_depth: 1 });
    assert_eq!(c.tip, b2.hash());
    // The payment fell out of the chain and is waiting again.
    assert!(c.find_tx(&pay.hash()).is_none());
    assert!(c.mempool.contains_key(&pay.hash()));
}

#[test]
fn orphans_connect_when_parent_arrives() {
    let a = Keypair::from_seed("miner-a");
    let gc = g();
    let mut c = Chain::new(gc.clone());
    let mut builder = Chain::new(gc.clone());
    let b1 = next(&mut builder, &[&a], vec![]);
    let b2 = next(&mut builder, &[&a], vec![]);
    assert_eq!(c.add_block(b2.clone()).unwrap(), Added::Orphan);
    assert!(matches!(c.add_block(b1).unwrap(), Added::NewTip { .. }));
    assert_eq!(c.tip, b2.hash());
}

#[test]
fn switches_from_mining_to_staking_and_slashes_cheaters() {
    let miner = Keypair::from_seed("miner");
    let v1 = Keypair::from_seed("arjun");
    let v2 = Keypair::from_seed("bank");
    let mut gc = g();
    gc.pos_height = 5;
    let mut c = Chain::new(gc.clone());
    let id = gc.chain_id.clone();
    // Two people stake while mining is still going.
    let s1 = Tx::new_signed(&id, &v1, 0, 21_000, 1, TxKind::Stake { amount: 5_000 * COIN });
    let s2 = Tx::new_signed(&id, &v2, 0, 21_000, 1, TxKind::Stake { amount: 15_000 * COIN });
    next(&mut c, &[&miner], vec![s1, s2]);
    for _ in 0..3 {
        next(&mut c, &[&miner], vec![]);
    }
    assert_eq!(c.height(), 4);
    assert!(c.tip_state().is_pos(&gc, 5));

    // From height 5 only validators can make blocks. A miner's block is refused.
    let parent = c.tip_block().header.clone();
    let ps = c.tip_state();
    let (mut mined, _, _) = build_block(&gc, &parent, &ps, miner.public(), parent.time + 5_000, 0, &[]);
    mined.header.bits = 4;
    assert!(mine(&mut mined.header, &|| false));
    assert!(c.add_block(mined).is_err());

    // Validators take turns. Count who gets picked: bank has 3x the stake, so ~3x the blocks.
    let mut count = std::collections::HashMap::new();
    for _ in 0..200 {
        let b = next(&mut c, &[&v1, &v2], vec![]);
        *count.entry(b.header.producer.address()).or_insert(0) += 1;
    }
    let (n1, n2) = (count[&v1.address()], count[&v2.address()]);
    assert!(n2 > 2 * n1 && n2 < 4 * n1, "arjun {n1}, bank {n2}");

    // The wrong validator can't sign someone else's turn.
    let parent = c.tip_block().header.clone();
    let ps = c.tip_state();
    let who = ps.proposer(&gc, &parent.hash(), parent.height + 1, 0).unwrap();
    let wrong = if who == v1.address() { &v2 } else { &v1 };
    let (mut b, _, _) = build_block(&gc, &parent, &ps, wrong.public(), parent.time + gc.target_ms, 0, &[]);
    b.sig = Some(wrong.sign(&b.header.hash().0));
    assert!(c.add_block(b).unwrap_err().contains("not this validator's turn"));

    // A validator signs two different blocks for the same turn. Anyone can report it.
    let right = if who == v1.address() { &v1 } else { &v2 };
    let (b_a, _, _) = build_block(&gc, &parent, &ps, right.public(), parent.time + gc.target_ms, 0, &[]);
    let (b_b, _, _) = build_block(&gc, &parent, &ps, right.public(), parent.time + gc.target_ms + 7, 0, &[]);
    let ev = TxKind::Evidence {
        a: SignedHeader { sig: right.sign(&b_a.header.hash().0), header: b_a.header.clone() },
        b: SignedHeader { sig: right.sign(&b_b.header.hash().0), header: b_b.header.clone() },
    };
    let reporter = Keypair::from_seed("alice");
    let stake_before = c.tip_state().account(&right.address()).stake;
    let report = Tx::new_signed(&id, &reporter, 0, 21_000, 1, ev.clone());
    next(&mut c, &[&v1, &v2], vec![report.clone()]);
    let s = c.tip_state();
    let (_, _, r) = c.find_tx(&report.hash()).unwrap();
    assert!(r.ok, "{:?}", r.error);
    assert_eq!(s.account(&right.address()).stake, stake_before - stake_before / 2);
    assert_eq!(s.burned, stake_before / 2 - stake_before / 2 / 10);
    // Reporting the same thing twice does nothing.
    let again = Tx::new_signed(&id, &reporter, 1, 21_000, 1, ev);
    next(&mut c, &[&v1, &v2], vec![again.clone()]);
    assert!(!c.find_tx(&again.hash()).unwrap().2.ok);
}

#[test]
fn unstaking_waits_before_paying_out() {
    let miner = Keypair::from_seed("miner");
    let v = Keypair::from_seed("alice");
    let gc = g();
    let id = gc.chain_id.clone();
    let mut c = Chain::new(gc.clone());
    next(&mut c, &[&miner], vec![Tx::new_signed(&id, &v, 0, 21_000, 1, TxKind::Stake { amount: 2_000 * COIN })]);
    next(&mut c, &[&miner], vec![Tx::new_signed(&id, &v, 1, 21_000, 1, TxKind::Unstake { amount: 2_000 * COIN })]);
    let bal = c.tip_state().account(&v.address()).balance;
    for _ in 0..gc.unbonding_blocks - 1 {
        next(&mut c, &[&miner], vec![]);
    }
    assert_eq!(c.tip_state().account(&v.address()).balance, bal);
    next(&mut c, &[&miner], vec![]);
    assert_eq!(c.tip_state().account(&v.address()).balance, bal + 2_000 * COIN);
}

const COUNTER: &str = r#"
(module
  (import "env" "input_len" (func $input_len (result i32)))
  (import "env" "input_read" (func $input_read (param i32)))
  (import "env" "storage_read" (func $sread (param i32 i32 i32) (result i32)))
  (import "env" "storage_write" (func $swrite (param i32 i32 i32 i32)))
  (import "env" "output" (func $output (param i32 i32)))
  (import "env" "transfer" (func $transfer (param i32 i64) (result i32)))
  (import "env" "caller" (func $caller (param i32)))
  (import "env" "revert" (func $revert (param i32 i32)))
  (import "env" "emit" (func $emit (param i32 i32 i32 i32)))
  (memory (export "memory") 1)
  (data (i32.const 0) "count")
  (data (i32.const 16) "bump")
  ;; input byte 0: 1 = add one, 2 = loop forever, 3 = add one then fail, 4 = pay caller 7 units
  (func (export "call")
    (local $op i32)
    (call $input_read (i32.const 100))
    (local.set $op (i32.load8_u (i32.const 100)))
    (if (i32.eq (local.get $op) (i32.const 2)) (then (loop $l (br $l))))
    (if (i32.eq (local.get $op) (i32.const 4)) (then
      (call $caller (i32.const 300))
      (drop (call $transfer (i32.const 300) (i64.const 7)))
      (return)))
    (drop (call $sread (i32.const 0) (i32.const 5) (i32.const 200)))
    (i64.store (i32.const 200) (i64.add (i64.load (i32.const 200)) (i64.const 1)))
    (call $swrite (i32.const 0) (i32.const 5) (i32.const 200) (i32.const 8))
    (call $emit (i32.const 16) (i32.const 4) (i32.const 200) (i32.const 8))
    (call $output (i32.const 200) (i32.const 8))
    (if (i32.eq (local.get $op) (i32.const 3)) (then (call $revert (i32.const 16) (i32.const 4)))))
)"#;

#[test]
fn contracts_run_charge_gas_and_undo_on_failure() {
    let miner = Keypair::from_seed("miner");
    let me = Keypair::from_seed("arjun");
    let gc = g();
    let id = gc.chain_id.clone();
    let mut c = Chain::new(gc.clone());
    let code = wat::parse_str(COUNTER).unwrap();
    let deploy = Tx::new_signed(&id, &me, 0, 2_000_000, 1, TxKind::Deploy { code: Bytes(code), args: Bytes::default() });
    next(&mut c, &[&miner], vec![deploy.clone()]);
    let addr = c.find_tx(&deploy.hash()).unwrap().2.contract.unwrap();
    let call = |n: u64, op: u8, value: u64| {
        Tx::new_signed(&id, &me, n, 500_000, 1, TxKind::Call { contract: addr, amount: value, args: Bytes(vec![op]) })
    };
    let read_count = |c: &Chain| {
        let s = c.tip_state();
        let v = s.contracts[&addr].storage.get(b"count".as_slice()).cloned().unwrap_or(vec![0; 8]);
        u64::from_le_bytes(v.try_into().unwrap())
    };

    let t1 = call(1, 1, 0);
    let t2 = call(2, 1, 0);
    next(&mut c, &[&miner], vec![t1, t2.clone()]);
    assert_eq!(read_count(&c), 2);
    let r = c.find_tx(&t2.hash()).unwrap().2;
    assert_eq!(r.output.0, 2u64.to_le_bytes());
    assert_eq!(r.events[0].topic, "bump");

    // An endless loop runs out of gas and is charged the whole limit, but the chain carries on.
    let bal = c.tip_state().account(&me.address()).balance;
    let t3 = call(3, 2, 0);
    next(&mut c, &[&miner], vec![t3.clone()]);
    let r = c.find_tx(&t3.hash()).unwrap().2;
    assert_eq!((r.ok, r.error.as_deref(), r.gas_used), (false, Some("out of gas"), 500_000));
    assert_eq!(c.tip_state().account(&me.address()).balance, bal - 500_000);

    // A call that changes storage and then fails leaves storage as it was, and keeps the CTDY sent.
    let t4 = call(4, 3, 5 * COIN);
    next(&mut c, &[&miner], vec![t4.clone()]);
    let r = c.find_tx(&t4.hash()).unwrap().2;
    assert!(!r.ok && r.error.unwrap().contains("reverted: bump"));
    assert_eq!(read_count(&c), 2);
    assert_eq!(c.tip_state().account(&addr).balance, 0);

    // Contracts can hold CTDY and pay it out.
    let fund = call(5, 1, 100);
    let pay = call(6, 4, 0);
    next(&mut c, &[&miner], vec![fund, pay]);
    assert_eq!(c.tip_state().account(&addr).balance, 93);

    // Code that tries to import something it isn't allowed to never gets on the chain.
    let sneaky = wat::parse_str(r#"(module (import "env" "steal" (func)) (func (export "call")))"#).unwrap();
    let bad = Tx::new_signed(&id, &me, 7, 2_000_000, 1, TxKind::Deploy { code: Bytes(sneaky), args: Bytes::default() });
    assert!(c.submit_tx(bad.clone()).is_ok());
    let p = c.pending();
    next(&mut c, &[&miner], p);
    assert!(c.find_tx(&bad.hash()).is_none());
}

#[test]
fn merkle_proofs_and_abi() {
    let leaves: Vec<Hash> = (0..7u8).map(|i| hash_with("x", &[i])).collect();
    let root = merkle_root(&leaves);
    for i in 0..7 {
        assert!(merkle_verify(leaves[i], &merkle_proof(&leaves, i), root));
    }
    assert!(!merkle_verify(leaves[1], &merkle_proof(&leaves, 2), root));
    let a = Keypair::from_seed("x").address();
    let args = vec![Arg::Str("buy".into()), Arg::U64(5), Arg::Addr(a), Arg::Bytes(vec![1, 2])];
    assert_eq!(abi::decode(&abi::encode(&args)).unwrap(), args);
}
