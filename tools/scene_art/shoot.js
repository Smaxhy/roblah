// Screenshots of tools/scene_sheet.html (the scene art contact sheet) with Playwright.
//   node tools/scene_art/shoot.js [mode=small|big|seeds|card] [scenes=a,b|all] [seed=1] [out.png] [dpr=1]
// Writes into tools/scene_art/shots/ unless given a path.
const path = require("path");
const fs = require("fs");
const { chromium } = require("playwright");

const [mode = "small", scenes = "all", seed = "1", outArg, dprArg] = process.argv.slice(2);
const dir = path.join(__dirname, "shots");
fs.mkdirSync(dir, { recursive: true });
const out = outArg ? path.resolve(outArg) : path.join(dir, `${mode}${scenes === "all" ? "" : "_" + scenes.replace(/,/g, "-")}_s${seed}.png`);
const sheet = "file://" + path.join(__dirname, "..", "scene_sheet.html");

(async () => {
  const browser = await chromium.launch();
  const width = mode === "big" ? 940 : mode === "seeds" ? 1530 : 1530;
  const page = await browser.newPage({ viewport: { width, height: 800 }, deviceScaleFactor: Number(dprArg || 1) });
  const errors = [];
  page.on("pageerror", (e) => errors.push(e.message));
  page.on("console", (m) => { if (m.type() === "error") errors.push(m.text()); });
  const q = new URLSearchParams({ mode, seed });
  if (process.env.FADE) q.set("fade", process.env.FADE);
  if (scenes !== "all") q.set("scene", scenes);
  await page.goto(`${sheet}?${q}`);
  await page.evaluate(() => window.__ready);
  await page.waitForTimeout(300);
  await page.screenshot({ path: out, fullPage: true });
  await browser.close();
  if (errors.length) {
    console.error("page errors:\n" + errors.join("\n"));
    process.exitCode = 1;
  }
  console.log(out);
})();
