// Screenshots tools/emblem_sheet.html (the emblem contact sheet) with Playwright.
//   node tools/emblems/shot.js [outDir]        -> one PNG per group, plus grid.png and logo.png
// Default outDir: tools/emblems/sheet
const path = require('path');
const fs = require('fs');
const { chromium } = require('playwright');

const SHEET = 'file://' + path.resolve(__dirname, '..', 'emblem_sheet.html');
const OUT = path.resolve(process.argv[2] || path.join(__dirname, 'sheet'));
const SHOTS = [
  ['grid', '?grid=1', 1],
  ['stat', '?group=stat', 1], ['cur', '?group=cur', 1], ['approach', '?group=approach', 1],
  ['style', '?group=style', 1], ['sin', '?group=sin', 1], ['faction', '?group=faction', 1],
  ['tab', '?group=tab', 1], ['misc', '?group=misc', 1], ['logo', '?group=logo', 1],
];

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const browser = await chromium.launch();
  const errors = [];
  for (const [name, query, scale] of SHOTS) {
    const page = await browser.newPage({ viewport: { width: 1120, height: 400 }, deviceScaleFactor: scale });
    page.on('pageerror', (e) => errors.push(name + ': ' + e.message));
    page.on('console', (m) => { if (m.type() === 'error' && !/fonts\.g|ERR_FAILED/.test(m.text())) errors.push(name + ': ' + m.text()); });
    // no web fonts needed to judge the shapes; don't wait on the network for them
    await page.route(/fonts\.(googleapis|gstatic)\.com/, (r) => r.abort());
    await page.goto(SHEET + query);
    await page.waitForSelector('body[data-ready="1"]', { timeout: 10000 });
    const file = path.join(OUT, name + '.png');
    await page.screenshot({ path: file, fullPage: true });
    console.log(file);
    await page.close();
  }
  await browser.close();
  if (errors.length) {
    console.error(errors.join('\n'));
    process.exit(1);
  }
})();
