--[[
	The Archive: lore entries a player finds through their lives (kept across lives).
	{ id, category, title, text, secret }. Categories are listed in init.luau (pack.codex).
	Written in-world, in our own words; canon facts follow docs/CANON.md.
]]

return {
	-- ── the City ──
	{
		id = "city_basics",
		category = "city",
		title = "The City",
		text = "One city, twenty-six Districts. Each District was given to a Wing: a megacorporation that owns a Singularity, a technology nobody else is allowed to make. The Head rules from District 1 and sets the Taboos. Nobody you know has ever seen the Head.\n\nInside each District is a Nest, walled and watched. Outside the Nest are the Backstreets, where most people live. Beyond the City are the Outskirts, and you don't go there.",
	},
	{
		id = "city_sweepers",
		category = "city",
		title = "The Night in the Backstreets",
		text = "Every night at 3:13, the Sweepers rise out of the ground along the Nest walls and walk the Backstreets for eighty minutes, in three waves. They clean. Bodies, illegal buildings, anyone caught outside.\n\nDuring the Night it is forbidden to record anything, or to break into someone else's home. A locked door is the safest place in the City. Every Backstreets child learns one rule before any other: be home before three.",
	},
	{
		id = "city_white_nights",
		category = "city",
		title = "The White Nights and Dark Days",
		text = "In L Corp's last year a pillar of light rose from its tower in District 12 and spread over the whole City. For three days there was no night, and people say nobody died. Then it went out, and for four days there was no day.\n\nWhen it was over, L Corp was gone. Its facilities sealed and sank, its Wing's seat stood empty, and District 12 fell into chaos. Almost everyone alive then remembers where they were.",
	},

	-- ── terms ──
	{
		id = "terms_distortion",
		category = "terms",
		title = "Distortions",
		text = "Some people, pushed to an emotional extreme, turn into something else: a Distortion. Not everyone at the edge distorts, so nobody is sure what tips it. They can be killed, which is more than you can say for some things.\n\nIt started after the Light failed; in the Age of L Corp nobody had the word, because it didn't happen. People who Distort hear a kind voice first. Fixers treat it like a disease with stages. Some Distortions warp a whole street around them.",
	},
	{
		id = "terms_ego",
		category = "terms",
		title = "E.G.O",
		text = "Every person has a shape their despair wants to take. Most never see it. Since the Light, a few at the very edge hear a voice offer them that shape, look at the whole of it, and refuse. What they come back holding is called E.G.O: a weapon, a coat, a light, made of the thing that nearly ate them.\n\nIt keeps the voice out for good. Letting it out in a fight costs Sanity, and the stronger the mind, the less. A refusal that isn't whole leaves something else: a volatile E.G.O.\n\n(L Corp used the same word for the gear it drew out of Abnormalities. Whether that's a coincidence, nobody who'd know is saying.)",
	},
	{
		id = "terms_ahn",
		category = "terms",
		title = "Ahn",
		text = "The City's money. Fixers don't work for free, protection is paid for, and better bodies are bought. Prosthetics, ampules, Nest residence: everything has a price in Ahn, and the price is always a little more than you have.",
	},

	-- ── Districts and Wings ──
	{
		id = "districts_w_corp",
		category = "districts",
		title = "W Corp and the WARP trains",
		text = "District 23 belongs to W Corp, the WARP Corporation. Its trains cross the City in seconds. Tickets are expensive. The cleanup crews who board after every run are well paid, and never say what they cleaned.",
	},
	{
		id = "districts_warp_secret",
		category = "districts",
		title = "What the cleanup crews clean",
		text = "A trip on the WARP train takes seconds for anyone watching from outside. For the passengers inside, it is much, much longer. First Class sleeps through it. Everyone else does not. The cleanup crews board after every run to deal with what's left, and then every passenger is put back exactly as they boarded, with nothing of the trip left in their heads. They step off sure it was ten seconds. That is why nobody outside W Corp knows, and why the crews are paid not to say.",
		secret = true,
	},

	-- ── the Fingers ──
	{
		id = "fingers_thumb",
		category = "fingers",
		title = "The Thumb",
		text = "One of the Five Fingers, the great Syndicates of the Backstreets. The Thumb lives by propriety: rank, title and respect, in exact detail. Soldati, Capi, the Sottocapo above them. They carry guns, and bullets are expensive, so a Thumb soldier thinks before shooting. Disrespect, even one wrong word, is punished.",
	},

	{
		id = "fingers_index",
		category = "fingers",
		title = "The Index",
		text = "The Finger of faith. Its members follow Prescripts: orders written on slips of paper, delivered by Messengers, obeyed without question. Some Prescripts are terrible. Some are only strange: buy a red umbrella at noon, give it to the third stranger who passes. Nobody knows who writes them.",
	},

	-- ── Fixers ──
	{
		id = "fixers_hana",
		category = "fixers",
		title = "The Hana Association",
		text = "The first of the twelve Fixer Associations. Hana runs the Fixer system itself: it tests and licenses Fixers, grades them from 9 up to 1, sets the hazard levels for threats, and grants the Colors, titles every Fixer dreams of. Every Fixer belongs to an Office or an Association. Hana belongs to itself.",
	},

	-- ── Lobotomy Corporation ──
	{
		id = "lcorp_abnormalities",
		category = "lobotomy",
		title = "What L Corp keeps",
		text = "Lobotomy Corporation keeps Abnormalities in containment units deep under District 12: impossible things born out of human minds. Defeated, they don't die; they go back into something like an egg. L Corp's agents work with them every day, and from that work comes Enkephalin, the green energy that runs half the City.",
	},
	{
		id = "lcorp_work_types",
		category = "lobotomy",
		title = "The four kinds of work",
		text = "An L Corp agent works with an Abnormality in one of four ways: Instinct (feeding, cleaning, physical care), Insight (study and observation), Attachment (play and company), and Repression (force). Every Abnormality prefers some kinds of work and hates others. Getting it wrong is how agents die.",
	},
	{
		id = "lcorp_enkephalin",
		category = "lobotomy",
		title = "Enkephalin",
		text = "A glowing green energy. L Corp drew it out of the Abnormalities in its care and sold it to the City. Research teams measured yields, tested work types, and kept careful logs. Nobody outside the facility asked what the energy really was, and inside it, people learned not to.",
		secret = true,
	},
	{
		id = "lcorp_fall",
		category = "lobotomy",
		title = "The fall of L Corp",
		text = "At the end, there was a pillar of light. The facility sealed itself, the branches sank under the streets, and Lobotomy Corporation stopped existing. Its slot among the Wings is still empty. Some of what it kept is still down there.",
	},

	-- ── the Library ──
	{
		id = "library_tower",
		category = "library",
		title = "The Library",
		text = "A tower that appeared where L Corp's headquarters had stood. It sends invitations, promising each guest whatever they desire most. Inside, guests are received by Librarians. Guests who lose become books.",
	},
	{
		id = "library_invitations",
		category = "library",
		title = "Invitations",
		text = "Cream envelopes, heavy paper, handwriting nobody recognizes. Fixers, Syndicates and ordinary people all received them. Some went for the prize. Some went because they were told to. Some never came back.",
	},
	{
		id = "library_books",
		category = "library",
		title = "Books",
		text = "When a guest loses in the Library, what's left of them is a book. The books hold their skills, their memories, sometimes their power. People who walked out of the Library carrying one found that the City would pay almost anything for it.",
		secret = true,
	},

	-- ── Limbus Company ──
	{
		id = "limbus_company",
		category = "limbus",
		title = "Limbus Company",
		text = "In the Distortion era, a company called Limbus deals in what L Corp left behind. It searches the buried branches for Golden Boughs and sells Distortion management to anyone who can pay. Its bus, they say, carries a very strange crew.",
	},
}
