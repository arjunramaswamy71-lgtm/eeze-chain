// Security token for a real-world asset, following the ideas of ERC-3643 (T-REX).
//
// One contract handles two kinds of asset:
//   "property"  a building split into shares. Buyers pay the issuer; rent is paid out by share.
//   "fund"      a tokenized US Treasury bill fund. Money paid in stays in the fund as a reserve,
//               holders can redeem at the fund price, and interest is paid out daily by share.
//
// The rules a regulated security needs:
//   - Every holder must pass the checks in the shared identity registry (KYC, and any others
//     the issuer asks for). The token asks the registry with a read-only call on every move.
//   - Optional limits: most holders, most shares per holder, and which countries may hold it.
//   - Agents can pause all trading, freeze an account, freeze part of a balance, move shares by
//     legal order, and recover shares from a lost wallet to a new wallet of the same person.
//
// It also has a small built-in market (a constant-product pool, the Uniswap v2 formula) so KYC'd
// investors can trade shares for CTDY any time, instead of only buying from the issuer.
// Income uses a running total per share, so paying out costs the same for 2 holders or 10,000.

import {
  input, output, caller, value, pay, emit, require, fail, sameAddress, concat, utf8, selfAddress,
  load, save, loadU64, saveU64, loadFlag, saveFlag, u64Bytes, Reader, Writer, U128,
  staticCall, isqrt, mulDiv,
} from "./sdk";

const SCALE: u64 = 1_000_000_000_000_000_000; // 1e18, keeps rounding error tiny
const FEE_PER_1000: u64 = 3; // pool trading fee, 0.3%

function k(name: string): Uint8Array { return utf8(name); }
function key(prefix: string, a: Uint8Array): Uint8Array { return concat(utf8(prefix), a); }
function str(name: string): string { return String.UTF8.decode(load(k(name))!.buffer); }

function owner(): Uint8Array { return load(k("owner"))!; }
function pool(): Uint8Array { return selfAddress(); }
function isOwner(a: Uint8Array): bool { return sameAddress(a, owner()); }
function isAgent(a: Uint8Array): bool { return isOwner(a) || loadFlag(key("agt:", a)); }
function onlyAgent(): void { require(isAgent(caller()), "only the issuer or its agents can do this"); }
function isFund(): bool { return str("kind") == "fund"; }

function balanceOf(a: Uint8Array): u64 { return loadU64(key("bal:", a)); }
function frozenPart(a: Uint8Array): u64 { return loadU64(key("pfz:", a)); }
function isFrozen(a: Uint8Array): bool { return loadFlag(key("frz:", a)); }

// ---- asking the identity registry ----

function registryAsk(method: string, who: Uint8Array): u64 {
  const q = new Writer().str(method).addr(who);
  if (method == "is_verified") q.u64(loadU64(k("topics")));
  const out = staticCall(load(k("registry"))!, q.done());
  require(out != null, "the identity registry didn't answer");
  return new Reader(out!).u64("answer");
}
function verified(a: Uint8Array): bool {
  if (isOwner(a) || sameAddress(a, pool())) return true; // the issuer's own stock and the market pool
  return registryAsk("is_verified", a) != 0;
}
function countryOk(a: Uint8Array): bool {
  if (!loadFlag(k("ctyon")) || isOwner(a) || sameAddress(a, pool())) return true;
  return loadFlag(concat(utf8("cty:"), u64Bytes(registryAsk("country_of", a))));
}

// ---- income per share ----
//
// Income goes to shares investors hold. Shares the issuer still holds haven't been sold, so
// nothing backs them and they earn nothing (otherwise unsold stock would soak up most of the
// interest a fund's investors earned).

function acc(): U128 { return U128.from(load(k("acc"))); }

function outstanding(): u64 { return loadU64(k("total")) - balanceOf(owner()); }

function earned(a: Uint8Array): u64 {
  if (isOwner(a)) return loadU64(key("owed:", a));
  const diff = acc().sub(U128.from(load(key("last:", a))));
  const bal = balanceOf(a);
  const low = U128.mul(diff.lo, bal);
  const prod = new U128(low.hi + diff.hi * bal, low.lo);
  return loadU64(key("owed:", a)) + prod.div(SCALE);
}

function settle(a: Uint8Array): void {
  saveU64(key("owed:", a), earned(a));
  save(key("last:", a), acc().bytes());
}

