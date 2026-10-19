// The CoTdy coin in 3D: Coco and Teddy on heads, the chain on tails, a reeded gold edge. It turns
// slowly on its own; drag it to flip it yourself.

import * as THREE from "three";
import { RoomEnvironment } from "three/examples/jsm/environments/RoomEnvironment.js";

export function createCoin(box: HTMLElement, base = "brand/") {
  const canvas = document.createElement("canvas");
  canvas.setAttribute("role", "img");
  canvas.setAttribute("aria-label", "The CoTdy coin, turning: Coco and Teddy on one side, the EEZE Chain links on the other");
  box.prepend(canvas);
  let renderer: THREE.WebGLRenderer;
  try {
    renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
  } catch {
    canvas.remove();
    return null;
  }
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.toneMappingExposure = 0.92;

  const scene = new THREE.Scene();
  const pmrem = new THREE.PMREMGenerator(renderer);
  scene.environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
  const camera = new THREE.PerspectiveCamera(30, 1, 0.1, 50);
  camera.position.set(0, 0, 5.2);

  const key = new THREE.DirectionalLight(0xfff1d6, 1.6);
  key.position.set(-3, 4, 5);
  scene.add(key, new THREE.AmbientLight(0xffffff, 0.35));

  const load = new THREE.TextureLoader();
  const tex = (f: string) => {
    const t = load.load(base + f);
    t.colorSpace = THREE.SRGBColorSpace;
    t.anisotropy = 8;
    return t;
  };
  const heads = tex("cotdy-heads.webp");
  const tails = tex("cotdy-tails.webp");
  const edge = tex("cotdy-edge.webp");
  edge.wrapS = THREE.RepeatWrapping;

  // Two flat discs for the faces (their texture sits upright) and an open cylinder for the edge.
  const T = 0.11;
  const face = (map: THREE.Texture) => new THREE.MeshStandardMaterial({ map, metalness: 0.5, roughness: 0.42, envMapIntensity: 0.75 });
  const disc = new THREE.CircleGeometry(1, 160);
  const front = new THREE.Mesh(disc, face(heads));
  front.position.z = T / 2;
  const back = new THREE.Mesh(disc, face(tails));
  back.position.z = -T / 2;
  back.rotation.y = Math.PI;
  const rim = new THREE.Mesh(
    new THREE.CylinderGeometry(1, 1, T, 160, 1, true),
    new THREE.MeshStandardMaterial({ map: edge, metalness: 0.9, roughness: 0.3, color: 0xffe2a0 }),
  );
  rim.rotation.x = Math.PI / 2;
  const coin = new THREE.Group();
  coin.add(front, back, rim);
  const holder = new THREE.Group();
  holder.add(coin);
  scene.add(holder);

  function resize() {
    const w = box.clientWidth, h = box.clientHeight;
    renderer.setSize(w, h, false);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
  }
  const ro = new ResizeObserver(resize);
  ro.observe(box);
  resize();

  // Turns on its own; dragging hands control to you, then it settles back.
  const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
  let spin = 0.15, vel = reduce ? 0 : 0.55, dragging = false, lastX = 0, idle = 0;
  canvas.addEventListener("pointerdown", (e) => { dragging = true; lastX = e.clientX; canvas.setPointerCapture(e.pointerId); });
  canvas.addEventListener("pointermove", (e) => {
    if (!dragging) return;
    const dx = e.clientX - lastX;
    lastX = e.clientX;
    spin += dx * 0.012;
    vel = Math.max(-9, Math.min(9, dx * 0.6));
    idle = 0;
  });
  const stop = () => (dragging = false);
  canvas.addEventListener("pointerup", stop);
  canvas.addEventListener("pointercancel", stop);
  canvas.style.cursor = "grab";

  let visible = true;
  const io = new IntersectionObserver((e) => (visible = e[0].isIntersecting));
  io.observe(box);
  let raf = 0, last = performance.now(), t = 0;
  function frame(now: number) {
    raf = requestAnimationFrame(frame);
    const dt = Math.min((now - last) / 1000, 0.1);
    last = now;
    if (!visible || document.hidden) return;
    t += dt;
    if (!dragging) {
      idle += dt;
      const cruise = reduce ? 0 : 0.55;
      vel += (cruise - vel) * Math.min(1, dt * (idle > 1 ? 1.2 : 0.4));
      spin += vel * dt;
      // Without the slow turn, come to rest showing a face, not the edge.
      if (reduce && Math.abs(vel) < 0.4) spin += (Math.round(spin / Math.PI) * Math.PI - spin) * Math.min(1, dt * 4);
    }
    holder.rotation.y = spin;
    holder.rotation.x = reduce ? 0 : Math.sin(t * 0.7) * 0.08;
    holder.position.y = reduce ? 0 : Math.sin(t * 1.1) * 0.04;
    renderer.render(scene, camera);
  }
  raf = requestAnimationFrame(frame);

  return {
    dispose() {
      cancelAnimationFrame(raf);
      ro.disconnect();
      io.disconnect();
      renderer.dispose();
      pmrem.dispose();
      canvas.remove();
    },
  };
}
