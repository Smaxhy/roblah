/*
  A stand-in for the 3D City behind the UI (src/client/BackdropCity.luau builds it out of parts,
  which isn't GUI and isn't in the dump). In game, LifeSimBack's 25%-see-through shade sits over
  it, so something has to be behind the UI for the colours to read right. This is the night
  skyline from preview/index.html (drawCity, "BackdropCity.luau, flattened"), drawn once, still.
    GuiBackdrop.draw(canvas, width, height, dpr, kind)   kind: "city" | "dark" | "none"
*/
(function () {
  "use strict";
  function rand(seed) {
    let s = seed % 2147483647;
    if (s <= 0) s += 2147483646;
    return () => (s = (s * 48271) % 2147483647) / 2147483647;
  }
  const WING_COLORS = [[150, 170, 200], [214, 96, 88], [120, 170, 226], [168, 120, 222], [222, 198, 96]];
  const SIGN = ["#ff4646", "#50ffaa", "#be6eff", "#ffbe3c", "#50beff"];

  function city(ctx, W, H) {
    const r = rand(1313);
    const sky = ctx.createLinearGradient(0, 0, 0, H);
    sky.addColorStop(0, "#06070c"); sky.addColorStop(0.42, "#11131d"); sky.addColorStop(0.6, "#2a1d25"); sky.addColorStop(0.7, "#191419");
    ctx.fillStyle = sky; ctx.fillRect(0, 0, W, H);
    // the Nests: glass towers on walled platforms, each crowned in its Wing's colour
    const nestY = H * 0.52;
    const beacons = [];
    [0.12, 0.36, 0.63, 0.88].forEach((fx, i) => {
      const nx = W * fx + (r() - 0.5) * W * 0.05, nw = Math.max(90, W * (0.09 + r() * 0.05));
      ctx.fillStyle = "#161922"; ctx.fillRect(nx - nw * 0.75, nestY - 8, nw * 1.5, 12);
      ctx.fillStyle = "rgba(196,222,255,.25)"; ctx.fillRect(nx - nw * 0.75, nestY - 9, nw * 1.5, 1);
      const count = 5 + Math.floor(r() * 4);
      let tx = nx - nw / 2;
      for (let k = 0; k < count; k++) {
        const tw = (nw / count) * (0.75 + r() * 0.5);
        const centre = 1 - Math.min(1, Math.abs(tx + tw / 2 - nx) / (nw * 0.7));
        const th = H * (0.08 + centre * 0.22 + r() * 0.06);
        const g = ctx.createLinearGradient(0, nestY - th, 0, nestY);
        g.addColorStop(0, "#2b3344"); g.addColorStop(1, "#131720");
        ctx.fillStyle = g; ctx.fillRect(tx, nestY - th, tw, th);
        for (let wy = nestY - th + 6; wy < nestY - 6; wy += 6) for (let wx = tx + 2; wx < tx + tw - 2; wx += 4) {
          if (r() < 0.3) { ctx.fillStyle = `rgba(196,222,255,${0.2 + r() * 0.5})`; ctx.fillRect(wx, wy, 1.6, 2.4); }
        }
        if (centre > 0.75 && !beacons.some((b) => b.n === i)) beacons.push({ n: i, x: tx + tw / 2, y: nestY - th - 3, c: WING_COLORS[(i * 3 + 1) % WING_COLORS.length], p: r() * 6.28 });
        tx += tw + 1;
      }
    });
    const haze = ctx.createLinearGradient(0, H * 0.34, 0, H * 0.7);
    haze.addColorStop(0, "rgba(150,90,110,0)"); haze.addColorStop(1, "rgba(150,90,110,.2)");
    ctx.fillStyle = haze; ctx.fillRect(0, H * 0.34, W, H * 0.36);
    // the WARP rail on its pylons
    const railY = H * 0.61;
    ctx.fillStyle = "#0b0c11";
    for (let px = -20 + r() * 40; px < W + 40; px += 86 + r() * 20) ctx.fillRect(px, railY, 6, H - railY);
    ctx.fillStyle = "#1a1c24"; ctx.fillRect(0, railY - 4, W, 7);
    ctx.fillStyle = "rgba(120,200,255,.3)"; ctx.fillRect(0, railY - 5, W, 1);
    // the Backstreets: dense low blocks, warm windows, neon signs
    const signs = [];
    [{ y: H * 0.76, h: [24, 66], c: "#131219", lit: 0.2 }, { y: H * 0.88, h: [30, 92], c: "#0d0c12", lit: 0.15 }, { y: H * 1.01, h: [40, 120], c: "#08080b", lit: 0.12 }].forEach((row) => {
      let x = -10;
      while (x < W + 10) {
        const w = 18 + r() * 44, bh = row.h[0] + r() * (row.h[1] - row.h[0]);
        ctx.fillStyle = row.c; ctx.fillRect(x, row.y - bh, w, bh + 2);
        if (r() < 0.3) ctx.fillRect(x + w * 0.2, row.y - bh - 6, 7, 6);
        if (r() < 0.25) ctx.fillRect(x + w * 0.7, row.y - bh - 14, 1.5, 14);
        for (let wy = row.y - bh + 6; wy < row.y - 6; wy += 9) for (let wx = x + 4; wx < x + w - 4; wx += 7) {
          if (r() < row.lit) { ctx.fillStyle = `rgba(255,186,112,${0.35 + r() * 0.5})`; ctx.fillRect(wx, wy, 3, 4); }
        }
        if (r() < 0.24) signs.push({ x: x + 3 + r() * Math.max(1, w - 16), y: row.y - bh * (0.3 + r() * 0.5), w: 8 + r() * 12, h: 3 + r() * 3, c: SIGN[Math.floor(r() * SIGN.length)] });
        x += w + r() * 3;
      }
    });
    // one still frame of the lights
    for (const b of beacons) {
      const a = 0.55 + Math.sin(b.p) * 0.35;
      const g = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, 18);
      g.addColorStop(0, `rgba(${b.c[0]},${b.c[1]},${b.c[2]},${a})`); g.addColorStop(1, `rgba(${b.c[0]},${b.c[1]},${b.c[2]},0)`);
      ctx.fillStyle = g; ctx.fillRect(b.x - 18, b.y - 18, 36, 36);
    }
    for (const sg of signs) {
      ctx.globalAlpha = 0.85; ctx.fillStyle = sg.c; ctx.fillRect(sg.x, sg.y, sg.w, sg.h);
      const cx = sg.x + sg.w / 2, cy = sg.y + sg.h / 2;
      const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, 16);
      g.addColorStop(0, sg.c + "55"); g.addColorStop(1, sg.c + "00");
      ctx.fillStyle = g; ctx.fillRect(cx - 16, cy - 16, 32, 32); ctx.globalAlpha = 1;
    }
  }

  function draw(canvas, W, H, dpr, kind) {
    dpr = dpr || 1;
    canvas.width = Math.round(W * dpr);
    canvas.height = Math.round(H * dpr);
    canvas.style.width = W + "px";
    canvas.style.height = H + "px";
    const ctx = canvas.getContext("2d");
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    if (kind === "none") { ctx.clearRect(0, 0, W, H); return; }
    if (kind === "dark") {
      const g = ctx.createLinearGradient(0, 0, 0, H);
      g.addColorStop(0, "#0a0c12"); g.addColorStop(1, "#15121a");
      ctx.fillStyle = g; ctx.fillRect(0, 0, W, H);
      return;
    }
    city(ctx, W, H);
  }

  window.GuiBackdrop = { draw };
})();
