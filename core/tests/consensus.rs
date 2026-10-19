//! Fair validator picking (VRF) and finality.
use eeze_core::state::{Genesis, build_block};
use eeze_core::*;

/// A staking-only chain with three equal validators from the start.
fn pos_chain(names: &[&str]) -> (Chain, Vec<Keypair>) {
    let keys: Vec<Keypair> = names.iter().map(|n| Keypair::from_seed(n)).collect();
    let mut g = Genesis::devnet();
    g.pos_height = 1;
    g.stakes = keys
        .iter()
        .map(|k| (k.address(), 10_000 * COIN, k.vrf().public()))
        .collect();
    (Chain::new(g), keys)
}

/// Makes the next staking block with whoever's turn it is.
fn step(c: &mut Chain, keys: &[Keypair], commit: Option<Commit>) -> Block {
    let parent = c.tip_block().header.clone();
    let ps = c.tip_state();
    let g = c.genesis.clone();
    let h = parent.height + 1;
    for round in 0..50u32 {
        let who = ps.proposer(&g, h, round).unwrap();
        if let Some(k) = keys.iter().find(|k| k.address() == who) {
            let t = parent.time + g.target_ms + round as u64 * g.slot_ms;
            let (b, _, _) = build_block(&g, &parent, &ps, k, t, round, &[], commit);
            let r = c.add_block(b.clone()).unwrap();
            assert!(matches!(r, Added::NewTip { .. }), "{r:?}");
            return b;
        }
    }
    panic!("nobody's turn")
}

fn vote_all(c: &mut Chain, keys: &[Keypair], b: &Block) {
    for k in keys {
        let v = Vote::new(&c.genesis.chain_id, k, b.header.height, b.hash());
        assert_eq!(c.add_vote(v).unwrap(), chain::VoteAdded::New);
    }
}

#[test]
fn vrf_gives_one_answer_that_anyone_can_check() {
    let k = Keypair::from_seed("arjun");
    let other = Keypair::from_seed("bank");
    let input = vrf_input(&Hash([7; 32]), 42);
    let (pre, proof, out) = k.vrf().prove(&input);
    let (pre2, _, out2) = k.vrf().prove(&input);
    assert_eq!(
        (pre, out),
        (pre2, out2),
        "same key + same input = same output, no rerolls"
    );
    assert_eq!(
        vrf_verify(&k.vrf().public(), &input, &pre, &proof),
        Some(out)
    );
    // Someone else's key, a different height, or a tampered proof all fail.
    assert_eq!(
        vrf_verify(&other.vrf().public(), &input, &pre, &proof),
        None
    );
    assert_eq!(
        vrf_verify(
            &k.vrf().public(),
            &vrf_input(&Hash([7; 32]), 43),
            &pre,
            &proof
        ),
        None
    );
    let mut bad = proof;
    bad.0[5] ^= 1;
    assert_eq!(vrf_verify(&k.vrf().public(), &input, &pre, &bad), None);
    assert_ne!(other.vrf().prove(&input).2, out);
}

#[test]
fn changing_a_block_cannot_change_who_goes_next() {
    // The grinding attack: a producer tries many versions of its block hoping one hands the next
    // turns to itself. With the VRF, every version leads to the same next proposers.
    let (c, keys) = pos_chain(&["arjun", "bank", "alice"]);
    let g = c.genesis.clone();
    let parent = c.tip_block().header.clone();
    let ps = c.tip_state();
    let who = ps.proposer(&g, 1, 0).unwrap();
    let k = keys.iter().find(|k| k.address() == who).unwrap();
    let mut schedules = std::collections::HashSet::new();
    for variant in 0..30u64 {
        let tx = Tx::new_signed(
            &g.chain_id,
            k,
            0,
            21_000,
            1 + variant,
            TxKind::Transfer {
                to: keys[0].address(),
                amount: variant,
            },
        );
        let (_, s, _) = build_block(
            &g,
            &parent,
            &ps,
            k,
            parent.time + g.target_ms + variant,
            0,
            &[tx],
            None,
        );
        let next: Vec<Address> = (0..5).map(|r| s.proposer(&g, 2, r).unwrap()).collect();
        schedules.insert(next);
    }
    assert_eq!(
        schedules.len(),
        1,
        "30 different blocks, one possible future"
    );
}

