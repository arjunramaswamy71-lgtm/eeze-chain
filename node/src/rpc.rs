//! The node's web API. The wallet, the explorer and the scripts all use this.

use crate::node::{now_ms, Node};
use axum::extract::{Path, Query, State};
use axum::http::StatusCode;
use axum::routing::{get, post};
use axum::{Json, Router};
use eeze_core::abi::{self, Arg};
use eeze_core::*;
use serde::Deserialize;
use serde_json::{json, Value};
use std::collections::HashMap;
use std::sync::Arc;
use tower_http::cors::CorsLayer;
use tower_http::services::ServeDir;

type Res = Result<Json<Value>, (StatusCode, Json<Value>)>;

fn err(code: StatusCode, msg: impl ToString) -> (StatusCode, Json<Value>) {
    (code, Json(json!({ "error": msg.to_string() })))
}

pub fn router(node: Arc<Node>, web: Option<std::path::PathBuf>) -> Router {
    let r = Router::new()
        .route("/status", get(status))
        .route("/genesis", get(genesis))
        .route("/blocks", get(blocks))
        .route("/block/{id}", get(block))
        .route("/tx/{hash}", get(tx))
        .route("/tx", post(submit))
        .route("/account/{addr}", get(account))
        .route("/validators", get(validators))
        .route("/contracts", get(contracts))
        .route("/events", get(events))
        .route("/mempool", get(mempool))
        .route("/query", post(query))
        .route("/peers", get(peers))
        .route("/history/{addr}", get(history))
        .route("/recent-txs", get(recent_txs))
        .layer(CorsLayer::permissive().allow_private_network(true))
        .with_state(node);
    // The explorer and wallet web app, served from the same place as the API.
    match web {
        Some(dir) => r.fallback_service(ServeDir::new(dir)),
        None => r,
    }
}

/// Transactions sent from or to an address, newest first.
async fn history(State(n): State<Arc<Node>>, Path(a): Path<String>, Query(q): Query<HashMap<String, String>>) -> Res {
    let a: Address = a.parse().map_err(|e| err(StatusCode::BAD_REQUEST, e))?;
    let limit: usize = q.get("limit").and_then(|v| v.parse().ok()).unwrap_or(25).min(200);
    let c = n.chain.lock().unwrap();
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
                out.push(json!({ "height": h, "time": s.block.header.time, "hash": t.hash(), "from": t.sender(), "tx": t, "receipt": r }));
            }
        }
        if out.len() >= limit || c.height() - h > 5_000 {
            break;
        }
    }
    Ok(Json(json!(out)))
}

async fn status(State(n): State<Arc<Node>>) -> Json<Value> {
    let c = n.chain.lock().unwrap();
    let s = c.tip_state();
    let tip = c.tip_block();
    let next = tip.header.height + 1;
    Json(json!({
        "node": n.name,
        "chain_id": c.genesis.chain_id,
        "height": tip.header.height,
        "tip": c.tip,
        "tip_time": tip.header.time,
        "now": now_ms(),
        "consensus": if s.is_pos(&c.genesis, next) { "proof-of-stake" } else { "proof-of-work" },
        "difficulty_bits": s.bits,
        "pos_height": c.genesis.pos_height,
        "supply": s.supply,
        "burned": s.burned,
        "validators": s.validators(&c.genesis).len(),
        "staked": s.accounts.values().map(|a| a.stake).sum::<u64>(),
        "mempool": c.mempool.len(),
        "peers": n.peers.lock().unwrap().len(),
        "accounts": s.accounts.len(),
        "contracts": s.contracts.len(),
        "coin": { "name": "CoTdy", "symbol": "CTDY", "decimals": 8 },
    }))
}

async fn genesis(State(n): State<Arc<Node>>) -> Json<Value> {
    Json(json!(n.chain.lock().unwrap().genesis))
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
        "txs": b.txs.len(),
        "gas_used": receipts.iter().map(|r| r.gas_used).sum::<u64>(),
        "fees": receipts.iter().map(|r| r.fee).sum::<u64>(),
    })
}

