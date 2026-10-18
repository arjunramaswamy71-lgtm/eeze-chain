//! The real-world-asset contract, run on the chain the way users would.
use eeze_core::abi::{self, Arg};
use eeze_core::state::{build_block, mine, Genesis};
use eeze_core::*;

struct Net {
    c: Chain,
    miner: Keypair,
    nonces: std::collections::HashMap<Address, u64>,
}

impl Net {
    fn new() -> Net {
        let mut g = Genesis::devnet();
        g.initial_bits = 2;
        Net { c: Chain::new(g), miner: Keypair::from_seed("miner"), nonces: Default::default() }
    }
    fn send(&mut self, who: &Keypair, kind: TxKind) -> Receipt {
        let n = self.nonces.entry(who.address()).or_insert(0);
        let tx = Tx::new_signed(&self.c.genesis.chain_id, who, *n, 3_000_000, 1, kind);
        *n += 1;
        let parent = self.c.tip_block().header.clone();
        let ps = self.c.tip_state();
        let g = self.c.genesis.clone();
        let (mut b, _, _) = build_block(&g, &parent, &ps, self.miner.public(), parent.time + 2_000, 0, &[tx.clone()]);
        assert!(mine(&mut b.header, &|| false));
        self.c.add_block(b).unwrap();
        self.c.find_tx(&tx.hash()).expect("tx went in").2
    }
    fn call(&mut self, who: &Keypair, contract: Address, value: u64, method: &str, args: &[Arg]) -> Receipt {
        self.send(who, TxKind::Call { contract, amount: value, args: Bytes(abi::call(method, args)) })
    }
    fn ask(&self, contract: Address, method: &str, args: &[Arg]) -> Vec<Arg> {
        let out = self.c.tip_state().query(&contract, abi::call(method, args), Address::default(), 5_000_000).unwrap();
        abi::decode(&out).unwrap()
    }
    fn shares(&self, contract: Address, who: &Keypair) -> u64 {
        match self.ask(contract, "balance_of", &[Arg::Addr(who.address())])[0] {
            Arg::U64(v) => v,
            _ => panic!(),
        }
    }
    fn balance(&self, who: &Keypair) -> u64 {
        self.c.tip_state().account(&who.address()).balance
    }
}

