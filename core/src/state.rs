//! The chain's memory: who owns what, who is staking, and every contract's storage.
//! Also the rules for applying a transaction and checking a block.

use crate::types::*;
use crate::vm::{self, CallEnv, Event, Storage};
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, BTreeSet};
use std::sync::Arc;

/// Base gas for any transaction, the same number Ethereum uses.
pub const BASE_GAS: u64 = 21_000;
pub const DEPLOY_GAS_PER_BYTE: u64 = 200;

/// Settings fixed when the chain starts. Every node must use the same ones.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Genesis {
    pub chain_id: String,
    pub time: u64,
    /// Starting CTDY balances.
    pub alloc: Vec<(Address, u64)>,
    /// Starting validator stakes, so staking can begin even if nobody staked during mining.
    pub stakes: Vec<(Address, u64)>,
    /// Starting proof-of-work difficulty, in leading zero bits.
    pub initial_bits: u32,
    /// How often we want a block, in milliseconds.
    pub target_ms: u64,
    /// The block height where mining stops and staking starts.
    pub pos_height: u64,
    /// How long a chosen validator gets before the next one may step in.
    pub slot_ms: u64,
    pub unbonding_blocks: u64,
    pub min_stake: u64,
    pub pow_reward: u64,
    pub pos_reward: u64,
    pub block_gas_limit: u64,
}

impl Genesis {
    /// The local test network, with a few well-known demo wallets.
    pub fn devnet() -> Genesis {
        let w = |s: &str| Keypair::from_seed(s).address();
        Genesis {
            chain_id: "eeze-devnet-1".into(),
            time: 1_760_000_000_000,
            alloc: vec![
                (w("arjun"), 1_000_000 * COIN),
                (w("bank"), 1_000_000 * COIN),
                (w("alice"), 10_000 * COIN),
                (w("bob"), 10_000 * COIN),
            ],
            stakes: vec![],
            initial_bits: 18,
            target_ms: 2_000,
            pos_height: 60,
            slot_ms: 3_000,
            unbonding_blocks: 20,
            min_stake: 1_000 * COIN,
            pow_reward: 50 * COIN,
            pos_reward: 10 * COIN,
            block_gas_limit: 20_000_000,
        }
    }

    pub fn genesis_block(&self) -> (Block, State) {
        let mut s = State { bits: self.initial_bits, ..Default::default() };
        for (a, v) in &self.alloc {
            s.acct(a).balance += v;
            s.supply += v;
        }
        for (a, v) in &self.stakes {
            s.acct(a).stake += v;
            s.supply += v;
        }
        s.recent_times.push(self.time);
        let header = Header {
            height: 0,
            prev: Hash::default(),
            time: self.time,
            tx_root: merkle_root(&[]),
            state_root: s.root(),
            producer: PubKey::default(),
            bits: 0,
            nonce: 0,
            round: 0,
        };
        (Block { header, sig: None, txs: vec![] }, s)
    }
}

