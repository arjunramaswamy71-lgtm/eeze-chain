//! The read side of the node's web API, as plain functions. The real node serves these over HTTP,
//! and the in-browser demo calls the very same code, so the explorer can't tell them apart.

use crate::abi::{self, Arg};
use crate::chain::Chain;
use crate::state::Receipt;
use crate::types::*;
use serde::Deserialize;
use serde_json::{Value, json};
use std::collections::HashMap;

/// What the chain itself can't know: who this node is and who it's talking to.
pub struct NodeInfo {
    pub name: String,
    pub now: u64,
    pub peers: Vec<Value>,
    pub network_key: String,
}

pub type ApiResult = Result<Value, (u16, String)>;

fn bad(e: impl ToString) -> (u16, String) {
    (400, e.to_string())
}
fn missing(e: impl ToString) -> (u16, String) {
    (404, e.to_string())
}

fn parse_query(q: &str) -> HashMap<String, String> {
    q.split('&')
        .filter_map(|kv| kv.split_once('='))
        .map(|(k, v)| (k.to_string(), v.to_string()))
        .collect()
}

/// Handles one request. `POST /tx` is left to the caller, because sending a transaction
/// also means passing it on to other nodes.
pub fn handle(
    c: &Chain,
    info: &NodeInfo,
    method: &str,
    path: &str,
    query: &str,
    body: &[u8],
) -> ApiResult {
    let q = parse_query(query);
    let parts: Vec<&str> = path.trim_matches('/').split('/').collect();
    match (method, parts.as_slice()) {
        ("GET", ["status"]) => Ok(status(c, info)),
        ("GET", ["genesis"]) => Ok(json!(c.genesis)),
        ("GET", ["blocks"]) => Ok(blocks(c, &q)),
        ("GET", ["block", id]) => block(c, id),
        ("GET", ["tx", h]) => tx(c, h),
        ("GET", ["account", a]) => account(c, a),
        ("GET", ["validators"]) => Ok(validators(c)),
        ("GET", ["contracts"]) => Ok(contracts(c)),
        ("GET", ["events"]) => Ok(events(c, &q)),
        ("GET", ["mempool"]) => Ok(json!(
            c.pending()
                .iter()
                .map(|t| json!({ "hash": t.hash(), "from": t.sender(), "tx": t }))
                .collect::<Vec<_>>()
        )),
        ("POST", ["query"]) => contract_query(c, body),
        ("GET", ["peers"]) => Ok(json!(info.peers)),
        ("GET", ["history", a]) => history(c, a, &q),
        ("GET", ["recent-txs"]) => Ok(recent_txs(c, &q)),
        ("GET", ["headers"]) => headers(c, &q),
        ("GET", ["proof", a]) => proof(c, a),
        _ => Err(missing("no such endpoint")),
    }
}

fn status(c: &Chain, info: &NodeInfo) -> Value {
    let s = c.tip_state();
    let tip = c.tip_block();
    let next = tip.header.height + 1;
    json!({
        "node": info.name,
        "chain_id": c.genesis.chain_id,
        "height": tip.header.height,
        "tip": c.tip,
        "tip_time": tip.header.time,
        "now": info.now,
        "consensus": if s.is_pos(&c.genesis, next) { "proof-of-stake" } else { "proof-of-work" },
        "difficulty_bits": s.bits,
        "pos_height": c.genesis.pos_height,
        "supply": s.supply,
        "burned": s.burned,
        "validators": s.validators(&c.genesis).len(),
        "staked": s.accounts.values().map(|a| a.stake).sum::<u64>(),
        "network_key": info.network_key,
        "mempool": c.mempool.len(),
        "peers": info.peers.len(),
        "accounts": s.accounts.len(),
        "contracts": s.contracts.len(),
        "finalized": { "height": s.finalized.0, "hash": s.finalized.1 },
        "votes_waiting": c.votes.len(),
        "coin": { "name": "CoTdy", "symbol": "CTDY", "decimals": 8 },
    })
}

