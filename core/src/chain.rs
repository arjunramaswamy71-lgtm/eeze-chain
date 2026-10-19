//! Keeps every block a node has seen, picks the best chain, and holds transactions waiting to go in.

use crate::state::*;
use crate::types::*;
use std::collections::{BTreeMap, HashMap};
use std::sync::Arc;

/// Before staking finality starts (the mining stage), how deep a reorg can go. Once validators
/// have voted a block final, the final block is the limit instead, however far back it is.
pub const FINALITY_DEPTH: u64 = 100;

/// Which chain is "best": the furthest finality first, then the most mining work, then the
/// most staking blocks, then the fewest missed turns.
#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Default)]
pub struct Score {
    pub finalized: u64,
    pub work: u128,
    pub pos_blocks: u64,
    pub on_time: i64,
}

pub struct Stored {
    pub block: Block,
    pub score: Score,
    pub state: Option<Arc<State>>,
    pub receipts: Vec<Receipt>,
}

#[derive(Debug, PartialEq)]
pub enum Added {
    /// Became the new tip of the best chain.
    NewTip { reorg_depth: u64 },
    /// Valid, but on a weaker fork.
    SideChain,
    /// Already had it.
    Known,
    /// Parent not seen yet. Kept until the parent arrives.
    Orphan,
}

pub struct Chain {
    pub genesis: Genesis,
    pub blocks: HashMap<Hash, Stored>,
    pub tip: Hash,
    /// Block hashes of the best chain, by height.
    pub best: Vec<Hash>,
    /// Where each transaction on the best chain is: (block hash, position).
    pub tx_index: HashMap<Hash, (Hash, usize)>,
    pub orphans: HashMap<Hash, Vec<Block>>,
    pub mempool: BTreeMap<Hash, Tx>,
    /// Finality votes seen so far: (height, block) -> voter -> vote.
    pub votes: BTreeMap<(u64, Hash), BTreeMap<Address, Vote>>,
    /// The first vote seen from each validator at each height, to catch double voting.
    first_vote: HashMap<(u64, Address), Vote>,
}

#[derive(Debug, PartialEq)]
#[allow(clippy::large_enum_variant)] // short-lived, boxing buys nothing
pub enum VoteAdded {
    New,
    Known,
    /// The same validator voted for two different blocks at this height. Here's the proof.
    DoubleVote(Vote, Vote),
}

impl Chain {
    pub fn new(genesis: Genesis) -> Chain {
        let (block, state) = genesis.genesis_block();
        let h = block.hash();
        let mut blocks = HashMap::new();
        blocks.insert(
            h,
            Stored {
                block,
                score: Score::default(),
                state: Some(Arc::new(state)),
                receipts: vec![],
            },
        );
        Chain {
            genesis,
            blocks,
            tip: h,
            best: vec![h],
            tx_index: HashMap::new(),
            orphans: HashMap::new(),
            mempool: BTreeMap::new(),
            votes: BTreeMap::new(),
            first_vote: HashMap::new(),
        }
    }

    /// Starts from a saved snapshot instead of replaying every block from the beginning.
    /// `history` is the best chain up to and including the snapshot block, with receipts.
    pub fn restore(
        genesis: Genesis,
        history: Vec<(Block, Vec<Receipt>)>,
        snapshot: State,
    ) -> Result<Chain, String> {
        let mut c = Chain::new(genesis);
        let mut score = Score::default();
        let last = history.len().saturating_sub(1);
        for (i, (block, receipts)) in history.into_iter().enumerate() {
            let h = block.hash();
            if i == 0 {
                if h != c.best[0] {
                    return Err("saved chain is for a different genesis".into());
                }
                continue;
            }
            if block.header.prev != c.best[i - 1] {
                return Err("saved chain doesn't link up".into());
            }
            if block.header.bits > 0 {
                score.work += 1u128 << block.header.bits.min(120);
            } else {
                score.pos_blocks += 1;
                score.on_time -= block.header.round as i64;
            }
            for (j, tx) in block.txs.iter().enumerate() {
                c.tx_index.insert(tx.hash(), (h, j));
            }
            let state = if i == last {
                if snapshot.root() != block.header.state_root {
                    return Err("snapshot doesn't match its block".into());
                }
                score.finalized = snapshot.finalized.0;
                Some(Arc::new(snapshot.clone()))
            } else {
                None
            };
            c.blocks.insert(
                h,
                Stored {
                    block,
                    score,
                    state,
                    receipts,
                },
            );
            c.best.push(h);
        }
        c.tip = *c.best.last().unwrap();
        Ok(c)
    }

    pub fn tip_block(&self) -> &Block {
        &self.blocks[&self.tip].block
    }
    pub fn tip_state(&self) -> Arc<State> {
        self.blocks[&self.tip]
            .state
            .clone()
            .expect("tip always has state")
    }
    pub fn height(&self) -> u64 {
        self.tip_block().header.height
    }
    pub fn block_at(&self, height: u64) -> Option<&Stored> {
        self.best.get(height as usize).map(|h| &self.blocks[h])
    }

