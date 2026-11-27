--[[
	Expeditions, area A: Backstreets runs for a solo life or a crew.
		bs_exp_home_before_three   carry medicine across the District and beat 3:13 home
		bs_exp_rat_tunnels         go down into the old service tunnels after a Rat pack
	Tokens: {crew}, {crewNames}, {champion}.
]]

return {
	order = { "bs_exp_home_before_three", "bs_exp_rat_tunnels" },

	bs_exp_home_before_three = {
		name = "Home Before Three",
		kind = "mission",
		desc = "A sick child on the far side of the District needs medicine before morning, and every courier has gone home. Cross the Backstreets with the parcel, and get home again before the Sweepers rise at 3:13.",
		minAge = 14,
		cost = 0,
		cooldown = 4,
		crew = { min = 1, max = 4 },
		length = 5,
		when = { side = "backstreets" },
		start = "parcel",
		stages = {
			parcel = {
				title = "1:50, the Clinic Door",
				text = "Doctor Seraphine presses a small parcel into {crew}'s hands: three ampules wrapped in cloth, an address on the far side of the District, a child with a fever that won't break. \"Before three,\" she says. \"There and back. If you can't make it back, don't come back: knock on a door and stay there.\"",
				choices = {
					{ label = "The short way, through the night market", result = { log = "{crew} took the short way, straight into the crowds of the night market." }, next = "market" },
					{ label = "The long way, along the canal", result = { log = "{crew} took the long way, down the dark canal path where nobody goes after one." }, next = "canal" },
				},
			},
			market = {
				title = "The Night Market",
				text = "The market is packed: skewers, steam, a puppet show, shoulder to shoulder. And Rats working the crowd in pairs. One of them has already noticed how carefully the parcel is being carried, and is drifting closer.",
				tone = "danger",
				choices = {
					{
						label = "Catch the Rat's wrist when he grabs",
						clash = { stat = "strength", foe = "A Rat pickpocket and his friend", coins = 2, base = 3, coinPower = 2, fight = true },
						win = { strength = 1, log = "{champion} caught the Rat's wrist mid-grab and sent him and his friend running into the crowd. The parcel never left {crew}'s hands." },
						lose = { health = { -5, -2 }, log = "The Rats got a hand on the parcel and {champion} had to fight to get it back. It came back. So did a bruise, and ten lost minutes." },
						next = "stairs",
					},
					{
						label = "Keep moving and hold on tight",
						clash = { stat = "mind", foe = "A crowd full of hands", coins = 2, base = 3, coinPower = 2 },
						win = { mind = 1, log = "{crew} kept the parcel close and never stopped moving. The Rats lost interest and went looking for easier pockets." },
						lose = { sanity = -2, log = "{crew} lost the way in the crowd and had to double back past the puppet show twice. The clock in the square said 2:20." },
						next = "stairs",
					},
				},
			},
			canal = {
				title = "The Canal Path",
				text = "The canal path is empty and dark and quiet, which is why it's fast. Halfway along, the old footbridge over the overflow channel has fallen in. The water below is black and loud. The far bank is a long jump away, or a long walk round.",
				choices = {
					{
						label = "Jump it",
						clash = { stat = "health", foe = "A long jump over black water", coins = 2, base = 3, coinPower = 2 },
						win = { health = 1, log = "{champion} made the jump, then helped everyone else across. The parcel stayed dry." },
						lose = { health = { -6, -3 }, sanity = -1, log = "{champion} landed short and went in up to the waist, holding the parcel over their head. Soaked, freezing, and late." },
						next = "stairs",
					},
					{ label = "Walk round by the pumping station", result = { sanity = -1, log = "{crew} walked the long way round the pumping station. It cost fifteen minutes and every one of them felt like an hour." }, next = "stairs" },
				},
			},
			stairs = {
				title = "2:31, the Hundred Stairs",
				text = "The address is at the top of the Hundred Stairs, which are, everybody agrees, closer to a hundred and forty. The street up there is already quiet. Shutters coming down. Somewhere a dog has stopped barking.",
				choices = {
					{
						label = "Run them",
						clash = { stat = "health", foe = "A hundred and forty stairs", coins = 2, base = 3, coinPower = 2 },
						win = { health = 1, log = "{crew} took the stairs two at a time and arrived at the top with burning legs and three minutes to spare." },
						lose = { health = { -4, -2 }, log = "{crew} made the top in the end, gasping. The clock on the street said 2:47." },
						next = "door",
					},
				},
			},
			door = {
				title = "2:49, the Door",
				text = "A woman opens the door before {crew} can knock. The child is behind her on a mattress, flushed and small. One ampule, and the fever starts to break while you watch. She looks at the clock, then at {crew}. \"You won't make it home,\" she says. \"Stay. The floor's clean.\"",
				choices = {
					{ label = "Stay the Night on her floor", result = { sanity = 3, log = "{crew} stayed. The Night went past outside, three waves, and nobody on the mattress or the floor said a word until the birds started." }, ["end"] = "success" },
					{ label = "Run for home: twenty-four minutes", result = { log = "{crew} thanked her and ran." }, next = "run_home" },
				},
			},
			run_home = {
				title = "2:56, Seventeen Minutes",
				text = "Down the Hundred Stairs, across the market square, every shutter already down, footsteps echoing too loudly. The pharmacy clock says 2:56. Seventeen minutes, and home is a long way off.",
				tone = "danger",
				choices = {
					{
						label = "Run like you were eight years old",
						clash = { stat = "strength", foe = "Seventeen minutes", coins = 2, base = 4, coinPower = 3 },
						win = { strength = 1, sanity = 2, log = "{crew} got the door shut at 3:12 and sat with backs against it, laughing and shaking, as the floor began to hum." },
						lose = { log = "A gate {crew} always cut through had been chained shut. The pharmacy clock struck the quarter. 3:13. The ground began to hum." },
						winEnd = "success",
						loseNext = "caught",
					},
				},
			},
			caught = {
				title = "3:13, the First Wave",
				text = "They come up out of the ground along the edge of the Nest and fill the street wall to wall: a crowd of slow figures, all walking the same way, and the street behind them is clean. {crew} is outside.",
				tone = "danger",
				choices = {
					{
						label = "Hold perfectly still in a doorway",
						clash = { stat = "mind", foe = "The first wave of Sweepers", coins = 2, base = 4, coinPower = 3 },
						win = { sanity = -3, setFlags = { "bs_night_survivor" }, addTrait = "survivor_of_the_night", codex = "bs_lore_sweepers", chronicle = "bs_act_night_walk", log = "{crew} pressed into a doorway and did not breathe for three waves. They passed close enough to touch. At dawn the street was clean and {crew} walked home through it, alive." },
						lose = { health = { -12, -6 }, sanity = -5, setFlags = { "bs_night_survivor" }, codex = "bs_lore_sweepers", log = "The second wave found {crew}'s doorway. Somehow, {crew} tore free, again and again, until it was over. Dawn came. It shouldn't have.", cause = "Swept away in the Night" },
						winEnd = "success",
						loseEnd = "fail",
					},
					{
						label = "Stand your ground",
						clash = { stat = "health", foe = "The Sweepers", coins = 3, base = 6, coinPower = 3, fight = true },
						win = { strength = 2, setFlags = { "bs_night_survivor", "bs_stood_ground" }, addTrait = "survivor_of_the_night", codex = "bs_lore_sweepers", chronicle = "bs_act_night_walk", log = "{champion} stood in the middle of the street and did not move, and the waves parted around {crew} like a river around a stone. At dawn {crew} walked home." },
						lose = { health = { -16, -8 }, sanity = -6, setFlags = { "bs_night_survivor" }, codex = "bs_lore_sweepers", log = "{crew} fought until there was nothing left to fight with, and lived anyway. Nobody could explain it, least of all {crew}.", cause = "Swept away in the Night" },
						winEnd = "success",
						loseEnd = "fail",
					},
				},
			},
		},
		success = { wage = { 50, 120 }, sanity = 3, log = "The fever broke and the child lived. Doctor Seraphine paid {crew} out of her own pocket and said, \"Never again,\" and then, \"Thank you.\"" },
		fail = { sanity = -4, log = "The child lived. {crew} barely did. Doctor Seraphine paid anyway, and wouldn't look anyone in the eye." },
	},

	bs_exp_rat_tunnels = {
		name = "The Rats' Tunnels",
		kind = "dungeon",
		desc = "A Rat pack has been robbing the street for a month and hiding in the old service tunnels under the District. The neighborhood watch has a map, a lamp, a reward, and nobody willing to go down.",
		minAge = 16,
		cost = 0,
		cooldown = 5,
		crew = { min = 1, max = 4 },
		length = 4,
		when = { side = "backstreets" },
		start = "grate",
		stages = {
			grate = {
				title = "The Grate Behind the Bathhouse",
				text = "Grandpa Teo hands over the watch's lamp and a map drawn on the back of a laundry ticket. The way in is a rusted grate behind the bathhouse, padlocked from the inside. Somebody below didn't want visitors. Warm air breathes up through the bars.",
				choices = {
					{
						label = "Pry it open",
						clash = { stat = "health", foe = "A rusted grate", coins = 2, base = 3, coinPower = 2 },
						win = { log = "{champion} wrenched the grate open with a screech that echoed a long way down." },
						lose = { health = { -4, -2 }, log = "The grate came open in the end, along with some skin off {champion}'s knuckles." },
						next = "tunnels",
					},
					{
						label = "Ask the bathhouse keeper for the old key",
						clash = { stat = "mind", foe = "A bathhouse keeper who hates questions", coins = 2, base = 3, coinPower = 2 },
						win = { mind = 1, log = "The bathhouse keeper sighed, produced a key from a hook, and said the Rats had been stealing her towels." },
						lose = { sanity = -1, log = "The keeper didn't have a key, didn't like you, and didn't believe in tunnels. {crew} pried the grate open anyway." },
						next = "tunnels",
					},
					{ label = "Turn back", result = { log = "{crew} looked down into the dark and handed the lamp back to Grandpa Teo." }, ["end"] = "retreat" },
				},
			},
			tunnels = {
				title = "The Service Tunnels",
				text = "Old brick tunnels, older than anybody's grandparents, built for pipes nobody uses. They branch and branch again. Someone has chalked little marks at the junctions: a rat, an arrow, a crown. Somewhere ahead, very faintly, someone is laughing.",
				choices = {
					{
						label = "Follow the chalk marks",
						clash = { stat = "mind", foe = "A maze of brick tunnels", coins = 2, base = 3, coinPower = 3 },
						win = { mind = 1, log = "{champion} worked out the Rats' marks: the crown meant the boss, the arrow meant the way. {crew} came up behind the den without a sound." },
						lose = { sanity = -2, log = "The marks were a trap. {crew} walked straight into the Rats' lookouts." },
						winNext = "den",
						loseNext = "ambush",
					},
					{
						label = "Follow the laughing",
						result = { log = "{crew} followed the laughing round three corners, straight into the Rats' lookouts." },
						next = "ambush",
					},
				},
			},
			ambush = {
				title = "Lookouts",
				text = "Four Rats drop down from a pipe ledge with lengths of pipe and borrowed Workshop knives, yelling to wake the whole pack. In the narrow tunnel there's nowhere to go but through them.",
				tone = "danger",
				choices = {
					{
						label = "Go through them",
						clash = { stat = "strength", foe = "Rat lookouts in a narrow tunnel", coins = 2, base = 4, coinPower = 3, fight = true },
						win = { strength = 2, log = "{crew} went through the lookouts like a door. Two ran ahead to warn the den, which was fine. The den was where {crew} was going anyway." },
						lose = { health = { -8, -3 }, sanity = -2, log = "The lookouts got their licks in before they ran. {crew} limped on toward the den.", cause = "Beaten by Rats in the tunnels" },
						next = "den",
					},
				},
			},
			den = {
				title = "The Den",
				text = "An old boiler room, warm and dry, piled with stolen things: the pharmacy's till, the bathhouse towels, three bicycles, a grandmother's radio. Eight Rats, and in the middle on an upturned crate, their boss: a scrawny man everyone calls Tinker Vasko, with a very good stolen knife and a very bad smile.",
				tone = "danger",
				choices = {
					{
						label = "Fight Vasko",
						clash = { stat = "strength", foe = "Tinker Vasko and his pack", coins = 3, base = 5, coinPower = 3, fight = true, status = { id = "bleed", potency = 1 } },
						win = { strength = 2, log = "Vasko was quick and nasty, and {champion} was better. When he went down, the pack stopped being a pack and started being eight frightened people looking for the exit." },
						lose = { health = { -12, -5 }, sanity = -3, log = "Vasko's knife was faster than it looked. {crew} got out of the boiler room and back to the grate, bleeding and empty-handed.", cause = "Cut down by a Rat boss" },
						winEnd = "success",
						loseEnd = "fail",
					},
					{
						label = "Talk the pack out from under him",
						clash = { stat = "mind", foe = "Eight Rats and their boss", coins = 3, base = 4, coinPower = 3 },
						win = { mind = 2, sanity = 2, log = "{champion} talked to the pack, not to Vasko: the watch knows where you are, the Night doesn't care, the Workshop on Kettle Lane is hiring. One by one they walked out. Vasko was left alone on his crate with a stolen radio." },
						lose = { health = { -6, -2 }, sanity = -2, log = "The pack laughed, Vasko laughed loudest, and {crew} was chased all the way back to the grate." },
						winEnd = "success",
						loseEnd = "fail",
					},
				},
			},
		},
		success = { wage = { 80, 160 }, strength = 1, setFlags = { "bs_tunnels_cleared" }, codex = "bs_lore_rats", chronicle = "bs_act_rats_broken", log = "{crew} carried the pharmacy's till, the grandmother's radio and forty towels up into the daylight. The street held a little party on the bathhouse steps. Grandpa Teo paid the reward in full." },
		fail = { sanity = -3, log = "{crew} came up out of the tunnels with nothing but bruises. The Rats moved their den the next week. Somewhere else, they're laughing." },
	},
}