async fn blocks(State(n): State<Arc<Node>>, Query(q): Query<HashMap<String, String>>) -> Json<Value> {
    let c = n.chain.lock().unwrap();
    let limit: u64 = q.get("limit").and_then(|v| v.parse().ok()).unwrap_or(20).min(500);
    let to: u64 = q.get("before").and_then(|v| v.parse().ok()).unwrap_or(c.height() + 1).min(c.height() + 1);
    let from = to.saturating_sub(limit);
    let list: Vec<Value> = (from..to)
        .rev()
        .filter_map(|h| c.block_at(h))
        .map(|s| summary(&s.block, &s.receipts))
        .collect();
    Json(json!(list))
}

async fn block(State(n): State<Arc<Node>>, Path(id): Path<String>) -> Res {
    let c = n.chain.lock().unwrap();
    let stored = if let Ok(h) = id.parse::<u64>() {
        c.block_at(h)
    } else {
        id.parse::<Hash>().ok().and_then(|h| c.blocks.get(&h))
    }
    .ok_or(err(StatusCode::NOT_FOUND, "no such block"))?;
    let b = &stored.block;
    let on_best = c.best.get(b.header.height as usize) == Some(&b.hash());
    let txs: Vec<Value> = b
        .txs
        .iter()
        .zip(&stored.receipts)
        .map(|(t, r)| json!({ "hash": t.hash(), "from": t.sender(), "tx": t, "receipt": r }))
        .collect();
    Ok(Json(json!({
        "summary": summary(b, &stored.receipts),
        "header": b.header,
        "sig": b.sig,
        "on_best_chain": on_best,
        "txs": txs,
    })))
}

async fn tx(State(n): State<Arc<Node>>, Path(h): Path<String>) -> Res {
    let h: Hash = h.parse().map_err(|e| err(StatusCode::BAD_REQUEST, e))?;
    let c = n.chain.lock().unwrap();
    if let Some((height, t, r)) = c.find_tx(&h) {
        return Ok(Json(json!({
            "status": "confirmed",
            "height": height,
            "confirmations": c.height() - height + 1,
            "from": t.sender(),
            "tx": t,
            "receipt": r,
        })));
    }
    if let Some(t) = c.mempool.get(&h) {
        return Ok(Json(json!({ "status": "pending", "from": t.sender(), "tx": t })));
    }
    Err(err(StatusCode::NOT_FOUND, "unknown transaction"))
}

async fn submit(State(n): State<Arc<Node>>, Json(t): Json<Tx>) -> Res {
    let node = n.clone();
    let r = tokio::task::spawn_blocking(move || node.on_tx(t, None)).await.unwrap();
    match r {
        Ok(h) => Ok(Json(json!({ "hash": h }))),
        Err(e) => Err(err(StatusCode::BAD_REQUEST, e)),
    }
}

async fn account(State(n): State<Arc<Node>>, Path(a): Path<String>) -> Res {
    let a: Address = a.parse().map_err(|e| err(StatusCode::BAD_REQUEST, e))?;
    let c = n.chain.lock().unwrap();
    let s = c.tip_state();
    let acc = s.account(&a);
    let pending = c.mempool.values().filter(|t| t.sender() == a).map(|t| t.nonce + 1).max().unwrap_or(0);
    let contract = s.contracts.get(&a).map(|k| json!({ "creator": k.creator, "code_size": k.code.0.len(), "slots": k.storage.len() }));
    Ok(Json(json!({
        "address": a,
        "balance": acc.balance,
        "nonce": acc.nonce,
        "next_nonce": acc.nonce.max(pending),
        "stake": acc.stake,
        "unbonding": acc.unbonding,
        "is_validator": acc.stake >= c.genesis.min_stake,
        "contract": contract,
    })))
}

