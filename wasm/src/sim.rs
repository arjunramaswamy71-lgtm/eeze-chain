//! A small EEZE Chain network that runs entirely in the browser.
//!
//! Every node here is a real `Chain` from the core, the same code the real node runs. Blocks are
//! really mined (real hashes, with a hash budget per node so some miners are "stronger"), staking
//! blocks carry real VRF proofs, and finality comes from real signed votes. Only the network is
//! pretend: messages are passed between nodes with a delay, and can be cut to split the network.

use eeze_core::abi::{self, Arg};
use eeze_core::api::{self, NodeInfo};
use eeze_core::chain::VoteAdded;
use eeze_core::state::{Genesis, build_block, contract_address};
use eeze_core::*;
use serde::Serialize;
use serde_json::{Value, json};
use std::collections::{HashMap, HashSet};

const REGISTRY_WASM: &[u8] = include_bytes!("../../contracts/build/identity.wasm");
const SECURITY_WASM: &[u8] = include_bytes!("../../contracts/build/security.wasm");
const STEP_MS: u64 = 25;
const LATENCY_MS: u64 = 120;

#[derive(Clone)]
#[allow(clippy::large_enum_variant)] // short-lived, boxing buys nothing
enum Msg {
    Block(Block),
    Tx(Tx),
    Vote(Vote),
}

struct Pending {
    at: u64,
    to: usize,
    msg: Msg,
}

pub struct SimNode {
    pub name: String,
    key: Keypair,
    pub chain: Chain,
    /// Hashes tried per second of network time. 0 = not mining.
    pub hashrate: u64,
    pub online: bool,
    pub group: u8,
    pub evil_double_sign: bool,
    pub evil_double_vote: bool,
    signed: HashSet<(u64, u32)>,
    voted: HashSet<u64>,
    last_vote: Option<(u64, Hash)>,
    seen_headers: HashMap<(u64, u32, Address), SignedHeader>,
    reported: HashSet<(u64, u32, Address)>,
    template: Option<(Block, Hash, u64)>,
    hash_carry: u64,
    pub hashes: u64,
}

#[derive(Serialize, Clone)]
pub struct LogLine {
    pub t: u64,
    pub node: String,
    pub kind: String,
    pub text: String,
}

pub struct Sim {
    pub nodes: Vec<SimNode>,
    pub now: u64,
    pub start: u64,
    queue: Vec<Pending>,
    pub split: bool,
    pub log: Vec<LogLine>,
    genesis: Genesis,
    next_activity: u64,
    next_yield: u64,
    alice_bought: bool,
    seed: u64,
    pub attack: Option<Attack>,
    pub fund: Address,
    pub building: Address,
}

#[derive(Serialize, Clone)]
pub struct Attack {
    pub stage: String,
    pub pay_bob: Hash,
    pub secret: Hash,
    pub started_at: u64,
}

fn names() -> Vec<(&'static str, u64, bool)> {
    // name, mining hashrate, validator
    vec![
        ("miner-1", 9_000, false),
        ("miner-2", 9_000, false),
        ("arjun", 0, true),
        ("bank", 0, true),
        ("carol", 0, true),
        ("attacker", 0, false),
    ]
}

fn short(a: &Address) -> String {
    let s = a.to_string();
    format!("{}…{}", &s[..8], &s[s.len() - 4..])
}

