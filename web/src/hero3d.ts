// The live chain in 3D: each block is a slab on a sheet of ledger paper, linked to the one before.
// Mined blocks are gold, staked blocks are cyan, and once validators vote a block final it gets a
// red FINAL stamp. In the demo, a flag shows where each node's copy of the chain ends, so you can
// watch a split or an attack pull them apart. New blocks drop in; a block that loses a fork slides
// off the table.

import * as THREE from "three";

/* eslint-disable @typescript-eslint/no-explicit-any */
type Json = any;

export type HeroBlock = { height: number; hash: string; kind: string; producer: string; final: boolean; txs: number; round: number };
export type HeroNode = { name: string; height: number; online: boolean; hidden: boolean };

const SPACING = 2.5;
const SHOWN = 26;
const W = 1.7, H = 0.5, D = 1.2;

const css = (name: string) => getComputedStyle(document.documentElement).getPropertyValue(name).trim() || "#000";
const reduced = () => matchMedia("(prefers-reduced-motion: reduce)").matches;

type Slab = {
  b: HeroBlock;
  group: THREE.Group;
  body: THREE.Mesh;
  edges: THREE.LineSegments;
  stamp: THREE.Mesh;
  link: THREE.Group;
  drop: number; // 1 = just arrived, falls to 0
  stampT: number; // 0..1 stamp animation
  leaving: number; // >0 while sliding off after losing a fork
};

function stampTexture(): THREE.CanvasTexture {
  const c = document.createElement("canvas");
  c.width = 256;
  c.height = 128;
  const g = c.getContext("2d")!;
  g.strokeStyle = g.fillStyle = "#fff";
  g.lineWidth = 9;
  g.strokeRect(12, 16, 232, 96);
  g.lineWidth = 3;
  g.strokeRect(24, 28, 208, 72);
  g.font = "800 58px 'Archivo Variable', Archivo, Arial, sans-serif";
  g.textAlign = "center";
  g.textBaseline = "middle";
  g.fillText("FINAL", 128, 66);
  // A little wear, like a real rubber stamp.
  g.globalCompositeOperation = "destination-out";
  for (let i = 0; i < 260; i++) {
    g.globalAlpha = Math.random() * 0.6;
    g.fillRect(Math.random() * 256, Math.random() * 128, 1 + Math.random() * 3, 1 + Math.random() * 2);
  }
  const t = new THREE.CanvasTexture(c);
  t.anisotropy = 4;
  return t;
}

