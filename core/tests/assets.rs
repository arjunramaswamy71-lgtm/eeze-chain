//! The identity registry, the compliant security token, the T-bill fund and the market pool,
//! run on the chain the way users would.
use eeze_core::abi::{self, Arg};
use eeze_core::state::{Genesis, build_block, mine};
use eeze_core::*;
use std::collections::HashMap;

struct Net {
    c: Chain,
    miner: Keypair,
    nonces: HashMap<Address, u64>,
}

impl Net {
    fn new() -> Net {
        let mut g = Genesis::devnet();
        g.initial_bits = 2;
        g.pos_height = 100_000;
        for w in ["carol", "dave", "kyc-co", "alice-new-phone"] {
            g.alloc
                .push((Keypair::from_seed(w).address(), 10_000 * COIN));
        }
        Net {
            c: Chain::new(g),
            miner: Keypair::from_seed("miner"),
            nonces: HashMap::new(),
        }
    }
    fn block(&mut self, txs: Vec<Tx>) {
        let parent = self.c.tip_block().header.clone();
        let ps = self.c.tip_state();
        let g = self.c.genesis.clone();
        let (mut b, _, _) = build_block(
            &g,
            &parent,
            &ps,
            &self.miner,
            parent.time + 2_000,
            0,
            &txs,
            None,
        );
        assert!(mine(&mut b.header, &|| false));
        self.c.add_block(b).unwrap();
    }
    fn send(&mut self, who: &Keypair, kind: TxKind) -> Receipt {
        let n = self.nonces.entry(who.address()).or_insert(0);
        let tx = Tx::new_signed(&self.c.genesis.chain_id, who, *n, 8_000_000, 1, kind);
        *n += 1;
        self.block(vec![tx.clone()]);
        self.c.find_tx(&tx.hash()).expect("tx went in").2
    }
    fn deploy(&mut self, who: &Keypair, file: &str, args: &[Arg]) -> Address {
        let code = std::fs::read(format!("../contracts/build/{file}"))
            .expect("build the contracts first: npm run build in contracts/");
        let r = self.send(
            who,
            TxKind::Deploy {
                code: Bytes(code),
                args: Bytes(abi::encode(args)),
            },
        );
        assert!(r.ok, "{:?}", r.error);
        r.contract.unwrap()
    }
    fn call(
        &mut self,
        who: &Keypair,
        contract: Address,
        value: u64,
        method: &str,
        args: &[Arg],
    ) -> Receipt {
        self.send(
            who,
            TxKind::Call {
                contract,
                amount: value,
                args: Bytes(abi::call(method, args)),
            },
        )
    }
    fn ok(
        &mut self,
        who: &Keypair,
        contract: Address,
        value: u64,
        method: &str,
        args: &[Arg],
    ) -> Receipt {
        let r = self.call(who, contract, value, method, args);
        assert!(r.ok, "{method} failed: {:?}", r.error);
        r
    }
    fn fails(
        &mut self,
        who: &Keypair,
        contract: Address,
        value: u64,
        method: &str,
        args: &[Arg],
        why: &str,
    ) {
        let r = self.call(who, contract, value, method, args);
        assert!(!r.ok, "{method} should have failed");
        let e = r.error.unwrap();
        assert!(e.contains(why), "{method}: expected '{why}', got '{e}'");
    }
    fn ask(&self, contract: Address, method: &str, args: &[Arg]) -> Vec<u64> {
        let out = self
            .c
            .tip_state()
            .query(
                &contract,
                abi::call(method, args),
                Address::default(),
                50_000_000,
            )
            .unwrap();
        abi::decode(&out)
            .unwrap()
            .into_iter()
            .map(|a| if let Arg::U64(v) = a { v } else { 0 })
            .collect()
    }
    fn shares(&self, t: Address, k: &Keypair) -> u64 {
        self.ask(t, "balance_of", &[a(k)])[0]
    }
    fn ctdy(&self, k: &Keypair) -> u64 {
        self.c.tip_state().account(&k.address()).balance
    }
}

fn a(k: &Keypair) -> Arg {
    Arg::Addr(k.address())
}
fn n(v: u64) -> Arg {
    Arg::U64(v)
}
fn s(v: &str) -> Arg {
    Arg::Str(v.into())
}
const KYC: u64 = 1;
const AML: u64 = 4;

struct World {
    net: Net,
    registry: Address,
    bank: Keypair,
    kyc: Keypair,
    alice: Keypair,
    bob: Keypair,
    carol: Keypair,
    dave: Keypair,
}