impl Sim {
    pub fn new(now: u64) -> Sim {
        let k = Keypair::from_seed;
        let mut g = Genesis::devnet();
        g.chain_id = "eeze-browser-demo".into();
        g.time = now;
        g.target_ms = 1_000;
        g.slot_ms = 1_500;
        g.pos_height = 60;
        g.initial_bits = 11;
        g.unbonding_blocks = 10;
        g.alloc = vec![
            (k("arjun").address(), 1_000_000 * COIN),
            (k("bank").address(), 1_000_000 * COIN),
            (k("alice").address(), 10_000 * COIN),
            (k("bob").address(), 10_000 * COIN),
            (k("carol").address(), 10_000 * COIN),
            (k("eve").address(), 1_000 * COIN),
        ];
        g.stakes = ["arjun", "bank", "carol"]
            .iter()
            .zip([5_000, 15_000, 5_000])
            .map(|(n, s)| (k(n).address(), s * COIN, k(n).vrf().public()))
            .collect();
        let nodes = names()
            .into_iter()
            .map(|(n, hr, _)| SimNode {
                name: n.to_string(),
                key: k(n),
                chain: Chain::new(g.clone()),
                hashrate: hr,
                online: n != "attacker",
                group: 0,
                evil_double_sign: false,
                evil_double_vote: false,
                signed: HashSet::new(),
                voted: HashSet::new(),
                last_vote: None,
                seen_headers: HashMap::new(),
                reported: HashSet::new(),
                template: None,
                hash_carry: 0,
                hashes: 0,
            })
            .collect();
        let bank = k("bank");
        let fund = contract_address(&bank.address(), 5);
        let building = contract_address(&bank.address(), 6);
        let mut sim = Sim {
            nodes,
            now,
            start: now,
            queue: Vec::new(),
            split: false,
            log: Vec::new(),
            genesis: g,
            next_activity: now + 4_000,
            next_yield: now + 15_000,
            alice_bought: false,
            seed: 0x9E37_79B9_7F4A_7C15,
            attack: None,
            fund,
            building,
        };
        sim.setup_assets();
        sim.say(
            "network",
            "info",
            "Six nodes started: two miners, three validators-to-be, and one that's switched off.",
        );
        sim
    }

    fn rand(&mut self) -> u64 {
        self.seed ^= self.seed << 13;
        self.seed ^= self.seed >> 7;
        self.seed ^= self.seed << 17;
        self.seed
    }

    fn say(&mut self, node: &str, kind: &str, text: impl Into<String>) {
        self.log.push(LogLine {
            t: self.now,
            node: node.into(),
            kind: kind.into(),
            text: text.into(),
        });
        if self.log.len() > 300 {
            self.log.remove(0);
        }
    }

    /// The bank sets up an identity registry, a T-bill fund and a tokenized building, and checks
    /// Alice's ID, so visitors can use the asset pages straight away.
    fn setup_assets(&mut self) {
        let bank = Keypair::from_seed("bank");
        let alice = Keypair::from_seed("alice").address();
        let registry = contract_address(&bank.address(), 0);
        let id = self.genesis.chain_id.clone();
        let c = |m: &str, a: &[Arg]| Bytes(abi::call(m, a));
        let sec = |name: &str, sym: &str, kind: &str, price: u64, total: u64, doc: &str| {
            Bytes(abi::encode(&[
                Arg::Str(name.into()),
                Arg::Str(sym.into()),
                Arg::Str(kind.into()),
                Arg::Addr(registry),
                Arg::U64(5),
                Arg::U64(price),
                Arg::U64(total),
                Arg::Str(doc.into()),
            ]))
        };
        let kinds = vec![
            (
                8_000_000,
                TxKind::Deploy {
                    code: Bytes(REGISTRY_WASM.to_vec()),
                    args: Bytes(vec![]),
                },
            ),
            (
                300_000,
                TxKind::Call {
                    contract: registry,
                    amount: 0,
                    args: c("add_issuer", &[Arg::Addr(bank.address()), Arg::U64(5)]),
                },
            ),
            (
                300_000,
                TxKind::Call {
                    contract: registry,
                    amount: 0,
                    args: c("register", &[Arg::Addr(alice), Arg::U64(1), Arg::U64(840)]),
                },
            ),
            (
                300_000,
                TxKind::Call {
                    contract: registry,
                    amount: 0,
                    args: c("add_claim", &[Arg::U64(1), Arg::U64(1), Arg::U64(0)]),
                },
            ),
            (
                300_000,
                TxKind::Call {
                    contract: registry,
                    amount: 0,
                    args: c("add_claim", &[Arg::U64(1), Arg::U64(4), Arg::U64(0)]),
                },
            ),
            (
                9_000_000,
                TxKind::Deploy {
                    code: Bytes(SECURITY_WASM.to_vec()),
                    args: sec(
                        "EEZE Treasury Bill Fund",
                        "ETBF",
                        "fund",
                        COIN,
                        1_000_000,
                        "prospectus sha256 51b0aa77",
                    ),
                },
            ),
            (
                9_000_000,
                TxKind::Deploy {
                    code: Bytes(SECURITY_WASM.to_vec()),
                    args: sec(
                        "Main St Building",
                        "MSB",
                        "property",
                        10 * COIN,
                        1_000,
                        "deed sha256 9f2c41e1",
                    ),
                },
            ),
            (
                3_000_000,
                TxKind::Call {
                    contract: contract_address(&bank.address(), 6),
                    amount: 2_000 * COIN,
                    args: c("add_liquidity", &[Arg::U64(200)]),
                },
            ),
        ];
        for (nonce, (gas, kind)) in kinds.into_iter().enumerate() {
            let tx = Tx::new_signed(&id, &bank, nonce as u64, gas, 1, kind);
            for n in &mut self.nodes {
                let _ = n.chain.submit_tx(tx.clone());
            }
        }
    }