export function createHero(stage: HTMLElement, labels: HTMLElement, tip: HTMLElement, onPick: (h: number) => void, nameOf: (a: string) => string) {
  const canvas = document.createElement("canvas");
  canvas.setAttribute("aria-hidden", "true");
  stage.prepend(canvas);
  let renderer: THREE.WebGLRenderer;
  try {
    renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
  } catch {
    canvas.remove();
    return null;
  }
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(28, 1, 0.1, 300);
  const look = new THREE.Vector3();

  const colors = () => ({
    paper: new THREE.Color(css("--paper")),
    ink: new THREE.Color(css("--ink")),
    rule: new THREE.Color(css("--rule")),
    red: new THREE.Color(css("--red")),
    gold: new THREE.Color(css("--block-mined")),
    cyan: new THREE.Color(css("--block-staked")),
    genesis: new THREE.Color(css("--ink-3")),
  });
  let C = colors();

  scene.fog = new THREE.Fog(C.paper, 26, 62);
  const hemi = new THREE.HemisphereLight(0xffffff, 0xffffff, 1.6);
  scene.add(hemi);
  const sun = new THREE.DirectionalLight(0xffffff, 1.4);
  sun.position.set(-4, 10, 8);
  scene.add(sun);

  // Ledger paper: rows run along the chain; each block sits in its own column.
  const rows = new THREE.Group();
  const rowMat = new THREE.LineBasicMaterial({ color: C.rule });
  const redMat = new THREE.LineBasicMaterial({ color: C.red });
  const rowPts: THREE.Vector3[] = [];
  for (let z = -9; z <= 6; z += 1.5) rowPts.push(new THREE.Vector3(-90, 0, z), new THREE.Vector3(20, 0, z));
  rows.add(new THREE.LineSegments(new THREE.BufferGeometry().setFromPoints(rowPts), rowMat));
  // The red double margin line of an accounting ledger, right where the chain runs.
  const margin = new THREE.LineSegments(
    new THREE.BufferGeometry().setFromPoints([
      new THREE.Vector3(-90, 0.002, D / 2 + 0.35), new THREE.Vector3(20, 0.002, D / 2 + 0.35),
      new THREE.Vector3(-90, 0.002, D / 2 + 0.47), new THREE.Vector3(20, 0.002, D / 2 + 0.47),
    ]),
    redMat,
  );
  rows.add(margin);
  scene.add(rows);
  const cols = new THREE.Group();
  const colPts: THREE.Vector3[] = [];
  for (let k = -SHOWN - 4; k <= 4; k++) colPts.push(new THREE.Vector3(k * SPACING + SPACING / 2, 0.001, -9), new THREE.Vector3(k * SPACING + SPACING / 2, 0.001, 6));
  cols.add(new THREE.LineSegments(new THREE.BufferGeometry().setFromPoints(colPts), rowMat));
  scene.add(cols);

  const boxGeo = new THREE.BoxGeometry(W, H, D);
  const edgeGeo = new THREE.EdgesGeometry(boxGeo);
  const stampGeo = new THREE.PlaneGeometry(1.25, 0.62);
  const stampTex = stampTexture();
  const ringGeo = new THREE.TorusGeometry(0.17, 0.045, 8, 24);

  const slabs = new Map<number, Slab>();
  const leaving: Slab[] = [];
  let tipH = 0;
  let glide = 0; // extra x offset that eases to 0 after the chain moves on
  let nodes: HeroNode[] = [];
  const flags = new Map<string, { pole: THREE.Mesh; cloth: THREE.Mesh; label: HTMLElement }>();
  const ticks = new Map<number, HTMLElement>();

  function bodyMat(b: HeroBlock) {
    const col = b.kind === "pow" ? C.gold : b.kind === "pos" ? C.cyan : C.genesis;
    return new THREE.MeshLambertMaterial({ color: col, transparent: !b.final, opacity: b.final ? 1 : 0.62 });
  }

  function makeSlab(b: HeroBlock, arriving: boolean): Slab {
    const group = new THREE.Group();
    const body = new THREE.Mesh(boxGeo, bodyMat(b));
    body.position.y = H / 2;
    body.userData.height = b.height;
    const edges = new THREE.LineSegments(edgeGeo, new THREE.LineBasicMaterial({ color: C.ink }));
    edges.position.y = H / 2;
    const stamp = new THREE.Mesh(stampGeo, new THREE.MeshBasicMaterial({ map: stampTex, color: C.red, transparent: true, depthWrite: false }));
    stamp.rotation.x = -Math.PI / 2;
    stamp.rotation.z = 0.12 - ((b.height * 37) % 10) / 40;
    stamp.position.y = H + 0.004;
    stamp.visible = b.final;
    // Two interlocking links joining this block to the one before it.
    const link = new THREE.Group();
    const ringMat = new THREE.MeshLambertMaterial({ color: C.ink });
    const r1 = new THREE.Mesh(ringGeo, ringMat);
    const r2 = new THREE.Mesh(ringGeo, ringMat);
    r1.position.set(-W / 2 - (SPACING - W) * 0.36, H / 2, 0);
    r2.position.set(-W / 2 - (SPACING - W) * 0.64, H / 2, 0);
    r2.rotation.x = Math.PI / 2;
    link.add(r1, r2);
    link.visible = b.height > 0;
    group.add(body, edges, stamp, link);
    scene.add(group);
    return { b, group, body, edges, stamp, link, drop: arriving && !reduced() ? 1 : 0, stampT: b.final ? 1 : 0, leaving: 0 };
  }

  function tick(h: number) {
    let el = ticks.get(h);
    if (!el) {
      el = document.createElement("span");
      el.className = "t-tick";
      el.textContent = `#${h}`;
      labels.append(el);
      ticks.set(h, el);
    }
    return el;
  }

  let first = true;
  function update(blocks: HeroBlock[], ns: HeroNode[] = []) {
    if (!blocks.length) return;
    const newTip = blocks[0].height;
    if (!first && newTip > tipH && !reduced()) glide += (newTip - tipH) * SPACING;
    if (!first && newTip < tipH && !reduced()) glide -= (tipH - newTip) * SPACING;
    glide = Math.max(-SPACING * 6, Math.min(glide, SPACING * 6));
    tipH = newTip;
    const keep = new Set<number>();
    for (const b of blocks.slice(0, SHOWN)) {
      keep.add(b.height);
      const s = slabs.get(b.height);
      if (s && s.b.hash !== b.hash) {
        // This height now holds a different block: the old one lost a fork.
        s.leaving = 0.001;
        leaving.push(s);
        slabs.delete(b.height);
      }
      const cur = slabs.get(b.height);
      if (!cur) {
        slabs.set(b.height, makeSlab(b, !first));
      } else if (b.final && !cur.b.final) {
        cur.b = b;
        cur.body.material = bodyMat(b);
        cur.stamp.visible = true;
        cur.stampT = reduced() ? 1 : 0;
      } else cur.b = b;
    }
    for (const [h, s] of slabs) {
      if (!keep.has(h)) {
        if (h > tipH) {
          s.leaving = 0.001;
          leaving.push(s);
        } else scene.remove(s.group);
        slabs.delete(h);
      }
    }
    for (const [h, el] of ticks) if (!slabs.has(h)) { el.remove(); ticks.delete(h); }
    nodes = ns;
    first = false;
  }

  function flag(name: string) {
    let f = flags.get(name);
    if (!f) {
      const pole = new THREE.Mesh(new THREE.CylinderGeometry(0.025, 0.025, 2.2, 6), new THREE.MeshLambertMaterial({ color: C.ink }));
      const cloth = new THREE.Mesh(new THREE.PlaneGeometry(0.55, 0.32), new THREE.MeshLambertMaterial({ color: C.ink, side: THREE.DoubleSide }));
      const label = document.createElement("span");
      label.className = "t-tick flag";
      label.textContent = name;
      labels.append(label);
      scene.add(pole, cloth);
      f = { pole, cloth, label };
      flags.set(name, f);
    }
    return f;
  }

  // Pointer: hover shows a note about the block, click opens it.
  const ray = new THREE.Raycaster();
  const ptr = new THREE.Vector2();
  let hovered: number | null = null;
  function pick(ev: PointerEvent) {
    const r = canvas.getBoundingClientRect();
    ptr.set(((ev.clientX - r.left) / r.width) * 2 - 1, -((ev.clientY - r.top) / r.height) * 2 + 1);
    ray.setFromCamera(ptr, camera);
    const hit = ray.intersectObjects([...slabs.values()].map((s) => s.body))[0];
    return hit ? (hit.object.userData.height as number) : null;
  }
  canvas.addEventListener("pointermove", (ev) => {
    const h = pick(ev);
    hovered = h;
    canvas.style.cursor = h === null ? "" : "pointer";
    const s = h === null ? null : slabs.get(h);
    if (!s) {
      tip.hidden = true;
      return;
    }
    const b = s.b;
    const how = b.kind === "pow" ? "Mined" : b.kind === "pos" ? "Staked" : "The first block";
    tip.innerHTML = `<b>Block #${b.height}</b><span>${b.kind === "genesis" ? how : `${how} by ${nameOf(b.producer)}${b.round ? `, on try ${b.round + 1}` : ""}`}</span>
      <span>${b.txs} transaction${b.txs === 1 ? "" : "s"}</span><em>${b.final ? "Final. It can never be rewritten." : "Not final yet."}</em>`;
    const r = stage.getBoundingClientRect();
    tip.style.transform = `translate(${Math.min(ev.clientX - r.left + 14, r.width - 260)}px, ${ev.clientY - r.top + 14}px)`;
    tip.hidden = false;
  });
  canvas.addEventListener("pointerleave", () => { tip.hidden = true; hovered = null; });
  canvas.addEventListener("click", (ev) => { const h = pick(ev); if (h !== null) onPick(h); });

  // Size and theme.
  function resize() {
    const w = stage.clientWidth, h = stage.clientHeight;
    renderer.setSize(w, h, false);
    camera.aspect = w / h;
    // Narrow screens pull back so the chain still fits.
    camera.fov = w < 700 ? 40 : 28;
    camera.updateProjectionMatrix();
  }
  const ro = new ResizeObserver(resize);
  ro.observe(stage);
  resize();
  const mq = matchMedia("(prefers-color-scheme: dark)");
  const retheme = () => {
    C = colors();
    (scene.fog as THREE.Fog).color = C.paper;
    rowMat.color = C.rule;
    redMat.color = C.red;
    for (const s of slabs.values()) {
      s.body.material = bodyMat(s.b);
      (s.edges.material as THREE.LineBasicMaterial).color = C.ink;
      (s.stamp.material as THREE.MeshBasicMaterial).color = C.red;
      s.link.children.forEach((r) => ((r as THREE.Mesh).material as THREE.MeshLambertMaterial).color = C.ink);
    }
    for (const f of flags.values()) {
      (f.pole.material as THREE.MeshLambertMaterial).color = C.ink;
    }
  };
  mq.addEventListener("change", retheme);

  const v = new THREE.Vector3();
  function place(el: HTMLElement, x: number, y: number, z: number) {
    v.set(x, y, z).project(camera);
    const vis = v.z < 1 && Math.abs(v.x) < 1.05 && Math.abs(v.y) < 1.05;
    el.style.opacity = vis ? "" : "0";
    el.style.transform = `translate(${((v.x + 1) / 2) * stage.clientWidth}px, ${((1 - v.y) / 2) * stage.clientHeight}px)`;
  }

  let visible = true;
  const io = new IntersectionObserver((e) => (visible = e[0].isIntersecting));
  io.observe(stage);
  let raf = 0;
  let last = performance.now();
  function frame(now: number) {
    raf = requestAnimationFrame(frame);
    const dt = Math.min((now - last) / 1000, 0.1);
    last = now;
    if (!visible || document.hidden) return;
    glide *= Math.pow(0.02, dt); // eases out over about a second
    if (Math.abs(glide) < 0.001) glide = 0;
    const narrow = stage.clientWidth < 700;
    // Aim a little in front of the chain so it sits in the upper part of the picture, clear of
    // the two panels; the newest block lands about three quarters of the way across.
    if (narrow) {
      look.set(-3.2, 0, -0.6);
      camera.position.set(look.x + 3.2, 9, look.z + 12.5);
    } else {
      look.set(-6.8, 0, 2.2);
      camera.position.set(look.x + 2.2, 10.5, look.z + 16);
    }
    camera.lookAt(look);
    cols.position.x = glide % SPACING;

    for (const s of slabs.values()) {
      const x = (s.b.height - tipH) * SPACING + glide;
      if (s.drop > 0) s.drop = Math.max(0, s.drop - dt * 2.2);
      const fall = s.drop * s.drop * 3;
      s.group.position.set(x, fall, 0);
      s.group.rotation.z = s.drop * 0.25;
      if (s.stampT < 1) {
        s.stampT = Math.min(1, s.stampT + dt * 3.2);
        const k = 1 + (1 - s.stampT) * 0.9;
        s.stamp.scale.set(k, k, k);
        (s.stamp.material as THREE.MeshBasicMaterial).opacity = s.stampT;
      }
      const el = tick(s.b.height);
      place(el, x, 0, D / 2 + 0.95);
      el.classList.toggle("on", hovered === s.b.height);
      // On a phone, number every third block so the labels don't pile up.
      el.classList.toggle("dim", narrow && (tipH - s.b.height) % 3 !== 0);
    }
    for (let i = leaving.length - 1; i >= 0; i--) {
      const s = leaving[i];
      s.leaving += dt * 0.9;
      s.group.position.z = s.leaving * s.leaving * 9;
      s.group.position.x = (s.b.height - tipH) * SPACING + glide;
      s.group.rotation.y = s.leaving * 0.6;
      const m = s.body.material as THREE.MeshLambertMaterial;
      m.transparent = true;
      m.opacity = Math.max(0, 0.7 - s.leaving * 0.7);
      (s.edges.material as THREE.LineBasicMaterial).transparent = true;
      (s.edges.material as THREE.LineBasicMaterial).opacity = m.opacity;
      s.stamp.visible = false;
      s.link.visible = false;
      if (s.leaving >= 1) {
        scene.remove(s.group);
        leaving.splice(i, 1);
      }
    }

    // Flags: where each node's copy of the chain ends. Nodes that agree share one flag, so when
    // the network splits or an attacker forks the chain, you see the flags pull apart.
    const groups = new Map<string, { at: number; online: boolean; names: string[]; ahead: number }>();
    const shown = nodes.filter((n) => !n.hidden);
    const onlineCount = shown.filter((n) => n.online).length;
    for (const n of shown) {
      // A node ahead of this chain (on the other side of a split, say) is pinned to the tip.
      const at = Math.min(Math.max(n.height, tipH - SHOWN + 1), tipH);
      // A block or so ahead is just news still spreading; only a real lead gets its own flag.
      const lead = n.height > tipH + 1;
      const key = `${n.online ? "on" : "off"}:${at}:${lead ? "ahead" : ""}`;
      const g = groups.get(key) ?? { at, online: n.online, names: [], ahead: 0 };
      g.names.push(n.name);
      if (lead) g.ahead = Math.max(g.ahead, n.height - tipH);
      groups.set(key, g);
    }
    const perX = new Map<number, number>();
    for (const [key, g] of groups) {
      const f = flag(key);
      const k = perX.get(g.at) ?? 0;
      perX.set(g.at, k + 1);
      const x = (g.at - tipH) * SPACING + glide;
      const z = -D / 2 - 0.45 - k * 0.9;
      const up = g.online ? 1 : 0.55;
      f.pole.position.set(x, 1.1 * up, z);
      f.pole.scale.y = up;
      f.cloth.position.set(x + 0.3, 2.05 * up, z);
      (f.cloth.material as THREE.MeshLambertMaterial).color = g.online ? C.ink : C.rule;
      f.label.classList.toggle("off", !g.online);
      const all = g.online && g.names.length === onlineCount && onlineCount > 2;
      const names = all ? `All ${onlineCount} nodes` : g.names.length > 3 ? `${g.names.length} nodes` : g.names.join(", ");
      const where = g.ahead > 0 ? `, ahead at #${tipH + g.ahead}` : "";
      f.label.textContent = g.online ? names + where : `${names} (off)`;
      place(f.label, x + 0.05, 2.25 * up + 0.05, z);
      // Near the right edge, hang the label on the other side of the pole.
      f.label.classList.toggle("left", v.x > 0.55);
    }
    for (const [key, f] of flags) {
      if (!groups.has(key)) {
        scene.remove(f.pole, f.cloth);
        f.label.remove();
        flags.delete(key);
      }
    }
    renderer.render(scene, camera);
  }
  raf = requestAnimationFrame(frame);

  return {
    update,
    dispose() {
      cancelAnimationFrame(raf);
      ro.disconnect();
      io.disconnect();
      mq.removeEventListener("change", retheme);
      renderer.dispose();
      canvas.remove();
      labels.innerHTML = "";
    },
  };
}

export type Hero = NonNullable<ReturnType<typeof createHero>>;
export type { Json };