/// A bank runs the identity registry; a KYC company vouches for investors.
fn world() -> World {
    let mut net = Net::new();
    let k = Keypair::from_seed;
    let (bank, kyc, alice, bob, carol, dave) = (
        k("bank"),
        k("kyc-co"),
        k("alice"),
        k("bob"),
        k("carol"),
        k("dave"),
    );
    let registry = net.deploy(&bank, "identity.wasm", &[]);
    net.ok(&bank, registry, 0, "add_issuer", &[a(&kyc), n(KYC | AML)]);
    // Identity numbers and countries (ISO 3166): US 840, India 356, France 250.
    for (w, id, country) in [
        (&alice, 1, 840),
        (&bob, 2, 356),
        (&carol, 3, 250),
        (&dave, 4, 840),
    ] {
        net.ok(&bank, registry, 0, "register", &[a(w), n(id), n(country)]);
    }
    for id in [1, 2, 3] {
        net.ok(&kyc, registry, 0, "add_claim", &[n(id), n(KYC), n(0)]);
        net.ok(&kyc, registry, 0, "add_claim", &[n(id), n(AML), n(0)]);
    }
    World {
        net,
        registry,
        bank,
        kyc,
        alice,
        bob,
        carol,
        dave,
    }
}

fn property(w: &mut World) -> Address {
    let args = [
        s("Main St Building"),
        s("MSB"),
        s("property"),
        Arg::Addr(w.registry),
        n(KYC | AML),
        n(10 * COIN),
        n(1_000),
        s("deed sha256 9f2c41e1"),
    ];
    let bank = Keypair::from_seed("bank");
    w.net.deploy(&bank, "security.wasm", &args)
}

#[test]
fn registry_checks_and_claim_rules() {
    let mut w = world();
    let r = w.registry;
    let reg = |w: &World, k: &Keypair| w.net.ask(r, "is_verified", &[a(k), n(KYC | AML)])[0];
    assert_eq!(reg(&w, &w.alice), 1);
    assert_eq!(
        reg(&w, &w.dave),
        0,
        "dave is registered but nobody vouched for him"
    );
    // Only trusted issuers can add claims, and only for the topics they're trusted for.
    w.net.fails(
        &w.alice.clone(),
        r,
        0,
        "add_claim",
        &[n(4), n(KYC), n(0)],
        "not a trusted issuer",
    );
    w.net.fails(
        &w.kyc.clone(),
        r,
        0,
        "add_claim",
        &[n(4), n(2), n(0)],
        "not a trusted issuer",
    );
    // A claim can expire.
    let now = w.net.c.height();
    let kyc = w.kyc.clone();
    w.net
        .ok(&kyc, r, 0, "add_claim", &[n(4), n(KYC), n(now + 3)]);
    w.net.ok(&kyc, r, 0, "add_claim", &[n(4), n(AML), n(0)]);
    assert_eq!(reg(&w, &w.dave), 1);
    w.net.block(vec![]);
    w.net.block(vec![]);
    assert_eq!(reg(&w, &w.dave), 0, "dave's KYC expired");
}

#[test]
fn property_token_follows_every_rule() {
    let mut w = world();
    let t = property(&mut w);
    let (bank, alice, bob, carol, dave) = (
        w.bank.clone(),
        w.alice.clone(),
        w.bob.clone(),
        w.carol.clone(),
        w.dave.clone(),
    );
    let net = &mut w.net;

    // Dave never passed KYC: can't buy. Alice can, and the CTDY goes to the bank.
    net.fails(&dave, t, 100 * COIN, "buy", &[n(10)], "KYC");
    let bank_before = net.ctdy(&bank);
    net.ok(&alice, t, 1_000 * COIN, "buy", &[n(100)]);
    assert_eq!(net.ctdy(&bank), bank_before + 1_000 * COIN);
    assert_eq!(net.ask(t, "info", &[])[10], 1, "one holder");

    // Country rule: only the US and India.
    net.ok(&bank, t, 0, "allow_country", &[n(840)]);
    net.ok(&bank, t, 0, "allow_country", &[n(356)]);
    net.fails(&alice, t, 0, "transfer", &[a(&carol), n(5)], "country");
    net.ok(&alice, t, 0, "transfer", &[a(&bob), n(5)]);

    // Most shares per investor, and most holders.
    net.ok(&bank, t, 0, "set_rules", &[n(2), n(150)]);
    net.fails(&alice, t, 600 * COIN, "buy", &[n(60)], "limit per investor");
    net.ok(&bank, t, 0, "allow_country", &[n(250)]);
    net.fails(&alice, t, 0, "transfer", &[a(&carol), n(1)], "most holders");
    net.ok(&bank, t, 0, "set_rules", &[n(0), n(0)]);

    // Pause stops everyone; agents can still act.
    net.ok(&bank, t, 0, "pause", &[]);
    net.fails(&alice, t, 0, "transfer", &[a(&bob), n(1)], "paused");
    net.ok(&bank, t, 0, "unpause", &[]);

    // Freeze part of a balance: Alice has 95, 50 frozen, so 45 can move but 46 can't.
    net.ok(&bank, t, 0, "freeze_partial", &[a(&alice), n(50)]);
    net.fails(&alice, t, 0, "transfer", &[a(&bob), n(46)], "frozen");
    net.ok(&alice, t, 0, "transfer", &[a(&bob), n(45)]);
    assert_eq!(net.ask(t, "status", &[a(&alice)]), vec![1, 0, 50, 1, 0]);

    // Freeze a whole account.
    net.ok(&bank, t, 0, "freeze", &[a(&bob)]);
    net.fails(&bob, t, 0, "transfer", &[a(&alice), n(1)], "frozen");
    net.fails(&alice, t, 0, "transfer", &[a(&bob), n(0)], "frozen");
    net.ok(&bank, t, 0, "unfreeze", &[a(&bob)]);
}

