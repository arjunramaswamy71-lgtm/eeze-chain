import "@fontsource/ibm-plex-sans/400.css";
import "@fontsource/ibm-plex-sans/600.css";
import "@fontsource/ibm-plex-sans/700.css";
import "@fontsource/ibm-plex-mono/400.css";
import "@fontsource/ibm-plex-mono/500.css";
import "./style.css";
import logo from "./logo.svg?raw";
import { Wallet, signTx, parseCtdy, fmtCtdy, callData, unhex, hex, type Kind, type Arg } from "./chain";

// ---------------------------------------------------------------- setup

const $ = <T extends HTMLElement = HTMLElement>(sel: string, root: ParentNode = document) => root.querySelector(sel) as T;
const view = $("#view");
$("#brand").innerHTML = logo;

const store = {
  get(k: string) { try { return localStorage.getItem("eeze." + k); } catch { return null; } },
  set(k: string, v: string | null) { try { v === null ? localStorage.removeItem("eeze." + k) : localStorage.setItem("eeze." + k, v); } catch { /* private mode */ } },
};

const defaultNode = location.port && location.protocol.startsWith("http") && location.hostname.match(/^(127\.0\.0\.1|localhost)$/)
  ? location.origin
  : "http://127.0.0.1:8001";
let NODE = store.get("node") || defaultNode;

/** Names for the demo wallets, so the explorer can say "bank" instead of 0xf1bd… */
const NAMES: Record<string, string> = {};
for (const w of ["arjun", "bank", "alice", "bob", "eve", "eve-2", "mallory", "miner1", "miner2", "attacker", "m"]) {
  NAMES[Wallet.fromSeed(w).address] = w;
}

type Json = any; // eslint-disable-line @typescript-eslint/no-explicit-any

async function api(path: string, body?: unknown): Promise<Json> {
  const r = await fetch(NODE + path, body === undefined ? {} : {
    method: "POST", headers: { "content-type": "application/json" }, body: JSON.stringify(body),
  });
  const data = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(data.error || `the node answered ${r.status}`);
  return data;
}

// ---------------------------------------------------------------- small helpers

const esc = (s: unknown) => String(s ?? "").replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]!);
const short = (h: string) => (h && h.length > 14 ? `${h.slice(0, 8)}…${h.slice(-4)}` : h);
const who = (a: string) => (NAMES[a] ? `<a class="who" href="#/address/${a}">${esc(NAMES[a])}</a>` : `<a class="hash" href="#/address/${a}">${short(a)}</a>`);
const ctdy = (u: number) => `${fmtCtdy(u)} <span class="unit">CTDY</span>`;

function ago(ms: number, now = Date.now()) {
  const s = Math.max(0, Math.round((now - ms) / 1000));
  if (s < 60) return `${s}s ago`;
  if (s < 3600) return `${Math.round(s / 60)} min ago`;
  return `${Math.round(s / 3600)} h ago`;
}

/** The method name is the first thing in a contract call's arguments. */
function methodOf(argsHex: string): string | null {
  try {
    const b = unhex(argsHex);
    if (b[0] !== 4) return null;
    const n = b[1] | (b[2] << 8) | (b[3] << 16) | (b[4] << 24);
    return new TextDecoder().decode(b.slice(5, 5 + n));
  } catch { return null; }
}

const METHOD_WORDS: Record<string, string> = {
  buy: "Bought asset shares", transfer: "Moved asset shares", claim: "Collected asset income",
  distribute: "Paid income to asset holders", approve: "Approved an investor (KYC)", revoke: "Revoked an investor's KYC",
  freeze: "Froze an account", unfreeze: "Unfroze an account", set_price: "Changed a share price", force_transfer: "Moved shares by order",
};

function describe(tx: Json): string {
  switch (tx.type) {
    case "transfer": return `Sent ${ctdy(tx.amount)} to ${who(tx.to)}`;
    case "stake": return `Staked ${ctdy(tx.amount)}`;
    case "unstake": return `Started unstaking ${ctdy(tx.amount)}`;
    case "deploy": return `Put a contract on the chain`;
    case "call": {
      const m = methodOf(tx.args);
      const base = (m && METHOD_WORDS[m]) || (m ? `Called ${esc(m)} on a contract` : "Called a contract");
      return `${base}${tx.amount ? ` with ${ctdy(tx.amount)}` : ""}`;
    }
    case "evidence": return `Reported a validator for double signing`;
    default: return tx.type;
  }
}

/** Green block number if it worked; otherwise why not. A second report of the same cheat isn't an error worth shouting about. */
function status_(t: Json) {
  if (t.receipt.ok) return `<span class="ok">#${t.height}</span>`;
  if (/already punished/.test(t.receipt.error || "")) return `<span class="muted" title="Someone reported it first">already reported</span>`;
  return `<span class="bad" title="${esc(t.receipt.error)}">failed</span>`;
}

