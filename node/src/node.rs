//! A running EEZE Chain node: talks to other nodes, makes blocks, saves the chain to disk.

use eeze_core::state::{build_block, mine};
use eeze_core::*;
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};
use std::io::{BufRead, Write};
use std::path::PathBuf;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex};
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::mpsc;

pub fn now_ms() -> u64 {
    SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_millis() as u64
}

#[macro_export]
macro_rules! log {
    ($node:expr, $($t:tt)*) => {{
        let secs = $crate::node::now_ms() / 1000 % 86400;
        println!("[{:02}:{:02}:{:02} {}] {}", secs / 3600, secs / 60 % 60, secs % 60, $node.name, format!($($t)*));
    }};
}

/// Messages between nodes, one JSON object per line.
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(tag = "m", rename_all = "snake_case")]
pub enum Msg {
    Hello { height: u64, tip: Hash, port: u16, chain_id: String },
    GetBlocks { from: u64 },
    Blocks { blocks: Vec<Block> },
    Block { block: Block },
    Tx { tx: Tx },
    Peers { addrs: Vec<String> },
}

pub struct Peer {
    pub addr: String,
    pub listen: Option<String>,
    pub height: u64,
    pub send: mpsc::UnboundedSender<Msg>,
}

pub struct Node {
    pub name: String,
    pub chain: Mutex<Chain>,
    pub peers: Mutex<HashMap<u64, Peer>>,
    next_peer: AtomicU64,
    /// Goes up every time the best chain changes, so miners know to start over.
    pub tip_version: AtomicU64,
    pub port: u16,
    pub key: Option<Keypair>,
    data: Option<PathBuf>,
    saved: Mutex<Vec<Hash>>,
    /// Staking headers seen, to catch a validator signing two blocks for one turn.
    seen_headers: Mutex<HashMap<(u64, u32, Address), SignedHeader>>,
    /// Turns this node has signed, so it never signs twice (that would get it slashed).
    signed: Mutex<HashSet<(u64, u32)>>,
    /// Cheats already reported, so each one is reported once.
    reported: Mutex<HashSet<(u64, u32, Address)>>,
    pub known_addrs: Mutex<HashSet<String>>,
    /// For the slashing demo only: sign two blocks per turn on purpose.
    pub evil_double_sign: bool,
    pub max_peers: usize,
}

impl Node {
    pub fn new(name: String, genesis: Genesis, port: u16, key: Option<Keypair>, data: Option<PathBuf>) -> Arc<Node> {
        let node = Arc::new(Node {
            name,
            chain: Mutex::new(Chain::new(genesis)),
            peers: Mutex::new(HashMap::new()),
            next_peer: AtomicU64::new(1),
            tip_version: AtomicU64::new(0),
            port,
            key,
            data,
            saved: Mutex::new(Vec::new()),
            seen_headers: Mutex::new(HashMap::new()),
            signed: Mutex::new(HashSet::new()),
            reported: Mutex::new(HashSet::new()),
            known_addrs: Mutex::new(HashSet::new()),
            evil_double_sign: false,
            max_peers: 12,
        });
        node.load_from_disk();
        node
    }

    fn blocks_file(&self) -> Option<PathBuf> {
        self.data.as_ref().map(|d| d.join("blocks.jsonl"))
    }

    fn load_from_disk(&self) {
        let Some(path) = self.blocks_file() else { return };
        let Ok(f) = std::fs::File::open(&path) else { return };
        let mut n = 0;
        {
            let mut c = self.chain.lock().unwrap();
            for line in std::io::BufReader::new(f).lines().map_while(Result::ok) {
                if let Ok(b) = serde_json::from_str::<Block>(&line) {
                    if c.add_block(b).is_ok() {
                        n += 1;
                    }
                }
            }
            *self.saved.lock().unwrap() = c.best.clone();
        }
        log!(self, "loaded {n} blocks from {}", path.display());
    }

    /// Writes new best-chain blocks to disk. After a reorg it rewrites the file.
    fn save(&self) {
        let Some(path) = self.blocks_file() else { return };
        let c = self.chain.lock().unwrap();
        let mut saved = self.saved.lock().unwrap();
        let same_prefix = saved.iter().zip(c.best.iter()).all(|(a, b)| a == b);
        let (start, append) = if same_prefix && saved.len() <= c.best.len() { (saved.len(), true) } else { (0, false) };
        let mut f = std::fs::OpenOptions::new()
            .create(true)
            .append(append)
            .write(true)
            .truncate(!append)
            .open(&path)
            .expect("can't write chain file");
        for h in &c.best[start.max(1)..] {
            let line = serde_json::to_string(&c.blocks[h].block).unwrap();
            writeln!(f, "{line}").unwrap();
        }
        *saved = c.best.clone();
    }

