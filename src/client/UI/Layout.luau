--[[
	Device layout: what kind of screen this is and how big the UI should be.
		Layout.kind()         "phone" | "tablet" | "desktop" | "console"
		Layout.userScale()    the size multiplier from settings (consoles start bigger)
		Layout.setPref(p)     "small" | "auto" | "big" | "huge"
		Layout.sideWidth(w)   how wide each side panel can be on a screen w logical px wide
		                      (0 when there's no room and the panels become a drawer)
		Layout.changed        fires when the preference, the device or the screen changes
]]

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Layout = {}

Layout.SCALES = { small = 0.9, auto = 1, big = 1.15, huge = 1.3 }
Layout.pref = "auto"
Layout.COLUMN = 560
Layout.SIDE_MIN = 270
Layout.SIDE_MAX = 360
Layout.GAP = 14

local changed = Instance.new("BindableEvent")
Layout.changed = changed.Event

local cached: string? = nil

function Layout.kind(): string
	if cached then
		return cached
	end
	local kind = "desktop"
	local ok, tenFoot = pcall(function()
		return GuiService:IsTenFootInterface()
	end)
	-- the camera can be missing on the very first frame
	local okVp, vp = pcall(function()
		return workspace.CurrentCamera.ViewportSize
	end)
	if not okVp or typeof(vp) ~= "Vector2" or vp.X <= 1 then
		vp = Vector2.new(1280, 720)
	end
	if ok and tenFoot then
		kind = "console"
	elseif UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		kind = if math.min(vp.X, vp.Y) < 600 then "phone" else "tablet"
	elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
		kind = "console"
	end
	cached = kind
	return kind
end

function Layout.userScale(): number
	if Layout.pref == "auto" and Layout.kind() == "console" then
		return 1.25
	end
	return Layout.SCALES[Layout.pref] or 1
end

function Layout.setPref(pref: string?)
	if pref and Layout.SCALES[pref] and pref ~= Layout.pref then
		Layout.pref = pref
		changed:Fire()
	end
end

-- Each side panel's width for a screen `width` logical pixels wide, or 0 for drawer mode.
function Layout.sideWidth(width: number): number
	local room = (width - Layout.COLUMN - 4 * Layout.GAP) / 2
	if room < Layout.SIDE_MIN then
		return 0
	end
	return math.min(Layout.SIDE_MAX, room)
end

-- v0.8: on a wide screen everything sits in one hub on the right of the life column.
-- The hub's width for a screen `width` logical pixels wide, or 0 (a phone: the drawer).
Layout.HUB_MAX = 440
function Layout.hubWidth(width: number): number
	local room = width - Layout.COLUMN - 4 * Layout.GAP
	if room < Layout.SIDE_MIN then
		return 0
	end
	return math.min(Layout.HUB_MAX, room)
end

-- ── FULL SCREEN ─────────────────────────────────────────────────────────────
-- On a wide screen (a PC, a console, a tablet on its side) the UI is laid out on a canvas of
-- about 1300-1420 x 800 logical pixels and scaled to fill the screen edge to edge, in three
-- full-height panels: you (left), the story (center), the hub (right).
Layout.MARGIN = 12

-- the UI scale for a screen `abs` pixels in size
function Layout.scaleFor(abs: Vector2): number
	local user = Layout.userScale()
	if abs.X >= 900 and abs.X > abs.Y * 1.2 then
		return math.clamp(math.min(abs.Y / 800, abs.X / 1300), 0.45, 2.4) * user
	end
	local s = math.clamp(math.min(abs.Y / 720, abs.X / 390), 0.6, 1) * user
	return math.min(s, abs.X / 340, abs.Y / 520)
end

-- The three panels for a canvas `width` logical pixels wide, or nil when there's no room
-- (then it's the life column with a hub beside it, or a phone's drawer).
function Layout.panels(width: number)
	local m, g = Layout.MARGIN, Layout.GAP
	local avail = width - 2 * m - 2 * g
	if avail < 1120 then
		return nil
	end
	local left = math.clamp(math.floor(avail * 0.235), 280, 350)
	local hub = math.clamp(math.floor(avail * 0.32), 390, 520)
	local center = avail - left - hub
	local extra = 0
	if center > 900 then
		-- a very wide screen: keep the story's lines a readable length
		extra = center - 900
		center = 900
	end
	local x0 = m + extra / 2
	return {
		left = left,
		center = center,
		hub = hub,
		leftX = x0,
		centerX = x0 + left + g,
		hubX = x0 + left + g + center + g,
	}
end

-- Where the life column sits: how far (logical px) it moves from the middle of the screen,
-- and how wide it is (nil: the usual column). Set by the side panels when they lay out.
Layout.mainShift = 0
Layout.mainWidth = nil :: number?
Layout.leftWidth = nil :: number?
function Layout.setMain(shift: number, width: number?, left: number?)
	if shift ~= Layout.mainShift or width ~= Layout.mainWidth or left ~= Layout.leftWidth then
		Layout.mainShift = shift
		Layout.mainWidth = width
		Layout.leftWidth = left
		changed:Fire()
	end
end
function Layout.setMainShift(px: number)
	Layout.setMain(px, nil, nil)
end

function Layout.isTouch(): boolean
	local k = Layout.kind()
	return k == "phone" or k == "tablet"
end

-- the device can change (a gamepad plugged in, a touch screen used)
UserInputService.LastInputTypeChanged:Connect(function()
	local before = cached
	cached = nil
	if Layout.kind() ~= before then
		changed:Fire()
	end
end)

return Layout