#[test]
fn lost_wallet_recovery_and_legal_orders() {
    let mut w = world();
    let t = property(&mut w);
    let (bank, alice, bob) = (w.bank.clone(), w.alice.clone(), w.bob.clone());
    let new_phone = Keypair::from_seed("alice-new-phone");
    w.net.ok(&alice, t, 300 * COIN, "buy", &[n(30)]);
    w.net.ok(&bank, t, 100 * COIN, "distribute", &[]);
    let owed = w.net.ask(t, "claimable", &[a(&alice)])[0];
    // Alice holds every share that has been sold, so all the rent is hers. The 970 unsold shares
    // still with the bank earn nothing.
    assert!(100 * COIN - owed <= 1, "{owed}"); // per-share maths rounds down by at most a unit
    assert_eq!(w.net.ask(t, "claimable", &[a(&bank)])[0], 0);

    // Recovery only works to a wallet the registry says is the same person.
    w.net.fails(
        &bank,
        t,
        0,
        "recover",
        &[a(&alice), a(&bob)],
        "same identity",
    );
    let registry = w.registry;
    w.net.ok(
        &bank,
        registry,
        0,
        "register",
        &[a(&new_phone), n(1), n(840)],
    );
    w.net
        .ok(&bank, t, 0, "recover", &[a(&alice), a(&new_phone)]);
    assert_eq!(
        (w.net.shares(t, &alice), w.net.shares(t, &new_phone)),
        (0, 30)
    );
    assert_eq!(
        w.net.ask(t, "claimable", &[a(&new_phone)])[0],
        owed,
        "unpaid income moves too"
    );

    // A court orders 10 shares moved to Bob.
    let r = w.net.ok(
        &bank,
        t,
        0,
        "force_transfer",
        &[a(&new_phone), a(&bob), n(10)],
    );
    assert_eq!(r.events[0].topic, "ForcedTransfer");
    // Only agents can do that.
    w.net.fails(
        &bob,
        t,
        0,
        "force_transfer",
        &[a(&new_phone), a(&bob), n(1)],
        "only the issuer",
    );
}

#[test]
fn treasury_fund_subscribe_earn_redeem() {
    let mut w = world();
    let (bank, alice, bob) = (w.bank.clone(), w.alice.clone(), w.bob.clone());
    let args = [
        s("EEZE Treasury Bill Fund"),
        s("ETBF"),
        s("fund"),
        Arg::Addr(w.registry),
        n(KYC | AML),
        n(COIN),
        n(1_000_000),
        s("prospectus sha256 51b0aa77"),
    ];
    let f = w.net.deploy(&bank, "security.wasm", &args);
    // Money paid in stays in the fund as a reserve.
    w.net.ok(&alice, f, 5_000 * COIN, "buy", &[n(5_000)]);
    w.net.ok(&bob, f, 1_000 * COIN, "buy", &[n(1_000)]);
    assert_eq!(w.net.ask(f, "info", &[])[11], 6_000 * COIN, "reserve");

    // One "day" of interest at about 4.5% a year on 6,000 CTDY is ~0.74 CTDY, split over the
    // 6,000 shares investors hold. The 994,000 unsold shares earn nothing.
    let daily = 6_000 * COIN * 45 / 1000 / 365;
    w.net.ok(&bank, f, daily, "distribute", &[]);
    let got = w.net.ask(f, "claimable", &[a(&alice)])[0];
    assert!(daily * 5 / 6 - got <= 1, "{got} vs {}", daily * 5 / 6);
    assert_eq!(w.net.ask(f, "claimable", &[a(&bank)])[0], 0);
    // Alice earns 4.5% a year on what she put in, near enough.
    let yearly = got as f64 * 365.0 / (5_000 * COIN) as f64;
    assert!((yearly - 0.045).abs() < 0.0001, "{yearly}");

    // Redeem at the fund price, paid from the reserve.
    let before = w.net.ctdy(&bob);
    let r = w.net.ok(&bob, f, 0, "redeem", &[n(400)]);
    assert_eq!(w.net.ctdy(&bob), before + 400 * COIN - r.fee);
    assert_eq!(w.net.shares(f, &bob), 600);
    // Can't redeem more than the reserve holds.
    w.net.ok(&bank, f, 0, "set_price", &[n(1_000 * COIN)]);
    w.net
        .fails(&alice, f, 0, "redeem", &[n(5_000)], "reserve is too low");
}

