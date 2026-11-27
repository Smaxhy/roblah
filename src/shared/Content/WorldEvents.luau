--[[
	World events: things that happen to the whole server at once. The server rolls
	one every so often (Config.worldEvents), announces it to everyone, and switches
	it on for `minutes` of real time. While it's on:
		* events with when = { worldEvent = "id" } can roll,
		* tagWeights make events with those tags more (or less) likely,
		* startEvent (if set) is queued for everyone who's playing,
		* expedition (if set) is open to crews.

	Fields: name, headline (the banner), text, minutes, weight, tone ("danger",
	"strange" or nil), district (where it's centered, optional), tagWeights,
	startEvent, expedition, endText.
]]

return {
	order = { "breach_tidewell", "lantern_festival", "great_low_tide", "fog_week", "company_strike" },

	breach_tidewell = {
		name = "Containment breach",
		headline = "BREACH AT THE TIDEWELL INSTITUTE",
		text = "Sirens over Glasswall. Something the Institute dredged out of the Mere and kept under glass is loose in the Wards, and the shutters are coming down street by street.",
		minutes = 8,
		weight = 3,
		tone = "danger",
		district = "glasswall",
		tagWeights = { breach = 8, danger = 1.4, luxury = 0.5 },
		startEvent = "breach_sirens",
		expedition = "tidewell_containment",
		endText = "The Tidewell Institute reports the breach contained. The shutters go back up, slowly.",
	},

	lantern_festival = {
		name = "Lantern Night",
		headline = "LANTERN NIGHT ON THE MERE",
		text = "Every Ward floats paper lanterns for the drowned tonight. The trams run free and the Choir sings from the rooftops.",
		minutes = 7,
		weight = 4,
		tagWeights = { faith = 2, friend = 1.6, danger = 0.6 },
		startEvent = "festival_lanterns",
		endText = "The last lanterns drift out past the cathedral spire.",
	},

	great_low_tide = {
		name = "The Great Low Tide",
		headline = "THE MERE IS LOWER THAN ANYONE REMEMBERS",
		text = "The water has pulled back off whole streets that drowned a hundred years ago. Salvagers are pouring down the stairs.",
		minutes = 7,
		weight = 3,
		tagWeights = { salvage = 3, strange = 1.3 },
		startEvent = "lowtide_streets",
		endText = "The Mere comes back in, quietly, over everything it gave up.",
	},

	fog_week = {
		name = "Fog Week",
		headline = "FOG ROLLS IN OFF THE MERE",
		text = "A yellow fog fills the crater to the Rim. You can't see your own hand on the railing, and the coughing starts on the second day.",
		minutes = 6,
		weight = 3,
		tone = "strange",
		tagWeights = { danger = 1.3, crime = 1.6, strange = 1.8 },
		startEvent = "fog_door",
		endText = "The fog lifts. People count each other on the stairs.",
	},

	company_strike = {
		name = "The Great Strike",
		headline = "THE PUMPWORKS HAVE STOPPED",
		text = "Every stoker in the city has put down their shovel. The pumps are silent, the water is creeping up the lowest stairs, and the companies are furious.",
		minutes = 6,
		weight = 2,
		tagWeights = { company = 0.5, crime = 1.4 },
		startEvent = "strike_picket",
		endText = "The strike ends with a handshake nobody believes. The pumps cough back to life.",
	},
}
