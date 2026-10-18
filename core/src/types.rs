//! The basic pieces of EEZE Chain: hashes, addresses, keys, transactions and blocks.

use ed25519_dalek::{Signer, SigningKey, Verifier, VerifyingKey};
use serde::{Deserialize, Deserializer, Serialize, Serializer};
use std::fmt;

/// 1 CTDY is 100,000,000 of the smallest unit (like satoshis in Bitcoin).
pub const COIN: u64 = 100_000_000;

/// Fixed-size byte arrays that show up as hex strings in JSON.
macro_rules! hex_type {
    ($name:ident, $n:expr) => {
        #[derive(Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
        pub struct $name(pub [u8; $n]);

        impl Default for $name {
            fn default() -> Self {
                $name([0u8; $n])
            }
        }
        impl fmt::Display for $name {
            fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
                write!(f, "0x{}", hex::encode(self.0))
            }
        }
        impl fmt::Debug for $name {
            fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
                fmt::Display::fmt(self, f)
            }
        }
        impl std::str::FromStr for $name {
            type Err = String;
            fn from_str(s: &str) -> Result<Self, String> {
                let raw = hex::decode(s.trim_start_matches("0x")).map_err(|e| e.to_string())?;
                let arr: [u8; $n] = raw
                    .try_into()
                    .map_err(|_| format!("expected {} bytes", $n))?;
                Ok($name(arr))
            }
        }
        impl Serialize for $name {
            fn serialize<S: Serializer>(&self, s: S) -> Result<S::Ok, S::Error> {
                s.serialize_str(&self.to_string())
            }
        }
        impl<'de> Deserialize<'de> for $name {
            fn deserialize<D: Deserializer<'de>>(d: D) -> Result<Self, D::Error> {
                let s = String::deserialize(d)?;
                s.parse().map_err(serde::de::Error::custom)
            }
        }
    };
}

hex_type!(Hash, 32);
hex_type!(Address, 20);
hex_type!(PubKey, 32);
hex_type!(Sig, 64);

/// A byte string that shows up as hex in JSON.
#[derive(Clone, PartialEq, Eq, Default, PartialOrd, Ord)]
pub struct Bytes(pub Vec<u8>);

impl fmt::Debug for Bytes {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "0x{}", hex::encode(&self.0))
    }
}
impl Serialize for Bytes {
    fn serialize<S: Serializer>(&self, s: S) -> Result<S::Ok, S::Error> {
        s.serialize_str(&format!("0x{}", hex::encode(&self.0)))
    }
}
impl<'de> Deserialize<'de> for Bytes {
    fn deserialize<D: Deserializer<'de>>(d: D) -> Result<Self, D::Error> {
        let s = String::deserialize(d)?;
        hex::decode(s.trim_start_matches("0x"))
            .map(Bytes)
            .map_err(serde::de::Error::custom)
    }
}

/// blake3 with a label in front, so a hash of one kind of thing can never be mistaken for another.
pub fn hash_with(label: &str, data: &[u8]) -> Hash {
    let mut h = blake3::Hasher::new();
    h.update(label.as_bytes());
    h.update(data);
    Hash(*h.finalize().as_bytes())
}

impl PubKey {
    pub fn address(&self) -> Address {
        let h = hash_with("EEZE-ADDR", &self.0);
        let mut a = [0u8; 20];
        a.copy_from_slice(&h.0[..20]);
        Address(a)
    }

    pub fn verify(&self, msg: &[u8], sig: &Sig) -> bool {
        match VerifyingKey::from_bytes(&self.0) {
            Ok(vk) => vk
                .verify(msg, &ed25519_dalek::Signature::from_bytes(&sig.0))
                .is_ok(),
            Err(_) => false,
        }
    }
}

/// A wallet key. Only the owner ever holds this.
pub struct Keypair(pub SigningKey);

impl Keypair {
    pub fn generate() -> Self {
        Keypair(SigningKey::generate(&mut rand_core::OsRng))
    }
    pub fn from_secret_hex(s: &str) -> Result<Self, String> {
        let raw = hex::decode(s.trim().trim_start_matches("0x")).map_err(|e| e.to_string())?;
        let arr: [u8; 32] = raw.try_into().map_err(|_| "secret key must be 32 bytes")?;
        Ok(Keypair(SigningKey::from_bytes(&arr)))
    }
    /// Same key every time for the same word. Only for tests and the local demo network.
    pub fn from_seed(word: &str) -> Self {
        Keypair(SigningKey::from_bytes(&hash_with("EEZE-DEV-SEED", word.as_bytes()).0))
    }
    pub fn secret_hex(&self) -> String {
        hex::encode(self.0.to_bytes())
    }
    pub fn public(&self) -> PubKey {
        PubKey(self.0.verifying_key().to_bytes())
    }
    pub fn address(&self) -> Address {
        self.public().address()
    }
    pub fn sign(&self, msg: &[u8]) -> Sig {
        Sig(self.0.sign(msg).to_bytes())
    }
}

