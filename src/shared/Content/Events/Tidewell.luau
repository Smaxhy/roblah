--[[
	Tidewell Institute career events (career "warden"). The Institute dredges living
	things out of the Mere (Remnants) and keeps them in sealed vaults under Glasswall,
	where keepers tend them. Ids and flags are prefixed tw_.

	The Remnants, and the one way of tending each that works. Shift scenes always
	offer Feed / Study / Soothe / Restrain in that order, so players can learn them:
		Lullay        Cistern Vault  a tram-long coil of pale fins, calms only to singing    SOOTHE (sing)
		Magpie        Vault Six      tall, polite and lonely, keeps any voice it hears       FEED (old wax-cylinder voices)
		The Surveyor  Map Room       scratches maps of the drowned city into its glass       STUDY (copy the map)
		Kettle        Boiler Vault   a cat-sized knot of temper that boils its own tank      RESTRAIN (clamps + cold sluice)
		Glim          Lamp Room      a small frightened light; the vault freezes as it dims  SOOTHE (hold the jar, talk)
		Umber         Dark Tank      a gentle giant the size of a house; light hurts it      FEED (lamps out, by hand)
		Thimble       Small Vault    grants small wishes, takes something small back        RESTRAIN (keep the lead jar down)
		The Tallyman  Low Vault      taps out numbers: the Mere's levels a week ahead        STUDY (write the count down)
	Rank gates: Lullay, Magpie, Surveyor, Kettle from rank 1; Glim, Umber from 2;
	Thimble, Tallyman from 3. The activities act_tw_extra_shift and act_tw_keepers_book
	(CareerActivities.luau) hint at all eight between them.

	Threads:
		umber   tw_umber_pining (sets tw_umber_bond) -> tw_umber_loose (3 yrs)
		        -> tw_umber_home, or tw_umber_free -> tw_umber_hum (4 yrs, any career)
		ethics  tw_weeping_schedule (sets tw_schedule_copied, adds Noor Saltry) -> tw_whistle (2 yrs)
		        -> tw_whistleblower -> tw_reforms (3 yrs, any career)
	Also: tw_recruit (a job offer to anyone who isn't a keeper), tw_breach_callin (only
	during the breach_tidewell world event; can set contained_a_specimen).
	Elsewhere: act_tw_sit_umber needs tw_umber_bond; cond_keeping_pace (Conductor.luau)
	has a choice for tw_umber_free.
]]

