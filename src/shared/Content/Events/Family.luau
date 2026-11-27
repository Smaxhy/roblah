--[[
	Family and relationship events: parents, siblings, children, friends, mentors.
	Threads:
		sibling_choir  fam_sibling_choir -> fam_sibling_vow (3 yrs) -> fam_sibling_return (weighted, 28+)
		took_in_foundling (Life) -> fam_child_trade (scheduled 9 yrs after the child arrives)
]]

return {
	{
		id = "fam_sibling_choir",
		title = "A Sibling Gone Quiet",
		text = "{sibling} has started going down to the ferry steps every evening to sit with the Choir of Still Water. They come home late, damp and calm, and say less every week. Tonight they left supper untouched and asked whether you have ever heard the water answer.",
		once = true,
		tags = { "family", "sibling", "choir", "thread_sibling" },
		when = { minAge = 12, maxAge = 40, hasRelation = "sibling" },
		choices = {
			{
				label = "Go and sit with them",
				result = {
					prudence = 2,
					sanity = 2,
					relationBond = { kind = "sibling", amount = 6 },
					setFlags = { "sibling_choir" },
					schedule = { event = "fam_sibling_vow", inYears = 3 },
					log = "You sat beside {sibling} on the ferry steps and listened to the water with them.",
				},
			},
			{
				label = "Argue them out of it",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Your sibling's calm", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 2, relationBond = { kind = "sibling", amount = 2 }, log = "You argued until {sibling} laughed and promised to come home for supper. Mostly, they did." },
				lose = {
					sanity = -3,
					relationBond = { kind = "sibling", amount = -8 },
					setFlags = { "sibling_choir" },
					schedule = { event = "fam_sibling_vow", inYears = 3 },
					log = "You argued until {sibling} stopped answering at all and went back down to the water.",
				},
			},
			{
				label = "Let them be",
				result = {
					sanity = -1,
					setFlags = { "sibling_choir" },
					schedule = { event = "fam_sibling_vow", inYears = 3 },
					log = "You let {sibling} go down to the water every evening and kept their supper warm.",
				},
			},
		},
	},
	{
		id = "fam_sibling_vow",
		title = "The Vow of Silence",
		text = "{sibling} has taken the Choir's long vow: a year without speaking, sitting by the water from dawn to dusk. They write you notes on scraps of old tide tables. The latest one says only: \"It is very loud down here. Come and listen.\"",
		weight = 0,
		once = true,
		tags = { "family", "sibling", "choir", "thread_sibling" },
		when = { hasRelation = "sibling" },
		choices = {
			{
				label = "Join the Choir yourself",
				hint = "Needs a patient mind.",
				requires = { minAge = 12, career = "none", min = { prudence = 25 } },
				result = { career = "choir", sanity = 3, relationBond = { kind = "sibling", amount = 10 }, log = "You took a seat beside {sibling} on the ferry steps and became a Listener yourself." },
			},
			{
				label = "Write back every week",
				result = { prudence = 1, sanity = 1, relationBond = { kind = "sibling", amount = 8 }, log = "You wrote {sibling} a note every week for a year and kept every one they sent back." },
			},
			{
				label = "Pull them out of there",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The Still Voice", coins = 2, base = 4, coinPower = 3 },
				win = {
					justice = 2,
					relationBond = { kind = "sibling", amount = 4 },
					clearFlags = { "sibling_choir" },
					log = "You argued with the Still Voice until {sibling} was released from the vow, blinking at the light.",
				},
				lose = { sanity = -4, relationBond = { kind = "sibling", amount = -10 }, log = "The Still Voice listened to you shout and said nothing. {sibling} never looked up." },
			},
		},
	},
	{
		id = "fam_sibling_return",
		title = "Back from the Steps",
		text = "{sibling} turns up at your door in grey wool worn thin at the elbows, holding an unlit lantern. They have left the Choir. They don't explain, and you don't ask. They sit down at your table as if no years have passed and ask what's for supper.",
		once = true,
		weight = 10,
		tags = { "family", "sibling", "choir", "thread_sibling" },
		when = { minAge = 28, hasRelation = "sibling", flags = { "sibling_choir" } },
		choices = {
			{
				label = "Make up a bed for them",
				result = {
					money = { -20, -10 },
					sanity = 3,
					relationBond = { kind = "sibling", amount = 12 },
					clearFlags = { "sibling_choir" },
					log = "You made up a bed for {sibling} by the window, the way it used to be.",
				},
			},
			{
				label = "Ask what they heard down there",
				result = {
					prudence = 2,
					sanity = { -4, -2 },
					relationBond = { kind = "sibling", amount = 6 },
					clearFlags = { "sibling_choir" },
					log = "{sibling} told you what the water said. Afterwards, you wished you hadn't asked.",
				},
			},
		},
	},
	{
		id = "fam_pump_lung",
		title = "Pump Lung",
		text = "{mother} has a cough the stitchers call pump lung, from forty years of steam and soot. She laughs it off between fits, makes broth, and won't sit down. The Rim sanatorium has dry air and good beds, and it costs more than you have ever spent on anything.",
		once = true,
		tags = { "family", "mother", "sickness" },
		when = { minAge = 32, hasRelation = "mother", chance = 0.35 },
		choices = {
			{
				label = "Pay for the sanatorium",
				hint = "150 scrip.",
				requires = { min = { money = 150 } },
				result = { money = -150, sanity = 3, relationBond = { kind = "mother", amount = 15 }, log = "You paid for a winter at the Rim sanatorium. {mother} came home breathing easier and furious at the cost." },
			},
			{
				label = "Nurse her at home",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "Pump lung", coins = 2, base = 4, coinPower = 3 },
				win = { fortitude = -2, sanity = 2, relationBond = { kind = "mother", amount = 12 }, log = "You nursed {mother} through the worst winter in years, and by spring she was scolding you again." },
				lose = { sanity = -8, killRelation = "mother", log = "You nursed your mother all winter. She died in her own bed, with the pumps thumping below." },
			},
			{
				label = "Let her carry on her own way",
				result = { sanity = -1, relationBond = { kind = "mother", amount = 4 }, log = "{mother} carried on her own way, coughing and cooking, and told you to stop fussing." },
			},
		},
	},
	{
		id = "fam_father_watch",
		title = "The Old Watch",
		text = "{father} has grown slow on the stairs. He sits you down at his table, takes out a brass watch with a cracked face, and turns it over in his hands for a long while before he speaks. \"Never missed a shift with this,\" he says. \"I want you to have it.\"",
		once = true,
		tags = { "family", "father" },
		when = { minAge = 25, hasRelation = "father" },
		choices = {
			{
				label = "Take the watch",
				result = { prudence = 1, sanity = 3, relationBond = { kind = "father", amount = 10 }, log = "You took {father}'s watch. It ran four minutes slow, exactly like he always had." },
			},
			{
				label = "Tell him to keep it a while",
				result = { sanity = 1, relationBond = { kind = "father", amount = 6 }, log = "You told {father} to keep it a while longer. He looked pleased and put it back in his pocket." },
			},
		},
	},
	{
		id = "fam_child_swim",
		title = "Learning to Swim",
		text = "{child} wants to learn to swim, like every Silt kid and half the Terraces. The water off the public steps is cold and green, and older kids are shrieking and jumping in. {child} stands on the edge in a borrowed swimming shirt, shivering, looking at you.",
		once = true,
		tags = { "family", "child" },
		when = { minAge = 20, hasRelation = "child" },
		choices = {
			{
				label = "Get in with them",
				result = { fortitude = 1, sanity = 3, relationBond = { kind = "child", amount = 8 }, log = "You got into the cold water with {child} and held them up until they could float alone." },
			},
			{
				label = "Coach them from the steps",
				result = { prudence = 1, relationBond = { kind = "child", amount = 4 }, log = "You coached {child} from the steps, and they swam to you, furious and proud." },
			},
			{
				label = "Say it's too dangerous",
				result = { sanity = -1, relationBond = { kind = "child", amount = -5 }, log = "You said no. {child} learned anyway, in secret, from the dock kids." },
			},
		},
	},
	{
		id = "fam_child_trade",
		title = "A Trade of Their Own",
		text = "{child} is old enough to choose a trade and has three offers: an apprenticeship at the Pumpworks, a seat at the Sluice night school, and a cousin on the docks promising easy money on the Brine Kin boats. They want your blessing, and they want it tonight.",
		weight = 0,
		once = true,
		tags = { "family", "child", "thread_foundling" },
		when = { hasRelation = "child" },
		choices = {
			{
				label = "Pay for the night school",
				hint = "60 scrip.",
				requires = { min = { money = 60 } },
				result = { money = -60, sanity = 2, relationBond = { kind = "child", amount = 10 }, log = "You paid {child}'s night school fees and watched them go off with a satchel of tide tables." },
			},
			{
				label = "Bless the Pumpworks",
				result = { sanity = 1, relationBond = { kind = "child", amount = 6 }, log = "You gave {child} your blessing, and they came home every night smelling of soot and pride." },
			},
			{
				label = "Forbid the Brine boats",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "A stubborn child", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 2, relationBond = { kind = "child", amount = 4 }, log = "You talked {child} out of the Brine boats, and years later they thanked you for it." },
				lose = { sanity = -3, relationBond = { kind = "child", amount = -10 }, log = "{child} took the cousin's oar anyway and stopped coming home for supper." },
			},
		},
	},
	{
		id = "fam_friend_moves_up",
		title = "A Friend Moves Up",
		text = "{friend} has saved for years and is finally moving up a tier, to rooms with dry floors and a view of the tram lines. Their whole life fits on one handcart. They have asked you to help push it up the switchbacks, and to promise you will visit.",
		cooldown = 10,
		tags = { "family", "friend" },
		when = { minAge = 20, hasRelation = "friend" },
		choices = {
			{
				label = "Push the cart all the way",
				result = { fortitude = { 1, 2 }, sanity = 2, relationBond = { kind = "friend", amount = 8 }, log = "You pushed {friend}'s handcart up four hundred stairs and ate broth on their new floor." },
			},
			{
				label = "Promise to visit, and mean it",
				result = { prudence = 1, relationBond = { kind = "friend", amount = 5 }, log = "You waved {friend} off at the tram stop and promised to visit. You mostly kept it." },
			},
			{
				label = "Stay home, sore at being left",
				result = { sanity = -2, relationBond = { kind = "friend", amount = -6 }, log = "You stayed home sulking while {friend} pushed the cart up alone." },
			},
		},
	},
	{
		id = "fam_mentor_farewell",
		title = "The Last Lesson",
		text = "{mentor} sends for you on a wet evening. They are smaller than you remember, propped up in bed by the window with a lamp burning low. Their tools are laid out on the blanket, cleaned and oiled. \"Sit,\" they say. \"There's one thing I never taught you.\"",
		once = true,
		weight = 8,
		tags = { "family", "mentor" },
		when = { minAge = 30, hasRelation = "mentor", notFlags = { "guild_mentor" }, chance = 0.4 },
		choices = {
			{
				label = "Sit and listen",
				result = {
					temperance = 3,
					prudence = 3,
					sanity = -4,
					killRelation = "mentor",
					log = "Your mentor taught you one last thing that night, and was gone by morning.",
				},
			},
			{
				label = "Run for a stitcher",
				hint = "30 scrip.",
				requires = { min = { money = 30 } },
				result = { money = -30, relationBond = { kind = "mentor", amount = 6 }, log = "You fetched a stitcher, and {mentor} grumbled at you for one whole extra year." },
			},
		},
	},
}
