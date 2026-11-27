#!/usr/bin/env node
/*
  Screenshots of the real Roblox GUI code, without Studio.
    node tools/gui_render/shoot.js                 snapshot (lune run tests/gui_snapshot) + render all
    node tools/gui_render/shoot.js --render-only   just re-render the dumps already in out/dumps
    node tools/gui_render/shoot.js --dump some.json [--png some.png]   draw one dump file
    options: --device pc|phone|tablet   --states menu,hud (prefixes work)   --scale 2 (hi-dpi PNGs)
             --bg city|dark|none   --no-topbar   --folder-padding off   --outline
  Writes tools/gui_render/out/<device>/<state>.png and tools/gui_render/out/index.html.
  Run from anywhere; the Lune step runs from the repo root.
*/
"use strict";
const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");
const { pathToFileURL } = require("url");

const HERE = __dirname;
const ROOT = path.resolve(HERE, "..", "..");
const OUT = path.join(HERE, "out");
const DUMPS = path.join(OUT, "dumps");

function parseArgs(argv) {
  const a = { scale: 1, bg: "city", topbar: true, folderPadding: true, outline: false, renderOnly: false };
  for (let i = 0; i < argv.length; i++) {
    const k = argv[i];
    const next = () => argv[++i];
    if (k === "--render-only" || k === "--no-snapshot") a.renderOnly = true;
    else if (k === "--device") a.device = next();
    else if (k === "--states") a.states = next();
    else if (k === "--scale") a.scale = Number(next()) || 1;
    else if (k === "--hidpi" || k === "--2x") a.scale = 2;
    else if (k === "--bg") a.bg = next();
    else if (k === "--no-topbar") a.topbar = false;
    else if (k === "--folder-padding") a.folderPadding = next() !== "off";
    else if (k === "--outline") a.outline = true;
    else if (k === "--dump") a.dump = next();
    else if (k === "--png") a.png = next();
    else if (k === "--help" || k === "-h") a.help = true;
    else { console.error("unknown option " + k); process.exit(2); }
  }
  return a;
}

function wanted(states, name) {
  if (!states) return true;
  return states.split(",").map((s) => s.trim()).filter(Boolean).some((w) => name === w || name.startsWith(w));
}

function snapshot(args) {
  const luneArgs = ["run", "tests/gui_snapshot"];
  if (args.device) luneArgs.push("--device", args.device);
  if (args.states) luneArgs.push("--states", args.states);
  console.log(`$ lune ${luneArgs.join(" ")}`);
  const r = spawnSync("lune", luneArgs, { cwd: ROOT, stdio: "inherit" });
  if (r.error) {
    console.error("couldn't run lune (" + r.error.message + "); rendering whatever dumps are already there");
    return false;
  }
  if (r.status !== 0) console.error("the snapshot step reported failures (exit " + r.status + "); rendering what it saved");
  return r.status === 0;
}

function collect(args) {
  const out = [];
  if (!fs.existsSync(DUMPS)) return out;
  for (const device of fs.readdirSync(DUMPS).sort()) {
    const dir = path.join(DUMPS, device);
    if (!fs.statSync(dir).isDirectory()) continue;
    if (args.device && device !== args.device && !device.startsWith(args.device + "-")) continue;
    let manifest = null;
    try { manifest = JSON.parse(fs.readFileSync(path.join(dir, "manifest.json"), "utf8")); } catch (e) { manifest = null; }
    const order = new Map();
    const skipped = new Set();
    for (const s of (manifest && manifest.states) || []) {
      order.set(s.name, s.index);
      if (!s.ok) skipped.add(s.name);
    }
    // a state that was skipped last time has no picture: drop an old one so it can't mislead
    for (const name of skipped) {
      const old = path.join(OUT, device, name + ".png");
      if (fs.existsSync(old)) fs.unlinkSync(old);
    }
    const files = fs.readdirSync(dir).filter((f) => f.endsWith(".json") && f !== "manifest.json");
    for (const f of files) {
      const state = f.replace(/\.json$/, "");
      if (!wanted(args.states, state) || skipped.has(state)) continue;
      out.push({ device, state, file: path.join(dir, f), index: order.has(state) ? order.get(state) : 999, manifest });
    }
  }
  out.sort((a, b) => a.device.localeCompare(b.device) || a.index - b.index || a.state.localeCompare(b.state));
  return out;
}

