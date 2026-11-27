--[[
	Traits from the voice and from the second Light. None are pickable: each comes out of a story
	(Events/Ages.luau) or out of years of training (the "still your heart" activities).
	Fields: see Traits/Core.luau. `yearly` is what carrying it costs every year.
]]

return {
	order = { "ego_volatile", "shin", "mang_one", "mang_two", "mang_three" },

	-- THE VOLATILE E.G.O: you refused the voice, but you couldn't look at all of it. It can be
	-- used in a fight (the Volatile approach), it costs more Sanity than a true E.G.O, and it is
	-- no protection: the next time you break, she comes back (carmen_returns).
	ego_volatile = {
		name = "Volatile E.G.O",
		desc = "Half an answer to the voice: bright, cracked, and unstable. You can let it out in a fight for a heavy price in Sanity. It will not protect you the next time you break. Looking at the rest of it then makes it whole, or ends you.",
		yearly = { sanity = { -2, -1 } },
		color = { 255, 150, 90 },
	},

	-- SHIN: a heart held still, for years. Only after the second Light.
	shin = {
		name = "Shin",
		desc = "A heart held perfectly still. It amplifies what you already are: +1 base in every fight and +3% heads. It takes years, and it can't be hurried.",
		fight = { base = 1 },
		heads = 3,
		color = { 150, 200, 255 },
	},
	-- MANG: rings shaped out of Shin, each one a thing you want, resent or grieve, held still.
	-- Each ring nearly doubles the strain of the last.
	mang_one = {
		name = "Mang: one ring",
		desc = "One ring of wanting at your back. +1 power on every heads in a fight. It costs a little Sanity every year to keep it still.",
		fight = { coinPower = 1 },
		yearly = { sanity = -1 },
		color = { 255, 120, 80 },
	},
	mang_two = {
		name = "Mang: two rings",
		desc = "Two rings. +1 base and +1 potency in a fight, on top of the first. The strain is nearly double.",
		fight = { base = 1, potency = 1 },
		yearly = { sanity = -2 },
		color = { 255, 100, 70 },
	},
	mang_three = {
		name = "Mang: three rings",
		desc = "Three rings: what a Color carries. +1 coin in a fight, on top of the others. Very few minds can hold this, and none of them hold it comfortably.",
		fight = { coins = 1 },
		yearly = { sanity = -4 },
		color = { 255, 70, 60 },
	},
}
