import "@fontsource-variable/archivo/wdth.css";
import "@fontsource/public-sans/400.css";
import "@fontsource/public-sans/400-italic.css";
import "@fontsource/public-sans/600.css";
import "@fontsource/public-sans/700.css";
import "./style.css";
import { createHero, type Hero } from "./hero3d";
import logo from "./logo.svg?raw";
import { Wallet, signTx, parseCtdy, fmtCtdy, callData, unhex, hex, addressOf, type Kind, type Arg } from "./chain";
import { demo } from "./backend";
import { verifyAccount } from "./light";

/* eslint-disable @typescript-eslint/no-explicit-any */
type Json = any;

// ---------------------------------------------------------------- setup

const $ = <T extends HTMLElement = HTMLElement>(sel: string, root: ParentNode = document) => root.querySelector(sel) as T;
const view = $("#view");
$("#brand").innerHTML = logo;

const store = {
  get(k: string) { try { return localStorage.getItem("eeze." + k); } catch { return null; } },
  set(k: string, v: string | null) { try { if (v === null) localStorage.removeItem("eeze." + k); else localStorage.setItem("eeze." + k, v); } catch { /* private mode */ } },
};

// Served by a node on this computer: talk to it. Anywhere else (like the project website):
// run the demo network inside the page, unless the visitor picked a node.
const servedByNode = !!location.port && /^(127\.0\.0\.1|localhost)$/.test(location.hostname);
let MODE: "demo" | "node" = (store.get("mode") as "demo" | "node") || (servedByNode ? "node" : "demo");
let NODE = store.get("node") || (servedByNode ? location.origin : "http://127.0.0.1:8001");

/** Names for the demo wallets and nodes, so the explorer can say "bank" instead of 0xf1bd… */
const NAMES: Record<string, string> = {};
for (const w of ["arjun", "bank", "alice", "bob", "carol", "eve", "eve-2", "mallory", "miner1", "miner2", "miner-1", "miner-2", "attacker", "m"]) {
  NAMES[Wallet.fromSeed(w).address] = w;
}

async function api(path: string, body?: unknown): Promise<Json> {
  if (MODE === "demo") {
    await demo.start("eeze_wasm.wasm");
    return demo.api(body === undefined ? "GET" : "POST", path, body);
  }
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
const lower = (s: string) => s.replace(/^./, (c) => c.toLowerCase());

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
  buy: "Bought new asset shares", transfer: "Moved asset shares", claim: "Collected asset income", redeem: "Redeemed fund shares",
  distribute: "Paid income to asset holders", swap_buy: "Bought shares on the market", swap_sell: "Sold shares on the market",
  add_liquidity: "Added to a market pool", remove_liquidity: "Took money out of a market pool",
  register: "Registered an investor's identity", add_claim: "Added a KYC check result", revoke_claim: "Revoked a KYC check",
  add_issuer: "Trusted a KYC provider", freeze: "Froze an account", unfreeze: "Unfroze an account", freeze_partial: "Froze part of a balance",
  pause: "Paused trading", unpause: "Restarted trading", recover: "Recovered a lost wallet", force_transfer: "Moved shares by legal order",
  set_price: "Changed a share price", set_rules: "Changed investor limits", allow_country: "Allowed a country", mint: "Issued new shares",
};

function describe(tx: Json): string {
  switch (tx.type) {
    case "transfer": return `Sent ${ctdy(tx.amount)} to ${who(tx.to)}`;
    case "stake": return `Staked ${ctdy(tx.amount)}`;
    case "unstake": return `Started unstaking ${ctdy(tx.amount)}`;
    case "deploy": return "Put a contract on the chain";
    case "set_validator_key": return "Registered a validator key";
    case "evidence": return "Reported a validator for signing two blocks";
    case "vote_evidence": return "Reported a validator for voting twice";
    case "call": {
      const m = methodOf(tx.args);
      const base = (m && METHOD_WORDS[m]) || (m ? `Called ${esc(m)} on a contract` : "Called a contract");
      return `${base}${tx.amount ? ` with ${ctdy(tx.amount)}` : ""}`;
    }
    default: return esc(tx.type);
  }
}

/** Green block number if it worked; otherwise why not. */
function outcome(t: Json) {
  if (t.receipt.ok) return `<span class="ok">#${t.height}</span>`;
  if (/already punished/.test(t.receipt.error || "")) return `<span class="muted" title="Someone reported it first">already reported</span>`;
  return `<span class="bad" title="${esc(t.receipt.error)}">failed</span>`;
}

const argVal = (a: Json) => (a?.t === "u64" ? Number(a.v) : a?.v);

// ---------------------------------------------------------------- connection pill

let status: Json = null;
async function refreshStatus() {
  try {
    status = await api("/status");
    $("#node-dot").className = "dot on";
    $("#node-label").textContent = MODE === "demo" ? `demo, ${status.node} #${status.height}` : `#${status.height}`;
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
  $<HTMLInputElement>(MODE === "demo" ? "#mode-demo" : "#mode-node").checked = true;
  dialog.showModal();
});
dialog.addEventListener("close", () => {
  if (dialog.returnValue !== "ok") return;
  MODE = $<HTMLInputElement>("#mode-demo").checked ? "demo" : "node";
  NODE = $<HTMLInputElement>("#node-url").value.replace(/\/$/, "") || NODE;
  store.set("mode", MODE);
  store.set("node", NODE);
  route();
});

function offline(): string {
  return `<section class="empty">
    <h1>No node to talk to</h1>
    <p>This page reads the chain from an EEZE Chain node at <code>${esc(NODE)}</code>, and nothing answered there.</p>
    <p>Start one on your computer:</p>
    <pre>cargo build --release
./target/release/eeze node --mine --key seed:arjun</pre>
    <p>Or switch to the demo network that runs right here in your browser, using the button at the top right.</p>
  </section>`;
}