    // ---------------------------------------------------------------- network

    /// Group 9 is the hidden attacker, who talks to nobody. Otherwise everyone talks, unless the
    /// network is split, when each half only hears itself.
    fn can_talk(&self, a: usize, b: usize) -> bool {
        let (x, y) = (&self.nodes[a], &self.nodes[b]);
        if !x.online || !y.online {
            return false;
        }
        if x.group == 9 || y.group == 9 {
            return x.group == y.group;
        }
        !self.split || x.group == y.group
    }

    fn broadcast(&mut self, from: usize, msg: Msg) {
        for to in 0..self.nodes.len() {
            if to != from && self.can_talk(from, to) {
                let jitter = self.rand() % 80;
                self.queue.push(Pending {
                    at: self.now + LATENCY_MS + jitter,
                    to,
                    msg: msg.clone(),
                });
            }
        }
    }

    /// When nodes can talk again, they catch each other up on blocks they missed.
    fn resync(&mut self) {
        for i in 0..self.nodes.len() {
            for j in 0..self.nodes.len() {
                if i == j || !self.can_talk(i, j) {
                    continue;
                }
                let missing: Vec<Block> = {
                    let (a, b) = (&self.nodes[i].chain, &self.nodes[j].chain);
                    b.best
                        .iter()
                        .filter(|h| !a.blocks.contains_key(h))
                        .map(|h| b.blocks[h].block.clone())
                        .collect()
                };
                for (k, b) in missing.into_iter().enumerate() {
                    self.queue.push(Pending {
                        at: self.now + LATENCY_MS + k as u64,
                        to: i,
                        msg: Msg::Block(b),
                    });
                }
            }
        }
    }

    fn deliver(&mut self, to: usize, msg: Msg) {
        match msg {
            Msg::Block(b) => self.on_block(to, b, false),
            // The sender already passed it to everyone it can reach.
            Msg::Tx(t) => {
                let _ = self.nodes[to].chain.submit_tx(t);
            }
            Msg::Vote(v) => self.on_vote(to, v),
        }
    }

    fn on_block(&mut self, i: usize, b: Block, ours: bool) {
        self.watch_double_sign(i, &b);
        let height = b.header.height;
        let res = self.nodes[i].chain.add_block(b.clone());
        match res {
            Ok(Added::NewTip { reorg_depth }) => {
                let name = self.nodes[i].name.clone();
                if reorg_depth > 0 {
                    self.say(
                        &name,
                        "reorg",
                        format!("switched to a heavier chain, dropping {reorg_depth} block(s)"),
                    );
                }
                if ours {
                    let kind = if b.header.bits > 0 { "mined" } else { "staked" };
                    let fin = b
                        .commit
                        .as_ref()
                        .map(|c| format!(" and makes #{} final", c.height))
                        .unwrap_or_default();
                    let tx = if b.txs.is_empty() {
                        String::new()
                    } else {
                        format!(" with {} tx", b.txs.len())
                    };
                    let try_ = if b.header.round > 0 {
                        format!(" (try {}, someone missed their turn)", b.header.round + 1)
                    } else {
                        String::new()
                    };
                    self.say(&name, kind, format!("{kind} #{height}{tx}{try_}{fin}"));
                }
                // Pass it on, like real nodes gossip. Seeing every block is how nodes spot a
                // validator who signed two.
                self.broadcast(i, Msg::Block(b));
                self.maybe_vote(i);
            }
            Ok(Added::SideChain) => self.broadcast(i, Msg::Block(b)),
            Ok(_) => {}
            Err(e) => {
                let name = self.nodes[i].name.clone();
                self.say(&name, "reject", format!("rejected #{height}: {e}"));
            }
        }
    }