/** The pool's share of income goes into the pool, so liquidity providers earn it. */
function settlePool(): void {
  settle(pool());
  const owed = loadU64(key("owed:", pool()));
  if (owed > 0) {
    saveU64(key("owed:", pool()), 0);
    saveU64(k("pool_ctdy"), loadU64(k("pool_ctdy")) + owed);
  }
}

// ---- moving shares ----

function setBalance(a: Uint8Array, v: u64): void {
  const before = balanceOf(a);
  saveU64(key("bal:", a), v);
  // Count holders (not the issuer's stock or the pool) for the max-holders rule.
  if (isOwner(a) || sameAddress(a, pool())) return;
  if (before == 0 && v > 0) saveU64(k("holders"), loadU64(k("holders")) + 1);
  if (before > 0 && v == 0) saveU64(k("holders"), loadU64(k("holders")) - 1);
}

function checkReceive(to: Uint8Array, amount: u64): void {
  require(verified(to), "receiver hasn't passed the required checks (KYC)");
  require(countryOk(to), "receiver's country isn't allowed to hold this asset");
  require(!isFrozen(to), "receiver's account is frozen");
  const after = balanceOf(to) + amount;
  const maxBal = loadU64(k("max_balance"));
  if (maxBal > 0 && !isOwner(to) && !sameAddress(to, pool())) require(after <= maxBal, "receiver would hold more than the limit per investor");
  const maxHolders = loadU64(k("max_holders"));
  if (maxHolders > 0 && balanceOf(to) == 0 && !isOwner(to) && !sameAddress(to, pool())) {
    require(loadU64(k("holders")) < maxHolders, "this asset already has the most holders allowed");
  }
}

function checkSend(from: Uint8Array, amount: u64): void {
  require(!isFrozen(from), "sender's account is frozen");
  const bal = balanceOf(from);
  require(bal >= amount, "not enough shares");
  require(bal - amount >= frozenPart(from), "part of these shares is frozen");
}

/** Every normal move goes through here and follows every rule. */
function move(from: Uint8Array, to: Uint8Array, amount: u64): void {
  require(!loadFlag(k("paused")), "trading is paused");
  checkSend(from, amount);
  checkReceive(to, amount);
  forceMove(from, to, amount, "Transfer");
}

/** Moves shares without the checks: only for agents acting by legal order, and the rules
 *  that still matter (receiver must be verified) are checked by the caller. */
function forceMove(from: Uint8Array, to: Uint8Array, amount: u64, topic: string): void {
  require(balanceOf(from) >= amount, "not enough shares");
  settle(from);
  settle(to);
  setBalance(from, balanceOf(from) - amount);
  setBalance(to, balanceOf(to) + amount);
  emit(topic, concat(concat(from, to), u64Bytes(amount)));
}

// ---- setup ----

/** init(name, symbol, kind, registry, required topics, price per share, total shares, document) */
export function init(): void {
  const r = new Reader(input());
  const name = r.str("name");
  const symbol = r.str("symbol");
  const kind = r.str("kind");
  const registry = r.addr("identity registry");
  const topics = r.u64("required claim topics");
  const price = r.u64("price per share");
  const total = r.u64("total shares");
  const doc = r.str("document");
  require(kind == "property" || kind == "fund", "kind must be property or fund");
  require(total > 0, "need at least one share");
  const me = caller();
  save(k("name"), utf8(name));
  save(k("symbol"), utf8(symbol));
  save(k("kind"), utf8(kind));
  save(k("doc"), utf8(doc));
  save(k("owner"), me);
  save(k("registry"), registry);
  saveU64(k("topics"), topics);
  saveU64(k("price"), price);
  saveU64(k("total"), total);
  saveU64(key("bal:", me), total);
  emit("Issued", concat(me, u64Bytes(total)));
}

// ---- calls ----