function argVal(a: Json) {
  return a?.t === "u64" ? Number(a.v) : a?.v;
}

// ---------------------------------------------------------------- connection pill

let status: Json = null;
async function refreshStatus() {
  try {
    status = await api("/status");
    $("#node-dot").className = "dot on";
    $("#node-label").textContent = `#${status.height}`;
  } catch {
    status = null;
    $("#node-dot").className = "dot off";
    $("#node-label").textContent = "no node";
  }
  return status;
}

const dialog = $<HTMLDialogElement>("#node-dialog");
$("#node-pill").addEventListener("click", () => {
  $<HTMLInputElement>("#node-url").value = NODE;
  dialog.showModal();
});
dialog.addEventListener("close", () => {
  if (dialog.returnValue === "ok") {
    NODE = $<HTMLInputElement>("#node-url").value.replace(/\/$/, "");
    store.set("node", NODE);
    route();
  }
});

function offline(): string {
  return `<section class="empty">
    <h1>No node to talk to</h1>
    <p>This page reads the chain from an EEZE Chain node at <code>${esc(NODE)}</code>, and nothing answered there.</p>
    <p>Start one on your computer:</p>
    <pre>cargo build --release
./target/release/eeze node --mine --key seed:arjun</pre>
    <p>Then reload, or pick a different node with the button at the top right.</p>
  </section>`;
}

// ---------------------------------------------------------------- live chain

let rail: { el: HTMLElement; shown: Set<number> } | null = null;

function plate(b: Json, posHeight: number) {
  const kind = b.kind === "pow" ? "mined" : b.kind === "pos" ? "staked" : "genesis";
  const ticks = b.kind === "pow" ? `<span class="bits" title="${b.bits} zero bits of work">${"<i></i>".repeat(Math.min(b.bits, 32))}</span>` : "";
  const by = b.kind === "genesis" ? "the start" : NAMES[b.producer] || short(b.producer);
  return `<a class="plate ${kind}${b.height === posHeight ? " first-staked" : ""}" href="#/block/${b.height}" data-h="${b.height}" data-hash="${b.hash}">
    <span class="h">#${b.height}</span>
    <span class="k">${kind}${b.round ? `, try ${b.round + 1}` : ""}</span>
    <span class="by">${esc(by)}</span>
    ${ticks}
    <span class="n">${b.txs} tx</span>
  </a>`;
}

async function liveView() {
  if (!(await refreshStatus())) return (view.innerHTML = offline());
  view.innerHTML = `
    <section class="rail-wrap" aria-label="The newest blocks, linked together">
      <div class="rail" id="rail"></div>
    </section>
    <section class="live">
      <div class="facts" id="facts"></div>
      <div class="feed">
        <h2>Latest transactions</h2>
        <ol class="txlist" id="txs"></ol>
      </div>
    </section>`;
  rail = { el: $("#rail"), shown: new Set() };
  await tickLive(true);
}