    fn submit(&mut self, i: usize, tx: Tx) -> Result<Hash, String> {
        let h = self.nodes[i].chain.submit_tx(tx.clone())?;
        self.broadcast(i, Msg::Tx(tx));
        Ok(h)
    }

    fn next_nonce(&self, i: usize, who: &Address) -> u64 {
        let c = &self.nodes[i].chain;
        let pending = c
            .mempool
            .values()
            .filter(|t| t.sender() == *who)
            .map(|t| t.nonce + 1)
            .max()
            .unwrap_or(0);
        c.tip_state().account(who).nonce.max(pending)
    }

    fn submit_own(&mut self, i: usize, kind: TxKind) {
        let key = self.nodes[i].key.clone();
        let nonce = self.next_nonce(i, &key.address());
        let tx = Tx::new_signed(&self.genesis.chain_id, &key, nonce, 21_000, 1, kind);
        let _ = self.submit(i, tx);
    }

    // ---------------------------------------------------------------- consensus duties

    fn maybe_vote(&mut self, i: usize) {
        let n = &self.nodes[i];
        let me = n.key.address();
        let tip = n.chain.tip_block().clone();
        let s = n.chain.tip_state();
        let acc = s.account(&me);
        if tip.header.bits > 0
            || tip.header.height == 0
            || acc.stake < self.genesis.min_stake
            || acc.vrf_key.is_none()
        {
            return;
        }
        let h = tip.header.height;
        if n.voted.contains(&h) {
            return;
        }
        // One vote per height, always moving forward, always for the best chain this node follows
        // (which never drops a final block). After a split heals, validators who voted on the
        // losing side switch to the winning side, so finality can carry on.
        if let Some((lh, _)) = n.last_vote
            && lh >= h
        {
            return;
        }
        let vote = Vote::new(&self.genesis.chain_id, &n.key, h, tip.hash());
        let evil = n.evil_double_vote;
        let n = &mut self.nodes[i];
        n.voted.insert(h);
        n.last_vote = Some((h, vote.block));
        let _ = n.chain.add_vote(vote.clone());
        self.broadcast(i, Msg::Vote(vote));
        if evil {
            // Vote for a second, different block at the same height and send it out too.
            let fake = hash_with("EEZE-DEMO-FAKE", &h.to_le_bytes());
            let other = Vote::new(&self.genesis.chain_id, &self.nodes[i].key, h, fake);
            self.nodes[i].evil_double_vote = false;
            let name = self.nodes[i].name.clone();
            self.say(
                &name,
                "evil",
                format!("votes for two different blocks at #{h}"),
            );
            self.broadcast(i, Msg::Vote(other));
        }
    }

    fn on_vote(&mut self, i: usize, v: Vote) {
        if let Ok(VoteAdded::DoubleVote(a, b)) = self.nodes[i].chain.add_vote(v) {
            let who = a.voter.address();
            if self.nodes[i].reported.insert((a.height, u32::MAX, who)) {
                let name = self.nodes[i].name.clone();
                self.say(
                    &name,
                    "caught",
                    format!(
                        "caught {} voting twice at #{}, reporting it",
                        self.who(&who),
                        a.height
                    ),
                );
                self.submit_own(i, TxKind::VoteEvidence { a, b });
            }
        }
    }

    fn watch_double_sign(&mut self, i: usize, b: &Block) {
        let Some(sig) = b.sig else { return };
        let sh = SignedHeader {
            header: b.header.clone(),
            sig,
        };
        let k = (
            sh.header.height,
            sh.header.round,
            sh.header.producer.address(),
        );
        let n = &mut self.nodes[i];
        let earlier = match n.seen_headers.get(&k) {
            Some(prev) if prev.header.hash() != sh.header.hash() => Some(prev.clone()),
            Some(_) => None,
            None => {
                n.seen_headers.insert(k, sh.clone());
                None
            }
        };
        if let Some(prev) = earlier
            && n.reported.insert(k)
            && sh.verify()
        {
            let name = n.name.clone();
            self.say(
                &name,
                "caught",
                format!(
                    "caught {} signing two blocks at #{}, reporting it",
                    self.who(&k.2),
                    k.0
                ),
            );
            self.submit_own(i, TxKind::Evidence { a: prev, b: sh });
        }
    }

