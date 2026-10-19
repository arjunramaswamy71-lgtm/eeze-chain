//! Saves the chain to an embedded database (redb: crash-safe, transactional, pure Rust).
//!
//! Blocks and their receipts are kept by hash, the best chain by height, and every so often a
//! snapshot of the state at the newest final block. On restart the node loads the snapshot and
//! only replays the blocks after it, instead of re-running the whole history.

use eeze_core::*;
use redb::{Database, ReadableDatabase, ReadableTable, TableDefinition};
use serde::{Deserialize, Serialize};
use std::path::Path;

const BLOCKS: TableDefinition<&[u8], &[u8]> = TableDefinition::new("blocks");
const BEST: TableDefinition<u64, &[u8]> = TableDefinition::new("best");
const META: TableDefinition<&str, &[u8]> = TableDefinition::new("meta");
const SNAPSHOT_EVERY: u64 = 25;

#[derive(Serialize, Deserialize)]
struct Saved {
    block: Block,
    receipts: Vec<Receipt>,
}

pub struct Store {
    db: Database,
    /// The best chain as last written.
    saved: Vec<Hash>,
    snapshot_height: u64,
}

type Res<T> = Result<T, String>;
fn e(x: impl std::fmt::Display) -> String {
    x.to_string()
}

impl Store {
    pub fn open(dir: &Path) -> Res<Store> {
        let db = Database::create(dir.join("chain.redb")).map_err(e)?;
        let w = db.begin_write().map_err(e)?;
        {
            w.open_table(BLOCKS).map_err(e)?;
            w.open_table(BEST).map_err(e)?;
            w.open_table(META).map_err(e)?;
        }
        w.commit().map_err(e)?;
        Ok(Store {
            db,
            saved: Vec::new(),
            snapshot_height: 0,
        })
    }

    /// Loads the saved chain. Returns (chain, blocks replayed, snapshot height used).
    pub fn load(&mut self, genesis: Genesis) -> Res<(Chain, usize, u64)> {
        let r = self.db.begin_read().map_err(e)?;
        let best = r.open_table(BEST).map_err(e)?;
        let blocks = r.open_table(BLOCKS).map_err(e)?;
        let meta = r.open_table(META).map_err(e)?;
        let mut history: Vec<(Block, Vec<Receipt>)> = Vec::new();
        for row in best.iter().map_err(e)? {
            let (_, hash) = row.map_err(e)?;
            let Some(raw) = blocks.get(hash.value()).map_err(e)? else {
                break;
            };
            let s: Saved = serde_json::from_slice(raw.value()).map_err(e)?;
            history.push((s.block, s.receipts));
        }
        if history.is_empty() {
            return Ok((Chain::new(genesis), 0, 0));
        }
        let snap = match (
            meta.get("snapshot").map_err(e)?,
            meta.get("snapshot_height").map_err(e)?,
        ) {
            (Some(s), Some(h)) => Some((
                State::from_bytes(s.value())?,
                u64::from_le_bytes(h.value().try_into().map_err(e)?),
            )),
            _ => None,
        };
        let (mut chain, start) = match snap {
            Some((state, h)) if (h as usize) < history.len() => {
                let rest = history.split_off(h as usize + 1);
                let c = Chain::restore(genesis.clone(), history, state)?;
                self.snapshot_height = h;
                (c, rest)
            }
            _ => {
                let rest = history.split_off(1);
                (Chain::new(genesis), rest)
            }
        };
        let replay = start.len();
        for (b, _) in start {
            chain.add_block(b)?;
        }
        self.saved = chain.best.clone();
        Ok((chain, replay, self.snapshot_height))
    }

    /// Writes any new best-chain blocks. After a reorg, rewrites from where the chains split.
    pub fn save(&mut self, chain: &Chain) -> Res<()> {
        let split = self
            .saved
            .iter()
            .zip(chain.best.iter())
            .take_while(|(a, b)| a == b)
            .count();
        if split == chain.best.len() && split == self.saved.len() {
            return Ok(());
        }
        let w = self.db.begin_write().map_err(e)?;
        {
            let mut blocks = w.open_table(BLOCKS).map_err(e)?;
            let mut best = w.open_table(BEST).map_err(e)?;
            for h in (chain.best.len() as u64)..(self.saved.len() as u64) {
                best.remove(h).map_err(e)?;
            }
            for (i, hash) in chain.best.iter().enumerate().skip(split) {
                let s = &chain.blocks[hash];
                let raw = serde_json::to_vec(&Saved {
                    block: s.block.clone(),
                    receipts: s.receipts.clone(),
                })
                .map_err(e)?;
                blocks
                    .insert(hash.0.as_slice(), raw.as_slice())
                    .map_err(e)?;
                best.insert(i as u64, hash.0.as_slice()).map_err(e)?;
            }
            // A snapshot at the newest final block, every so often.
            let (fh, fhash) = chain.finalized();
            if fh >= self.snapshot_height + SNAPSHOT_EVERY
                && let Some(state) = chain.blocks.get(&fhash).and_then(|s| s.state.clone())
            {
                let mut meta = w.open_table(META).map_err(e)?;
                meta.insert("snapshot", state.to_bytes().as_slice())
                    .map_err(e)?;
                meta.insert("snapshot_height", fh.to_le_bytes().as_slice())
                    .map_err(e)?;
                self.snapshot_height = fh;
            }
        }
        w.commit().map_err(e)?;
        self.saved = chain.best.clone();
        Ok(())
    }
}
