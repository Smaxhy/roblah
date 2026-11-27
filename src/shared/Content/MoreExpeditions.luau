--[[
	More expeditions, merged into pack.expeditions by init.luau.
	Same format as Content/Expeditions.luau: { order = { ids... }, [id] = def }.

	Missions: guild_lantern_road (Lantern Guild), kin_gull_steps_run (Brine Kin),
	sluice_overflow_survey (Sluice Authority), hempen_high_cable (the Hempen Company).
	Dungeons: drowned_cathedral, foundry_undercroft, wreck_company_vault (crew of 2+).
	Trips on the Undertow Line: undertow_rim_gardens, undertow_glass_lighthouse,
	undertow_kelp_islands.

	The two faction missions use when.career = { faction, "none" }: members and free
	hands only, never a rival's badge. Stricter gates (one career, one Ward, a form,
	a flag, a piece of gear) sit on routes inside the runs, through `requires`.
	Reads flags: rang_the_lost_bell (lost_bell), waved_in_the_undertow (undertow_saltflats).
	Sets flags: worked_for_brine, brine_grudge, sluice_marked (existing threads), plus
	carried_a_lantern_home, warned_the_culvert, kept_the_culvert_off_the_map,
	sat_with_the_congregation, played_the_drowned_organ, walked_the_drowned_nave,
	freed_the_kin_cousins, beat_the_paymaster, cracked_the_wreck_vault,
	finished_the_stone_pear, kept_the_glass_light, touched_a_grazer.
]]

