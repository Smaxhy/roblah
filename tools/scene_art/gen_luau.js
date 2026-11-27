// Writes the scene geometry from preview/scenes.js into src/client/SceneArt.luau
// (between the GENERATED markers), after checking what Roblox would refuse or draw wrong.
//   node tools/scene_art/gen_luau.js          write
//   node tools/scene_art/gen_luau.js --check  only check and print instance counts
const fs = require("fs");
const path = require("path");
const vm = require("vm");

const ROOT = path.join(__dirname, "..", "..");
const JS = path.join(ROOT, "preview", "scenes.js");
const LUAU = path.join(ROOT, "src", "client", "SceneArt.luau");
const BEGIN = "--[[ GENERATED SCENES: tools/scene_art/gen_luau.js from preview/scenes.js. Edit the JS, then run it. ]]";
const END = "--[[ END GENERATED SCENES ]]";
const LIMIT = 160; // GuiObjects per scene, every chance op drawn

function load() {
  const ctx = { window: {} };
  vm.createContext(ctx);
  vm.runInContext(fs.readFileSync(JS, "utf8"), ctx, { filename: JS });
  return ctx.window.SceneArt;
}

const KEY_ORDER = ["n", "k", "p", "pn", "x", "y", "w", "h", "ax", "ay", "yy", "rot", "c", "a", "r", "g", "s", "t", "f", "xa", "clip", "u", "an", "o"];

function num(v) {
  if (typeof v !== "number" || !isFinite(v)) throw new Error("bad number " + v);
  // the tree is already rounded by scenes.js (3 decimals below 10, else 2): print it as is
  const k = Math.abs(v) < 10 ? 1000 : 100;
  if (Math.abs(Math.round(v * k) / k - v) > 1e-9) throw new Error("unrounded number " + v);
  let s = v.toString();
  if (s === "-0") s = "0";
  if (s.startsWith("0.")) s = s.slice(1);
  else if (s.startsWith("-0.")) s = "-" + s.slice(2);
  return s;
}
function str(s) {
  return JSON.stringify(String(s)); // JSON escapes are valid Luau string escapes for this content
}
function value(v) {
  if (typeof v === "number") return num(v);
  if (typeof v === "string") return str(v);
  if (typeof v === "boolean") return v ? "true" : "false";
  if (Array.isArray(v)) return "{" + v.map(value).join(",") + "}";
  if (v && typeof v === "object") {
    if (v.R) return "{R={" + v.R.map(value).join(",") + "}" + (v.n != null ? ",n=" + str(v.n) : "") + "}";
    if (v.P) return "{P={" + v.P.map(value).join(",") + "}" + (v.n != null ? ",n=" + str(v.n) : "") + "}";
    return "{" + Object.keys(v).map((k) => k + "=" + value(v[k])).join(",") + "}";
  }
  throw new Error("cannot serialise " + JSON.stringify(v));
}

const problems = [];
function checkSeq(where, keys) {
  if (keys.length > 20) problems.push(`${where}: ${keys.length} keypoints (Roblox allows 20)`);
  if (keys.length < 2) problems.push(`${where}: needs 2+ keypoints`);
  if (keys[0][0] !== 0 || keys[keys.length - 1][0] !== 1) problems.push(`${where}: keypoints must start at 0 and end at 1`);
  for (let i = 1; i < keys.length; i++) {
    if (!(keys[i][0] > keys[i - 1][0])) problems.push(`${where}: keypoint times must increase (${keys[i - 1][0]} -> ${keys[i][0]})`);
  }
}
const COLOR = /^#[0-9a-f]{6}$/;
function checkColor(where, c) {
  const list = c && c.P ? c.P : [c];
  for (const x of list) if (typeof x !== "string" || !COLOR.test(x)) problems.push(`${where}: bad color ${JSON.stringify(x)}`);
}