#[test]
fn a_bad_vrf_reveal_is_rejected() {
    let (mut c, keys) = pos_chain(&["arjun", "bank", "alice"]);
    let g = c.genesis.clone();
    let parent = c.tip_block().header.clone();
    let ps = c.tip_state();
    let who = ps.proposer(&g, 1, 0).unwrap();
    let k = keys.iter().find(|k| k.address() == who).unwrap();
    let (mut b, _, _) = build_block(&g, &parent, &ps, k, parent.time + g.target_ms, 0, &[], None);
    b.header.vrf_preout.0[0] ^= 1;
    b.sig = Some(k.sign(&b.header.hash().0));
    assert!(c.add_block(b).unwrap_err().contains("VRF"));
}

#[test]
fn two_thirds_of_votes_make_a_block_final() {
    let (mut c, keys) = pos_chain(&["arjun", "bank", "alice"]);
    let b1 = step(&mut c, &keys, None);
    assert_eq!(c.finalized().0, 0);

    // Two of three equal validators is exactly 2/3. That's not MORE than 2/3, so not final.
    for k in &keys[..2] {
        c.add_vote(Vote::new(&c.genesis.chain_id, k, 1, b1.hash()))
            .unwrap();
    }
    assert!(c.best_commit().is_none());

    // The third vote tips it over. The next block carries the votes and #1 becomes final.
    c.add_vote(Vote::new(&c.genesis.chain_id, &keys[2], 1, b1.hash()))
        .unwrap();
    let commit = c.best_commit().unwrap();
    assert_eq!((commit.height, commit.votes.len()), (1, 3));
    step(&mut c, &keys, Some(commit));
    assert_eq!(c.finalized(), (1, b1.hash()));
}

#[test]
fn fake_or_short_commits_make_a_block_invalid() {
    let (mut c, keys) = pos_chain(&["arjun", "bank", "alice"]);
    let b1 = step(&mut c, &keys, None);
    let g = c.genesis.clone();
    let parent = c.tip_block().header.clone();
    let ps = c.tip_state();
    let who = ps.proposer(&g, 2, 0).unwrap();
    let k = keys.iter().find(|k| k.address() == who).unwrap();
    let mk = |votes: Vec<Vote>| {
        let commit = Some(Commit {
            height: 1,
            block: b1.hash(),
            votes,
        });
        let mut b = build_block(&g, &parent, &ps, k, parent.time + g.target_ms, 0, &[], None).0;
        b.commit = commit.clone();
        b.header.commit_root = Commit::root(&commit);
        b.sig = Some(k.sign(&b.header.hash().0));
        b
    };
    let v = |k: &Keypair| Vote::new(&g.chain_id, k, 1, b1.hash());
    // Not enough stake.
    let mut cc = Chain::new(g.clone());
    cc.add_block(b1.clone()).unwrap();
    assert!(cc.add_block(mk(vec![v(&keys[0]), v(&keys[1])])).is_err());
    // The same validator counted twice.
    assert!(
        cc.add_block(mk(vec![v(&keys[0]), v(&keys[0]), v(&keys[1])]))
            .is_err()
    );
    // A vote from someone who isn't a validator.
    assert!(
        cc.add_block(mk(vec![
            v(&keys[0]),
            v(&keys[1]),
            v(&Keypair::from_seed("eve"))
        ]))
        .is_err()
    );
    // A forged signature.
    let mut forged = v(&keys[2]);
    forged.sig.0[0] ^= 1;
    assert!(
        cc.add_block(mk(vec![v(&keys[0]), v(&keys[1]), forged]))
            .is_err()
    );
}

