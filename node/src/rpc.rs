//! The node's web API. The wallet, the explorer and the scripts all use this.
//! The answers come from eeze_core::api, the same code the in-browser demo runs.

use crate::node::{Node, now_ms};
use crate::secure::NetKey;
use axum::body::Bytes as Body;
use axum::extract::State;
use axum::http::{Method, StatusCode, Uri};
use axum::response::{IntoResponse, Response};
use axum::routing::any;
use axum::{Json, Router};
use eeze_core::api::{self, NodeInfo};
use eeze_core::*;
use serde_json::{Value, json};
use std::sync::Arc;
use tower_http::cors::CorsLayer;
use tower_http::services::ServeDir;

const ROUTES: &[&str] = &[
    "/status",
    "/genesis",
    "/blocks",
    "/block/{id}",
    "/tx/{hash}",
    "/tx",
    "/account/{addr}",
    "/validators",
    "/contracts",
    "/events",
    "/mempool",
    "/query",
    "/peers",
    "/history/{addr}",
    "/recent-txs",
    "/headers",
    "/proof/{addr}",
];

pub fn router(node: Arc<Node>, web: Option<std::path::PathBuf>) -> Router {
    let mut r = Router::new();
    for path in ROUTES {
        r = r.route(path, any(handle));
    }
    let r = r
        .layer(CorsLayer::permissive().allow_private_network(true))
        .with_state(node);
    // The explorer and wallet web app, served from the same place as the API.
    match web {
        Some(dir) => r.fallback_service(ServeDir::new(dir)),
        None => r,
    }
}

fn reply(code: u16, v: Value) -> Response {
    (
        StatusCode::from_u16(code).unwrap_or(StatusCode::BAD_REQUEST),
        Json(v),
    )
        .into_response()
}

async fn handle(State(n): State<Arc<Node>>, method: Method, uri: Uri, body: Body) -> Response {
    // Sending a transaction also passes it on to other nodes, so the node handles it itself.
    if method == Method::POST && uri.path() == "/tx" {
        let tx: Tx = match serde_json::from_slice(&body) {
            Ok(t) => t,
            Err(e) => return reply(400, json!({ "error": e.to_string() })),
        };
        let node = n.clone();
        return match tokio::task::spawn_blocking(move || node.on_tx(tx, None))
            .await
            .unwrap()
        {
            Ok(h) => reply(200, json!({ "hash": h })),
            Err(e) => reply(400, json!({ "error": e })),
        };
    }
    let peers: Vec<Value> = n
        .peers
        .lock()
        .unwrap()
        .values()
        .map(|p| json!({ "addr": p.addr, "listen": p.listen, "height": p.height, "key": p.key }))
        .collect();
    let info = NodeInfo {
        name: n.name.clone(),
        now: now_ms(),
        peers,
        network_key: NetKey::fingerprint(&n.net_key.public),
    };
    let node = n.clone();
    let (m, path, query) = (
        method.to_string(),
        uri.path().to_string(),
        uri.query().unwrap_or("").to_string(),
    );
    let res = tokio::task::spawn_blocking(move || {
        let c = node.chain.lock().unwrap();
        api::handle(&c, &info, &m, &path, &query, &body)
    })
    .await
    .unwrap();
    match res {
        Ok(v) => reply(200, v),
        Err((code, e)) => reply(code, json!({ "error": e })),
    }
}
