//! How arguments are packed when you call a smart contract.
//! Every value starts with a one-byte tag, so a contract can check it got what it expected.
//!   1 = number (8 bytes)   2 = raw bytes   3 = address (20 bytes)   4 = text
//! A call is: text(method name), then the arguments.

use crate::types::Address;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
#[serde(tag = "t", content = "v", rename_all = "lowercase")]
pub enum Arg {
    U64(u64),
    Bytes(#[serde(with = "hexbytes")] Vec<u8>),
    Addr(Address),
    Str(String),
}

mod hexbytes {
    use serde::{Deserialize, Deserializer, Serializer};
    pub fn serialize<S: Serializer>(v: &[u8], s: S) -> Result<S::Ok, S::Error> {
        s.serialize_str(&format!("0x{}", hex::encode(v)))
    }
    pub fn deserialize<'de, D: Deserializer<'de>>(d: D) -> Result<Vec<u8>, D::Error> {
        let s = String::deserialize(d)?;
        hex::decode(s.trim_start_matches("0x")).map_err(serde::de::Error::custom)
    }
}

pub fn encode(args: &[Arg]) -> Vec<u8> {
    let mut out = Vec::new();
    for a in args {
        match a {
            Arg::U64(v) => {
                out.push(1);
                out.extend_from_slice(&v.to_le_bytes());
            }
            Arg::Bytes(b) => {
                out.push(2);
                out.extend_from_slice(&(b.len() as u32).to_le_bytes());
                out.extend_from_slice(b);
            }
            Arg::Addr(a) => {
                out.push(3);
                out.extend_from_slice(&a.0);
            }
            Arg::Str(s) => {
                out.push(4);
                out.extend_from_slice(&(s.len() as u32).to_le_bytes());
                out.extend_from_slice(s.as_bytes());
            }
        }
    }
    out
}

/// A method call: the method name first, then its arguments.
pub fn call(method: &str, args: &[Arg]) -> Vec<u8> {
    let mut v = vec![Arg::Str(method.to_string())];
    v.extend_from_slice(args);
    encode(&v)
}

pub fn decode(mut b: &[u8]) -> Result<Vec<Arg>, String> {
    let mut out = Vec::new();
    let take = |b: &mut &[u8], n: usize| -> Result<Vec<u8>, String> {
        if b.len() < n {
            return Err("ran out of bytes".into());
        }
        let (h, t) = b.split_at(n);
        *b = t;
        Ok(h.to_vec())
    };
    while !b.is_empty() {
        let tag = take(&mut b, 1)?[0];
        match tag {
            1 => out.push(Arg::U64(u64::from_le_bytes(
                take(&mut b, 8)?.try_into().unwrap(),
            ))),
            2 | 4 => {
                let n = u32::from_le_bytes(take(&mut b, 4)?.try_into().unwrap()) as usize;
                let v = take(&mut b, n)?;
                out.push(if tag == 2 {
                    Arg::Bytes(v)
                } else {
                    Arg::Str(String::from_utf8(v).map_err(|e| e.to_string())?)
                });
            }
            3 => out.push(Arg::Addr(Address(take(&mut b, 20)?.try_into().unwrap()))),
            t => return Err(format!("unknown tag {t}")),
        }
    }
    Ok(out)
}

/// Reads arguments typed on the command line, like  u64:5  addr:0xab..  str:hello  bytes:0x01
pub fn parse_cli(items: &[String]) -> Result<Vec<Arg>, String> {
    items
        .iter()
        .map(|s| {
            let (t, v) = s
                .split_once(':')
                .ok_or(format!("'{s}' should look like type:value"))?;
            Ok(match t {
                "u64" | "n" => Arg::U64(
                    v.replace('_', "")
                        .parse()
                        .map_err(|_| format!("bad number {v}"))?,
                ),
                "addr" | "a" => Arg::Addr(v.parse()?),
                "str" | "s" => Arg::Str(v.to_string()),
                "bytes" | "b" => {
                    Arg::Bytes(hex::decode(v.trim_start_matches("0x")).map_err(|e| e.to_string())?)
                }
                _ => return Err(format!("unknown type {t}")),
            })
        })
        .collect()
}
