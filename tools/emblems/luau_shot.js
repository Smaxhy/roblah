// Draws the emblems as Roblox builds them: lune run tests/emblem_check --dump, then the GUI tree
// is drawn by tools/gui_render (the renderer for real Roblox GUI dumps) and screenshotted.
//   node tools/emblems/luau_shot.js [out.png]     default: tools/emblems/sheet/luau.png
// The renderer doesn't draw a UIGradient under a UIStroke, so half-ring arcs show as full rings
// here; tools/emblems/parity.js checks those cuts number by number instead.
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');
const { pathToFileURL } = require('url');
const { chromium } = require('playwright');

const ROOT = path.resolve(__dirname, '..', '..');
const RENDER = path.join(ROOT, 'tools', 'gui_render');
const OUT = path.resolve(process.argv[2] || path.join(__dirname, 'sheet', 'luau.png'));

(async () => {
  if (!fs.existsSync(path.join(RENDER, 'render.html'))) {
    console.error('tools/gui_render is not here');
    process.exit(1);
  }
  const dumpPath = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'emblems-')), 'dump.json');
  const r = spawnSync('lune', ['run', 'tests/emblem_check', '--dump', dumpPath], { cwd: ROOT, encoding: 'utf8' });
  if (r.status !== 0) {
    console.error(r.stdout, r.stderr);
    process.exit(1);
  }
  const dump = JSON.parse(fs.readFileSync(dumpPath, 'utf8'));
  const [w, h] = dump.screen;
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: 1 });
  const errors = [];
  page.on('pageerror', (e) => errors.push(e.message));
  const three = path.join(RENDER, 'vendor', 'three.min.js');
  if (fs.existsSync(three)) {
    const body = fs.readFileSync(three, 'utf8');
    await page.route('**/three.min.js', (route) => route.fulfill({ status: 200, contentType: 'application/javascript', body }));
  }
  await page.route(/fonts\.(googleapis|gstatic)\.com/, (route) => route.abort());
  await page.goto(pathToFileURL(path.join(RENDER, 'render.html')).href + '?shot=1');
  await page.evaluate((d) => window.renderDump(d, { backdrop: 'dark', topbar: false, dpr: 1 }), dump);
  fs.mkdirSync(path.dirname(OUT), { recursive: true });
  await page.screenshot({ path: OUT, clip: { x: 0, y: 0, width: w, height: h } });
  await browser.close();
  if (errors.length) console.error(errors.join('\n'));
  console.log(OUT);
})();