export function call(): void {
  const r = new Reader(input());
  const m = r.str("method");
  const w = new Writer();
  const me = caller();

  // -------- investors --------
  if (m == "transfer") {
    const to = r.addr("to");
    move(me, to, r.u64("amount"));
  } else if (m == "buy") {
    // Buy new shares from the issuer at the issuer's price.
    const amount = r.u64("amount");
    const price = loadU64(k("price"));
    require(price > 0, "shares are not for sale from the issuer right now");
    const cost = U128.mul(price, amount);
    require(cost.hi == 0 && cost.lo == value(), "send exactly price x amount");
    move(owner(), me, amount);
    if (isFund()) saveU64(k("reserve"), loadU64(k("reserve")) + value());
    else pay(owner(), value());
    emit("Buy", concat(me, u64Bytes(amount)));
  } else if (m == "redeem") {
    // Fund only: hand shares back and get the fund price in CTDY from the reserve.
    require(isFund(), "only fund shares can be redeemed");
    require(!loadFlag(k("paused")), "trading is paused");
    const amount = r.u64("amount");
    checkSend(me, amount);
    const out = mulDiv(amount, loadU64(k("price")), 1);
    const reserve = loadU64(k("reserve"));
    require(reserve >= out, "the fund's reserve is too low to redeem that much right now");
    forceMove(me, owner(), amount, "Redeem");
    saveU64(k("reserve"), reserve - out);
    pay(me, out);
  } else if (m == "claim") {
    settle(me);
    const owed = loadU64(key("owed:", me));
    require(owed > 0, "nothing to claim");
    saveU64(key("owed:", me), 0);
    pay(me, owed);
    emit("Claim", concat(me, u64Bytes(owed)));
    w.u64(owed);
  } else if (m == "distribute") {
    // Pays income to every investor in proportion to shares. Send the CTDY with the call.
    const amount = value();
    require(amount > 0, "send some CTDY to distribute");
    const held = outstanding();
    require(held > 0, "no investor holds shares yet");
    const add = U128.mul(amount, SCALE).divWide(held);
    save(k("acc"), acc().add(add).bytes());
    saveU64(k("paid"), loadU64(k("paid")) + amount);
    emit("Income", u64Bytes(amount));
  }
  // -------- the market pool --------
  else if (m == "add_liquidity") {
    // Put in shares and CTDY together. You get pool units for your part of the pool.
    require(!loadFlag(k("paused")), "trading is paused");
    require(verified(me), "you haven't passed the required checks (KYC)");
    settlePool();
    const shares = r.u64("shares");
    const ctdy = value();
    require(shares > 0 && ctdy > 0, "add both shares and CTDY");
    const rc = loadU64(k("pool_ctdy"));
    const rs = balanceOf(pool());
    const lps = loadU64(k("lps"));
    let minted: u64 = 0;
    if (lps == 0) {
      minted = isqrt(mulDiv(shares, ctdy, 1));
    } else {
      // Must match the pool's current ratio; extra shares are not taken.
      const needShares = mulDiv(ctdy, rs, rc);
      require(shares >= needShares, "add more shares to match the pool's price");
      minted = mulDiv(ctdy, lps, rc);
      checkSend(me, needShares);
      forceMove(me, pool(), needShares, "PoolDeposit");
    }
    if (lps == 0) {
      checkSend(me, shares);
      forceMove(me, pool(), shares, "PoolDeposit");
    }
    require(minted > 0, "too small");
    saveU64(k("pool_ctdy"), rc + ctdy);
    saveU64(k("lps"), lps + minted);
    saveU64(key("lp:", me), loadU64(key("lp:", me)) + minted);
    w.u64(minted);
  } else if (m == "remove_liquidity") {
    settlePool();
    const units = r.u64("pool units");
    const mine = loadU64(key("lp:", me));
    require(units > 0 && units <= mine, "you don't have that many pool units");
    const lps = loadU64(k("lps"));
    const outC = mulDiv(units, loadU64(k("pool_ctdy")), lps);
    const outS = mulDiv(units, balanceOf(pool()), lps);
    checkReceive(me, outS);
    saveU64(key("lp:", me), mine - units);
    saveU64(k("lps"), lps - units);
    saveU64(k("pool_ctdy"), loadU64(k("pool_ctdy")) - outC);
    forceMove(pool(), me, outS, "PoolWithdraw");
    pay(me, outC);
    w.u64(outC).u64(outS);
  } else if (m == "swap_buy") {
    // Pay CTDY, get shares. Fails if you'd get fewer than min_out (protects against price moves).
    require(!loadFlag(k("paused")), "trading is paused");
    require(verified(me), "you haven't passed the required checks (KYC)");
    settlePool();
    const minOut = r.u64("min shares out");
    const out = quoteBuy(value());
    require(out > 0 && out >= minOut, "price moved: you'd get fewer shares than your minimum");
    checkReceive(me, out);
    // Shares are whole, so charge only what those whole shares cost and give back the change.
    const cost = costToBuy(out);
    require(cost <= value(), "not enough CTDY sent");
    saveU64(k("pool_ctdy"), loadU64(k("pool_ctdy")) + cost);
    forceMove(pool(), me, out, "SwapBuy");
    pay(me, value() - cost);
    w.u64(out).u64(cost);
  } else if (m == "swap_sell") {
    require(!loadFlag(k("paused")), "trading is paused");
    require(verified(me), "you haven't passed the required checks (KYC)");
    settlePool();
    const shares = r.u64("shares in");
    const minOut = r.u64("min CTDY out");
    const out = quoteSell(shares);
    require(out > 0 && out >= minOut, "price moved: you'd get less CTDY than your minimum");
    checkSend(me, shares);
    forceMove(me, pool(), shares, "SwapSell");
    saveU64(k("pool_ctdy"), loadU64(k("pool_ctdy")) - out);
    pay(me, out);
    w.u64(out);
  }
  // -------- issuer and agents --------
  else if (m == "add_agent" || m == "remove_agent") {
    require(isOwner(me), "only the issuer can change agents");
    saveFlag(key("agt:", r.addr("agent")), m == "add_agent");
  } else if (m == "pause" || m == "unpause") {
    onlyAgent();
    saveFlag(k("paused"), m == "pause");
    emit(m == "pause" ? "Paused" : "Unpaused", me);
  } else if (m == "freeze" || m == "unfreeze") {
    onlyAgent();
    const who = r.addr("who");
    saveFlag(key("frz:", who), m == "freeze");
    emit(m == "freeze" ? "Frozen" : "Unfrozen", who);
  } else if (m == "freeze_partial") {
    onlyAgent();
    const who = r.addr("who");
    const amount = r.u64("amount");
    const now = frozenPart(who) + amount;
    require(now <= balanceOf(who), "can't freeze more than they hold");
    saveU64(key("pfz:", who), now);
    emit("PartlyFrozen", concat(who, u64Bytes(amount)));
  } else if (m == "unfreeze_partial") {
    onlyAgent();
    const who = r.addr("who");
    const amount = r.u64("amount");
    const now = frozenPart(who);
    saveU64(key("pfz:", who), amount >= now ? 0 : now - amount);
  } else if (m == "force_transfer") {
    // By legal order, e.g. a court ruling. Public on the chain, like every agent action.
    onlyAgent();
    const from = r.addr("from");
    const to = r.addr("to");
    const amount = r.u64("amount");
    require(verified(to), "receiver hasn't passed the required checks (KYC)");
    const pf = frozenPart(from);
    const left = balanceOf(from) - amount;
    if (left < pf) saveU64(key("pfz:", from), left);
    forceMove(from, to, amount, "ForcedTransfer");
  } else if (m == "recover") {
    // Someone lost their wallet. Move everything to their new wallet, but only if the registry
    // says both wallets belong to the same identity.
    onlyAgent();
    const lost = r.addr("lost wallet");
    const fresh = r.addr("new wallet");
    const idLost = registryAsk("identity_of", lost);
    require(idLost != 0 && idLost == registryAsk("identity_of", fresh), "the two wallets don't belong to the same identity");
    settle(lost);
    settle(fresh);
    saveU64(key("owed:", fresh), loadU64(key("owed:", fresh)) + loadU64(key("owed:", lost)));
    saveU64(key("owed:", lost), 0);
    saveU64(key("pfz:", fresh), frozenPart(fresh) + frozenPart(lost));
    saveU64(key("pfz:", lost), 0);
    if (isFrozen(lost)) saveFlag(key("frz:", fresh), true);
    forceMove(lost, fresh, balanceOf(lost), "Recovered");
  } else if (m == "mint") {
    onlyAgent();
    const to = r.addr("to");
    const amount = r.u64("amount");
    checkReceive(to, amount);
    settle(to);
    setBalance(to, balanceOf(to) + amount);
    saveU64(k("total"), loadU64(k("total")) + amount);
    emit("Minted", concat(to, u64Bytes(amount)));
  } else if (m == "burn") {
    onlyAgent();
    const from = r.addr("from");
    const amount = r.u64("amount");
    require(balanceOf(from) >= amount, "not enough shares");
    settle(from);
    setBalance(from, balanceOf(from) - amount);
    saveU64(k("total"), loadU64(k("total")) - amount);
    emit("Burned", concat(from, u64Bytes(amount)));
  } else if (m == "set_price") {
    onlyAgent();
    saveU64(k("price"), r.u64("price"));
  } else if (m == "set_rules") {
    onlyAgent();
    saveU64(k("max_holders"), r.u64("max holders (0 = no limit)"));
    saveU64(k("max_balance"), r.u64("max shares per investor (0 = no limit)"));
  } else if (m == "allow_country" || m == "block_country") {
    // The first allowed country switches the country rule on. ISO 3166 numeric codes.
    onlyAgent();
    const code = r.u64("country");
    saveFlag(concat(utf8("cty:"), u64Bytes(code)), m == "allow_country");
    saveFlag(k("ctyon"), true);
  } else if (m == "fund_reserve") {
    // The fund manager tops up the reserve, e.g. after T-bills mature.
    onlyAgent();
    saveU64(k("reserve"), loadU64(k("reserve")) + value());
  }
  // -------- read-only --------
  else if (m == "info") {
    w.str(str("name")).str(str("symbol")).u64(loadU64(k("total"))).u64(loadU64(k("price")))
      .addr(owner()).str(str("doc")).u64(loadU64(k("paid"))).str(str("kind"))
      .addr(load(k("registry"))!).bool(loadFlag(k("paused"))).u64(loadU64(k("holders")))
      .u64(loadU64(k("reserve")));
  } else if (m == "balance_of") {
    w.u64(balanceOf(r.addr("who")));
  } else if (m == "claimable") {
    w.u64(earned(r.addr("who")));
  } else if (m == "status") {
    const who = r.addr("who");
    w.bool(verified(who)).bool(isFrozen(who)).u64(frozenPart(who)).bool(countryOk(who)).bool(isAgent(who));
  } else if (m == "pool") {
    w.u64(loadU64(k("pool_ctdy"))).u64(balanceOf(pool())).u64(loadU64(k("lps")));
  } else if (m == "lp_of") {
    w.u64(loadU64(key("lp:", r.addr("who"))));
  } else if (m == "quote_buy") {
    w.u64(quoteBuy(r.u64("CTDY in")));
  } else if (m == "cost_to_buy") {
    w.u64(costToBuy(r.u64("shares")));
  } else if (m == "quote_sell") {
    w.u64(quoteSell(r.u64("shares in")));
  } else if (m == "rules") {
    w.u64(loadU64(k("max_holders"))).u64(loadU64(k("max_balance"))).bool(loadFlag(k("ctyon"))).u64(loadU64(k("topics")));
  } else {
    fail("unknown method: " + m);
  }
  output(w.done());
}

