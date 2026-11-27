--[[
	Visual theme: "the file". Ink-black panels with hard edges and brass
	corner brackets, condensed all-caps headings, crimson for danger, brass
	for money and action, teal for the strange. Tweak here and the whole UI follows.
]]

local Theme = {}

Theme.colors = {
	shade = Color3.fromRGB(5, 6, 8),
	panel = Color3.fromRGB(14, 16, 20),
	panelHi = Color3.fromRGB(24, 27, 33),
	panelLo = Color3.fromRGB(9, 10, 13),
	stroke = Color3.fromRGB(46, 50, 58),
	strokeHi = Color3.fromRGB(80, 85, 95),
	text = Color3.fromRGB(236, 232, 225),
	sub = Color3.fromRGB(168, 170, 176),
	faint = Color3.fromRGB(110, 114, 122),
	accent = Color3.fromRGB(207, 163, 73),
	accentHi = Color3.fromRGB(237, 196, 114),
	accentLo = Color3.fromRGB(122, 92, 36),
	crimson = Color3.fromRGB(196, 50, 42),
	crimsonHi = Color3.fromRGB(226, 86, 76),
	crimsonLo = Color3.fromRGB(96, 24, 20),
	paper = Color3.fromRGB(231, 224, 209),
	paperEdge = Color3.fromRGB(186, 174, 150),
	paperHi = Color3.fromRGB(243, 238, 226),
	ink = Color3.fromRGB(28, 26, 23),
	inkSub = Color3.fromRGB(98, 88, 74),
	good = Color3.fromRGB(122, 194, 140),
	bad = Color3.fromRGB(226, 86, 76),
	strange = Color3.fromRGB(96, 186, 178),
	money = Color3.fromRGB(234, 200, 108),
	coinHeads = Color3.fromRGB(232, 190, 96),
	coinTails = Color3.fromRGB(44, 48, 58),
}