fn summary(b: &Block, receipts: &[Receipt]) -> Value {
    json!({
        "height": b.header.height,
        "hash": b.hash(),
        "time": b.header.time,
        "producer": b.header.producer.address(),
        "kind": if b.header.height == 0 { "genesis" } else if b.header.bits > 0 { "pow" } else { "pos" },
        "bits": b.header.bits,
        "round": b.header.round,
        "finalizes": b.commit.as_ref().map(|c| c.height),
        "txs": b.txs.len(),
        "gas_used": receipts.iter().map(|r| r.gas_used).sum::<u64>(),
        "fees": receipts.iter().map(|r| r.fee).sum::<u64>(),
    })
}

fn num(q: &HashMap<String, String>, k: &str) -> Option<u64> {
    q.get(k).and_then(|v| v.parse().ok())
}

fn blocks(c: &Chain, q: &HashMap<String, String>) -> Value {
    let limit = num(q, "limit").unwrap_or(20).min(500);
    let to = num(q, "before")
        .unwrap_or(c.height() + 1)
        .min(c.height() + 1);
    let from = to.saturating_sub(limit);
    let fin = c.finalized().0;
    let list: Vec<Value> = (from..to)
        .rev()
        .filter_map(|h| c.block_at(h))
        .map(|s| {
            let mut v = summary(&s.block, &s.receipts);
            v["final"] = json!(s.block.header.height <= fin);
            v
        })
        .collect();
    json!(list)
}

fn block(c: &Chain, id: &str) -> ApiResult {
    let stored = if let Ok(h) = id.parse::<u64>() {
        c.block_at(h)
    } else {
        id.parse::<Hash>().ok().and_then(|h| c.blocks.get(&h))
    }
    .ok_or(missing("no such block"))?;
    let b = &stored.block;
    let on_best = c.best.get(b.header.height as usize) == Some(&b.hash());
    let txs: Vec<Value> = b
        .txs
        .iter()
        .zip(&stored.receipts)
        .map(|(t, r)| json!({ "hash": t.hash(), "from": t.sender(), "tx": t, "receipt": r }))
        .collect();
    let fin = c.finalized();
    Ok(json!({
        "summary": summary(b, &stored.receipts),
        "header": b.header,
        "sig": b.sig,
        "commit": b.commit,
        "on_best_chain": on_best,
        "final": on_best && b.header.height <= fin.0,
        "txs": txs,
    }))
}

fn tx(c: &Chain, h: &str) -> ApiResult {
    let h: Hash = h.parse().map_err(bad)?;
    if let Some((height, t, r)) = c.find_tx(&h) {
        return Ok(json!({
            "status": "confirmed",
            "height": height,
            "confirmations": c.height() - height + 1,
            "final": height <= c.finalized().0,
            "from": t.sender(),
            "tx": t,
            "receipt": r,
        }));
    }
    if let Some(t) = c.mempool.get(&h) {
        return Ok(json!({ "status": "pending", "from": t.sender(), "tx": t }));
    }
    Err(missing("unknown transaction"))
}

fn account(c: &Chain, a: &str) -> ApiResult {
    let a: Address = a.parse().map_err(bad)?;
    let s = c.tip_state();
    let acc = s.account(&a);
    let pending = c
        .mempool
        .values()
        .filter(|t| t.sender() == a)
        .map(|t| t.nonce + 1)
        .max()
        .unwrap_or(0);
    let contract = s.contracts.get(&a).map(
        |k| json!({ "creator": k.creator, "code_size": k.code.0.len(), "slots": k.storage.len() }),
    );
    Ok(json!({
        "address": a,
        "balance": acc.balance,
        "nonce": acc.nonce,
        "next_nonce": acc.nonce.max(pending),
        "stake": acc.stake,
        "unbonding": acc.unbonding,
        "is_validator": acc.stake >= c.genesis.min_stake && acc.vrf_key.is_some(),
        "vrf_key": acc.vrf_key,
        "contract": contract,
    }))
}

