# gui_render: screenshots of the real Roblox GUI, without Studio

The real client UI (`src/client/App.luau`, `src/client/UI/*`) runs inside Lune on `@lune/roblox`
instances against the real server code, gets driven to named states, and each state's
PlayerGui is dumped to JSON. A browser page then draws those dumps with Roblox's layout rules,
and Playwright saves PNGs.

## Run it

From anywhere (the Lune step runs from the repo root):

```
node tools/gui_render/shoot.js
```

That runs `lune run tests/gui_snapshot` (PC 1440x900 and phone 390x844, about 10 s each), then
draws every dump. Output:

| Path | What |
| --- | --- |
| `tools/gui_render/out/pc/<state>.png`, `out/phone/<state>.png` | the screenshots |
| `tools/gui_render/out/index.html` | contact sheet: every picture with its note, and skipped states with the reason |
| `tools/gui_render/out/dumps/<device>/<state>.json` | the dumps (the instance tree with every drawn property) |
| `tools/gui_render/out/dumps/<device>/manifest.json` | which states were saved or skipped, and why |

`out/` is generated; delete it whenever you like.

Options (shoot.js passes `--device` and `--states` on to the Lune step):

```
node tools/gui_render/shoot.js --device phone           one device (pc | phone | tablet)
node tools/gui_render/shoot.js --states menu,hud        only these states (prefixes work: creator)
node tools/gui_render/shoot.js --scale 2                PNGs at deviceScaleFactor 2
node tools/gui_render/shoot.js --render-only            re-draw the dumps already there (after a renderer change)
node tools/gui_render/shoot.js --dump x.json --png x.png    draw one dump file
node tools/gui_render/shoot.js --bg dark|none --no-topbar   backdrop / topbar overlay
node tools/gui_render/shoot.js --folder-padding off     see the note on Folders below
node tools/gui_render/shoot.js --outline                outline every GuiObject
```

The Lune step alone: `lune run tests/gui_snapshot [--device phone] [--states hud] [--size 1920x1080] [--list] [--verbose]`.

By hand in a browser: `python3 -m http.server -d tools/gui_render 8000`, then open
`http://localhost:8000/render.html?dump=out/dumps/pc/menu.json` (add `&outline=1`, `&bg=dark`,
`&topbar=0`, `&folderPadding=0`). Hovering shows which instance is under the cursor (its full
path, class and size). Opened as a file, the page takes a dump by drag and drop.

## The states

`lune run tests/gui_snapshot --list` prints them with notes. Today: `intro` and
`intro-montage` (two moments of the join cinematic), `daily`, `menu`, `creator`, `creator-hair`,
`creator-sins`, `birth`, `canto`, `tutorial`, `hud`, `activities`, `life`, `event`,
`event-approach`, `fight`,
`fight-end`, `check`, `store`, `guide`, `crew`, `duel`.