-- (v0.13) how an event card is dressed for what it is (pending.theme, or its episode's):
-- the paper it's printed on, its edge, its band, a word for the band, and a motif drawn over it
--   scan   faint lines, like an old screen       depth  a depth gauge down the right edge
--   gild   gold corner brackets                  drip   a red edge along the top
--   grit   warning stripes in the band           haze   a soft fog from the bottom
Theme.cardThemes = {
	terminal = { paper = Color3.fromRGB(214, 226, 214), edge = Color3.fromRGB(70, 150, 104), band = Color3.fromRGB(18, 48, 34), accent = Color3.fromRGB(96, 214, 140), word = "Facility record", motif = "scan" },
	delve = { paper = Color3.fromRGB(206, 210, 218), edge = Color3.fromRGB(84, 102, 138), band = Color3.fromRGB(20, 26, 42), accent = Color3.fromRGB(130, 160, 230), word = "Going down", motif = "depth" },
	blood = { paper = Color3.fromRGB(230, 212, 210), edge = Color3.fromRGB(150, 40, 54), band = Color3.fromRGB(70, 12, 22), accent = Color3.fromRGB(214, 60, 80), word = "By invitation", motif = "drip" },
	library = { paper = Color3.fromRGB(236, 224, 196), edge = Color3.fromRGB(176, 140, 70), band = Color3.fromRGB(64, 44, 22), accent = Color3.fromRGB(226, 186, 100), word = "From the stacks", motif = "gild" },
	street = { paper = Color3.fromRGB(226, 220, 208), edge = Color3.fromRGB(150, 130, 100), band = Color3.fromRGB(42, 36, 30), accent = Color3.fromRGB(230, 170, 90), word = "The Backstreets", motif = "grit" },
	smoke = { paper = Color3.fromRGB(218, 216, 212), edge = Color3.fromRGB(120, 118, 112), band = Color3.fromRGB(46, 46, 46), accent = Color3.fromRGB(190, 186, 176), word = "From before", motif = "haze" },
	strange = { paper = Color3.fromRGB(222, 218, 232), edge = Color3.fromRGB(120, 100, 170), band = Color3.fromRGB(36, 28, 60), accent = Color3.fromRGB(176, 150, 240), word = "Unexplained", motif = "haze" },
	nest = { paper = Color3.fromRGB(240, 236, 228), edge = Color3.fromRGB(196, 170, 110), band = Color3.fromRGB(40, 40, 52), accent = Color3.fromRGB(230, 200, 130), word = "In good company", motif = "gild" },
	lake = { paper = Color3.fromRGB(208, 224, 226), edge = Color3.fromRGB(70, 130, 140), band = Color3.fromRGB(16, 44, 52), accent = Color3.fromRGB(110, 200, 210), word = "Off the Great Lake", motif = "haze" },
	gold = { paper = Color3.fromRGB(240, 228, 196), edge = Color3.fromRGB(206, 160, 60), band = Color3.fromRGB(60, 42, 12), accent = Color3.fromRGB(250, 206, 100), word = "Once in a life", motif = "gild" },
}

local oswald = Font.fromEnum(Enum.Font.Oswald).Family
local merri = Font.fromEnum(Enum.Font.Merriweather).Family
local gotham = Font.fromEnum(Enum.Font.Gotham).Family

Theme.fonts = {
	-- condensed caps for headings, labels and buttons
	display = Font.new(oswald, Enum.FontWeight.Bold),
	displayMed = Font.new(oswald, Enum.FontWeight.Medium),
	-- prose
	title = Font.new(merri, Enum.FontWeight.Bold),
	serif = Font.new(merri, Enum.FontWeight.Regular),
	serifItalic = Font.new(merri, Enum.FontWeight.Regular, Enum.FontStyle.Italic),
	-- small interface text
	ui = Font.new(gotham, Enum.FontWeight.Regular),
	uiMedium = Font.new(gotham, Enum.FontWeight.Medium),
	uiBold = Font.new(gotham, Enum.FontWeight.Bold),
	-- numbers and file stamps
	mono = Font.fromEnum(Enum.Font.RobotoMono),
	type = Font.fromEnum(Enum.Font.SpecialElite),
}

Theme.sizes = {
	columnWidth = 560,
	corner = 3,
	pad = 12,
}

function Theme.rgb(t): Color3
	if typeof(t) == "Color3" then
		return t
	end
	return Color3.fromRGB(t[1], t[2], t[3])
end

-- A storyline's tone (grim, tragic, strange, hopeful) as a color.
local TONE_COLORS = {
	grim = Color3.fromRGB(214, 84, 70),
	tragic = Color3.fromRGB(150, 110, 220),
	strange = Color3.fromRGB(70, 196, 186),
	hopeful = Color3.fromRGB(232, 196, 104),
}
function Theme.tone(tone: string?): Color3
	return TONE_COLORS[tone or ""] or TONE_COLORS.grim
end

-- (blueprint) a game's own colors (spec.theme, sent with hello): any key of Theme.colors as
-- { r, g, b }. `accent` alone also sets accentHi and accentLo (lighter and darker), and
-- `crimson` its Hi and Lo, unless those are given too. Called once, before the screens are
-- built; everything drawn after uses the new colors.
local function rgb(t: any): Color3?
	if type(t) == "table" and type(t[1]) == "number" and type(t[2]) == "number" and type(t[3]) == "number" then
		return Color3.fromRGB(t[1], t[2], t[3])
	end
	return nil
end
function Theme.apply(theme: any)
	if type(theme) ~= "table" then
		return
	end
	local c = Theme.colors
	for key, value in theme do
		local col = rgb(value)
		if col and c[key] ~= nil then
			c[key] = col
		end
	end
	local accent = rgb(theme.accent)
	if accent then
		c.accentHi = rgb(theme.accentHi) or accent:Lerp(Color3.new(1, 1, 1), 0.28)
		c.accentLo = rgb(theme.accentLo) or accent:Lerp(Color3.new(0, 0, 0), 0.45)
		c.coinHeads = rgb(theme.coinHeads) or accent:Lerp(Color3.new(1, 1, 1), 0.12)
	end
	local crimson = rgb(theme.crimson)
	if crimson then
		c.crimsonHi = rgb(theme.crimsonHi) or crimson:Lerp(Color3.new(1, 1, 1), 0.25)
		c.crimsonLo = rgb(theme.crimsonLo) or crimson:Lerp(Color3.new(0, 0, 0), 0.5)
	end
	local panel = rgb(theme.panel)
	if panel then
		c.panelHi = rgb(theme.panelHi) or panel:Lerp(Color3.new(1, 1, 1), 0.06)
		c.panelLo = rgb(theme.panelLo) or panel:Lerp(Color3.new(0, 0, 0), 0.3)
	end
	Theme.applied = theme
end

return Theme