    pub fn broadcast(&self, msg: &Msg, except: Option<u64>) {
        for (id, p) in self.peers.lock().unwrap().iter() {
            if Some(*id) != except {
                let _ = p.send.send(msg.clone());
            }
        }
    }

    fn send_to(&self, id: u64, msg: Msg) {
        if let Some(p) = self.peers.lock().unwrap().get(&id) {
            let _ = p.send.send(msg);
        }
    }

    /// Handles a block from a peer (or one we made ourselves, `from` = None).
    pub fn on_block(self: &Arc<Self>, block: Block, from: Option<u64>) {
        if block.header.time > now_ms() + 15_000 {
            log!(self, "ignored block #{} from the future", block.header.height);
            return;
        }
        self.watch_for_double_signing(&block);
        let h = block.header.height;
        let n_tx = block.txs.len();
        let producer = block.header.producer.address();
        let res = self.chain.lock().unwrap().add_block(block.clone());
        match res {
            Ok(Added::NewTip { reorg_depth }) => {
                self.tip_version.fetch_add(1, Ordering::SeqCst);
                let kind = if block.header.bits > 0 { "mined" } else { "staked" };
                if reorg_depth > 0 {
                    log!(self, "REORG: dropped {reorg_depth} block(s), switched to a heavier chain");
                }
                let mine = self.key.as_ref().map(|k| k.address() == producer).unwrap_or(false);
                log!(self, "#{h} {kind} by {}{} with {n_tx} tx", short(&producer), if mine { " (us)" } else { "" });
                self.save();
                self.broadcast(&Msg::Block { block }, from);
            }
            Ok(Added::SideChain) => {
                log!(self, "#{h} side chain block (a fork), kept in case it wins");
                self.broadcast(&Msg::Block { block }, from);
            }
            Ok(Added::Orphan) => {
                if let Some(id) = from {
                    let ours = self.chain.lock().unwrap().height();
                    self.send_to(id, Msg::GetBlocks { from: ours.saturating_sub(64).max(1) });
                }
            }
            Ok(Added::Known) => {}
            Err(e) => log!(self, "rejected block #{h}: {e}"),
        }
    }

    pub fn on_tx(&self, tx: Tx, from: Option<u64>) -> Result<Hash, String> {
        let h = tx.hash();
        let fresh = {
            let mut c = self.chain.lock().unwrap();
            let was = c.mempool.contains_key(&h) || c.tx_index.contains_key(&h);
            c.submit_tx(tx.clone())?;
            !was
        };
        if fresh {
            self.broadcast(&Msg::Tx { tx }, from);
        }
        Ok(h)
    }

    /// If a validator signs two different blocks for the same turn, report it with a slashing proof.
    fn watch_for_double_signing(&self, block: &Block) {
        let Some(sig) = block.sig else { return };
        let sh = SignedHeader { header: block.header.clone(), sig };
        if !sh.verify() {
            return;
        }
        let k = (sh.header.height, sh.header.round, sh.header.producer.address());
        let earlier = {
            let mut seen = self.seen_headers.lock().unwrap();
            match seen.get(&k) {
                Some(prev) if prev.header.hash() != sh.header.hash() => Some(prev.clone()),
                Some(_) => None,
                None => {
                    seen.insert(k, sh.clone());
                    None
                }
            }
        };
        let (Some(prev), Some(key)) = (earlier, &self.key) else { return };
        if !self.reported.lock().unwrap().insert(k) {
            return;
        }
        log!(self, "CAUGHT {} signing two blocks at #{} round {}. Reporting it.", short(&k.2), k.0, k.1);
        let (chain_id, nonce) = {
            let c = self.chain.lock().unwrap();
            let pending = c.mempool.values().filter(|t| t.sender() == key.address()).count() as u64;
            (c.genesis.chain_id.clone(), c.tip_state().account(&key.address()).nonce + pending)
        };
        let tx = Tx::new_signed(&chain_id, key, nonce, 21_000, 1, TxKind::Evidence { a: prev, b: sh });
        if let Err(e) = self.on_tx(tx, None) {
            log!(self, "couldn't submit the report: {e}");
        }
    }