    fn who(&self, a: &Address) -> String {
        self.nodes
            .iter()
            .find(|n| n.key.address() == *a)
            .map(|n| n.name.clone())
            .unwrap_or_else(|| short(a))
    }

    fn mine(&mut self, i: usize, dt: u64) {
        let g = self.genesis.clone();
        let now = self.now;
        let n = &mut self.nodes[i];
        if n.hashrate == 0 || !n.online {
            return;
        }
        let parent = n.chain.tip_block().header.clone();
        let ps = n.chain.tip_state();
        if ps.is_pos(&g, parent.height + 1) {
            return;
        }
        let stale = match &n.template {
            Some((_, tip, built)) => *tip != n.chain.tip || now - built > 2_000,
            None => true,
        };
        if stale {
            let pending = n.chain.pending();
            let (b, _, _) = build_block(&g, &parent, &ps, &n.key, now, 0, &pending, None);
            n.template = Some((b, n.chain.tip, now));
        }
        let budget = n.hashrate * dt + n.hash_carry;
        n.hash_carry = budget % 1000;
        let tries = budget / 1000;
        let (block, _, _) = n.template.as_mut().unwrap();
        let mut found = false;
        for _ in 0..tries {
            block.header.nonce = block.header.nonce.wrapping_add(1);
            if leading_zero_bits(&block.header.hash()) >= block.header.bits {
                found = true;
                break;
            }
        }
        n.hashes += tries;
        if found {
            let b = n.template.take().unwrap().0;
            self.on_block(i, b, true);
        }
    }

    fn stake(&mut self, i: usize) {
        let g = self.genesis.clone();
        let now = self.now;
        let n = &self.nodes[i];
        if !n.online {
            return;
        }
        let me = n.key.address();
        let parent = n.chain.tip_block().header.clone();
        let ps = n.chain.tip_state();
        let h = parent.height + 1;
        if !ps.is_pos(&g, h) {
            return;
        }
        let mut round = 0u32;
        while parent.time + g.target_ms + round as u64 * g.slot_ms <= now && round < 1_000 {
            if ps.proposer(&g, h, round) == Some(me) {
                if !self.nodes[i].signed.insert((h, round)) {
                    return;
                }
                let n = &self.nodes[i];
                let pending = n.chain.pending();
                let commit = n.chain.best_commit();
                let key = n.key.clone();
                let (b, _, _) = build_block(&g, &parent, &ps, &key, now, round, &pending, commit);
                if self.nodes[i].evil_double_sign {
                    self.nodes[i].evil_double_sign = false;
                    let (b2, _, _) = build_block(&g, &parent, &ps, &key, now + 1, round, &[], None);
                    let name = self.nodes[i].name.clone();
                    self.say(&name, "evil", format!("signs two different blocks for #{h} and shows each half of the network a different one"));
                    let peers: Vec<usize> = (0..self.nodes.len())
                        .filter(|&j| j != i && self.can_talk(i, j))
                        .collect();
                    for (k, j) in peers.into_iter().enumerate() {
                        let blk = if k % 2 == 0 { b.clone() } else { b2.clone() };
                        self.queue.push(Pending {
                            at: now + LATENCY_MS,
                            to: j,
                            msg: Msg::Block(blk),
                        });
                    }
                    let _ = self.nodes[i].chain.add_block(b);
                } else {
                    self.on_block(i, b, true);
                }
                return;
            }
            round += 1;
        }
    }