#[derive(Clone, Debug, Default, PartialEq, Serialize, Deserialize)]
pub struct Account {
    pub balance: u64,
    pub nonce: u64,
    pub stake: u64,
    /// Stake on its way out: (height it unlocks, amount).
    pub unbonding: Vec<(u64, u64)>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Contract {
    pub code: Arc<Bytes>,
    pub creator: Address,
    pub storage: Storage,
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct State {
    pub height: u64,
    pub accounts: BTreeMap<Address, Account>,
    pub contracts: BTreeMap<Address, Contract>,
    /// Difficulty for the next mined block.
    pub bits: u32,
    /// Times of the last few blocks, used to adjust difficulty.
    pub recent_times: Vec<u64>,
    /// Total CTDY that exists, and how much has been destroyed by slashing.
    pub supply: u64,
    pub burned: u64,
    /// (validator, height, round) already punished, so the same proof can't be used twice.
    pub slashed: BTreeSet<(Address, u64, u32)>,
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct Receipt {
    pub tx: Hash,
    pub ok: bool,
    pub gas_used: u64,
    pub fee: u64,
    pub error: Option<String>,
    pub output: Bytes,
    pub events: Vec<Event>,
    /// Set when a contract was deployed.
    pub contract: Option<Address>,
}

/// Information about the block a transaction is being run in.
#[derive(Clone, Debug)]
pub struct BlockCtx {
    pub height: u64,
    pub time: u64,
    pub producer: Address,
}

#[derive(Debug, thiserror::Error, PartialEq)]
pub enum TxError {
    #[error("bad signature")]
    BadSig,
    #[error("wrong nonce: expected {expected}, got {got}")]
    Nonce { expected: u64, got: u64 },
    #[error("not enough CTDY to pay for this")]
    Funds,
    #[error("gas limit too low, needs at least {0}")]
    GasTooLow(u64),
    #[error("gas price must be at least 1")]
    GasPrice,
    #[error("{0}")]
    Invalid(String),
}

pub fn contract_address(deployer: &Address, nonce: u64) -> Address {
    let mut b = deployer.0.to_vec();
    b.extend_from_slice(&nonce.to_le_bytes());
    let h = hash_with("EEZE-CONTRACT", &b);
    Address(h.0[..20].try_into().unwrap())
}

impl State {
    pub fn acct(&mut self, a: &Address) -> &mut Account {
        self.accounts.entry(*a).or_default()
    }

    pub fn account(&self, a: &Address) -> Account {
        self.accounts.get(a).cloned().unwrap_or_default()
    }

    /// One hash that sums up the whole state. If two nodes agree on this, they agree on everything.
    pub fn root(&self) -> Hash {
        let mut leaves = Vec::new();
        for (a, acc) in &self.accounts {
            let mut e = Enc::default();
            e.raw(&a.0).u64(acc.balance).u64(acc.nonce).u64(acc.stake).u32(acc.unbonding.len() as u32);
            for (h, v) in &acc.unbonding {
                e.u64(*h).u64(*v);
            }
            leaves.push(hash_with("EEZE-ACCT", &e.0));
        }
        for (a, c) in &self.contracts {
            let slots: Vec<Hash> = c
                .storage
                .iter()
                .map(|(k, v)| {
                    let mut e = Enc::default();
                    e.bytes(k).bytes(v);
                    hash_with("EEZE-SLOT", &e.0)
                })
                .collect();
            let mut e = Enc::default();
            e.raw(&a.0)
                .raw(&hash_with("EEZE-CODE", &c.code.0).0)
                .raw(&c.creator.0)
                .raw(&merkle_root(&slots).0);
            leaves.push(hash_with("EEZE-CONTRACT", &e.0));
        }
        let mut e = Enc::default();
        e.u64(self.height).u32(self.bits).u64(self.supply).u64(self.burned);
        for t in &self.recent_times {
            e.u64(*t);
        }
        for (a, h, r) in &self.slashed {
            e.raw(&a.0).u64(*h).u32(*r);
        }
        leaves.push(hash_with("EEZE-META", &e.0));
        merkle_root(&leaves)
    }

    /// Validators who have at least the minimum stake, sorted so every node sees the same list.
    pub fn validators(&self, g: &Genesis) -> Vec<(Address, u64)> {
        self.accounts
            .iter()
            .filter(|(_, a)| a.stake >= g.min_stake)
            .map(|(k, a)| (*k, a.stake))
            .collect()
    }

    /// Picks who makes the next block. More stake means a bigger chance, like more raffle tickets.
    /// The pick comes from the previous block's hash, so nobody can choose it in advance.
    pub fn proposer(&self, g: &Genesis, prev: &Hash, height: u64, round: u32) -> Option<Address> {
        let vals = self.validators(g);
        let total: u128 = vals.iter().map(|v| v.1 as u128).sum();
        if total == 0 {
            return None;
        }
        let mut e = Enc::default();
        e.raw(&prev.0).u64(height).u32(round);
        let seed = hash_with("EEZE-PROPOSER", &e.0);
        let r = u128::from_le_bytes(seed.0[..16].try_into().unwrap()) % total;
        let mut acc = 0u128;
        for (a, s) in &vals {
            acc += *s as u128;
            if r < acc {
                return Some(*a);
            }
        }
        None
    }

    /// Mining until `pos_height`, then staking. If nobody is staking yet, mining carries on.
    pub fn is_pos(&self, g: &Genesis, height: u64) -> bool {
        height >= g.pos_height && !self.validators(g).is_empty()
    }

    fn credit(&mut self, a: &Address, v: u64) {
        let acc = self.acct(a);
        acc.balance = acc.balance.checked_add(v).expect("supply overflow");
    }

    /// Runs one transaction. An `Err` means it can never go in a block (bad signature, wrong nonce,
    /// can't pay). A receipt with `ok: false` means it went in, paid its fee, but did nothing.
    pub fn apply_tx(&mut self, g: &Genesis, ctx: &BlockCtx, tx: &Tx) -> Result<Receipt, TxError> {
        if !tx.verify(&g.chain_id) {
            return Err(TxError::BadSig);
        }
        if tx.gas_price < 1 {
            return Err(TxError::GasPrice);
        }
        let from = tx.sender();
        let acc = self.account(&from);
        if acc.nonce != tx.nonce {
            return Err(TxError::Nonce { expected: acc.nonce, got: tx.nonce });
        }
        let intrinsic = match &tx.kind {
            TxKind::Deploy { code, args } => BASE_GAS + (code.0.len() + args.0.len()) as u64 * DEPLOY_GAS_PER_BYTE,
            TxKind::Call { args, .. } => BASE_GAS + args.0.len() as u64 * vm::GAS_PER_BYTE,
            _ => BASE_GAS,
        };
        if tx.gas_limit < intrinsic {
            return Err(TxError::GasTooLow(intrinsic));
        }
        let max_fee = tx.gas_limit.checked_mul(tx.gas_price).ok_or(TxError::Funds)?;
        let value = match &tx.kind {
            TxKind::Transfer { amount, .. } | TxKind::Stake { amount } | TxKind::Call { amount, .. } => *amount,
            _ => 0,
        };
        if acc.balance < max_fee.checked_add(value).ok_or(TxError::Funds)? {
            return Err(TxError::Funds);
        }
        if let TxKind::Deploy { code, .. } = &tx.kind {
            vm::validate(&code.0).map_err(TxError::Invalid)?;
        }

        // Take the most it could cost up front, give back what isn't used at the end.
        {
            let a = self.acct(&from);
            a.balance -= max_fee;
            a.nonce += 1;
        }

        let mut r = Receipt {
            tx: tx.hash(),
            ok: true,
            gas_used: intrinsic,
            fee: 0,
            error: None,
            output: Bytes::default(),
            events: vec![],
            contract: None,
        };

        match &tx.kind {
            TxKind::Transfer { to, amount } => {
                self.acct(&from).balance -= amount;
                self.credit(to, *amount);
            }
            TxKind::Stake { amount } => {
                let a = self.acct(&from);
                a.balance -= amount;
                a.stake += amount;
            }
            TxKind::Unstake { amount } => {
                let release = ctx.height + g.unbonding_blocks;
                let a = self.acct(&from);
                if a.stake < *amount {
                    r.ok = false;
                    r.error = Some("not that much staked".into());
                } else {
                    a.stake -= amount;
                    a.unbonding.push((release, *amount));
                }
            }
            TxKind::Evidence { a, b } => {
                if let Err(e) = self.slash(g, &from, a, b) {
                    r.ok = false;
                    r.error = Some(e);
                }
            }
            TxKind::Deploy { code, args } => {
                let addr = contract_address(&from, tx.nonce);
                let env = CallEnv { caller: from, this: addr, value: 0, balance: 0, height: ctx.height, time: ctx.time };
                let out = vm::run(&code.0, "init", args.0.clone(), Storage::new(), env, tx.gas_limit - intrinsic);
                r.gas_used += out.gas_used;
                if out.ok {
                    self.contracts.insert(
                        addr,
                        Contract { code: Arc::new(code.clone()), creator: from, storage: out.storage },
                    );
                    self.acct(&addr);
                    r.contract = Some(addr);
                    r.events = out.events;
                    r.output = Bytes(out.output);
                } else {
                    r.ok = false;
                    r.error = out.error;
                }
            }
            TxKind::Call { contract, amount, args } => match self.contracts.get(contract).cloned() {
                None => {
                    r.ok = false;
                    r.error = Some("no contract at that address".into());
                }
                Some(c) => {
                    let balance = self.account(contract).balance + amount;
                    let env = CallEnv { caller: from, this: *contract, value: *amount, balance, height: ctx.height, time: ctx.time };
                    let out = vm::run(&c.code.0, "call", args.0.clone(), c.storage, env, tx.gas_limit - intrinsic);
                    r.gas_used += out.gas_used;
                    if out.ok {
                        // The call worked: move the CTDY, save storage, pay out what the contract sent.
                        self.acct(&from).balance -= amount;
                        self.credit(contract, *amount);
                        for (to, v) in &out.transfers {
                            self.acct(contract).balance -= v;
                            self.credit(to, *v);
                        }
                        self.contracts.get_mut(contract).unwrap().storage = out.storage;
                        r.events = out.events;
                        r.output = Bytes(out.output);
                    } else {
                        // It failed: nothing changes except the fee.
                        r.ok = false;
                        r.error = out.error;
                    }
                }
            },
        }

        r.gas_used = r.gas_used.min(tx.gas_limit);
        r.fee = r.gas_used * tx.gas_price;
        self.acct(&from).balance += max_fee - r.fee;
        self.credit(&ctx.producer, r.fee);
        Ok(r)
    }

    /// Asks a contract something without changing anything (no transaction, no fee).
    pub fn query(&self, contract: &Address, args: Vec<u8>, as_caller: Address, gas: u64) -> Result<Vec<u8>, String> {
        let c = self.contracts.get(contract).ok_or("no contract at that address")?;
        let env = CallEnv {
            caller: as_caller,
            this: *contract,
            value: 0,
            balance: self.account(contract).balance,
            height: self.height,
            time: self.recent_times.last().copied().unwrap_or(0),
        };
        let out = vm::run(&c.code.0, "call", args, c.storage.clone(), env, gas);
        if out.ok { Ok(out.output) } else { Err(out.error.unwrap_or_default()) }
    }

    /// Punishes a validator who signed two different blocks for the same slot.
    /// Half their stake is taken; the reporter gets a tenth of that and the rest is destroyed.
    fn slash(&mut self, g: &Genesis, reporter: &Address, a: &SignedHeader, b: &SignedHeader) -> Result<(), String> {
        let (ha, hb) = (&a.header, &b.header);
        if ha.producer != hb.producer || ha.height != hb.height || ha.round != hb.round {
            return Err("headers are not for the same slot".into());
        }
        if ha.hash() == hb.hash() {
            return Err("headers are the same".into());
        }
        if ha.height < g.pos_height || !a.verify() || !b.verify() {
            return Err("headers are not validly signed staking blocks".into());
        }
        let offender = ha.producer.address();
        if !self.slashed.insert((offender, ha.height, ha.round)) {
            return Err("already punished for this".into());
        }
        let acc = self.acct(&offender);
        let mut taken = acc.stake / 2;
        acc.stake -= acc.stake / 2;
        for u in acc.unbonding.iter_mut() {
            taken += u.1 / 2;
            u.1 -= u.1 / 2;
        }
        let reward = taken / 10;
        self.credit(reporter, reward);
        self.burned += taken - reward;
        self.supply -= taken - reward;
        Ok(())
    }

    /// Unlocks stake whose waiting period is over.
    fn release_unbonding(&mut self, height: u64) {
        for acc in self.accounts.values_mut() {
            if acc.unbonding.iter().any(|u| u.0 <= height) {
                let freed: u64 = acc.unbonding.iter().filter(|u| u.0 <= height).map(|u| u.1).sum();
                acc.unbonding.retain(|u| u.0 > height);
                acc.balance += freed;
            }
        }
    }

    /// Mining difficulty goes up when blocks come too fast and down when they come too slow.
    fn adjust_difficulty(&mut self, g: &Genesis, time: u64) {
        self.recent_times.push(time);
        if self.recent_times.len() > 11 {
            self.recent_times.remove(0);
        }
        if self.height % 10 == 0 && self.recent_times.len() == 11 {
            let took = self.recent_times[10].saturating_sub(self.recent_times[0]);
            let want = 10 * g.target_ms;
            // Each extra zero bit doubles the work, so move by log2 of how far off we are (at most 4).
            let took = took.max(1);
            if took < want / 2 {
                self.bits += (63 - (want / took).leading_zeros()).min(4);
            } else if took > want * 2 {
                let down = (63 - (took / want).leading_zeros()).min(4);
                self.bits = self.bits.saturating_sub(down).max(1);
            }
        }
    }

    /// Everything a block does to the state after its header checks out: unlock stake,
    /// run transactions, pay the producer, adjust difficulty.
    pub fn execute(
        &mut self,
        g: &Genesis,
        header: &Header,
        txs: &[Tx],
        skip_bad: bool,
    ) -> Result<(Vec<Tx>, Vec<Receipt>), String> {
        let ctx = BlockCtx { height: header.height, time: header.time, producer: header.producer.address() };
        let pos = self.is_pos(g, header.height);
        self.height = header.height;
        self.release_unbonding(header.height);
        let mut kept = Vec::new();
        let mut receipts = Vec::new();
        let mut gas = 0u64;
        for tx in txs {
            if gas + tx.gas_limit > g.block_gas_limit {
                if skip_bad {
                    continue;
                }
                return Err("block uses too much gas".into());
            }
            match self.apply_tx(g, &ctx, tx) {
                Ok(r) => {
                    gas += r.gas_used;
                    receipts.push(r);
                    kept.push(tx.clone());
                }
                Err(e) if skip_bad => {
                    let _ = e;
                }
                Err(e) => return Err(format!("tx {} is invalid: {e}", tx.hash())),
            }
        }
        let reward = if pos { g.pos_reward } else { g.pow_reward };
        self.credit(&ctx.producer, reward);
        self.supply += reward;
        if !pos {
            self.adjust_difficulty(g, header.time);
        } else {
            self.recent_times.push(header.time);
            if self.recent_times.len() > 11 {
                self.recent_times.remove(0);
            }
        }
        Ok((kept, receipts))
    }
}

/// Checks a block against its parent and works out the state after it.
/// This is the heart of the chain: every node runs exactly this on every block.
pub fn check_block(g: &Genesis, parent: &Header, parent_state: &State, block: &Block) -> Result<(State, Vec<Receipt>), String> {
    let h = &block.header;
    if h.height != parent.height + 1 {
        return Err("wrong height".into());
    }
    if h.prev != parent.hash() {
        return Err("doesn't point at its parent".into());
    }
    if h.time <= parent.time {
        return Err("time went backwards".into());
    }
    if parent_state.is_pos(g, h.height) {
        // Proof of stake: the right validator must have signed it, and not too early.
        if h.bits != 0 || h.nonce != 0 {
            return Err("staking blocks don't carry mining fields".into());
        }
        let chosen = parent_state
            .proposer(g, &h.prev, h.height, h.round)
            .ok_or("no validators")?;
        if chosen != h.producer.address() {
            return Err(format!("not this validator's turn (round {} belongs to {chosen})", h.round));
        }
        if h.time < parent.time + g.target_ms + h.round as u64 * g.slot_ms {
            return Err("made before its turn started".into());
        }
        match &block.sig {
            Some(s) if h.producer.verify(&h.hash().0, s) => {}
            _ => return Err("validator signature is missing or wrong".into()),
        }
    } else {
        // Proof of work: the hash must start with enough zeros.
        if h.round != 0 || block.sig.is_some() {
            return Err("mined blocks don't carry staking fields".into());
        }
        if h.bits != parent_state.bits {
            return Err(format!("wrong difficulty: need {}, got {}", parent_state.bits, h.bits));
        }
        if leading_zero_bits(&h.hash()) < h.bits {
            return Err("not enough work".into());
        }
    }
    let tx_hashes: Vec<Hash> = block.txs.iter().map(|t| t.hash()).collect();
    if h.tx_root != merkle_root(&tx_hashes) {
        return Err("transaction root doesn't match".into());
    }
    let mut s = parent_state.clone();
    let (_, receipts) = s.execute(g, h, &block.txs, false)?;
    if s.root() != h.state_root {
        return Err("state root doesn't match".into());
    }
    Ok((s, receipts))
}

/// Puts together a new block on top of `parent` from waiting transactions.
/// Bad transactions are left out. Mining or signing happens after.
pub fn build_block(
    g: &Genesis,
    parent: &Header,
    parent_state: &State,
    producer: PubKey,
    time: u64,
    round: u32,
    pending: &[Tx],
) -> (Block, State, Vec<Receipt>) {
    let pos = parent_state.is_pos(g, parent.height + 1);
    let mut header = Header {
        height: parent.height + 1,
        prev: parent.hash(),
        time: time.max(parent.time + 1),
        tx_root: Hash::default(),
        state_root: Hash::default(),
        producer,
        bits: if pos { 0 } else { parent_state.bits },
        nonce: 0,
        round: if pos { round } else { 0 },
    };
    let mut s = parent_state.clone();
    let (kept, receipts) = s.execute(g, &header, pending, true).expect("skip_bad never fails");
    header.tx_root = merkle_root(&kept.iter().map(|t| t.hash()).collect::<Vec<_>>());
    header.state_root = s.root();
    (Block { header, sig: None, txs: kept }, s, receipts)
}

/// Tries nonces until the hash has enough leading zeros. `stop` lets the miner give up
/// when someone else finds a block first.
pub fn mine(header: &mut Header, stop: &dyn Fn() -> bool) -> bool {
    loop {
        for _ in 0..10_000 {
            if leading_zero_bits(&header.hash()) >= header.bits {
                return true;
            }
            header.nonce = header.nonce.wrapping_add(1);
        }
        if stop() {
            return false;
        }
    }
}