    fn on_msg(self: &Arc<Self>, id: u64, msg: Msg) {
        match msg {
            Msg::Hello { height, port, chain_id, .. } => {
                let ours_id = self.chain.lock().unwrap().genesis.chain_id.clone();
                if chain_id != ours_id {
                    log!(self, "peer is on a different chain ({chain_id}), disconnecting");
                    self.peers.lock().unwrap().remove(&id);
                    return;
                }
                let mut addr = None;
                if let Some(p) = self.peers.lock().unwrap().get_mut(&id) {
                    p.height = height;
                    let ip = p.addr.rsplit_once(':').map(|x| x.0.to_string()).unwrap_or_default();
                    p.listen = Some(format!("{ip}:{port}"));
                    addr = p.listen.clone();
                }
                if let Some(a) = addr {
                    self.known_addrs.lock().unwrap().insert(a);
                }
                let ours = self.chain.lock().unwrap().height();
                if height > ours {
                    self.send_to(id, Msg::GetBlocks { from: ours.saturating_sub(64).max(1) });
                }
            }
            Msg::GetBlocks { from } => {
                let blocks: Vec<Block> = {
                    let c = self.chain.lock().unwrap();
                    c.best.iter().skip(from as usize).take(200).map(|h| c.blocks[h].block.clone()).collect()
                };
                if !blocks.is_empty() {
                    self.send_to(id, Msg::Blocks { blocks });
                }
            }
            Msg::Blocks { blocks } => {
                let full = blocks.len() == 200;
                let last = blocks.last().map(|b| b.header.height).unwrap_or(0);
                for b in blocks {
                    self.on_block(b, Some(id));
                }
                if full {
                    self.send_to(id, Msg::GetBlocks { from: last + 1 });
                }
            }
            Msg::Block { block } => {
                if let Some(p) = self.peers.lock().unwrap().get_mut(&id) {
                    p.height = p.height.max(block.header.height);
                }
                self.on_block(block, Some(id));
            }
            Msg::Tx { tx } => {
                let _ = self.on_tx(tx, Some(id));
            }
            Msg::Peers { addrs } => {
                let mut k = self.known_addrs.lock().unwrap();
                for a in addrs.into_iter().take(50) {
                    k.insert(a);
                }
            }
        }
    }

    /// Runs one connection until it closes.
    pub async fn run_conn(self: Arc<Self>, stream: TcpStream, addr: String) {
        if self.peers.lock().unwrap().len() >= self.max_peers {
            return;
        }
        let id = self.next_peer.fetch_add(1, Ordering::SeqCst);
        let (rd, mut wr) = stream.into_split();
        let (tx, mut rx) = mpsc::unbounded_channel::<Msg>();
        self.peers.lock().unwrap().insert(id, Peer { addr: addr.clone(), listen: None, height: 0, send: tx.clone() });
        let hello = {
            let c = self.chain.lock().unwrap();
            Msg::Hello { height: c.height(), tip: c.tip, port: self.port, chain_id: c.genesis.chain_id.clone() }
        };
        let _ = tx.send(hello);
        log!(self, "connected to {addr}");

        let writer = tokio::spawn(async move {
            while let Some(m) = rx.recv().await {
                let mut line = serde_json::to_vec(&m).unwrap();
                line.push(b'\n');
                if wr.write_all(&line).await.is_err() {
                    break;
                }
            }
        });
        let mut lines = BufReader::with_capacity(1 << 20, rd).lines();
        while let Ok(Some(line)) = lines.next_line().await {
            if line.len() > 32 << 20 {
                break;
            }
            match serde_json::from_str::<Msg>(&line) {
                Ok(m) => {
                    let me = self.clone();
                    // Block checking is CPU work, so keep it off the network threads.
                    let _ = tokio::task::spawn_blocking(move || me.on_msg(id, m)).await;
                }
                Err(e) => log!(self, "bad message from {addr}: {e}"),
            }
            if !self.peers.lock().unwrap().contains_key(&id) {
                break;
            }
        }
        writer.abort();
        self.peers.lock().unwrap().remove(&id);
        log!(self, "disconnected from {addr}");
    }

    pub async fn listen(self: Arc<Self>) {
        let l = TcpListener::bind(("0.0.0.0", self.port)).await.expect("p2p port is taken");
        loop {
            if let Ok((s, a)) = l.accept().await {
                tokio::spawn(self.clone().run_conn(s, a.to_string()));
            }
        }
    }

