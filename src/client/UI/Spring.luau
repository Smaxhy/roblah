--[[
	SPRING (v0.18): UI motion on springs, from spr (Fraktality, MIT, vendored in
	client/Vendor/spr.luau). A spring settles where a tween stops dead, so a card you point
	at lights up and eases back the way a physical thing would.

	  Spring.to(instance, damping, frequency, { Property = goal, ... })
	      damping 1 settles without overshoot, under 1 overshoots a little; frequency is how
	      fast (in cycles a second). Where spr can't run (an old client, the tests) it's a
	      short tween instead.
	  Spring.hover(frame, { lighten = 0.06 })
	      pointing at the frame brightens it and its UIStroke; leaving lets them settle back.
]]

local TweenService = game:GetService("TweenService")

local Spring = {}

local spr = nil
local tried = false
local function lib()
	if not tried then
		tried = true
		local ok, m = pcall(function()
			return require(script.Parent.Parent:WaitForChild("Vendor", 5):WaitForChild("spr", 5))
		end)
		if ok and type(m) == "table" then
			spr = m
		end
	end
	return spr
end

function Spring.to(inst: Instance, damping: number, frequency: number, props: { [string]: any })
	local s = lib()
	if s then
		local ok = pcall(s.target, inst, damping, frequency, props)
		if ok then
			return
		end
	end
	pcall(function()
		TweenService:Create(inst, TweenInfo.new(math.clamp(0.6 / math.max(frequency, 0.5), 0.08, 0.5), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
	end)
end

function Spring.hover(frame: GuiObject, opts: { lighten: number? }?)
	local o = opts or {}
	local stroke = frame:FindFirstChildOfClass("UIStroke")
	local restBg = frame.BackgroundColor3
	local hotBg = restBg:Lerp(Color3.new(1, 1, 1), o.lighten or 0.06)
	local restT, restW = 0, 1
	if stroke then
		restT, restW = stroke.Transparency, stroke.Thickness
	end
	frame.MouseEnter:Connect(function()
		Spring.to(frame, 0.75, 4, { BackgroundColor3 = hotBg })
		if stroke then
			Spring.to(stroke, 0.6, 4, { Transparency = math.max(0, restT - 0.45), Thickness = restW + 1 })
		end
	end)
	frame.MouseLeave:Connect(function()
		Spring.to(frame, 0.9, 3, { BackgroundColor3 = restBg })
		if stroke then
			Spring.to(stroke, 0.9, 3, { Transparency = restT, Thickness = restW })
		end
	end)
end

return Spring