async function tickLive(first = false) {
  if (!rail || !document.body.contains(rail.el)) return;
  const [st, blocks] = await Promise.all([refreshStatus(), api("/blocks?limit=14").catch(() => null)]);
  if (!st || !blocks) return;
  // Rebuild the rail if blocks were replaced (a reorg), otherwise add the new ones on the right.
  const top = blocks[0];
  const byHeight = new Map(blocks.map((b: Json) => [b.height, b.hash]));
  const reorged = Array.from(rail.el.children).some((el) => {
    const h = Number((el as HTMLElement).dataset.h);
    return byHeight.has(h) && byHeight.get(h) !== (el as HTMLElement).dataset.hash;
  });
  const fresh = blocks.filter((b: Json) => !rail!.shown.has(b.height)).reverse();
  if (first || reorged) {
    rail.el.innerHTML = blocks.slice().reverse().map((b: Json) => plate(b, st.pos_height)).join("");
    rail.shown = new Set(blocks.map((b: Json) => b.height));
  } else {
    for (const b of fresh) {
      rail.el.insertAdjacentHTML("beforeend", plate(b, st.pos_height));
      const el = rail.el.lastElementChild as HTMLElement;
      el.classList.add("arriving");
      rail.shown.add(b.height);
    }
    while (rail.el.children.length > 14) {
      const gone = rail.el.firstElementChild as HTMLElement;
      rail.shown.delete(Number(gone.dataset.h));
      gone.remove();
    }
  }
  rail.el.scrollLeft = rail.el.scrollWidth;

  const toPos = st.pos_height - st.height;
  const how = st.consensus === "proof-of-stake"
    ? `Validators take turns making blocks, picked by how much CTDY they have staked.`
    : toPos > 0
      ? `Miners race to find a hash with ${st.difficulty_bits} leading zero bits. Staking takes over in ${toPos} blocks.`
      : `Miners race to find a hash with ${st.difficulty_bits} leading zero bits. Staking starts once someone has staked enough.`;
  $("#facts").innerHTML = `
    <p class="lede">Block <strong>${st.height.toLocaleString()}</strong> was made ${ago(st.tip_time, st.now)} by ${who(top.producer)}.</p>
    <p class="how">${how}</p>
    <dl>
      <div><dt>How blocks are made</dt><dd>${st.consensus === "proof-of-stake" ? "Proof of stake" : "Proof of work"}</dd></div>
      <div><dt>CoTdy in existence</dt><dd>${ctdy(st.supply)}</dd></div>
      <div><dt>Locked by validators</dt><dd>${ctdy(st.staked)}</dd></div>
      <div><dt>Destroyed for cheating</dt><dd>${ctdy(st.burned)}</dd></div>
      <div><dt>Waiting to go in a block</dt><dd>${st.mempool} transactions</dd></div>
      <div><dt>Nodes connected</dt><dd>${st.peers}</dd></div>
      <div><dt>Wallets / contracts</dt><dd>${st.accounts} / ${st.contracts}</dd></div>
    </dl>`;

  if (fresh.length || first) {
    const rows: Json[] = await api("/recent-txs?limit=10");
    $("#txs").innerHTML = rows.length
      ? rows.slice(0, 10).map((t: Json) => `<li>
          <a class="hash" href="#/tx/${t.hash}">${short(t.hash)}</a>
          <span class="what">${who(t.from)} ${describe(t.tx).replace(/^./, (c) => c.toLowerCase())}</span>
          ${status_(t)}
        </li>`).join("")
      : `<li class="none">No transactions yet. Send some CTDY from the <a href="#/wallet">wallet</a>.</li>`;
  }
}

// ---------------------------------------------------------------- blocks, block, tx, address

async function blocksView(before?: number) {
  const list: Json[] = await api(`/blocks?limit=40${before ? `&before=${before}` : ""}`);
  const last = list[list.length - 1];
  view.innerHTML = `
    <h1>Blocks</h1>
    <table class="grid">
      <thead><tr><th>Height</th><th>Made by</th><th>How</th><th>Transactions</th><th>Fees</th><th>When</th></tr></thead>
      <tbody>${list.map((b) => `<tr>
        <td><a href="#/block/${b.height}">#${b.height}</a></td>
        <td>${b.kind === "genesis" ? "the start" : who(b.producer)}</td>
        <td><span class="tag ${b.kind}">${b.kind === "pow" ? `mined, ${b.bits} bits` : b.kind === "pos" ? (b.round ? `staked, try ${b.round + 1}` : "staked") : "genesis"}</span></td>
        <td>${b.txs}</td><td>${fmtCtdy(b.fees, 6)}</td><td>${ago(b.time)}</td></tr>`).join("")}
      </tbody>
    </table>
    ${last && last.height > 0 ? `<p><a class="button ghost" href="#/blocks/${last.height}">Older blocks</a></p>` : ""}`;
}

async function blockView(id: string) {
  const b = await api(`/block/${id}`);
  const s = b.summary, h = b.header;
  view.innerHTML = `
    <p class="crumb"><a href="#/blocks">Blocks</a></p>
    <h1>Block #${s.height}</h1>
    ${b.on_best_chain ? "" : `<p class="warn">This block is on a fork that lost. It is not part of the chain.</p>`}
    <dl class="kv">
      <div><dt>Hash</dt><dd class="hash">${s.hash}</dd></div>
      <div><dt>Previous block</dt><dd>${s.height > 0 ? `<a class="hash" href="#/block/${h.prev}">${h.prev}</a>` : "none, this is the first block"}</dd></div>
      <div><dt>Made by</dt><dd>${s.height ? who(s.producer) : "the genesis settings"}</dd></div>
      <div><dt>How</dt><dd>${s.kind === "pow" ? `Mined. The hash had to start with ${h.bits} zero bits; it took nonce ${h.nonce.toLocaleString()}.` : s.kind === "pos" ? `Staked. Signed by the validator picked for try ${h.round + 1}.` : "Genesis"}</dd></div>
      <div><dt>Time</dt><dd>${new Date(s.time).toLocaleString()}</dd></div>
      <div><dt>Transactions root</dt><dd class="hash">${h.tx_root}</dd></div>
      <div><dt>State root</dt><dd class="hash">${h.state_root}</dd></div>
      <div><dt>Gas used</dt><dd>${s.gas_used.toLocaleString()}</dd></div>
    </dl>
    <h2>${b.txs.length} transaction${b.txs.length === 1 ? "" : "s"}</h2>
    ${b.txs.length ? `<ol class="txlist">${b.txs.map((t: Json) => `<li>
        <a class="hash" href="#/tx/${t.hash}">${short(t.hash)}</a>
        <span class="what">${who(t.from)} ${describe(t.tx).replace(/^./, (c) => c.toLowerCase())}</span>
        <span class="${t.receipt.ok ? "ok" : "bad"}">${t.receipt.ok ? "worked" : "failed"}</span></li>`).join("")}</ol>` : `<p class="muted">An empty block. It still moves the chain forward and pays its maker.</p>`}`;
}