fn validators(c: &Chain) -> Value {
    let s = c.tip_state();
    let vals = s.validators(&c.genesis);
    let total: u64 = vals.iter().map(|v| v.1).sum();
    let mut made: HashMap<Address, u64> = HashMap::new();
    let mut voted: HashMap<Address, u64> = HashMap::new();
    for h in c.height().saturating_sub(99)..=c.height() {
        if let Some(b) = c.block_at(h) {
            if b.block.header.bits == 0 && h > 0 {
                *made.entry(b.block.header.producer.address()).or_default() += 1;
            }
            if let Some(cm) = &b.block.commit {
                for v in &cm.votes {
                    *voted.entry(v.voter.address()).or_default() += 1;
                }
            }
        }
    }
    let list: Vec<Value> = vals
        .iter()
        .map(|(a, st)| {
            json!({
                "address": a,
                "stake": st,
                "share": *st as f64 / total.max(1) as f64,
                "recent_blocks": made.get(a).copied().unwrap_or(0),
                "recent_votes": voted.get(a).copied().unwrap_or(0),
                "vrf_key": s.account(a).vrf_key,
                "slashed": s.slashed.iter().any(|x| x.0 == *a),
            })
        })
        .collect();
    let slashed: Vec<Value> = s
        .slashed
        .iter()
        .map(|(a, h, r)| json!({ "address": a, "height": h, "round": r, "kind": if *r == u32::MAX { "double vote" } else { "double block" }, "stake_left": s.account(a).stake }))
        .collect();
    json!({ "total_stake": total, "min_stake": c.genesis.min_stake, "validators": list, "slashed": slashed, "finalized": c.finalized().0 })
}

fn contracts(c: &Chain) -> Value {
    let s = c.tip_state();
    let list: Vec<Value> = s
        .contracts
        .iter()
        .map(|(a, k)| {
            let info = s.query(a, abi::call("info", &[]), Address::default(), 5_000_000).ok().and_then(|o| abi::decode(&o).ok());
            json!({ "address": a, "creator": k.creator, "balance": s.account(a).balance, "info": info })
        })
        .collect();
    json!(list)
}

fn events(c: &Chain, q: &HashMap<String, String>) -> Value {
    let want: Option<Address> = q.get("contract").and_then(|v| v.parse().ok());
    let limit = num(q, "limit").unwrap_or(50) as usize;
    let mut out = Vec::new();
    for h in (0..=c.height()).rev() {
        let Some(s) = c.block_at(h) else { continue };
        for (t, r) in s.block.txs.iter().zip(&s.receipts) {
            for e in &r.events {
                if want.map(|w| w == e.contract).unwrap_or(true) {
                    out.push(json!({ "height": h, "tx": t.hash(), "contract": e.contract, "topic": e.topic, "data": e.data }));
                }
            }
        }
        if out.len() >= limit {
            break;
        }
    }
    json!(out)
}

#[derive(Deserialize)]
struct QueryReq {
    contract: Address,
    method: String,
    #[serde(default)]
    args: Vec<Arg>,
    caller: Option<Address>,
}

fn contract_query(c: &Chain, body: &[u8]) -> ApiResult {
    let q: QueryReq = serde_json::from_slice(body).map_err(bad)?;
    let s = c.tip_state();
    let out = s
        .query(
            &q.contract,
            abi::call(&q.method, &q.args),
            q.caller.unwrap_or_default(),
            20_000_000,
        )
        .map_err(bad)?;
    Ok(json!({ "result": abi::decode(&out).map_err(bad)? }))
}

fn tx_row(h: u64, b: &Block, t: &Tx, r: &Receipt) -> Value {
    json!({ "height": h, "time": b.header.time, "hash": t.hash(), "from": t.sender(), "tx": t, "receipt": r })
}

