--[[
	Tooltips: hover (or tap, on a phone) something small to read what it is.
		Tip.setLayer(screenGui)                 -- once, from the app: where tips are drawn
		Tip.attach(guiObject, title, body?)     -- strings, or functions returning strings
	The tip appears under the object (above it near the bottom of the screen), stays while the
	mouse is over it, and for a few seconds after a tap.
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Tip = {}

local layer: ScreenGui? = nil
local current: Frame? = nil
local owner: GuiObject? = nil
local token = 0

function Tip.setLayer(gui: ScreenGui)
	layer = gui
end

function Tip.hide(from: GuiObject?)
	if from and owner ~= from then
		return
	end
	token += 1
	if current then
		current:Destroy()
		current = nil
	end
	owner = nil
end

local function resolve(v: any): string?
	if type(v) == "function" then
		local ok, out = pcall(v)
		return if ok and type(out) == "string" then out else nil
	end
	return if type(v) == "string" then v else nil
end

function Tip.show(target: GuiObject, title: any, body: any)
	local gui = layer
	if not gui then
		return
	end
	local head, text = resolve(title), resolve(body)
	if not head and not text then
		return
	end
	Tip.hide()
	owner = target
	local width = 250
	local frame = new("Frame", {
		Name = "Tip",
		BackgroundColor3 = Color3.fromRGB(26, 29, 36),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 100,
		Parent = gui,
	}, { Kit.corner(4), Kit.padding(9, 11, 10, 11), Kit.list(3), Kit.depth(nil :: any, true) })
	Kit.stroke(C.accent, 1, 0.2).Parent = frame
	if head then
		Kit.caps({ Text = string.upper(Format.escape(head)), FontFace = F.display, TextSize = 13, TextColor3 = C.accentHi, LayoutOrder = 1, ZIndex = 101, Parent = frame })
	end
	if text and text ~= "" then
		Kit.text({ Text = Format.escape(text), FontFace = F.serif, TextSize = 13, TextColor3 = C.text, LayoutOrder = 2, ZIndex = 101, Parent = frame })
	end
	-- under the target, kept on screen; above it when there's no room below
	local pos, size = target.AbsolutePosition, target.AbsoluteSize
	local screen = gui.AbsoluteSize
	local x = math.clamp(pos.X, 6, math.max(6, screen.X - width - 6))
	local below = pos.Y + size.Y + 6
	if below > screen.Y - 110 then
		frame.AnchorPoint = Vector2.new(0, 1)
		frame.Position = UDim2.fromOffset(x, pos.Y - 6)
	else
		frame.Position = UDim2.fromOffset(x, below)
	end
	current = frame
end

function Tip.attach(target: GuiObject, title: any, body: any)
	target.Active = true
	target.MouseEnter:Connect(function()
		Tip.show(target, title, body)
	end)
	target.MouseLeave:Connect(function()
		Tip.hide(target)
	end)
	target.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			Tip.show(target, title, body)
			token += 1
			local mine = token
			task.delay(3.5, function()
				if token == mine then
					Tip.hide(target)
				end
			end)
		end
	end)
	target.Destroying:Connect(function()
		Tip.hide(target)
	end)
end

return Tip