    /// Some everyday activity, so there's always something happening: small payments, and the
    /// fund paying a "day" of interest every so often.
    fn activity(&mut self) {
        // Once the bank's setup is on the chain, Alice (who passed KYC) invests, so the asset
        // pages have a holder and her demo wallet earns interest.
        if !self.alice_bought && self.now > self.start + 9_000 {
            let i = self
                .nodes
                .iter()
                .position(|n| n.online && n.group == 0)
                .unwrap_or(0);
            let s = self.nodes[i].chain.tip_state();
            if s.contracts.contains_key(&self.building)
                && s.account(&Keypair::from_seed("bank").address()).nonce >= 8
            {
                self.alice_bought = true;
                let alice = Keypair::from_seed("alice");
                let n0 = self.next_nonce(i, &alice.address());
                let id = self.genesis.chain_id.clone();
                let buy_fund = Tx::new_signed(
                    &id,
                    &alice,
                    n0,
                    4_000_000,
                    1,
                    TxKind::Call {
                        contract: self.fund,
                        amount: 2_000 * COIN,
                        args: Bytes(abi::call("buy", &[Arg::U64(2_000)])),
                    },
                );
                let buy_bldg = Tx::new_signed(
                    &id,
                    &alice,
                    n0 + 1,
                    4_000_000,
                    1,
                    TxKind::Call {
                        contract: self.building,
                        amount: 300 * COIN,
                        args: Bytes(abi::call("buy", &[Arg::U64(30)])),
                    },
                );
                let _ = self.submit(i, buy_fund);
                let _ = self.submit(i, buy_bldg);
                self.say(
                    "alice",
                    "info",
                    "invests 2,000 CTDY in the T-bill fund and buys 30 shares of the building",
                );
            }
        }
        if self.now >= self.next_activity {
            self.next_activity = self.now + 2_500 + self.rand() % 3_000;
            let people = ["arjun", "alice", "bob", "carol"];
            let a = people[(self.rand() % 4) as usize];
            let b = people[(self.rand() % 4) as usize];
            if a != b {
                let amount = (1 + self.rand() % 40) * COIN / 4;
                let key = Keypair::from_seed(a);
                let i = self
                    .nodes
                    .iter()
                    .position(|n| n.online && n.group == 0)
                    .unwrap_or(0);
                let nonce = self.next_nonce(i, &key.address());
                let tx = Tx::new_signed(
                    &self.genesis.chain_id,
                    &key,
                    nonce,
                    21_000,
                    1,
                    TxKind::Transfer {
                        to: Keypair::from_seed(b).address(),
                        amount,
                    },
                );
                let _ = self.submit(i, tx);
            }
        }
        if self.now >= self.next_yield {
            self.next_yield = self.now + 20_000;
            let bank = Keypair::from_seed("bank");
            let i = self
                .nodes
                .iter()
                .position(|n| n.online && n.group == 0)
                .unwrap_or(0);
            // A day of interest at 4.5% a year on the money investors have in the fund (its
            // reserve), shared out over the shares they hold.
            let reserve = self.nodes[i]
                .chain
                .tip_state()
                .query(
                    &self.fund,
                    abi::call("info", &[]),
                    bank.address(),
                    10_000_000,
                )
                .ok()
                .and_then(|out| abi::decode(&out).ok())
                .and_then(|v| match v.get(11) {
                    Some(Arg::U64(r)) => Some(*r),
                    _ => None,
                })
                .unwrap_or(0);
            if reserve > 0 {
                let nonce = self.next_nonce(i, &bank.address());
                let daily = reserve * 45 / 1000 / 365;
                let tx = Tx::new_signed(
                    &self.genesis.chain_id,
                    &bank,
                    nonce,
                    3_000_000,
                    1,
                    TxKind::Call {
                        contract: self.fund,
                        amount: daily,
                        args: Bytes(abi::call("distribute", &[])),
                    },
                );
                let _ = self.submit(i, tx);
            }
        }
    }

    pub fn tick(&mut self, ms: u64) {
        let end = self.now + ms.min(5_000);
        while self.now < end {
            let dt = STEP_MS.min(end - self.now);
            self.now += dt;
            self.queue.sort_by_key(|p| p.at);
            while let Some(p) = self.queue.first() {
                if p.at > self.now {
                    break;
                }
                let p = self.queue.remove(0);
                if self.nodes[p.to].online {
                    self.deliver(p.to, p.msg);
                }
            }
            for i in 0..self.nodes.len() {
                self.mine(i, dt);
                self.stake(i);
            }
            self.activity();
            self.check_attack();
        }
    }

    // ---------------------------------------------------------------- controls