#[test]
fn a_final_block_is_never_undone_and_double_voters_pay() {
    let (mut c, keys) = pos_chain(&["arjun", "bank", "alice"]);
    let g = c.genesis.clone();
    let b1 = step(&mut c, &keys, None);
    vote_all(&mut c, &keys, &b1);
    let commit = c.best_commit().unwrap();
    step(&mut c, &keys, Some(commit));
    assert_eq!(c.finalized().0, 1);

    // (The node dropped genesis's state once #1 was final, so rebuild it from the config.)
    let (gb, gs) = g.genesis_block();
    let genesis = gb.header;
    let who = gs.proposer(&g, 1, 1).unwrap();
    let k = keys.iter().find(|k| k.address() == who).unwrap();
    let (alt1, s1, _) = build_block(
        &g,
        &genesis,
        &gs,
        k,
        genesis.time + g.target_ms + g.slot_ms,
        1,
        &[],
        None,
    );
    let alt_votes: Vec<Vote> = keys
        .iter()
        .map(|k| Vote::new(&g.chain_id, k, 1, alt1.hash()))
        .collect();
    let alt_commit = Commit {
        height: 1,
        block: alt1.hash(),
        votes: alt_votes.clone(),
    };
    // A long fork on top of it that also claims #1 is final.
    let mut fork = vec![alt1.clone()];
    let (mut ph, mut ps) = (alt1.header.clone(), s1);
    for i in 0..5 {
        let h = ph.height + 1;
        let who = ps.proposer(&g, h, 0).unwrap();
        let k = keys.iter().find(|k| k.address() == who).unwrap();
        let commit = if i == 0 {
            Some(alt_commit.clone())
        } else {
            None
        };
        let (b, s, _) = build_block(&g, &ph, &ps, k, ph.time + g.target_ms, 0, &[], commit);
        ph = b.header.clone();
        ps = s;
        fork.push(b);
    }
    let tip_before = c.tip;
    for b in fork {
        // Turned away outright, or kept on the side, but never followed.
        let r = c.add_block(b);
        assert!(
            !matches!(r, Ok(Added::NewTip { .. })),
            "a fork that undoes a final block was followed"
        );
    }
    assert_eq!(c.tip, tip_before);

    // Their double votes are caught, and anyone can turn them into slashing.
    let first = Vote::new(&g.chain_id, &keys[0], 1, b1.hash());
    match c.add_vote(alt_votes[0].clone()) {
        Ok(chain::VoteAdded::Known) => {} // height 1 is already final, nothing more to collect
        other => panic!("{other:?}"),
    }
    let reporter = Keypair::from_seed("bob");
    let ev = Tx::new_signed(
        &g.chain_id,
        &reporter,
        0,
        21_000,
        1,
        TxKind::VoteEvidence {
            a: first,
            b: alt_votes[0].clone(),
        },
    );
    let before = c.tip_state().account(&keys[0].address()).stake;
    step(&mut c, &keys, None);
    c.submit_tx(ev.clone()).unwrap();
    let p = c.pending();
    let parent = c.tip_block().header.clone();
    let ps = c.tip_state();
    let h = parent.height + 1;
    for round in 0..50u32 {
        let who = ps.proposer(&g, h, round).unwrap();
        if let Some(k) = keys.iter().find(|k| k.address() == who) {
            let (b, _, _) = build_block(
                &g,
                &parent,
                &ps,
                k,
                parent.time + g.target_ms + round as u64 * g.slot_ms,
                round,
                &p,
                None,
            );
            c.add_block(b).unwrap();
            break;
        }
    }
    let r = c.find_tx(&ev.hash()).unwrap().2;
    assert!(r.ok, "{:?}", r.error);
    assert_eq!(
        c.tip_state().account(&keys[0].address()).stake,
        before - before / 2
    );
}