function serialise(ops, depth, where, rotated, counts) {
  const pad = "\t".repeat(depth);
  const lines = [];
  ops.forEach((op, i) => {
    const here = `${where}/${op.n || i}`;
    const isRot = rotated || (op.rot != null && op.rot !== 0);
    if (op.clip && isRot) problems.push(`${here}: clipping under a rotation (Roblox ignores it)`);
    if (op.k !== "T" && op.c != null) checkColor(here, op.c);
    if (op.k === "T") {
      checkColor(here, op.c);
      if (op.t == null) problems.push(`${here}: text without t`);
    }
    if (op.g) {
      if (op.g.c) { checkSeq(here + " gradient color", op.g.c); op.g.c.forEach((k) => checkColor(here, k[1])); }
      if (op.g.a) checkSeq(here + " gradient alpha", op.g.a);
      if (op.g.r != null && op.g.r % 90 !== 0 && op.w !== op.h) problems.push(`${here}: gradient rotation ${op.g.r} on a non-square (keep to multiples of 90)`);
    }
    for (const f of ["x", "y", "w", "h"]) if (op[f] == null) problems.push(`${here}: missing ${f}`);
    counts.max += 1;
    const keys = Object.keys(op).filter((k) => op[k] !== undefined && op[k] !== null && k !== "o");
    for (const k of keys) if (!KEY_ORDER.includes(k)) problems.push(`${here}: unknown key ${k}`);
    keys.sort((a, b) => KEY_ORDER.indexOf(a) - KEY_ORDER.indexOf(b));
    // x, y, w, h and the color go first, by position: {x, y, w, h, color, key=value...}
    const POS = ["x", "y", "w", "h", "c"];
    const head0 = POS.map((k) => (op[k] == null ? "nil" : value(op[k])));
    while (head0.length && head0[head0.length - 1] === "nil") head0.pop();
    const rest = keys.filter((k) => !POS.includes(k)).map((k) => `${k}=${value(op[k])}`);
    let head = "{" + head0.concat(rest).join(",");
    if (op.o && op.o.length) {
      lines.push(pad + head + ",o={");
      lines.push(...serialise(op.o, depth + 1, here, isRot, counts));
      lines.push(pad + "}},");
    } else {
      lines.push(pad + head + "},");
    }
  });
  return lines;
}

// The most GuiObjects a list can produce: every chance op drawn, except that ops sharing a
// named draw (pn) count only for draws that can happen together (either/or bands).
function maxCount(ops) {
  let total = 0;
  const groups = {};
  for (const op of ops) {
    const n = 1 + (op.o ? maxCount(op.o) : 0);
    if (op.pn != null && op.p != null) (groups[op.pn] = groups[op.pn] || []).push([op.p, n]);
    else total += n;
  }
  for (const list of Object.values(groups)) {
    const cuts = new Set([0]);
    for (const [pp] of list) {
      if (Array.isArray(pp)) { cuts.add(pp[0]); cuts.add(pp[1]); } else cuts.add(pp);
    }
    let best = 0;
    for (const c of cuts) {
      const u = Math.min(c + 1e-9, 1 - 1e-9);
      let sum = 0;
      for (const [pp, n] of list) if (Array.isArray(pp) ? u >= pp[0] && u < pp[1] : u < pp) sum += n;
      best = Math.max(best, sum);
    }
    total += best;
  }
  return total;
}

const SceneArt = load();
const out = [BEGIN, "DATA = {"];
const table = [];
const partial = process.argv.includes("--partial"); // while scenes are being written
for (const id of SceneArt.scenes) {
  if (!SceneArt._defs[id]) {
    if (!partial) problems.push(`${id}: no definition`);
    continue;
  }
  const t = SceneArt.tree(id);
  const counts = { max: 1 }; // the root frame
  const body = serialise(t.o, 2, id, false, counts);
  counts.max = 1 + maxCount(t.o);
  if (counts.max > LIMIT) problems.push(`${id}: up to ${counts.max} GuiObjects (limit ${LIMIT})`);
  table.push([id, counts.max]);
  out.push(`\t${id} = { bg = ${str(t.bg)}, o = {`);
  out.push(...body);
  out.push("\t} },");
}
out.push("}", END);

console.log(table.map(([id, n]) => `${id.padEnd(11)} ${n}`).join("\n"));
if (problems.length) {
  console.error("\nPROBLEMS:\n" + problems.join("\n"));
  process.exit(1);
}
if (!process.argv.includes("--check")) {
  const src = fs.readFileSync(LUAU, "utf8");
  const a = src.indexOf(BEGIN), b = src.indexOf(END);
  if (a < 0 || b < 0) throw new Error("markers not found in " + LUAU);
  const next = src.slice(0, a) + out.join("\n") + src.slice(b + END.length);
  fs.writeFileSync(LUAU, next);
  console.log(`\nwrote ${LUAU} (${(next.length / 1024).toFixed(0)} KB)`);
}