async fn validators(State(n): State<Arc<Node>>) -> Json<Value> {
    let c = n.chain.lock().unwrap();
    let s = c.tip_state();
    let total: u64 = s.validators(&c.genesis).iter().map(|v| v.1).sum();
    // Who made the last 100 blocks.
    let mut made: HashMap<Address, u64> = HashMap::new();
    for h in c.height().saturating_sub(99)..=c.height() {
        if let Some(b) = c.block_at(h) {
            if b.block.header.bits == 0 && h > 0 {
                *made.entry(b.block.header.producer.address()).or_default() += 1;
            }
        }
    }
    let list: Vec<Value> = s
        .validators(&c.genesis)
        .iter()
        .map(|(a, st)| json!({
            "address": a,
            "stake": st,
            "share": *st as f64 / total.max(1) as f64,
            "recent_blocks": made.get(a).copied().unwrap_or(0),
            "slashed": s.slashed.iter().any(|x| x.0 == *a),
        }))
        .collect();
    let slashed: Vec<Value> = s
        .slashed
        .iter()
        .map(|(a, h, r)| json!({ "address": a, "height": h, "round": r, "stake_left": s.account(a).stake }))
        .collect();
    Json(json!({ "total_stake": total, "min_stake": c.genesis.min_stake, "validators": list, "slashed": slashed }))
}

async fn contracts(State(n): State<Arc<Node>>) -> Json<Value> {
    let c = n.chain.lock().unwrap();
    let s = c.tip_state();
    let list: Vec<Value> = s
        .contracts
        .iter()
        .map(|(a, k)| {
            // Ask each contract what it is, if it answers "info".
            let info = s
                .query(a, abi::call("info", &[]), Address::default(), 2_000_000)
                .ok()
                .and_then(|o| abi::decode(&o).ok());
            json!({ "address": a, "creator": k.creator, "balance": s.account(a).balance, "info": info })
        })
        .collect();
    Json(json!(list))
}

async fn events(State(n): State<Arc<Node>>, Query(q): Query<HashMap<String, String>>) -> Json<Value> {
    let c = n.chain.lock().unwrap();
    let want: Option<Address> = q.get("contract").and_then(|v| v.parse().ok());
    let limit: usize = q.get("limit").and_then(|v| v.parse().ok()).unwrap_or(50);
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
    Json(json!(out))
}

async fn mempool(State(n): State<Arc<Node>>) -> Json<Value> {
    let c = n.chain.lock().unwrap();
    let list: Vec<Value> = c.pending().iter().map(|t| json!({ "hash": t.hash(), "from": t.sender(), "tx": t })).collect();
    Json(json!(list))
}

#[derive(Deserialize)]
struct QueryReq {
    contract: Address,
    method: String,
    #[serde(default)]
    args: Vec<Arg>,
    caller: Option<Address>,
}

async fn query(State(n): State<Arc<Node>>, Json(q): Json<QueryReq>) -> Res {
    let s = n.chain.lock().unwrap().tip_state();
    let out = s
        .query(&q.contract, abi::call(&q.method, &q.args), q.caller.unwrap_or_default(), 5_000_000)
        .map_err(|e| err(StatusCode::BAD_REQUEST, e))?;
    let decoded = abi::decode(&out).map_err(|e| err(StatusCode::BAD_REQUEST, e))?;
    Ok(Json(json!({ "result": decoded })))
}

async fn peers(State(n): State<Arc<Node>>) -> Json<Value> {
    let p = n.peers.lock().unwrap();
    let list: Vec<Value> = p.values().map(|p| json!({ "addr": p.addr, "listen": p.listen, "height": p.height })).collect();
    Json(json!(list))
}

/// The newest transactions on the chain, however far back they are.
async fn recent_txs(State(n): State<Arc<Node>>, Query(q): Query<HashMap<String, String>>) -> Json<Value> {
    let limit: usize = q.get("limit").and_then(|v| v.parse().ok()).unwrap_or(10).min(100);
    let c = n.chain.lock().unwrap();
    let mut out = Vec::new();
    for h in (1..=c.height()).rev() {
        let Some(s) = c.block_at(h) else { continue };
        for (t, r) in s.block.txs.iter().zip(&s.receipts).rev() {
            out.push(json!({ "height": h, "time": s.block.header.time, "hash": t.hash(), "from": t.sender(), "tx": t, "receipt": r }));
        }
        if out.len() >= limit || c.height() - h > 10_000 {
            break;
        }
    }
    out.truncate(limit);
    Json(json!(out))
}