// ---------------------------------------------------------------- live chain

let live: { hero: Hero | null; fallback: HTMLElement | null; seen: number } | null = null;

function plate(b: Json) {
  const kind = b.kind === "pow" ? "mined" : b.kind === "pos" ? "staked" : "the first block";
  return `<a class="plate${b.final ? " final" : ""}" href="#/block/${b.height}"><b>#${b.height}</b><br>${kind}<br>${b.txs} tx${b.final ? ", final" : ""}</a>`;
}

async function liveView() {
  if (!(await refreshStatus())) return (view.innerHTML = offline());
  const demoMode = MODE === "demo";
  view.innerHTML = `
    <section class="band hero" aria-label="The live chain">
      <div class="stage">
        <div class="canvas-box" id="stage"><div class="t-labels" id="labels"></div><div class="t-tip" id="tip" hidden></div></div>
        <div class="titleblock">
          <h1>A blockchain you can open, use and try to break.</h1>
          <p class="lede">${demoMode
            ? "This is EEZE Chain, running right now inside this page: six nodes mining, voting and keeping one shared ledger. Send CoTdy, buy into a tokenized Treasury bill fund, or attack the network and see what holds."
            : `This is your own node at <code>${esc(NODE)}</code>, keeping its copy of the EEZE Chain ledger. Every slab is a block it has checked.`}</p>
          <div class="row"><a class="btn" href="#/wallet">Open the wallet</a>${demoMode ? `<a class="btn quiet" href="#/lab">Try to break it</a>` : `<a class="btn quiet" href="#/blocks">Read every block</a>`}</div>
        </div>
        <aside class="now" id="now" aria-live="polite"></aside>
      </div>
    </section>
    <div class="legend" aria-label="What the picture shows">
      <span><i class="mined"></i>Mined block</span>
      <span><i class="staked"></i>Staked block</span>
      <span><i class="final"></i>Stamped final: it can never be rewritten</span>
      ${demoMode ? `<span><i class="flag"></i>Where each node's copy ends</span>` : ""}
      <span class="muted">Point at a block to read it. Click to open it.</span>
    </div>
    <section class="books">
      <div>
        <h2>Latest entries</h2>
        <div class="table-scroll"><table class="ledger">
          <thead><tr><th>Who</th><th>What happened</th><th class="n">Block</th></tr></thead>
          <tbody id="txs"></tbody>
        </table></div>
      </div>
      <div>
        <h2>The books</h2>
        <dl class="kv facts" id="facts"></dl>
      </div>
    </section>`;
  const stageEl = $("#stage");
  const hero = createHero(stageEl, $("#labels"), $("#tip"), (h) => (location.hash = `#/block/${h}`), (a) => NAMES[a] || short(a));
  let fallback: HTMLElement | null = null;
  if (!hero) {
    fallback = document.createElement("div");
    fallback.className = "fallback";
    stageEl.append(fallback);
  }
  live = { hero, fallback, seen: -1 };
  await tickLive();
}