    pub fn control(&mut self, action: &str, arg: &Value) -> Result<Value, String> {
        match action {
            "attack" => self.start_attack(),
            "release" => self.release_attack(),
            "double_sign" | "double_vote" => {
                let i = self.idx(arg["node"].as_str().unwrap_or("carol"))?;
                if self.nodes[i]
                    .chain
                    .tip_state()
                    .account(&self.nodes[i].key.address())
                    .stake
                    < self.genesis.min_stake
                {
                    return Err(
                        "that validator doesn't have enough stake left to cheat with".into(),
                    );
                }
                if action == "double_sign" {
                    self.nodes[i].evil_double_sign = true;
                    let name = self.nodes[i].name.clone();
                    self.say(&name, "evil", "will sign two blocks on its next turn");
                } else {
                    self.nodes[i].evil_double_vote = true;
                }
                Ok(json!({ "ok": true }))
            }
            "split" => {
                self.split = !self.split;
                if self.split {
                    for (k, n) in self.nodes.iter_mut().enumerate() {
                        if n.group != 9 {
                            n.group = (k % 2) as u8;
                        }
                    }
                    self.say(
                        "network",
                        "split",
                        "network split in two: each half can only see itself",
                    );
                } else {
                    for n in self.nodes.iter_mut() {
                        if n.group != 9 {
                            n.group = 0;
                        }
                    }
                    self.say(
                        "network",
                        "split",
                        "network joined back together; nodes catch each other up",
                    );
                    self.resync();
                }
                Ok(json!({ "split": self.split }))
            }
            "toggle" => {
                let i = self.idx(arg["node"].as_str().unwrap_or(""))?;
                if self.nodes[i].group == 9 {
                    return Err("that node is busy attacking".into());
                }
                self.nodes[i].online = !self.nodes[i].online;
                let (name, on) = (self.nodes[i].name.clone(), self.nodes[i].online);
                self.say(
                    &name,
                    "info",
                    if on { "back online" } else { "went offline" },
                );
                if on {
                    self.resync();
                }
                Ok(json!({ "online": on }))
            }
            _ => Err(format!("unknown action {action}")),
        }
    }

    fn idx(&self, name: &str) -> Result<usize, String> {
        self.nodes
            .iter()
            .position(|n| n.name == name)
            .ok_or(format!("no node called {name}"))
    }

    /// Eve pays Bob on the real network, while a hidden attacker with 3x the mining power builds
    /// a different history where the same coins go to Eve's other wallet.
    fn start_attack(&mut self) -> Result<Value, String> {
        if self.attack.is_some() {
            return Err("an attack is already running".into());
        }
        let a = self.idx("attacker")?;
        let pub_node = self.idx("miner-1")?;
        let s = self.nodes[pub_node].chain.tip_state();
        if s.is_pos(&self.genesis, self.nodes[pub_node].chain.height() + 1) {
            return Err("mining is over: this chain runs on staking now, and final blocks can't be rewritten by hash power. Reload the page to try the attack from the start.".into());
        }
        // The attacker starts from the same chain everyone has.
        let blocks: Vec<Block> = {
            let c = &self.nodes[pub_node].chain;
            c.best
                .iter()
                .skip(1)
                .map(|h| c.blocks[h].block.clone())
                .collect()
        };
        for b in blocks {
            let _ = self.nodes[a].chain.add_block(b);
        }
        let honest: u64 = self
            .nodes
            .iter()
            .filter(|n| n.online)
            .map(|n| n.hashrate)
            .sum();
        self.nodes[a].online = true;
        self.nodes[a].group = 9;
        self.nodes[a].hashrate = honest * 3;
        let eve = Keypair::from_seed("eve");
        let nonce = s.account(&eve.address()).nonce;
        let id = self.genesis.chain_id.clone();
        let pay = Tx::new_signed(
            &id,
            &eve,
            nonce,
            21_000,
            1,
            TxKind::Transfer {
                to: Keypair::from_seed("bob").address(),
                amount: 900 * COIN,
            },
        );
        let secret = Tx::new_signed(
            &id,
            &eve,
            nonce,
            21_000,
            1,
            TxKind::Transfer {
                to: Keypair::from_seed("eve-2").address(),
                amount: 900 * COIN,
            },
        );
        let (ph, sh) = (pay.hash(), secret.hash());
        self.submit(pub_node, pay)?;
        self.nodes[a].chain.submit_tx(secret)?;
        self.say(
            "attacker",
            "evil",
            "goes dark with 3x everyone else's mining power, building a secret chain",
        );
        self.say(
            "eve",
            "evil",
            "pays Bob 900 CTDY in public, and the same 900 to herself on the secret chain",
        );
        self.attack = Some(Attack {
            stage: "hidden".into(),
            pay_bob: ph,
            secret: sh,
            started_at: self.now,
        });
        Ok(json!({ "ok": true }))
    }