#[test]
fn tokenized_building_end_to_end() {
    let code = std::fs::read("../contracts/build/rwa.wasm").expect("build the contract first: npm run build in contracts/");
    let mut n = Net::new();
    let bank = Keypair::from_seed("bank");
    let alice = Keypair::from_seed("alice");
    let bob = Keypair::from_seed("bob");
    let eve = Keypair::from_seed("eve");

    // The bank tokenizes a building into 1,000 shares at 10 CTDY each.
    let init = abi::encode(&[
        Arg::Str("Blacksburg Main St Building".into()),
        Arg::Str("BMSB".into()),
        Arg::U64(1_000),
        Arg::U64(10 * COIN),
        Arg::Str("deed sha256: 9f2c...e1".into()),
    ]);
    let r = n.send(&bank, TxKind::Deploy { code: Bytes(code), args: Bytes(init) });
    assert!(r.ok, "{:?}", r.error);
    let asset = r.contract.unwrap();
    println!("deploy gas: {}", r.gas_used);
    let info = n.ask(asset, "info", &[]);
    assert_eq!(info[0], Arg::Str("Blacksburg Main St Building".into()));
    assert_eq!(info[2], Arg::U64(1_000));

    // Alice can't buy before KYC.
    let r = n.call(&alice, asset, 100 * COIN, "buy", &[Arg::U64(10)]);
    assert!(!r.ok && r.error.as_ref().unwrap().contains("KYC"), "{:?}", r.error);
    // Only the bank can approve people.
    let r = n.call(&alice, asset, 0, "approve", &[Arg::Addr(alice.address())]);
    assert!(r.error.unwrap().contains("only the issuer"));

    n.call(&bank, asset, 0, "approve", &[Arg::Addr(alice.address())]);
    n.call(&bank, asset, 0, "approve", &[Arg::Addr(bob.address())]);

    // Wrong payment is refused, exact payment works and the CTDY goes to the bank.
    assert!(!n.call(&alice, asset, 99 * COIN, "buy", &[Arg::U64(10)]).ok);
    let bank_before = n.balance(&bank);
    let r = n.call(&alice, asset, 3_000 * COIN, "buy", &[Arg::U64(300)]);
    assert!(r.ok, "{:?}", r.error);
    println!("buy gas: {}", r.gas_used);
    assert_eq!(n.shares(asset, &alice), 300);
    assert_eq!(n.shares(asset, &bank), 700);
    assert_eq!(n.balance(&bank), bank_before + 3_000 * COIN);

    // Alice sells 100 to Bob. Eve (no KYC) can't receive.
    assert!(n.call(&alice, asset, 0, "transfer", &[Arg::Addr(bob.address()), Arg::U64(100)]).ok);
    let r = n.call(&alice, asset, 0, "transfer", &[Arg::Addr(eve.address()), Arg::U64(1)]);
    assert!(r.error.unwrap().contains("receiver hasn't passed KYC"));
    assert!(!n.call(&alice, asset, 0, "transfer", &[Arg::Addr(bob.address()), Arg::U64(1_000)]).ok);

    // Rent comes in: 1,000 CTDY split by shares. Bank 700, Alice 200, Bob 100.
    assert!(n.call(&bank, asset, 1_000 * COIN, "distribute", &[]).ok);
    let claimable = |n: &Net, k: &Keypair| match n.ask(asset, "claimable", &[Arg::Addr(k.address())])[0] {
        Arg::U64(v) => v,
        _ => panic!(),
    };
    assert_eq!(claimable(&n, &alice), 200 * COIN);
    assert_eq!(claimable(&n, &bob), 100 * COIN);
    assert_eq!(claimable(&n, &bank), 700 * COIN);

    // Bob sells half his shares AFTER the rent. The rent he earned stays his.
    n.call(&bob, asset, 0, "transfer", &[Arg::Addr(alice.address()), Arg::U64(50)]);
    assert_eq!(claimable(&n, &bob), 100 * COIN);
    assert_eq!(claimable(&n, &alice), 200 * COIN);

    // More rent: 500 CTDY. Now Alice has 250 shares, Bob 50.
    n.call(&bank, asset, 500 * COIN, "distribute", &[]);
    assert_eq!(claimable(&n, &alice), 200 * COIN + 125 * COIN);
    assert_eq!(claimable(&n, &bob), 100 * COIN + 25 * COIN);

    // Claiming pays out CTDY (minus the gas fee) and resets to zero.
    let before = n.balance(&alice);
    let r = n.call(&alice, asset, 0, "claim", &[]);
    assert!(r.ok, "{:?}", r.error);
    assert_eq!(n.balance(&alice), before + 325 * COIN - r.fee);
    assert_eq!(claimable(&n, &alice), 0);
    assert!(!n.call(&alice, asset, 0, "claim", &[]).ok);

    // A court freezes Bob. He can't move shares, and nobody can send him any.
    n.call(&bank, asset, 0, "freeze", &[Arg::Addr(bob.address())]);
    assert!(n.call(&bob, asset, 0, "transfer", &[Arg::Addr(alice.address()), Arg::U64(1)]).error.unwrap().contains("frozen"));
    assert!(n.call(&alice, asset, 0, "transfer", &[Arg::Addr(bob.address()), Arg::U64(1)]).error.unwrap().contains("frozen"));
    // He can still claim the rent he already earned.
    assert!(n.call(&bob, asset, 0, "claim", &[]).ok);

    // Bob loses his wallet; the issuer moves his shares to Alice by order. Public on the chain.
    let r = n.call(&bank, asset, 0, "force_transfer", &[Arg::Addr(bob.address()), Arg::Addr(alice.address()), Arg::U64(50)]);
    assert!(r.ok && r.events[0].topic == "ForcedTransfer");
    assert_eq!(n.shares(asset, &alice), 300);
    assert_eq!(n.shares(asset, &bob), 0);

    // Share count never changed, and the contract holds exactly the unclaimed rent.
    let total: u64 = [&bank, &alice, &bob].iter().map(|k| n.shares(asset, k)).sum();
    assert_eq!(total, 1_000);
    assert_eq!(n.c.tip_state().account(&asset).balance, claimable(&n, &bank));
    println!("contract holds {} CTDY for the bank to claim", n.c.tip_state().account(&asset).balance / COIN);
}
