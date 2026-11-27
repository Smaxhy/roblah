--[[
	More scenes that only roll during world events (see Content/WorldEvents.luau
	and Events/WorldTimes.luau). Each is gated by when.worldEvent and boosted by
	that world event's tagWeights. Ids are prefixed wt2_.
		breach_tidewell   5 scenes (tag "breach")
		lantern_festival  3 scenes (tags "faith", "friend")
		great_low_tide    3 scenes (tag "salvage")
		fog_week          2 scenes (tags "strange", "danger", "crime")
		company_strike    2 scenes (tag "strike")
	Fog and strike scenes carry a higher weight: those world events boost few
	tags and only run for a few minutes.
	Sets: survived_breach (breach); broke_the_strike (strike).
]]

return {
	-- ── the breach at the Tidewell Institute ──
	{
		id = "wt2_breach_lamp_row",
		title = "The Lamps in a Row",
		text = "Every lamp on your street has been unscrewed and set down on the cobbles in a perfectly straight row, glass and all, still warm. A wet trail runs between them, uphill. Somewhere above you, very carefully, another lamp is being taken down.",
		cooldown = 4,
		tags = { "breach", "danger", "strange" },
		when = { worldEvent = "breach_tidewell", minAge = 10 },
		choices = {
			{
				label = "Put the lamps back up",
				hint = "Prudence clash. It hates the light.",
				clash = { stat = "prudence", foe = "The dark between the lamps", coins = 2, base = 4, coinPower = 3 },
				win = { justice = { 1, 2 }, sanity = 2, setFlags = { "survived_breach" }, log = "You climbed the street fitting every lamp back in. Halfway up, something wet hurried away from the light, and the street stayed lit all night." },
				lose = { fortitude = { -6, -2 }, sanity = -4, setFlags = { "survived_breach" }, log = "The lamps went out ahead of you one by one, faster than you could light them. You fell twice running home, and didn't stop shaking until morning.", cause = "Lost in the dark during the Tidewell breach" },
			},
			{ label = "Light every candle you own and stay in", result = { sanity = -1, log = "You lit every candle you owned and sat in the middle of the floor until dawn. Nothing came in. Something stood outside the door for a while." } },
			{ label = "Tell the nearest Institute warden", result = { prudence = 1, sanity = -1, log = "You told a warden in a rubber coat. She wrote 'lamps, in a row' on her clipboard and underlined it twice." } },
		},
	},
	{
		id = "wt2_breach_voice_in_drain",
		title = "A Voice in the Drain",
		text = "Past midnight, a voice comes up through the drain under your window. It is calling your name, softly and patiently, the way someone calls a child in for supper. The Institute's posters were very clear about this part: it learns names, and it wants you to answer.",
		cooldown = 5,
		tags = { "breach", "strange" },
		when = { worldEvent = "breach_tidewell", minAge = 8 },
		choices = {
			{
				label = "Don't answer. Not even a little.",
				hint = "Prudence clash.",
				clash = { stat = "prudence", foe = "The voice in the drain", coins = 2, base = 5, coinPower = 3 },
				win = { prudence = { 2, 3 }, sanity = -1, log = "You put your hands over your ears and hummed the bell-hours until dawn. The voice gave up before you did." },
				lose = { sanity = -7, condition = "night_terrors", log = "You didn't answer. You only went to the window to look. You don't remember the next hour, and your sleeves were wet to the elbow." },
			},
			{ label = "Bang a pot until it stops", result = { sanity = -2, log = "You banged a pot with a spoon until the whole building banged back. The voice stopped, as if offended." } },
			{
				label = "Ring your little bell",
				hint = "It rings when nothing touches it.",
				requires = { hasGear = "little_bell" },
				result = { prudence = 1, sanity = 2, log = "Your little bell rang once, clear as ice, before you even touched it. The voice in the drain went quiet and did not come back." },
			},
		},
	},
	{
		id = "wt2_breach_jam_jar",
		title = "Something in a Jam Jar",
		text = "Your neighbor's boy, Iver, has caught something in the gutter and brought it to you in a jam jar. It is the size of a thumb, grey as dishwater, and it presses itself flat against the glass wherever you stand. The Institute is paying for anything that came out of its vaults. Iver wants to keep it.",
		once = true,
		tags = { "breach", "strange" },
		when = { worldEvent = "breach_tidewell", minAge = 10 },
		choices = {
			{ label = "Take it to the Institute", result = { wage = { 10, 25 }, sanity = -1, log = "A Tidewell clerk weighed the jar, paid you, and told you it was only a tadpole. She said it very quickly." } },
			{ label = "Tip it back into the Mere", result = { prudence = 1, sanity = 2, log = "You and Iver tipped it into the Mere. It swam away fast, like it had somewhere to be." } },
			{ label = "Let Iver keep it", result = { sanity = -3, log = "Iver kept it on his windowsill, where it watched the street all week. Then one morning the jar was empty, and the lid was still on tight." } },
		},
	},
	{
		id = "wt2_breach_glasswall_families",
		title = "Families on the Stair",
		text = "The Institute is clearing the Glasswall Gutters street by street while it searches, and the families it moved out have ended up on your stair with their bedding in their arms. A grandmother is rocking a baby on the landing outside your door, humming to keep it quiet.",
		cooldown = 4,
		tags = { "breach" },
		when = { worldEvent = "breach_tidewell", side = "gutters", notDistrict = "glasswall", minAge = 14 },
		choices = {
			{ label = "Give them your room for the night", result = { fortitude = -1, justice = { 2, 3 }, sanity = 3, log = "You gave the grandmother and the baby your bed and slept on the landing in your coat. In the morning she had mended the coat without asking." } },
			{ label = "Bring blankets and broth", hint = "10 scrip.", requires = { min = { money = 10 } }, result = { money = -10, justice = { 1, 2 }, sanity = 2, log = "You bought broth for the whole landing and dug out every blanket you owned." } },
			{ label = "Keep your door shut", result = { sanity = -2, log = "You kept your door shut and listened to the humming on the landing until it finally stopped." } },
		},
	},
	{
		id = "wt2_breach_charter_gate",
		title = "The Gates Stay Shut",
		text = "The Charter gates of {district} have been chained for the breach. Through the bars you can see Gutter folk packed against the ironwork, asking to come inside until the sirens stop. The guards are looking straight ahead. One of them has the key on a ring at her belt.",
		cooldown = 4,
		tags = { "breach", "danger" },
		when = { worldEvent = "breach_tidewell", side = "charter", notDistrict = "drownside", minAge = 16 },
		choices = {
			{
				label = "Talk the guard into opening the gate",
				hint = "Justice clash. The company won't thank you.",
				clash = { stat = "justice", foe = "A guard with orders", coins = 2, base = 4, coinPower = 3 },
				win = { justice = { 2, 3 }, sanity = 4, log = "You argued until the guard unlocked the gate herself. Forty people slept in the company's glass hall that night, and not one candlestick went missing." },
				lose = { money = -20, sanity = -3, log = "The guard took your name, and the company fined you twenty {currency} for obstruction during an emergency." },
			},
			{ label = "Pass bread through the bars", hint = "10 scrip.", requires = { min = { money = 10 } }, result = { money = -10, justice = 1, sanity = 2, log = "You passed bread through the bars until your arms ached. Someone on the other side kept thanking you long after the bread ran out." } },
			{ label = "Go inside and draw the curtains", result = { sanity = -3, log = "You went inside and drew the curtains. You could still hear them." } },
		},
	},

	-- ── Lantern Night ──
	{
		id = "wt2_lantern_no_name",
		title = "A Lantern With No Name",
		text = "One lantern has drifted back to the ferry steps against the current, unlit, its paper blank. The Choir says a blank lantern belongs to someone nobody was left to remember, and that it comes back to ask.",
		cooldown = 5,
		tags = { "faith", "strange" },
		when = { worldEvent = "lantern_festival", minAge = 8 },
		choices = {
			{ label = "Light it and send it back out", result = { justice = 1, sanity = 4, log = "You lit the blank lantern and pushed it out with your hand. This time it went straight out past the spire, as if it had only needed someone to bother." } },
			{
				label = "Find out whose it was",
				hint = "Temperance clash. The Choir keeps old registers.",
				clash = { stat = "temperance", foe = "Sixty years of water-stained registers", coins = 2, base = 3, coinPower = 2 },
				win = { temperance = 2, sanity = 4, log = "You found her in a Choir register sixty years old: Edda Saltry, net-mender, no family listed. You wrote her name on the paper and let her go." },
				lose = { sanity = -1, log = "The registers were water-stained past reading. You wrote 'someone' on the paper and hoped that counted." },
			},
			{ label = "Leave it for the Choir", result = { prudence = 1, log = "You left the lantern on the step for the Choir. When you looked back it was gone, and nobody had touched it." } },
		},
	},
	{
		id = "wt2_lantern_race",
		title = "The Overflow Race",
		text = "Every Lantern Night, children race little paper boats down the overflow channel, each one carrying a stub of candle. The winner gets a ribbon and the honor of lighting the big lantern at the top of the stairs. Someone has already folded you a boat.",
		cooldown = 2,
		tags = { "faith", "friend" },
		when = { worldEvent = "lantern_festival", minAge = 6, maxAge = 16 },
		choices = {
			{
				label = "Race it",
				hint = "Temperance clash. A good fold floats.",
				clash = { stat = "temperance", foe = "The overflow channel", coins = 1, base = 2, coinPower = 2 },
				win = { temperance = 1, sanity = 4, log = "Your boat shot the last drop with its candle still lit, and you lit the big lantern at the top of the stairs while everyone cheered." },
				lose = { sanity = 1, log = "Your boat tipped over at the first bend. You cheered for the winner anyway, louder than anyone." },
			},
			{ label = "Help the little ones fold theirs", result = { justice = 1, sanity = 3, log = "You spent the race helping the smallest kids fold boats that would float. Three of them finished. One of them won." } },
		},
	},
	{
		id = "wt2_lantern_landing_supper",
		title = "Supper on the Landings",
		text = "On Lantern Night nobody on your stair eats alone. Every door brings a pot out to the landing, and the whole building eats on the steps under strings of paper lanterns. At the end of the row, someone you don't know is sitting with an empty bowl.",
		cooldown = 3,
		tags = { "faith", "friend" },
		when = { worldEvent = "lantern_festival", side = "gutters", minAge = 10 },
		choices = {
			{ label = "Bring a pot to share", hint = "5 scrip.", requires = { min = { money = 5 } }, result = { money = -5, sanity = 4, relationBond = { kind = "all", amount = 3 }, log = "You brought a pot of kelp stew out to the landing. It came back scraped clean and full of compliments." } },
			{ label = "Sit with the stranger", result = { sanity = 3, addRelation = { kind = "friend", bond = 45 }, log = "You shared your bowl with the stranger at the end of the row. {newRelation} had only just moved to {district}, and by the last lantern you were trading stories like old friends." } },
			{ label = "Eat quickly and slip away", result = { sanity = -1, log = "You ate quickly and went in early. The laughing on the landing went on without you." } },
		},
	},

	-- ── the Great Low Tide ──
	{
		id = "wt2_lowtide_schoolroom",
		title = "The Drowned Schoolroom",
		text = "The water has pulled back off a schoolhouse that drowned before your grandparents were born. Slates still sit on the little desks. On the blackboard, under a skin of silt, the last lesson is still chalked up: a map of the old streets, with a thin river running through the place where the Mere is now.",
		once = true,
		tags = { "salvage", "strange" },
		when = { worldEvent = "great_low_tide", minAge = 8 },
		choices = {
			{ label = "Copy the old map", result = { temperance = 2, prudence = 1, log = "You copied the old map onto the back of a tram ticket: streets, squares, and a little river where the Mere should be. You keep it in your coat." } },
			{ label = "Salvage the brass school bell", result = { wage = { 20, 40 }, sanity = -1, log = "You worked the brass bell off its bracket and sold it on the stairs. It felt a little like taking something from a child." } },
			{ label = "Leave the room as you found it", result = { prudence = 1, sanity = 2, log = "You wiped the silt off one slate, set it straight on its desk, and left. The water would be back for it soon enough." } },
		},
	},
	{
		id = "wt2_lowtide_stranded_eel",
		title = "Stranded",
		text = "The water went out too fast, and a silt eel as long as a tram car is stranded in a shrinking pool below the stairs. It is pale, tired and much bigger than anything should be. A crowd is gathering on the steps with hooks and opinions.",
		cooldown = 5,
		tags = { "salvage", "danger" },
		when = { worldEvent = "great_low_tide", minAge = 12 },
		choices = {
			{
				label = "Help roll it back to the water",
				hint = "Fortitude clash. It doesn't know you're helping.",
				clash = { stat = "fortitude", foe = "A stranded silt eel", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 2, sanity = 4, log = "You and six strangers rolled it down the mud on a wet tarp. At the waterline it looked back at you once, and then it was gone." },
				lose = { fortitude = { -7, -3 }, sanity = -2, log = "It thrashed when the tarp went under it, and its tail threw you ten feet into the mud.", cause = "Thrown by a stranded silt eel" },
			},
			{ label = "Keep it wet with buckets", result = { fortitude = -1, sanity = 3, log = "You and the stair kids kept it wet with buckets until the water crept back far enough to float it away." } },
			{ label = "Leave it to the crowd", result = { sanity = -2, log = "You went back up the stairs. By morning the pool was empty, and nobody would say which way it had gone." } },
		},
	},
	{
		id = "wt2_lowtide_footprints",
		title = "Footprints Going Down",
		text = "In the fresh mud below the old tram line there is a single line of bare footprints, walking out toward the deep water. They are small, evenly spaced and in no hurry at all. None of them come back.",
		once = true,
		tags = { "salvage", "strange" },
		when = { worldEvent = "great_low_tide", minAge = 10 },
		choices = {
			{
				label = "Follow them to the waterline",
				hint = "Prudence clash.",
				clash = { stat = "prudence", foe = "The footprints that go down", coins = 2, base = 5, coinPower = 3 },
				win = { prudence = 2, sanity = -2, log = "At the waterline the prints simply stopped. Far out in the deep water, something people-shaped was standing very still. You walked back without hurrying, which was the hardest thing you have ever done." },
				lose = { sanity = -6, condition = "night_terrors", log = "You followed them much farther than you meant to, until the mud was over your knees and the water was whispering. You don't remember turning back, but you must have." },
			},
			{ label = "Rake them over so no child follows", result = { justice = 1, sanity = -1, log = "You raked the prints over with a broken oar, all the way out to the water, so no child would follow them." } },
			{ label = "Go home a different way", result = { sanity = -2, log = "You went home the long way round and didn't look at the mud again until the water came back." } },
		},
	},

	-- ── Fog Week ──
	{
		id = "wt2_fog_guide_ropes",
		title = "The Guide Ropes",
		text = "The Sluice Authority has strung guide ropes down every stair so people can feel their way through the fog. Somebody has been cutting them a few yards at a time, and the coal carts keep rolling off the landings.",
		weight = 20,
		cooldown = 4,
		tags = { "danger", "crime" },
		when = { worldEvent = "fog_week", minAge = 12 },
		choices = {
			{
				label = "Walk the ropes with a lantern and knot the cuts",
				hint = "Justice clash. Whoever is cutting them is still out there.",
				clash = { stat = "justice", foe = "Whoever is cutting the ropes", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 2, sanity = 2, log = "You knotted every cut rope from the top of the stair to the bottom. Near the Silt, a figure with shears bolted into the fog, and the ropes held for the rest of the week." },
				lose = { fortitude = { -6, -2 }, sanity = -2, log = "The rope you were holding went slack in your hands, and you went down six steps in the fog before a landing caught you.", cause = "Fell on the stairs in the fog" },
			},
			{ label = "Lead people up the stairs for a few {currency}", result = { wage = { 8, 20 }, fortitude = -1, log = "You led strangers up the stairs by the hand all week, counting the steps out loud, for whatever they could spare." } },
			{ label = "Stay off the stairs", result = { sanity = -1, log = "You stayed in until the fog lifted. Twice you heard a cart go clattering down the stair, and someone shouting for a rope." } },
		},
	},
	{
		id = "wt2_fog_counting_voice",
		title = "Counting Steps",
		text = "Someone ahead of you in the fog is counting the stairs out loud, the way children do. You have climbed this stair all your life, and you know it has eighty-four steps. The voice has just reached ninety, and it is still going up.",
		weight = 20,
		once = true,
		tags = { "strange" },
		when = { worldEvent = "fog_week", minAge = 8 },
		choices = {
			{
				label = "Count along with them",
				hint = "Prudence clash.",
				clash = { stat = "prudence", foe = "The voice that counts too high", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 2, sanity = 1, log = "You counted along, out loud and firmly, until the voice lost its place and started again at eighty-four with you. At the top, nobody was there. The stair has had eighty-four steps ever since." },
				lose = { sanity = -5, log = "You counted along. Somewhere past a hundred and twenty, you noticed you couldn't hear your own feet any more. You came out of the fog on your own landing hours later, very cold." },
			},
			{ label = "Hold the rail and count your own", result = { prudence = 1, sanity = -1, log = "You held the rail and counted your own steps under your breath. Eighty-four. You checked twice." } },
			{ label = "Call out and ask who it is", result = { sanity = -3, log = "You called out. The counting stopped. Then, very close to your ear, it started again from one." } },
		},
	},

	-- ── the Great Strike ──
	{
		id = "wt2_strike_bucket_chain",
		title = "The Bucket Chain",
		text = "With the pumps silent, the Mere is creeping up the lowest stairs a step a day. The Silt has formed a bucket chain to keep the water out of the stilt-houses, hand to hand, all night long, and there is a gap in the line right where you are standing.",
		weight = 25,
		cooldown = 4,
		tags = { "strike", "danger" },
		when = { worldEvent = "company_strike", side = "gutters", minAge = 12 },
		choices = {
			{
				label = "Take a place in the chain",
				hint = "Fortitude clash. It's a long night.",
				clash = { stat = "fortitude", foe = "The rising water", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 2, sanity = 3, log = "You passed buckets until your arms turned to rope. By dawn the water was a step lower, and the whole chain cheered as if the pumps had started again." },
				lose = { fortitude = { -7, -3 }, sanity = -2, log = "You stood knee-deep in cold water for two nights straight, and came home too tired to climb your own stairs.", cause = "Worn out on the bucket chain" },
			},
			{ label = "Carry the old folk up to a dry landing", result = { fortitude = -1, justice = 1, sanity = 2, log = "You carried old Lowen Hollin and her sewing box up four landings on your back. She told you the whole way that she could perfectly well walk." } },
			{ label = "Move your own things up a floor", result = { prudence = 1, sanity = -1, log = "You carried everything you owned up a floor and slept on top of it, listening to the water lap at the stairs." } },
		},
	},
	{
		id = "wt2_strike_company_notice",
		title = "Triple Pay, No Questions",
		text = "A company man is pasting notices on every tram post: shovel hands wanted at the Pumpworks, triple pay, start tonight, no questions asked. The stokers on the picket line can read them from where they stand.",
		weight = 25,
		cooldown = 5,
		tags = { "strike" },
		when = { worldEvent = "company_strike", minAge = 16, career = { "none", "company", "diver", "sluice", "brine", "choir" } },
		choices = {
			{ label = "Take the shovel", result = { wage = { 30, 60 }, justice = -2, sanity = -3, setFlags = { "broke_the_strike" }, log = "You shoveled coal for the company under guard for three nights. The pay was very good. Nobody on your street would look at you for a month." } },
			{ label = "Tear the notices down", result = { justice = 2, sanity = 1, log = "You tore down every notice from the tram stop to the Pumpworks gate. A stoker on the picket line saluted you with her shovel." } },
			{ label = "Carry a notice down to the picket", result = { prudence = 1, sanity = 2, log = "You brought a notice down to the picket line. The stokers laughed, nailed it to the gate, and gave you a bowl of strike broth." } },
		},
	},
}