    fn release_attack(&mut self) -> Result<Value, String> {
        let Some(at) = self.attack.as_mut() else {
            return Err("no attack running".into());
        };
        if at.stage != "hidden" {
            return Err("the attacker already revealed its chain".into());
        }
        at.stage = "released".into();
        let a = self.idx("attacker")?;
        self.nodes[a].group = 0;
        self.nodes[a].hashrate = 0;
        self.say("attacker", "evil", "reveals its secret chain to everyone");
        self.resync();
        Ok(json!({ "ok": true }))
    }

    fn check_attack(&mut self) {
        let Some(at) = self.attack.clone() else {
            return;
        };
        if at.stage == "hidden" && self.now - at.started_at > 25_000 {
            let _ = self.release_attack();
        }
        if at.stage == "released" {
            let bob = &self.nodes[self.idx("miner-1").unwrap()].chain;
            if bob.find_tx(&at.secret).is_some() && bob.find_tx(&at.pay_bob).is_none() {
                self.attack.as_mut().unwrap().stage = "worked".into();
                self.say(
                    "bob",
                    "reorg",
                    "Bob's 900 CTDY payment has vanished from history. The double spend worked.",
                );
            } else if self.now - at.started_at > 60_000 {
                self.attack.as_mut().unwrap().stage = "failed".into();
                self.say("network", "info", "the honest chain held this time");
            }
        }
    }

    // ---------------------------------------------------------------- reading

    pub fn api(
        &mut self,
        node: usize,
        method: &str,
        path: &str,
        query: &str,
        body: &[u8],
    ) -> Result<Value, (u16, String)> {
        let node = node.min(self.nodes.len() - 1);
        if method == "POST" && path == "/tx" {
            let tx: Tx = serde_json::from_slice(body).map_err(|e| (400, e.to_string()))?;
            let h = self.submit(node, tx).map_err(|e| (400, e))?;
            return Ok(json!({ "hash": h }));
        }
        let peers: Vec<Value> = (0..self.nodes.len())
            .filter(|&j| j != node && self.can_talk(node, j))
            .map(|j| json!({ "addr": self.nodes[j].name, "height": self.nodes[j].chain.height(), "key": "" }))
            .collect();
        let info = NodeInfo {
            name: self.nodes[node].name.clone(),
            now: self.now,
            peers,
            network_key: "in-browser".into(),
        };
        api::handle(&self.nodes[node].chain, &info, method, path, query, body)
    }

    pub fn overview(&self) -> Value {
        let nodes: Vec<Value> = self
            .nodes
            .iter()
            .map(|n| {
                let s = n.chain.tip_state();
                let acc = s.account(&n.key.address());
                json!({
                    "name": n.name,
                    "online": n.online,
                    "group": n.group,
                    "height": n.chain.height(),
                    "tip": n.chain.tip,
                    "final": n.chain.finalized().0,
                    "hashrate": n.hashrate,
                    "hashes": n.hashes,
                    "stake": acc.stake,
                    "validator": acc.stake >= self.genesis.min_stake && acc.vrf_key.is_some(),
                    "consensus": if s.is_pos(&self.genesis, n.chain.height() + 1) { "stake" } else { "work" },
                    "bits": s.bits,
                })
            })
            .collect();
        json!({
            "now": self.now,
            "started": self.start,
            "split": self.split,
            "pos_height": self.genesis.pos_height,
            "nodes": nodes,
            "log": self.log.iter().rev().take(60).collect::<Vec<_>>(),
            "attack": self.attack,
            "fund": self.fund,
            "building": self.building,
        })
    }
}
