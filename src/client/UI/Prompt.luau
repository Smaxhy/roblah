--[[
	Small modal card with a title, text and buttons.
	Prompt.show(layer, { title = "...", text = "...", buttons = { { label = "OK", style = "primary", onClick = fn } } })
	-> close()
]]

local Theme = require(script.Parent.Theme)
local Kit = require(script.Parent.Kit)
local Format = require(script.Parent.Format)

local C = Theme.colors
local F = Theme.fonts
local new = Kit.new

local Prompt = {}

function Prompt.show(layer: Instance, opts)
	local scrim = Kit.scrim(layer, 1)
	Kit.tween(scrim, 0.2, { BackgroundTransparency = 0.4 })
	local card = Kit.panel({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.new(1, -24, 0, 0),
		BackgroundTransparency = 0,
		ZIndex = 2,
		Parent = layer,
	}, nil, C.accent)
	Kit.padding(18, 18, 16, 18).Parent = card
	Kit.list(12).Parent = card
	local scale = new("UIScale", { Scale = 0.94, Parent = card })

	Kit.text({
		Text = string.upper(Format.escape(opts.title or "")),
		FontFace = F.display,
		TextSize = 22,
		LayoutOrder = 1,
		ZIndex = 2,
		Parent = card,
	})
	if opts.text then
		Kit.text({
			-- opts.rich: the caller has written RichText (and escaped what needed it)
			Text = if opts.rich then opts.text else Format.escape(opts.text),
			FontFace = F.serif,
			TextSize = 15,
			TextColor3 = C.sub,
			LayoutOrder = 2,
			ZIndex = 2,
			Parent = card,
		})
	end
	local row = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 44),
		LayoutOrder = 3,
		ZIndex = 2,
		Parent = card,
	}, { Kit.list(8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right) })

	local closed = false
	local function close()
		if closed then
			return
		end
		closed = true
		Kit.tween(scrim, 0.15, { BackgroundTransparency = 1 })
		task.delay(0.15, function()
			scrim:Destroy()
			card:Destroy()
		end)
	end

	local buttons = opts.buttons or { { label = "OK", style = "primary" } }
	for i, b in buttons do
		local btn = Kit.button({
			name = b.name or ("PromptButton" .. i),
			text = b.label,
			style = b.style or "secondary",
			size = UDim2.new(1 / #buttons, -8, 1, 0),
			order = i,
			zIndex = 2,
			onClick = function()
				close()
				if b.onClick then
					b.onClick()
				end
			end,
		})
		btn.Parent = row
	end
	Kit.tween(scale, 0.22, { Scale = 1 }, Enum.EasingStyle.Back)
	return close
end

return Prompt
