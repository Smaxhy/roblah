// Writes what preview/scenes.js draws (every element's box, rotation, color, alpha, text) for
// each scene and a few seeds at 900x260, for tools/scene_art/crosscheck.luau to compare with
// the Frames SceneArt.luau builds.
//   node tools/scene_art/crosscheck.js && lune run tools/scene_art/crosscheck.luau
const fs = require("fs");
const path = require("path");
const vm = require("vm");

const ROOT = path.join(__dirname, "..", "..");
const ctx = { window: {} };
vm.createContext(ctx);
vm.runInContext(fs.readFileSync(path.join(ROOT, "preview", "scenes.js"), "utf8"), ctx);
const SceneArt = ctx.window.SceneArt;

const W = 900, H = 260;
const SEEDS = [1, 2, 3, 4, 5, 99, 2024];

function walk(ops, px, py, pw, ph, uw, uh, out) {
  for (const op of ops) {
    const w = op.yy ? (op.w / uh) * ph : (op.w / uw) * pw;
    const h = (op.h / uh) * ph;
    const x = px + (op.x / uw) * pw - (op.ax || 0) * w;
    const y = py + (op.y / uh) * ph - (op.ay || 0) * h;
    out.push({
      k: op.k === "T" ? "TextLabel" : "Frame",
      x, y, w, h,
      rot: op.rot || 0,
      c: op.c == null ? null : op.c,
      a: op.c == null && op.k !== "T" ? 0 : op.a == null ? 1 : op.a,
      t: op.k === "T" ? String(op.t) : null,
    });
    if (op.o) {
      const u = op.u || [op.w, op.h];
      walk(op.o, x, y, w, h, u[0], u[1], out);
    }
  }
  return out;
}

const result = { W, H, cases: [] };
for (const id of SceneArt.scenes) {
  for (const seed of SEEDS) {
    const r = SceneArt.build(id, seed);
    result.cases.push({ id, seed, bg: r.bg, items: walk(r.o, 0, 0, W, H, 100, 100, []) });
  }
}
const out = path.join(__dirname, "shots", "crosscheck.json");
fs.mkdirSync(path.dirname(out), { recursive: true });
fs.writeFileSync(out, JSON.stringify(result));
console.log(`wrote ${out}: ${result.cases.length} cases`);
