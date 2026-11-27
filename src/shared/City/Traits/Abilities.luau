--[[
	Abilities learned from books (Books/Loot.luau): bl_ ids. Earned by reading, never picked.
	Style abilities only work with their own fighting style. Every one also sets a flag
	(bl_ab_learned) so records and titles can see that a life taught itself something.
]]

local LEARNED = { "bl_ab_learned" }

return {
	order = {
		"bl_ab_ivory_stance", "bl_ab_cloud_draw", "bl_ab_propellant", "bl_ab_obedient_hands", "bl_ab_never_forget",
		"bl_ab_clearance", "bl_ab_night_sense", "bl_ab_suppression", "bl_ab_red_mend", "bl_ab_wu_gait",
		"bl_ab_nailwork", "bl_ab_beast_reader", "bl_ab_critics_eye", "bl_ab_afterimage", "bl_ab_quick_study",
		"bl_ab_drill_rhythm", "bl_ab_emotion_level",
	},

	bl_ab_ivory_stance = {
		name = "Ivory Stance",
		desc = "Poise style only. The Verdict's footwork: +2 Poise potency and +1 coin in fights.",
		style = "poise",
		fight = { potency = 2, coins = 1 },
		flags = LEARNED,
	},
	bl_ab_cloud_draw = {
		name = "Black Cloud Draw",
		desc = "Bleed style only. The Kurokumo quick-draw: +1 Bleed potency and +1 power per heads in fights.",
		style = "bleed",
		fight = { potency = 1, coinPower = 1 },
		flags = LEARNED,
	},
	bl_ab_propellant = {
		name = "Propellant Drill",
		desc = "Burn style only. Load, brace, fire, like a Soldato: +1 Burn potency and +1 base in fights.",
		style = "burn",
		fight = { potency = 1, base = 1 },
		flags = LEARNED,
	},
	bl_ab_obedient_hands = {
		name = "Obedient Hands",
		desc = "Your hands do exactly what they're told: +1 base in fights and +1 coin in Intelligence checks.",
		fight = { base = 1 },
		clash = { intelligence = { coins = 1 } },
		flags = LEARNED,
	},
	bl_ab_never_forget = {
		name = "Never Forget",
		desc = "Tremor style only. Every grudge goes into the swing: +1 Tremor potency and +2 base in fights.",
		style = "tremor",
		fight = { potency = 1, base = 2 },
		flags = LEARNED,
	},
	bl_ab_clearance = {
		name = "Clearance Drills",
		desc = "LCD field training: +1 coin in Health checks, and you take 10% less Health damage.",
		clash = { health = { coins = 1 } },
		toughness = 0.9,
		flags = LEARNED,
	},
	bl_ab_night_sense = {
		name = "Night Sense",
		desc = "You always know what time it is, and where the nearest open door is: +1 coin in Mental Strength checks, +5 Sanity.",
		clash = { mind = { coins = 1 } },
		sanity = 5,
		flags = LEARNED,
	},
	bl_ab_suppression = {
		name = "Suppression Protocol",
		desc = "L Corp's way of putting things back in the box: +1 coin in every fight.",
		fight = { coins = 1 },
		flags = LEARNED,
	},
	bl_ab_red_mend = {
		name = "Red Mend",
		desc = "A Bloodfiend's trick of closing wounds by will: you take 25% less Health damage, and +6 Health.",
		toughness = 0.75,
		stats = { health = 6 },
		flags = LEARNED,
	},
	bl_ab_wu_gait = {
		name = "Wu Gait",
		desc = "Rupture style only. The Heishou horse branch's gallop: +2 Rupture potency and +1 base in fights.",
		style = "rupture",
		fight = { potency = 2, base = 1 },
		flags = LEARNED,
	},
	bl_ab_nailwork = {
		name = "Nailwork",
		desc = "Bleed style only. The Inquisition's method, without the faith: +2 Bleed potency in fights. Reading it cost you 4 Sanity.",
		style = "bleed",
		fight = { potency = 2 },
		sanity = -4,
		flags = LEARNED,
	},
	bl_ab_beast_reader = {
		name = "Beast Reader",
		desc = "You read a monster the way a sailor reads weather: +1 base in fights, and Health grows 30% faster.",
		fight = { base = 1 },
		growth = { health = 1.3 },
		flags = LEARNED,
	},
	bl_ab_critics_eye = {
		name = "Critic's Eye",
		desc = "Bleed style only. You see where a body is badly composed: +1 Bleed potency and +1 power per heads in fights.",
		style = "bleed",
		fight = { potency = 1, coinPower = 1 },
		flags = LEARNED,
	},
	bl_ab_afterimage = {
		name = "Afterimage",
		desc = "Sinking style only. You move like a light going out: +2 Sinking potency in fights and +4% heads.",
		style = "sinking",
		fight = { potency = 2 },
		heads = 4,
		flags = LEARNED,
	},
	bl_ab_quick_study = {
		name = "Quick Study",
		desc = "Somebody's margins taught you how to learn: every stat grows 20% faster.",
		growth = 1.2,
		flags = LEARNED,
	},
	bl_ab_drill_rhythm = {
		name = "Drill Rhythm",
		desc = "You drill to a count now: style mastery grows 50% faster.",
		masteryGrowth = 1.5,
		flags = LEARNED,
	},
	bl_ab_emotion_level = {
		name = "Emotion Level",
		desc = "Like a Librarian, you get better as a fight goes on: +1 base in fights and +5% heads.",
		fight = { base = 1 },
		heads = 5,
		flags = LEARNED,
	},
}
