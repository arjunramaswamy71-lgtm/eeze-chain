//! Encrypted connections between nodes, using the Noise protocol (the same framework behind
//! WhatsApp's transport encryption and the Lightning Network).
//!
//! Each node has its own long-term network key, separate from any wallet. When two nodes connect
//! they run the XX handshake: both sides prove who they are and agree on fresh keys for this
//! connection only. After that, every message is encrypted and authenticated (ChaCha20-Poly1305),
//! so nobody in between can read it or change it without being noticed.

use std::path::Path;
use std::sync::Arc;
use std::time::Duration;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::TcpStream;
use tokio::net::tcp::{OwnedReadHalf, OwnedWriteHalf};

pub const PARAMS: &str = "Noise_XX_25519_ChaChaPoly_BLAKE2s";
const CHUNK: usize = 60_000;
const MAX_MESSAGE: usize = 32 << 20;

pub struct NetKey {
    pub private: Vec<u8>,
    pub public: Vec<u8>,
}

impl NetKey {
    /// Loads this node's network key, or makes one the first time and saves it.
    pub fn load_or_create(dir: Option<&Path>) -> NetKey {
        let builder = snow::Builder::new(PARAMS.parse().unwrap());
        if let Some(d) = dir {
            let path = d.join("network.key");
            if let Ok(text) = std::fs::read_to_string(&path)
                && let Some((a, b)) = text.trim().split_once(':')
                && let (Ok(private), Ok(public)) = (hex::decode(a), hex::decode(b))
            {
                return NetKey { private, public };
            }
            let k = builder.generate_keypair().expect("can make a key");
            let _ = std::fs::write(
                &path,
                format!("{}:{}", hex::encode(&k.private), hex::encode(&k.public)),
            );
            return NetKey {
                private: k.private,
                public: k.public,
            };
        }
        let k = builder.generate_keypair().expect("can make a key");
        NetKey {
            private: k.private,
            public: k.public,
        }
    }

    /// A short name for this key, shown in logs.
    pub fn fingerprint(public: &[u8]) -> String {
        hex::encode(&public[..4.min(public.len())])
    }
}

async fn write_frame(w: &mut (impl AsyncWriteExt + Unpin), data: &[u8]) -> std::io::Result<()> {
    w.write_all(&(data.len() as u16).to_be_bytes()).await?;
    w.write_all(data).await
}

async fn read_frame(r: &mut (impl AsyncReadExt + Unpin)) -> std::io::Result<Vec<u8>> {
    let mut len = [0u8; 2];
    r.read_exact(&mut len).await?;
    let mut buf = vec![0u8; u16::from_be_bytes(len) as usize];
    r.read_exact(&mut buf).await?;
    Ok(buf)
}

fn bad(e: impl std::fmt::Display) -> std::io::Error {
    std::io::Error::new(std::io::ErrorKind::InvalidData, e.to_string())
}

/// Runs the handshake. Returns the two encrypted halves of the connection and the other
/// node's public network key.
pub async fn handshake(
    mut stream: TcpStream,
    key: &NetKey,
    initiator: bool,
) -> std::io::Result<(Sender, Receiver, Vec<u8>)> {
    let b = snow::Builder::new(PARAMS.parse().unwrap())
        .local_private_key(&key.private)
        .map_err(bad)?;
    let mut hs = if initiator {
        b.build_initiator()
    } else {
        b.build_responder()
    }
    .map_err(bad)?;
    let mut buf = vec![0u8; 65_535];
    let mut payload = vec![0u8; 65_535];
    let steps = async {
        // XX:  -> e   <- e, ee, s, es   -> s, se
        if initiator {
            let n = hs.write_message(&[], &mut buf).map_err(bad)?;
            write_frame(&mut stream, &buf[..n]).await?;
            let m = read_frame(&mut stream).await?;
            hs.read_message(&m, &mut payload).map_err(bad)?;
            let n = hs.write_message(&[], &mut buf).map_err(bad)?;
            write_frame(&mut stream, &buf[..n]).await?;
        } else {
            let m = read_frame(&mut stream).await?;
            hs.read_message(&m, &mut payload).map_err(bad)?;
            let n = hs.write_message(&[], &mut buf).map_err(bad)?;
            write_frame(&mut stream, &buf[..n]).await?;
            let m = read_frame(&mut stream).await?;
            hs.read_message(&m, &mut payload).map_err(bad)?;
        }
        Ok::<(), std::io::Error>(())
    };
    tokio::time::timeout(Duration::from_secs(5), steps)
        .await
        .map_err(|_| bad("handshake timed out"))??;
    let remote = hs
        .get_remote_static()
        .map(|r| r.to_vec())
        .ok_or_else(|| bad("no remote key"))?;
    let t = Arc::new(hs.into_stateless_transport_mode().map_err(bad)?);
    let (rd, wr) = stream.into_split();
    Ok((
        Sender {
            t: t.clone(),
            nonce: 0,
            wr,
        },
        Receiver { t, nonce: 0, rd },
        remote,
    ))
}

pub struct Sender {
    t: Arc<snow::StatelessTransportState>,
    nonce: u64,
    wr: OwnedWriteHalf,
}

impl Sender {
    /// Sends one message: its length first, then the message in encrypted chunks.
    pub async fn send(&mut self, data: &[u8]) -> std::io::Result<()> {
        let mut out = vec![0u8; CHUNK + 16];
        let n = self
            .t
            .write_message(self.nonce, &(data.len() as u32).to_be_bytes(), &mut out)
            .map_err(bad)?;
        self.nonce += 1;
        write_frame(&mut self.wr, &out[..n]).await?;
        for chunk in data.chunks(CHUNK) {
            let n = self
                .t
                .write_message(self.nonce, chunk, &mut out)
                .map_err(bad)?;
            self.nonce += 1;
            write_frame(&mut self.wr, &out[..n]).await?;
        }
        Ok(())
    }
}

pub struct Receiver {
    t: Arc<snow::StatelessTransportState>,
    nonce: u64,
    rd: OwnedReadHalf,
}

impl Receiver {
    pub async fn recv(&mut self) -> std::io::Result<Vec<u8>> {
        let mut plain = vec![0u8; 65_535];
        let head = read_frame(&mut self.rd).await?;
        let n = self
            .t
            .read_message(self.nonce, &head, &mut plain)
            .map_err(|_| bad("message failed its integrity check"))?;
        self.nonce += 1;
        if n != 4 {
            return Err(bad("bad message header"));
        }
        let total = u32::from_be_bytes(plain[..4].try_into().unwrap()) as usize;
        if total > MAX_MESSAGE {
            return Err(bad("message too big"));
        }
        let mut data = Vec::with_capacity(total);
        while data.len() < total {
            let frame = read_frame(&mut self.rd).await?;
            let n = self
                .t
                .read_message(self.nonce, &frame, &mut plain)
                .map_err(|_| bad("message failed its integrity check"))?;
            self.nonce += 1;
            data.extend_from_slice(&plain[..n]);
        }
        Ok(data)
    }
}