    /// Keeps trying to stay connected to the given peers and any peers they tell us about.
    pub async fn dial_loop(self: Arc<Self>, seeds: Vec<String>) {
        {
            let mut k = self.known_addrs.lock().unwrap();
            k.extend(seeds);
        }
        let me = format!("127.0.0.1:{}", self.port);
        loop {
            let (connected, n): (HashSet<String>, usize) = {
                let p = self.peers.lock().unwrap();
                (p.values().flat_map(|p| [Some(p.addr.clone()), p.listen.clone()]).flatten().collect(), p.len())
            };
            let targets: Vec<String> = self
                .known_addrs
                .lock()
                .unwrap()
                .iter()
                .filter(|a| !connected.contains(*a) && **a != me && !a.ends_with(&format!("0.0.0.0:{}", self.port)))
                .cloned()
                .collect();
            for t in targets.into_iter().take(self.max_peers.saturating_sub(n)) {
                if let Ok(Ok(s)) = tokio::time::timeout(Duration::from_secs(2), TcpStream::connect(&t)).await {
                    tokio::spawn(self.clone().run_conn(s, t));
                }
            }
            // Share who we know.
            let addrs: Vec<String> = self.peers.lock().unwrap().values().filter_map(|p| p.listen.clone()).collect();
            self.broadcast(&Msg::Peers { addrs }, None);
            tokio::time::sleep(Duration::from_secs(3)).await;
        }
    }

    /// Proof of work: keep guessing nonces on top of the current best block.
    /// Each thread starts its guesses far apart so they never repeat each other's work.
    pub fn mine_forever(self: Arc<Self>, thread: u64, rt: tokio::runtime::Handle) {
        let key = self.key.as_ref().expect("mining needs a key").public();
        loop {
            let (g, parent, ps, pending, ver) = {
                let c = self.chain.lock().unwrap();
                (c.genesis.clone(), c.tip_block().header.clone(), c.tip_state(), c.pending(), self.tip_version.load(Ordering::SeqCst))
            };
            if ps.is_pos(&g, parent.height + 1) {
                std::thread::sleep(Duration::from_secs(2));
                continue;
            }
            let (mut b, _, _) = build_block(&g, &parent, &ps, key, now_ms(), 0, &pending);
            b.header.nonce = thread << 56;
            let started = now_ms();
            let found = mine(&mut b.header, &|| {
                self.tip_version.load(Ordering::SeqCst) != ver || now_ms() - started > 4_000
            });
            if found {
                let me = self.clone();
                let _ = rt.spawn_blocking(move || me.on_block(b, None));
                std::thread::sleep(Duration::from_millis(5));
            }
        }
    }

    /// Proof of stake: when it's our turn, make and sign a block.
    pub async fn validate_forever(self: Arc<Self>) {
        let key = self.key.as_ref().expect("validating needs a key");
        loop {
            tokio::time::sleep(Duration::from_millis(100)).await;
            let (g, parent, ps, pending) = {
                let c = self.chain.lock().unwrap();
                (c.genesis.clone(), c.tip_block().header.clone(), c.tip_state(), c.pending())
            };
            let h = parent.height + 1;
            if !ps.is_pos(&g, h) {
                continue;
            }
            let now = now_ms();
            let mut round = 0u32;
            while parent.time + g.target_ms + round as u64 * g.slot_ms <= now && round < 10_000 {
                if ps.proposer(&g, &parent.hash(), h, round) == Some(key.address()) {
                    if !self.signed.lock().unwrap().insert((h, round)) {
                        break; // already signed this turn
                    }
                    let (mut b, _, _) = build_block(&g, &parent, &ps, key.public(), now, round, &pending);
                    b.sig = Some(key.sign(&b.header.hash().0));
                    if self.evil_double_sign {
                        self.double_sign(&g, &parent, &ps, key, now, round, b);
                    } else {
                        let me = self.clone();
                        let _ = tokio::task::spawn_blocking(move || me.on_block(b, None)).await;
                    }
                    break;
                }
                round += 1;
            }
        }
    }

    /// Demo of cheating: sign a second, different block for the same turn and show
    /// each half of the network a different one. Honest nodes will catch it.
    #[allow(clippy::too_many_arguments)]
    fn double_sign(&self, g: &Genesis, parent: &Header, ps: &State, key: &Keypair, now: u64, round: u32, a: Block) {
        let (mut b, _, _) = build_block(g, parent, ps, key.public(), now + 1, round, &[]);
        b.sig = Some(key.sign(&b.header.hash().0));
        log!(self, "(evil) signing two blocks for #{} round {round}", parent.height + 1);
        let peers: Vec<u64> = self.peers.lock().unwrap().keys().copied().collect();
        for (i, id) in peers.iter().enumerate() {
            let blk = if i % 2 == 0 { a.clone() } else { b.clone() };
            self.send_to(*id, Msg::Block { block: blk });
        }
        let _ = self.chain.lock().unwrap().add_block(a);
        self.tip_version.fetch_add(1, Ordering::SeqCst);
    }
}

pub fn short(a: &Address) -> String {
    let s = a.to_string();
    format!("{}…{}", &s[..8], &s[s.len() - 4..])
}