#[test]
fn a_long_fork_that_finalizes_more_wins_even_far_behind_the_tip() {
    // Both sides agree #1 is final. Then the network splits: one side keeps making blocks but
    // can't finalize anything (150 blocks), the other side has the votes and finalizes #3. When
    // they meet, the side with more finality must win, even though its fork starts way back.
    let (mut c, keys) = pos_chain(&["arjun", "bank", "alice"]);
    let g = c.genesis.clone();
    let b1 = step(&mut c, &keys, None);
    vote_all(&mut c, &keys, &b1);
    let commit = c.best_commit().unwrap();
    step(&mut c, &keys, Some(commit));
    assert_eq!(c.finalized().0, 1);
    let (mut ph, mut ps) = (c.tip_block().header.clone(), (*c.tip_state()).clone());

    for _ in 0..150 {
        step(&mut c, &keys, None);
    }
    assert_eq!(c.finalized().0, 1);
    let long_tip = c.tip;

    // The other side: #3 made a turn late (so it differs), then #4 carries the votes for it.
    let mut fork = vec![];
    let mut commit = None;
    for min_round in [1u32, 0] {
        let h = ph.height + 1;
        let (b, s) = (min_round..60)
            .find_map(|round| {
                let who = ps.proposer(&g, h, round).unwrap();
                let k = keys.iter().find(|k| k.address() == who)?;
                let t = ph.time + g.target_ms + round as u64 * g.slot_ms;
                let (b, s, _) = build_block(&g, &ph, &ps, k, t, round, &[], commit.clone());
                Some((b, s))
            })
            .unwrap();
        let votes = keys
            .iter()
            .map(|k| Vote::new(&g.chain_id, k, h, b.hash()))
            .collect();
        commit = Some(Commit {
            height: h,
            block: b.hash(),
            votes,
        });
        ph = b.header.clone();
        ps = s;
        fork.push(b);
    }
    for b in fork {
        c.add_block(b).unwrap();
    }
    assert_ne!(c.tip, long_tip, "switched to the side that finalized more");
    assert_eq!(c.finalized().0, 3);
    assert_eq!(c.height(), 4);
}

#[test]
fn double_votes_are_spotted_as_they_arrive() {
    let (mut c, keys) = pos_chain(&["arjun", "bank", "alice"]);
    let b1 = step(&mut c, &keys, None);
    let id = c.genesis.chain_id.clone();
    assert_eq!(
        c.add_vote(Vote::new(&id, &keys[0], 1, b1.hash())).unwrap(),
        chain::VoteAdded::New
    );
    assert_eq!(
        c.add_vote(Vote::new(&id, &keys[0], 1, b1.hash())).unwrap(),
        chain::VoteAdded::Known
    );
    match c
        .add_vote(Vote::new(&id, &keys[0], 1, Hash([9; 32])))
        .unwrap()
    {
        chain::VoteAdded::DoubleVote(a, b) => assert_ne!(a.block, b.block),
        other => panic!("{other:?}"),
    }
}

#[test]
fn light_client_proofs_check_out_against_the_state_root() {
    let (mut c, keys) = pos_chain(&["arjun", "bank", "alice"]);
    step(&mut c, &keys, None);
    let s = c.tip_state();
    let root = c.tip_block().header.state_root;
    for k in &keys {
        let (acc, _, proof) = s.account_proof(&k.address()).unwrap();
        let leaf = hash_with("EEZE-ACCT", &acc.leaf_bytes(&k.address()));
        assert!(merkle_verify(leaf, &proof, root));
        // Change one number and the proof no longer matches.
        let mut fake = acc.clone();
        fake.balance += 1;
        assert!(!merkle_verify(
            hash_with("EEZE-ACCT", &fake.leaf_bytes(&k.address())),
            &proof,
            root
        ));
    }
    let (meta, _, proof) = s.meta_proof();
    assert!(merkle_verify(hash_with("EEZE-META", &meta), &proof, root));
    assert_eq!(
        u64::from_le_bytes(meta[..8].try_into().unwrap()),
        30_000 * COIN
    );
}

#[test]
fn a_snapshot_restores_exactly() {
    let (mut c, keys) = pos_chain(&["arjun", "bank", "alice"]);
    for _ in 0..5 {
        step(&mut c, &keys, None);
    }
    let s = c.tip_state();
    let back = State::from_bytes(&s.to_bytes()).unwrap();
    assert_eq!(back.root(), s.root());
    let history: Vec<(Block, Vec<Receipt>)> = c
        .best
        .iter()
        .map(|h| (c.blocks[h].block.clone(), c.blocks[h].receipts.clone()))
        .collect();
    let mut r = Chain::restore(c.genesis.clone(), history, back).unwrap();
    assert_eq!((r.height(), r.tip), (c.height(), c.tip));
    // And it carries on making blocks from there.
    step(&mut r, &keys, None);
    assert_eq!(r.height(), 6);
}
