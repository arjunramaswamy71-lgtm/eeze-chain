//! Command-line wallet. Keys stay on this computer; only signed transactions go to the node.

use anyhow::{anyhow, bail, Result};
use clap::Subcommand;
use eeze_core::abi::{self, Arg};
use eeze_core::*;
use serde_json::{json, Value};
use std::time::Duration;

#[derive(Subcommand)]
pub enum Cmd {
    /// Make a new wallet and save its key to a file.
    Keygen {
        #[arg(long, default_value = "wallet.key")]
        out: String,
    },
    /// Show a wallet's address.
    Address { #[arg(long)] key: String },
    /// Show the demo wallets on the dev network.
    Devnet,
    /// Chain status.
    Status,
    /// Balance and stake of an address (or of --key).
    Balance { address: Option<String>, #[arg(long)] key: Option<String> },
    /// Send CTDY.
    Send {
        #[arg(long)] key: String,
        #[arg(long)] to: String,
        /// In CTDY, like 12.5
        #[arg(long)] amount: String,
        #[arg(long)] no_wait: bool,
    },
    /// Lock CTDY to become a validator.
    Stake { #[arg(long)] key: String, #[arg(long)] amount: String },
    /// Start unlocking staked CTDY.
    Unstake { #[arg(long)] key: String, #[arg(long)] amount: String },
    /// Put a smart contract on the chain. Args look like  str:Name  u64:1000  addr:0x..
    Deploy {
        #[arg(long)] key: String,
        #[arg(long)] wasm: String,
        args: Vec<String>,
    },
    /// Run a contract method (costs gas). Args look like  u64:5  addr:0x..
    Call {
        #[arg(long)] key: String,
        #[arg(long)] contract: String,
        #[arg(long)] method: String,
        /// CTDY to send with the call.
        #[arg(long, default_value = "0")] value: String,
        args: Vec<String>,
    },
    /// Ask a contract something. Free, changes nothing.
    Query {
        #[arg(long)] contract: String,
        #[arg(long)] method: String,
        args: Vec<String>,
    },
    /// Look up a transaction.
    Tx { hash: String },
}

pub fn load_key(spec: &str) -> Result<Keypair, String> {
    if let Some(word) = spec.strip_prefix("seed:") {
        return Ok(Keypair::from_seed(word));
    }
    let text = std::fs::read_to_string(spec).map_err(|e| format!("can't read key file {spec}: {e}"))?;
    Keypair::from_secret_hex(&text)
}

/// "12.5" CTDY -> smallest units.
pub fn parse_ctdy(s: &str) -> Result<u64> {
    let (whole, frac) = s.split_once('.').unwrap_or((s, ""));
    if frac.len() > 8 {
        bail!("CTDY has 8 decimal places at most");
    }
    let w: u64 = if whole.is_empty() { 0 } else { whole.replace('_', "").parse()? };
    let f: u64 = if frac.is_empty() { 0 } else { format!("{frac:0<8}").parse()? };
    w.checked_mul(COIN).and_then(|x| x.checked_add(f)).ok_or(anyhow!("amount too big"))
}

pub fn fmt_ctdy(v: u64) -> String {
    let s = format!("{}.{:08}", v / COIN, v % COIN);
    let s = s.trim_end_matches('0').trim_end_matches('.');
    format!("{s} CTDY")
}

struct Api {
    base: String,
    agent: ureq::Agent,
}

impl Api {
    fn new(base: &str) -> Api {
        let agent = ureq::Agent::config_builder()
            .http_status_as_error(false)
            .timeout_global(Some(Duration::from_secs(10)))
            .build()
            .new_agent();
        Api { base: base.trim_end_matches('/').to_string(), agent }
    }
    fn get(&self, path: &str) -> Result<Value> {
        let mut r = self.agent.get(&format!("{}{path}", self.base)).call().map_err(|e| anyhow!("can't reach the node at {}: {e}", self.base))?;
        let ok = r.status().is_success();
        let v: Value = r.body_mut().read_json()?;
        if !ok {
            bail!("{}", v["error"].as_str().unwrap_or("request failed"));
        }
        Ok(v)
    }
    fn post(&self, path: &str, body: &Value) -> Result<Value> {
        let mut r = self.agent.post(&format!("{}{path}", self.base)).send_json(body).map_err(|e| anyhow!("can't reach the node at {}: {e}", self.base))?;
        let ok = r.status().is_success();
        let v: Value = r.body_mut().read_json()?;
        if !ok {
            bail!("{}", v["error"].as_str().unwrap_or("request failed"));
        }
        Ok(v)
    }

    /// Signs and sends a transaction, then waits for it to land in a block.
    fn send(&self, key: &Keypair, kind: TxKind, gas: u64, wait: bool) -> Result<Value> {
        let chain_id = self.get("/status")?["chain_id"].as_str().unwrap().to_string();
        let acc = self.get(&format!("/account/{}", key.address()))?;
        let nonce = acc["next_nonce"].as_u64().unwrap_or(0);
        let tx = Tx::new_signed(&chain_id, key, nonce, gas, 1, kind);
        let h = self.post("/tx", &json!(tx))?["hash"].as_str().unwrap().to_string();
        println!("sent {h}");
        if !wait {
            return Ok(json!({ "hash": h }));
        }
        for _ in 0..240 {
            std::thread::sleep(Duration::from_millis(500));
            if let Ok(t) = self.get(&format!("/tx/{h}")) {
                if t["status"] == "confirmed" {
                    let r = &t["receipt"];
                    if r["ok"].as_bool().unwrap_or(false) {
                        println!("confirmed in block #{} | fee {}", t["height"], fmt_ctdy(r["fee"].as_u64().unwrap_or(0)));
                    } else {
                        println!("in block #{} but FAILED: {} | fee {}", t["height"], r["error"].as_str().unwrap_or("?"), fmt_ctdy(r["fee"].as_u64().unwrap_or(0)));
                    }
                    return Ok(t);
                }
            }
        }
        bail!("not confirmed after 2 minutes (it may still go in)")
    }
}

fn show_args(v: &Value) -> String {
    let Some(list) = v.as_array() else { return v.to_string() };
    list.iter()
        .map(|a| match a["t"].as_str() {
            Some("u64") => a["v"].to_string(),
            _ => a["v"].as_str().unwrap_or("").to_string(),
        })
        .collect::<Vec<_>>()
        .join("  ")
}

pub fn run(cmd: Cmd, rpc: &str) -> Result<()> {
    let api = Api::new(rpc);
    let key = |k: &str| load_key(k).map_err(|e| anyhow!(e));
    match cmd {
        Cmd::Keygen { out } => {
            if std::path::Path::new(&out).exists() {
                bail!("{out} already exists, not overwriting it");
            }
            let k = Keypair::generate();
            std::fs::write(&out, k.secret_hex())?;
            println!("new wallet saved to {out}\naddress {}\nKeep {out} private: whoever has it controls the wallet.", k.address());
        }
        Cmd::Address { key: k } => println!("{}", key(&k)?.address()),
        Cmd::Devnet => {
            for w in ["arjun", "bank", "alice", "bob"] {
                println!("seed:{w:<6} {}", Keypair::from_seed(w).address());
            }
        }
        Cmd::Status => println!("{}", serde_json::to_string_pretty(&api.get("/status")?)?),
        Cmd::Balance { address, key: k } => {
            let a = match (address, k) {
                (Some(a), _) => a,
                (None, Some(k)) => key(&k)?.address().to_string(),
                _ => bail!("give an address or --key"),
            };
            let v = api.get(&format!("/account/{a}"))?;
            println!("{a}\n  balance {}\n  staked  {}", fmt_ctdy(v["balance"].as_u64().unwrap_or(0)), fmt_ctdy(v["stake"].as_u64().unwrap_or(0)));
            if let Some(u) = v["unbonding"].as_array().filter(|u| !u.is_empty()) {
                for e in u {
                    println!("  unlocking {} at block #{}", fmt_ctdy(e[1].as_u64().unwrap_or(0)), e[0]);
                }
            }
        }
        Cmd::Send { key: k, to, amount, no_wait } => {
            let to: Address = to.parse().map_err(|e: String| anyhow!(e))?;
            api.send(&key(&k)?, TxKind::Transfer { to, amount: parse_ctdy(&amount)? }, 21_000, !no_wait)?;
        }
        Cmd::Stake { key: k, amount } => {
            api.send(&key(&k)?, TxKind::Stake { amount: parse_ctdy(&amount)? }, 21_000, true)?;
        }
        Cmd::Unstake { key: k, amount } => {
            api.send(&key(&k)?, TxKind::Unstake { amount: parse_ctdy(&amount)? }, 21_000, true)?;
        }
        Cmd::Deploy { key: k, wasm, args } => {
            let code = std::fs::read(&wasm)?;
            let args = abi::encode(&abi::parse_cli(&args).map_err(|e| anyhow!(e))?);
            let gas = 21_000 + (code.len() + args.len()) as u64 * 200 + 2_000_000;
            let t = api.send(&key(&k)?, TxKind::Deploy { code: Bytes(code), args: Bytes(args) }, gas, true)?;
            if let Some(a) = t["receipt"]["contract"].as_str() {
                println!("contract address {a}");
            }
        }
        Cmd::Call { key: k, contract, method, value, args } => {
            let contract: Address = contract.parse().map_err(|e: String| anyhow!(e))?;
            let args = abi::parse_cli(&args).map_err(|e| anyhow!(e))?;
            let t = api.send(
                &key(&k)?,
                TxKind::Call { contract, amount: parse_ctdy(&value)?, args: Bytes(abi::call(&method, &args)) },
                3_000_000,
                true,
            )?;
            for e in t["receipt"]["events"].as_array().into_iter().flatten() {
                println!("  event {}", e["topic"].as_str().unwrap_or(""));
            }
        }
        Cmd::Query { contract, method, args } => {
            let args: Vec<Arg> = abi::parse_cli(&args).map_err(|e| anyhow!(e))?;
            let v = api.post("/query", &json!({ "contract": contract, "method": method, "args": args }))?;
            println!("{}", show_args(&v["result"]));
        }
        Cmd::Tx { hash } => println!("{}", serde_json::to_string_pretty(&api.get(&format!("/tx/{hash}"))?)?),
    }
    Ok(())
}