return {
	order = {
		"guild_lantern_road",
		"kin_gull_steps_run",
		"sluice_overflow_survey",
		"hempen_high_cable",
		"drowned_cathedral",
		"foundry_undercroft",
		"wreck_company_vault",
		"undertow_rim_gardens",
		"undertow_glass_lighthouse",
		"undertow_kelp_islands",
	},

	-- ── a mission for the Lantern Guild ──
	guild_lantern_road = {
		name = "The Lantern Road",
		desc = "Every guide lantern along drowned Chandlers' Row went dark last night, and three Guild divers are stuck past them in the old Mint. The Lantern Guild sends its own lanterns and free hands only: no Kin, no company badges.",
		kind = "mission",
		minAge = 16,
		cooldown = 2,
		crew = { min = 1, max = 4 },
		length = 5,
		when = { career = { "diver", "none" } },
		start = "pier",
		stages = {
			pier = {
				title = "The Guild Pier",
				text = "The Lantern-Captain meets you at the end of the Guild pier with a crate of lamp oil and a coil of new rope. Every guide lantern between here and the old Mint went out in the night, and three Guild divers are still down there. Their ropes are tied off at the rail, and every so often, they twitch.",
				choices = {
					{ label = "Follow the guide rope down", next = "row", result = { fortitude = { -2, 0 }, log = "Hand over hand, {crew} went down the guide rope into water as cold as a key." } },
					{ label = "Take the lamp sled through the tram cut", hint = "Guild divers only.", requires = { career = "diver" }, next = "tramcut", result = { log = "The Guild boathouse let {crew} sign out the lamp sled, a brass fish with a lantern in its nose, and you steered it into the old tram cut." } },
				},
			},
			row = {
				title = "Chandlers' Row",
				text = "The guide lanterns still hang from their iron hooks above the drowned shopfronts, glass clean, wicks gone. Not burned: gone, as if something drank them. Far down the street, past the chandler's sign, a faint gold light flickers in the high windows of the Mint.",
				choices = {
					{ label = "Relight the lanterns one by one", hint = "Temperance clash.", clash = { stat = "temperance", foe = "Wet wicks and cold hands", coins = 2, base = 4, coinPower = 3 }, winNext = "mint", loseNext = "dark", win = { log = "{champion} trimmed and relit every lantern on the Row, and the drowned street glowed gold behind {crew}." }, lose = { sanity = -2, log = "The third lantern hissed out in {champion}'s hands. Up ahead, in the dark, something turned toward {crew}." } },
					{ label = "Swim the Row in the dark", hint = "Needs nerve.", requires = { min = { prudence = 40 } }, next = "mint", result = { sanity = -3, log = "Counting doorways by touch, {crew} swam the whole Row without a light: once for left, twice for down, three times for still." } },
					{ label = "Climb back up the rope", ["end"] = "retreat", result = { sanity = -2, log = "In the end, {crew} climbed back up into the grey morning. On the pier, the ropes kept twitching." } },
				},
			},
			tramcut = {
				title = "The Old Tram Cut",
				text = "The sled's lantern throws a long gold cone down the drowned tram tunnel. Tram cars sit on the rails with their doors open, route boards still reading CHANDLERS' ROW. The current pulls toward the Mint like a held breath.",
				choices = {
					{ label = "Open the throttle and ride the current", next = "mint", result = { sanity = 2, log = "The current carried {crew} straight down the tram cut, past a hundred empty seats, and out under the Mint's windows." } },
					{ label = "Search the tram cars on the way", hint = "Slow lights get noticed.", next = "dark", result = { wage = { 15, 35 }, log = "Car by car, {crew} filled a net bag with brass fare tokens and a conductor's silver whistle. It took longer than it should have." } },
				},
			},
			dark = {
				title = "Where the Light Goes",
				text = "They come up out of the drowned doorways like pale ribbons, dozens of them, and fold themselves around your lantern. The flame shrinks to a bead. The water goes black, then blacker, and something soft brushes the back of your neck.",
				tone = "danger",
				choices = {
					{ label = "Shield the flame and swim for the Mint", hint = "Justice clash, hard.", clash = { stat = "justice", foe = "The lamp-eaters", coins = 3, base = 6, coinPower = 3 }, winNext = "mint", loseEnd = "fail", win = { sanity = -2, log = "{champion} wrapped the lantern in a coat and swam for the gold windows, with the lamp-eaters streaming behind like torn sails." }, lose = { fortitude = { -10, -4 }, sanity = -5, condition = "night_terrors", log = "The last light went out. Hours later, {crew} found the guide rope by touch and came up shaking.", cause = "Lost in the dark under Chandlers' Row" } },
					{ label = "Cover your lamps and let them pass", hint = "Needs a steady nerve.", requires = { min = { prudence = 45 } }, next = "mint", result = { sanity = -4, log = "Every lamp covered, {crew} hung still in the black water while the lamp-eaters drifted past, close enough to touch. Then they were gone." } },
					{ label = "Cut loose and kick for the surface", ["end"] = "retreat", result = { fortitude = { -4, -1 }, log = "Lungs burning, {crew} cut the line and kicked for the surface. The Guild would have to send someone else." } },
				},
			},
			mint = {
				title = "The Old Mint",
				text = "The Mint's bronze doors stand half open, and under its vaulted ceiling a single guide lantern still burns in a pocket of trapped air. Three Guild divers sit on a counting table above the water, blue-lipped and grinning. All around them, old Mint silver lies on the drowned floor in drifts.",
				choices = {
					{ label = "Rope all three together and bring them up", result = { sanity = 3, log = "Roped together, the three divers followed {crew} back up the Row, one lantern at a time." } },
					{ label = "Carry the diver with the broken leg", hint = "Needs a strong back.", requires = { min = { fortitude = 50 } }, result = { fortitude = { -3, -1 }, justice = { 1, 2 }, setFlags = { "carried_a_lantern_home" }, log = "All the way up the Row, {crew} carried the diver with the broken leg, and the whole Guild pier went quiet to watch you come in." } },
					{ label = "Fill a sack with Mint silver first", hint = "Fortitude clash. The ceiling is groaning.", clash = { stat = "fortitude", foe = "The settling ceiling", coins = 2, base = 5, coinPower = 3 }, winEnd = "success", loseEnd = "fail", win = { wage = { 40, 90 }, log = "{champion} hauled a sack of old Mint silver up behind the divers. The Guild pretended not to see." }, lose = { fortitude = { -8, -3 }, log = "The ceiling came down in a slow grey cloud. Everyone got out, but the Guild does not pay crews who stop to fill their pockets, and {crew} came home with nothing.", cause = "Caught under the Mint ceiling" } },
				},
			},
		},
		success = { wage = { 70, 130 }, sanity = 2, log = "On the pier, the Lantern-Captain paid you and said the old words: a lantern goes down, a lantern comes up." },
		fail = { sanity = -3, log = "Another crew brought the divers home. On the Guild pier, nobody says your name." },
		retreat = { sanity = -1, log = "You came up with dry pockets and a heavy feeling that wouldn't wash off." },
	},

	-- ── a mission for the Brine Kin ──
	kin_gull_steps_run = {
		name = "A Heart for Gull Steps",
		desc = "The pumps on Gull Steps are failing, and the Sluice Authority keeps losing the repair order. The Brine Kin have a brass pump heart, bought off a Boilermakers' yard with no questions asked, and it needs rowing across the Mere tonight. The Kin don't hire anyone who wears a badge.",
		kind = "mission",
		minAge = 14,
		cooldown = 2,
		crew = { min = 1, max = 4 },
		length = 5,
		when = { career = { "brine", "none" } },
		start = "boathouse",
		stages = {
			boathouse = {
				title = "The Kin Boathouse",
				text = "A Kin cousin in a patched coat pulls the sailcloth off the cargo: a brass pump heart, heavy as a sack of coal, its Boilermakers' stamps filed smooth. 'Gull Steps floods at the next High Water without this,' she says. 'The Sluice calls it contraband. The Silt calls it a miracle. We call it a debt.'",
				choices = {
					{ label = "Take the long way, under the viaduct", next = "viaduct", result = { log = "Oarlocks wrapped in rags, {crew} pushed off into the fog toward the viaduct's black arches." } },
					{ label = "Cut straight across the open Mere", hint = "Faster, but the patrol boats sweep open water.", next = "open_water", result = { log = "With the pump heart under a tarp, {crew} rowed straight out onto the open Mere." } },
					{ label = "Take the cousins' way through the old Exchange", hint = "Kin only.", requires = { career = "brine" }, next = "exchange", result = { log = "A whispered password at the water gate, and {crew} slid the boat into the dark mouth of the drowned Exchange." } },
				},
			},
			viaduct = {
				title = "Under the Viaduct",
				text = "The viaduct's arches are full of fog and hanging weed, and every sound comes back to you twice. In the next arch a green lantern swings: a Brackwater boat, lying right across your way. Their oarsman grins and holds out an open hand. 'Toll's gone up, cousin.'",
				choices = {
					{ label = "Race them through the arches", hint = "Fortitude clash.", clash = { stat = "fortitude", foe = "The Brackwater oarsmen", coins = 2, base = 5, coinPower = 3 }, winNext = "gull_steps", loseNext = "open_water", win = { log = "{champion} pulled so hard that the Brackwater boat was left spinning in the fog behind {crew}." }, lose = { fortitude = { -4, -1 }, log = "The Brackwater boat shouldered {crew} out of the arches and onto the open Mere, right where the patrols sweep." } },
					{ label = "Pay the toll", hint = "40 scrip.", requires = { min = { money = 40 } }, next = "gull_steps", result = { money = -40, log = "The Brackwater oarsman held each note up to the green lantern, laughed, and let {crew} through." } },
					{ label = "Wait them out in the fog", hint = "Slow and cold. They get bored eventually.", next = "gull_steps", result = { fortitude = { -2, 0 }, sanity = -2, log = "For two cold hours {crew} sat in the fog without a word, until the Brackwater boat got bored and rowed off to bother someone else." } },
					{ label = "Back out of the arches", ["end"] = "retreat", result = { log = "Quietly, {crew} backed the boat out of the arches and rowed the pump heart home to the boathouse." } },
				},
			},
			open_water = {
				title = "Open Water",
				text = "The fog thins over the open Mere, and the big lamp of a Sluice patrol boat swings across the water toward you. A voice booms through a speaking trumpet: 'Halt, and show your manifest!' In the bottom of the boat, the pump heart gleams like a second moon.",
				tone = "danger",
				choices = {
					{ label = "Douse the lamp and drift", hint = "Prudence clash, hard.", clash = { stat = "prudence", foe = "The patrol lamp", coins = 3, base = 6, coinPower = 3 }, winNext = "gull_steps", loseEnd = "fail", win = { log = "{champion} kept everyone still and silent while the beam slid over the boat, paused, and moved on." }, lose = { money = { -40, -15 }, setFlags = { "sluice_marked" }, log = "The patrol hauled the pump heart aboard, wrote your name in a red book, and fined {crew} on the spot." } },
					{ label = "Show them a page of your ledger", hint = "Every debt, every favor, every name.", requires = { hasGear = "pocket_ledger" }, next = "gull_steps", result = { prudence = { 1, 2 }, log = "The patrol captain's name was in your pocket ledger, beside a favor he still owed. One look at the page from {crew}, and the lamp swung away." } },
					{ label = "Haul out the nets and play night fishers", hint = "Someone who can mend a net with their eyes shut.", requires = { min = { temperance = 40 } }, next = "gull_steps", result = { temperance = { 0, 1 }, log = "By the time the lamp reached the boat, {crew} had nets out and were arguing about bait. The patrol laughed and swung away, and nobody looked under the tarp." } },
					{ label = "Roll the cargo over the side", hint = "The Kin will not forgive this.", ["end"] = "retreat", result = { sanity = -3, condition = "marked", log = "Over the side went the pump heart. The patrol found nothing on {crew}, and by morning every cousin in the Silt knew what you had done." } },
				},
			},
			exchange = {
				title = "The Drowned Exchange",
				text = "The Kin's secret way runs through the drowned old Exchange: down a hall of marble pillars, under a great board of prices nobody has changed in a hundred years. Below the boat, in the green water, the Quiet stand in rows between the pillars, faces turned up. Your oars pass a hand's width over their heads.",
				tone = "strange",
				choices = {
					{ label = "Row on without a sound", next = "gull_steps", result = { sanity = -2, log = "Not one splash: {crew} rowed the whole length of the Exchange in silence. Nobody looked down. Nobody needed to." } },
					{ label = "Fish a strongbox off a drowned desk", hint = "One of them is closer than the rest.", next = "gull_steps", result = { wage = { 25, 55 }, sanity = -4, log = "A boathook and a steady hand got {crew} a little strongbox off a drowned desk. When you looked back, one of the Quiet was standing in the boat's wake." } },
				},
			},
			gull_steps = {
				title = "Gull Steps",
				text = "The pump house on Gull Steps is ankle-deep already, and the old pump is coughing like a sick dog. Silt families hold lanterns along every walkway, watching. Someone has to bolt the new heart in while the pump is still turning.",
				choices = {
					{ label = "Bolt it in yourselves", hint = "Temperance clash.", clash = { stat = "temperance", foe = "The coughing pump", coins = 2, base = 4, coinPower = 3 }, winEnd = "success", loseEnd = "success", win = { wage = { 15, 35 }, sanity = 3, log = "{champion} bolted the heart in on the first try. The pump caught and roared, the floor began to drain, and every walkway on Gull Steps cheered for {crew}." }, lose = { condition = "burned_hands", log = "The pump spat scalding water across your hands, but on the third try {crew} got the heart in, and the pump caught." } },
					{ label = "Hand it to the pump-keeper and slip away", result = { log = "The old pump-keeper took the heart from {crew} with both hands, and you slipped away before anyone could ask your name." } },
				},
			},
		},
		success = { wage = { 50, 110 }, setFlags = { "worked_for_brine" }, log = "The Kin paid you in creased scrip and wrote your name in the ledger, on the good side of the page." },
		fail = { sanity = -3, setFlags = { "brine_grudge" }, log = "The Kin lost a pump heart, and Gull Steps lost its pump. A week later, someone chalked a curled hook on a post by your door." },
		retreat = { sanity = -1, log = "You rowed back to the boathouse. The cousin said nothing at all, which was worse than shouting." },
	},

	-- ── a mission for the Sluice Authority ──
	sluice_overflow_survey = {
		name = "The Overflow Survey",
		desc = "Before every storm season, the Sluice Authority sends someone down the old Saltpan overflow to chalk every blockage between the Rim drains and the Silt. The Authority's map says the tunnels are empty. The Authority's map is wrong.",
		kind = "mission",
		minAge = 16,
		cooldown = 2,
		crew = { min = 1, max = 4 },
		length = 5,
		start = "sluice_house",
		stages = {
			sluice_house = {
				title = "Seventh Floor, Sluice House",
				text = "An Engineer with ink to the elbows hands you a bag of chalk, a measuring pole and a map older than the Pumpworks. 'Walk the overflow from the Rim drain to the Silt outfall and chalk every blockage,' she says. 'And be out before the storm. The storm doesn't read maps.'",
				choices = {
					{ label = "Go down the Rim drain", next = "culverts", result = { log = "Down the Rim drain {crew} went, into brick tunnels that smelled of rain and rust." } },
					{ label = "Take the Authority's maintenance lift", hint = "Sluice Authority staff only.", requires = { career = "sluice" }, next = "valve_hall", result = { log = "One look at an Authority pass, and a bored lift-keeper dropped {crew} straight down to the valve hall." } },
				},
			},
			culverts = {
				title = "The Brick Culverts",
				text = "The culverts are knee-deep and cold, and the old surveyors' chalk marks on the walls stop forty years ago. At a junction, a side culvert that should be dry has a curtain hung across it. Behind the curtain, someone is singing a counting song.",
				choices = {
					{ label = "Look behind the curtain", next = "families", result = { log = "Very gently, {crew} pulled the curtain aside." } },
					{ label = "Chalk the junction and press on", next = "valve_hall", result = { temperance = { 1, 2 }, log = "Neat as a clerk, {crew} chalked the junction on the map and kept going. The singing stopped as you passed." } },
					{ label = "Turn back before it gets deeper", ["end"] = "retreat", result = { log = "With half a map, {crew} climbed back up the Rim drain." } },
				},
			},
			families = {
				title = "The Rooms Behind the Curtain",
				text = "A dozen Silt families are living in the dry culvert: bunks, cook-pots, a school slate with today's sums on it. The Authority's map says this tunnel is empty, so nobody will warn them when the storm comes through. An old man looks at your chalk bag and doesn't say a word.",
				choices = {
					{ label = "Help them carry everything up to the Terraces", hint = "The storm won't wait for you.", next = "storm", result = { sanity = 4, fortitude = { -3, -1 }, setFlags = { "warned_the_culvert" }, log = "Bunks, pots and one very angry cat: {crew} carried it all up the drain stairs. By the time you came back down, it was raining on the Rim." } },
					{ label = "Leave them off the map", hint = "Then the valve had better hold.", next = "valve_hall", result = { sanity = -1, setFlags = { "kept_the_culvert_off_the_map" }, log = "Not one chalk mark: {crew} walked past as if the culvert were empty. The old man nodded once." } },
					{ label = "Ask them the way to the valve", hint = "They trust their own.", requires = { side = "gutters" }, next = "valve_hall", result = { prudence = { 1, 2 }, log = "Gutter folk know Gutter folk. A girl with a school slate led {crew} down a dry back passage, straight to the valve hall." } },
				},
			},
			valve_hall = {
				title = "The Valve Hall",
				text = "The overflow valve is an iron wheel taller than a door, crusted with rust and old weed. If it isn't open before the storm, every culvert behind you fills to the roof. Far above, faintly, rain is beginning on the Rim.",
				choices = {
					{ label = "Heave the wheel open", hint = "Fortitude clash.", clash = { stat = "fortitude", foe = "The rusted valve", coins = 2, base = 5, coinPower = 3 }, winEnd = "success", loseNext = "storm", win = { log = "{champion} threw everything into the wheel until the rust cracked, and the valve swung open with a groan that rattled {crew} to the teeth." }, lose = { fortitude = { -5, -2 }, log = "The wheel moved a hand's width for {crew} and froze. Then the storm came down the drains." } },
					{ label = "Lever it with a hooked pole", hint = "Needs a Hooked Pole.", requires = { hasGear = "hook_pole" }, result = { log = "With the hooked pole jammed through the spokes, {crew} leaned and leaned until the valve gave, slow and screaming." } },
					{ label = "Chalk it 'jammed' and get out", ["end"] = "retreat", result = { log = "On the map, {crew} wrote JAMMED in big letters beside the valve, and climbed out before the rain reached the drains." } },
				},
			},
			storm = {
				title = "The Storm Comes Down",
				text = "Rain off the Rim pours into the drains all at once, and the culverts become rivers. The water is brown, fast and full of whatever the storm picked up on the way down, including a silt eel as long as a tram rail. The Silt outfall is somewhere ahead, past the roar.",
				tone = "danger",
				choices = {
					{ label = "Ride the flood out through the outfall", hint = "Justice clash, hard.", clash = { stat = "justice", foe = "The storm flood", coins = 3, base = 6, coinPower = 3 }, winEnd = "success", loseEnd = "fail", win = { sanity = 2, log = "{champion} kept everyone's heads up all the way down, and the flood spat {crew} out of the Silt outfall into the Mere, map held high. A Kelpmarket fisherman hauled you aboard, laughing." }, lose = { fortitude = { -12, -5 }, sanity = -3, condition = "fog_lung", log = "The flood tumbled {crew} through the dark like washing in a tub. You came out at the outfall coughing brown water, and the map was gone.", cause = "Drowned in the Saltpan overflow" } },
					{ label = "Wedge into a high drain and wait it out", hint = "Needs patience.", requires = { min = { prudence = 45 } }, ["end"] = "success", result = { sanity = -3, log = "Knees under chins, {crew} waited out the storm in a high drain while the water roared past below, then walked the rest of the survey in the dripping quiet." } },
					{ label = "Fight back up the way you came", hint = "Against the water, with nothing to show for it.", ["end"] = "retreat", result = { fortitude = { -5, -2 }, sanity = -2, log = "Step by step against the rising water, {crew} fought back up to the Rim drain and climbed out soaked to the neck." } },
				},
			},
		},
		success = { wage = { 60, 120 }, temperance = { 1, 2 }, log = "The Engineer read your map, frowned at one or two of the marks, and paid you anyway." },
		fail = { sanity = -3, log = "The Authority docked your pay for the lost map. Nobody asked about the people in the culverts." },
		retreat = { log = "You turned in half a map and half a story. The Engineer took both without comment." },
	},

	-- ── a mission for a Ward company: the Hempen Company of Ropewalk ──
	hempen_high_cable = {
		name = "The High Cable",
		desc = "The Hempen Company's freight cable runs from the Ropewalk towers far out over the Mere. A gondola has jammed halfway across with three riggers aboard, and a squall is coming. The Company pays a bounty to whoever brings them in.",
		kind = "mission",
		minAge = 15,
		cooldown = 2,
		crew = { min = 1, max = 4 },
		length = 5,
		start = "tower",
		stages = {
			tower = {
				title = "The Cable Tower",
				text = "The Ropewalk cable tower creaks in the wind like a ship's mast. From the top platform, the stuck gondola is a tiny box on a thread, swinging over black water a quarter mile out. A Hempen foreman shoves a harness at you. 'Hook on, don't look down, and don't let go of anything you can't afford to lose.'",
				choices = {
					{ label = "Ride the maintenance trolley out", next = "span", result = { log = "Clipped onto the maintenance trolley, {crew} cranked it out along the cable, foot by foot." } },
					{ label = "Row out under the cable instead", next = "below", result = { log = "In a Company launch, {crew} rowed out across the chop to the spot under the gondola." } },
					{ label = "Walk the cable like a Ropewalk rigger", hint = "Ropewalk folk grow up on these cables.", requires = { district = "ropewalk" }, next = "gondola", result = { justice = { 1, 2 }, log = "One hand on the guide rope, the old Ropewalk way, {crew} walked the cable out and reached the gondola before the trolley could have left the tower." } },
				},
			},
			span = {
				title = "Halfway Out",
				text = "Halfway out, the squall arrives all at once: rain sideways, the cable bucking like something alive, the trolley swinging out over nothing. Below, the Mere is white with wind. The gondola is still a long way off.",
				tone = "danger",
				choices = {
					{ label = "Hold on and ride it out", hint = "Fortitude clash.", clash = { stat = "fortitude", foe = "The squall", coins = 2, base = 5, coinPower = 3 }, winNext = "gondola", loseNext = "below", win = { log = "{champion} locked both arms around the trolley frame and held on until the gust blew itself out." }, lose = { fortitude = { -8, -3 }, sanity = -2, log = "The trolley's hook jumped the cable, and {crew} dropped into the Mere. A Company launch fished you out, coughing, right under the gondola.", cause = "Fell from the High Cable" } },
					{ label = "Clip on a second line", hint = "A careful hand.", requires = { min = { prudence = 40 } }, next = "gondola", result = { log = "Before the next gust, {crew} clipped a second safety line to the cable. When it came, both lines held." } },
					{ label = "Crank back to the tower", ["end"] = "retreat", result = { sanity = -2, log = "Back to the tower {crew} cranked. Out on the cable, the gondola kept swinging." } },
				},
			},
			gondola = {
				title = "The Gondola",
				text = "Three riggers are wedged in the gondola among bales of new rope, soaked, furious and very glad to see you. One holds his arm against his chest. Above them, the gondola's wheel is jammed solid in a cable splice, packed tight with frayed hemp.",
				choices = {
					{ label = "Clear the jammed wheel", hint = "Temperance clash.", clash = { stat = "temperance", foe = "The jammed splice", coins = 2, base = 4, coinPower = 3 }, winNext = "landing", loseNext = "below", win = { log = "{champion} cut the frayed hemp out strand by strand until the wheel turned, and the gondola began to roll home." }, lose = { sanity = -2, log = "The wheel lurched free, dropped the gondola a sickening yard, and jammed again. After that, {crew} and the riggers wanted another way down." } },
					{ label = "Pry it loose with a hooked pole", hint = "Needs a Hooked Pole.", requires = { hasGear = "hook_pole" }, next = "landing", result = { log = "One heave on the hooked pole levered the splice open, and the gondola rolled free with {crew} and the riggers aboard." } },
					{ label = "Lower the riggers down to the water", next = "below", result = { log = "With a rope tied off to the gondola frame, {crew} lowered the riggers toward the Mere, one by one." } },
				},
			},
			below = {
				title = "Under the Cable",
				text = "From the water, the gondola is a dark box against the clouds, and the cable sings in the wind. Swells shove the launch sideways as the riggers come down the rope, swinging. Someone has to catch them.",
				choices = {
					{ label = "Catch them one by one", hint = "Justice clash, hard. The foreman tips for a dry landing.", clash = { stat = "justice", foe = "The heaving swell", coins = 3, base = 6, coinPower = 3 }, winNext = "landing", loseEnd = "fail", win = { wage = { 15, 30 }, justice = { 1, 2 }, log = "{champion} caught all three riggers out of the air, one after another, and the launch barely rocked. The foreman tipped {crew} on the spot." }, lose = { fortitude = { -8, -3 }, condition = "broken_arm", log = "A swell lifted the launch at the worst moment, and {crew} went into the water in a tangle of rope and riggers. Everyone came up in the end, you with a broken arm.", cause = "Dragged under the High Cable" } },
					{ label = "Spread a net across the launch", hint = "Someone who knows rigging.", requires = { min = { temperance = 35 } }, next = "landing", result = { log = "A cargo net, rigged tight across the launch, caught the riggers like fish as {crew} called each drop." } },
					{ label = "Have them drop into the water", hint = "Slow and cold. The foreman will dock you for it.", next = "landing", result = { fortitude = { -4, -1 }, sanity = -2, money = { -30, -10 }, log = "One by one the riggers dropped into the Mere, and one by one {crew} hauled them over the side, everybody soaked and shivering. The foreman docked the bounty for the soaking." } },
				},
			},
			landing = {
				title = "The Ropewalk Landing",
				text = "The foreman counts heads on the landing: three riggers, all breathing, one arm in a sling. Rain runs off the Company's painted sign. A clerk in a dry coat is already working out what the delay cost.",
				choices = {
					{ label = "Take the bounty", result = { log = "The riggers lined up to shake hands with {crew}, and the foreman counted out the bounty in the rain." } },
					{ label = "Pay the riggers' stitcher out of your bounty", hint = "30 scrip.", requires = { min = { money = 30 } }, result = { money = -30, sanity = 4, justice = { 1, 2 }, log = "At a word from {crew}, the clerk took the riggers' stitcher bill out of the bounty. The foreman looked at you differently after that." } },
				},
			},
		},
		success = { wage = { 70, 130 }, sanity = 2, log = "The Hempen Company paid the bounty in full, and the riggers' families sent round a basket of bread." },
		fail = { sanity = -3, log = "The riggers came home. The Company called it 'an incident' and paid you nothing at all." },
		retreat = { sanity = -1, log = "Another crew brought the riggers in. You watched from the tower with your harness still on." },
	},

	-- ── a dungeon: the cathedral at the bottom of the Mere ──
	drowned_cathedral = {
		name = "The Drowned Cathedral",
		desc = "At the bottom of the Mere stands the cathedral of the old city, its bell tower leaning up toward the light. The Choir says it is where the drowned city listens. Salvagers say the altar silver is still down there, and so is a congregation that never left.",
		kind = "dungeon",
		minAge = 17,
		cost = 15,
		cooldown = 3,
		crew = { min = 1, max = 4 },
		length = 6,
		start = "tower",
		stages = {
			tower = {
				title = "The Leaning Tower",
				text = "Your boat bumps against the cathedral's bell tower where it breaks the surface, leaning like a tired old man. Through the louvers you can see the great bell, green with age, hanging over a stairwell full of black water. A brass plate on the stone reads, in old letters: BE STILL, AND BE HEARD.",
				choices = {
					{ label = "Climb down the tower stair", next = "stair", result = { log = "Past the great bell and into the dark, {crew} started down the drowned stair." } },
					{ label = "Dive the outside wall to the rose window", hint = "Needs a Guild Diving Lamp.", requires = { hasGear = "diving_lamp" }, next = "organ", result = { log = "Following the Guild lamp's beam, {crew} dove down the cathedral wall past stone saints furred with weed, and in through a broken pane of the rose window." } },
					{ label = "Sink straight down the tower's heart", hint = "Tidetouched only.", requires = { form = "tidetouched" }, next = "nave", result = { sanity = 2, log = "Breathing slow and sinking easy, the Tidetouched way, {crew} let the Mere carry you down the tower's heart and into the nave." } },
				},
			},
			stair = {
				title = "The Spiral Stair",
				text = "The stair winds down inside the tower, each landing a bubble of stale air. Bell ropes hang down the middle of the well, thick with weed, and the weed is moving: silt eels, a whole knot of them, nesting in the ropes. They are very interested in your lamps.",
				choices = {
					{ label = "Fight down through the eel knot", hint = "Justice clash.", clash = { stat = "justice", foe = "The eel knot", coins = 2, base = 5, coinPower = 3 }, winNext = "nave", loseNext = "nave", win = { log = "{champion} drove the eels back up the bell ropes with a lamp and a boot, and {crew} slipped down past them." }, lose = { fortitude = { -8, -3 }, sanity = -2, log = "The eels bit and let go, bit and let go, all the way down the stair, and {crew} reached the bottom bruised and shaking.", cause = "Bitten in the cathedral tower" } },
					{ label = "Climb down outside the stairwell", hint = "Slow and steady.", requires = { min = { prudence = 40 } }, next = "nave", result = { sanity = -2, log = "A hand's width from the eel knot, {crew} climbed down the outside of the stairwell and never once looked at it." } },
					{ label = "Go back up to the boat", ["end"] = "retreat", result = { log = "Back up past the great bell {crew} climbed, and out into the daylight." } },
				},
			},
			nave = {
				title = "The Congregation",
				text = "The nave is a long hall of green water, and every pew is full. The Quiet sit shoulder to shoulder, dozens of them, faces turned up to the vaulted roof as if listening to a sermon only they can hear. The altar is at the far end of the aisle, and the aisle is very long.",
				tone = "strange",
				choices = {
					{ label = "Walk the aisle without a sound", hint = "Prudence clash, hard.", clash = { stat = "prudence", foe = "The listening congregation", coins = 3, base = 6, coinPower = 3 }, winNext = "crypt", loseNext = "rising", win = { sanity = -2, log = "{champion} led the way down the aisle, step by silent step. Not one face in the pews turned." }, lose = { sanity = -6, log = "Someone's boot scraped stone. Slowly, every face in the pews turned toward {crew}." } },
					{ label = "Sit in an empty pew and listen", hint = "The Choir knows how.", requires = { career = "choir" }, next = "crypt", result = { sanity = { -2, 5 }, setFlags = { "sat_with_the_congregation" }, log = "In the last pew, {crew} sat and listened for a long time. When you stood, the congregation had made room in the aisle." } },
					{ label = "Swim up along the roof to the organ loft", next = "organ", result = { log = "Up into the carved vaulting {crew} swam, high above the pews, toward the organ loft." } },
				},
			},
			organ = {
				title = "The Organ Loft",
				text = "The organ loft holds a great pocket of trapped air, stale and cold, and the pipes rise above you like a drowned forest. The organist's bench is still here. So is a hymnal, swollen with water, open to a page with no notes on it at all.",
				choices = {
					{ label = "Rest, then take the choir stair down", next = "crypt", result = { fortitude = { 1, 3 }, log = "After a rest in the trapped air, {crew} took the narrow choir stair down behind the altar." } },
					{ label = "Press one key", hint = "Nobody knows what it does.", next = "rising", result = { sanity = { -5, 6 }, setFlags = { "played_the_drowned_organ" }, log = "When {crew} pressed one key, a low note rolled through the drowned cathedral and kept going. In the nave below, the congregation stood up." } },
					{ label = "Pry the silver pipe-caps loose", next = "rising", result = { wage = { 30, 60 }, log = "One by one, {crew} pried the silver caps off the organ pipes. Each came loose with a little sigh of air, like a held breath let go." } },
				},
			},
			crypt = {
				title = "The Treasury",
				text = "Under the altar, a stair leads down to the old treasury, where the water is so still your lamps don't even flicker. Silver plates and candlesticks lie stacked on stone shelves, black with age. On the last shelf sits a brass token stamped with a lantern, warm as a hand in the cold water.",
				choices = {
					{ label = "Fill the sacks with altar silver", next = "rising", result = { wage = { 60, 120 }, log = "Sack after sack, {crew} filled up with altar silver until the straps creaked." } },
					{ label = "Take only the warm token and go", hint = "A Lantern Token. It replaces your charm.", result = { gear = "lantern_token", sanity = 2, log = "Leaving everything else exactly where it lay, {crew} took the warm token and went. Nothing followed you up." } },
					{ label = "Take the silver and the token", hint = "Heavy. Needs a strong back.", requires = { min = { fortitude = 55 } }, next = "rising", result = { wage = { 60, 120 }, gear = "lantern_token", log = "Silver and token both went into the sacks. Somewhere above {crew}, the great bell gave a single soft knock." } },
				},
			},
			rising = {
				title = "The Bell Wakes",
				text = "The great bell in the tower begins to ring, slow and deep, though nothing touches it. The water shivers with every stroke. In the nave, the Quiet are standing in the aisle now, all of them, between you and the way out.",
				tone = "danger",
				choices = {
					{ label = "Swim for the rose window", hint = "Fortitude clash, hard.", clash = { stat = "fortitude", foe = "The bell's pull", coins = 3, base = 6, coinPower = 3 }, winEnd = "success", loseEnd = "fail", win = { log = "{champion} found the broken pane in the rose window, and {crew} burst out of the cathedral into open water with the bell still ringing behind." }, lose = { fortitude = { -12, -5 }, sanity = -6, money = { -40, -10 }, condition = "night_terrors", log = "Each stroke of the bell knocked the breath out of {crew}. You came up beside the boat with no memory of the climb, and with lighter pockets than you went down with.", cause = "Drowned in the cathedral nave" } },
					{ label = "Walk back through them, eyes down", hint = "Needs an iron nerve.", requires = { min = { prudence = 55 } }, ["end"] = "success", result = { sanity = -4, log = "Eyes on the floor, {crew} walked back up the aisle through the standing congregation. Cold shoulders brushed yours. None of them stopped you." } },
					{ label = "Hum the lost bell's note back", hint = "You have rung a drowned bell before.", requires = { flags = { "rang_the_lost_bell" } }, ["end"] = "success", result = { sanity = 4, log = "The note of the lost bell was still in you. When {crew} hummed it back at the tower, the great bell stopped mid-stroke, and the Quiet sat down again, one by one." } },
					{ label = "Leave an offering in the aisle", hint = "Give something back.", ["end"] = "retreat", result = { money = { -40, -15 }, sanity = 2, log = "Pockets emptied into the aisle, silver and scrip and all: that was the price. The bell stopped, the Quiet sat back down, and {crew} swam out without looking back." } },
				},
			},
		},
		success = { wage = { 50, 100 }, sanity = 2, setFlags = { "walked_the_drowned_nave" }, log = "On the Bellhollow stairs, a silversmith bought every scrap of old silver you brought up and didn't ask where it came from. From the look on her face, she knew." },
		fail = { sanity = -4, log = "The cathedral kept its silver, and a little of you. On still nights, you can hear the bell." },
		retreat = { sanity = -1, log = "You came up into daylight with empty sacks and all your breath." },
	},

	-- ── a dungeon: the Ironmongers' sealed furnaces ──
	foundry_undercroft = {
		name = "The Foundry Undercroft",
		desc = "Under Foundry Row lie the Ironmongers' first furnaces, sealed below the waterline eighty years ago. The Charter is paying crews to bring up the old master patterns before the Mere takes them. Nobody mentions why the shaft is still warm.",
		kind = "dungeon",
		minAge = 16,
		cost = 10,
		cooldown = 2,
		crew = { min = 1, max = 4 },
		length = 6,
		start = "lift",
		stages = {
			lift = {
				title = "The Cage Lift",
				text = "Behind the Ironmongers' yard, an iron cage lift hangs over a shaft that breathes warm air, like the mouth of something asleep. The Charter's agent stays well back by the gate. Far below there is an orange glow, and the steady scrape of a shovel.",
				choices = {
					{ label = "Ride the cage down", next = "hall", result = { log = "The chain sang the whole way down, and the air around {crew} grew warmer with every turn." } },
					{ label = "Climb down the service ladders", hint = "Quick hands and a head for heights.", requires = { min = { justice = 35 } }, next = "gantry", result = { fortitude = { -2, 0 }, log = "Rung by sooty rung, {crew} climbed down the service ladders and came out high under the undercroft roof." } },
				},
			},
			hall = {
				title = "The Casting Hall",
				text = "The lift opens on a hall as big as a cathedral, half flooded with water as warm as a bath and steaming. Iron casting patterns stick up out of it like the masts of sunken boats. Old pattern-iron sells for a fortune on Foundry Row, if you can find it in steam thick enough to lose each other in.",
				choices = {
					{ label = "Wade in and gather pattern-iron", hint = "Fortitude clash.", clash = { stat = "fortitude", foe = "The scalding shallows", coins = 2, base = 4, coinPower = 3 }, winNext = "furnace", loseNext = "furnace", win = { wage = { 40, 80 }, log = "{champion} waded into the steaming channels and came back to {crew} with an armful of pattern-iron and steam rising off both sleeves." }, lose = { wage = { 10, 25 }, fortitude = { -8, -3 }, condition = "burned_hands", log = "A hot spring opened under the water right where you were reaching. In the end {crew} got a little iron out, and a lot of blisters.", cause = "Scalded in the Foundry undercroft" } },
					{ label = "Follow the dry rail line along the wall", next = "furnace", result = { log = "An old ore-cart rail led {crew} along the wall, where the floor was dry and the steam thinner." } },
				},
			},
			gantry = {
				title = "The High Gantry",
				text = "The ladders let you out onto an iron gantry high above the casting hall, under a roof black with old soot. From up here you can see everything: the steaming water, the pattern-iron, and at the far end, a furnace door glowing orange. A tall shape stands in front of it, shoveling.",
				choices = {
					{ label = "Fish for pattern-iron with a rope and hook", next = "furnace", result = { wage = { 40, 70 }, log = "Piece by piece, {crew} fished the best pattern-iron in the hall up out of the steam." } },
					{ label = "Cross the gantry to the pattern vault", next = "vault", result = { sanity = -2, log = "Right over the furnace {crew} crept, along the gantry. The shoveling below never missed a beat." } },
				},
			},
			furnace = {
				title = "The Banked Fire",
				text = "The furnace has been burning down here for eighty years, and someone has been feeding it: the coal heap is fresh, the shovel handle worn bright. The tall shape in the leather apron keeps shoveling, steady as a pump, and never turns around. Behind it is the door to the pattern vault.",
				tone = "strange",
				choices = {
					{ label = "Slip past while its back is turned", hint = "Prudence clash, hard.", clash = { stat = "prudence", foe = "The Tender", coins = 3, base = 6, coinPower = 3 }, winNext = "vault", loseNext = "blowback", win = { log = "{champion} timed every step to the shovel strokes, and {crew} slipped past behind the Tender's back." }, lose = { sanity = -5, log = "A boot rang on a loose plate behind {crew}. The shoveling stopped, and for the first time in eighty years, the fire began to die." } },
					{ label = "Pick up a spare shovel and help", hint = "Needs a strong body.", requires = { min = { fortitude = 50 } }, next = "vault", result = { fortitude = { -4, -1 }, sanity = 2, log = "Shovel for shovel, {crew} fed the fire beside it until the furnace roared white. Then it stepped aside to let you pass." } },
					{ label = "Feed it the way stokers do", hint = "Pumpworks stokers only.", requires = { career = "stoker" }, next = "vault", result = { sanity = 3, log = "Three shovels and a rest, three shovels and a rest: {crew} fed the fire the Pumpworks way. The Tender nodded once and stepped aside." } },
					{ label = "Back away to the lift", ["end"] = "retreat", result = { log = "Slowly, {crew} backed away to the cage lift and rang for the top." } },
				},
			},
			vault = {
				title = "The Pattern Vault",
				text = "The pattern vault is dry and as hot as an oven. The Ironmongers' first master patterns hang on the walls, the molds every chain in Undermere was cast from. In a rack by the door stands a hooked pole of black Foundry iron, the kind the old chain-men carried.",
				choices = {
					{ label = "Load the master patterns", next = "blowback", result = { wage = { 80, 150 }, log = "Into the sacks went the master patterns, each as heavy as an anvil and worth more than a house, until {crew} could barely stand." } },
					{ label = "Take only the black iron pole", hint = "A Hooked Pole. It replaces your tool.", result = { gear = "hook_pole", log = "Leaving the patterns on their hooks, {crew} took the black iron pole from its rack and rode the cage up in silence." } },
					{ label = "Take the patterns and the pole", hint = "Heavy. Needs a strong back.", requires = { min = { fortitude = 55 } }, next = "blowback", result = { wage = { 80, 150 }, gear = "hook_pole", log = "Patterns, pole and all: the vault floor creaked under {crew} on the way out." } },
				},
			},
			blowback = {
				title = "Blowback",
				text = "The furnace's rhythm has changed: the shoveling has stopped. Pressure is building in the old flues with a shriek like a kettle the size of a house, and the cage lift is all the way across the casting hall.",
				tone = "danger",
				choices = {
					{ label = "Run for the lift", hint = "Justice clash.", clash = { stat = "justice", foe = "The blowback", coins = 2, base = 5, coinPower = 3 }, winEnd = "success", loseEnd = "fail", win = { log = "{champion} hauled the cage gate shut a breath before the flues blew, and a wall of steam chased {crew} halfway up the shaft." }, lose = { fortitude = { -12, -5 }, money = { -40, -10 }, condition = "burned_hands", log = "The flues blew while {crew} were still crossing the hall. You came up the shaft wrapped in wet sacking, with the haul left behind.", cause = "Caught in the Foundry blowback" } },
					{ label = "Shut the flue damper", hint = "Someone who knows engines.", requires = { min = { temperance = 45 } }, ["end"] = "success", result = { sanity = 2, log = "Hunting through the steam, {crew} found the old flue damper and wrestled it shut. The shriek died to a hiss, and somewhere in the dark, the shoveling started again." } },
					{ label = "Pull your oilskin tight and run", hint = "Needs an Oilskin Coat.", requires = { hasGear = "oilskin" }, ["end"] = "success", result = { fortitude = { -3, -1 }, log = "Oilskin over head and shoulders, {crew} ran straight through the steam to the lift. It hissed off the oiled cloth like rain on a stove." } },
					{ label = "Duck into a cooling pit until it blows", hint = "You'll be leaving with what's in your pockets.", ["end"] = "retreat", result = { fortitude = { -4, -1 }, sanity = -3, log = "Up to the neck in a cooling pit, {crew} waited while the flues roared overhead. When it was over, you climbed out and rode the cage up with whatever was still in your pockets." } },
				},
			},
		},
		success = { wage = { 50, 100 }, sanity = 1, log = "The Ironmongers' agent weighed whatever you brought up twice and paid you once, in clean Charter notes." },
		fail = { sanity = -3, log = "The undercroft is sealed again. The Charter has your name on a list, under 'damages'." },
		retreat = { sanity = -1, log = "You rode the cage up empty-handed. The Charter's agent crossed your name off the list without looking up." },
	},

	-- ── a dungeon for two or more: the Wreck Company's vault ──
	wreck_company_vault = {
		name = "The Sunken Vault",
		desc = "When the Wreck Company went under, its vault went with it: a strongroom beneath the counting house with the collapsed dome, out in the Drownside shallows. The vault wheel takes two to turn, and nobody who went down alone came back up. The Brine Kin say everything inside is theirs.",
		kind = "dungeon",
		minAge = 18,
		cost = 20,
		cooldown = 3,
		crew = { min = 2, max = 4 },
		length = 6,
		start = "dome",
		stages = {
			dome = {
				title = "The Broken Dome",
				text = "The Wreck Company's counting house sits in the Drownside shallows with its great dome caved in like a cracked egg. Through the hole you can see the trading floor under green water, and at the back, a round iron door with a wheel the size of a cart. Two Kin boats are tied up by the wall, lanterns lit, nobody in them.",
				choices = {
					{ label = "Dive down through the dome", next = "floor", result = { log = "A rope tied off to the dome's broken frame, and down into the green {crew} went." } },
					{ label = "Take the clerks' tunnel", hint = "The Kin keep the key.", requires = { career = "brine" }, next = "deposit_hall", result = { log = "With a Kin key, {crew} unlocked the old clerks' tunnel and crawled through a dry brick pipe toward the deposit hall." } },
				},
			},
			floor = {
				title = "The Trading Floor",
				text = "The trading floor is a forest of drowned desks, each with its inkwell and its chair pushed back. Ledgers float against the ceiling like pale fish. Somewhere under the desks, something is tapping on iron, slow and patient.",
				choices = {
					{ label = "Search the clerks' desks", next = "door", result = { wage = { 20, 40 }, sanity = -2, log = "Drawer by drawer, {crew} went through the desks and came away with a bundle of old Wreck Company notes. The tapping followed you the whole way." } },
					{ label = "Follow the tapping", next = "deposit_hall", result = { log = "The tapping led {crew} across the floor to a rusted grille at the back of the hall." } },
				},
			},
			deposit_hall = {
				title = "The Deposit Hall",
				text = "Behind a rusted grille, in a pocket of trapped air, six Brine Kin cousins are sitting on the deposit counter, out of lamp oil and out of patience. 'Two days,' one says, tapping a spanner on the bars. 'Get us out and we'll call it square. Leave us, and the ledger hears about it.'",
				choices = {
					{ label = "Pry the grille and get them out", next = "door", result = { fortitude = { -3, -1 }, sanity = 3, setFlags = { "freed_the_kin_cousins" }, log = "Bar by bar, {crew} pried the grille open. The cousins swam out, called you cousin, and swore to buy you broth for a year." } },
					{ label = "Free them, for the vault's secret", hint = "Make a deal.", requires = { min = { prudence = 45 } }, next = "vault", result = { setFlags = { "freed_the_kin_cousins" }, log = "Through the bars, {crew} struck a deal: freedom for a secret. 'The wheel turns backward,' the cousin said. It did, and the vault swung open." } },
					{ label = "Leave them for now", next = "door", result = { sanity = -3, setFlags = { "brine_grudge" }, log = "On {crew} swam. Behind you the spanner went quiet, which was somehow worse." } },
				},
			},
			door = {
				title = "The Vault Wheel",
				text = "The vault door is round, iron and three times your height, and its wheel is as wide as a cart. It takes two to turn it; everybody knows that. What nobody mentions is the slow scraping on the other side.",
				choices = {
					{ label = "Put your backs into the wheel", hint = "Fortitude clash, hard. Every hand helps.", clash = { stat = "fortitude", foe = "The vault wheel", coins = 3, base = 6, coinPower = 3 }, winNext = "vault", loseNext = "flood", win = { log = "{champion} called the pull, and together {crew} heaved until the bolts drew back with a boom like a struck bell." }, lose = { fortitude = { -8, -3 }, log = "The wheel slipped and spun back hard. Somewhere above {crew}, the old walls cracked, and the water began to move.", cause = "Caught by the Wreck Company vault wheel" } },
					{ label = "Read the dial like a company clerk", hint = "Company staff know these old dials.", requires = { career = "company" }, next = "vault", result = { log = "The combination was in the dial's wear marks, the numbers clerks had turned ten thousand times, and {crew} spun the wheel as easily as a tap." } },
					{ label = "Leave the vault shut and swim out", ["end"] = "retreat", result = { log = "One look at the scraping door was enough. Up through the dome {crew} went, with nothing but a story." } },
				},
			},
			vault = {
				title = "The Strongroom",
				text = "The strongroom has been sealed dry for eighty years: shelves of company strongboxes, bundles of old notes, and a Company greatcoat on a peg, the cut still sharp. In the dark at the back, something very long uncoils from around the last shelf and lifts a pale head into your lamplight. The Kin call it the Paymaster.",
				tone = "danger",
				choices = {
					{ label = "Grab what you can and back out slowly", next = "flood", result = { wage = { 70, 130 }, log = "Never once turning your backs on the Paymaster, {crew} filled your sacks from the near shelves." } },
					{ label = "Fight the Paymaster for the back shelf", hint = "Justice clash, hard. The big one.", clash = { stat = "justice", foe = "The Paymaster", coins = 3, base = 7, coinPower = 3 }, winNext = "flood", loseNext = "flood", win = { wage = { 150, 260 }, setFlags = { "beat_the_paymaster" }, log = "{champion} drove the old eel back into its corner with a lamp in one hand and a strongbox lid in the other, and {crew} cleared the back shelf." }, lose = { wage = { 30, 60 }, fortitude = { -12, -5 }, condition = "broken_arm", log = "The Paymaster struck like a falling rope, and {crew} scrambled out of reach with a few boxes and a broken arm to show for it.", cause = "Taken by the Paymaster" } },
					{ label = "Take the greatcoat from its peg", hint = "A Company Greatcoat. It replaces your coat.", next = "flood", result = { gear = "company_greatcoat", wage = { 20, 40 }, log = "Off the peg came the greatcoat, bone dry and smelling of cedar, and {crew} grabbed a strongbox on the way past." } },
				},
			},
			flood = {
				title = "The Counting House Floods",
				text = "The tide turned while you were inside, and the whole counting house is groaning. Water pours through the broken dome in a green wall, and the trading floor has become a whirlpool of desks and ledgers. The dome is a long swim up.",
				tone = "danger",
				choices = {
					{ label = "Keep your heads and find the current", hint = "Prudence clash.", clash = { stat = "prudence", foe = "The turning tide", coins = 2, base = 5, coinPower = 3 }, winEnd = "success", loseEnd = "fail", win = { log = "{champion} found the current that ran up through the dome, and {crew} rode it out into daylight with every sack." }, lose = { fortitude = { -10, -4 }, sanity = -4, money = { -60, -20 }, log = "The whirlpool took the sacks first and nearly took {crew} after them. You came up through the dome with empty hands.", cause = "Drowned in the Wreck Company vault" } },
					{ label = "Wait for slack water", hint = "Your tide tables know the minute.", requires = { hasGear = "tide_tables" }, ["end"] = "success", result = { sanity = 2, log = "Tide tables open, {crew} waited in the strongroom doorway, counting under your breath, and swam out on the slack as easily as a ferry ride." } },
					{ label = "Drop the sacks and swim light", ["end"] = "retreat", result = { money = { -50, -20 }, log = "The heavy sacks went first, and {crew} swam light. The tide took the Wreck Company's money back, the way it always does." } },
				},
			},
		},
		success = { wage = { 80, 150 }, sanity = 2, setFlags = { "cracked_the_wreck_vault" }, log = "A Gatewater collector bought the old Wreck Company notes as 'history'. The Kin took their cut before you got home." },
		fail = { sanity = -4, log = "The counting house kept everything you carried. The vault is underwater again, and the Kin know who opened it." },
		retreat = { sanity = -1, log = "You came up through the dome with light sacks and all your breath. The Kin boats were gone." },
	},

	-- ── a trip on the Undertow Line: up the locks to the Rim ──
	undertow_rim_gardens = {
		name = "The Undertow Line to the Rim Gardens",
		desc = "On Visitors' Day, the Undertow's Rim spur carries anyone with a ticket up through the old aqueduct locks inside the crater wall, all the way to the Rim Gardens: glasshouses, fountains and real sunlight. The garden wardens watch Gutter boots very closely.",
		kind = "trip",
		minAge = 14,
		cost = 20,
		cooldown = 1,
		crew = { min = 1, max = 4 },
		length = 6,
		start = "platform",
		stages = {
			platform = {
				title = "Platform Three",
				text = "The Rim spur leaves from Platform Three, where the Undertow car waits in a lock chamber full of green water. The conductor stamps your ticket with a little glass flower and warns everyone not to pull the cord at the old orchard gallery. The doors seal, the water rises, and the car rises with it.",
				choices = {
					{ label = "Watch the locks go by", next = "gardens", result = { sanity = 2, log = "Lock after lock filled and lifted the car up through the dark inside the crater wall, and {crew} watched the water outside turn from black to green to gold." } },
					{ label = "Pull the cord at the orchard gallery", hint = "There's a fine.", next = "orchard", result = { money = -10, log = "When {crew} pulled the cord, the car shuddered to a stop, and the conductor wrote out a fine with enormous dignity." } },
				},
			},
			orchard = {
				title = "The Stone Orchard",
				text = "The aqueduct builders carved an orchard into the rock here: stone trees with stone fruit, every leaf cut by hand, all of it under a foot of clear water and lit by lamps that someone still fills. At the end of the row kneels a stone gardener holding out a stone pear. The pear is not quite finished.",
				tone = "strange",
				choices = {
					{ label = "Get back on before the car leaves", next = "gardens", result = { sanity = 3, log = "Soaked to the knees, {crew} stood among the stone trees until the conductor rang the bell, then ran for the car." } },
					{ label = "Finish carving the pear", hint = "Needs a craftsman's hands.", requires = { min = { temperance = 40 } }, next = "gardens", result = { sanity = 5, temperance = { 1, 2 }, setFlags = { "finished_the_stone_pear" }, log = "With the conductor's pocketknife, {crew} finished the stone pear's last leaf. The lamps in the gallery seemed to burn a little brighter." } },
					{ label = "Take the stone pear home", hint = "It's very heavy, and it isn't yours.", next = "warden", result = { sanity = { -3, 2 }, wage = { 20, 50 }, log = "Under a coat, {crew} sneaked the stone pear back onto the car. It got heavier all the way up." } },
				},
			},
			gardens = {
				title = "The Rim Gardens",
				text = "The last lock opens onto sunlight so bright you have to squint. The Rim Gardens run along the crater's lip in green terraces: glasshouses, fountains, clipped hedges, and people who have never once been wet. A garden warden in white gloves is watching your boots.",
				choices = {
					{ label = "Walk the terraces to the great glasshouse", next = "glasshouse", result = { sanity = 3, log = "Past fountains and roses, with the whole crater spread out below like a map, {crew} walked the terraces in the sun." } },
					{ label = "Sell kelp toffee to the Rim children", hint = "Visitors aren't allowed to trade.", next = "warden", result = { wage = { 25, 55 }, log = "By the fountain, {crew} sold a whole bag of kelp toffee to Rim children who had never tasted anything so salty. They wanted more." } },
					{ label = "Buy lunch at the terrace pavilion", hint = "30 scrip. Rim prices.", requires = { min = { money = 30 } }, next = "ride_home", result = { money = -30, sanity = 6, log = "At a white table under an awning, with silver forks and a view of the whole crater, {crew} ate a lunch that cost a month of broth." } },
				},
			},
			glasshouse = {
				title = "The Great Glasshouse",
				text = "Inside the Glaziers' great glasshouse it is warm and green and smells of earth after rain. Trees from beyond the crater grow under panes as tall as houses. High in the roof, a gardener is wrestling a cracked pane, and the wind is about to take it.",
				choices = {
					{ label = "Run up the ladder and help hold it", hint = "Fortitude clash.", clash = { stat = "fortitude", foe = "The gusting pane", coins = 2, base = 4, coinPower = 3 }, winNext = "ride_home", loseNext = "warden", win = { wage = { 20, 45 }, sanity = 2, log = "{champion} held the pane steady while the gardener bolted it home. She paid {crew} from her own pocket, with a cutting wrapped in wet paper." }, lose = { fortitude = { -4, -1 }, log = "The pane slipped out of {champion}'s hands and burst on the path below {crew}. A warden came running, very fast for a man in white gloves." } },
					{ label = "Stay out of the way and look", next = "ride_home", result = { sanity = 5, log = "Under the great trees, {crew} looked up for so long that a gardener asked if you were feeling all right." } },
				},
			},
			warden = {
				title = "The Garden Warden",
				text = "A white glove closes on your sleeve. 'Visitors' Day tickets do not cover trade, theft or trouble,' the warden says. 'Papers.' Behind him, two Charter guards are strolling over, in no particular hurry.",
				tone = "danger",
				choices = {
					{ label = "Talk your way out of it", hint = "Prudence clash.", clash = { stat = "prudence", foe = "The garden warden", coins = 2, base = 5, coinPower = 3 }, winNext = "ride_home", loseEnd = "fail", win = { log = "{champion} explained everything so politely and at such length that the warden let go of {crew} just to make it stop." }, lose = { money = { -30, -10 }, sanity = -3, log = "The guards marched {crew} back to the lock platform and fined you twice: once for the trouble, once for the boots." } },
					{ label = "Show your Charter papers", hint = "Charter residents only.", requires = { side = "charter" }, next = "ride_home", result = { log = "One look at Charter papers, and the warden let go of {crew} at once. He apologized to your boots." } },
					{ label = "Apologize and leave early", ["end"] = "retreat", result = { sanity = -2, log = "Red-faced, {crew} apologized to the warden, the guards and a nearby hedge, and caught the next car down." } },
				},
			},
			ride_home = {
				title = "The Long Way Down",
				text = "The car sinks back down through the locks with the water roaring out around it, and the light goes gold, then green, then lamp-yellow. When the doors hiss open on Platform Three, Undermere smells of kelp broth and wet stone, and somehow that's fine.",
				choices = {
					{ label = "Step off the car", result = { sanity = 2, log = "Back on Platform Three, {crew} stepped off with the Rim's sunlight still in your eyes." } },
				},
			},
		},
		success = { sanity = 4, log = "For weeks afterward, you could close your eyes and see green." },
		fail = { sanity = -3, log = "The guards put you on the next car down with a note pinned to your coat. You took the note off on the stairs, and kept it anyway." },
		retreat = { sanity = 1, log = "You left the Rim early, but you saw it. Nobody can take that back." },
	},

	-- ── a trip on the Undertow Line: the end of the Far Line ──
	undertow_glass_lighthouse = {
		name = "The Undertow Line to the Glass Lighthouse",
		desc = "The Undertow's Far Line runs under the crater wall, under the Salt Flats, and on for hours through the dark to the Glass Shore, where the old sea used to be. The Glaziers built a lighthouse there, entirely of glass, for ships that never came. It still turns.",
		kind = "trip",
		minAge = 14,
		cost = 35,
		cooldown = 3,
		crew = { min = 1, max = 4 },
		length = 6,
		start = "far_line",
		stages = {
			far_line = {
				title = "The Far Line",
				text = "The Far Line car is older than the others, with brass seats worn smooth and portholes the size of dinner plates. It runs for hours through drowned aqueducts without a single station. At last the conductor says, almost shyly, 'Glass Shore. End of the line.'",
				choices = {
					{ label = "Doze through the long dark", next = "shore", result = { sanity = 2, log = "Dozing against the warm brass, {crew} woke to a strange white light through the portholes." } },
					{ label = "Wave at the porthole again", hint = "It remembers you.", requires = { flags = { "waved_in_the_undertow" } }, next = "shore", result = { sanity = 6, log = "When {crew} waved into the dark, something enormous turned after a long while and kept pace with the car all the way to the Glass Shore, like an escort." } },
				},
			},
			shore = {
				title = "The Glass Shore",
				text = "The sea that was here left its floor behind: a plain of salt and sea-glass, green and blue and amber, crunching under your boots. Out on a spit of rock, the lighthouse stands like a great icicle, every wall and step made of glass. At the top, a light turns slowly, sweeping a shore no ship has reached in a hundred years.",
				choices = {
					{ label = "Walk out along the spit", next = "stair", result = { log = "Sea-glass crunching underfoot, {crew} walked out along the spit toward the lighthouse." } },
					{ label = "Comb the shore for sea-glass", hint = "Pretty, and it sells. The wind is rising.", next = "storm", result = { wage = { 20, 45 }, log = "Pocket by pocket, {crew} filled up with sea-glass the colors of tram lamps and new leaves, and didn't notice the wind until the salt began to sting." } },
					{ label = "Sit on the salt and watch the light turn", result = { sanity = 6, prudence = { 1, 2 }, log = "On the warm salt, {crew} sat and watched the light sweep the empty shore until the conductor rang for the last car home." } },
				},
			},
			stair = {
				title = "The Glass Stair",
				text = "The lighthouse stair is a spiral of clear glass, three hundred steps, and you can see straight down through every one of them to the rocks. The walls hum faintly in the wind. From the top, a thin old voice calls down: 'Hurry, please. They're coming.'",
				choices = {
					{ label = "Climb steadily, eyes up", hint = "Prudence clash.", clash = { stat = "prudence", foe = "The long way down", coins = 2, base = 4, coinPower = 3 }, winNext = "lamp_room", loseEnd = "retreat", win = { log = "{champion} counted the steps out loud, and {crew} climbed all three hundred without once looking down." }, lose = { sanity = -4, log = "{champion} looked down on step two hundred and ten and froze. It took {crew} a long time to get back down to the rock." } },
					{ label = "Hold the Still Stone and breathe", hint = "Needs a Still Stone.", requires = { hasGear = "still_stone" }, next = "lamp_room", result = { sanity = 2, log = "With the Still Stone warm in one fist and every breath slow, {crew} climbed, and the glass felt as solid as a pier." } },
				},
			},
			lamp_room = {
				title = "The Lantern Room",
				text = "At the top, the great lens turns around a flame no bigger than your hand and throws it miles across the salt. The keeper, a small old man in a salt-white coat, points with his chin. Out in the dark, drifting toward the light like snow falling upward, come the lamp-eaters: hundreds of them.",
				tone = "danger",
				choices = {
					{ label = "Trim the wick and work the shutters", hint = "Temperance clash, hard.", clash = { stat = "temperance", foe = "The lamp-eater swarm", coins = 3, base = 6, coinPower = 3 }, winNext = "keeper", loseNext = "storm", win = { log = "While the keeper trimmed the wick, {champion} worked the shutters, flashing the light so hard and bright that the lamp-eaters scattered like startled moths." }, lose = { sanity = -4, log = "The lamp-eaters folded over the lens, and for the first time in a hundred years, the light went out. The keeper sent {crew} down the stair in the dark to find the car." } },
					{ label = "Lead them off with a hand lantern", hint = "Quick feet on a glass balcony.", requires = { min = { justice = 40 } }, next = "keeper", result = { fortitude = { -2, 0 }, log = "Hand lantern held high, {crew} ran the glass balcony, and the whole swarm followed the light out over the salt and away." } },
				},
			},
			keeper = {
				title = "The Keeper's Table",
				text = "When the last lamp-eater has drifted off into the dark, the keeper sets out tea in glass cups. He has kept this light for sixty years, he says, for ships that never came. 'It isn't for ships, really. It's so the dark knows someone is still awake.'",
				choices = {
					{ label = "Promise to come back", result = { sanity = 5, setFlags = { "kept_the_glass_light" }, log = "Over the glass cups, {crew} promised to come back, and meant it. The keeper walked you to the car and waved until the doors sealed." } },
					{ label = "Accept his old tide tables", hint = "Tide Tables. They replace your tool.", result = { gear = "tide_tables", sanity = 2, log = "The keeper pressed his old tide tables on {crew}, sea-stained and soft at the corners. 'I know them by heart,' he said. 'Someone should have them.'" } },
				},
			},
			storm = {
				title = "Salt Storm",
				text = "The wind gets up off the old sea floor and fills the air with salt, stinging and blinding. You can't see the lighthouse, the shore or your own hands. Somewhere ahead, very faint, the Far Line car is ringing its bell for the last departure.",
				tone = "danger",
				choices = {
					{ label = "Follow the bell", hint = "Fortitude clash.", clash = { stat = "fortitude", foe = "The salt storm", coins = 2, base = 5, coinPower = 3 }, winEnd = "success", loseEnd = "fail", win = { log = "{champion} walked into the wind toward the bell, one step at a time, and {crew} reached the car just as the doors began to close." }, lose = { fortitude = { -6, -2 }, sanity = -3, condition = "salt_cough", log = "The storm turned {crew} around and around until the bell stopped. You spent a cold night lost on the old sea floor, coughing salt, until the morning car came.", cause = "Lost in a salt storm on the Glass Shore" } },
					{ label = "Wrap up in your oilskin and wait", hint = "Needs an Oilskin Coat.", requires = { hasGear = "oilskin" }, ["end"] = "success", result = { sanity = 1, log = "Huddled under oilskin, {crew} waited out the storm, then walked to the car under a sky full of stars." } },
					{ label = "Shelter in the lee of a dune till morning", hint = "Cold, and the morning car costs extra.", ["end"] = "success", result = { fortitude = { -3, -1 }, sanity = -2, money = -10, log = "Curled up in the lee of a salt dune, {crew} let the storm howl past all night, and caught the morning car home, hoarse and very hungry." } },
				},
			},
		},
		success = { sanity = 5, log = "On the long ride home, you kept seeing the light turn behind your eyes." },
		fail = { sanity = -2, log = "You came home salt-burned and hoarse, and the light on the Glass Shore turned in your dreams for a month." },
		retreat = { sanity = 1, log = "You rode home early with the glass stair still humming in your knees. Behind you, the light was still turning." },
	},

	-- ── a trip on the Undertow Line: the lagoon past the western wall ──
	undertow_kelp_islands = {
		name = "The Undertow Line to the Kelp Islands",
		desc = "Past the western wall of the crater, the Undertow's Weedwater spur surfaces in a warm green lagoon where the kelp grows so thick it floats in islands, and whole villages live on them. The islanders say you'll want to stay. The last car home says otherwise.",
		kind = "trip",
		minAge = 14,
		cost = 25,
		cooldown = 2,
		crew = { min = 1, max = 4 },
		length = 6,
		start = "weedwater",
		stages = {
			weedwater = {
				title = "Weedwater Halt",
				text = "The car surfaces in a burst of bubbles beside a platform of lashed kelp stalks that bobs under your boots. The air is warm and smells of salt and green things. Out across the lagoon, islands of golden kelp drift on the water, with stilt-huts, washing lines and children waving.",
				choices = {
					{ label = "Take the ferry raft to the market island", next = "market", result = { sanity = 2, log = "The ferryman sang a song with no end to it while {crew} rode his raft across the lagoon." } },
					{ label = "Walk the kelp bridges to the wild islands", next = "bridges", result = { log = "Off along the kelp bridges {crew} went, toward the far islands, where there were no huts at all." } },
					{ label = "Slip into the warm water and swim", hint = "Tidetouched only.", requires = { form = "tidetouched" }, next = "grazers", result = { sanity = 3, log = "Under the islands the light came down green and gold through the kelp, and {crew} swam out through it in water that felt like home." } },
				},
			},
			market = {
				title = "The Floating Market",
				text = "The market island rocks gently under a hundred stalls: kelp cakes, dried fish, rope sandals, shell buttons, and jars of something bright orange that the seller swears is jam. Everyone is shouting, and nobody is angry.",
				choices = {
					{ label = "Help a stallholder through the noon rush", next = "feast", result = { wage = { 20, 45 }, temperance = { 0, 1 }, log = "All through the noon rush, {crew} sold kelp cakes for a stallholder and got paid in coins with holes in the middle." } },
					{ label = "Haggle for island pearls to sell at home", hint = "Temperance clash.", clash = { stat = "temperance", foe = "The pearl-sellers", coins = 2, base = 4, coinPower = 3 }, winNext = "feast", loseNext = "feast", win = { wage = { 40, 80 }, log = "{champion} haggled a pearl-seller down to half price. Back home, {crew} will sell those pearls for double." }, lose = { money = { -25, -10 }, log = "{champion} paid full price for pearls that turned out to be painted clay. The pearl-seller waved goodbye to {crew} very warmly." } },
					{ label = "Eat your way down the stalls", hint = "15 scrip.", requires = { min = { money = 15 } }, next = "feast", result = { money = -15, sanity = 5, log = "Kelp cakes, orange jam and something on a stick nobody could name: {crew} ate the lot, and all of it was good." } },
				},
			},
			bridges = {
				title = "The Kelp Bridges",
				text = "The bridges between the islands are ropes of braided kelp, springy and slick, and they sway with every step. The far islands are wild, just gulls and golden kelp. In the clear water between them, huge slow shapes drift under the surface like clouds.",
				choices = {
					{ label = "Cross the swaying bridges", hint = "Justice clash.", clash = { stat = "justice", foe = "The kelp bridges", coins = 2, base = 4, coinPower = 3 }, winNext = "grazers", loseNext = "market", win = { log = "{champion} found the rhythm of the bridges, bounce and step, bounce and step, and {crew} crossed to the wild islands without a splash." }, lose = { fortitude = { -3, -1 }, sanity = -1, log = "The bridge rolled, and {crew} went into the lagoon. Island kids fished you out, laughing, and sent you to the market to dry off." } },
					{ label = "Run them like a Kelpmarket kid", hint = "Kelpmarket folk grow up on floating kelp.", requires = { district = "kelpmarket" }, next = "grazers", result = { sanity = 2, log = "Never stopping, never looking down, {crew} ran the bridges the Kelpmarket way, and the island kids cheered." } },
				},
			},
			grazers = {
				title = "The Grazers",
				text = "In the channel between the wild islands, the slow shapes rise to the surface: fish as big as tram cars, grey and gentle, with eyes like old coins. The islanders call them grazers. They are eating the kelp one island at a time, and they don't seem to mind you at all.",
				tone = "strange",
				choices = {
					{ label = "Lie on the kelp and watch them", next = "feast", result = { sanity = 6, log = "Stretched out on the warm kelp, {crew} watched the grazers drift past, close enough to hear them breathe." } },
					{ label = "Touch one as it passes", next = "feast", result = { sanity = { -2, 8 }, setFlags = { "touched_a_grazer" }, log = "As a grazer slid past, {crew} reached down and touched its side, cool and smooth as river stone. It rolled one coin-bright eye up at you." } },
					{ label = "Follow them out past the islands", hint = "Where are they all going in such a hurry?", next = "squall", result = { log = "Past the last island {crew} followed the grazers. They were swimming faster now, all in one direction, away from the western sky." } },
				},
			},
			feast = {
				title = "The Lantern Raft Feast",
				text = "At dusk the islanders set lanterns drifting on little rafts, and everyone eats at one long table of planks. Someone hands you a bowl of kelp broth and moves up to make room. The last car leaves at the last bell, and the sky to the west has gone a strange dark green.",
				choices = {
					{ label = "Catch the last car home", result = { sanity = 2, log = "Broth bowl still in hand, {crew} ran for the last car and waved to the islands until the water closed over the portholes." } },
					{ label = "Stay for the singing", hint = "Just one more song.", next = "squall", result = { sanity = 4, log = "Just one more song, {crew} said, and one more song turned into five." } },
				},
			},
			squall = {
				title = "The Squall",
				text = "The squall comes across the lagoon in a grey wall of rain. The islands heave, the kelp bridges snap one by one, and lantern rafts spin off into the dark. Somewhere behind the rain, Weedwater Halt is ringing the last call.",
				tone = "danger",
				choices = {
					{ label = "Run for the halt", hint = "Fortitude clash.", clash = { stat = "fortitude", foe = "The squall", coins = 2, base = 5, coinPower = 3 }, winEnd = "success", loseEnd = "fail", win = { log = "{champion} led the way across the heaving kelp, and {crew} dove through the car doors just before they sealed." }, lose = { fortitude = { -6, -2 }, sanity = -2, log = "The car left without {crew}. You spent the night under an upturned raft, soaked through, listening to the storm.", cause = "Lost in the Weedwater squall" } },
					{ label = "Take a bed with an island family", hint = "25 scrip for a dry corner and the morning car.", requires = { min = { money = 25 } }, ["end"] = "success", result = { money = -25, sanity = 3, log = "An island family took {crew} in for the night and put you on the morning car. Their grandmother told stories until the storm went quiet." } },
				},
			},
		},
		success = { sanity = 5, log = "You came home sunburned and smelling of kelp, with a shell button in your pocket you'll keep for years." },
		fail = { money = { -30, -10 }, sanity = -2, log = "You came home a day late and soaked to the bone, and the Undertow charged you for a second ticket." },
	},
}