    pub fn add_block(&mut self, block: Block) -> Result<Added, String> {
        let mut result = self.add_one(block)?;
        // A new block might be the missing parent of blocks that arrived early.
        loop {
            let ready: Vec<Hash> = self
                .orphans
                .keys()
                .filter(|p| self.blocks.contains_key(*p))
                .copied()
                .collect();
            if ready.is_empty() {
                break;
            }
            for p in ready {
                for child in self.orphans.remove(&p).unwrap_or_default() {
                    if let Ok(r @ Added::NewTip { .. }) = self.add_one(child) {
                        result = r;
                    }
                }
            }
        }
        Ok(result)
    }

    fn add_one(&mut self, block: Block) -> Result<Added, String> {
        let h = block.hash();
        if self.blocks.contains_key(&h) {
            return Ok(Added::Known);
        }
        let Some(parent) = self.blocks.get(&block.header.prev) else {
            if self.orphans.len() < 1000 {
                self.orphans
                    .entry(block.header.prev)
                    .or_default()
                    .push(block);
            }
            return Ok(Added::Orphan);
        };
        if block.header.height <= self.floor() {
            return Err("block is behind the final part of the chain".into());
        }
        let parent_state = parent
            .state
            .clone()
            .ok_or("parent is too old to build on")?;
        let (state, receipts) =
            check_block(&self.genesis, &parent.block.header, &parent_state, &block)?;
        let mut score = parent.score;
        score.finalized = state.finalized.0;
        if block.header.bits > 0 {
            score.work += 1u128 << block.header.bits.min(120);
        } else {
            score.pos_blocks += 1;
            score.on_time -= block.header.round as i64;
        }
        self.blocks.insert(
            h,
            Stored {
                block,
                score,
                state: Some(Arc::new(state)),
                receipts,
            },
        );
        if score > self.blocks[&self.tip].score && self.keeps_finalized(&h) {
            let depth = self.set_tip(h);
            Ok(Added::NewTip { reorg_depth: depth })
        } else {
            Ok(Added::SideChain)
        }
    }

    /// True if the chain ending at `h` still contains our final block. A fork that would undo a
    /// final block is never followed, however much work or stake is behind it.
    fn keeps_finalized(&self, h: &Hash) -> bool {
        let (fh, fhash) = self.tip_state().finalized;
        if fh == 0 {
            return true;
        }
        let mut cur = *h;
        loop {
            let Some(s) = self.blocks.get(&cur) else {
                return false;
            };
            let height = s.block.header.height;
            if height == fh {
                return cur == fhash;
            }
            if height < fh {
                return false;
            }
            cur = s.block.header.prev;
        }
    }

    pub fn finalized(&self) -> (u64, Hash) {
        self.tip_state().finalized
    }

    /// Takes in a finality vote from a validator.
    pub fn add_vote(&mut self, v: Vote) -> Result<VoteAdded, String> {
        let s = self.tip_state();
        if v.height <= s.finalized.0 {
            return Ok(VoteAdded::Known);
        }
        if v.height > self.height() + 10 {
            return Err("vote is too far ahead".into());
        }
        if !v.verify(&self.genesis.chain_id) {
            return Err("bad vote signature".into());
        }
        let who = v.voter.address();
        if s.account(&who).stake < self.genesis.min_stake {
            return Err("vote from someone who isn't a validator".into());
        }
        if let Some(first) = self.first_vote.get(&(v.height, who)) {
            if first.block != v.block {
                return Ok(VoteAdded::DoubleVote(first.clone(), v));
            }
            return Ok(VoteAdded::Known);
        }
        self.first_vote.insert((v.height, who), v.clone());
        self.votes
            .entry((v.height, v.block))
            .or_default()
            .insert(who, v);
        Ok(VoteAdded::New)
    }

    /// The votes that would make the newest possible block on our best chain final,
    /// if enough validators have voted. A block producer puts this in its block.
    pub fn best_commit(&self) -> Option<Commit> {
        let s = self.tip_state();
        let stakes: BTreeMap<Address, u64> = s.validators(&self.genesis).into_iter().collect();
        let total: u128 = stakes.values().map(|v| *v as u128).sum();
        if total == 0 {
            return None;
        }
        // Newest first. The commit goes in the NEXT block, so the tip itself can be committed.
        for h in (s.finalized.0 + 1..=self.height()).rev() {
            let Some(bh) = self.best.get(h as usize) else {
                continue;
            };
            let Some(vs) = self.votes.get(&(h, *bh)) else {
                continue;
            };
            let counted: Vec<Vote> = vs
                .iter()
                .filter(|(a, _)| stakes.contains_key(*a))
                .map(|(_, v)| v.clone())
                .collect();
            let signed: u128 = counted
                .iter()
                .map(|v| stakes[&v.voter.address()] as u128)
                .sum();
            if signed * 3 > total * 2 {
                return Some(Commit {
                    height: h,
                    block: *bh,
                    votes: counted,
                });
            }
        }
        None
    }