fn history(c: &Chain, a: &str, q: &HashMap<String, String>) -> ApiResult {
    let a: Address = a.parse().map_err(bad)?;
    let limit = num(q, "limit").unwrap_or(25).min(200) as usize;
    let mut out = Vec::new();
    for h in (1..=c.height()).rev() {
        let Some(s) = c.block_at(h) else { continue };
        for (t, r) in s.block.txs.iter().zip(&s.receipts) {
            let to = match &t.kind {
                TxKind::Transfer { to, .. } => Some(*to),
                TxKind::Call { contract, .. } => Some(*contract),
                _ => None,
            };
            if t.sender() == a || to == Some(a) {
                out.push(tx_row(h, &s.block, t, r));
            }
        }
        if out.len() >= limit || c.height() - h > 5_000 {
            break;
        }
    }
    Ok(json!(out))
}

fn recent_txs(c: &Chain, q: &HashMap<String, String>) -> Value {
    let limit = num(q, "limit").unwrap_or(10).min(100) as usize;
    let mut out = Vec::new();
    for h in (1..=c.height()).rev() {
        let Some(s) = c.block_at(h) else { continue };
        for (t, r) in s.block.txs.iter().zip(&s.receipts).rev() {
            out.push(tx_row(h, &s.block, t, r));
        }
        if out.len() >= limit || c.height() - h > 10_000 {
            break;
        }
    }
    out.truncate(limit);
    json!(out)
}

fn headers(c: &Chain, q: &HashMap<String, String>) -> ApiResult {
    let from = num(q, "from").unwrap_or(0);
    let to = num(q, "to").unwrap_or(c.height()).min(c.height());
    if to < from || to - from > 2_000 {
        return Err(bad("ask for at most 2,000 headers"));
    }
    Ok(json!(
        (from..=to)
            .filter_map(|h| c.block_at(h))
            .map(|s| json!(s.block.header))
            .collect::<Vec<_>>()
    ))
}

/// Everything a light client needs to check an account's balance without trusting this node:
/// the newest final block, the votes that made it final, proofs of each voter's stake and of the
/// total validator stake, and a Merkle proof of the account in the final block's state.
fn proof(c: &Chain, a: &str) -> ApiResult {
    let a: Address = a.parse().map_err(bad)?;
    let (fh, fhash) = c.finalized();
    if fh == 0 {
        return Err(missing(
            "nothing is final yet; finality starts once validators are voting",
        ));
    }
    let carrier = (fh + 1..=c.height())
        .filter_map(|h| c.block_at(h))
        .find(|s| s.block.commit.as_ref().map(|x| x.height) == Some(fh))
        .ok_or(missing("votes for the final block not found"))?;
    let commit = carrier.block.commit.clone().unwrap();
    let ch = carrier.block.header.height;
    let pstate = c
        .block_at(ch - 1)
        .and_then(|p| p.state.clone())
        .ok_or(missing("state too old to prove"))?;
    let fstate = c
        .block_at(fh)
        .and_then(|f| f.state.clone())
        .ok_or(missing("state too old to prove"))?;
    let voters: Vec<Value> = commit
        .votes
        .iter()
        .filter_map(|v| {
            let a = v.voter.address();
            pstate.account_proof(&a).map(|(acc, index, proof)| json!({ "address": a, "account": acc, "index": index, "proof": proof }))
        })
        .collect();
    let (meta, mi, mp) = pstate.meta_proof();
    let account = fstate
        .account_proof(&a)
        .map(|(acc, index, proof)| json!({ "account": acc, "index": index, "proof": proof }));
    let headers: Vec<Value> = (fh..=ch)
        .filter_map(|h| c.block_at(h))
        .map(|s| json!(s.block.header))
        .collect();
    Ok(json!({
        "chain_id": c.genesis.chain_id,
        "final": { "height": fh, "hash": fhash },
        "headers": headers,
        "commit": commit,
        "voters": voters,
        "meta": { "bytes": Bytes(meta), "index": mi, "proof": mp },
        "account": account,
        "address": a,
    }))
}
