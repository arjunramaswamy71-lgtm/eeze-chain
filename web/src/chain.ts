// Everything the wallet needs to speak EEZE Chain: keys, addresses, and the exact byte layout
// the Rust node signs and hashes. If this drifts from core/src/types.rs, signatures stop working.

import * as ed from "@noble/ed25519";
import { sha512 } from "@noble/hashes/sha512";
import { blake3 } from "@noble/hashes/blake3";

ed.etc.sha512Sync = (...m) => sha512(ed.etc.concatBytes(...m));

export const COIN = 100_000_000n;
const te = new TextEncoder();

export const hex = (b: Uint8Array) => "0x" + Array.from(b, (x) => x.toString(16).padStart(2, "0")).join("");
export function unhex(s: string): Uint8Array {
  const h = s.trim().replace(/^0x/, "");
  if (h.length % 2 || /[^0-9a-f]/i.test(h)) throw new Error("not valid hex");
  return Uint8Array.from(h.match(/../g) ?? [], (x) => parseInt(x, 16));
}

export function hashWith(label: string, data: Uint8Array): Uint8Array {
  return blake3(ed.etc.concatBytes(te.encode(label), data));
}

export class Enc {
  private parts: Uint8Array[] = [];
  raw(b: Uint8Array) { this.parts.push(b); return this; }
  u8(v: number) { return this.raw(Uint8Array.of(v)); }
  u32(v: number) { const b = new Uint8Array(4); new DataView(b.buffer).setUint32(0, v, true); return this.raw(b); }
  u64(v: bigint) { const b = new Uint8Array(8); new DataView(b.buffer).setBigUint64(0, v, true); return this.raw(b); }
  bytes(b: Uint8Array) { return this.u32(b.length).raw(b); }
  done() { return ed.etc.concatBytes(...this.parts); }
}

export class Wallet {
  constructor(public secret: Uint8Array) {
    if (secret.length !== 32) throw new Error("a key is 32 bytes (64 hex characters)");
  }
  static create() { return new Wallet(ed.utils.randomPrivateKey()); }
  /** The dev network's demo wallets. Anyone can recreate these, so never hold real value in them. */
  static fromSeed(word: string) { return new Wallet(hashWith("EEZE-DEV-SEED", te.encode(word))); }
  get publicKey() { return ed.getPublicKey(this.secret); }
  get address() { return addressOf(this.publicKey); }
  sign(msg: Uint8Array) { return ed.sign(msg, this.secret); }
}

export const addressOf = (pub: Uint8Array) => hex(hashWith("EEZE-ADDR", pub).slice(0, 20));

export type Kind =
  | { type: "transfer"; to: string; amount: bigint }
  | { type: "stake"; amount: bigint }
  | { type: "unstake"; amount: bigint }
  | { type: "call"; contract: string; amount: bigint; args: Uint8Array };

export function signingBytes(chainId: string, from: Uint8Array, nonce: bigint, gasLimit: bigint, gasPrice: bigint, k: Kind) {
  const e = new Enc().raw(te.encode("EEZE-TX")).bytes(te.encode(chainId)).raw(from).u64(nonce).u64(gasLimit).u64(gasPrice);
  if (k.type === "transfer") e.u8(0).raw(unhex(k.to)).u64(k.amount);
  if (k.type === "stake") e.u8(1).u64(k.amount);
  if (k.type === "unstake") e.u8(2).u64(k.amount);
  if (k.type === "call") e.u8(4).raw(unhex(k.contract)).u64(k.amount).bytes(k.args);
  return e.done();
}

/** Builds and signs a transaction, returning the JSON the node expects and its hash. */
export function signTx(chainId: string, w: Wallet, nonce: number, gasLimit: number, k: Kind) {
  const from = w.publicKey;
  const sig = w.sign(signingBytes(chainId, from, BigInt(nonce), BigInt(gasLimit), 1n, k));
  const idBytes = ed.etc.concatBytes(signingBytes("", from, BigInt(nonce), BigInt(gasLimit), 1n, k), sig);
  const big = (v: bigint) => {
    if (v > BigInt(Number.MAX_SAFE_INTEGER)) throw new Error("amount too large");
    return Number(v);
  };
  const body: Record<string, unknown> = { from: hex(from), nonce, gas_limit: gasLimit, gas_price: 1, type: k.type };
  if (k.type === "transfer") Object.assign(body, { to: k.to, amount: big(k.amount) });
  if (k.type === "stake" || k.type === "unstake") Object.assign(body, { amount: big(k.amount) });
  if (k.type === "call") Object.assign(body, { contract: k.contract, amount: big(k.amount), args: hex(k.args) });
  body.sig = hex(sig);
  return { body, hash: hex(hashWith("EEZE-TXID", idBytes)) };
}

// ---- contract arguments, same tags as core/src/abi.rs ----

export type Arg = { t: "u64"; v: bigint } | { t: "addr"; v: string } | { t: "str"; v: string } | { t: "bytes"; v: Uint8Array };

export function encodeArgs(args: Arg[]) {
  const e = new Enc();
  for (const a of args) {
    if (a.t === "u64") e.u8(1).u64(a.v);
    if (a.t === "bytes") e.u8(2).bytes(a.v);
    if (a.t === "addr") e.u8(3).raw(unhex(a.v));
    if (a.t === "str") e.u8(4).bytes(te.encode(a.v));
  }
  return e.done();
}
export const callData = (method: string, args: Arg[] = []) => encodeArgs([{ t: "str", v: method }, ...args]);

// ---- CTDY amounts ----

export function parseCtdy(s: string): bigint {
  const m = s.trim().replace(/[,_]/g, "").match(/^(\d*)(?:\.(\d{0,8}))?$/);
  if (!m || (!m[1] && !m[2])) throw new Error("enter an amount like 12.5");
  return BigInt(m[1] || "0") * COIN + BigInt((m[2] || "").padEnd(8, "0"));
}

export function fmtCtdy(units: number | bigint, maxFrac = 4): string {
  const v = BigInt(units);
  const whole = v / COIN;
  const frac = (v % COIN).toString().padStart(8, "0").slice(0, maxFrac).replace(/0+$/, "");
  return whole.toLocaleString("en-US") + (frac ? "." + frac : "");
}
