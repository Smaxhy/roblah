--[[
	SOLD OUT (v0.12): sell a Bloodfiend Family to the hunters, and the Family hunts you back,
	climbing its own ranks (Careers/Bloodfiend.luau: Fledgling, Kindred of the Family,
	Hardblood Knight, Elder's Hand) until one of you is done. Beat its Elder's Hand and the
	Family lets you go; pay the blood-price and it might. A Kindred who gives up the Family's
	own cellar is a kin-seller, and the Elder comes last, in person.
	Canon: Bloodfiends form Families of Kindred led by Elders, shape their blood into weapons
	(Hardblood) and keep to old manners [Limbus, Canto VII]. The Morvaine Family, its ranks and
	these people are this game's own. Violence stays implied (Roblox Moderate).
]]

local HUNTED = "bf_hunted_family"

return {
	-- ── ways to sell them out ─────────────────────────────────────────────
	{
		id = "bf_sell_offer",
		title = "A Hunter's Price",
		text = "A Fixer from a hunting Office buys you noodles and doesn't eat his. \"You've been seen near a Hemobar cellar. We pay for addresses, and we pay well. Nobody will ever know it was you.\" He slides a card across the counter with a number on it, and the number is large.",
		weight = 5,
		once = true,
		tags = { "danger", "bloodfiend" },
		when = { minAge = 18, form = "human", flags = { "knows_bloodfiends" }, notFlags = { "bf_informer", "bf_sold_out" } },
		choices = {
			{
				label = "Sell them the address",
				hint = "A fortune now. The Family will hunt you, rank by rank.",
				result = {
					money = { 500, 1100 },
					sanity = -5,
					rep = { bloodfiends = -60 },
					setFlags = { "bf_sold_out" },
					condition = HUNTED,
					schedule = { event = "bf_hunt_fledgling", inYears = 1 },
					log = "You wrote the address on his card. He paid in clean notes. Three nights later there was a single red foil wrapper on your doorstep, folded into a small neat bird.",
				},
			},
			{ label = "Tell him nothing", result = { sanity = 1, rep = { bloodfiends = 4 }, log = "\"Never been near one,\" you said. He shrugged, paid for both bowls, and left the card. You burned it." } },
			{
				label = "Warn the Family",
				hint = "The hunters won't thank you. The Family will.",
				result = { rep = { bloodfiends = 18, fixers = -6 }, money = { 80, 160 }, log = "You left a note under the Hemobar's door. The next night the cellar was empty, and an envelope with your name on it was full." },
			},
		},
	},
	{
		id = "bf_member_offer",
		title = "A Price on the Cellar",
		text = "The hunters have found out what you are, and instead of coming for you they've come with an offer: the Family's cellar, its Elder's hours, the names of its Kindred. For that, they'll forget your face and pay you more than the Family ever has.",
		weight = 4,
		once = true,
		tags = { "danger", "bloodfiend" },
		when = { minAge = 20, career = "bf_family", notFlags = { "bf_sold_out" } },
		choices = {
			{
				label = "Give up the cellar",
				hint = "Leave the Family rich. The Family will send everyone it has, the Elder last.",
				result = {
					money = { 1500, 3200 },
					sanity = -10,
					quitCareer = true,
					rep = { bloodfiends = -95 },
					setFlags = { "bf_sold_out", "bf_kin_seller" },
					clearFlags = { "bf_family_member" },
					condition = HUNTED,
					schedule = { event = "bf_hunt_knight", inYears = 1 },
					log = "You drew the map from memory. The hunters were very pleased with you. You moved out that night, and you didn't sleep, and you knew you'd never really sleep again.",
				},
			},
			{
				label = "Refuse, and tell the Elder",
				hint = "Loyalty the Family will remember.",
				result = { rep = { bloodfiends = 25 }, mind = 2, promote = true, log = "The Elder listened without blinking. \"Good,\" she said. By morning the hunters' Office had a new tenant, and you had a new rank." },
			},
			{ label = "Refuse, and say nothing", result = { sanity = -2, log = "You told them no and walked home the long way. You never mentioned it to anyone. You wonder, sometimes, if the Elder knows anyway." } },
		},
	},

	-- ── the hunt, rank by rank ────────────────────────────────────────────
	{
		id = "bf_hunt_fledgling",
		title = "Footsteps on the Roof",
		text = "Someone is on the roof, keeping pace with you from building to building. When you stop, they stop. A Fledgling of the Family you sold out, sent to see what you're made of.",
		weight = 0,
		tags = { "danger", "bloodfiend" },
		when = { flags = { "bf_sold_out" } },
		choices = {
			{
				label = "Turn and fight",
				clash = { stat = "strength", foe = "A Fledgling of the Family", enemy = "bf_fledgling", coins = 3, base = 7, coinPower = 3, fight = true, status = "bleed" },
				win = { renown = 6, sanity = -2, schedule = { event = "bf_hunt_knight", inYears = 2 }, log = "The Fledgling went over the edge of the roof and didn't come back up. They'll send someone better next time. You'd send someone better." },
				lose = { health = { -18, -10 }, sanity = -4, schedule = { event = "bf_hunt_knight", inYears = 1 }, log = "It was quick and it was cruel and it was only meant to frighten you. It worked." },
			},
			{
				label = "Run for a lit street",
				clash = { stat = "speed", foe = "A Fledgling of the Family", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = -2, schedule = { event = "bf_hunt_knight", inYears = 2 }, log = "You made the noodle stalls with a second to spare. The footsteps stopped at the edge of the light." },
				lose = { health = { -12, -6 }, sanity = -3, schedule = { event = "bf_hunt_knight", inYears = 1 }, log = "You didn't make the light. You made it home, later, the long way, and locked every lock you had." },
			},
		},
	},
	{
		id = "bf_hunt_knight",
		title = "A Hardblood Knight",
		text = "A Hardblood Knight of the Family is waiting at your table when you come home, in a coat that's older than the building. \"You can pay what you owe,\" she says, \"in Ahn or in blood. I don't mind which.\"",
		weight = 0,
		tags = { "danger", "bloodfiend" },
		when = { flags = { "bf_sold_out" } },
		choices = {
			{
				label = "Fight her",
				clash = { stat = "strength", foe = "A Hardblood Knight", enemy = "bf_knight", coins = 4, base = 10, coinPower = 4, fight = true, status = "bleed" },
				win = { renown = 18, sanity = -4, schedule = { event = "bf_hunt_hand", inYears = 3 }, log = "Her blade of blood broke before your nerve did. She stood, bowed exactly as deep as was correct, and went out the window. The Family will send its Elder's Hand." },
				lose = { health = { -34, -20 }, sanity = -6, schedule = { event = "bf_hunt_hand", inYears = 2 }, cause = "Bled out after a Hardblood Knight's visit", log = "She left you on the floor, alive, because that was the message. The next one won't be." },
			},
			{
				label = "Pay the blood-price (1,500 Ahn)",
				requires = { min = { money = 1500 } },
				result = { money = -1500, rep = { bloodfiends = 30 }, cure = HUNTED, clearFlags = { "bf_sold_out" }, setFlags = { "bf_price_paid" }, log = "She counted it twice and put it away. \"The Family accepts,\" she said, and for the first time in a year you slept with the lamp off." },
			},
			{
				label = "Talk your way to time",
				clash = { stat = "charisma", foe = "A Knight's patience", coins = 3, base = 9, coinPower = 3 },
				win = { sanity = -2, schedule = { event = "bf_hunt_knight", inYears = 2 }, log = "You talked about old manners until she smiled despite herself. \"Two years,\" she said. \"Find the money, or find a weapon.\"" },
				lose = { health = { -20, -12 }, schedule = { event = "bf_hunt_hand", inYears = 2 }, log = "She listened, politely, and then she answered. You'll carry the answer for a while." },
			},
		},
	},
	{
		id = "bf_hunt_hand",
		title = "The Elder's Hand",
		text = "The Family has sent its Elder's Hand: the one who speaks with the Elder's voice, and fights with it too. He doesn't hide, and he doesn't hurry. He's standing in the street outside your window at noon, which no Bloodfiend should do, just so you know how little he fears anything.",
		weight = 0,
		tags = { "danger", "bloodfiend" },
		when = { flags = { "bf_sold_out" } },
		choices = {
			{
				label = "Go down and face him",
				clash = { stat = "strength", foe = "The Elder's Hand", enemy = "bf_hand", coins = 5, base = 13, coinPower = 4, fight = true, status = "bleed" },
				win = {
					renown = 45,
					sanity = -6,
					chronicle = "bf_hand_beaten",
					log = "When it was over he knelt, which nobody had seen him do. \"The Elder will hear that you stood,\" he said. Whatever the Family decides now, it will decide it about someone who beat its Hand.",
					schedule = { event = "bf_hunt_verdict", inYears = 1 },
				},
				lose = { die = "Taken by the Family they sold out", log = "He was exactly as good as the Family said. Better, at the end." },
			},
			{
				label = "Pay the blood-price (4,000 Ahn)",
				requires = { min = { money = 4000 } },
				result = { money = -4000, rep = { bloodfiends = 35 }, cure = HUNTED, clearFlags = { "bf_sold_out" }, setFlags = { "bf_price_paid" }, log = "He took it without counting. \"The Elder is generous today,\" he said. \"Don't be here when she isn't.\"" },
			},
			{
				label = "Leave the District tonight",
				clash = { stat = "speed", foe = "The Elder's Hand", coins = 4, base = 12, coinPower = 4 },
				win = { sanity = -5, district = "random", schedule = { event = "bf_hunt_hand", inYears = 3 }, log = "You were on the night train before he finished his tea. It won't be enough. It bought you three years." },
				lose = { health = { -40, -26 }, sanity = -8, schedule = { event = "bf_hunt_hand", inYears = 1 }, cause = "Caught running from the Elder's Hand", log = "He was waiting at the station, reading a timetable. He didn't kill you. He wanted the Elder to have the chance." },
			},
		},
	},
	{
		id = "bf_hunt_verdict",
		title = "The Elder's Verdict",
		text = "A letter sealed in red wax, delivered by a child who runs away before you can thank her. The Elder of the Family has considered the matter of you.",
		weight = 0,
		tags = { "bloodfiend" },
		when = { flags = { "bf_sold_out" } },
		choices = {
			{
				label = "Open it",
				result = {
					cure = HUNTED,
					clearFlags = { "bf_sold_out" },
					setFlags = { "bf_hunt_survived" },
					rep = { bloodfiends = 20 },
					renown = 10,
					log = "\"You sold us, and then you stood when we came. The first we will not forget. The second we will not forget either. The matter is closed.\" It was signed in a hand two hundred years old.",
					trigger = "bf_hunt_elder_check",
				},
			},
		},
	},
	{
		id = "bf_hunt_elder_check",
		title = "One More Line",
		text = "There's a second page folded inside the first. It is shorter. It is only for those who gave up the Family's own cellar.",
		weight = 0,
		tags = { "danger", "bloodfiend" },
		when = { flags = { "bf_kin_seller" } },
		choices = {
			{
				label = "Read it",
				result = { sanity = -6, setFlags = { "bf_sold_out" }, condition = HUNTED, schedule = { event = "bf_hunt_elder", inYears = 2 }, log = "\"For the one who was ours: I will come myself.\"" },
			},
		},
	},
	{
		id = "bf_hunt_elder",
		title = "The Elder Comes Herself",
		text = "No knock. The Elder of the Family is simply in your room when you turn around, older than the District and dressed for an opera. \"You were ours,\" she says, and the air smells of iron. \"I made a promise about you. I keep my promises.\"",
		weight = 0,
		tags = { "danger", "bloodfiend" },
		when = { flags = { "bf_sold_out", "bf_kin_seller" } },
		choices = {
			{
				label = "Fight the Elder",
				clash = { stat = "strength", foe = "The Family's Elder", enemy = "bf_elder", coins = 6, base = 15, coinPower = 5, fight = true, status = "bleed" },
				win = {
					renown = 120,
					cure = HUNTED,
					clearFlags = { "bf_sold_out", "bf_kin_seller" },
					setFlags = { "bf_elder_withdrew" },
					chronicle = "bf_elder_withdrew",
					log = "At the end she lowered her blade of blood and looked at you for a long, long time. \"Live, then,\" she said, \"and know that I let you.\" Then she was gone, and the room was only a room.",
				},
				lose = { die = "Taken by their own Family's Elder", log = "She kept her promise." },
			},
			{
				label = "Kneel and ask for the Family's mercy",
				clash = { stat = "charisma", foe = "Two hundred years of memory", coins = 5, base = 14, coinPower = 4 },
				win = { sanity = 8, cure = HUNTED, clearFlags = { "bf_sold_out", "bf_kin_seller" }, rep = { bloodfiends = 10 }, log = "You knelt and told her the truth, all of it. She listened like a judge. \"Mercy,\" she said at last, as if tasting an old word. \"Once.\"" },
				lose = { die = "Taken by their own Family's Elder", log = "She heard you out, and then she kept her promise." },
			},
		},
	},
}
