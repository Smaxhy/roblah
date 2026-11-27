--[[
	Echoes: how one player's deed in the Library era reaches other lives on the server.
	Writer D (lib_ ids). Each event fires for OTHER players after someone records the act
	(when = { chronicle = "act" }); {actor} and {actorDistrict} name who and where.
	Acts: Chronicle/Limbus.luau (lib_*) and Chronicle/Core.luau (became_book, won_reception).
]]

return {
	-- someone became a book (any reception, here or in the core invitation)
	{
		id = "lib_echo_became_book",
		title = "A Book Called {actor}",
		text = "At a stall of gilt-spined books, the newest one has a name you know from the City's gossip: {actor}, of {actorDistrict}. They accepted an invitation to the Library, and this is what came back out. The seller wants a fortune for it. \"Fresh,\" he says, and taps the spine.",
		weight = 14,
		cooldown = 10,
		tags = { "library" },
		when = { chronicle = "became_book", world = { era = { "library", "limbus" } }, minAge = 14 },
		codex = "lib_books_sold",
		choices = {
			{
				label = "Buy it and take it to their family",
				hint = "200 Ahn",
				requires = { min = { money = 200 } },
				result = { money = -200, sanity = 6, chronicle = "lib_book_returned", log = "You found {actor}'s family in {actorDistrict} by asking at every noodle stall. Their mother took the book in both hands and held it like a sleeping child. She asked you to stay for dinner. You stayed." },
			},
			{
				label = "Read a few pages at the stall",
				result = { mind = 2, sanity = -3, codex = "lib_key_pages", log = "They were braver than you'd guessed, and more frightened, and they'd been thinking about someone at the very end. You put the book down before the end. The seller charged you for reading." },
			},
			{
				label = "Burn the invitation you kept",
				requires = { flags = { "kept_invitation" } },
				result = { sanity = 5, clearFlags = { "kept_invitation" }, log = "You went home and burned the invitation in your drawer. It smelled of lilies. You thought about {actor}'s name on that spine the whole time it burned." },
			},
			{
				label = "Say their name out loud, and walk on",
				result = { sanity = 1, intelligence = 1, log = "You said {actor}'s name out loud, once, so that somebody would. Then you walked on." },
			},
		},
	},
	-- someone won a reception
	{
		id = "lib_echo_won_reception",
		title = "Fake Invitations",
		text = "Ever since {actor} walked out of the Library carrying a book, half of {actorDistrict} wants an invitation, and a man at your market is selling them: cream paper, signed A, ten Ahn each. They're very good fakes. Some people are buying three.",
		weight = 14,
		once = true,
		tags = { "library" },
		when = { chronicle = "won_reception", world = { era = "library" }, minAge = 12 },
		codex = "library_invitations",
		choices = {
			{
				label = "Expose the forger",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A very good forger", coins = 2, base = 4, coinPower = 3 },
				win = { strength = 1, sanity = 3, log = "You held one up to the light in front of the crowd: wrong paper, wrong ink, an A with a tremble in it. People got their money back. The forger left the District the same night." },
				lose = { money = -10, sanity = -1, log = "He talked faster than you could think, and somehow you walked away holding one of his invitations and short ten Ahn." },
			},
			{
				label = "Buy one, just to have it",
				result = { money = -10, sanity = 1, log = "A fake invitation to a real Library. You keep it in your wallet. When people ask, you say it's real. Nobody can tell." },
			},
			{
				label = "Warn your neighbors off the whole business",
				result = { sanity = 2, relationBond = { kind = "all", amount = 3 }, log = "You told everyone who'd listen that {actor} was one lucky guest out of a hundred unlucky ones. Two people put their envelopes away. One of them thanked you, later." },
			},
		},
	},
	-- someone talked a loved one out of going
	{
		id = "lib_echo_talked_out",
		title = "Burning Invitations",
		text = "In {actorDistrict}, people have started burning their Library invitations in the street, after {actor} talked someone they love out of going. The fashion has reached your block: a little bonfire on the corner, cream paper curling, people standing round it the way they used to stand round a stove.",
		weight = 14,
		once = true,
		tags = { "library" },
		when = { chronicle = "lib_talked_out", world = { era = "library" }, minAge = 10 },
		choices = {
			{
				label = "Burn yours too",
				requires = { flags = { "kept_invitation" } },
				result = { sanity = 5, clearFlags = { "kept_invitation" }, log = "You fetched the invitation from your drawer and dropped it in. Your neighbors clapped, which felt ridiculous, and also good." },
			},
			{
				label = "Stand by the fire and talk",
				result = { sanity = 3, relationBond = { kind = "all", amount = 3 }, log = "You stood by the fire until it burned out, talking with neighbors you'd only ever nodded to. Somebody brought chestnuts." },
			},
			{
				label = "Go and check on someone you love",
				requires = { hasRelation = { "mother", "father", "sibling", "child", "friend" } },
				result = { sanity = 2, relationBond = { kind = "all", amount = 6 }, log = "You went home and asked the people you love, straight out, if any of them had an envelope. Nobody did. You made them promise to tell you if one ever came." },
			},
		},
	},
	-- someone heard the Reverberation Ensemble
	{
		id = "lib_echo_ensemble",
		title = "A Tune Going Around",
		text = "Children on your street are humming a tune nobody taught them. It came from {actorDistrict}, people say, from the night {actor} heard a strange ensemble play and walked away whole. It is very catchy. Everyone who hums it gets a little sadder, or a little angrier, than they were.",
		weight = 12,
		once = true,
		tags = { "library", "strange" },
		when = { chronicle = "lib_ensemble_heard", world = { era = { "library", "limbus" } }, minAge = 8 },
		choices = {
			{
				label = "Teach them a different song",
				hint = "Intelligence check.",
				clash = { stat = "intelligence", foe = "A very catchy tune", coins = 2, base = 4, coinPower = 3 },
				win = { intelligence = 1, sanity = 3, log = "You taught the whole street an old counting song, loudly and badly, until the children were laughing too hard to hum anything. The other tune never came back." },
				lose = { sanity = -3, log = "They sang your song for a day. Then you caught yourself humming the other one, in the bath, and couldn't stop." },
			},
			{
				label = "Hum it yourself",
				result = { sanity = -5, strength = 2, log = "You hummed it once, to see. Every feeling you had stood up at once, and for a week you felt everything twice as hard. Some of that was useful. Most of it wasn't." },
			},
			{
				label = "Find out where it came from",
				hint = "Mental Strength check.",
				clash = { stat = "mind", foe = "A tune that doesn't want to be traced", coins = 2, base = 5, coinPower = 3 },
				win = { mind = 2, codex = "lib_ensemble", log = "You traced it back street by street to {actorDistrict}, to a corner where five sets of footprints stopped in the middle of the road. An old Fixer there told you who plays music like that, and asked you to forget it." },
				lose = { sanity = -4, log = "Every street you asked on, someone had just started humming it. You gave up when you realized you'd been humming it too." },
			},
		},
	},
	-- someone carried a Library book home to a family
	{
		id = "lib_echo_book_returned",
		title = "Notices on the Wall",
		text = "Since {actor} carried a Library book home to the family of the person in it, notices have gone up on walls in {actorDistrict} and well beyond. IF YOU HAVE THE BOOK OF... and a name, and an address, and sometimes a photograph. There are a lot of notices on your street.",
		weight = 12,
		once = true,
		tags = { "library" },
		when = { chronicle = "lib_book_returned", world = { era = { "library", "limbus" } }, minAge = 12 },
		choices = {
			{
				label = "Return the Library book you have",
				requires = { flags = { "lib_book_owner" } },
				result = { sanity = 8, loseGear = "lib_library_book", clearFlags = { "lib_book_owner" }, chronicle = "lib_book_returned", log = "The name on your book's spine was on the third notice down. You took it to the address that night. The door opened before you knocked." },
			},
			{
				label = "Help copy notices for the families",
				result = { intelligence = 2, sanity = 2, log = "You spent a week copying notices in your neatest handwriting. Each family told you about the person they were looking for, and you remember every one of them." },
			},
			{
				label = "Read every notice on your street",
				result = { mind = 2, sanity = -2, log = "You read them all. You recognized two of the names: a courier, and a girl from your old academy. You didn't know they had gone in. You hadn't asked." },
			},
		},
	},
}
