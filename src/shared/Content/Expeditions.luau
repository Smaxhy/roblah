--[[
	Expeditions: missions, dungeons, trips and containment jobs. Each is a run of
	stages (cards with choices). Solo or with a crew of players: the captain
	chooses, everyone gets the results, and clashes are fought by the crew member
	best at that stat with +1 coin per other member (up to +3).

	Fields:
		name, desc, kind ("mission" | "dungeon" | "trip" | "containment")
		minAge, maxAge, cost, actions (default 1), cooldown (years), when
		crew = { min = 1, max = 4 }   how many players can go (default 1 to 1)
		length = 4                    rough number of stages, shown on the card
		start = "stageId", stages = { [id] = { title, text, tone?, choices = {...} } }
		success / fail / retreat      results applied when the run ends that way

	A stage choice is like an event choice (label, hint, requires, result OR clash +
	win + lose) plus where it leads:
		next = "stageId"              (after a result, or after a clash either way)
		winNext / loseNext            (after a clash)
		end = "success" | "fail" | "retreat", winEnd / loseEnd
	A choice with no next and no end finishes the run as a success.
	Text tokens: {crew} ("you" or "your crew"), {crewNames}, {champion} (who fought).
]]

return {
	order = { "lost_bell", "drowned_arcade", "undertow_saltflats", "tidewell_containment" },

	-- ── a mission ──
	lost_bell = {
		name = "The Lost Bell of Bellhollow",
		desc = "The Bellhollow choir lost a hand bell in the flooded chapel under the old market. They pay well for its return, and they don't ask how.",
		kind = "mission",
		minAge = 14,
		cooldown = 3,
		crew = { min = 1, max = 4 },
		length = 4,
		start = "stairs",
		stages = {
			stairs = {
				title = "The Chapel Stairs",
				text = "The stairs down to the chapel are slick with weed. Below, the water stands knee-deep and perfectly still. Somewhere under it, very faintly, something rings.",
				choices = {
					{ label = "Wade straight in", next = "nave", result = { fortitude = { -2, 0 }, log = "{crew} waded in to the knees. The cold went straight to the bone." } },
					{ label = "Find the dry gallery first", hint = "Needs a careful eye.", requires = { min = { prudence = 25 } }, next = "gallery", result = { log = "{crew} found the old choir gallery, still dry, running along the wall." } },
					{ label = "Turn back", ["end"] = "retreat", result = { log = "The stillness of that water was enough. {crew} went back up." } },
				},
			},
			gallery = {
				title = "The Choir Gallery",
				text = "From the gallery you can see the whole drowned nave. The bell's glint is under the altar, and something long and pale is lying across the aisle between you and it.",
				choices = {
					{ label = "Lower a hook from up here", hint = "Temperance clash.", clash = { stat = "temperance", foe = "The long reach down", coins = 2, base = 4, coinPower = 3 }, winNext = "altar", loseNext = "nave", win = { log = "{champion} lowered the hook inch by inch and caught the bell's handle." }, lose = { log = "The hook slipped, the bell rang under the water, and the pale thing stirred." } },
					{ label = "Climb down by the altar", next = "altar", result = { sanity = -2, log = "{crew} climbed down the old organ pipes, as far from the aisle as possible." } },
				},
			},
			nave = {
				title = "The Drowned Nave",
				text = "The pale thing across the aisle is a drowned banner, rippling. Or it was. Now it is lifting, slowly, toward you.",
				tone = "danger",
				choices = {
					{ label = "Stand your ground", hint = "Justice clash.", clash = { stat = "justice", foe = "The pale banner", coins = 2, base = 5, coinPower = 3 }, winNext = "altar", loseEnd = "fail", win = { sanity = -2, log = "{champion} tore the banner down with both hands. It was only cloth after all. Probably." }, lose = { fortitude = { -10, -4 }, sanity = -4, log = "It wrapped around {champion} and pulled. Everyone ran.", cause = "Drowned in the Bellhollow chapel" } },
					{ label = "Back away up the stairs", ["end"] = "retreat", result = { sanity = -3, log = "{crew} backed up the stairs without turning around." } },
				},
			},
			altar = {
				title = "The Altar",
				text = "The bell is in your hand. It is warmer than it should be, and when you lift it out of the water, every other bell in Bellhollow, up above, rings once.",
				choices = {
					{ label = "Carry it back to the choir", result = { log = "{crew} carried the bell back up into the light." } },
					{ label = "Ring it here", hint = "Nobody knows what it does.", ["end"] = "success", result = { sanity = { -4, 6 }, setFlags = { "rang_the_lost_bell" }, log = "{crew} rang it once. The water in the nave went perfectly flat, and stayed that way." } },
				},
			},
		},
		success = { wage = { 60, 120 }, sanity = 3, log = "The choir paid in coin and in a blessing nobody understood." },
		fail = { sanity = -4, log = "The bell is still down there. So is part of your nerve." },
	},

	-- ── a dungeon ──
	drowned_arcade = {
		name = "The Drowned Arcade",
		desc = "A covered market that sank whole in the last flood. At low water you can walk its upper floor. Brass, glass and old company strongboxes, if you can get them out before the tide.",
		kind = "dungeon",
		minAge = 16,
		cost = 10,
		cooldown = 2,
		crew = { min = 1, max = 4 },
		length = 5,
		start = "gate",
		stages = {
			gate = {
				title = "The Rusted Gate",
				text = "The arcade's iron gate is rusted half-shut. Beyond it, rows of drowned shopfronts glimmer in the dark, and the tide clock on your wrist says you have about an hour.",
				choices = {
					{ label = "Force the gate", hint = "Fortitude clash.", clash = { stat = "fortitude", foe = "The rusted gate", coins = 1, base = 4, coinPower = 3 }, winNext = "shops", loseNext = "shops", win = { log = "The gate screamed and gave." }, lose = { fortitude = { -5, -2 }, log = "The gate gave, eventually, and took some skin with it." } },
					{ label = "Squeeze through the gap", next = "shops", result = { sanity = -1, log = "{crew} squeezed through sideways, one at a time." } },
				},
			},
			shops = {
				title = "The Shopfronts",
				text = "A watchmaker's, a chandler's, and a company paymaster's office with its door still locked. The water is already ankle-deep and rising.",
				choices = {
					{ label = "Clear out the watchmaker's", next = "flood", result = { wage = { 20, 45 }, log = "{crew} filled a sack with brass gears and watch faces." } },
					{ label = "Crack the paymaster's office", hint = "Temperance clash. The good stuff.", clash = { stat = "temperance", foe = "The paymaster's lock", coins = 2, base = 5, coinPower = 3 }, winNext = "strongroom", loseNext = "flood", win = { log = "The lock turned. Behind it, a narrow stair led down to a strongroom." }, lose = { log = "The lock jammed for good, and the water was rising." } },
				},
			},
			strongroom = {
				title = "The Strongroom",
				text = "Three company strongboxes sit on a shelf above the waterline. Something is nesting in the third one. It clicks.",
				tone = "danger",
				choices = {
					{ label = "Take the first two and go", next = "flood", result = { wage = { 50, 100 }, log = "{crew} took two strongboxes and left the clicking one alone." } },
					{ label = "Take all three", hint = "Justice clash.", clash = { stat = "justice", foe = "The thing in the strongbox", coins = 2, base = 6, coinPower = 3 }, winNext = "flood", loseNext = "flood", win = { wage = { 100, 180 }, log = "{champion} wrestled the third box free. Whatever was in it was gone, along with a good deal of {champion}'s sleeve." }, lose = { wage = { 40, 80 }, fortitude = { -8, -3 }, condition = "burned_hands", log = "The third box spat something hot and bitter, and {crew} ran with what they had." } },
				},
			},
			flood = {
				title = "The Tide Comes In",
				text = "The tide clock is wrong, or the tide is early. Water is pouring through the gate you came in by, and the only other way out is a broken skylight two floors up.",
				tone = "danger",
				choices = {
					{ label = "Swim for the gate", hint = "Fortitude clash.", clash = { stat = "fortitude", foe = "The incoming tide", coins = 2, base = 5, coinPower = 3 }, win = { log = "{crew} came out through the gate in a rush of black water, gasping and laughing." }, lose = { fortitude = { -12, -5 }, sanity = -3, log = "{crew} made it out, barely, and lost half a sack to the current.", cause = "Drowned in the arcade" } },
					{ label = "Climb to the skylight", hint = "Needs someone steady.", requires = { min = { prudence = 30 } }, result = { sanity = 2, log = "{crew} climbed the old display shelves to the skylight and walked home along the rooftops." } },
				},
			},
		},
		success = { sanity = 2, log = "You sold the haul on the Kelpmarket stairs before the sun was up." },
	},

	-- ── a trip on the Undertow Line ──
	undertow_saltflats = {
		name = "The Undertow Line to the Salt Flats",
		desc = "The Sluice Authority's sealed express runs through the drowned aqueducts and out under the crater wall to the Salt Flats, where the sky is enormous. Tickets are cheap. The ride is fast. Usually.",
		kind = "trip",
		minAge = 12,
		cost = 25,
		cooldown = 2,
		crew = { min = 1, max = 4 },
		length = 4,
		start = "platform",
		stages = {
			platform = {
				title = "Platform Nine",
				text = "The Undertow car is a riveted iron capsule with portholes and a conductor who looks at your ticket for much too long. The doors seal with a hiss. Then the water lets go of you.",
				choices = {
					{ label = "Take a window seat", next = "tunnel", result = { sanity = 2, log = "{crew} watched drowned streets flash past the porthole, lit by the car's lamps." } },
					{ label = "Sleep through it", next = "flats", result = { sanity = 1, log = "{crew} slept through the whole ride and woke to white light." } },
				},
			},
			tunnel = {
				title = "The Long Tunnel",
				text = "Halfway through the aqueduct the car slows. The lamps flicker. Outside the porthole, very close, something enormous is keeping pace with you in the dark.",
				tone = "strange",
				choices = {
					{ label = "Wave at it", result = { sanity = { -4, 6 }, setFlags = { "waved_in_the_undertow" }, log = "{crew} waved. After a long moment, it turned away into the deep." }, next = "flats" },
					{ label = "Close the shutter and wait", next = "flats", result = { sanity = -2, log = "{crew} closed the shutter and listened to something brush along the length of the car." } },
				},
			},
			flats = {
				title = "The Salt Flats",
				text = "Outside the crater, the sky is so big it hurts. The Salt Flats run white to the horizon, crisscrossed by salt-cutters' sledges and tents.",
				choices = {
					{ label = "Work a day with the salt-cutters", next = "return", result = { wage = { 25, 55 }, fortitude = { 1, 2 }, log = "{crew} cut salt until sunset for honest wages and a terrible sunburn." } },
					{ label = "Walk out to where the sky meets the salt", next = "return", result = { sanity = 6, prudence = { 1, 3 }, log = "{crew} walked until the crater was a dark smudge behind you. For a while there was no Undermere at all." } },
					{ label = "Trade at the salt market", hint = "Temperance clash.", clash = { stat = "temperance", foe = "The salt traders", coins = 2, base = 4, coinPower = 3 }, winNext = "return", loseNext = "return", win = { wage = { 40, 80 }, log = "{champion} bought cheap and will sell dear back home." }, lose = { money = { -20, -5 }, log = "The salt traders saw {crew} coming from a mile off." } },
				},
			},
			["return"] = {
				title = "The Ride Home",
				text = "The Undertow car takes you back under the crater wall. When the doors hiss open, the air in Undermere smells like rain and coal smoke and home.",
				choices = {
					{ label = "Step off", result = { sanity = 2, log = "{crew} stepped back onto Platform Nine, salt still in your hair." } },
				},
			},
		},
		success = { log = "You'll be telling people about the sky for weeks." },
	},

	-- ── containment: only while the Tidewell breach is on ──
	tidewell_containment = {
		name = "Containment Duty: Tidewell",
		desc = "The Institute is hiring crews to bring its escaped specimen back in. Nets, lamps, a brass whistle, and a waiver nobody reads. Big pay. Bring friends.",
		kind = "containment",
		minAge = 16,
		crew = { min = 1, max = 4 },
		length = 4,
		when = { worldEvent = "breach_tidewell" },
		start = "briefing",
		stages = {
			briefing = {
				title = "The Briefing",
				text = "A Tidewell warden in a rubber coat hands out lamps and whistles. 'It hates light, loves water, and knows your name if you say it out loud. Do not say it out loud.'",
				choices = {
					{ label = "Take the lamps and go", next = "trail", result = { log = "{crew} took the lamps, the whistles and the waiver." } },
					{ label = "Ask what it is", next = "trail", result = { sanity = -3, prudence = { 1, 2 }, log = "The warden told you. You wish they hadn't." } },
				},
			},
			trail = {
				title = "The Wet Trail",
				text = "A trail of seawater runs up the middle of a dry street, uphill, toward the Charter wall. Every lamp along it has been unscrewed and set neatly on the ground.",
				tone = "strange",
				choices = {
					{ label = "Follow it quietly", hint = "Prudence clash.", clash = { stat = "prudence", foe = "The trail that wants to be followed", coins = 2, base = 5, coinPower = 3 }, winNext = "cornered", loseNext = "ambush", win = { log = "{champion} read the trail and found where it doubled back." }, lose = { sanity = -3, log = "The trail led {crew} in a perfect circle, back to where it started. Something had been walking behind you." } },
					{ label = "Light every lamp on the street", next = "cornered", result = { sanity = 2, log = "{crew} lit every lamp. The trail began to steam and hurry." } },
				},
			},
			ambush = {
				title = "Behind You",
				text = "It is right behind you. It is taller than the lamp posts and thinner than a shadow, and it has your face, a little wrong.",
				tone = "danger",
				choices = {
					{ label = "Whistles, now", hint = "Justice clash.", clash = { stat = "justice", foe = "The Tidewell specimen", coins = 3, base = 6, coinPower = 3 }, winNext = "cornered", loseEnd = "fail", win = { sanity = -2, log = "The whistles shrieked and it folded away from the sound, down toward the water." }, lose = { fortitude = { -14, -6 }, sanity = -6, condition = "night_terrors", log = "It took {champion}'s lamp, and then it took {champion}'s voice for a whole week.", cause = "Taken by the Tidewell specimen" } },
				},
			},
			cornered = {
				title = "Cornered at the Sluice",
				text = "You drive it into a sluice channel at the edge of Glasswall. It coils in the water, hissing like a kettle, and the Institute's net crew is still three streets away.",
				tone = "danger",
				choices = {
					{ label = "Hold it with the lamps until the nets come", hint = "Fortitude clash. The big one.", clash = { stat = "fortitude", foe = "The Tidewell specimen", coins = 3, base = 7, coinPower = 3 }, winEnd = "success", loseEnd = "fail", win = { setFlags = { "contained_a_specimen" }, log = "{crew} held the light on it until the nets came down. It went into the tank screaming like steam." }, lose = { fortitude = { -12, -5 }, sanity = -5, log = "It slipped the light and went over the sluice gate into the dark. The Institute docked your pay for the lamps.", cause = "Lost at the Glasswall sluice" } },
					{ label = "Let it go back to the water", ["end"] = "retreat", result = { sanity = { -2, 4 }, log = "{crew} stepped back. It slid over the sluice gate into the Mere and was gone. Some things should go home." } },
				},
			},
		},
		success = { wage = { 150, 260 }, sanity = 4, log = "The Institute paid in clean notes and asked you to forget the whole thing." },
		fail = { sanity = -3, log = "The specimen is still out there. The Institute has your name on a list now." },
	},
}