return {
	-- Recruitment ------------------------------------------------------------
	{
		id = "tw_recruit",
		title = "The Institute Is Hiring",
		text = "A notice has gone up at every tram stop in Glasswall: THE TIDEWELL INSTITUTE SEEKS KEEPERS. Steady nerves, a strong stomach, no fear of the dark. Wages paid in full, every month, without fail. At the bottom, in smaller print: Applicants must be able to sing.",
		weight = 3,
		once = true,
		tags = { "career", "recruit", "warden" },
		when = { minAge = 18, maxAge = 40, career = { "none", "company", "stoker", "diver", "sluice", "brine", "choir", "conductor" } },
		choices = {
			{
				label = "Apply at the Glasswall gate",
				hint = "Needs a steady mind. You'd start as a Night Porter.",
				requires = { min = { prudence = 25 } },
				result = { career = "warden", prudence = 1, log = "A keeper in a rubber coat asked you to sing one verse of anything, listened with her eyes shut, and handed you a brass whistle." },
			},
			{
				label = "Ask what the keepers keep",
				result = { prudence = 1, sanity = -1, log = "The keeper at the gate said \"Remnants,\" as if that explained everything. When you asked what a Remnant was, she said it again, more kindly." },
			},
			{
				label = "Walk on by",
				result = { log = "You walked on past the notice. That night you dreamed of something enormous humming in the dark, and woke up oddly sad." },
			},
		},
	},

	-- Shift scenes: one per Remnant -------------------------------------------
	{
		id = "tw_shift_lullay",
		title = "Lullay Won't Settle",
		text = "Lullay is a coil of pale fins longer than a tram car, and tonight it is hurling itself against the glass of the Cistern Vault hard enough to set the gallery lamps swinging. The old keepers say it was dredged out of a drowned chapel in the middle of evensong, and that it has been waiting for the rest of the hymn ever since.",
		weight = 12,
		cooldown = 4,
		tags = { "career", "warden", "remnant" },
		when = { career = "warden" },
		choices = {
			{
				label = "Feed: lower a bucket of eels",
				result = { fortitude = { -3, -1 }, sanity = -2, log = "You lowered the eels. Lullay didn't even look at them. It hit the glass so hard that the bucket flew off its hook, and so did you." },
			},
			{
				label = "Study: time the thrashing",
				result = {
					prudence = 1,
					sanity = { -5, -3 },
					condition = "night_terrors",
					log = "You sat in the gallery with a stopwatch and a notebook while Lullay thrashed until dawn, and wrote down every blow. You can still count them at night, when you'd rather be asleep.",
				},
			},
			{
				label = "Soothe: sing to it",
				result = {
					paycheck = 0.2,
					prudence = { 2, 3 },
					sanity = 3,
					log = "You sang the only hymn you knew, badly, all the way through, and then again. By the third time Lullay had gone into the calm, coiled against the glass beside you with its fins folded like hands.",
				},
			},
			{
				label = "Restrain: drop the chains on it",
				hint = "Fortitude clash, medium-hard.",
				clash = { stat = "fortitude", foe = "Lullay", coins = 2, base = 5, coinPower = 3 },
				win = { prudence = 1, sanity = -3, log = "You winched the chains down over it. Lullay stopped thrashing and lay under the iron, keening, for the rest of your shift. Somehow that was worse." },
				lose = {
					fortitude = { -10, -5 },
					sanity = -2,
					condition = "broken_arm",
					log = "Lullay shrugged the chains off like ribbons, and one of them caught your arm on its way past.",
					cause = "Struck by a chain in the Cistern Vault",
				},
			},
		},
	},
	{
		id = "tw_shift_magpie",
		title = "Magpie Is Calling",
		text = "The thing in Vault Six is tall, soft and very polite. The keepers call it Magpie, because it takes voices the way a magpie takes spoons: speak to it, and it keeps yours for a week. Tonight it is calling through the grille in the voice of a porter who retired years ago. Two doors down, the sound library is shelved floor to ceiling with wax cylinders of old voices nobody needs anymore.",
		weight = 12,
		cooldown = 4,
		tags = { "career", "warden", "remnant" },
		when = { career = "warden" },
		choices = {
			{
				label = "Feed: play it the old wax cylinders",
				result = {
					paycheck = 0.2,
					prudence = { 2, 3 },
					sanity = 2,
					log = "You wheeled the cylinder player up to the grille and fed Magpie old voices all night: a weather report, a lecture on lenses, somebody's grandmother reading out a recipe for kelp bread. By dawn it was murmuring the recipe to itself, contented, in her voice.",
				},
			},
			{
				label = "Study: interview it through the grille",
				result = { prudence = 1, sanity = -5, log = "You asked it three questions. It answered all three in your own voice, and then it kept your voice. For a week you could only whisper, and the night shift kept hearing you call for help from Vault Six." },
			},
			{
				label = "Soothe: sing it something",
				result = { sanity = { -6, -4 }, condition = "night_terrors", log = "You sang it a lullaby. Magpie sang it back to you in your own voice, through every pipe in the vaults, until the morning shift came in." },
			},
			{
				label = "Restrain: slam the iron shutter",
				hint = "Justice clash, medium.",
				clash = { stat = "justice", foe = "Magpie", coins = 2, base = 4, coinPower = 3 },
				win = { prudence = 1, sanity = -2, log = "You got the iron shutter down before it could answer. Behind it, Magpie went very quiet, the way a child goes quiet when it has decided not to forgive you." },
				lose = {
					fortitude = { -4, -1 },
					sanity = { -8, -5 },
					log = "The shutter jammed halfway. Magpie screamed in every voice it had ever kept, all at once, and you ran, and fell twice on the vault stairs.",
					cause = "Fell on the vault stairs",
				},
			},
		},
	},
	{
		id = "tw_shift_surveyor",
		title = "The Surveyor's Map",
		text = "The Surveyor is a many-legged shell-thing the size of a cart wheel, and it spends its nights scratching maps of the drowned city into the inside of its glass with one long claw: streets, stairs, doors nobody has opened in a hundred years. Tonight it keeps stopping to look at you, and then at the blank log book on the keeper's desk.",
		weight = 12,
		cooldown = 4,
		tags = { "career", "warden", "remnant", "study" },
		when = { career = "warden" },
		choices = {
			{
				label = "Feed: tip in a basket of crabs",
				result = { sanity = -3, log = "It ignored the crabs and scratched faster and faster, until a crack ran right across the map it was drawing. Then it glared at you through the crack for the rest of the night." },
			},
			{
				label = "Study: copy the map into the log",
				result = {
					temperance = { 2, 3 },
					prudence = { 1, 2 },
					paycheck = 0.25,
					log = "You copied its map into the log, line for line. The Surveyor watched you finish, wiped the glass clean with its claws and started another. The Lantern Guild paid the Institute handsomely for your copy, and found the drowned street exactly where it said.",
				},
			},
			{
				label = "Soothe: hum to it",
				result = { sanity = { -5, -3 }, log = "You hummed to it. The Surveyor stopped drawing, came right up to the glass in front of your face, and scratched one word into it, slowly and backward, so that you could read it: READ." },
			},
			{
				label = "Restrain: clamp its drawing claw",
				hint = "Fortitude clash, medium.",
				clash = { stat = "fortitude", foe = "The Surveyor", coins = 2, base = 4, coinPower = 3 },
				win = { sanity = -3, log = "You got the clamp on its claw, and it stopped drawing and sulked in the corner of its tank. In the morning the day shift found a new map scratched into the underside of the keeper's desk." },
				lose = {
					fortitude = { -8, -3 },
					sanity = -1,
					condition = "broken_arm",
					log = "It caught the clamp in its claw, and your wrist along with it, and let go only when it was good and ready.",
					cause = "Hurt in the Map Room",
				},
			},
		},
	},
	{
		id = "tw_shift_kettle",
		title = "Kettle Is Boiling",
		text = "Kettle is a furious knot of heat no bigger than a cat. It lives in a riveted iron tank in the Boiler Vault, and it boils its own water whenever it is cross, which is most of the time. Tonight the tank is ticking, the steam valve is shrieking, the lid clamps are hanging open, and the wheel for the cold sluice is right beside your hand.",
		weight = 12,
		cooldown = 4,
		tags = { "career", "warden", "remnant" },
		when = { career = "warden" },
		choices = {
			{
				label = "Feed: shovel in its coal ration",
				result = {
					fortitude = { -6, -2 },
					sanity = -1,
					condition = "burned_hands",
					log = "Kettle took the coal, doubled in heat and boiled over. You got your hands up in time to save your face, and not in time to save your hands.",
					cause = "Scalded in the Boiler Vault",
				},
			},
			{
				label = "Study: open the hatch to read it",
				result = {
					fortitude = { -5, -2 },
					sanity = -2,
					log = "You opened the hatch to read the gauge. Kettle had been waiting for exactly that. The steam took your eyebrows and most of your nerve.",
					cause = "Scalded in the Boiler Vault",
				},
			},
			{
				label = "Soothe: talk to it gently",
				result = { fortitude = { -3, -1 }, sanity = -3, log = "You talked to it gently. Kettle loves attention, and it boiled with delight until the whole vault was fogged and dripping and you were soaked to the skin in hot water." },
			},
			{
				label = "Restrain: clamp it, open the cold sluice",
				hint = "Fortitude clash, medium. The clamps are hot.",
				clash = { stat = "fortitude", foe = "Kettle", coins = 2, base = 4, coinPower = 3 },
				win = {
					paycheck = 0.25,
					prudence = { 2, 3 },
					fortitude = 1,
					log = "You threw the clamps over, spun the cold sluice wide open, and held on while Kettle hissed itself down to a sulky simmer. That is as close to the calm as it ever gets.",
				},
				lose = {
					fortitude = { -6, -2 },
					prudence = 1,
					condition = "burned_hands",
					log = "It was the right idea and the right wheel, but the clamps were too hot to hold for long. Kettle simmered down in the end, and you wore bandages for a season.",
					cause = "Scalded in the Boiler Vault",
				},
			},
		},
	},
	{
		id = "tw_shift_glim",
		title = "Glim Is Dimming",
		text = "Glim is a small, frightened light that lives in a jar of black water in the Lamp Room, and it dims whenever it is scared. When Glim dims, the whole vault grows cold. Somebody on the day shift dropped a tray beside its jar, and tonight it is barely a glow, flinching at every footstep, while frost creeps across the inside of the glass.",
		weight = 12,
		cooldown = 4,
		tags = { "career", "warden", "remnant" },
		when = { career = "warden", minRank = 2 },
		choices = {
			{
				label = "Feed: sprinkle in its krill",
				result = { sanity = -2, log = "You lifted the lid to feed it. Glim flinched from your hand and went out like a pinched candle for a whole minute, and when it came back, it was a little smaller than before." },
			},
			{
				label = "Study: check it under the lamp",
				result = {
					fortitude = { -4, -1 },
					sanity = -4,
					log = "Under the examination lamp, Glim nearly went out. The Lamp Room froze so hard that your breath crackled, and you spent the rest of the shift with your hands in your armpits, apologizing to a jar.",
					cause = "Frozen in the Lamp Room",
				},
			},
			{
				label = "Soothe: hold the jar and talk softly",
				result = {
					paycheck = 0.15,
					prudence = { 2, 3 },
					sanity = 4,
					log = "You held the jar in both hands and told it about the noodle barge, the tram bells and the way the Mere looks at dusk. By morning Glim was glowing like a kitchen window, and the frost was gone.",
				},
			},
			{
				label = "Restrain: pull its hood down",
				result = { sanity = { -6, -4 }, log = "You covered the jar with its hood. Underneath, the glow went out entirely. For an hour the Lamp Room was colder than the bottom of the Mere, and when you lifted the hood, Glim was no bigger than a pinhead." },
			},
		},
	},
	{
		id = "tw_shift_umber",
		title = "Feeding the Dark Tank",
		text = "Umber is a gentle giant the size of a house, soft and grey and shy, and it lives in the Dark Tank, where every lamp is painted black. When it is happy, it hums. When light touches it, it curls up in pain, and anything that hurts it frightens it. Tonight it is nudging its empty feeding trough with its great soft head, over and over, and flinching every time your lamp swings.",
		weight = 12,
		cooldown = 4,
		tags = { "career", "warden", "remnant" },
		when = { career = "warden", minRank = 2, notFlags = { "tw_umber_free" } },
		choices = {
			{
				label = "Feed: lamps out, feed it by hand",
				result = {
					paycheck = 0.2,
					prudence = { 2, 3 },
					sanity = 3,
					log = "You put out every lamp and fed it kelp bales by hand in the pitch dark, one at a time. A vast, soft mouth took each one gently from your arms. By the last bale Umber was humming so deep that the floor buzzed under your boots.",
				},
			},
			{
				label = "Study: shine a lamp to check on it",
				result = {
					fortitude = { -7, -3 },
					sanity = -2,
					condition = "broken_arm",
					log = "The lamplight touched it, and Umber curled up and rolled away from it, and half the tank came over the gallery rail, and you went with it.",
					cause = "Swept off the gallery of the Dark Tank",
				},
			},
			{
				label = "Soothe: sing to it",
				result = { fortitude = { -2, 0 }, sanity = 1, log = "You sang to it. Umber listened politely and hummed along a little, then went back to nudging its empty trough until the walls shook." },
			},
			{
				label = "Restrain: chain it for feeding",
				hint = "Fortitude clash, hard.",
				clash = { stat = "fortitude", foe = "Umber", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = -5, log = "You got the feeding chains on it. Umber didn't fight. It just went still and shook. It ate because it was made to, and it wouldn't come near the glass for a month." },
				lose = {
					fortitude = { -10, -5 },
					sanity = -3,
					condition = "broken_arm",
					log = "Umber panicked at the first touch of the chains, and a frightened giant in a small tank is a terrible thing to be near.",
					cause = "Lost in the Dark Tank",
				},
			},
		},
	},
	{
		id = "tw_shift_thimble",
		title = "Cleaning Thimble's Dish",
		text = "Once a month somebody has to clean Thimble's brass dish, and tonight it's you. Thimble is a glimmer no bigger than your thumb that lives under a lead jar in the Small Vault. Lift the jar and it grants small wishes, then takes something small back, and it decides what small means. It is already chiming under the lead, hopefully, as you come in.",
		weight = 12,
		cooldown = 4,
		tags = { "career", "warden", "remnant" },
		when = { career = "warden", minRank = 3 },
		choices = {
			{
				label = "Feed: lift the jar, give it a crumb",
				result = { loseGear = true, sanity = -3, log = "Thimble ate the crumb, thanked you, and took something small in return. You're still not sure what. Some mornings you reach for a thing that isn't there anymore." },
			},
			{
				label = "Study: measure it, wanting nothing",
				hint = "Prudence clash, hard. Don't want anything.",
				clash = { stat = "prudence", foe = "Thimble", coins = 3, base = 6, coinPower = 3 },
				win = { prudence = 2, sanity = -1, log = "You lifted the jar and measured it to the hair, and didn't want a single thing the whole time. Thimble seemed almost impressed. You lowered the jar and backed out, sweating." },
				lose = { sanity = { -6, -3 }, log = "Halfway through, you caught yourself wishing the shift were over. Thimble granted it. You woke on the stairs outside at dawn with no memory of the night and your boots on the wrong feet." },
			},
			{
				label = "Soothe: chat with it while you work",
				result = { sanity = -4, log = "You chatted with it while you worked, and somewhere in the chatter Thimble heard a wish. It granted it, and took the color of your front door. You've walked straight past your own house twice since." },
			},
			{
				label = "Restrain: clean it through the hatch",
				result = {
					paycheck = 0.25,
					prudence = { 2, 3 },
					sanity = 1,
					log = "You cleaned the dish through the lead hatch with long tongs, never lifting the jar a hair and never saying a word. Thimble sulked under the lead, chiming like a spoon in a cup.",
				},
			},
		},
	},
	{
		id = "tw_shift_tallyman",
		title = "The Tallyman's Count",
		text = "The Tallyman has no eyes and a great many fingers, and every night it taps numbers on the glass of the Low Vault, row after row, never missing a beat. Each time it finishes a row, it turns its smooth head toward the tally book on the keeper's desk and waits. Nobody has written in the book for a week, and the tapping is getting louder.",
		weight = 12,
		cooldown = 4,
		tags = { "career", "warden", "remnant", "study" },
		when = { career = "warden", minRank = 3 },
		choices = {
			{
				label = "Feed: lower its fish through the hatch",
				result = { sanity = -3, log = "It stopped to eat, lost count, and started again from the very beginning, twice as fast and twice as loud. You heard the tapping in the pipes for the rest of the shift, and in your bunk after." },
			},
			{
				label = "Study: write down the count",
				result = {
					temperance = { 2, 3 },
					prudence = { 1, 2 },
					paycheck = 0.3,
					log = "You wrote down every number it tapped until your hand cramped. They were the Mere's water levels a week ahead, to the inch. The Sluice Authority bought the book, and the Governors started saying your name in meetings.",
				},
			},
			{
				label = "Soothe: tell it it has done enough",
				result = {
					sanity = { -5, -3 },
					condition = "night_terrors",
					log = "It didn't want comfort. It wanted a witness. It came right up to the glass in front of your face and tapped out a row there, very slowly, and you kept hearing that row in your sleep for months.",
				},
			},
			{
				label = "Restrain: muffle the glass with felt",
				hint = "Prudence clash, medium-hard.",
				clash = { stat = "prudence", foe = "The Tallyman", coins = 2, base = 5, coinPower = 3 },
				win = { sanity = -2, log = "You hung the felt and held your nerve while it tapped through it. In the end it stopped and sat very still, and you had the strong feeling it had started counting something else." },
				lose = { sanity = { -7, -4 }, log = "Under the felt, the tapping moved into the walls, then the pipes, then the frame of your bunk. It found its way out of the felt in an hour. It took a great deal longer to find its way out of your head." },
			},
		},
	},

	-- Deeper in the vaults ------------------------------------------------------
	{
		id = "tw_lullay_storm",
		title = "The Glass Is Singing",
		text = "A storm on the Mere is pushing water up the Cistern Vault's old intake, and Lullay is thrashing so hard that the glass rings like a struck bell. A crack as fine as a hair is climbing toward the ceiling. The night shift is looking at you. Somebody has to sing, and keep singing, while the glass shakes.",
		cooldown = 6,
		tags = { "career", "warden", "remnant" },
		when = { career = "warden", minRank = 3 },
		choices = {
			{
				label = "Soothe: sing it through the storm",
				hint = "Prudence clash, medium-hard. Keep your voice steady.",
				clash = { stat = "prudence", foe = "The storm in the Cistern Vault", coins = 2, base = 5, coinPower = 3 },
				win = {
					promote = true,
					prudence = { 2, 3 },
					sanity = 4,
					log = "You sang the same three verses for four hours while the glass shook, and never once let your voice crack. Lullay went into the calm against the glass beside you, and the crack stopped climbing a finger's width from the top.",
				},
				lose = {
					sanity = { -7, -4 },
					condition = "night_terrors",
					log = "Your voice gave out before the storm did. Lullay thrashed until dawn, and the crack reached the ceiling and stopped there, quivering. You still hear the glass ringing at night.",
				},
			},
			{
				label = "Soothe: get the whole shift singing",
				result = {
					justice = { 1, 2 },
					paycheck = 0.15,
					sanity = 3,
					log = "You lined every keeper on the shift up along the gallery rail, and you sang together, terribly, until the storm blew itself out. Lullay settled before the second verse. It seems to like a crowd.",
				},
			},
			{
				label = "Restrain: drop the storm chains",
				hint = "Fortitude clash, hard.",
				clash = { stat = "fortitude", foe = "Lullay in a storm", coins = 3, base = 6, coinPower = 3 },
				win = { sanity = -4, log = "The storm chains held, and Lullay lay coiled under them all night without a sound. It didn't eat for a month, and it wouldn't let anyone sing to it for two." },
				lose = {
					fortitude = { -12, -6 },
					sanity = -3,
					condition = "broken_arm",
					log = "Lullay threw off the storm chains like a skipping rope, and the glass gave at a seam. You came to on the flooded gallery stairs with an arm that wouldn't work.",
					cause = "Drowned in the Cistern Vault",
				},
			},
			{
				label = "Seal the vault and wait it out",
				result = { prudence = 1, sanity = -3, log = "You sealed the vault and listened from the corridor with your hand flat on the door. At dawn the storm passed, and so did the thrashing, and the crack stopped a finger's width from the top." },
			},
		},
	},
	{
		id = "tw_thimble_wish",
		title = "Something Small",
		text = "It has been a long year, and Thimble knows it. As you pass the Small Vault on your rounds, the lead jar is standing beside its dish instead of on it, and a voice like a pin dropped on glass offers to make one small thing better. Only something small. It is always very fair about what it takes back.",
		cooldown = 8,
		tags = { "career", "warden", "remnant" },
		when = { career = "warden", minRank = 3 },
		choices = {
			{
				label = "Wish for a little money",
				result = {
					money = { 120, 220 },
					sanity = -4,
					relationBond = { kind = "family", amount = -8 },
					log = "In the morning there was a neat stack of clean notes on your pillow. It was weeks before you noticed you could no longer remember the tune your family used to hum on the stairs.",
				},
			},
			{
				label = "Wish an old hurt away",
				hint = "Only if something ails you.",
				requires = { hasCondition = { "broken_arm", "burned_hands", "night_terrors", "fog_lung", "salt_cough" } },
				result = { cure = "any", loseGear = true, sanity = -2, log = "By morning the hurt was gone as if it had never been. So was something you carried every day, though it took you a while to work out what. Thimble is always very fair." },
			},
			{
				label = "Wish for nothing at all",
				hint = "Prudence clash, hard. You have to mean it.",
				clash = { stat = "prudence", foe = "Thimble", coins = 3, base = 6, coinPower = 3 },
				win = { prudence = { 3, 4 }, sanity = 4, log = "You wished for nothing, and meant it. Thimble thought about that for a long time, then laughed like a pin falling on glass. It gave you nothing and took nothing, and you walked home feeling you had won something anyway." },
				lose = { sanity = { -7, -4 }, log = "You wished for nothing, but somewhere at the back of your mind you wished you had wished for something. Thimble heard. It took the smell of rain, and you haven't smelled it since." },
			},
			{
				label = "Restrain: set the jar back on",
				result = { prudence = { 2, 3 }, paycheck = 0.15, log = "You set the lead jar back on its dish without a word and ran a bead of wax around the rim. Under the lead, Thimble chimed once, disappointed, and you wrote up the day shift." },
			},
		},
	},
	{
		id = "tw_breach_callin",
		title = "All Keepers Below",
		text = "The breach sirens are howling over Glasswall, and every keeper has been called in. Something from the lower vaults is out in the Wards, and down here every Remnant can feel it: Lullay is thrashing, Kettle is boiling, Magpie is calling in a hundred voices at once. The duty officer hands out whistles and asks who knows the vaults well enough to walk them alone.",
		cooldown = 2,
		tags = { "career", "warden", "breach" },
		when = { career = "warden", worldEvent = "breach_tidewell" },
		choices = {
			{
				label = "Walk the vaults and settle each one",
				hint = "Prudence clash, medium-hard. You'll need to know them all.",
				clash = { stat = "prudence", foe = "Every vault at once", coins = 2, base = 5, coinPower = 3 },
				win = {
					promote = true,
					paycheck = 0.3,
					prudence = { 2, 3 },
					sanity = 2,
					log = "You went vault to vault with your whistle in your teeth: a song for Lullay, old voices for Magpie, the cold sluice for Kettle, a kind word for Glim. By dawn the vaults were quiet, and the Governors knew your name.",
				},
				lose = {
					sanity = { -8, -5 },
					condition = "night_terrors",
					log = "You mixed them up in the dark. You sang where you should have fed and lit a lamp where you should have sung, and the vaults screamed at you until the sirens stopped.",
				},
			},
			{
				label = "Join the net crews in the streets",
				hint = "Justice clash, hard.",
				clash = { stat = "justice", foe = "The thing loose in the Wards", coins = 3, base = 6, coinPower = 3 },
				win = {
					paycheck = 0.4,
					justice = { 2, 3 },
					setFlags = { "contained_a_specimen" },
					log = "You went up with the net crews, walked it down into a sluice channel with lamps and whistles, and held the light on it until the nets came down. It went into the tank hissing like a kettle.",
				},
				lose = {
					fortitude = { -12, -6 },
					sanity = -4,
					condition = "night_terrors",
					log = "It was waiting at the top of the vault stairs, taller than the lamps, wearing your face a little wrong. You don't remember the rest of the night.",
					cause = "Taken during the Tidewell breach",
				},
			},
			{
				label = "Hold the great doors",
				result = { paycheck = 0.2, fortitude = { -2, 0 }, sanity = -3, log = "You stood at the great vault doors with a lamp and a whistle until the sirens stopped. Nothing came. Twice, something knocked." },
			},
			{
				label = "Get the Gutter families out",
				result = { justice = { 2, 3 }, sanity = 2, log = "You took off your rubber coat so nobody would stop you with questions, and spent the night knocking on Gutter doors and walking families up to the evacuation trams." },
			},
		},
	},

	-- Thread: Umber gets loose ---------------------------------------------------
	{
		id = "tw_umber_pining",
		title = "Umber Won't Eat",
		text = "Old Garrow Hollin kept the Dark Tank for thirty years, and the week he retired, Umber stopped eating. The great soft shape lies at the bottom of the tank and doesn't hum. The vault doctor wants to light the examination lamps and find out what's wrong. In the keepers' book, the only line about Umber is underlined twice: never a lamp.",
		weight = 12,
		once = true,
		tags = { "career", "warden", "remnant", "thread_umber" },
		when = { career = "warden", minRank = 2, notFlags = { "tw_umber_bond", "tw_umber_free" } },
		choices = {
			{
				label = "Feed: sit in the dark, feed it by hand",
				result = {
					prudence = { 2, 3 },
					sanity = 3,
					setFlags = { "tw_umber_bond" },
					schedule = { event = "tw_umber_loose", inYears = 3 },
					log = "You sat in the pitch dark of the gallery every night for a month with a kelp bale in your lap. On the twenty-ninth night a vast, soft mouth took it from your hands, very gently, and Umber hummed until the floor buzzed. Now it hums whenever you come in.",
				},
			},
			{
				label = "Study: let the doctor light the lamps",
				result = { justice = -1, sanity = -4, log = "The doctor lit the lamps. Umber curled into a ball at the bottom of the tank and shook until they went out again. The doctor wrote 'inconclusive' and went home." },
			},
			{
				label = "Soothe: sing to it",
				result = { sanity = 1, log = "You sang to it for an hour. Umber listened politely, and still didn't eat. In the end the Dark Tank was given to a new keeper, and Umber ate for her, eventually." },
			},
			{
				label = "Restrain: harness it for the doctor",
				result = { justice = -1, sanity = -4, log = "It took six keepers and the feeding harness. Umber ate, because it was made to, and it wouldn't come near the glass for a year." },
			},
		},
	},
	{
		id = "tw_umber_loose",
		title = "Umber Is Out",
		text = "The pumps under Glasswall failed last night, and the Dark Tank's old drain stood open for an hour. Umber is gone, out into the drowned aqueducts beneath the Ward. The Institute has sent hunters down with arc lamps and nets. You know what light does to it. You also know it has only ever come, in the dark, to one person.",
		weight = 0,
		once = true,
		tags = { "career", "warden", "remnant", "thread_umber" },
		when = { career = "warden", flags = { "tw_umber_bond" } },
		choices = {
			{
				label = "Go down in the dark with a kelp bale",
				hint = "Prudence clash, hard. No lamps.",
				clash = { stat = "prudence", foe = "The drowned aqueducts", coins = 3, base = 6, coinPower = 3 },
				win = {
					promote = true,
					prudence = { 2, 3 },
					sanity = 5,
					setFlags = { "tw_umber_home" },
					log = "You found it in the black water under the Glaziers' Hall, curled up and shaking. You hummed, and Umber hummed back, and followed you home through the dark like an enormous soft dog. The Governors never asked how.",
				},
				lose = {
					fortitude = { -8, -3 },
					sanity = -8,
					condition = "grief",
					clearFlags = { "tw_umber_bond" },
					log = "You searched the aqueducts until your legs gave out. The hunters found Umber first, under the arc lamps. It came home, but it doesn't hum anymore, not even for you.",
					cause = "Lost in the aqueducts under Glasswall",
				},
			},
			{
				label = "Open the old sluice to the Mere",
				result = {
					justice = 3,
					sanity = 4,
					money = { -40, -20 },
					clearFlags = { "tw_umber_bond" },
					setFlags = { "tw_umber_free" },
					schedule = { event = "tw_umber_hum", inYears = 4 },
					log = "You opened the old sluice at the bottom of the aqueduct and stood aside in the dark. Something enormous slid past you, close enough to touch, humming. The Institute docked the whole shift's pay for the lost specimen, and never found out who opened the gate.",
				},
			},
			{
				label = "Lead the hunters to it",
				result = {
					paycheck = 0.3,
					promote = true,
					justice = -3,
					sanity = -8,
					condition = "grief",
					clearFlags = { "tw_umber_bond" },
					log = "You led the hunters straight to it. Umber came home blinking and shaking under the arc lamps, and it never hummed for you again. The Governors were very pleased with you.",
				},
			},
			{
				label = "Stay at your post",
				result = { sanity = -4, log = "You stayed at your post and listened to the hunters' whistles echo in the pipes all night. They brought Umber back at dawn, shaking. The next night it hummed when you came in, as if it had decided to forgive you." },
			},
		},
	},
	{
		id = "tw_umber_hum",
		title = "A Hum Under the Pier",
		text = "Years after the night the old sluice opened, you are standing at the end of a pier at dusk when the boards start to buzz under your boots. It is a hum, deep and slow and enormous, rising out of the dark water. You would know that hum anywhere.",
		weight = 0,
		once = true,
		tags = { "warden", "remnant", "thread_umber" },
		when = { flags = { "tw_umber_free" } },
		choices = {
			{
				label = "Hum back",
				result = {
					prudence = 2,
					sanity = 6,
					gear = "lantern_token",
					log = "You hummed back. A great soft shape rose just under the surface, darker than the water, and when it sank away, something warm had been left on the bottom step: an old brass lantern token, polished smooth as a pebble. Then the hum moved off toward the middle of the Mere.",
				},
			},
			{
				label = "Light your lamp to see it",
				result = { sanity = -3, log = "You lit your lamp. The hum stopped at once, and the water went flat and empty. You stood there a long time with the lamp in your hand, knowing exactly what you'd done." },
			},
		},
	},

	-- Thread: the weeping schedule ----------------------------------------------
	{
		id = "tw_weeping_schedule",
		title = "The Weeping Schedule",
		text = "Noor Saltry, who keeps the vault next to yours, shows you a ledger from the Governors' office that no keeper was ever meant to see. It is a schedule. Some nights say 'no song' beside Lullay's name, or 'hood down' beside Glim's. Beside each mark is a weight in grains: the tears the Remnants weep when they are frightened, gathered in brass dishes and sold to the Glaziers' Charter for the finest lenses in the city.",
		weight = 12,
		once = true,
		tags = { "career", "warden", "thread_ethics" },
		when = { career = "warden", minRank = 2, notFlags = { "tw_schedule_copied", "tw_whistleblower" } },
		choices = {
			{
				label = "Copy it with Noor",
				result = {
					justice = 2,
					sanity = -1,
					setFlags = { "tw_schedule_copied" },
					addRelation = { kind = "friend", name = "Noor Saltry", bond = 55, age = { 24, 34 } },
					schedule = { event = "tw_whistle", inYears = 2 },
					log = "You and {newRelation} copied the schedule by a shaded lamp, page after page, and walked out past the night clerk with it folded inside your boots.",
				},
			},
			{
				label = "Quietly ignore it on your shifts",
				hint = "Prudence clash, medium.",
				clash = { stat = "prudence", foe = "The Governors' clerks", coins = 2, base = 4, coinPower = 3 },
				win = { justice = 3, sanity = 3, log = "On your shifts the songs went on and the hoods stayed up. Your vaults gave the fewest tears in the Institute, and you blamed the weather so convincingly that the clerks started blaming it too." },
				lose = { money = { -40, -20 }, justice = 2, sanity = -2, log = "On your shifts the songs went on and the hoods stayed up. Your vaults gave the fewest tears in the Institute, and the clerks docked your pay until they gave more." },
			},
			{
				label = "Follow the schedule",
				result = { paycheck = 0.3, justice = -3, sanity = -5, log = "You followed the schedule. On the 'no song' nights you stood outside the Cistern Vault with your hands in your pockets, listening to Lullay thrash, and the brass dishes filled." },
			},
			{
				label = "Ask the Governors about it",
				result = { prudence = 1, sanity = -2, log = "A Governor's secretary closed the ledger gently and explained that the tears paid for the vaults, the lamps and your wages. \"Everybody does a little,\" she said. \"You'll see.\"" },
			},
		},
	},
	{
		id = "tw_whistle",
		title = "One Name or Two",
		text = "Two years after you copied the weeping schedule, Noor Saltry finds you in the locker room with a printer's proof in her hand. The Glasswall Morning Sheet will run the whole schedule on its front page, if keepers will put their names to it. \"One name is a rumor,\" Noor says. \"Two names are the news.\"",
		weight = 0,
		once = true,
		tags = { "career", "warden", "thread_ethics" },
		when = { career = "warden", flags = { "tw_schedule_copied" } },
		choices = {
			{
				label = "Put your name to it",
				result = {
					quitCareer = true,
					justice = { 5, 6 },
					sanity = 4,
					clearFlags = { "tw_schedule_copied" },
					setFlags = { "tw_whistleblower" },
					schedule = { event = "tw_reforms", inYears = 3 },
					log = "Your name and Noor's ran on the front of the Morning Sheet, under the whole schedule. The Glaziers cancelled their contract by noon, the Institute dismissed you both by evening, and that night half of Glasswall stood outside the Institute's gates with lanterns.",
				},
			},
			{
				label = "Take it to the Governors yourself",
				hint = "Prudence clash, hard.",
				clash = { stat = "prudence", foe = "The Governors", coins = 3, base = 6, coinPower = 3 },
				win = {
					promote = true,
					justice = 3,
					sanity = 3,
					clearFlags = { "tw_schedule_copied" },
					log = "You laid the schedule on the Governors' long table and stood there until they had read every page. They cancelled it quietly, and made you the one to see it done.",
				},
				lose = {
					quitCareer = true,
					sanity = -6,
					clearFlags = { "tw_schedule_copied" },
					log = "The Governors thanked you, kept the schedule, and had you walked out through the Glasswall gate with your locker in a box. The brass dishes are still filling.",
				},
			},
			{
				label = "Burn your copy, keep your post",
				result = { prudence = 1, sanity = -5, clearFlags = { "tw_schedule_copied" }, log = "You burned your copy in the locker room stove. Noor watched you do it, and didn't speak to you again." },
			},
			{
				label = "Give the Governors Noor's name",
				result = {
					paycheck = 0.3,
					promote = true,
					justice = -5,
					sanity = -7,
					clearFlags = { "tw_schedule_copied" },
					log = "You gave the Governors Noor's name. She was dismissed by morning, and by spring you had been promoted. You keep the schedule now.",
				},
			},
		},
	},
	{
		id = "tw_reforms",
		title = "A Letter from Glasswall",
		text = "A letter finds you three years after the Morning Sheet ran your name. It is from a Night Porter you have never met. The Institute has a new rule painted over every vault door, she writes: a song for Lullay every night, a kind word for Glim, and no brass dishes anywhere. \"They say a keeper wrote it,\" she finishes. \"I wanted you to know we keep it.\"",
		weight = 0,
		once = true,
		tags = { "warden", "thread_ethics" },
		when = { flags = { "tw_whistleblower" } },
		result = { justice = 2, prudence = 2, sanity = 6, log = "You read the letter twice on the stairs, then sat there with it in your lap for a long while." },
	},
}