async function txView(hash: string) {
  const t = await api(`/tx/${hash}`);
  const r = t.receipt;
  const tx = t.tx;
  view.innerHTML = `
    <h1>Transaction</h1>
    <p class="lede">${who(t.from)} ${describe(tx).replace(/^./, (c) => c.toLowerCase())}.</p>
    ${t.status === "pending" ? `<p class="warn">Waiting to go in a block.</p>` : r.ok ? `<p class="good">It worked, in block <a href="#/block/${t.height}">#${t.height}</a> (${t.confirmations} confirmation${t.confirmations === 1 ? "" : "s"}).</p>` : `<p class="warn">It went in block <a href="#/block/${t.height}">#${t.height}</a> but failed: ${esc(r.error)}. Only the fee was charged.</p>`}
    <dl class="kv">
      <div><dt>Hash</dt><dd class="hash">${hash}</dd></div>
      <div><dt>Nonce</dt><dd>${tx.nonce} <span class="muted">(this sender's transaction number)</span></dd></div>
      ${r ? `<div><dt>Fee</dt><dd>${ctdy(r.fee)} <span class="muted">for ${r.gas_used.toLocaleString()} gas</span></dd></div>` : ""}
      ${tx.contract ? `<div><dt>Contract</dt><dd>${who(tx.contract)}</dd></div>` : ""}
      ${r?.contract ? `<div><dt>New contract</dt><dd><a class="hash" href="#/assets/${r.contract}">${r.contract}</a></dd></div>` : ""}
      <div><dt>Signature</dt><dd class="hash">${tx.sig}</dd></div>
    </dl>
    ${r?.events?.length ? `<h2>Events</h2><ul class="events">${r.events.map((e: Json) => `<li><strong>${esc(e.topic)}</strong> <span class="hash">${short(e.data)}</span></li>`).join("")}</ul>` : ""}`;
}

async function addressView(addr: string) {
  const [a, hist] = await Promise.all([api(`/account/${addr}`), api(`/history/${addr}?limit=30`)]);
  view.innerHTML = `
    <h1>${NAMES[addr] ? esc(NAMES[addr]) : a.contract ? "Contract" : "Wallet"}</h1>
    <p class="hash big">${addr}</p>
    <dl class="kv">
      <div><dt>Balance</dt><dd>${ctdy(a.balance)}</dd></div>
      <div><dt>Staked</dt><dd>${ctdy(a.stake)}${a.is_validator ? " <span class='tag pos'>validator</span>" : ""}</dd></div>
      ${a.unbonding.map((u: number[]) => `<div><dt>Unlocking</dt><dd>${ctdy(u[1])} at block #${u[0]}</dd></div>`).join("")}
      <div><dt>Transactions sent</dt><dd>${a.nonce}</dd></div>
      ${a.contract ? `<div><dt>Contract</dt><dd>made by ${who(a.contract.creator)}, ${a.contract.code_size.toLocaleString()} bytes of code, ${a.contract.slots} stored values. <a href="#/assets/${addr}">Open as an asset</a></dd></div>` : ""}
    </dl>
    <h2>History</h2>
    ${historyList(hist, addr)}`;
}

function historyList(hist: Json[], me: string) {
  if (!hist.length) return `<p class="muted">Nothing yet.</p>`;
  return `<ol class="txlist">${hist.map((t) => {
    const incoming = t.tx.type === "transfer" && t.tx.to === me && t.from !== me;
    return `<li>
      <a class="hash" href="#/tx/${t.hash}">${short(t.hash)}</a>
      <span class="what">${incoming ? `Got ${ctdy(t.tx.amount)} from ${who(t.from)}` : describe(t.tx)}</span>
      <span class="${t.receipt.ok ? "ok" : "bad"}">${t.receipt.ok ? `#${t.height}` : "failed"}</span></li>`;
  }).join("")}</ol>`;
}

// ---------------------------------------------------------------- wallet

function loadWallet(): Wallet | null {
  const s = store.get("wallet");
  try { return s ? new Wallet(unhex(s)) : null; } catch { return null; }
}
function saveWallet(w: Wallet | null) {
  store.set("wallet", w ? hex(w.secret) : null);
}

/** Signs, sends, and reports back as the transaction confirms. */
async function send(w: Wallet, kind: Kind, gas: number, out: HTMLElement): Promise<Json | null> {
  out.className = "result busy";
  out.textContent = "Signing and sending…";
  try {
    const [st, acc] = await Promise.all([api("/status"), api(`/account/${w.address}`)]);
    const { body, hash } = signTx(st.chain_id, w, acc.next_nonce, gas, kind);
    await api("/tx", body);
    out.innerHTML = `Sent <a class="hash" href="#/tx/${hash}">${short(hash)}</a>. Waiting for a block…`;
    for (let i = 0; i < 120; i++) {
      await new Promise((r) => setTimeout(r, 700));
      const t = await api(`/tx/${hash}`).catch(() => null);
      if (t?.status === "confirmed") {
        out.className = t.receipt.ok ? "result good" : "result bad";
        out.innerHTML = t.receipt.ok
          ? `Done, in block <a href="#/block/${t.height}">#${t.height}</a>. Fee ${fmtCtdy(t.receipt.fee, 8)} CTDY.`
          : `In block #${t.height}, but it failed: ${esc(t.receipt.error)}. Fee ${fmtCtdy(t.receipt.fee, 8)} CTDY.`;
        return t;
      }
    }
    out.className = "result";
    out.textContent = "Still waiting. It may go in later.";
  } catch (e) {
    out.className = "result bad";
    out.textContent = (e as Error).message;
  }
  return null;
}

