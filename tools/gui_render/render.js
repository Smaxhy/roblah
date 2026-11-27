/*
  Draws a gui-snapshot dump (tests/gui_snapshot.luau) the way Roblox draws the same instances.

  The layout is worked out here with Roblox's rules rather than left to CSS, because Roblox's
  rules aren't CSS's: every GuiObject gets a pixel rect from its UDim2 Size/Position relative to
  its parent's content box (after UIPadding), minus AnchorPoint x its size; AutomaticSize grows a
  box to its text or its children (never below Size); UIListLayout / UIGridLayout place their
  siblings; ScrollingFrames lay their children out on a canvas. The browser is only asked to
  measure and draw text (same fonts, same wrapping) and to paint the boxes.

    GuiRender.render(dump, container, options) -> Promise<{ warnings }>
      options: backdrop "city" | "dark" | "none"   (the 3D City isn't GUI; this stands in)
               topbar true | false                 (Roblox's topbar buttons over the inset)
               folderPadding true | false           (does a parent's UIPadding move children
                                                     that sit in a Folder? true = assume yes)
               outline true                         (outline every GuiObject, for debugging)
               dpr number                            (canvas resolution for 3D and backdrop)
  What isn't faithful is listed in README.md.
*/
(function () {
  "use strict";

  const GUI = new Set(["Frame", "TextLabel", "TextButton", "TextBox", "ScrollingFrame", "ImageLabel", "ImageButton", "ViewportFrame", "CanvasGroup", "VideoFrame"]);
  const TEXT = new Set(["TextLabel", "TextButton", "TextBox"]);
  const MODS = new Set(["UICorner", "UIStroke", "UIGradient", "UIPadding", "UIListLayout", "UIGridLayout", "UIPageLayout", "UITableLayout", "UIAspectRatioConstraint", "UISizeConstraint", "UITextSizeConstraint", "UIScale", "UIFlexItem"]);
  const LAYER = new Set(["ScreenGui", "BillboardGui", "SurfaceGui"]);

  // ── small helpers ─────────────────────────────────────────────────────────
  const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
  const inf = (v) => (v === null || v === undefined ? Infinity : v);
  const rgba = (c, alpha) => `rgba(${c[0]},${c[1]},${c[2]},${clamp(alpha, 0, 1)})`;
  const udim = (u, size) => (u ? u[0] * size + u[1] : 0);
  const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  const align = (mode, free) => (mode === "Center" ? free / 2 : mode === "Right" || mode === "Bottom" ? free : 0);

  // ── fonts: Roblox families to the same (or closest) web fonts ─────────────
  // name in rbxasset://fonts/families/<Name>.json -> [css family, Google Fonts spec, fallback]
  const FONTS = {
    Oswald: ["Oswald", "Oswald:wght@200;300;400;500;600;700", "'Arial Narrow', sans-serif"],
    Merriweather: ["Merriweather", "Merriweather:ital,wght@0,300;0,400;0,700;0,900;1,300;1,400;1,700;1,900", "Georgia, serif"],
    GothamSSm: ["Montserrat", "Montserrat:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500;1,700", "Arial, sans-serif"], // Gotham isn't free: Montserrat is the closest
    Gotham: ["Montserrat", null, "Arial, sans-serif"],
    BuilderSans: ["Montserrat", null, "Arial, sans-serif"],
    RobotoMono: ["Roboto Mono", "Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400", "monospace"],
    SpecialElite: ["Special Elite", "Special+Elite", "'Courier New', monospace"],
    SourceSansPro: ["Source Sans 3", "Source+Sans+3:ital,wght@0,300;0,400;0,600;0,700;0,900;1,400;1,700", "Arial, sans-serif"],
    Arial: ["Arimo", "Arimo:ital,wght@0,400;0,700;1,400;1,700", "Arial, sans-serif"],
    LegacyArial: ["Arimo", null, "Arial, sans-serif"],
    Roboto: ["Roboto", "Roboto:ital,wght@0,300;0,400;0,500;0,700;0,900;1,400;1,700", "Arial, sans-serif"],
    RobotoCondensed: ["Roboto Condensed", "Roboto+Condensed:ital,wght@0,300;0,400;0,700;1,400", "'Arial Narrow', sans-serif"],
    Montserrat: ["Montserrat", null, "Arial, sans-serif"],
    Nunito: ["Nunito", "Nunito:ital,wght@0,300;0,400;0,600;0,700;0,800;0,900;1,400", "Arial, sans-serif"],
    Ubuntu: ["Ubuntu", "Ubuntu:ital,wght@0,300;0,400;0,500;0,700;1,400", "Arial, sans-serif"],
    TitilliumWeb: ["Titillium Web", "Titillium+Web:ital,wght@0,300;0,400;0,600;0,700;0,900;1,400", "Arial, sans-serif"],
    FredokaOne: ["Fredoka", "Fredoka:wght@400;600", "Arial, sans-serif"],
    PressStart2P: ["Press Start 2P", "Press+Start+2P", "monospace"],
    ComicNeueAngular: ["Comic Neue", "Comic+Neue:ital,wght@0,400;0,700;1,400", "'Comic Sans MS', cursive"],
    Bodoni: ["Bodoni Moda", "Bodoni+Moda:ital,wght@0,400;0,700;1,400", "serif"],
    AmaticSC: ["Amatic SC", "Amatic+SC:wght@400;700", "cursive"],
    JosefinSans: ["Josefin Sans", "Josefin+Sans:ital,wght@0,300;0,400;0,600;0,700;1,400", "Arial, sans-serif"],
  };
  // Enum.Font names (rich text face="...") that don't match their family file
  const ENUM_FAMILY = { Gotham: "GothamSSm", GothamMedium: "GothamSSm", GothamBold: "GothamSSm", GothamBlack: "GothamSSm", SourceSans: "SourceSansPro", SourceSansBold: "SourceSansPro", SourceSansLight: "SourceSansPro", SourceSansItalic: "SourceSansPro", SourceSansSemibold: "SourceSansPro", Legacy: "LegacyArial", ArialBold: "Arial", Arcade: "PressStart2P", Cartoon: "ComicNeueAngular", Fantasy: "Balthazar", Antique: "Arial", Highway: "Arial", SciFi: "Arial", RobotoMono: "RobotoMono" };
  const ENUM_WEIGHT = { GothamMedium: 500, GothamBold: 700, GothamBlack: 900, SourceSansBold: 700, SourceSansLight: 300, SourceSansSemibold: 600, ArialBold: 700 };
  const WEIGHTS = { Thin: 100, ExtraLight: 200, Light: 300, Regular: 400, Medium: 500, SemiBold: 600, Bold: 700, ExtraBold: 800, Heavy: 900 };

  function familyKey(family) {
    const m = /families\/([^/.]+)\.json/i.exec(family || "");
    return m ? m[1] : family || "SourceSansPro";
  }
  function fontInfo(key) {
    if (FONTS[key]) return FONTS[key];
    const spaced = key.replace(/([a-z])([A-Z0-9])/g, "$1 $2");
    return [spaced, spaced.replace(/ /g, "+"), "sans-serif"];
  }
  function cssFamily(key) {
    const f = fontInfo(key);
    return `'${f[0]}', ${f[2]}`;
  }
  const requestedFonts = new Set();
  const fontFaces = new Set(); // "weight style family" strings to wait for
  function useFont(key, weight, italic) {
    const f = fontInfo(key);
    // a family that shares its web font with another entry (Gotham -> Montserrat) uses that one's spec
    const url = f[1] || (Object.values(FONTS).find((v) => v[0] === f[0] && v[1]) || [])[1];
    if (url && !requestedFonts.has(url)) {
      requestedFonts.add(url);
      const link = document.createElement("link");
      link.rel = "stylesheet";
      link.href = `https://fonts.googleapis.com/css2?family=${url}&display=block`;
      document.head.appendChild(link);
    }
    fontFaces.add(`${italic ? "italic " : ""}${weight} 16px '${f[0]}'`);
  }
  async function waitForFonts(timeoutMs) {
    const links = [...document.querySelectorAll('link[rel="stylesheet"]')];
    await Promise.race([
      Promise.all(links.map((l) => (l.sheet ? Promise.resolve() : new Promise((res) => { l.addEventListener("load", res); l.addEventListener("error", res); })))),
      new Promise((res) => setTimeout(res, timeoutMs)),
    ]);
    await Promise.race([
      Promise.all([...fontFaces].map((f) => document.fonts.load(f).catch(() => null))),
      new Promise((res) => setTimeout(res, timeoutMs)),
    ]);
    await document.fonts.ready;
  }

  // ── rich text ─────────────────────────────────────────────────────────────
  const ENT = { "&lt;": "<", "&gt;": ">", "&amp;": "&", "&quot;": '"', "&apos;": "'" };
  const decode = (s) => s.replace(/&(lt|gt|amp|quot|apos);/g, (m) => ENT[m]);
  const RICH_TAGS = new Set(["b", "i", "u", "s", "font", "stroke", "mark", "uc", "uppercase", "sc", "smallcaps", "br"]);
  function parseColor(v) {
    if (!v) return null;
    v = v.trim();
    let m = /^#?([0-9a-f]{6})$/i.exec(v);
    if (m) return [parseInt(m[1].slice(0, 2), 16), parseInt(m[1].slice(2, 4), 16), parseInt(m[1].slice(4, 6), 16)];
    m = /^rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)$/i.exec(v);
    if (m) return [+m[1], +m[2], +m[3]];
    return null;
  }
  function parseAttrs(s) {
    const out = {};
    const re = /([a-zA-Z]+)\s*=\s*("([^"]*)"|'([^']*)'|([^\s"']+))/g;
    let m;
    while ((m = re.exec(s))) out[m[1].toLowerCase()] = m[3] ?? m[4] ?? m[5];
    return out;
  }
  // -> [{ text, st }] or null when Roblox would show the markup as plain text
  function parseRich(text) {
    const runs = [];
    const stack = [{ tag: null, st: {} }];
    let buf = "";
    const flush = () => {
      if (buf) runs.push({ text: decode(buf), st: stack[stack.length - 1].st });
      buf = "";
    };
    let i = 0;
    while (i < text.length) {
      const c = text[i];
      if (c !== "<") { buf += c; i++; continue; }
      if (text.startsWith("<!--", i)) {
        const e = text.indexOf("-->", i + 4);
        if (e < 0) return null;
        i = e + 3;
        continue;
      }
      const e = text.indexOf(">", i);
      if (e < 0) return null;
      const m = /^(\/)?\s*([a-zA-Z]+)([\s\S]*?)(\/)?\s*$/.exec(text.slice(i + 1, e));
      if (!m || !RICH_TAGS.has(m[2].toLowerCase())) return null;
      const name = m[2].toLowerCase();
      flush();
      i = e + 1;
      if (name === "br") { runs.push({ text: "\n", st: stack[stack.length - 1].st }); continue; }
      if (m[1]) {
        const top = stack[stack.length - 1];
        const norm = (t) => (t === "uppercase" ? "uc" : t === "smallcaps" ? "sc" : t);
        if (stack.length < 2 || norm(top.tag) !== norm(name)) return null;
        stack.pop();
        continue;
      }
      const a = parseAttrs(m[3] || "");
      const st = Object.assign({}, stack[stack.length - 1].st);
      if (name === "b") st.weight = 700;
      else if (name === "i") st.italic = true;
      else if (name === "u") st.underline = true;
      else if (name === "s") st.strike = true;
      else if (name === "uc" || name === "uppercase") st.upper = true;
      else if (name === "sc" || name === "smallcaps") st.smallcaps = true;
      else if (name === "font") {
        if (a.color) st.color = parseColor(a.color) || st.color;
        if (a.size) st.size = parseFloat(a.size) || st.size;
        if (a.transparency) st.alpha = 1 - clamp(parseFloat(a.transparency) || 0, 0, 1);
        if (a.face) { st.family = ENUM_FAMILY[a.face] || a.face; if (ENUM_WEIGHT[a.face]) st.weight = ENUM_WEIGHT[a.face]; }
        if (a.family) st.family = familyKey(a.family);
        if (a.weight) st.weight = WEIGHTS[Object.keys(WEIGHTS).find((k) => k.toLowerCase() === a.weight.toLowerCase())] || parseInt(a.weight, 10) || st.weight;
      } else if (name === "stroke") {
        st.stroke = { color: parseColor(a.color) || [0, 0, 0], thickness: parseFloat(a.thickness) || 1, alpha: 1 - clamp(parseFloat(a.transparency) || 0, 0, 1) };
      } else if (name === "mark") {
        st.mark = { color: parseColor(a.color) || [255, 255, 0], alpha: 1 - clamp(parseFloat(a.transparency) || 0, 0, 1) };
      }
      if (!m[4]) stack.push({ tag: name, st });
    }
    flush();
    return runs;
  }

  // the text of a text object as runs, with MaxVisibleGraphemes applied
  function textRuns(n) {
    const p = n.p;
    let text = p.Text ?? "";
    let placeholder = false;
    if (n.cls === "TextBox" && text === "" && p.PlaceholderText) { text = p.PlaceholderText; placeholder = true; }
    let runs = p.RichText && !placeholder ? parseRich(text) : null;
    if (!runs) runs = [{ text, st: {} }];
    const max = p.MaxVisibleGraphemes ?? -1;
    if (max >= 0) {
      let left = max;
      const out = [];
      for (const r of runs) {
        if (left <= 0) break;
        const chars = Array.from(r.text);
        out.push({ text: chars.slice(0, left).join(""), st: r.st });
        left -= chars.length;
      }
      runs = out;
    }
    return { runs, placeholder };
  }

  // the element's own text style (rich text runs override parts of it)
  function baseStyle(n, size) {
    const p = n.p;
    const f = p.FontFace || { family: "", weight: "Regular", style: "Normal" };
    const color = n.placeholder ? p.PlaceholderColor3 || [178, 178, 178] : p.TextColor3 || [0, 0, 0];
    const st = {
      family: familyKey(f.family),
      weight: WEIGHTS[f.weight] || 400,
      italic: f.style === "Italic",
      size,
      color,
      alpha: 1 - (p.TextTransparency ?? 0),
      lineHeight: p.LineHeight ?? 1,
    };
    const strokeT = p.TextStrokeTransparency ?? 1;
    if (strokeT < 1) st.textStroke = { color: p.TextStrokeColor3 || [0, 0, 0], alpha: 1 - strokeT, thickness: 1 };
    const ctxStroke = n.strokes.find((s) => s.p.Enabled !== false && (s.p.ApplyStrokeMode || "Contextual") === "Contextual");
    if (ctxStroke) st.textStroke = { color: ctxStroke.p.Color || [0, 0, 0], alpha: 1 - (ctxStroke.p.Transparency ?? 0), thickness: ctxStroke.p.Thickness ?? 1 };
    return st;
  }

  function spanCss(base, st, gradTint) {
    const family = st.family || base.family;
    const weight = st.weight || base.weight;
    const italic = st.italic ?? base.italic;
    const size = st.size || base.size;
    let color = st.color || base.color;
    if (gradTint) color = [color[0] * gradTint[0] / 255, color[1] * gradTint[1] / 255, color[2] * gradTint[2] / 255].map(Math.round);
    const alpha = (st.alpha ?? 1) * base.alpha;
    useFont(family, weight, italic);
    const css = [
      `font-family:${cssFamily(family)}`,
      `font-weight:${weight}`,
      `font-style:${italic ? "italic" : "normal"}`,
      `font-size:${size}px`,
      `line-height:${size * base.lineHeight}px`,
      `color:${rgba(color, alpha)}`,
    ];
    const deco = [];
    if (st.underline) deco.push("underline");
    if (st.strike) deco.push("line-through");
    if (deco.length) css.push(`text-decoration:${deco.join(" ")}`);
    if (st.upper) css.push("text-transform:uppercase");
    if (st.smallcaps) css.push("font-variant:small-caps");
    const stroke = st.stroke || base.textStroke;
    if (stroke && stroke.alpha > 0) css.push(`-webkit-text-stroke:${stroke.thickness * 2}px ${rgba(stroke.color, stroke.alpha * alpha)}`, "paint-order:stroke fill");
    if (st.mark) css.push(`background:${rgba(st.mark.color, st.mark.alpha)}`);
    return css.join(";");
  }

  function runsHtml(base, runs, gradTint) {
    return runs.map((r) => `<span style="${spanCss(base, r.st, gradTint)}">${esc(r.st.upper ? r.text : r.text)}</span>`).join("");
  }

  // ── measuring text ────────────────────────────────────────────────────────
  let measureBox = null;
  const measureCache = new Map();
  function measureHtml(html, wrapWidth, xAlign) {
    const key = wrapWidth + "|" + html;
    const hit = measureCache.get(key);
    if (hit) return hit;
    if (!measureBox) {
      measureBox = document.createElement("div");
      measureBox.style.cssText = "position:absolute;left:-200000px;top:0;visibility:hidden;contain:layout;";
      document.body.appendChild(measureBox);
    }
    const b = document.createElement("div");
    b.className = "gr-tb";
    if (wrapWidth === Infinity) {
      b.style.cssText = "display:inline-block;white-space:pre;font-size:0;";
    } else {
      b.style.cssText = `display:block;white-space:pre-wrap;font-size:0;width:${wrapWidth}px;text-align:${xAlign || "left"}`;
    }
    b.innerHTML = html;
    measureBox.appendChild(b);
    let w = 0, h = 0;
    if (wrapWidth === Infinity) {
      const r = b.getBoundingClientRect();
      w = r.width; h = r.height;
    } else {
      // the width the text really takes (its longest line), and the height
      const range = document.createRange();
      range.selectNodeContents(b);
      const rects = [...range.getClientRects()];
      const br = b.getBoundingClientRect();
      h = br.height;
      if (rects.length) {
        let l = Infinity, r = -Infinity;
        for (const rc of rects) { if (rc.width > 0) { l = Math.min(l, rc.left); r = Math.max(r, rc.right); } }
        w = r > l ? r - l : 0;
      }
    }
    measureBox.removeChild(b);
    const out = { w, h };
    measureCache.set(key, out);
    return out;
  }

  // the text layout of a text object for a content box (cw wide, ch tall). wrapWidth: Infinity = one line
  function textLayout(n, cw, ch, autoX) {
    const p = n.p;
    const { runs, placeholder } = textRuns(n);
    n.placeholder = placeholder;
    const gradTint = null;
    const hasText = runs.some((r) => r.text.length > 0);
    const xAlign = (p.TextXAlignment || "Center").toLowerCase();
    let size = p.TextSize ?? 14;
    const tsc = n.mods.textSize;
    const minT = tsc ? tsc.p.MinTextSize ?? 1 : 1;
    const maxT = tsc ? tsc.p.MaxTextSize ?? 100 : 100;
    let wrap = (p.TextWrapped || p.TextScaled) && !autoX;
    if (p.TextScaled && hasText) {
      // the biggest size (Roblox caps TextScaled at 100) that fits the box
      let lo = Math.max(1, minT), hi = Math.min(100, maxT), best = lo;
      while (lo <= hi) {
        const mid = Math.floor((lo + hi) / 2);
        const html = runsHtml(baseStyle(n, mid), runs, gradTint);
        const one = measureHtml(html, Infinity);
        let fits = one.w <= cw + 0.5 && one.h <= ch + 0.5;
        if (!fits && wrap) {
          const m = measureHtml(html, Math.max(1, cw), xAlign);
          fits = m.h <= ch + 0.5 && m.w <= cw + 0.5;
        }
        if (fits) { best = mid; lo = mid + 1; } else hi = mid - 1;
      }
      size = best;
      const one = measureHtml(runsHtml(baseStyle(n, size), runs, gradTint), Infinity);
      if (one.w <= cw + 0.5) wrap = false;
    } else if (tsc) {
      size = clamp(size, minT, maxT);
    }
    const base = baseStyle(n, size);
    const html = runsHtml(base, runs, gradTint);
    if (!hasText) return { html, base, size, wrap, w: 0, h: 0, runs };
    const m = measureHtml(html, wrap ? Math.max(1, cw) : Infinity, xAlign);
    return { html, base, size, wrap, w: m.w, h: m.h, runs };
  }

  // ── the model ─────────────────────────────────────────────────────────────
  function build(raw, defaults, parent, path) {
    const p = Object.assign({}, defaults[raw.class] || {}, raw.props || {});
    const n = { cls: raw.class, name: raw.name, p, parent, kids: [], mods: {}, strokes: [], raw, path: path + "." + raw.name };
    n.isGui = GUI.has(raw.class);
    n.isText = TEXT.has(raw.class);
    const addKid = (c, inFolder) => {
      const k = build(c, defaults, n, n.path);
      k.inFolder = inFolder;
      n.kids.push(k);
    };
    const walkFolder = (folder) => {
      for (const c of folder.children || []) {
        if (c.class === "Folder") walkFolder(c);
        else if (GUI.has(c.class)) addKid(c, true);
      }
    };
    for (const c of raw.children || []) {
      if (MODS.has(c.class)) {
        const m = { cls: c.class, p: Object.assign({}, defaults[c.class] || {}, c.props || {}) };
        const slot = { UICorner: "corner", UIGradient: "gradient", UIPadding: "padding", UIListLayout: "list", UIPageLayout: "list", UITableLayout: "list", UIGridLayout: "grid", UIAspectRatioConstraint: "aspect", UISizeConstraint: "sizeLimit", UITextSizeConstraint: "textSize", UIScale: "scale", UIFlexItem: "flex" }[c.class];
        if (c.class === "UIStroke") n.strokes.push(m);
        else if (slot && !n.mods[slot]) n.mods[slot] = m;
      } else if (c.class === "Folder") walkFolder(c);
      else if (GUI.has(c.class)) addKid(c, false);
    }
    return n;
  }

  // ── layout ────────────────────────────────────────────────────────────────
  let opts = {};
  function paddingOf(n, w, h) {
    const pad = n.mods.padding;
    if (!pad) return { l: 0, r: 0, t: 0, b: 0 };
    return { l: udim(pad.p.PaddingLeft, w), r: udim(pad.p.PaddingRight, w), t: udim(pad.p.PaddingTop, h), b: udim(pad.p.PaddingBottom, h) };
  }
  function constrain(n, w, h) {
    const a = n.mods.aspect;
    if (a) {
      const ratio = a.p.AspectRatio || 1;
      if (a.p.AspectType === "ScaleWithParentSize") {
        if (a.p.DominantAxis === "Height") w = h * ratio; else h = w / ratio;
      } else {
        // FitWithinMaxSize: the biggest box of that ratio inside the one Size asks for
        if (w / Math.max(h, 1e-9) > ratio) w = h * ratio; else h = w / ratio;
      }
    }
    const s = n.mods.sizeLimit;
    if (s) {
      const min = s.p.MinSize || [0, 0], max = s.p.MaxSize || [null, null];
      w = clamp(w, min[0], inf(max[0]));
      h = clamp(h, min[1], inf(max[1]));
    }
    return [w, h];
  }
  // a GuiObject's size inside a content box of pw x ph (forced: a grid cell)
  function sizeOf(n, pw, ph, forced) {
    const key = pw + "x" + ph + (forced ? "f" + forced.join(",") : "");
    if (n._sizeKey === key) return n._size;
    let w, h;
    if (forced) [w, h] = forced;
    else {
      const s = n.p.Size || [0, 0, 0, 0];
      let sx = pw, sy = ph;
      if (n.p.SizeConstraint === "RelativeXX") sy = pw;
      else if (n.p.SizeConstraint === "RelativeYY") sx = ph;
      w = s[0] * sx + s[1];
      h = s[2] * sy + s[3];
    }
    [w, h] = constrain(n, w, h);
    const auto = n.p.AutomaticSize || "None";
    n.autoX = auto === "X" || auto === "XY";
    n.autoY = auto === "Y" || auto === "XY";
    if (!forced && (n.autoX || n.autoY)) {
      const m = measure(n, w, h);
      if (n.autoX) w = Math.max(w, m.w);
      if (n.autoY) h = Math.max(h, m.h);
      [w, h] = constrain(n, w, h);
    }
    w = Math.max(0, w);
    h = Math.max(0, h);
    n._sizeKey = key;
    n._size = [w, h];
    return n._size;
  }
  // what AutomaticSize grows to: text and children, plus padding
  function measure(n, w, h) {
    const pad = paddingOf(n, w, h);
    const cw = Math.max(0, w - pad.l - pad.r), ch = Math.max(0, h - pad.t - pad.b);
    let mw = 0, mh = 0;
    if (n.isText) {
      const t = textLayout(n, cw, ch, n.autoX);
      mw = Math.ceil(t.w);
      mh = Math.ceil(t.h - 0.01);
    }
    const kids = n.kids;
    const managed = kids.filter((k) => !k.inFolder && (n.mods.list || n.mods.grid));
    if (managed.length) {
      const c = n.mods.list ? listLayout(n, managed, cw, ch, true) : gridLayout(n, managed, cw, ch, true);
      mw = Math.max(mw, c.w);
      mh = Math.max(mh, c.h);
    }
    const ox = opts.folderPadding === false ? pad.l : 0, oy = opts.folderPadding === false ? pad.t : 0;
    for (const k of kids) {
      if (managed.includes(k)) continue;
      const fw = k.inFolder && opts.folderPadding === false ? w : cw, fh = k.inFolder && opts.folderPadding === false ? h : ch;
      const [kw, kh] = sizeOf(k, fw, fh);
      const pos = k.p.Position || [0, 0, 0, 0], an = k.p.AnchorPoint || [0, 0];
      const x = pos[0] * fw + pos[1] - an[0] * kw - (k.inFolder ? ox : 0);
      const y = pos[2] * fh + pos[3] - an[1] * kh - (k.inFolder ? oy : 0);
      mw = Math.max(mw, x + kw);
      mh = Math.max(mh, y + kh);
    }
    return { w: mw + pad.l + pad.r, h: mh + pad.t + pad.b };
  }
  function sortKids(list, order) {
    const arr = list.map((k, i) => ({ k, i }));
    if (order === "LayoutOrder") arr.sort((a, b) => (a.k.p.LayoutOrder ?? 0) - (b.k.p.LayoutOrder ?? 0) || a.i - b.i);
    else if (order === "Name") arr.sort((a, b) => (a.k.name < b.k.name ? -1 : a.k.name > b.k.name ? 1 : a.i - b.i));
    return arr.map((x) => x.k);
  }
  // UIListLayout: places `kids` in a cw x ch content box; returns the content size
  function listLayout(n, kids, cw, ch, measureOnly, ox = 0, oy = 0) {
    const L = n.mods.list.p;
    const vertical = (L.FillDirection || "Vertical") === "Vertical";
    const sorted = sortKids(kids, L.SortOrder || "LayoutOrder");
    const gap = udim(L.Padding, vertical ? ch : cw);
    const sizes = sorted.map((k) => sizeOf(k, cw, ch).slice());
    const main = vertical ? 1 : 0, cross = vertical ? 0 : 1;
    const avail = vertical ? ch : cw;
    const crossAvail = vertical ? cw : ch;
    // lines (Wraps breaks them where the next one doesn't fit)
    const lines = [];
    let line = { items: [], len: 0, thick: 0 };
    sorted.forEach((k, i) => {
      const s = sizes[i];
      const add = (line.items.length ? gap : 0) + s[main];
      if (L.Wraps && line.items.length && line.len + add > avail + 0.01) {
        lines.push(line);
        line = { items: [], len: 0, thick: 0 };
      }
      line.len += (line.items.length ? gap : 0) + s[main];
      line.thick = Math.max(line.thick, s[cross]);
      line.items.push(i);
    });
    if (line.items.length) lines.push(line);
    // flex: grow to fill, or spread out
    const flex = (vertical ? L.VerticalFlex : L.HorizontalFlex) || "None";
    let contentMain = 0, contentCross = 0;
    lines.forEach((ln, li) => {
      let spacing = gap, lead = 0;
      const free = avail - ln.len;
      if (!measureOnly && flex !== "None" && free > 0 && Number.isFinite(avail)) {
        if (flex === "Fill") {
          const per = free / ln.items.length;
          ln.items.forEach((i) => { sizes[i][main] += per; });
          ln.len = avail;
        } else if (flex === "SpaceBetween" && ln.items.length > 1) spacing = gap + free / (ln.items.length - 1);
        else if (flex === "SpaceAround") { spacing = gap + free / ln.items.length; lead = free / ln.items.length / 2; }
        else if (flex === "SpaceEvenly") { spacing = gap + free / (ln.items.length + 1); lead = free / (ln.items.length + 1); }
        if (flex !== "Fill") ln.len = avail;
      }
      ln.spacing = spacing;
      ln.lead = lead;
      contentMain = Math.max(contentMain, ln.len);
      contentCross += ln.thick + (li > 0 ? gap : 0);
    });
    const contentW = vertical ? contentCross : contentMain, contentH = vertical ? contentMain : contentCross;
    if (measureOnly) return { w: contentW, h: contentH };
    const hAlign = L.HorizontalAlignment || "Left", vAlign = L.VerticalAlignment || "Top";
    const mainAlign = vertical ? vAlign : hAlign, crossAlign = vertical ? hAlign : vAlign;
    const itemAlign = L.ItemLineAlignment && L.ItemLineAlignment !== "Automatic" ? L.ItemLineAlignment : null;
    let crossPos = lines.length > 1 || L.Wraps ? align(crossAlign, crossAvail - contentCross) : 0;
    for (const ln of lines) {
      let pos = align(mainAlign, avail - ln.len) + ln.lead;
      for (const i of ln.items) {
        const k = sorted[i], s = sizes[i];
        let c;
        const lineThick = lines.length > 1 || L.Wraps ? ln.thick : crossAvail;
        if (itemAlign === "Stretch") { s[cross] = lineThick; c = 0; }
        else if (itemAlign === "Start") c = 0;
        else if (itemAlign === "Center") c = (lineThick - s[cross]) / 2;
        else if (itemAlign === "End") c = lineThick - s[cross];
        else c = align(crossAlign, lineThick - s[cross]);
        const x = vertical ? crossPos + c : pos, y = vertical ? pos : crossPos + c;
        k.x = ox + x; k.y = oy + y; k.w = s[0]; k.h = s[1];
        k.placed = true;
        pos += s[main] + ln.spacing;
      }
      crossPos += ln.thick + gap;
    }
    return { w: contentW, h: contentH };
  }
  // UIGridLayout
  function gridLayout(n, kids, cw, ch, measureOnly, ox = 0, oy = 0) {
    const G = n.mods.grid.p;
    const sorted = sortKids(kids, G.SortOrder || "LayoutOrder");
    const cs = G.CellSize || [0, 100, 0, 100], cp = G.CellPadding || [0, 5, 0, 5];
    let cellW = cs[0] * cw + cs[1], cellH = cs[2] * ch + cs[3];
    const padX = cp[0] * cw + cp[1], padY = cp[2] * ch + cp[3];
    const horizontal = (G.FillDirection || "Horizontal") === "Horizontal";
    const maxCells = G.FillDirectionMaxCells || 0;
    let per = horizontal ? Math.floor((cw + padX + 1e-6) / (cellW + padX)) : Math.floor((ch + padY + 1e-6) / (cellH + padY));
    if (!Number.isFinite(per) || per < 1) per = 1;
    if (maxCells > 0) per = Math.min(per, maxCells);
    const count = sorted.length;
    const lines = Math.ceil(count / per);
    const across = Math.min(count, per);
    const cols = horizontal ? across : lines, rows = horizontal ? lines : across;
    const w = cols * cellW + Math.max(0, cols - 1) * padX, h = rows * cellH + Math.max(0, rows - 1) * padY;
    if (measureOnly) return { w, h };
    const x0 = align(G.HorizontalAlignment || "Left", cw - w), y0 = align(G.VerticalAlignment || "Top", ch - h);
    const corner = G.StartCorner || "TopLeft";
    sorted.forEach((k, i) => {
      let col = horizontal ? i % per : Math.floor(i / per), row = horizontal ? Math.floor(i / per) : i % per;
      if (corner === "TopRight" || corner === "BottomRight") col = cols - 1 - col;
      if (corner === "BottomLeft" || corner === "BottomRight") row = rows - 1 - row;
      const [kw, kh] = constrain(k, cellW, cellH);
      k.x = ox + x0 + col * (cellW + padX);
      k.y = oy + y0 + row * (cellH + padY);
      k.w = kw; k.h = kh;
      k.placed = true;
      k._forced = [cellW, cellH];
    });
    return { w, h };
  }
  // lays out n's children (n.w, n.h are known)
  function layoutChildren(n) {
    const pad = paddingOf(n, n.w, n.h);
    let cw = n.w - pad.l - pad.r, ch = n.h - pad.t - pad.b;
    let ox = pad.l, oy = pad.t;
    const managed = n.kids.filter((k) => !k.inFolder && (n.mods.list || n.mods.grid));
    const free = n.kids.filter((k) => !managed.includes(k));
    if (n.cls === "ScrollingFrame") {
      // the canvas: CanvasSize (relative to the window), never smaller than the window,
      // grown to the content on AutomaticCanvasSize's axes
      const cs = n.p.CanvasSize || [0, 0, 2, 0];
      let canW = Math.max(n.w, cs[0] * n.w + cs[1]), canH = Math.max(n.h, cs[2] * n.h + cs[3]);
      const auto = n.p.AutomaticCanvasSize || "None";
      if (auto !== "None") {
        const cpad = paddingOf(n, canW, canH);
        const c = { w: 0, h: 0 };
        const icw = canW - cpad.l - cpad.r, ich = canH - cpad.t - cpad.b;
        if (managed.length) {
          const m = n.mods.list ? listLayout(n, managed, icw, ich, true) : gridLayout(n, managed, icw, ich, true);
          c.w = m.w; c.h = m.h;
        }
        for (const k of free) {
          const [kw, kh] = sizeOf(k, icw, ich);
          const pos = k.p.Position || [0, 0, 0, 0], an = k.p.AnchorPoint || [0, 0];
          c.w = Math.max(c.w, pos[0] * icw + pos[1] - an[0] * kw + kw);
          c.h = Math.max(c.h, pos[2] * ich + pos[3] - an[1] * kh + kh);
        }
        if (auto === "X" || auto === "XY") canW = Math.max(canW, c.w + cpad.l + cpad.r);
        if (auto === "Y" || auto === "XY") canH = Math.max(canH, c.h + cpad.t + cpad.b);
      }
      n.canvasW = canW;
      n.canvasH = canH;
      const cpad = paddingOf(n, canW, canH);
      cw = canW - cpad.l - cpad.r;
      ch = canH - cpad.t - cpad.b;
      ox = cpad.l; oy = cpad.t;
      const cp = n.p.CanvasPosition || [0, 0];
      n.scrollX = clamp(cp[0], 0, Math.max(0, canW - n.w));
      n.scrollY = clamp(cp[1], 0, Math.max(0, canH - n.h));
    }
    if (managed.length) {
      if (n.mods.list) listLayout(n, managed, cw, ch, false, ox, oy);
      else gridLayout(n, managed, cw, ch, false, ox, oy);
    }
    for (const k of free) {
      const useOuter = k.inFolder && opts.folderPadding === false && n.cls !== "ScrollingFrame";
      const fw = useOuter ? n.w : cw, fh = useOuter ? n.h : ch;
      const [kw, kh] = sizeOf(k, fw, fh);
      const pos = k.p.Position || [0, 0, 0, 0], an = k.p.AnchorPoint || [0, 0];
      k.w = kw; k.h = kh;
      k.x = (useOuter ? 0 : ox) + pos[0] * fw + pos[1] - an[0] * kw;
      k.y = (useOuter ? 0 : oy) + pos[2] * fh + pos[3] - an[1] * kh;
      k.placed = true;
    }
    for (const k of n.kids) {
      // a child whose size depended on a guess made while measuring gets the real box now
      layoutChildren(k);
    }
  }

  // ── painting ──────────────────────────────────────────────────────────────
  const warnings = [];
  function gradientSvg(n, w, h, color, alpha, radius) {
    const g = n.mods.gradient.p;
    const colorKeys = g.Color || [[0, 255, 255, 255], [1, 255, 255, 255]];
    const alphaKeys = g.Transparency || [[0, 0, 0], [1, 0, 0]];
    const times = [...new Set([...colorKeys.map((k) => k[0]), ...alphaKeys.map((k) => k[0])])].sort((a, b) => a - b);
    const at = (keys, t, idx) => {
      if (t <= keys[0][0]) return idx.map((i) => keys[0][i]);
      for (let i = 0; i < keys.length - 1; i++) {
        const a = keys[i], b = keys[i + 1];
        if (t >= a[0] && t <= b[0]) {
          const k = b[0] > a[0] ? (t - a[0]) / (b[0] - a[0]) : 0;
          return idx.map((j) => a[j] + (b[j] - a[j]) * k);
        }
      }
      const last = keys[keys.length - 1];
      return idx.map((i) => last[i]);
    };
    const stops = times.map((t) => {
      const c = at(colorKeys, t, [1, 2, 3]);
      const [tr] = at(alphaKeys, t, [1]);
      const col = [color[0] * c[0] / 255, color[1] * c[1] / 255, color[2] * c[2] / 255].map(Math.round);
      return `<stop offset="${t}" stop-color="rgb(${col[0]},${col[1]},${col[2]})" stop-opacity="${clamp(alpha * (1 - tr), 0, 1)}"/>`;
    }).join("");
    const rot = g.Rotation || 0, off = g.Offset || [0, 0];
    const id = "g" + Math.random().toString(36).slice(2);
    // objectBoundingBox: the gradient lives in the box's own 0..1 space, stretched with it, as in Roblox
    return `<svg width="100%" height="100%" viewBox="0 0 1 1" preserveAspectRatio="none" style="position:absolute;inset:0;border-radius:${radius}px;overflow:hidden">` +
      `<defs><linearGradient id="${id}" gradientUnits="objectBoundingBox" x1="0" y1="0.5" x2="1" y2="0.5" gradientTransform="translate(${off[0]} ${off[1]}) rotate(${rot} 0.5 0.5)">${stops}</linearGradient></defs>` +
      `<rect x="0" y="0" width="1" height="1" fill="url(#${id})"/></svg>`;
  }
  // the gradient's colour at the middle, for tinting text (approximation)
  function gradientTint(n) {
    const g = n.mods.gradient;
    if (!g || g.p.Enabled === false) return null;
    const keys = g.p.Color || [];
    if (!keys.length) return null;
    const c = [0, 0, 0];
    for (const k of keys) { c[0] += k[1]; c[1] += k[2]; c[2] += k[3]; }
    return c.map((v) => v / keys.length);
  }

  function cornerRadius(n) {
    const c = n.mods.corner;
    if (!c) return 0;
    const r = udim(c.p.CornerRadius || [0, 8], Math.min(n.w, n.h));
    return clamp(r, 0, Math.min(n.w, n.h) / 2);
  }

  function paintNode(n, parentEl, zBehavior) {
    const p = n.p;
    const el = document.createElement("div");
    el.className = "gr-n";
    el.dataset.path = n.path;
    el.dataset.cls = n.cls;
    el.style.left = n.x + "px";
    el.style.top = n.y + "px";
    el.style.width = n.w + "px";
    el.style.height = n.h + "px";
    const scale = n.mods.scale ? n.mods.scale.p.Scale ?? 1 : 1;
    const rot = p.Rotation || 0;
    if (scale !== 1 || rot !== 0) {
      const an = p.AnchorPoint || [0, 0];
      const ax = an[0] * n.w, ay = an[1] * n.h, cx = n.w / 2, cy = n.h / 2;
      el.style.transformOrigin = "0 0";
      el.style.transform = `translate(${ax}px,${ay}px) scale(${scale}) translate(${-ax}px,${-ay}px) translate(${cx}px,${cy}px) rotate(${rot}deg) translate(${-cx}px,${-cy}px)`;
    }
    if (n.cls === "CanvasGroup" && p.GroupTransparency) el.style.opacity = String(1 - p.GroupTransparency);
    if (opts.outline) el.style.outline = "1px solid rgba(0,255,200,.35)";

    // own looks: background (+gradient), legacy border, UIStroke (border mode), corner
    const radius = cornerRadius(n);
    const bgT = p.BackgroundTransparency ?? 0;
    const bgColor = p.BackgroundColor3 || [163, 162, 165];
    const grad = n.mods.gradient && n.mods.gradient.p.Enabled !== false ? n.mods.gradient : null;
    const shadows = [];
    const borderSize = p.BorderSizePixel ?? 0;
    if (borderSize > 0 && bgT < 1 && !n.mods.corner) {
      const c = rgba(p.BorderColor3 || [27, 42, 53], 1 - bgT);
      const mode = p.BorderMode || "Outline";
      if (mode === "Inset") shadows.push(`inset 0 0 0 ${borderSize}px ${c}`);
      else if (mode === "Middle") shadows.push(`0 0 0 ${borderSize / 2}px ${c}`, `inset 0 0 0 ${borderSize / 2}px ${c}`);
      else shadows.push(`0 0 0 ${borderSize}px ${c}`);
    }
    for (const s of n.strokes) {
      if (s.p.Enabled === false) continue;
      const mode = s.p.ApplyStrokeMode || "Contextual";
      if (mode === "Contextual" && n.isText) continue; // drawn on the text
      const t = s.p.Thickness ?? 1, a = 1 - (s.p.Transparency ?? 0);
      if (t <= 0 || a <= 0) continue;
      const c = rgba(s.p.Color || [0, 0, 0], a);
      const where = s.p.BorderStrokePosition || "Outer";
      if (where === "Inner") shadows.unshift(`inset 0 0 0 ${t}px ${c}`);
      else if (where === "Center") shadows.unshift(`0 0 0 ${t / 2}px ${c}`, `inset 0 0 0 ${t / 2}px ${c}`);
      else shadows.unshift(`0 0 0 ${t}px ${c}`);
      break; // one stroke per object
    }
    if (bgT < 1 || shadows.length) {
      const bg = document.createElement("div");
      bg.className = "gr-bg";
      if (radius) bg.style.borderRadius = radius + "px";
      if (bgT < 1) {
        if (grad) bg.innerHTML = gradientSvg(n, n.w, n.h, bgColor, 1 - bgT, radius);
        else bg.style.background = rgba(bgColor, 1 - bgT);
      }
      if (shadows.length) bg.style.boxShadow = shadows.join(",");
      el.appendChild(bg);
      el.dataset.draws = "1";
    }

    if (n.cls === "ImageLabel" || n.cls === "ImageButton") {
      if (p.Image) {
        const img = document.createElement("div");
        img.className = "gr-img";
        const c = p.ImageColor3 || [255, 255, 255];
        img.style.background = `repeating-linear-gradient(45deg, ${rgba(c, 0.18 * (1 - (p.ImageTransparency ?? 0)))} 0 6px, transparent 6px 12px)`;
        img.title = p.Image;
        if (radius) img.style.borderRadius = radius + "px";
        el.appendChild(img);
      }
    }
    if (n.cls === "ViewportFrame" && n.raw.viewport) {
      const cv = document.createElement("canvas");
      cv.className = "gr-vp";
      if (radius) cv.style.borderRadius = radius + "px";
      el.appendChild(cv);
      viewports.push({ n, canvas: cv });
    }
    if (n.isText) paintText(n, el);
    if (el.querySelector(":scope > .gr-t, :scope > .gr-vp, :scope > .gr-img")) el.dataset.draws = "1";

    // children: Sibling behaviour, by ZIndex, then by order
    if (n.kids.length) {
      const box = document.createElement("div");
      box.className = "gr-c";
      if (p.ClipsDescendants && !rot) box.style.overflow = "hidden";
      let host = box;
      if (n.cls === "ScrollingFrame") {
        box.style.overflow = "hidden";
        const canvas = document.createElement("div");
        canvas.className = "gr-canvas";
        canvas.style.width = n.canvasW + "px";
        canvas.style.height = n.canvasH + "px";
        canvas.style.left = -n.scrollX + "px";
        canvas.style.top = -n.scrollY + "px";
        box.appendChild(canvas);
        host = canvas;
      }
      for (const k of sortByZ(n.kids)) paintNode(k, host, zBehavior);
      el.appendChild(box);
    }
    if (n.cls === "ScrollingFrame") paintScrollbars(n, el);
    parentEl.appendChild(el);
    n.el = el;
  }
  function sortByZ(kids) {
    return kids.map((k, i) => ({ k, i })).sort((a, b) => (a.k.p.ZIndex ?? 1) - (b.k.p.ZIndex ?? 1) || a.i - b.i).map((x) => x.k);
  }
  function paintScrollbars(n, el) {
    const p = n.p;
    const t = p.ScrollBarThickness ?? 12;
    if (t <= 0 || p.ScrollingEnabled === false) return;
    const dir = p.ScrollingDirection || "XY";
    const color = rgba(p.ScrollBarImageColor3 || [255, 255, 255], 1 - (p.ScrollBarImageTransparency ?? 0));
    if ((dir === "Y" || dir === "XY") && n.canvasH > n.h + 0.5) {
      const len = Math.max(t * 2, n.h * n.h / n.canvasH);
      const top = (n.h - len) * (n.scrollY / Math.max(1, n.canvasH - n.h));
      const bar = document.createElement("div");
      bar.className = "gr-sb";
      bar.style.cssText = `width:${t}px;height:${len}px;top:${top}px;${p.VerticalScrollBarPosition === "Left" ? "left:0" : "right:0"};background:${color}`;
      el.appendChild(bar);
    }
    if ((dir === "X" || dir === "XY") && n.canvasW > n.w + 0.5) {
      const len = Math.max(t * 2, n.w * n.w / n.canvasW);
      const left = (n.w - len) * (n.scrollX / Math.max(1, n.canvasW - n.w));
      const bar = document.createElement("div");
      bar.className = "gr-sb";
      bar.style.cssText = `height:${t}px;width:${len}px;left:${left}px;bottom:0;background:${color}`;
      el.appendChild(bar);
    }
  }

  // Roblox's TextTruncate.AtEnd: cut and add "..." until it fits
  function truncate(n, t, cw, ch) {
    const plain = t.runs.map((r) => r.text).join("");
    const fits = (s) => {
      const html = runsHtml(t.base, [{ text: s, st: t.runs[0] ? t.runs[0].st : {} }], null);
      const m = measureHtml(html, t.wrap ? Math.max(1, cw) : Infinity, "left");
      return t.wrap ? m.h <= ch + 0.5 : m.w <= cw + 0.5;
    };
    if (fits(plain)) return null;
    let lo = 0, hi = plain.length, best = "";
    const chars = Array.from(plain);
    while (lo <= hi) {
      const mid = (lo + hi) >> 1;
      const s = chars.slice(0, mid).join("").replace(/\s+$/, "") + "...";
      if (fits(s)) { best = s; lo = mid + 1; } else hi = mid - 1;
    }
    return runsHtml(t.base, [{ text: best, st: t.runs[0] ? t.runs[0].st : {} }], null);
  }

  function paintText(n, el) {
    const p = n.p;
    const pad = paddingOf(n, n.w, n.h);
    const cw = Math.max(0, n.w - pad.l - pad.r), ch = Math.max(0, n.h - pad.t - pad.b);
    const t = textLayout(n, cw, ch, n.autoX && !n._forced);
    if (!t.runs.some((r) => r.text.length)) return;
    let html = t.html;
    const tint = gradientTint(n);
    if (tint) html = runsHtml(t.base, t.runs, tint);
    if (p.TextTruncate === "AtEnd" || p.TextTruncate === "SplitWord") {
      const cut = truncate(n, t, cw, ch);
      if (cut) html = cut;
    }
    const box = document.createElement("div");
    box.className = "gr-t";
    box.style.left = pad.l + "px";
    box.style.top = pad.t + "px";
    box.style.width = cw + "px";
    box.style.height = ch + "px";
    const y = p.TextYAlignment || "Center", x = p.TextXAlignment || "Center";
    box.style.justifyContent = y === "Top" ? "flex-start" : y === "Bottom" ? "flex-end" : "center";
    box.style.alignItems = t.wrap ? "stretch" : x === "Left" ? "flex-start" : x === "Right" ? "flex-end" : "center";
    const block = document.createElement("div");
    block.className = "gr-tb";
    block.style.whiteSpace = t.wrap ? "pre-wrap" : "pre";
    block.style.textAlign = x.toLowerCase();
    if (!t.wrap) block.style.flex = "none";
    block.innerHTML = html;
    box.appendChild(block);
    el.appendChild(box);
  }

  // ── ViewportFrames: the parts the client put in them, through three.js ─────
  let viewports = [];
  let glRenderer = null;
  function drawViewports(dpr) {
    const THREE = window.THREE;
    for (const { n, canvas } of viewports) {
      const vp = n.raw.viewport;
      const w = Math.max(1, Math.round(n.w * dpr)), h = Math.max(1, Math.round(n.h * dpr));
      canvas.width = w; canvas.height = h;
      const c2 = canvas.getContext("2d");
      if (!THREE || !vp.camera || !vp.parts || !vp.parts.length) {
        silhouette(c2, w, h, vp);
        continue;
      }
      try {
        if (!glRenderer) {
          glRenderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, preserveDrawingBuffer: true });
          glRenderer.setPixelRatio(1);
          glRenderer.setClearColor(0x000000, 0);
        }
        glRenderer.setSize(w, h, false);
        const scene = new THREE.Scene();
        const col = (c) => new THREE.Color(c[0] / 255, c[1] / 255, c[2] / 255);
        const amb = n.p.Ambient || [200, 200, 200], lc = n.p.LightColor || [140, 140, 140], ld = n.p.LightDirection || [-1, -1, -1];
        scene.add(new THREE.AmbientLight(col(amb), 1));
        const sun = new THREE.DirectionalLight(col(lc), 1);
        sun.position.set(-ld[0], -ld[1], -ld[2]);
        scene.add(sun);
        const mat4 = (cf) => new THREE.Matrix4().set(cf[3], cf[4], cf[5], cf[0], cf[6], cf[7], cf[8], cf[1], cf[9], cf[10], cf[11], cf[2], 0, 0, 0, 1);
        for (const part of vp.parts) {
          const s = part.size;
          let geo;
          if (part.shape === "Ball") geo = new THREE.SphereGeometry(Math.min(s[0], s[1], s[2]) / 2, 24, 16);
          else if (part.shape === "Cylinder") {
            const r = Math.min(s[1], s[2]) / 2;
            geo = new THREE.CylinderGeometry(r, r, s[0], 28);
            geo.rotateZ(Math.PI / 2); // Roblox cylinders run along X
          } else geo = new THREE.BoxGeometry(s[0], s[1], s[2]);
          const color = col(part.color);
          let mat;
          if (part.material === "Neon") mat = new THREE.MeshBasicMaterial({ color });
          else if (["Metal", "DiamondPlate", "Foil", "Glass", "Marble", "Granite"].includes(part.material)) mat = new THREE.MeshPhongMaterial({ color, shininess: 55, specular: 0x444444 });
          else mat = new THREE.MeshLambertMaterial({ color });
          if (part.transparency > 0) { mat.transparent = true; mat.opacity = 1 - part.transparency; }
          const mesh = new THREE.Mesh(geo, mat);
          mat4(part.cframe).decompose(mesh.position, mesh.quaternion, mesh.scale);
          scene.add(mesh);
        }
        const cam = new THREE.PerspectiveCamera(vp.camera.fov || 70, w / h, 0.05, 2000);
        mat4(vp.camera.cframe).decompose(cam.position, cam.quaternion, cam.scale);
        glRenderer.render(scene, cam);
        c2.drawImage(glRenderer.domElement, 0, 0, w, h);
        scene.traverse((o) => { if (o.geometry) o.geometry.dispose(); if (o.material) o.material.dispose(); });
      } catch (e) {
        warnings.push("viewport: " + e.message);
        silhouette(c2, w, h, vp);
      }
    }
  }
  // ── (v0.18) the 3D stage (src/client/UI/World3D.luau): its parts, its light, and its effects
  // (particles as soft sprites from what was emitted, lights as glows, beams as ribbons of glow).
  // An approximation of Roblox's renderer, enough to see where everything is and how it reads.
  const spriteTex = {};
  function spriteTexture(THREE, tex) {
    const kind = /shockwave|vortex/.test(tex) ? "ring" : /sparkles/.test(tex) ? "star" : /smoke/.test(tex) ? "smoke" : "glow";
    if (spriteTex[kind]) return spriteTex[kind];
    const c = document.createElement("canvas");
    c.width = c.height = 64;
    const g = c.getContext("2d");
    const radial = (stops) => {
      const r = g.createRadialGradient(32, 32, 0, 32, 32, 32);
      stops.forEach(([o, a]) => r.addColorStop(o, `rgba(255,255,255,${a})`));
      return r;
    };
    if (kind === "ring") {
      g.strokeStyle = "rgba(255,255,255,0.35)"; g.lineWidth = 10; g.beginPath(); g.arc(32, 32, 23, 0, Math.PI * 2); g.stroke();
      g.strokeStyle = "rgba(255,255,255,0.9)"; g.lineWidth = 3; g.beginPath(); g.arc(32, 32, 23, 0, Math.PI * 2); g.stroke();
    } else if (kind === "star") {
      g.fillStyle = radial([[0, 0.9], [0.3, 0.35], [1, 0]]); g.fillRect(0, 0, 64, 64);
      g.fillStyle = "rgba(255,255,255,0.95)";
      g.beginPath(); g.moveTo(32, 0); g.lineTo(35, 29); g.lineTo(64, 32); g.lineTo(35, 35); g.lineTo(32, 64); g.lineTo(29, 35); g.lineTo(0, 32); g.lineTo(29, 29); g.closePath(); g.fill();
    } else if (kind === "smoke") {
      g.fillStyle = radial([[0, 0.75], [0.55, 0.4], [1, 0]]); g.fillRect(0, 0, 64, 64);
    } else {
      g.fillStyle = radial([[0, 1], [0.3, 0.6], [1, 0]]); g.fillRect(0, 0, 64, 64);
    }
    const t = new THREE.CanvasTexture(c);
    spriteTex[kind] = t;
    return t;
  }
  function drawWorld(canvas, W, H, dpr, world) {
    const THREE = window.THREE;
    if (!THREE || !world || !world.camera) return;
    const w = Math.max(1, Math.round(W * dpr)), h = Math.max(1, Math.round(H * dpr));
    canvas.width = w; canvas.height = h;
    canvas.style.width = W + "px"; canvas.style.height = H + "px";
    const c2 = canvas.getContext("2d");
    const L = world.lighting || {};
    const clock = L.clock ?? 0;
    const night = clock < 5.5 || clock > 19.5, dusk = !night && (clock > 16.5 || clock < 7.5);
    const sky = c2.createLinearGradient(0, 0, 0, h);
    if (night) { sky.addColorStop(0, "#05070f"); sky.addColorStop(0.6, "#111427"); sky.addColorStop(1, "#1d1830"); }
    else if (dusk) { sky.addColorStop(0, "#1e1838"); sky.addColorStop(0.65, "#7a4a5a"); sky.addColorStop(1, "#c8735a"); }
    else { sky.addColorStop(0, "#6a96cc"); sky.addColorStop(1, "#d6e4f2"); }
    c2.fillStyle = sky; c2.fillRect(0, 0, w, h);
    try {
      if (!glRenderer) {
        glRenderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, preserveDrawingBuffer: true });
        glRenderer.setPixelRatio(1);
        glRenderer.setClearColor(0x000000, 0);
      }
      glRenderer.setSize(w, h, false);
      const scene = new THREE.Scene();
      const col = (c) => new THREE.Color(c[0] / 255, c[1] / 255, c[2] / 255);
      const amb = L.outdoor || L.ambient || [90, 90, 110];
      scene.add(new THREE.AmbientLight(col(amb), 1.3));
      const sun = new THREE.DirectionalLight(night ? 0x9aa6d6 : dusk ? 0xffc8a0 : 0xfff4e6, night ? 0.55 : 0.95);
      sun.position.set(-4, 10, 7);
      scene.add(sun);
      const mat4 = (cf) => new THREE.Matrix4().set(cf[3], cf[4], cf[5], cf[0], cf[6], cf[7], cf[8], cf[1], cf[9], cf[10], cf[11], cf[2], 0, 0, 0, 1);
      for (const part of world.parts || []) {
        const s = part.size;
        let geo;
        if (part.shape === "Ball") geo = new THREE.SphereGeometry(Math.min(s[0], s[1], s[2]) / 2, 24, 16);
        else if (part.shape === "Cylinder") {
          const r = Math.min(s[1], s[2]) / 2;
          geo = new THREE.CylinderGeometry(r, r, s[0], 28);
          geo.rotateZ(Math.PI / 2);
        } else geo = new THREE.BoxGeometry(s[0], s[1], s[2]);
        const color = col(part.color);
        let mat;
        if (part.material === "Neon") mat = new THREE.MeshBasicMaterial({ color });
        else if (part.material === "ForceField") mat = new THREE.MeshBasicMaterial({ color, transparent: true, opacity: 0.28, blending: THREE.AdditiveBlending, depthWrite: false });
        else if (["Metal", "DiamondPlate", "Foil", "Glass", "Marble", "Granite"].includes(part.material)) mat = new THREE.MeshPhongMaterial({ color, shininess: 55, specular: 0x444444 });
        else mat = new THREE.MeshLambertMaterial({ color });
        if (part.transparency > 0 && part.material !== "ForceField") { mat.transparent = true; mat.opacity = 1 - part.transparency; }
        const mesh = new THREE.Mesh(geo, mat);
        mat4(part.cframe).decompose(mesh.position, mesh.quaternion, mesh.scale);
        scene.add(mesh);
      }
      // effects: deterministic, so the same dump always draws the same picture
      let seed = 1234567;
      const rnd = () => (seed = (seed * 48271) % 2147483647) / 2147483647;
      const sprite = (tex, pos, size, color, opacity, additive) => {
        const m = new THREE.SpriteMaterial({ map: spriteTexture(THREE, tex), color, transparent: true, opacity: Math.max(0, Math.min(1, opacity)), depthWrite: false, blending: additive ? THREE.AdditiveBlending : THREE.NormalBlending });
        const sp = new THREE.Sprite(m);
        sp.position.set(pos[0], pos[1], pos[2]);
        sp.scale.set(size, size, 1);
        scene.add(sp);
      };
      for (const f of world.fx || []) {
        if (f.kind === "light") {
          sprite("glow", f.pos, Math.max(2, f.range * 0.55), col(f.color), Math.min(0.55, f.brightness / 16), true);
        } else if (f.kind === "beam") {
          for (let i = 0; i <= 16; i++) {
            const t = i / 16, u = 1 - t;
            const p = [0, 1, 2].map((k) => u * u * u * f.p0[k] + 3 * u * u * t * f.c0[k] + 3 * u * t * t * f.c1[k] + t * t * t * f.p1[k]);
            sprite("glow", p, Math.max(0.2, (f.width0 * u + f.width1 * t) * 1.3), col(f.color), (f.alpha || 1) * 0.8, true);
          }
        } else if (f.kind === "particles") {
          const n = Math.min(f.count, 34);
          const travel = f.flat ? 0 : Math.min(7, (f.speed || 0) * Math.min(f.life || 0.3, 0.6) * (f.drag > 3 ? 0.12 : 0.3));
          for (let i = 0; i < n; i++) {
            let dx = rnd() * 2 - 1, dy = rnd() * 2 - 1, dz = rnd() * 2 - 1;
            const len = Math.hypot(dx, dy, dz) || 1;
            dx /= len; dy /= len; dz /= len;
            if (f.spread < 90 && f.accel && f.accel[1] > 1) dy = Math.abs(dy) + 0.4;
            if (f.accel && f.accel[1] < -1) dy -= 0.3;
            const r = travel * (0.35 + 0.65 * rnd());
            const p = [f.pos[0] + dx * r, f.pos[1] + dy * r, f.pos[2] + dz * r];
            const k = rnd();
            const c = col([f.color0[0] + (f.color1[0] - f.color0[0]) * k, f.color0[1] + (f.color1[1] - f.color0[1]) * k, f.color0[2] + (f.color1[2] - f.color0[2]) * k]);
            const size = Math.max(0.12, (f.size || 1) * (f.streak ? 0.5 : f.flat ? 0.7 : 0.65) * (0.7 + 0.5 * rnd()));
            sprite(f.tex, p, size, c, (f.alpha ?? 1) * (0.55 + 0.35 * rnd()), (f.light || 0) >= 0.5);
          }
        }
      }
      const cam = new THREE.PerspectiveCamera(world.camera.fov || 40, w / h, 0.1, 4000);
      mat4(world.camera.cframe).decompose(cam.position, cam.quaternion, cam.scale);
      glRenderer.render(scene, cam);
      c2.drawImage(glRenderer.domElement, 0, 0, w, h);
      scene.traverse((o) => { if (o.geometry) o.geometry.dispose(); if (o.material) o.material.dispose(); });
    } catch (e) {
      warnings.push("world: " + e.message);
    }
  }

  // no WebGL: a plain figure where the avatar would be
  function silhouette(c, w, h, vp) {
    const full = vp && vp.avatar && vp.avatar.framing === "full";
    c.fillStyle = "rgba(160,160,170,.55)";
    const cx = w / 2;
    if (full) {
      const u = h / 10;
      c.beginPath(); c.arc(cx, u * 1.6, u * 0.9, 0, Math.PI * 2); c.fill();
      c.fillRect(cx - u * 1.1, u * 2.7, u * 2.2, u * 3.4);
      c.fillRect(cx - u * 1.0, u * 6.2, u * 0.9, u * 3.2); c.fillRect(cx + u * 0.1, u * 6.2, u * 0.9, u * 3.2);
    } else {
      c.beginPath(); c.arc(cx, h * 0.42, Math.min(w, h) * 0.22, 0, Math.PI * 2); c.fill();
      c.beginPath(); c.ellipse(cx, h * 1.02, w * 0.42, h * 0.38, 0, 0, Math.PI * 2); c.fill();
    }
  }

  // ── Roblox's topbar (approximate): the menu and chat buttons over the inset ─
  function topbar(root, W, inset) {
    if (!inset) return;
    const bar = document.createElement("div");
    bar.className = "gr-topbar";
    bar.style.height = inset + "px";
    const size = Math.min(44, inset - 12);
    const pill = document.createElement("div");
    pill.className = "gr-pill";
    pill.style.cssText = `left:12px;top:${(inset - size) / 2}px;height:${size}px;width:${size * 2 + 4}px;border-radius:${size / 2}px`;
    pill.innerHTML = `<svg viewBox="0 0 88 44" width="${size * 2 + 4}" height="${size}"><g fill="none" stroke="rgba(255,255,255,.92)" stroke-width="2.6" stroke-linecap="round"><rect x="13" y="13" width="18" height="18" rx="2" transform="rotate(15 22 22)"/><path d="M56 15h17a3 3 0 0 1 3 3v9a3 3 0 0 1-3 3h-9l-6 5v-5h-2a3 3 0 0 1-3-3v-9a3 3 0 0 1 3-3z"/></g></svg>`;
    bar.appendChild(pill);
    root.appendChild(bar);
  }

  // ── entry point ───────────────────────────────────────────────────────────
  async function render(dump, container, options) {
    opts = Object.assign({ backdrop: "city", topbar: true, folderPadding: true, outline: false, dpr: window.devicePixelRatio || 1 }, options || {});
    warnings.length = 0;
    viewports = [];
    measureCache.clear();
    const [W, H] = dump.screen;
    const inset = dump.inset || 0;
    container.innerHTML = "";
    const root = document.createElement("div");
    root.className = "gr-screen";
    root.style.width = W + "px";
    root.style.height = H + "px";
    container.appendChild(root);
    const back = document.createElement("canvas");
    back.className = "gr-backdrop";
    root.appendChild(back);
    if (window.GuiBackdrop) window.GuiBackdrop.draw(back, W, H, opts.dpr, opts.backdrop);
    // (v0.18) a 3D stage up: it is what's behind the GUI, not the city
    if (dump.world) drawWorld(back, W, H, opts.dpr, dump.world);

    // the model, fonts first (text can't be measured before its font is in)
    const defaults = dump.defaults || {};
    const guis = (dump.guis || []).filter((g) => LAYER.has(g.class)).map((g, i) => ({ g, i, n: build(g, defaults, null, "PlayerGui") }));
    const scanFonts = (n) => {
      if (n.isText) {
        const f = n.p.FontFace;
        if (f) useFont(familyKey(f.family), WEIGHTS[f.weight] || 400, f.style === "Italic");
        const runs = n.p.RichText ? parseRich(n.p.Text || "") : null;
        for (const r of runs || []) if (r.st.family || r.st.weight) useFont(r.st.family || familyKey(f && f.family), r.st.weight || 400, !!r.st.italic);
      }
      n.kids.forEach(scanFonts);
    };
    guis.forEach(({ n }) => n.kids.forEach(scanFonts));
    await waitForFonts(opts.fontTimeout || 8000);

    guis.sort((a, b) => (a.n.p.DisplayOrder ?? 0) - (b.n.p.DisplayOrder ?? 0) || a.i - b.i);
    for (const { n } of guis) {
      const ignore = n.p.IgnoreGuiInset === true;
      const top = ignore ? 0 : inset;
      const gw = W, gh = H - top;
      const layer = document.createElement("div");
      layer.className = "gr-gui";
      layer.dataset.path = n.path;
      layer.style.top = top + "px";
      layer.style.width = gw + "px";
      layer.style.height = gh + "px";
      n.w = gw; n.h = gh;
      for (const k of n.kids) {
        const [kw, kh] = sizeOf(k, gw, gh);
        const pos = k.p.Position || [0, 0, 0, 0], an = k.p.AnchorPoint || [0, 0];
        k.w = kw; k.h = kh;
        k.x = pos[0] * gw + pos[1] - an[0] * kw;
        k.y = pos[2] * gh + pos[3] - an[1] * kh;
        layoutChildren(k);
      }
      for (const k of sortByZ(n.kids)) paintNode(k, layer, n.p.ZIndexBehavior);
      root.appendChild(layer);
    }
    if (opts.topbar) topbar(root, W, inset);
    drawViewports(opts.dpr);
    await new Promise((res) => requestAnimationFrame(() => requestAnimationFrame(res)));
    return { warnings: warnings.slice() };
  }

  window.GuiRender = { render, parseRich, version: 1 };
})();
