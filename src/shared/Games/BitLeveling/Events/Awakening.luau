--[[
	AWAKENING CARDS. Engine/HunterWorld.awakening rolls whether a life awakens (and at what
	rank and class: ORIGINAL odds; canon gives none) and queues aw_wake_<rank>. The rank is
	the rank for life (canon). aw_reawaken_<rank> is the very rare second awakening.
	Never drawn at random (weight 0).
]]

local RANKS = { "E", "D", "C", "B", "A", "S" }
local FORMS = { "hunter_e", "hunter_d", "hunter_c", "hunter_b", "hunter_a", "hunter_s" }

local OPENINGS = {
	E = "You woke up at four in the morning with a fever that wasn't a fever. Your hands felt like someone else's for a week. The Association's measuring device gave a reading so low the technician checked it twice: {gRank}, {gClass}. Awake, but barely.",
	D = "It happened in the middle of an ordinary day: a pressure behind your eyes, a rush, then everything sharper. At the {gCity} branch, the measurement came back {gRank}. A {gClass}. Enough to work. Not enough to be anyone.",
	C = "You fainted on the subway, and when you came to, the handrail you'd grabbed was bent in your fist. The Association's reading: {gRank}, {gClass}. The technician smiled for the first time all day. Guilds would be calling.",
	B = "Three days of sleep, and when you opened your eyes the room was too loud and too bright and far too slow. The reading at the {gCity} branch drew a supervisor out of a meeting: {gRank}, {gClass}. A guild recruiter was waiting in the lobby by the time you left.",
	A = "You awakened in a single night, hard and all at once; the window glass in your room cracked. At the branch they had to recalibrate the device. {gRank}. {gClass}. There are maybe a few hundred like you in the country. Everyone you love is going to start treating you differently.",
	S = "The measuring device stopped working. They brought a second one from headquarters, and it read {gRank}. {gClass}. Nobody in the room said anything for a long moment. There have been only a handful of S-ranks in the whole country's history, and now there is you, and the phones in the building have started ringing.",
}

local cards = {}
for i, L in RANKS do
	table.insert(cards, {
		id = "aw_wake_" .. L,
		title = "Awakening: {gRank}",
		text = OPENINGS[L],
		weight = 0,
		when = { flags = { "hw_on_aw_wake_" .. L } },
		tags = { "awakening" },
		choices = {
			{
				label = "Register with the Association",
				hint = "A Hunter's licence: legal raids, guild work, and your rank on record.",
				result = { form = FORMS[i], setFlags = { "licensed", "awakened" }, clearFlags = { "hw_on_aw_wake_" .. L }, sanity = 2, codex = { "lore_awakening", "lore_ranks", "lore_classes" }, log = "You were measured, photographed and licensed: a {gRank} Hunter, {gClass}. The card is heavier than it looks." },
			},
			{
				label = "Keep it to yourself for now",
				hint = "You're still yourself. Probably. You can register later (an activity).",
				result = { form = FORMS[i], setFlags = { "awakened", "unregistered" }, clearFlags = { "hw_on_aw_wake_" .. L }, sanity = -1, codex = { "lore_awakening" }, log = "You told nobody. You started noticing how fragile door handles are." },
			},
		},
	})
	if i > 1 then
		table.insert(cards, {
			id = "aw_reawaken_" .. L,
			title = "A Second Awakening",
			text = "It came back, the fever-that-isn't from years ago, and this time it didn't stop. When you could stand again you went straight to the Association. The old record said {gTrueRank}. The new measurement says {gRank}. The technician says reawakenings are so rare most of them are rumours.",
			weight = 0,
			when = { flags = { "hw_on_aw_reawaken_" .. L } },
			tags = { "awakening", "strange" },
			choices = {
				{
					label = "Have the Association record it",
					result = { form = FORMS[i], setFlags = { "licensed", "reawakened_public" }, clearFlags = { "hw_on_aw_reawaken_" .. L }, sanity = 4, codex = { "lore_reawakening" }, log = "Re-registered at {gRank}. The news ran a small story about it, without your name." },
				},
				{
					label = "Keep the old licence and say nothing",
					hint = "Being underestimated has its uses.",
					result = { form = FORMS[i], clearFlags = { "hw_on_aw_reawaken_" .. L }, sanity = 1, codex = { "lore_reawakening" }, log = "Your licence still says {gTrueRank}. You know better." },
				},
			},
		})
	end
end
return cards
