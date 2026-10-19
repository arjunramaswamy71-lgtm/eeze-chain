//! `eeze`: run an EEZE Chain node, or use it as a command-line wallet.

mod node;
mod rpc;
mod secure;
mod store;
mod wallet;

use clap::{Parser, Subcommand};
use eeze_core::*;
use std::path::PathBuf;
use std::sync::Arc;

#[derive(Parser)]
#[command(
    name = "eeze",
    about = "EEZE Chain node and wallet. The coin is CoTdy (CTDY)."
)]
struct Cli {
    /// Node API to talk to (for wallet commands).
    #[arg(
        long,
        global = true,
        env = "EEZE_RPC",
        default_value = "http://127.0.0.1:8001"
    )]
    rpc: String,
    #[command(subcommand)]
    cmd: Cmd,
}

#[derive(Subcommand)]
enum Cmd {
    /// Run a node.
    Node {
        #[arg(long, default_value = "node")]
        name: String,
        /// Port other nodes connect to.
        #[arg(long, default_value_t = 7001)]
        port: u16,
        /// Port for the web API.
        #[arg(long, default_value_t = 8001)]
        api: u16,
        /// Other nodes to connect to, like 127.0.0.1:7002. Can be repeated.
        #[arg(long)]
        peer: Vec<String>,
        /// This node's wallet: a key file, or seed:<word> on the dev network.
        #[arg(long)]
        key: Option<String>,
        /// Mine blocks (proof of work, until staking starts).
        #[arg(long)]
        mine: bool,
        #[arg(long, default_value_t = 1)]
        threads: u64,
        /// Make blocks when chosen as a validator (proof of stake).
        #[arg(long)]
        validate: bool,
        /// Folder to save the chain in.
        #[arg(long)]
        data: Option<PathBuf>,
        /// `devnet`, or a genesis JSON file. Every node must use the same one.
        #[arg(long, default_value = "devnet")]
        genesis: String,
        /// Folder with the built web explorer and wallet (docs/). Found automatically if left out.
        #[arg(long)]
        web: Option<PathBuf>,
        /// Demo only: cheat by signing two blocks per turn, to show slashing.
        #[arg(long, hide = true)]
        evil_double_sign: bool,
    },
    /// Print the dev network's genesis settings as JSON, to copy and edit.
    Genesis,
    #[command(flatten)]
    Wallet(wallet::Cmd),
}

fn load_genesis(s: &str) -> Genesis {
    if s == "devnet" {
        return Genesis::devnet();
    }
    let text = std::fs::read_to_string(s).expect("can't read genesis file");
    serde_json::from_str(&text).expect("bad genesis file")
}

fn main() {
    let cli = Cli::parse();
    match cli.cmd {
        Cmd::Genesis => println!(
            "{}",
            serde_json::to_string_pretty(&Genesis::devnet()).unwrap()
        ),
        Cmd::Wallet(w) => {
            if let Err(e) = wallet::run(w, &cli.rpc) {
                eprintln!("error: {e}");
                std::process::exit(1);
            }
        }
        Cmd::Node {
            name,
            port,
            api,
            peer,
            key,
            mine,
            threads,
            validate,
            data,
            genesis,
            web,
            evil_double_sign,
        } => {
            let key = key.map(|k| wallet::load_key(&k).expect("bad key"));
            if (mine || validate) && key.is_none() {
                eprintln!("--mine and --validate need --key, so rewards have somewhere to go");
                std::process::exit(1);
            }
            if let Some(d) = &data {
                std::fs::create_dir_all(d).expect("can't make data folder");
            }
            let rt = tokio::runtime::Runtime::new().unwrap();
            rt.block_on(async move {
                let mut n = node::Node::new(name, load_genesis(&genesis), port, key, data);
                Arc::get_mut(&mut n).unwrap().evil_double_sign = evil_double_sign;
                {
                    let c = n.chain.lock().unwrap();
                    log!(
                        n,
                        "EEZE Chain {} | height {} | p2p :{port} | api :{api}",
                        c.genesis.chain_id,
                        c.height()
                    );
                    if let Some(k) = &n.key {
                        log!(n, "wallet {}", k.address());
                    }
                }
                tokio::spawn(n.clone().listen());
                tokio::spawn(n.clone().dial_loop(peer));
                if mine {
                    for t in 0..threads {
                        let (me, h) = (n.clone(), tokio::runtime::Handle::current());
                        std::thread::spawn(move || me.mine_forever(t, h));
                    }
                }
                if validate {
                    tokio::spawn(n.clone().validate_forever());
                }
                let l = tokio::net::TcpListener::bind(("0.0.0.0", api))
                    .await
                    .expect("api port is taken");
                let web = web.or_else(|| {
                    ["docs", "../docs", "../../docs"]
                        .iter()
                        .map(PathBuf::from)
                        .find(|p| p.join("index.html").exists())
                });
                if let Some(w) = &web {
                    log!(
                        n,
                        "explorer and wallet at http://127.0.0.1:{api}  ({})",
                        w.display()
                    );
                }
                axum::serve(l, rpc::router(n, web)).await.unwrap();
            });
        }
    }
}