/// Writes things in one fixed byte layout, used for hashing and signing.
/// The web wallet copies this layout exactly, so the two must never drift apart.
#[derive(Default)]
pub struct Enc(pub Vec<u8>);

impl Enc {
    pub fn u8(&mut self, v: u8) -> &mut Self {
        self.0.push(v);
        self
    }
    pub fn u32(&mut self, v: u32) -> &mut Self {
        self.0.extend_from_slice(&v.to_le_bytes());
        self
    }
    pub fn u64(&mut self, v: u64) -> &mut Self {
        self.0.extend_from_slice(&v.to_le_bytes());
        self
    }
    pub fn raw(&mut self, v: &[u8]) -> &mut Self {
        self.0.extend_from_slice(v);
        self
    }
    pub fn bytes(&mut self, v: &[u8]) -> &mut Self {
        self.u32(v.len() as u32);
        self.raw(v)
    }
}

/// What a transaction does.
#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum TxKind {
    /// Send CTDY to someone.
    Transfer { to: Address, amount: u64 },
    /// Lock CTDY to become a validator once staking starts.
    Stake { amount: u64 },
    /// Start unlocking staked CTDY. It comes back after the unbonding wait.
    Unstake { amount: u64 },
    /// Put a WASM smart contract on the chain.
    Deploy { code: Bytes, args: Bytes },
    /// Run a smart contract, optionally sending it CTDY.
    Call { contract: Address, amount: u64, args: Bytes },
    /// Proof that a validator signed two different blocks for the same slot. Gets them slashed.
    Evidence { a: SignedHeader, b: SignedHeader },
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct Tx {
    pub from: PubKey,
    pub nonce: u64,
    pub gas_limit: u64,
    pub gas_price: u64,
    #[serde(flatten)]
    pub kind: TxKind,
    pub sig: Sig,
}

impl Tx {
    /// The exact bytes the sender signs.
    pub fn signing_bytes(
        chain_id: &str,
        from: &PubKey,
        nonce: u64,
        gas_limit: u64,
        gas_price: u64,
        kind: &TxKind,
    ) -> Vec<u8> {
        let mut e = Enc::default();
        e.raw(b"EEZE-TX")
            .bytes(chain_id.as_bytes())
            .raw(&from.0)
            .u64(nonce)
            .u64(gas_limit)
            .u64(gas_price);
        match kind {
            TxKind::Transfer { to, amount } => {
                e.u8(0).raw(&to.0).u64(*amount);
            }
            TxKind::Stake { amount } => {
                e.u8(1).u64(*amount);
            }
            TxKind::Unstake { amount } => {
                e.u8(2).u64(*amount);
            }
            TxKind::Deploy { code, args } => {
                e.u8(3).bytes(&code.0).bytes(&args.0);
            }
            TxKind::Call { contract, amount, args } => {
                e.u8(4).raw(&contract.0).u64(*amount).bytes(&args.0);
            }
            TxKind::Evidence { a, b } => {
                e.u8(5)
                    .bytes(&a.header.encode())
                    .raw(&a.sig.0)
                    .bytes(&b.header.encode())
                    .raw(&b.sig.0);
            }
        }
        e.0
    }

    pub fn new_signed(
        chain_id: &str,
        key: &Keypair,
        nonce: u64,
        gas_limit: u64,
        gas_price: u64,
        kind: TxKind,
    ) -> Tx {
        let from = key.public();
        let sig = key.sign(&Tx::signing_bytes(chain_id, &from, nonce, gas_limit, gas_price, &kind));
        Tx { from, nonce, gas_limit, gas_price, kind, sig }
    }

    pub fn verify(&self, chain_id: &str) -> bool {
        let msg = Tx::signing_bytes(
            chain_id,
            &self.from,
            self.nonce,
            self.gas_limit,
            self.gas_price,
            &self.kind,
        );
        self.from.verify(&msg, &self.sig)
    }