/** Constant product: (CTDY + in) x (shares - out) stays the same, after a 0.3% fee on the way in. */
function quoteBuy(ctdyIn: u64): u64 {
  const rc = loadU64(k("pool_ctdy"));
  const rs = balanceOf(pool());
  if (rc == 0 || rs == 0 || ctdyIn == 0) return 0;
  const inFee = mulDiv(ctdyIn, 1000 - FEE_PER_1000, 1000);
  return mulDiv(rs, inFee, rc + inFee);
}

/** The least CTDY (fee included) that takes `shares` out of the pool without lowering CTDY x shares.
 *  (rc + x * 0.997) * (rs - shares) >= rc * rs   means   x >= rc * shares / ((rs - shares) * 0.997) */
function costToBuy(shares: u64): u64 {
  const rc = loadU64(k("pool_ctdy"));
  const rs = balanceOf(pool());
  require(shares < rs, "the pool doesn't have that many shares");
  return U128.mul(rc * 1000, shares).div((rs - shares) * (1000 - FEE_PER_1000)) + 1;
}

function quoteSell(sharesIn: u64): u64 {
  const rc = loadU64(k("pool_ctdy"));
  const rs = balanceOf(pool());
  if (rc == 0 || rs == 0 || sharesIn == 0) return 0;
  const inFee = mulDiv(sharesIn, 1000 - FEE_PER_1000, 1000);
  return mulDiv(rc, inFee, rs + inFee);
}