function contactSheet(results) {
  const byDevice = new Map();
  for (const r of results) {
    if (!byDevice.has(r.device)) byDevice.set(r.device, []);
    byDevice.get(r.device).push(r);
  }
  const esc = (s) => String(s || "").replace(/&/g, "&amp;").replace(/</g, "&lt;");
  let html = `<!doctype html><meta charset="utf-8"><title>GUI Snapshots</title>
<style>body{margin:0;padding:20px 24px;background:#0b0c10;color:#ece8e1;font:14px/1.45 system-ui,sans-serif}
h1{font-size:20px;margin:0 0 4px}h2{font-size:16px;margin:28px 0 10px;color:#edc472;text-transform:uppercase;letter-spacing:.05em}
.grid{display:flex;flex-wrap:wrap;gap:18px}.card{background:#14161b;border:1px solid #2e323a;border-radius:3px;padding:10px;max-width:100%}
.card img{display:block;max-width:100%;height:auto;border:1px solid #2e323a}.card b{font-size:15px}.card p{margin:4px 0 8px;color:#a8aab0;max-width:720px}
.skip{color:#e2564c}</style><h1>GUI snapshots</h1><p>The real client UI (src/client) driven by tests/gui_snapshot.luau and drawn by tools/gui_render. Generated ${new Date().toISOString()}.</p>`;
  for (const [device, list] of byDevice) {
    html += `<h2>${esc(device)}</h2><div class="grid">`;
    for (const r of list) {
      const width = device.startsWith("phone") ? 390 : 720;
      html += `<div class="card"><b>${esc(r.state)}</b><p>${esc(r.note)}</p>` +
        (r.png ? `<a href="${esc(path.relative(OUT, r.png))}"><img src="${esc(path.relative(OUT, r.png))}" width="${width}"></a>` : `<p class="skip">not drawn: ${esc(r.error)}</p>`) + `</div>`;
    }
    const manifest = list[0] && list[0].manifest;
    for (const s of (manifest && manifest.states) || []) {
      if (!s.ok) html += `<div class="card"><b>${esc(s.name)}</b><p class="skip">skipped: ${esc(s.error)}</p></div>`;
    }
    html += `</div>`;
  }
  fs.writeFileSync(path.join(OUT, "index.html"), html);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    console.log(fs.readFileSync(__filename, "utf8").split("*/")[0].replace(/^[\s\S]*?\/\*/, ""));
    return;
  }
  let dumps;
  if (args.dump) {
    // one file, wherever it is
    const file = path.resolve(args.dump);
    const dump = JSON.parse(fs.readFileSync(file, "utf8"));
    dumps = [{ device: dump.device || "dump", state: dump.state || path.basename(file, ".json"), file, index: 0, manifest: null, png: args.png && path.resolve(args.png) }];
  } else {
    if (!args.renderOnly) snapshot(args);
    dumps = collect(args);
  }
  if (!dumps.length) {
    console.error("no dumps in " + DUMPS + " (run without --render-only, or lune run tests/gui_snapshot)");
    process.exit(1);
  }

  let chromium;
  try { ({ chromium } = require("playwright")); } catch (e) {
    console.error("playwright isn't installed (npm i -g playwright, then npx playwright install chromium)");
    process.exit(1);
  }
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 }, deviceScaleFactor: args.scale });
  const pageErrors = [];
  page.on("pageerror", (e) => pageErrors.push(e.message));
  page.on("console", (m) => { if (m.type() === "error" && !/fonts\.g/.test(m.text())) pageErrors.push(m.text()); });
  // three.js is vendored; if the page ever asks the CDN for it (blocked in headless runs), serve ours
  const three = fs.readFileSync(path.join(HERE, "vendor", "three.min.js"), "utf8");
  await page.route("**/three.min.js", (route) => route.fulfill({ status: 200, contentType: "application/javascript", body: three }));
  await page.goto(pathToFileURL(path.join(HERE, "render.html")).href + "?shot=1");

  const results = [];
  for (const d of dumps) {
    const t0 = Date.now();
    const dump = JSON.parse(fs.readFileSync(d.file, "utf8"));
    const [w, h] = dump.screen;
    await page.setViewportSize({ width: w, height: h });
    pageErrors.length = 0;
    const res = { device: d.device, state: d.state, note: dump.note, png: null, manifest: d.manifest };
    try {
      const out = await page.evaluate(([dumpArg, o]) => window.renderDump(dumpArg, o), [dump, { backdrop: args.bg, topbar: args.topbar, folderPadding: args.folderPadding, outline: args.outline, dpr: args.scale }]);
      const png = d.png || path.join(OUT, d.device, d.state + ".png");
      fs.mkdirSync(path.dirname(png), { recursive: true });
      await page.screenshot({ path: png, clip: { x: 0, y: 0, width: w, height: h } });
      res.png = png;
      const notes = (out && out.warnings || []).concat(pageErrors);
      console.log(`  ${path.relative(process.cwd(), png)}  ${w}x${h}${args.scale !== 1 ? " @" + args.scale + "x" : ""}  ${Date.now() - t0} ms${notes.length ? "  (" + notes.slice(0, 3).join("; ") + ")" : ""}`);
    } catch (e) {
      res.error = e.message.split("\n")[0];
      console.log(`  ${d.device}/${d.state}: couldn't draw it: ${res.error}`);
    }
    results.push(res);
  }
  await browser.close();
  if (!args.dump) contactSheet(results);
  const drawn = results.filter((r) => r.png).length;
  if (!args.dump) console.log(`${drawn} of ${results.length} drawn -> ${path.relative(process.cwd(), OUT) || "."}/  (contact sheet: ${path.relative(process.cwd(), path.join(OUT, "index.html"))})`);
  if (drawn === 0) process.exit(1);
}

main().catch((e) => { console.error(e); process.exit(1); });