#[test]
fn market_pool_prices_trades_like_uniswap() {
    let mut w = world();
    let t = property(&mut w);
    let (bank, alice, bob, dave) = (
        w.bank.clone(),
        w.alice.clone(),
        w.bob.clone(),
        w.dave.clone(),
    );
    // The bank seeds the pool with 400 shares and 4,000 CTDY: 10 CTDY a share.
    let r = w.net.ok(&bank, t, 4_000 * COIN, "add_liquidity", &[n(400)]);
    let units = abi::decode(&r.output.0).unwrap();
    assert_eq!(
        units,
        vec![Arg::U64(
            ((400u128 * 4_000 * COIN as u128) as f64).sqrt() as u64
        )]
    );
    assert_eq!(&w.net.ask(t, "pool", &[])[..2], &[4_000 * COIN, 400]);

    // Constant product with a 0.3% fee.
    let quote =
        |rc: u128, rs: u128, x: u128| (rs * (x * 997 / 1000) / (rc + x * 997 / 1000)) as u64;
    let expect = quote(4_000 * COIN as u128, 400, 500 * COIN as u128);
    assert_eq!(w.net.ask(t, "quote_buy", &[n(500 * COIN)])[0], expect);
    // Asking for more than the pool would give is refused (protection against the price moving).
    w.net.fails(
        &alice,
        t,
        500 * COIN,
        "swap_buy",
        &[n(expect + 1)],
        "price moved",
    );
    let before = w.net.ctdy(&alice);
    let r = w.net.ok(&alice, t, 500 * COIN, "swap_buy", &[n(expect)]);
    let out = abi::decode(&r.output.0).unwrap();
    assert_eq!(out[0], Arg::U64(expect));
    assert_eq!(w.net.shares(t, &alice), expect);
    // Whole shares only: she pays exactly what they cost and gets the change back.
    let Arg::U64(cost) = out[1] else { panic!() };
    assert!(cost <= 500 * COIN && cost > 490 * COIN);
    assert_eq!(w.net.ctdy(&alice), before - cost - r.fee);
    // Buying made shares scarcer in the pool, so the next share costs more.
    let after = w.net.ask(t, "pool", &[]);
    assert!(after[0] as f64 / after[1] as f64 > 10.0 * COIN as f64);

    // People who haven't passed KYC can't trade with the pool either.
    w.net.fails(&dave, t, 10 * COIN, "swap_buy", &[n(0)], "KYC");

    // Selling some back.
    let q = w.net.ask(t, "quote_sell", &[n(10)])[0];
    let before = w.net.ctdy(&alice);
    let r = w.net.ok(&alice, t, 0, "swap_sell", &[n(10), n(q)]);
    assert_eq!(w.net.ctdy(&alice), before + q - r.fee);

    // Rent paid to all holders: the pool's share goes to the pool, so liquidity providers earn it.
    let pool_before = w.net.ask(t, "pool", &[])[0];
    let pool_shares = w.net.ask(t, "pool", &[])[1];
    w.net.ok(&bank, t, 1_000 * COIN, "distribute", &[]);
    w.net.ok(&bob, t, 50 * COIN, "swap_buy", &[n(1)]); // any pool trade books the pool's rent
    let pool_after = w.net.ask(t, "pool", &[])[0];
    assert!(
        pool_after >= pool_before + pool_shares * COIN - 1,
        "pool got its share of rent"
    );

    // The bank takes everything back out.
    let all = w.net.ask(t, "lp_of", &[a(&bank)])[0];
    let r = w.net.ok(&bank, t, 0, "remove_liquidity", &[n(all)]);
    let out = abi::decode(&r.output.0).unwrap();
    assert_eq!(w.net.ask(t, "pool", &[]), vec![0, 0, 0]);
    assert!(
        matches!(out[0], Arg::U64(v) if v > 4_000 * COIN),
        "fees and rent made the pool grow"
    );
}

#[test]
fn a_read_only_call_cannot_change_anything() {
    // A token can only ASK the registry. If the registry tried to write during that call, the call
    // would fail rather than change anything.
    let mut w = world();
    let t = property(&mut w);
    let before = w.net.c.tip_state().contracts[&w.registry].storage.clone();
    let alice = w.alice.clone();
    w.net.ok(&alice, t, 100 * COIN, "buy", &[n(10)]);
    assert_eq!(w.net.c.tip_state().contracts[&w.registry].storage, before);
}
