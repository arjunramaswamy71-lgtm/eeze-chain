// Real-world asset token.
//
// Splits one real thing (a building, a loan, a bond) into shares that live on EEZE Chain.
// It follows the rules a regulated asset would need, in the spirit of the ERC-3643 standard:
//   - only people the issuer has checked (KYC) can hold shares
//   - the issuer can freeze an account, for example on a court order
//   - investors can buy shares with CTDY at the issuer's price
//   - income from the asset (like rent) is paid out to holders in proportion to their shares
//
// Dividends use the "running total per share" trick, so paying 10,000 holders costs the same
// as paying one: each holder's cut is worked out only when they claim or their balance changes.

import {
  input, output, caller, value, pay, emit, require, fail, sameAddress, concat, utf8,
  load, save, loadU64, saveU64, loadFlag, saveFlag, u64Bytes, Reader, Writer, U128,
} from "./sdk";

const SCALE: u64 = 1_000_000_000_000_000_000; // 1e18, keeps rounding error tiny

function key(prefix: string, a: Uint8Array): Uint8Array {
  return concat(utf8(prefix), a);
}
function k(name: string): Uint8Array {
  return utf8(name);
}

function issuer(): Uint8Array {
  return load(k("issuer"))!;
}
function onlyIssuer(): void {
  require(sameAddress(caller(), issuer()), "only the issuer can do this");
}
function balanceOf(a: Uint8Array): u64 {
  return loadU64(key("bal:", a));
}
function isApproved(a: Uint8Array): bool {
  return loadFlag(key("kyc:", a));
}
function isFrozen(a: Uint8Array): bool {
  return loadFlag(key("frz:", a));
}

// ---- dividends ----

function acc(): U128 {
  return U128.from(load(k("acc")));
}

/** Total income per share ever paid, times SCALE, minus what this holder already counted. */
function earned(a: Uint8Array): u64 {
  const diff = acc().sub(U128.from(load(key("last:", a))));
  const bal = balanceOf(a);
  // bal * diff / SCALE, done in 128 bits
  const low = U128.mul(diff.lo, bal);
  const prod = new U128(low.hi + diff.hi * bal, low.lo);
  return loadU64(key("owed:", a)) + prod.div(SCALE);
}

/** Locks in what a holder has earned so far. Must run before their balance changes. */
function settle(a: Uint8Array): void {
  saveU64(key("owed:", a), earned(a));
  save(key("last:", a), acc().bytes());
}

function move(from: Uint8Array, to: Uint8Array, amount: u64): void {
  require(isApproved(to), "receiver hasn't passed KYC");
  require(!isFrozen(from), "sender's account is frozen");
  require(!isFrozen(to), "receiver's account is frozen");
  const fb = balanceOf(from);
  require(fb >= amount, "not enough shares");
  settle(from);
  settle(to);
  saveU64(key("bal:", from), fb - amount);
  saveU64(key("bal:", to), balanceOf(to) + amount);
  emit("Transfer", concat(concat(from, to), u64Bytes(amount)));
}

// ---- setup ----

/** init(name, symbol, total shares, price per share in CTDY units, document) */
export function init(): void {
  const r = new Reader(input());
  const name = r.str("name");
  const symbol = r.str("symbol");
  const total = r.u64("total shares");
  const price = r.u64("price");
  const doc = r.str("document");
  require(total > 0, "need at least one share");
  const me = caller();
  save(k("name"), utf8(name));
  save(k("symbol"), utf8(symbol));
  save(k("doc"), utf8(doc));
  save(k("issuer"), me);
  saveU64(k("total"), total);
  saveU64(k("price"), price);
  saveFlag(key("kyc:", me), true);
  saveU64(key("bal:", me), total);
  emit("Issued", concat(me, u64Bytes(total)));
}

// ---- calls ----

export function call(): void {
  const r = new Reader(input());
  const m = r.str("method");
  const w = new Writer();

  if (m == "transfer") {
    const to = r.addr("to");
    const amount = r.u64("amount");
    require(isApproved(caller()), "you haven't passed KYC");
    move(caller(), to, amount);
  } else if (m == "buy") {
    // Buy shares straight from the issuer, paying CTDY with the call.
    const amount = r.u64("amount");
    const price = loadU64(k("price"));
    require(price > 0, "shares are not for sale right now");
    require(isApproved(caller()), "you haven't passed KYC");
    const cost = U128.mul(price, amount);
    require(cost.hi == 0 && cost.lo == value(), "send exactly price x amount");
    move(issuer(), caller(), amount);
    pay(issuer(), value());
    emit("Buy", concat(caller(), u64Bytes(amount)));
  } else if (m == "distribute") {
    // Pays income to every holder. Send the CTDY with the call.
    const amount = value();
    require(amount > 0, "send some CTDY to distribute");
    const total = loadU64(k("total"));
    const add = U128.mul(amount, SCALE).divWide(total);
    save(k("acc"), acc().add(add).bytes());
    saveU64(k("paid"), loadU64(k("paid")) + amount);
    emit("Dividend", u64Bytes(amount));
  } else if (m == "claim") {
    const me = caller();
    settle(me);
    const owed = loadU64(key("owed:", me));
    require(owed > 0, "nothing to claim");
    saveU64(key("owed:", me), 0);
    pay(me, owed);
    emit("Claim", concat(me, u64Bytes(owed)));
    w.u64(owed);
  } else if (m == "approve" || m == "revoke") {
    onlyIssuer();
    const who = r.addr("who");
    saveFlag(key("kyc:", who), m == "approve");
    emit(m == "approve" ? "Approved" : "Revoked", who);
  } else if (m == "freeze" || m == "unfreeze") {
    onlyIssuer();
    const who = r.addr("who");
    saveFlag(key("frz:", who), m == "freeze");
    emit(m == "freeze" ? "Frozen" : "Unfrozen", who);
  } else if (m == "set_price") {
    onlyIssuer();
    saveU64(k("price"), r.u64("price"));
  } else if (m == "force_transfer") {
    // A regulator-ordered move, e.g. recovering shares from a lost wallet. Issuer only, and public.
    onlyIssuer();
    const from = r.addr("from");
    const to = r.addr("to");
    const amount = r.u64("amount");
    require(isApproved(to), "receiver hasn't passed KYC");
    const fb = balanceOf(from);
    require(fb >= amount, "not enough shares");
    settle(from);
    settle(to);
    saveU64(key("bal:", from), fb - amount);
    saveU64(key("bal:", to), balanceOf(to) + amount);
    emit("ForcedTransfer", concat(concat(from, to), u64Bytes(amount)));
  }
  // ---- read-only ----
  else if (m == "info") {
    w.str(String.UTF8.decode(load(k("name"))!.buffer))
      .str(String.UTF8.decode(load(k("symbol"))!.buffer))
      .u64(loadU64(k("total")))
      .u64(loadU64(k("price")))
      .addr(issuer())
      .str(String.UTF8.decode(load(k("doc"))!.buffer))
      .u64(loadU64(k("paid")));
  } else if (m == "balance_of") {
    w.u64(balanceOf(r.addr("who")));
  } else if (m == "claimable") {
    w.u64(earned(r.addr("who")));
  } else if (m == "status") {
    const who = r.addr("who");
    w.bool(isApproved(who)).bool(isFrozen(who));
  } else {
    fail("unknown method: " + m);
  }
  output(w.done());
}