async function tickLive() {
  if (!live || !document.getElementById("now")) return;
  const [st, blocks] = await Promise.all([refreshStatus(), api("/blocks?limit=26").catch(() => null)]);
  if (!st || !blocks || !live) return;
  const ov = MODE === "demo" ? demo.overview() : null;
  const nodes = ov ? ov.nodes.map((n: Json) => ({ name: n.name, height: n.height, online: n.online, hidden: n.group === 9 })) : [];
  const seen = ov?.nodes[demo.view];
  const ahead = ov ? Math.max(0, ...ov.nodes.filter((n: Json) => n.online && n.group !== 9).map((n: Json) => n.height)) : 0;
  live.hero?.update(blocks, nodes);
  if (live.fallback) live.fallback.innerHTML = blocks.slice().reverse().map(plate).join("");

  const top = blocks[0];
  const toPos = st.pos_height - st.height;
  const made = top.kind === "pow" ? "mined" : "staked";
  $("#now").innerHTML = `
    <h2>Right now</h2>
    <p>Block <strong>#${st.height.toLocaleString()}</strong> was ${made} by ${who(top.producer)} ${ago(st.tip_time, st.now)}.</p>
    <p>${st.finalized.height
      ? `Everything up to <a href="#/block/${st.finalized.height}">#${st.finalized.height}</a> is <span class="stamp">final</span>. No one can rewrite it, however much power they have.`
      : toPos > 0
        ? `Miners are racing for each block. In ${toPos} blocks, validators take over and blocks start being stamped final.`
        : st.consensus === "proof-of-stake"
          ? "Waiting for validators to vote a block final."
          : "Mining carries on until someone stakes enough CoTdy to become a validator."}</p>
    ${seen && !seen.online ? `<p><strong>${esc(seen.name)} is switched off</strong>, so this is its last copy of the chain. The nodes still running are at #${ahead}. <a href="#/lab">Turn it back on</a>.</p>` : ""}`;

  $("#facts").innerHTML = `
    <div><dt>How blocks are made</dt><dd>${st.consensus === "proof-of-stake" ? "Staking" : `Mining, ${st.difficulty_bits} zero bits`}</dd></div>
    <div><dt>CoTdy in existence</dt><dd>${ctdy(st.supply)}</dd></div>
    <div><dt>Locked by validators</dt><dd>${ctdy(st.staked)}</dd></div>
    <div><dt>Destroyed for cheating</dt><dd>${ctdy(st.burned)}</dd></div>
    <div><dt>Waiting for a block</dt><dd>${st.mempool} transaction${st.mempool === 1 ? "" : "s"}</dd></div>
    <div><dt>Nodes connected</dt><dd>${st.peers}</dd></div>`;

  if (top.height !== live.seen) {
    live.seen = top.height;
    const rows: Json[] = await api("/recent-txs?limit=10");
    $("#txs").innerHTML = rows.length
      ? rows.map((t) => `<tr>
          <td>${who(t.from)}</td>
          <td>${describe(t.tx)}</td>
          <td class="n"><a href="#/tx/${t.hash}" title="Open this transaction">${outcome(t)}</a></td></tr>`).join("")
      : `<tr class="empty-row"><td colspan="3">Nothing yet. Open the <a href="#/wallet">wallet</a> and send some CoTdy.</td></tr>`;
  }
}

// ---------------------------------------------------------------- the network lab (demo only)

let labTimer: number | null = null;

const LOG_WORD: Record<string, string> = { reorg: "reorg", caught: "caught", evil: "cheat", split: "network", reject: "rejected" };

async function labView() {
  if (MODE !== "demo") {
    view.innerHTML = `<section class="empty"><h1>Try to break it</h1><p>This runs on the demo network inside your browser, not on your node. Switch to it with the button at the top right.</p></section>`;
    return;
  }
  await demo.start("eeze_wasm.wasm");
  view.innerHTML = `
    <h1>Try to break it</h1>
    <p class="lede">Six nodes share one chain, right here in this page. Crash them, cut the network in half, make a validator cheat, or launch a 51% attack. Then watch what the rules let through.</p>
    <p class="phase" id="phase"></p>
    <section class="nodes" id="nodes" aria-label="The nodes"></section>
    <section class="lab">
      <div class="experiments">
        <article>
          <h2>51% attack</h2>
          <p>A hidden attacker with 3 times everyone else's mining power builds a secret chain. Eve pays Bob 900 CTDY in public, and sends the same coins to herself on the secret chain. When the attacker reveals its chain, does Bob's payment survive?</p>
          <p class="muted">Only works while blocks are mined. Once staking starts, final blocks can't be outmined.</p>
          <div class="row"><button id="x-attack">Launch the attack</button><button class="ghost" id="x-release">Reveal the secret chain now</button></div>
          <p class="result" id="r-attack" aria-live="polite"></p>
        </article>
        <article>
          <h2>A validator cheats</h2>
          <p>Carol signs two different blocks for her turn, or votes for two different blocks at the same height. Honest nodes notice, send the proof to the chain, and she loses half her stake.</p>
          <div class="row"><button id="x-sign">Carol signs two blocks</button><button class="ghost" id="x-vote">Carol votes twice</button></div>
          <p class="result" id="r-cheat" aria-live="polite"></p>
        </article>
        <article>
          <h2>Split the network</h2>
          <p>Cut the network in half. Both halves keep making blocks, but neither has 2/3 of the stake, so nothing new becomes final. Join them back and they agree again.</p>
          <div class="row"><button id="x-split">Split the network</button></div>
          <p class="result" id="r-split" aria-live="polite"></p>
        </article>
        <div class="row controls">
          <label for="x-speed">Speed</label>
          <select id="x-speed"><option value="1">1x</option><option value="2">2x</option><option value="4">4x</option></select>
          <button class="ghost" id="x-pause">Pause</button>
          <label for="x-view">Explorer shows the chain as seen by</label>
          <select id="x-view"></select>
        </div>
      </div>
      <div class="feed">
        <h2>What's happening</h2>
        <ol class="log" id="log"></ol>
      </div>
    </section>`;

  const run = (id: string, out: string, fn: () => string) => {
    $(id).onclick = () => {
      const el = $(out);
      try { el.className = "result good"; el.textContent = fn(); } catch (e) { el.className = "result bad"; el.textContent = (e as Error).message; }
      drawLab();
    };
  };
  run("#x-attack", "#r-attack", () => { demo.control("attack"); return "The attacker went dark. Watch its chain grow on the right of its card."; });
  run("#x-release", "#r-attack", () => { demo.control("release"); return "Released. Nodes will switch if the secret chain has more work."; });
  run("#x-sign", "#r-cheat", () => { demo.control("double_sign", { node: "carol" }); return "Carol will cheat on her next turn (she has about a 1 in 5 chance each block)."; });
  run("#x-vote", "#r-cheat", () => { demo.control("double_vote", { node: "carol" }); return "Carol will vote twice on the next block."; });
  run("#x-split", "#r-split", () => {
    const r = demo.control("split");
    $("#x-split").textContent = r.split ? "Join it back together" : "Split the network";
    return r.split ? "Split. Watch the two halves' heights drift apart and finality stop." : "Joined. The heavier half wins and finality carries on.";
  });
  const sp = $<HTMLSelectElement>("#x-speed");
  sp.value = String(demo.speed);
  sp.onchange = () => (demo.speed = Number(sp.value));
  $("#x-pause").onclick = () => {
    demo.paused = !demo.paused;
    $("#x-pause").textContent = demo.paused ? "Resume" : "Pause";
  };
  $("#x-pause").textContent = demo.paused ? "Resume" : "Pause";
  const o = demo.overview();
  const vs = $<HTMLSelectElement>("#x-view");
  vs.innerHTML = o.nodes.map((n: Json, i: number) => `<option value="${i}">${esc(n.name)}</option>`).join("");
  vs.value = String(demo.view);
  vs.onchange = () => { demo.view = Number(vs.value); refreshStatus(); };
  drawLab();
  labTimer = window.setInterval(drawLab, 400);
}

function drawLab() {
  if (!document.getElementById("nodes")) return;
  const o = demo.overview();
  const pub = o.nodes[0];
  $("#phase").innerHTML = pub.consensus === "work"
    ? `Mining phase. Staking takes over at block #${o.pos_height}, in ${Math.max(0, o.pos_height - pub.height)} blocks.`
    : `Staking phase. Newest final block: #${Math.max(...o.nodes.map((n: Json) => n.final))}.${o.split ? " The network is split." : ""}`;
  const maxH = Math.max(...o.nodes.map((n: Json) => n.height));
  $("#nodes").innerHTML = o.nodes.map((n: Json, i: number) => {
    const role = n.name === "attacker" ? (n.group === 9 ? "attacking in secret" : "attacker") : n.hashrate > 0 ? "miner" : n.validator ? "validator" : "node";
    const power = n.hashrate > 0 ? `${(n.hashrate / 1000).toFixed(0)}k hashes/s` : n.validator ? `${fmtCtdy(n.stake, 0)} staked` : "";
    const side = o.split && n.group !== 9 ? `half ${n.group === 0 ? "A" : "B"}` : "";
    return `<article class="node${n.online ? "" : " off"}${n.group === 9 ? " hidden" : ""}${i === demo.view ? " viewing" : ""}">
      <header><strong>${esc(n.name)}</strong><span>${role}</span></header>
      <p class="h">#${n.height}<small>${n.final ? ` final #${n.final}` : ""}</small></p>
      <div class="bar"><i style="width:${maxH ? (n.height / maxH) * 100 : 0}%"></i></div>
      <p class="muted">${[power, side, n.online ? "" : "offline"].filter(Boolean).join(", ")}</p>
      ${n.name === "attacker" ? "" : `<button class="ghost small" data-toggle="${esc(n.name)}">${n.online ? "Turn off" : "Turn on"}</button>`}
    </article>`;
  }).join("");
  view.querySelectorAll<HTMLButtonElement>("[data-toggle]").forEach((b) => (b.onclick = () => {
    try { demo.control("toggle", { node: b.dataset.toggle }); } catch (e) { alertInline((e as Error).message); }
    drawLab();
  }));
  $("#log").innerHTML = o.log.slice(0, 40).map((l: Json) => `<li class="k-${esc(l.kind)}">
      <span class="t">${Math.round((l.t - o.started) / 1000)}s</span>
      <span class="who-n">${esc(l.node)}</span>
      <span>${LOG_WORD[l.kind] ? `<b>${LOG_WORD[l.kind]}</b> ` : ""}${esc(l.text).replace(/^(mined|staked)/, "<b>$1</b>")}</span></li>`).join("");
  const seen = o.nodes[demo.view];
  $("#node-label").textContent = `demo, ${seen.name} #${seen.height}`;
  const at = o.attack;
  if (at) {
    const words: Record<string, string> = {
      hidden: "Attack running: the attacker is mining a secret chain.",
      released: "The secret chain is out. Waiting to see which chain wins.",
      worked: "It worked. Bob's 900 CTDY payment vanished from history, even though he saw it confirmed.",
      failed: "The honest chain held. The attack didn't overturn Bob's payment.",
    };
    const el = $("#r-attack");
    if (el && words[at.stage]) { el.textContent = words[at.stage]; el.className = at.stage === "worked" ? "result bad" : "result good"; }
  }
}

function alertInline(msg: string) {
  const el = $("#r-split");
  if (el) { el.className = "result bad"; el.textContent = msg; }
}

// ---------------------------------------------------------------- blocks, block, tx, address

async function blocksView(before?: number) {
  const list: Json[] = await api(`/blocks?limit=40${before ? `&before=${before}` : ""}`);
  const last = list[list.length - 1];
  view.innerHTML = `
    <h1>Blocks</h1>
    <p class="lede">Every block this node keeps, newest first. Each one points at the fingerprint of the block before it.</p>
    <div class="table-scroll"><table class="grid">
      <thead><tr><th>Block</th><th>Made by</th><th>How</th><th class="n">Transactions</th><th>Status</th><th class="n">When</th></tr></thead>
      <tbody>${list.map((b) => `<tr>
        <td><a href="#/block/${b.height}">#${b.height}</a></td>
        <td>${b.kind === "genesis" ? "the start" : who(b.producer)}</td>
        <td><span class="tag ${b.kind}">${b.kind === "pow" ? `mined, ${b.bits} bits` : b.kind === "pos" ? (b.round ? `staked, try ${b.round + 1}` : "staked") : "genesis"}</span></td>
        <td class="n">${b.txs}</td>
        <td>${b.final ? `<span class="tag final">final</span>` : `<span class="muted">not final yet</span>`}</td>
        <td class="n">${ago(b.time, status?.now)}</td></tr>`).join("")}
      </tbody>
    </table></div>
    ${last && last.height > 0 ? `<p><a class="button ghost" href="#/blocks/${last.height}">Older blocks</a></p>` : ""}`;
}

async function blockView(id: string) {
  const b = await api(`/block/${id}`);
  const s = b.summary, h = b.header;
  view.innerHTML = `
    <p class="crumb"><a href="#/blocks">Blocks</a></p>
    <h1>Block #${s.height} ${b.final ? `<span class="tag final">final</span>` : ""}</h1>
    ${b.on_best_chain ? "" : `<p class="warn">This block is on a fork that lost. It is not part of the chain.</p>`}
    <dl class="kv">
      <div><dt>Hash</dt><dd class="hash">${s.hash}</dd></div>
      <div><dt>Previous block</dt><dd>${s.height > 0 ? `<a class="hash" href="#/block/${h.prev}">${h.prev}</a>` : "none, this is the first block"}</dd></div>
      <div><dt>Made by</dt><dd>${s.height ? who(s.producer) : "the genesis settings"}</dd></div>
      <div><dt>How</dt><dd>${s.kind === "pow" ? `Mined. The hash had to start with ${h.bits} zero bits; it took nonce ${Number(h.nonce).toLocaleString()}.` : s.kind === "pos" ? `Staked. Signed by the validator the VRF draw picked for try ${h.round + 1}.` : "Genesis"}</dd></div>
      ${s.kind === "pos" ? `<div><dt>VRF reveal</dt><dd class="hash">${h.vrf_preout}</dd></div>` : ""}
      ${b.commit ? `<div><dt>Makes final</dt><dd>block <a href="#/block/${b.commit.height}">#${b.commit.height}</a>, with ${b.commit.votes.length} validator votes: ${b.commit.votes.map((v: Json) => who(addrOfKey(v.voter))).join(", ")}</dd></div>` : ""}
      <div><dt>Time</dt><dd>${new Date(s.time).toLocaleString()}</dd></div>
      <div><dt>Transactions root</dt><dd class="hash">${h.tx_root}</dd></div>
      <div><dt>State root</dt><dd class="hash">${h.state_root}</dd></div>
      <div><dt>Gas used</dt><dd>${s.gas_used.toLocaleString()}</dd></div>
    </dl>
    <h2>${b.txs.length} transaction${b.txs.length === 1 ? "" : "s"}</h2>
    ${b.txs.length ? `<ol class="txlist">${b.txs.map((t: Json) => `<li>
        <a class="hash" href="#/tx/${t.hash}">${short(t.hash)}</a>
        <span class="what">${who(t.from)} ${lower(describe(t.tx))}</span>
        ${outcome({ ...t, height: s.height })}</li>`).join("")}</ol>` : `<p class="muted">An empty block. It still moves the chain forward and pays its maker.</p>`}`;
}

const addrOfKey = (pub: string) => addressOf(unhex(pub));

async function txView(hash: string) {
  const t = await api(`/tx/${hash}`);
  const r = t.receipt;
  const tx = t.tx;
  view.innerHTML = `
    <h1>Transaction</h1>
    <p class="lede">${who(t.from)} ${lower(describe(tx))}.</p>
    ${t.status === "pending" ? `<p class="warn">Waiting to go in a block.</p>` : r.ok ? `<p class="good">It worked, in block <a href="#/block/${t.height}">#${t.height}</a> (${t.confirmations} confirmation${t.confirmations === 1 ? "" : "s"}${t.final ? ", final" : ""}).</p>` : `<p class="warn">It went in block <a href="#/block/${t.height}">#${t.height}</a> but failed: ${esc(r.error)}. Only the fee was charged.</p>`}
    <dl class="kv">
      <div><dt>Hash</dt><dd class="hash">${hash}</dd></div>
      <div><dt>Nonce</dt><dd>${tx.nonce} <span class="muted">(this sender's transaction number)</span></dd></div>
      ${r ? `<div><dt>Fee</dt><dd>${ctdy(r.fee)} <span class="muted">for ${r.gas_used.toLocaleString()} gas</span></dd></div>` : ""}
      ${tx.contract ? `<div><dt>Contract</dt><dd><a class="hash" href="#/assets/${tx.contract}">${short(tx.contract)}</a></dd></div>` : ""}
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
      ${outcome(t)}</li>`;
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
      <p class="lede">Your key is made and kept in this browser. The node only ever sees transactions you've signed.</p>
      <div class="choices">
        <section>
          <h2>Make a new wallet</h2>
          <p>A fresh key, nobody else has it. It starts empty; ask someone to send you CTDY.</p>
          <button id="w-new">Make a wallet</button>
        </section>
        <section>
          <h2>Use a demo wallet</h2>
          <p>The network starts with these funded, and Alice has already passed KYC. Anyone can open them, so they're only for trying things out.</p>
          <div class="row">${["alice", "bob", "arjun", "bank"].map((n) => `<button class="ghost" data-seed="${n}">${n}</button>`).join("")}</div>
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
        <p class="amount">${fmtCtdy(a.balance)}</p><p class="muted">CTDY you can spend, as the node reports it</p>
        <dl class="kv tight">
          <div><dt>Staked</dt><dd>${ctdy(a.stake)}</dd></div>
          ${a.unbonding.map((u: number[]) => `<div><dt>Unlocking</dt><dd>${ctdy(u[1])} at #${u[0]}</dd></div>`).join("")}
        </dl>
        <div class="verify">
          <h2>Don't trust the node? Check it.</h2>
          <p class="muted">Your browser checks the validators' signatures and the Merkle proofs itself, the way a light client does on a phone.</p>
          <button class="ghost" id="w-verify">Check my balance myself</button>
          <ol class="checks" id="w-checks"></ol>
        </div>
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
  $("#w-verify").onclick = async () => {
    const list = $("#w-checks");
    list.innerHTML = `<li class="busy">Fetching proofs…</li>`;
    try {
      const g = await api("/genesis");
      const cpKey = `checkpoint.${g.chain_id}`;
      const cp = store.get(cpKey);
      const r = await verifyAccount(api, w.address, g.min_stake, cp ? JSON.parse(cp) : null);
      list.innerHTML = r.checks.map((c) => `<li class="${c.ok ? "pass" : "fail"}">${esc(c.text)}</li>`).join("") +
        (r.ok && r.balance !== undefined ? `<li class="sum">Proven balance at final block #${r.final!.height}: <strong>${fmtCtdy(r.balance)} CTDY</strong></li>` : "") +
        (r.ok ? "" : `<li class="fail">Something didn't check out. Don't trust this node's answer.</li>`);
      if (r.ok && r.final) store.set(cpKey, JSON.stringify(r.final));
    } catch (e) {
      list.innerHTML = `<li class="fail">${esc((e as Error).message)}</li>`;
    }
  };

  let tab: "send" | "stake" | "unstake" = "send";
  const hints = {
    send: "Costs a fee of 0.00021 CTDY.",
    stake: "Locks CTDY. To make blocks, run a node with --validate; it registers your VRF key. Cheating loses half the stake.",
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

// ---------------------------------------------------------------- assets

async function assetsView() {
  const list: Json[] = await api("/contracts");
  const assets = list.filter((c) => c.info && c.info.length >= 12);
  const registries = list.filter((c) => c.info && c.info.length === 2);
  view.innerHTML = `
    <h1>Tokenized assets</h1>
    <p class="lede">Real things split into shares on the chain. Only people who passed the issuer's checks can hold them, and income is paid out by share.</p>
    ${assets.length ? `<table class="grid">
      <thead><tr><th>Asset</th><th>Kind</th><th>Shares</th><th>Price per share</th><th>Holders</th><th>Income paid out</th></tr></thead>
      <tbody>${assets.map((c) => `<tr>
        <td><a href="#/assets/${c.address}">${esc(argVal(c.info[0]))}</a> <span class="muted">${esc(argVal(c.info[1]))}</span></td>
        <td>${argVal(c.info[7]) === "fund" ? "Treasury bill fund" : "Property"}</td>
        <td>${argVal(c.info[2]).toLocaleString()}</td>
        <td>${argVal(c.info[3]) ? ctdy(argVal(c.info[3])) : "not for sale"}</td>
        <td>${argVal(c.info[10])}</td>
        <td>${ctdy(argVal(c.info[6]) || 0)}</td></tr>`).join("")}</tbody></table>`
    : `<section class="empty"><p>No assets yet.</p></section>`}
    ${registries.length ? `<p class="muted after">Investor checks come from the shared identity registry at ${registries.map((r) => who(r.address)).join(", ")}, the way ERC-3643 keeps identity separate from tokens.</p>` : ""}`;
}

async function assetView(addr: string) {
  const w = loadWallet();
  const q = async (method: string, args: Arg[] = []) => {
    const body = { contract: addr, method, args: args.map((a) => (a.t === "u64" ? { t: "u64", v: Number(a.v) } : a)) };
    return (await api("/query", body)).result.map(argVal);
  };
  const [name, symbol, total, price, issuer, doc, paid, kind, registry, paused, holders, reserve] = await q("info");
  const fund = kind === "fund";
  const pool = await q("pool");
  const me = w ? { shares: (await q("balance_of", [{ t: "addr", v: w.address }]))[0], claim: (await q("claimable", [{ t: "addr", v: w.address }]))[0], st: await q("status", [{ t: "addr", v: w.address }]) } : null;
  const events: Json[] = await api(`/events?contract=${addr}&limit=30`);
  const isAgent = me?.st[4] === 1;
  const verified = me?.st[0] === 1;

  view.innerHTML = `
    <p class="crumb"><a href="#/assets">Assets</a></p>
    <h1>${esc(name)} <span class="muted">${esc(symbol)}</span></h1>
    ${paused ? `<p class="warn">Trading is paused by the issuer.</p>` : ""}
    <div class="asset">
      <dl class="kv">
        <div><dt>What it is</dt><dd>${fund ? "A tokenized US Treasury bill fund. Money paid in stays in the fund, interest (4.5% a year in this demo) is paid out daily over the shares investors hold, and you can redeem at the fund price." : "A building split into shares. Buyers pay the issuer, and rent is paid out by share."}</dd></div>
        <div><dt>Shares</dt><dd>${total.toLocaleString()}, held by ${holders} investor${holders === 1 ? "" : "s"}</dd></div>
        <div><dt>Issuer price</dt><dd>${price ? ctdy(price) : "not for sale right now"}</dd></div>
        ${fund ? `<div><dt>Fund reserve</dt><dd>${ctdy(reserve)}</dd></div>` : ""}
        <div><dt>Market price</dt><dd>${pool[1] > 0 ? `${ctdy(Math.round(pool[0] / pool[1]))} <span class="muted">(${pool[1]} shares and ${fmtCtdy(pool[0])} CTDY in the pool)</span>` : "no market yet"}</dd></div>
        <div><dt>Issuer</dt><dd>${who(issuer)}</dd></div>
        <div><dt>Investor checks</dt><dd>KYC and AML, from the identity registry ${who(registry)}</dd></div>
        <div><dt>Legal document</dt><dd>${esc(doc)}</dd></div>
        <div><dt>${fund ? "Interest" : "Rent"} paid out</dt><dd>${ctdy(paid)}</dd></div>
      </dl>
      <section class="mine">
        ${!me ? `<p>Open a <a href="#/wallet">wallet</a> to buy shares or collect income. Alice's demo wallet has already passed KYC.</p>` : `
          <p class="amount">${me.shares.toLocaleString()} <span class="unit">shares</span></p>
          <p class="muted">${total ? ((me.shares / total) * 100).toFixed(2) : 0}% of the asset. ${verified ? "Checks passed." : "You haven't passed the issuer's checks, so you can't hold shares."}${me.st[1] ? " Your account is frozen." : ""}${me.st[2] ? ` ${me.st[2]} of your shares are frozen.` : ""}</p>
          <p>${fund ? "Interest" : "Income"} waiting for you: <strong>${fmtCtdy(me.claim)} CTDY</strong></p>
          <form class="act" id="a-buy"><label for="a-n">Buy new shares from the issuer</label><div class="row"><input id="a-n" inputmode="numeric" placeholder="10" /><button ${price && verified ? "" : "disabled"}>Buy</button></div><p class="hint" id="a-cost">${price ? `${fmtCtdy(price)} CTDY each` : ""}</p></form>
          ${pool[1] > 0 ? `<form class="act" id="a-swap"><label for="a-c">Buy on the market with CTDY</label><div class="row"><input id="a-c" inputmode="decimal" placeholder="100" /><button ${verified ? "" : "disabled"}>Buy</button></div><p class="hint" id="a-quote">Price moves as you buy: the pool keeps CTDY x shares constant, with a 0.3% fee.</p></form>` : ""}
          ${fund ? `<form class="act" id="a-redeem"><label for="a-r">Redeem shares at the fund price</label><div class="row"><input id="a-r" inputmode="numeric" placeholder="10" /><button ${me.shares > 0 ? "" : "disabled"}>Redeem</button></div></form>` : ""}
          <form class="act" id="a-claim"><button ${me.claim > 0 ? "" : "disabled"}>Collect ${fmtCtdy(me.claim)} CTDY</button></form>
          <p class="result" id="a-out" aria-live="polite"></p>`}
      </section>
    </div>
    ${isAgent ? `<section class="issuer">
      <h2>Issuer controls</h2>
      <form id="i-who" class="act"><label for="i-addr">Investor address</label><input id="i-addr" placeholder="0x…" spellcheck="false" />
        <div class="row"><button class="ghost" data-m="freeze">Freeze</button><button class="ghost" data-m="unfreeze">Unfreeze</button></div></form>
      <form id="i-pay" class="act"><label for="i-amt">Pay ${fund ? "interest" : "rent"} to all holders (CTDY)</label><div class="row"><input id="i-amt" inputmode="decimal" placeholder="500" /><button>Pay out</button></div></form>
      <div class="row"><button class="ghost" id="i-pause">${paused ? "Restart trading" : "Pause trading"}</button></div>
      <p class="result" id="i-out" aria-live="polite"></p>
    </section>` : ""}
    <h2>Activity</h2>
    ${events.length ? `<ol class="txlist">${events.map((e) => `<li><a class="hash" href="#/tx/${e.tx}">${short(e.tx)}</a><span class="what">${esc(e.topic)}</span><span class="ok">#${e.height}</span></li>`).join("")}</ol>` : `<p class="muted">Nothing yet.</p>`}`;

  if (!w || !me) return;
  const out = $("#a-out");
  const call = async (method: string, args: Arg[], value: bigint, el: HTMLElement) => {
    const t = await send(w, { type: "call", contract: addr, amount: value, args: callData(method, args) }, 4_000_000, el);
    if (t?.receipt?.ok) setTimeout(() => assetView(addr), 1200);
  };
  const n = $<HTMLInputElement>("#a-n");
  n.oninput = () => {
    const k = parseInt(n.value || "0", 10);
    $("#a-cost").textContent = k > 0 ? `${k} x ${fmtCtdy(price)} = ${fmtCtdy(BigInt(price) * BigInt(k))} CTDY` : `${fmtCtdy(price)} CTDY each`;
  };
  $("#a-buy").onsubmit = (e) => { e.preventDefault(); const k = BigInt(parseInt(n.value || "0", 10)); if (k > 0n) call("buy", [{ t: "u64", v: k }], BigInt(price) * k, out); };
  const swap = document.getElementById("a-swap");
  if (swap) {
    const c = $<HTMLInputElement>("#a-c");
    c.oninput = async () => {
      try {
        const v = parseCtdy(c.value || "0");
        const got = v > 0n ? (await q("quote_buy", [{ t: "u64", v }]))[0] : 0;
        $("#a-quote").textContent = v > 0n ? `You'd get ${got} share${got === 1 ? "" : "s"}. If the price moves before your trade lands, it's cancelled instead.` : "";
      } catch { /* typing */ }
    };
    swap.onsubmit = async (e) => {
      e.preventDefault();
      try {
        const v = parseCtdy(c.value);
        const got = (await q("quote_buy", [{ t: "u64", v }]))[0];
        call("swap_buy", [{ t: "u64", v: BigInt(got) }], v, out);
      } catch (err) { out.className = "result bad"; out.textContent = (err as Error).message; }
    };
  }
  const red = document.getElementById("a-redeem");
  if (red) red.onsubmit = (e) => { e.preventDefault(); const k = BigInt(parseInt($<HTMLInputElement>("#a-r").value || "0", 10)); if (k > 0n) call("redeem", [{ t: "u64", v: k }], 0n, out); };
  $("#a-claim").onsubmit = (e) => { e.preventDefault(); call("claim", [], 0n, out); };
  if (isAgent) {
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
    $("#i-pause").onclick = () => call(paused ? "unpause" : "pause", [], 0n, io);
  }
}

// ---------------------------------------------------------------- validators

async function validatorsView() {
  const [v, st] = await Promise.all([api("/validators"), api("/status")]);
  view.innerHTML = `
    <h1>Validators</h1>
    <p class="lede">${st.consensus === "proof-of-stake"
      ? "Each block, one validator is picked to make it by a VRF draw: like a raffle where more stake means more tickets, and nobody can rig the draw. Validators also vote on blocks; 2/3 of the stake makes a block final."
      : `Blocks are still mined. From block #${st.pos_height}, these validators take over.`}</p>
    ${v.validators.length ? `<table class="grid">
      <thead><tr><th>Validator</th><th>Staked</th><th>Chance of each block</th><th>Blocks made</th><th>Votes counted</th></tr></thead>
      <tbody>${v.validators.sort((a: Json, b: Json) => b.stake - a.stake).map((x: Json) => `<tr>
        <td>${who(x.address)}${x.slashed ? ` <span class="tag bad">slashed</span>` : ""}</td>
        <td>${ctdy(x.stake)}</td>
        <td><span class="bar"><i style="width:${(x.share * 100).toFixed(1)}%"></i></span> ${(x.share * 100).toFixed(1)}%</td>
        <td>${x.recent_blocks}</td><td>${x.recent_votes}</td></tr>`).join("")}</tbody></table>
      <p class="muted after">Counts are for the last 100 blocks.</p>`
    : `<p class="muted">Nobody has staked the minimum of ${fmtCtdy(v.min_stake)} CTDY and registered a VRF key yet.</p>`}
    <h2>Caught cheating</h2>
    ${v.slashed.length ? `<ol class="txlist">${v.slashed.map((x: Json) => `<li>
        <span>${who(x.address)}</span>
        <span class="what">${x.kind === "double vote" ? `voted for two different blocks at #${x.height}` : `signed two different blocks for #${x.height}${x.round ? `, try ${x.round + 1}` : ""}`}. Lost half the stake.</span>
        <span class="bad">${fmtCtdy(x.stake_left)} left</span></li>`).join("")}</ol>` : `<p class="muted">Nobody yet.${MODE === "demo" ? ` Make Carol cheat in the <a href="#/lab">network lab</a>.` : ""}</p>`}
    <p class="muted after">Signing two blocks for one turn, or voting for two blocks at one height, costs a validator half its stake. Anyone can submit the proof and gets a tenth of what's taken.</p>`;
}

// ---------------------------------------------------------------- how it works

function aboutView() {
  view.innerHTML = `<article class="about">
    <h1>How it works</h1>
    <p class="lede">EEZE Chain is a blockchain I built from scratch: the network, its coin CoTdy (CTDY), a wallet, and tokens for real things like a Treasury bill fund. It's a student research project, so CoTdy has no value and is never sold.</p>

    <h2>A notebook everyone shares</h2>
    <p>Picture a ledger that a whole room keeps at once. Everyone has their own copy, and every payment is written on the next line of every copy. Two rules keep it honest.</p>
    <ol>
      <li><strong>Every page carries a fingerprint of the page before it.</strong> Change one old line and its fingerprint changes, which breaks the next page, and the next, all the way to today.</li>
      <li><strong>You have to earn the right to write the next page.</strong> EEZE Chain starts with mining, where computers race to solve a puzzle, then switches to staking, where people lock up coins and take turns.</li>
    </ol>
    <p>A block is a page. The chain is the pages linked by their fingerprints.</p>

    <h2>Fair turns, then a stamp</h2>
    <p>After block 60, validators take turns making blocks. Who goes next is drawn with a verifiable random function: more stake means more tickets, and anyone can check the draw, so nobody can rig it.</p>
    <p>Validators also vote on each block. Once votes from more than two thirds of the stake are in, the block is stamped final. No fork can ever undo it, however much computing power is behind it.</p>
    <p>Cheating is expensive. Sign two blocks for one turn, or vote for two blocks at once, and anyone can send in the proof. The cheater loses half their stake, and the person who reported them gets a tenth of it.</p>

    <h2>A wallet that doesn't take the node's word for it</h2>
    <p>Press "Check my balance myself" in the wallet and your browser checks the validators' signatures and the Merkle proofs on its own, the way a phone wallet would. A node that lies about your balance gets caught.</p>

    <h2>Real things, split into shares</h2>
    <p>A bank can put a Treasury bill fund or a building on the chain, split into shares. An identity registry records who passed which checks (KYC, anti-money-laundering, country), and the shares refuse to move to anyone who hasn't. Interest and rent are paid out by share, there's a trading pool, and the issuer has the controls a regulator would ask for: pausing, freezing, court-ordered transfers, and lost-wallet recovery. It follows ERC-3643, the standard used for tokenized securities.</p>

    <h2>Tested by trying to break it</h2>
    <p>A real 51% attack on six nodes, cheating validators, millions of fuzzed inputs, and hours of simulated chaos where the network splits and nodes crash every few seconds. Through all of it, no two nodes ever disagreed about a final block.</p>

    <h2>Built with</h2>
    <div class="stack"><dl class="kv">
      <div><dt>Rust</dt><dd>The chain: blocks, signatures, mining, staking, finality, the contract engine, networking and storage.</dd></div>
      <div><dt>WebAssembly</dt><dd>Smart contracts run in it, and the whole Rust chain compiles to it so this page can run six nodes.</dd></div>
      <div><dt>AssemblyScript</dt><dd>The identity registry, the security token, the fund and the trading pool.</dd></div>
      <div><dt>TypeScript</dt><dd>This site, the wallet, the light client and the 3D view.</dd></div>
      <div><dt>Python</dt><dd>The six-node test network and the attack and market simulations.</dd></div>
    </dl></div>
    <p class="after">Read the code, the tests and the write-up on <a href="https://github.com/arjunramaswamy71-lgtm/eeze-chain">GitHub</a>. Part of EEZE Research.</p>
  </article>`;
}

// ---------------------------------------------------------------- router

async function route() {
  live?.hero?.dispose();
  live = null;
  if (labTimer) { window.clearInterval(labTimer); labTimer = null; }
  const parts = location.hash.replace(/^#\/?/, "").split("/");
  view.setAttribute("aria-busy", "true");
  document.querySelectorAll("nav a").forEach((a) => {
    const target = (a as HTMLAnchorElement).hash.replace(/^#\/?/, "");
    a.toggleAttribute("aria-current", target === parts[0]);
  });
  $("#nav-lab").hidden = MODE !== "demo";
  try {
    if (!(await refreshStatus()) && parts[0] !== "wallet") {
      view.innerHTML = offline();
      return;
    }
    switch (parts[0]) {
      case "": await liveView(); break;
      case "lab": await labView(); break;
      case "blocks": await blocksView(parts[1] ? Number(parts[1]) : undefined); break;
      case "block": await blockView(parts[1]); break;
      case "tx": await txView(parts[1]); break;
      case "address": await addressView(parts[1]); break;
      case "wallet": await walletView(); break;
      case "assets": if (parts[1]) await assetView(parts[1]); else await assetsView(); break;
      case "validators": await validatorsView(); break;
      case "about": aboutView(); break;
      default: view.innerHTML = `<h1>Nothing on this page</h1><p><a href="#/">Go back to the live chain</a></p>`;
    }
  } catch (e) {
    view.innerHTML = `<section class="empty"><h1>That didn't load</h1><p>${esc((e as Error).message)}</p></section>`;
  } finally {
    view.removeAttribute("aria-busy");
  }
}

window.addEventListener("hashchange", () => { route(); view.focus({ preventScroll: true }); window.scrollTo(0, 0); });
setInterval(() => { if (live) tickLive().catch(() => {}); else if (!labTimer) refreshStatus(); }, 1500);
route();
