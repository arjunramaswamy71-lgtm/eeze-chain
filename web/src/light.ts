// A light client: checks an account's balance without trusting the node it talks to.
//
// It asks the node for proof, then checks every link itself:
//   1. The final block's header hashes to the hash the votes were for.
//   2. The headers link up, each one pointing at the hash of the one before.
//   3. Each vote is signed by a validator whose stake is proven (Merkle proof) in the state.
//   4. The total validator stake is proven too, so a node can't hide validators who didn't sign.
//   5. The votes add up to more than 2/3 of that total.
//   6. The account is proven (Merkle proof) in the final block's state.
//   7. The chain links back to the last final block this browser checked (a checkpoint).

import * as ed from "@noble/ed25519";
import { blake3 } from "@noble/hashes/blake3";
import { Enc, hashWith, hex, unhex, addressOf } from "./chain";

/* eslint-disable @typescript-eslint/no-explicit-any */
type Json = any;

export function encodeHeader(h: Json): Uint8Array {
  return new Enc()
    .raw(new TextEncoder().encode("EEZE-HDR"))
    .u64(BigInt(h.height))
    .raw(unhex(h.prev))
    .u64(BigInt(h.time))
    .raw(unhex(h.tx_root))
    .raw(unhex(h.state_root))
    .raw(unhex(h.producer))
    .u32(h.bits)
    .u64(BigInt(h.nonce))
    .u32(h.round)
    .raw(unhex(h.vrf_preout))
    .raw(unhex(h.vrf_proof))
    .raw(unhex(h.commit_root))
    .done();
}

export const headerHash = (h: Json) => hex(blake3(encodeHeader(h)));

export function accountLeaf(address: string, a: Json): Uint8Array {
  const e = new Enc().raw(unhex(address)).u64(BigInt(a.balance)).u64(BigInt(a.nonce)).u64(BigInt(a.stake)).u32(a.unbonding.length);
  for (const [h, v] of a.unbonding) e.u64(BigInt(h)).u64(BigInt(v));
  if (a.vrf_key) e.u8(1).raw(unhex(a.vrf_key));
  else e.u8(0);
  return hashWith("EEZE-ACCT", e.done());
}

export function merkleVerify(leaf: Uint8Array, proof: [string, boolean][], root: string): boolean {
  let h = leaf;
  for (const [sib, sibIsLeft] of proof) {
    const s = unhex(sib);
    h = hashWith("EEZE-NODE", sibIsLeft ? ed.etc.concatBytes(s, h) : ed.etc.concatBytes(h, s));
  }
  return hex(h) === root;
}

function voteBytes(chainId: string, height: number, block: string) {
  return new Enc().raw(new TextEncoder().encode("EEZE-VOTE")).bytes(new TextEncoder().encode(chainId)).u64(BigInt(height)).raw(unhex(block)).done();
}

export type Check = { ok: boolean; text: string };

export async function verifyAccount(
  api: (p: string) => Promise<Json>,
  address: string,
  minStake: number,
  checkpoint: { height: number; hash: string } | null,
): Promise<{ checks: Check[]; ok: boolean; balance?: number; final?: { height: number; hash: string } }> {
  const checks: Check[] = [];
  const add = (ok: boolean, text: string) => checks.push({ ok, text });
  const p = await api(`/proof/${address}`);
  const headers: Json[] = p.headers;
  const F = headers[0];
  const C = headers[headers.length - 1];
  const P = headers[headers.length - 2];

  add(headerHash(F) === p.final.hash, `Block #${F.height}'s header hashes to the block the votes are for`);
  let linked = true;
  for (let i = 1; i < headers.length; i++) linked &&= headers[i].prev === headerHash(headers[i - 1]);
  add(linked, `Headers #${F.height} to #${C.height} each point at the hash of the one before`);

  // Stake of each signer, proven against the state root of the block before the votes were counted.
  const stakeOf = new Map<string, number>();
  let proofsOk = true;
  for (const v of p.voters) {
    // The leaf includes the address, so a proof only checks out for the address it claims.
    const addr: string = v.address;
    const okProof = merkleVerify(accountLeaf(addr, v.account), v.proof, P.state_root);
    proofsOk &&= okProof;
    if (okProof && v.account.vrf_key && v.account.stake >= minStake) stakeOf.set(addr, v.account.stake);
  }
  add(proofsOk && stakeOf.size > 0, `Each voter's stake is proven in block #${P.height}'s state (Merkle proofs)`);

  const meta = unhex(p.meta.bytes);
  const metaOk = merkleVerify(hashWith("EEZE-META", meta), p.meta.proof, P.state_root);
  const total = Number(new DataView(meta.buffer, meta.byteOffset, 8).getBigUint64(0, true));
  add(metaOk, `The total validator stake (${(total / 1e8).toLocaleString()} CTDY) is proven too, so nobody can be hidden`);

  let signed = 0;
  let sigsOk = true;
  const seen = new Set<string>();
  for (const v of p.commit.votes) {
    const addr = addressOf(unhex(v.voter));
    const ok = v.height === F.height && v.block === p.final.hash && ed.verify(unhex(v.sig), voteBytes(p.chain_id, v.height, v.block), unhex(v.voter));
    sigsOk &&= ok;
    if (ok && stakeOf.has(addr) && !seen.has(addr)) {
      seen.add(addr);
      signed += stakeOf.get(addr)!;
    }
  }
  add(sigsOk, `All ${p.commit.votes.length} vote signatures check out`);
  const share = total ? signed / total : 0;
  add(signed * 3 > total * 2, `Votes cover ${(share * 100).toFixed(1)}% of the stake, more than the 2/3 needed to be final`);

  let balance: number | undefined;
  if (p.account) {
    const ok = merkleVerify(accountLeaf(address, p.account.account), p.account.proof, F.state_root);
    add(ok, `Your account is in block #${F.height}'s state, with ${p.account.proof.length} hashes of proof`);
    if (ok) balance = p.account.account.balance;
  } else {
    add(false, "This account isn't in the final state yet");
  }

  if (checkpoint && checkpoint.height <= F.height) {
    let ok = true;
    let prevHash = checkpoint.hash;
    for (let from = checkpoint.height; from < F.height; from += 2000) {
      const to = Math.min(from + 2000, F.height);
      const hs: Json[] = await api(`/headers?from=${from}&to=${to}`);
      if (hs[0] && headerHash(hs[0]) !== prevHash) ok = false;
      for (let i = 1; i < hs.length; i++) ok &&= hs[i].prev === headerHash(hs[i - 1]);
      prevHash = hs.length ? headerHash(hs[hs.length - 1]) : prevHash;
    }
    add(ok && prevHash === p.final.hash, `The chain links back to your checkpoint, block #${checkpoint.height}`);
  } else if (!checkpoint) {
    add(true, `First check: block #${F.height} is saved as your checkpoint for next time`);
  }

  const ok = checks.every((c) => c.ok);
  return { checks, ok, balance, final: p.final };
}