    pub fn hash(&self) -> Hash {
        // The chain id is already inside the signature, so the hash doesn't need it again.
        let mut b = Tx::signing_bytes("", &self.from, self.nonce, self.gas_limit, self.gas_price, &self.kind);
        b.extend_from_slice(&self.sig.0);
        hash_with("EEZE-TXID", &b)
    }

    pub fn sender(&self) -> Address {
        self.from.address()
    }
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct Header {
    pub height: u64,
    pub prev: Hash,
    /// Milliseconds since 1970.
    pub time: u64,
    pub tx_root: Hash,
    pub state_root: Hash,
    /// Who made the block (the miner or the validator). Gets the reward.
    pub producer: PubKey,
    /// Proof of work: how many leading zero bits the hash needs. 0 for staking blocks.
    pub bits: u32,
    pub nonce: u64,
    /// Proof of stake: which try this is. Goes up when the chosen validator misses its turn.
    pub round: u32,
}

impl Header {
    pub fn encode(&self) -> Vec<u8> {
        let mut e = Enc::default();
        e.raw(b"EEZE-HDR")
            .u64(self.height)
            .raw(&self.prev.0)
            .u64(self.time)
            .raw(&self.tx_root.0)
            .raw(&self.state_root.0)
            .raw(&self.producer.0)
            .u32(self.bits)
            .u64(self.nonce)
            .u32(self.round);
        e.0
    }

    pub fn hash(&self) -> Hash {
        Hash(*blake3::hash(&self.encode()).as_bytes())
    }
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct SignedHeader {
    pub header: Header,
    pub sig: Sig,
}

impl SignedHeader {
    pub fn verify(&self) -> bool {
        self.header.producer.verify(&self.header.hash().0, &self.sig)
    }
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct Block {
    pub header: Header,
    /// Validators sign their blocks. Mined blocks don't need to.
    pub sig: Option<Sig>,
    pub txs: Vec<Tx>,
}

impl Block {
    pub fn hash(&self) -> Hash {
        self.header.hash()
    }
}

/// How many leading zero bits a hash has. Proof of work needs at least `bits` of them.
pub fn leading_zero_bits(h: &Hash) -> u32 {
    let mut n = 0;
    for b in h.0 {
        if b == 0 {
            n += 8;
        } else {
            n += b.leading_zeros();
            break;
        }
    }
    n
}

/// Merkle root: hash pairs together, level by level, until one hash is left.
/// Lets someone prove one item is in a block without downloading the whole block.
pub fn merkle_root(leaves: &[Hash]) -> Hash {
    if leaves.is_empty() {
        return hash_with("EEZE-EMPTY", &[]);
    }
    let mut level: Vec<Hash> = leaves.to_vec();
    while level.len() > 1 {
        level = level
            .chunks(2)
            .map(|p| {
                let mut b = [0u8; 64];
                b[..32].copy_from_slice(&p[0].0);
                b[32..].copy_from_slice(&p[p.len() - 1].0);
                hash_with("EEZE-NODE", &b)
            })
            .collect();
    }
    level[0]
}

/// A Merkle proof: the sibling hashes from a leaf up to the root.
pub fn merkle_proof(leaves: &[Hash], mut index: usize) -> Vec<(Hash, bool)> {
    let mut proof = Vec::new();
    let mut level: Vec<Hash> = leaves.to_vec();
    while level.len() > 1 {
        let sib = if index % 2 == 0 { (index + 1).min(level.len() - 1) } else { index - 1 };
        proof.push((level[sib], index % 2 == 1));
        level = level
            .chunks(2)
            .map(|p| {
                let mut b = [0u8; 64];
                b[..32].copy_from_slice(&p[0].0);
                b[32..].copy_from_slice(&p[p.len() - 1].0);
                hash_with("EEZE-NODE", &b)
            })
            .collect();
        index /= 2;
    }
    proof
}

pub fn merkle_verify(leaf: Hash, proof: &[(Hash, bool)], root: Hash) -> bool {
    let mut h = leaf;
    for (sib, sib_is_left) in proof {
        let mut b = [0u8; 64];
        if *sib_is_left {
            b[..32].copy_from_slice(&sib.0);
            b[32..].copy_from_slice(&h.0);
        } else {
            b[..32].copy_from_slice(&h.0);
            b[32..].copy_from_slice(&sib.0);
        }
        h = hash_with("EEZE-NODE", &b);
    }
    h == root
}