They run in order in one session, the way a player gets there: first join, the intro, the mode
select, the creator, a life (Fixer's Road) lived four years, a forced event, its fight and its
check, the sheets, then a second player who joins your crew and challenges you to a duel. A state
that fails is skipped with the reason, and the rest carry on; after a failure the runner clears
anything a crashed screen left on the clash layer so later pictures aren't covered.

### Adding one

Add an entry to `STEPS` in `tests/gui_snapshot.luau`:

```lua
{
	name = "settings",
	note = "The menu sheet (sound, display, family name, help).",
	run = function(h)
		h.closeSheets()
		h.actions.openMenu()
		h.wait(0.5)
		h.assert(h.has("Sheet"), "the menu didn't open")
	end,
},
```

`run` drives the app; the dump is taken when it returns, after `settle` seconds (default 0.6 so
tweens finish; `settle = 0` catches a moment mid-animation). The helpers (`h.press`,
`h.pressText`, `h.choice`, `h.type`, `h.admin`, `h.waitFor`, `h.quiet`, `h.liveYears`,
`h.player2`, ...) are listed at the top of that file. Time is virtual, so `h.wait(30)` takes a
fraction of a second.

## How it works

**tests/harness.luau** is ui_smoke's harness (ui_smoke itself is untouched) with what pictures
need: a virtual 60 fps clock behind `task.wait/delay/defer`, `os.clock` and tweens (tweens really
animate, with Roblox's easing styles); `Absolute*` worked out from the Size/Position/UIPadding/
UIScale chain and the screen (the App sizes its column from `ScreenGui.AbsoluteSize`, the creator
picks wide or narrow from it); `Signal:Wait()` that really waits (the fight screen waits for
Continue); property-changed signals; `UserInputService`, the camera's `ViewportSize` and the
topbar inset set per device, so `UI/Layout.luau` sees a PC (keyboard and mouse) or a phone (touch,
under 600 px). World events are off, the date and random seeds are fixed, so runs repeat. The 3D
backdrop modules are stubbed (the City isn't GUI). `UI/AvatarView.new/set` are wrapped so each
ViewportFrame remembers the appearance (look table) it shows.

**The dump** (`gui-snapshot/1`): `screen`, `inset`, `defaults` (each class's default property
values, from a fresh `@lune/roblox` instance) and `guis`: every visible ScreenGui, GuiObject,
Folder and UI modifier with the properties that differ from the defaults (UDim2 as
`[xScale, xOffset, yScale, yOffset]`, colors as 0-255, enums by name, fonts as
`{ family, weight, style }`, sequences as keypoint lists). ViewportFrames carry `viewport`: their
parts (shape, size, CFrame, color, material), the camera (CFrame, field of view) and `avatar`
(the look table and framing).

**render.js** lays everything out with Roblox's rules rather than CSS's, then paints absolutely
positioned divs: Size/Position as `scale x parent + offset` inside the parent's content box
(after UIPadding), AnchorPoint, AutomaticSize (text bounds or children, never below Size,
UISizeConstraint applied), UIListLayout (direction, padding, alignments, LayoutOrder/Name sort,
Wraps, flex Fill/Space*), UIGridLayout (cell size and padding, max cells, start corner,
alignment), ScrollingFrames (canvas from CanvasSize, never smaller than the window, grown by
AutomaticCanvasSize, scrolled by CanvasPosition clamped to the end, scrollbars), UIAspectRatio
and UISize constraints, UIScale (around the AnchorPoint) and Rotation (around the centre) as
transforms, ClipsDescendants, ZIndex sorting per parent, ScreenGui DisplayOrder and
IgnoreGuiInset. UICorner is border-radius; UIStroke is an outer (or inner/centre) ring that
follows the corners, or a text outline in Contextual mode on text; UIGradient is an SVG gradient
in the box's own 0..1 space (so Rotation and Offset behave like Roblox's on non-square boxes),
multiplying BackgroundColor3 like Roblox does. Text is measured and drawn by the browser with the
same fonts: TextSize as the em size, lines TextSize x LineHeight apart, TextWrapped, the
alignments (overflow goes both ways when centred, as in Roblox), TextTruncate's `...`,
TextScaled (largest size that fits, capped at 100 and by UITextSizeConstraint),
MaxVisibleGraphemes, TextStroke, TextBox placeholders, and RichText (`font` color/size/face/
family/weight/transparency, `b`, `i`, `u`, `s`, `br`, `uc`, `sc`, `stroke`, `mark`, comments,
entities; markup Roblox would reject is shown raw, as Roblox does). ViewportFrames are drawn
with three.js (vendored r128, the same build preview/index.html uses) from the dumped parts and
camera, lit by the frame's Ambient, LightColor and LightDirection; without WebGL a plain
silhouette stands in.

Fonts, from Google Fonts: Oswald, Merriweather, Roboto Mono and Special Elite are the same
families Roblox ships; Gotham (`GothamSSm`) isn't free, so Montserrat stands in (a little wider).
If Google Fonts can't be reached, system fallbacks are used and the text widths change.

## What isn't faithful

- **Behind the UI** is the night skyline from preview/index.html (a still, flat stand-in for the
  3D City from BackdropCity), under the game's own LifeSimBack shade. `--bg dark` or `--bg none`
  to drop it.
- **The topbar** (Roblox's menu and chat buttons over the 58 px inset) is drawn roughly; safe
  areas and notches aren't modelled.
- **Text** is the browser's: kerning, hinting and exact glyph placement differ a little, and
  Montserrat is wider than Gotham, so lines can wrap a word earlier or later than in game.
- **ZIndexBehavior.Global** is drawn like Sibling (children above their parent, siblings by
  ZIndex). The game only uses Global on two full-screen layers (the shade and the hit flash).
- **UIGradient on text** tints the text with the gradient's average colour; a gradient's
  effect on UIStroke isn't drawn. UIStroke LineJoinMode is ignored, and only the first stroke
  on an object is drawn.
- **Images** (ImageLabel/ImageButton) are a hatched placeholder; the game has none right now.
- **3D** is plain Lambert/Phong shading: no shadows, no Roblox material textures.
- Rules I couldn't check without Studio, so they're choices (say if Studio disagrees):
  - a parent's UIPadding also moves GuiObjects that sit in a Folder inside it (Kit's corner
    brackets on padded panels land inside the padding; `--folder-padding off` draws the other
    reading);
  - children sized with Scale inside an AutomaticSize parent follow the parent's final size and
    don't count toward it;
  - UIScale scales around the AnchorPoint and doesn't move layout siblings;
  - TextScaled text may wrap.