    /// Switches the best chain to end at `h`. Returns how many old blocks were dropped (0 = no reorg).
    fn set_tip(&mut self, h: Hash) -> u64 {
        let mut path = Vec::new();
        let mut cur = h;
        loop {
            let b = &self.blocks[&cur].block;
            let height = b.header.height as usize;
            if self.best.get(height) == Some(&cur) {
                break;
            }
            path.push(cur);
            cur = b.header.prev;
        }
        let fork_height = self.blocks[&cur].block.header.height as usize;
        let dropped: Vec<Hash> = self.best.drain(fork_height + 1..).collect();
        // Transactions from dropped blocks go back to waiting, unless the new chain has them.
        for d in &dropped {
            for tx in &self.blocks[d].block.txs {
                let th = tx.hash();
                self.tx_index.remove(&th);
                self.mempool.insert(th, tx.clone());
            }
        }
        for p in path.iter().rev() {
            self.best.push(*p);
            for (i, tx) in self.blocks[p].block.txs.iter().enumerate() {
                let th = tx.hash();
                self.tx_index.insert(th, (*p, i));
                self.mempool.remove(&th);
            }
        }
        self.tip = h;
        self.prune();
        self.clean_mempool();
        let fin = self.tip_state().finalized.0;
        self.votes.retain(|(height, _), _| *height > fin);
        self.first_vote.retain(|(height, _), _| *height + 64 > fin);
        dropped.len() as u64
    }

    /// Blocks at or below this height can't change any more. With staking finality it is the
    /// final block, so a fork that started after it can still win even if it is long (say one
    /// half of a split network kept finalizing while the other half couldn't). Before that, in the
    /// mining stage, it is a fixed depth behind the tip.
    fn floor(&self) -> u64 {
        match self.tip_state().finalized.0 {
            0 => self.height().saturating_sub(FINALITY_DEPTH),
            fin => fin,
        }
    }

    /// Drops states below the floor to save memory. Their blocks stay, so the history can still
    /// be read. States above it are kept on every branch, so any fork that could still win can be
    /// checked.
    fn prune(&mut self) {
        let cutoff = self.floor();
        let keep_final = self.best.get(cutoff as usize).copied();
        for (h, s) in self.blocks.iter_mut() {
            if s.block.header.height < cutoff && Some(*h) != keep_final {
                s.state = None;
            }
        }
    }

    /// Removes waiting transactions that can no longer go in (nonce already used).
    fn clean_mempool(&mut self) {
        let s = self.tip_state();
        self.mempool
            .retain(|_, tx| s.account(&tx.sender()).nonce <= tx.nonce);
    }

    /// Checks a new transaction and holds it until a block includes it.
    pub fn submit_tx(&mut self, tx: Tx) -> Result<Hash, String> {
        let h = tx.hash();
        if self.mempool.contains_key(&h) || self.tx_index.contains_key(&h) {
            return Ok(h);
        }
        if !tx.verify(&self.genesis.chain_id) {
            return Err("bad signature".into());
        }
        let s = self.tip_state();
        let acc = s.account(&tx.sender());
        if tx.nonce < acc.nonce {
            return Err(format!(
                "nonce {} already used (next is {})",
                tx.nonce, acc.nonce
            ));
        }
        if tx.nonce > acc.nonce + 64 {
            return Err("nonce too far ahead".into());
        }
        if tx.gas_limit.saturating_mul(tx.gas_price) > acc.balance {
            return Err("not enough CTDY for the gas".into());
        }
        if self.mempool.len() >= 10_000 {
            return Err("too many waiting transactions".into());
        }
        self.mempool.insert(h, tx);
        Ok(h)
    }

    /// Waiting transactions in an order that can work: each sender's in nonce order,
    /// higher gas prices first.
    pub fn pending(&self) -> Vec<Tx> {
        let mut v: Vec<Tx> = self.mempool.values().cloned().collect();
        v.sort_by_key(|t| (t.sender(), t.nonce));
        let mut by_sender: BTreeMap<Address, Vec<Tx>> = BTreeMap::new();
        for t in v {
            by_sender.entry(t.sender()).or_default().push(t);
        }
        let mut queues: Vec<Vec<Tx>> = by_sender.into_values().collect();
        queues.sort_by_key(|q| std::cmp::Reverse(q[0].gas_price));
        let mut out = Vec::new();
        let mut i = 0;
        while queues.iter().any(|q| i < q.len()) {
            for q in &queues {
                if let Some(t) = q.get(i) {
                    out.push(t.clone());
                }
            }
            i += 1;
        }
        out
    }

    /// Looks up a transaction and its receipt on the best chain.
    pub fn find_tx(&self, h: &Hash) -> Option<(u64, Tx, Receipt)> {
        let (bh, i) = self.tx_index.get(h)?;
        let s = &self.blocks[bh];
        Some((
            s.block.header.height,
            s.block.txs[*i].clone(),
            s.receipts[*i].clone(),
        ))
    }
}
