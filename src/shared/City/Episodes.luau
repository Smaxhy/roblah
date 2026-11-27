--[[
	EPISODES (v0.13): short stories of a few cards each that happen once in a life, chained
	one card to the next (Events/Episodes_*.luau). Every card of an episode carries
	`episode = "<id>"` and its `step`; the card shows the episode's name and how far along it
	is, in the episode's own look (`theme`), and the way it ends is kept on the STORY tab
	(result.episodeEnd). No two end the same way twice in a row, and most can end three or
	four ways.
	Themes the cards are drawn in: terminal (an old L Corp screen), delve (going down), blood
	(Bloodfiends), library (books and ink), street (the Backstreets), smoke (old wars), strange
	(the City being the City), nest (money and manners), lake (water), gold (rare and grand).
]]

return {
	order = {
		"ep_intercom", "ep_sealed_unit", "ep_agent_next_door", "ep_energy_crates", "ep_book_remembers",
		"ep_war_medal", "ep_kindred_supper", "ep_masterwork", "ep_office_fire", "ep_middle_debt",
		"ep_past_the_wall", "ep_borrowed_hour", "ep_following_light", "ep_rain_umbrellas", "ep_last_contract",
		"ep_apprentice",
	},

	ep_intercom = { name = "The Voice in the Intercom", of = 4, theme = "terminal", color = { 120, 210, 150 } },
	ep_sealed_unit = { name = "The Sealed Unit", of = 4, theme = "terminal", color = { 220, 90, 80 } },
	ep_agent_next_door = { name = "The Agent Next Door", of = 4, theme = "terminal", color = { 150, 200, 120 } },
	ep_energy_crates = { name = "Twelve Crates of Light", of = 3, theme = "street", color = { 130, 230, 170 } },
	ep_book_remembers = { name = "A Book That Remembers", of = 4, theme = "library", color = { 214, 180, 110 } },
	ep_war_medal = { name = "A Medal from the Smoke War", of = 3, theme = "smoke", color = { 170, 160, 150 } },
	ep_kindred_supper = { name = "Supper with the Kindred", of = 3, theme = "blood", color = { 190, 50, 70 } },
	ep_masterwork = { name = "The Workshop's Masterwork", of = 4, theme = "gold", color = { 240, 196, 92 } },
	ep_office_fire = { name = "The Office Fire", of = 3, theme = "street", color = { 236, 120, 70 } },
	ep_middle_debt = { name = "A Debt to the Middle", of = 3, theme = "street", color = { 214, 176, 92 } },
	ep_past_the_wall = { name = "Someone from Past the Wall", of = 3, theme = "strange", color = { 170, 190, 140 } },
	ep_borrowed_hour = { name = "The Hour That Went Missing", of = 3, theme = "strange", color = { 120, 170, 226 } },
	ep_following_light = { name = "The Streetlight That Follows", of = 3, theme = "strange", color = { 240, 220, 150 } },
	ep_rain_umbrellas = { name = "Thirteen Umbrellas", of = 3, theme = "strange", color = { 110, 130, 170 } },
	ep_last_contract = { name = "The Last Contract", of = 3, theme = "gold", color = { 230, 170, 90 } },
	ep_apprentice = { name = "An Apprentice", of = 3, theme = "nest", color = { 190, 150, 220 } },
}