async function walletView() {
  const w = loadWallet();
  if (!w) {
    view.innerHTML = `
      <h1>Wallet</h1>
      <p class="lede">Your key is made and kept in this browser. Only signed transactions are sent to the node.</p>
      <div class="choices">
        <section>
          <h2>Make a new wallet</h2>
          <p>A fresh key, nobody else has it. It starts empty; ask someone to send you CTDY.</p>
          <button id="w-new">Make a wallet</button>
        </section>
        <section>
          <h2>Use a demo wallet</h2>
          <p>The dev network starts with these funded. Anyone can open them, so they're only for trying things out.</p>
          <div class="row">${["arjun", "bank", "alice", "bob"].map((n) => `<button class="ghost" data-seed="${n}">${n}</button>`).join("")}</div>
        </section>
        <section>
          <h2>Bring your own key</h2>
          <form id="w-import"><label for="w-key">Secret key (64 hex characters)</label>
          <input id="w-key" autocomplete="off" spellcheck="false" />
          <button>Open wallet</button><p class="result" id="w-err"></p></form>
        </section>
      </div>`;
    $("#w-new").onclick = () => { saveWallet(Wallet.create()); walletView(); };
    view.querySelectorAll<HTMLButtonElement>("[data-seed]").forEach((b) => (b.onclick = () => { saveWallet(Wallet.fromSeed(b.dataset.seed!)); walletView(); }));
    $("#w-import").onsubmit = (e) => {
      e.preventDefault();
      try { saveWallet(new Wallet(unhex($<HTMLInputElement>("#w-key").value))); walletView(); }
      catch (err) { $("#w-err").textContent = (err as Error).message; $("#w-err").className = "result bad"; }
    };
    return;
  }

  const [a, hist] = await Promise.all([api(`/account/${w.address}`), api(`/history/${w.address}?limit=20`)]);
  const name = NAMES[w.address];
  view.innerHTML = `
    <h1>Wallet${name ? `: ${esc(name)}` : ""}</h1>
    <p class="hash big"><span id="w-addr">${w.address}</span> <button class="ghost small" id="w-copy">Copy</button></p>
    <div class="wallet">
      <section class="balance">
        <p class="amount">${fmtCtdy(a.balance)}</p><p class="muted">CTDY you can spend</p>
        <dl class="kv tight">
          <div><dt>Staked</dt><dd>${ctdy(a.stake)}</dd></div>
          ${a.unbonding.map((u: number[]) => `<div><dt>Unlocking</dt><dd>${ctdy(u[1])} at #${u[0]}</dd></div>`).join("")}
        </dl>
      </section>
      <section class="actions">
        <div class="tabs" role="tablist">
          <button role="tab" aria-selected="true" data-tab="send">Send</button>
          <button role="tab" aria-selected="false" data-tab="stake">Stake</button>
          <button role="tab" aria-selected="false" data-tab="unstake">Unstake</button>
        </div>
        <form id="w-form">
          <div data-for="send"><label for="f-to">To address</label><input id="f-to" placeholder="0x…" spellcheck="false" autocomplete="off" /></div>
          <label for="f-amt">Amount in CTDY</label><input id="f-amt" inputmode="decimal" placeholder="10" autocomplete="off" />
          <p class="hint" id="f-hint"></p>
          <button id="f-go">Send CTDY</button>
          <p class="result" id="f-out" aria-live="polite"></p>
        </form>
      </section>
    </div>
    <h2>History</h2>
    ${historyList(hist, w.address)}
    <details class="danger"><summary>Key and sign out</summary>
      <p>Your secret key. Anyone who has it controls this wallet. Don't share it.</p>
      <p class="hash" id="w-secret">hidden</p>
      <div class="row"><button class="ghost" id="w-show">Show key</button><button class="ghost" id="w-out">Sign out of this wallet</button></div>
    </details>`;

  $("#w-copy").onclick = () => navigator.clipboard?.writeText(w.address).then(() => ($("#w-copy").textContent = "Copied"));
  $("#w-show").onclick = () => ($("#w-secret").textContent = hex(w.secret));
  $("#w-out").onclick = () => { saveWallet(null); walletView(); };

  let tab: "send" | "stake" | "unstake" = "send";
  const hints = {
    send: "Costs a fee of 0.00021 CTDY.",
    stake: "Locked CTDY makes you a validator once you have 1,000 staked. Cheating loses half of it.",
    unstake: "Unlocked CTDY comes back after a waiting period, so cheaters can still be caught.",
  };
  const labels = { send: "Send CTDY", stake: "Stake CTDY", unstake: "Unstake CTDY" };
  const setTab = (t: typeof tab) => {
    tab = t;
    view.querySelectorAll<HTMLButtonElement>("[data-tab]").forEach((b) => b.setAttribute("aria-selected", String(b.dataset.tab === t)));
    $("[data-for=send]").hidden = t !== "send";
    $("#f-hint").textContent = hints[t];
    $("#f-go").textContent = labels[t];
  };
  view.querySelectorAll<HTMLButtonElement>("[data-tab]").forEach((b) => (b.onclick = () => setTab(b.dataset.tab as typeof tab)));
  setTab("send");

  $("#w-form").onsubmit = async (e) => {
    e.preventDefault();
    const out = $("#f-out");
    let kind: Kind;
    try {
      const amount = parseCtdy($<HTMLInputElement>("#f-amt").value);
      if (tab === "send") {
        const to = $<HTMLInputElement>("#f-to").value.trim();
        if (!/^0x[0-9a-fA-F]{40}$/.test(to)) throw new Error("an address is 0x followed by 40 hex characters");
        kind = { type: "transfer", to: to.toLowerCase(), amount };
      } else kind = { type: tab, amount };
    } catch (err) {
      out.className = "result bad";
      out.textContent = (err as Error).message;
      return;
    }
    $<HTMLButtonElement>("#f-go").disabled = true;
    const t = await send(w, kind, 21_000, out);
    $<HTMLButtonElement>("#f-go").disabled = false;
    if (t?.receipt?.ok) setTimeout(walletView, 1500);
  };
}

// ---------------------------------------------------------------- assets (real-world asset contracts)

async function assetsView() {
  const list: Json[] = await api("/contracts");
  const assets = list.filter((c) => c.info && c.info.length >= 6);
  view.innerHTML = `
    <h1>Tokenized assets</h1>
    <p class="lede">Real things split into shares on the chain. Only people the issuer has checked can hold them, and income is paid out by share.</p>
    ${assets.length ? `<table class="grid">
      <thead><tr><th>Asset</th><th>Shares</th><th>Price per share</th><th>Issuer</th><th>Income paid out</th></tr></thead>
      <tbody>${assets.map((c) => `<tr>
        <td><a href="#/assets/${c.address}">${esc(argVal(c.info[0]))}</a> <span class="muted">${esc(argVal(c.info[1]))}</span></td>
        <td>${argVal(c.info[2]).toLocaleString()}</td>
        <td>${argVal(c.info[3]) ? ctdy(argVal(c.info[3])) : "not for sale"}</td>
        <td>${who(argVal(c.info[4]))}</td>
        <td>${ctdy(argVal(c.info[6]) || 0)}</td></tr>`).join("")}</tbody></table>`
    : `<section class="empty"><p>No assets yet. Put one on the chain from the command line:</p>
      <pre>eeze deploy --key seed:bank --wasm contracts/build/rwa.wasm \\
  "str:Main St Building" str:MSB u64:1000 u64:1000000000 "str:deed hash"</pre></section>`}`;
}

async function assetView(addr: string) {
  const w = loadWallet();
  const q = async (method: string, args: Arg[] = []) => {
    const body = { contract: addr, method, args: args.map((a) => (a.t === "u64" ? { t: "u64", v: Number(a.v) } : a)) };
    return (await api("/query", body)).result.map(argVal);
  };
  const [name, symbol, total, price, issuer, doc, paid] = await q("info");
  const mine = w ? await Promise.all([q("balance_of", [{ t: "addr", v: w.address }]), q("claimable", [{ t: "addr", v: w.address }]), q("status", [{ t: "addr", v: w.address }])]) : null;
  const events: Json[] = await api(`/events?contract=${addr}&limit=30`);
  const isIssuer = w?.address === issuer;
  const [shares, claim, st] = mine ? [mine[0][0], mine[1][0], mine[2]] : [0, 0, [0, 0]];

  view.innerHTML = `
    <p class="crumb"><a href="#/assets">Assets</a></p>
    <h1>${esc(name)} <span class="muted">${esc(symbol)}</span></h1>
    <div class="asset">
      <dl class="kv">
        <div><dt>Shares</dt><dd>${total.toLocaleString()}</dd></div>
        <div><dt>Price per share</dt><dd>${price ? ctdy(price) : "not for sale right now"}</dd></div>
        <div><dt>Issuer</dt><dd>${who(issuer)}</dd></div>
        <div><dt>Legal document</dt><dd>${esc(doc)}</dd></div>
        <div><dt>Income paid out</dt><dd>${ctdy(paid)}</dd></div>
        <div><dt>Contract</dt><dd>${who(addr)}</dd></div>
      </dl>
      <section class="mine">
        ${!w ? `<p>Open a <a href="#/wallet">wallet</a> to buy shares or collect income.</p>` : `
          <p class="amount">${shares.toLocaleString()} <span class="unit">shares</span></p>
          <p class="muted">${total ? ((shares / total) * 100).toFixed(1) : 0}% of the asset. ${st[0] ? "KYC passed." : "Not KYC-approved yet, so you can't hold shares."}${st[1] ? " Your account is frozen." : ""}</p>
          <p>Income waiting for you: <strong>${fmtCtdy(claim)} CTDY</strong></p>
          <form class="act" id="a-buy"><label for="a-n">Buy shares</label><div class="row"><input id="a-n" inputmode="numeric" placeholder="10" /><button ${price && st[0] ? "" : "disabled"}>Buy</button></div><p class="hint" id="a-cost">${price ? `${fmtCtdy(price)} CTDY each` : ""}</p></form>
          <form class="act" id="a-claim"><button ${claim > 0 ? "" : "disabled"}>Collect ${fmtCtdy(claim)} CTDY</button></form>
          <form class="act" id="a-send"><label for="a-to">Give shares to</label><input id="a-to" placeholder="0x…" spellcheck="false" />
            <div class="row"><input id="a-sn" inputmode="numeric" placeholder="shares" /><button ${shares > 0 ? "" : "disabled"}>Transfer</button></div></form>
          <p class="result" id="a-out" aria-live="polite"></p>`}
      </section>
    </div>
    ${isIssuer ? `<section class="issuer">
      <h2>Issuer controls</h2>
      <form id="i-who" class="act"><label for="i-addr">Investor address</label><input id="i-addr" placeholder="0x…" spellcheck="false" />
        <div class="row"><button data-m="approve">Approve KYC</button><button class="ghost" data-m="revoke">Revoke</button><button class="ghost" data-m="freeze">Freeze</button><button class="ghost" data-m="unfreeze">Unfreeze</button></div></form>
      <form id="i-pay" class="act"><label for="i-amt">Pay income to all holders (CTDY)</label><div class="row"><input id="i-amt" inputmode="decimal" placeholder="500" /><button>Pay out</button></div></form>
      <p class="result" id="i-out" aria-live="polite"></p>
    </section>` : ""}
    <h2>Activity</h2>
    ${events.length ? `<ol class="txlist">${events.map((e) => `<li><a class="hash" href="#/tx/${e.tx}">${short(e.tx)}</a><span class="what">${esc(e.topic)}</span><span class="ok">#${e.height}</span></li>`).join("")}</ol>` : `<p class="muted">Nothing yet.</p>`}`;

  if (!w) return;
  const out = $("#a-out");
  const call = async (method: string, args: Arg[], value: bigint, el: HTMLElement) => {
    const t = await send(w, { type: "call", contract: addr, amount: value, args: callData(method, args) }, 3_000_000, el);
    if (t?.receipt?.ok) setTimeout(() => assetView(addr), 1200);
  };
  const n = $<HTMLInputElement>("#a-n");
  n.oninput = () => {
    const k = parseInt(n.value || "0", 10);
    $("#a-cost").textContent = k > 0 ? `${k} × ${fmtCtdy(price)} = ${fmtCtdy(BigInt(price) * BigInt(k))} CTDY` : `${fmtCtdy(price)} CTDY each`;
  };
  $("#a-buy").onsubmit = (e) => { e.preventDefault(); const k = BigInt(parseInt(n.value || "0", 10)); if (k > 0n) call("buy", [{ t: "u64", v: k }], BigInt(price) * k, out); };
  $("#a-claim").onsubmit = (e) => { e.preventDefault(); call("claim", [], 0n, out); };
  $("#a-send").onsubmit = (e) => {
    e.preventDefault();
    const to = $<HTMLInputElement>("#a-to").value.trim().toLowerCase();
    const k = BigInt(parseInt($<HTMLInputElement>("#a-sn").value || "0", 10));
    if (/^0x[0-9a-f]{40}$/.test(to) && k > 0n) call("transfer", [{ t: "addr", v: to }, { t: "u64", v: k }], 0n, out);
  };
  if (isIssuer) {
    const io = $("#i-out");
    $("#i-who").onsubmit = (e) => {
      e.preventDefault();
      const m = ((e as SubmitEvent).submitter as HTMLButtonElement).dataset.m!;
      const to = $<HTMLInputElement>("#i-addr").value.trim().toLowerCase();
      if (/^0x[0-9a-f]{40}$/.test(to)) call(m, [{ t: "addr", v: to }], 0n, io);
      else { io.className = "result bad"; io.textContent = "an address is 0x followed by 40 hex characters"; }
    };
    $("#i-pay").onsubmit = (e) => {
      e.preventDefault();
      try { call("distribute", [], parseCtdy($<HTMLInputElement>("#i-amt").value), io); }
      catch (err) { io.className = "result bad"; io.textContent = (err as Error).message; }
    };
  }
}

// ---------------------------------------------------------------- validators

async function validatorsView() {
  const [v, st] = await Promise.all([api("/validators"), api("/status")]);
  view.innerHTML = `
    <h1>Validators</h1>
    <p class="lede">${st.consensus === "proof-of-stake"
      ? "Each block, one validator is picked to make it. More CTDY staked means a bigger chance, like holding more raffle tickets."
      : `Blocks are still mined. From block #${st.pos_height}, these validators take over.`}</p>
    ${v.validators.length ? `<table class="grid">
      <thead><tr><th>Validator</th><th>Staked</th><th>Chance of each block</th><th>Blocks in the last 100</th></tr></thead>
      <tbody>${v.validators.sort((a: Json, b: Json) => b.stake - a.stake).map((x: Json) => `<tr>
        <td>${who(x.address)}${x.slashed ? ` <span class="tag bad">slashed</span>` : ""}</td>
        <td>${ctdy(x.stake)}</td>
        <td><span class="bar"><i style="width:${(x.share * 100).toFixed(1)}%"></i></span> ${(x.share * 100).toFixed(1)}%</td>
        <td>${x.recent_blocks}</td></tr>`).join("")}</tbody></table>`
    : `<p class="muted">Nobody has staked the minimum of ${fmtCtdy(v.min_stake)} CTDY yet.</p>`}
    <h2>Caught cheating</h2>
    ${v.slashed.length ? `<ol class="txlist">${v.slashed.map((x: Json) => `<li>
        <span>${who(x.address)}</span>
        <span class="what">signed two different blocks for #${x.height}${x.round ? `, try ${x.round + 1}` : ""}. Lost half its stake.</span>
        <span class="bad">${fmtCtdy(x.stake_left)} left</span></li>`).join("")}</ol>` : `<p class="muted">Nobody yet.</p>`}
    <p class="muted after">Signing two different blocks for the same turn costs a validator half its stake. Anyone can submit the proof, and gets a tenth of what's taken.</p>`;
}

// ---------------------------------------------------------------- router

async function route() {
  rail = null;
  const parts = location.hash.replace(/^#\/?/, "").split("/");
  view.setAttribute("aria-busy", "true");
  document.querySelectorAll("nav a").forEach((a) => {
    const target = (a as HTMLAnchorElement).hash.replace(/^#\/?/, "");
    a.toggleAttribute("aria-current", target === parts[0] || (target === "" && parts[0] === ""));
  });
  try {
    if (!(await refreshStatus()) && parts[0] !== "wallet") {
      view.innerHTML = offline();
      return;
    }
    switch (parts[0]) {
      case "": await liveView(); break;
      case "blocks": await blocksView(parts[1] ? Number(parts[1]) : undefined); break;
      case "block": await blockView(parts[1]); break;
      case "tx": await txView(parts[1]); break;
      case "address": await addressView(parts[1]); break;
      case "wallet": await walletView(); break;
      case "assets": parts[1] ? await assetView(parts[1]) : await assetsView(); break;
      case "validators": await validatorsView(); break;
      default: view.innerHTML = `<h1>Nothing here</h1><p><a href="#/">Back to the live chain</a></p>`;
    }
  } catch (e) {
    view.innerHTML = `<section class="empty"><h1>That didn't load</h1><p>${esc((e as Error).message)}</p></section>`;
  } finally {
    view.removeAttribute("aria-busy");
  }
}

window.addEventListener("hashchange", () => { route(); view.focus({ preventScroll: true }); window.scrollTo(0, 0); });
setInterval(() => { if (rail) tickLive().catch(() => {}); else refreshStatus(); }, 1500);
route();
