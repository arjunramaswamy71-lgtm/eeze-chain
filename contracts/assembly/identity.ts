// Identity registry.
//
// One shared list of who has been checked, used by every security token on the chain, the way
// ERC-3643 (T-REX) separates identity from the tokens. An identity is a person or company; it can
// have several wallets. Trusted claim issuers (a KYC provider, an accreditation checker) add
// claims to identities. Tokens just ask: "does this wallet have the claims I need?"
//
// Claim topics are bits: 1 = KYC passed, 2 = accredited investor, 4 = AML screening.
// Nothing personal is stored here, only an identity number, a country code and which checks passed.

import {
  input, output, caller, height, emit, require, fail, sameAddress, concat, utf8,
  load, save, remove, loadU64, saveU64, loadFlag, saveFlag, u64Bytes, Reader, Writer,
} from "./sdk";

function key(prefix: string, a: Uint8Array): Uint8Array {
  return concat(utf8(prefix), a);
}

function owner(): Uint8Array {
  return load(utf8("owner"))!;
}
function isAgent(a: Uint8Array): bool {
  return loadFlag(key("agt:", a));
}
function onlyOwner(): void {
  require(sameAddress(caller(), owner()), "only the registry owner can do this");
}
function onlyAgent(): void {
  require(isAgent(caller()), "only a registry agent can do this");
}

function identityOf(wallet: Uint8Array): u64 {
  return loadU64(key("id:", wallet));
}
function claimKey(identity: u64, topic: u64): Uint8Array {
  return concat(concat(utf8("clm:"), u64Bytes(identity)), u64Bytes(topic));
}
function hasClaim(identity: u64, topic: u64): bool {
  // Stored as expiry height + 1, so 0 means "no claim" and 1 means "never expires".
  const v = loadU64(claimKey(identity, topic));
  if (v == 0) return false;
  return v == 1 || height() < v - 1;
}

export function verified(wallet: Uint8Array, topics: u64): bool {
  const id = identityOf(wallet);
  if (id == 0) return false;
  for (let bit: u64 = 1; bit != 0 && bit <= topics; bit <<= 1) {
    if ((topics & bit) != 0 && !hasClaim(id, bit)) return false;
  }
  return true;
}

export function init(): void {
  const me = caller();
  save(utf8("owner"), me);
  saveFlag(key("agt:", me), true);
  emit("RegistryCreated", me);
}

export function call(): void {
  const r = new Reader(input());
  const m = r.str("method");
  const w = new Writer();

  if (m == "add_agent" || m == "remove_agent") {
    onlyOwner();
    const a = r.addr("agent");
    saveFlag(key("agt:", a), m == "add_agent");
  } else if (m == "add_issuer") {
    // A trusted checker, and which claim topics it may vouch for.
    onlyOwner();
    const a = r.addr("issuer");
    saveU64(key("iss:", a), r.u64("topics"));
    emit("IssuerAdded", a);
  } else if (m == "remove_issuer") {
    onlyOwner();
    remove(key("iss:", r.addr("issuer")));
  } else if (m == "register") {
    // Link a wallet to an identity and record the identity's country (ISO 3166 numeric code).
    onlyAgent();
    const wallet = r.addr("wallet");
    const id = r.u64("identity");
    const country = r.u64("country");
    require(id > 0, "identity numbers start at 1");
    saveU64(key("id:", wallet), id);
    saveU64(concat(utf8("cty:"), u64Bytes(id)), country);
    emit("Registered", concat(wallet, u64Bytes(id)));
  } else if (m == "unregister") {
    onlyAgent();
    const wallet = r.addr("wallet");
    remove(key("id:", wallet));
    emit("Unregistered", wallet);
  } else if (m == "add_claim") {
    const id = r.u64("identity");
    const topic = r.u64("topic");
    const expires = r.u64("expires at height (0 = never)");
    const allowed = loadU64(key("iss:", caller()));
    require(topic != 0 && (topic & (topic - 1)) == 0, "a claim is for exactly one topic");
    require((allowed & topic) != 0, "you're not a trusted issuer for this claim");
    saveU64(claimKey(id, topic), expires + 1);
    emit("ClaimAdded", concat(u64Bytes(id), u64Bytes(topic)));
  } else if (m == "revoke_claim") {
    const id = r.u64("identity");
    const topic = r.u64("topic");
    const allowed = loadU64(key("iss:", caller()));
    require((allowed & topic) != 0 || isAgent(caller()), "you can't revoke this claim");
    remove(claimKey(id, topic));
    emit("ClaimRevoked", concat(u64Bytes(id), u64Bytes(topic)));
  }
  // ---- read-only, used by tokens ----
  else if (m == "is_verified") {
    const wallet = r.addr("wallet");
    w.bool(verified(wallet, r.u64("topics")));
  } else if (m == "identity_of") {
    w.u64(identityOf(r.addr("wallet")));
  } else if (m == "country_of") {
    const id = identityOf(r.addr("wallet"));
    w.u64(id == 0 ? 0 : loadU64(concat(utf8("cty:"), u64Bytes(id))));
  } else if (m == "info") {
    w.str("Identity registry").addr(owner());
  } else {
    fail("unknown method: " + m);
  }
  output(w.done());
}
