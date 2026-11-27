// Checks that the Roblox emblems match the browser ones part for part: builds every emblem with
// the real Luau module (lune run tests/emblem_check --dump), then compares each Frame's position,
// size, rotation, colors, stroke, corner and cut with what preview/emblems.js computes.
//   node tools/emblems/parity.js [dump.json]   (no argument: makes a fresh dump in a temp dir)
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const ROOT = path.resolve(__dirname, '..', '..');
const E = require(path.join(ROOT, 'preview', 'emblems.js'));

let dumpPath = process.argv[2];
if (!dumpPath) {
  dumpPath = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'emblems-')), 'dump.json');
  const r = spawnSync('lune', ['run', 'tests/emblem_check', '--dump', dumpPath], { cwd: ROOT, encoding: 'utf8' });
  if (r.status !== 0) {
    console.error(r.stdout, r.stderr);
    process.exit(1);
  }
}
const dump = JSON.parse(fs.readFileSync(dumpPath, 'utf8'));

const mix = (a, b, t) => a.map((v, j) => Math.round(v + (b[j] - v) * t));
function inks(def, logo) {
  const accent = def.color;
  const line = logo ? E.bone : def.ink || mix(accent, E.bone, E.inkMix);
  return {
    l: [line, 1], m: [line, 0.5], a: [accent, 1], d: [accent, 0.35],
    h: [mix(accent, [255, 255, 255], 0.5), 1], k: [E.dark, 1],
  };
}
const inkOf = (i, set) => (Array.isArray(i) ? [i, 1] : set[i] || set.l);
function cutKeys(a, b) {
  const k = [];
  if (a > 0) k.push([0, 1], [a - 0.001, 1], [a, 0]);
  else k.push([0, 0]);
  if (b < 1) k.push([b, 0], [b + 0.001, 1], [1, 1]);
  else k.push([1, 0]);
  return k;
}

let checked = 0;
const problems = [];
const near = (a, b) => Math.abs(a - b) <= 0.001; // pixels
function compare(label, def, S, tree, logo) {
  const W = E.weights(S);
  const set = inks(def, logo);
  const parts = (tree.children || []).filter((c) => c.class === 'Frame');
  if (parts.length !== def.ops.length) {
    problems.push(`${label}: ${parts.length} parts, expected ${def.ops.length}`);
    return;
  }
  def.ops.forEach((op, j) => {
    const fr = E.frameOf(op, S, W);
    const p = parts[j].props;
    const kids = parts[j].children || [];
    const bad = (what, got, want) => problems.push(`${label} part ${j + 1} (${op.t}): ${what} ${JSON.stringify(got)} vs preview ${JSON.stringify(want)}`);
    const [rgb, alpha] = inkOf(op.i, set);
    // parts are placed in Scale; Roblox (and Lune) keep Scale as a 32-bit float
    const px = (u) => u * S;
    if (p.Position[1] || p.Position[3] || p.Size[1] || p.Size[3]) bad('offsets', [p.Position, p.Size], 'Scale only');
    if (!near(px(p.Position[0]), fr.x) || !near(px(p.Position[2]), fr.y)) bad('position', [px(p.Position[0]), px(p.Position[2])], [fr.x, fr.y]);
    if (!near(px(p.Size[0]), fr.w) || !near(px(p.Size[2]), fr.h)) bad('size', [px(p.Size[0]), px(p.Size[2])], [fr.w, fr.h]);
    if (!near(p.Rotation, fr.rot)) bad('rotation', p.Rotation, fr.rot);
    const stroke = kids.find((c) => c.class === 'UIStroke');
    if (fr.st === 0) {
      if (stroke) bad('stroke', 'present', 'none');
      if (!near(p.BackgroundTransparency, 1 - alpha)) bad('fill transparency', p.BackgroundTransparency, 1 - alpha);
      if (p.BackgroundColor3.join() !== rgb.join()) bad('fill color', p.BackgroundColor3, rgb);
    } else {
      if (!stroke) return bad('stroke', 'missing', fr.st);
      if (p.BackgroundTransparency !== 1) bad('outline background', p.BackgroundTransparency, 1);
      if (stroke.props.Thickness !== fr.st) bad('stroke thickness', stroke.props.Thickness, fr.st);
      if (stroke.props.Color.join() !== rgb.join()) bad('stroke color', stroke.props.Color, rgb);
      if (!near(stroke.props.Transparency, 1 - alpha)) bad('stroke transparency', stroke.props.Transparency, 1 - alpha);
      if (stroke.props.LineJoinMode !== 'Miter') bad('line join', stroke.props.LineJoinMode, 'Miter');
    }
    const corner = kids.find((c) => c.class === 'UICorner');
    if (!!corner !== !!fr.round) bad('corner', !!corner, !!fr.round);
    const holder = fr.st === 0 ? parts[j] : stroke;
    const grad = (holder.children || []).find((c) => c.class === 'UIGradient');
    if (!!grad !== !!fr.cut) return bad('cut', !!grad, !!fr.cut);
    if (grad) {
      if (!near(grad.props.Rotation, fr.cut.r)) bad('cut rotation', grad.props.Rotation, fr.cut.r);
      const want = cutKeys(fr.cut.a, fr.cut.b);
      const got = grad.props.Transparency.map((k) => [k[0], k[1]]);
      if (got.length !== want.length || got.some((k, n) => !near(k[0], want[n][0]) || k[1] !== want[n][1])) bad('cut keys', got, want);
    }
    checked++;
  });
}

for (const id of E.ids) {
  for (const S of [64, 20]) compare(`${id} @${S}`, E.defs[id], S, dump.emblems[id][String(S)], false);
}
compare('unknown id @64', E.fallback, 64, dump.emblems['no.such.emblem']['64'], false);
for (const S of [128, 64, 40, 20]) compare(`logo @${S}`, E.logoDef, S, dump.emblems['logo@' + S], true);

if (problems.length) {
  console.error(problems.slice(0, 40).join('\n'));
  console.error(`${problems.length} mismatches between Emblem.luau and preview/emblems.js`);
  process.exit(1);
}
console.log(`parity: ${checked} parts built by Emblem.luau match preview/emblems.js`);
