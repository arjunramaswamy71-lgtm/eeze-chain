// Where the page gets its data: a real node over HTTP, or the demo network running inside the
// page itself (the same Rust chain code, compiled to WebAssembly).

/* eslint-disable @typescript-eslint/no-explicit-any */
type Json = any;

const te = new TextEncoder();
const td = new TextDecoder();

let ex: Json = null;
let viewNode = 0;
let speed = 1;
let timer: number | null = null;
let last = 0;
let paused = false;

function call(obj: object): Json {
  const b = te.encode(JSON.stringify(obj));
  const p = ex.alloc(b.length);
  new Uint8Array(ex.memory.buffer, p, b.length).set(b);
  const r: bigint = ex.call(p, b.length);
  const ptr = Number(r >> 32n);
  const len = Number(r & 0xffffffffn);
  const out = JSON.parse(td.decode(new Uint8Array(ex.memory.buffer, ptr, len)));
  ex.dealloc(ptr, len);
  return out;
}

export const demo = {
  get ready() {
    return ex !== null;
  },
  async start(url: string) {
    if (ex) return;
    const res = await fetch(url);
    const mod = "instantiateStreaming" in WebAssembly && res.headers.get("content-type")?.includes("wasm")
      ? await WebAssembly.instantiateStreaming(res, {})
      : await WebAssembly.instantiate(await res.arrayBuffer(), {});
    ex = mod.instance.exports;
    call({ cmd: "init", now: Date.now() });
    // A few seconds of history so the page doesn't open on an empty chain.
    call({ cmd: "tick", ms: 6_000 });
    last = performance.now();
    timer = window.setInterval(() => {
      const now = performance.now();
      const dt = Math.min(now - last, 1_000);
      last = now;
      if (!paused && !document.hidden) call({ cmd: "tick", ms: Math.round(dt * speed) });
    }, 100);
  },
  stop() {
    if (timer) window.clearInterval(timer);
  },
  api(method: string, path: string, body?: unknown): Json {
    const [p, q] = path.split("?");
    const r = call({ cmd: "api", node: viewNode, method, path: p, query: q || "", body: body === undefined ? "" : JSON.stringify(body) });
    if (r && !Array.isArray(r) && typeof r.code === "number" && r.error) throw new Error(r.error);
    return r;
  },
  overview(): Json {
    return call({ cmd: "overview" });
  },
  control(action: string, extra: object = {}): Json {
    const r = call({ cmd: "control", action, ...extra });
    if (r && r.error) throw new Error(r.error);
    return r;
  },
  get view() {
    return viewNode;
  },
  set view(i: number) {
    viewNode = i;
  },
  get speed() {
    return speed;
  },
  set speed(s: number) {
    speed = s;
  },
  get paused() {
    return paused;
  },
  set paused(p: boolean) {
    paused = p;
    last = performance.now();
  },
};
