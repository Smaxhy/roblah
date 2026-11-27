--[[
	GLOSSARY: City words worth one plain line. When a card's words use one, the card offers a
	"What's that?" chip (the first two times a life meets the word).

	{ term = "Wing", match = { "Wing's" }, mid = { "Wing", "Wings" }, text = "one sentence" }
	(with curly brackets, as below)

	match: NAMES.
	  - a piece written with a CAPITAL (or a digit) must appear exactly as written, as a whole
	    word. "the Middle" is the Finger; "the middle of it" is not. It is looked for anywhere
	    in the card's body, and in its headline too unless it leans on an article ("the Head":
	    a headline capitalises every word, and "The Head Teacher" is a teacher).
	  - a piece in all lowercase is loose (any case, any part of a word). Only for words that
	    never mean anything else here ("backstreets", "enkephalin").
	mid: ordinary words that are a name only when they wear a capital INSIDE a sentence
	  ("joined a Wing", "the Office took it"). Never looked for in a headline, and never counted
	  as the first word of a sentence ("Sweepers get a free lesson" is children with brooms).
	No list at all: the term itself, as a name.

	A card that is about something its words never name can say so: terms = { "Sweepers" } on
	the event (Engine/Validate checks the names).

	Order matters: at most three chips a card, the first three that match.
	tests/tags_check lists what every card would show; run it after changing this file.
]]

return {
	{ term = "The Night", match = { "3:13", "the Night", "THE NIGHT", "the Sweepers", "THE SWEEPERS", "The Night", "The Sweepers" }, mid = { "Sweeper", "Sweepers" }, text = "Every night from 3:13 to 4:34, Sweepers clear the Backstreets of anyone still outside. Indoors is safe." },
	{ term = "Sweepers", match = { "the Sweepers", "THE SWEEPERS", "Sweepers'", "The Sweepers" }, mid = { "Sweeper", "Sweepers" }, text = "The things that come out at 3:13. They take whoever is outdoors, and nobody sees those people again." },
	{ term = "Wing", match = { "Wing's", "Wings'" }, mid = { "Wing", "Wings" }, text = "One of the 26 corporations that own the City. Each has a District and a secret technology called a Singularity." },
	{ term = "Nest", match = { "Nest's" }, mid = { "Nest", "Nests" }, text = "The walled, clean part of a District, where a Wing's people live. Everyone else lives outside, in the Backstreets." },
	{ term = "Backstreets", match = { "backstreets", "Backstreet" }, text = "Everything outside the Nest walls: crowded, poor, and run by Syndicates rather than laws." },
	{ term = "Feather", match = { "Feather's" }, mid = { "Feather", "Feathers" }, text = "Someone employed by a Wing. A badge, a salary, a home in the Nest, and a Wing's protection." },
	{ term = "Fixer", match = { "Fixer", "Fixers", "Fixer's", "Fixers'", "FIXER", "FIXERS" }, text = "A licensed problem-solver for hire: guard, courier, detective, killer. Graded from 9 (new) up to 1." },
	{ term = "Office", match = { "Office's", "Offices'", "Fixer Office", "Fixer Offices" }, mid = { "Office", "Offices" }, text = "A small company of Fixers who take contracts together. Most have fewer than ten people." },
	{ term = "Association", match = { "Association", "Associations", "Association's", "ASSOCIATION", "Zwei", "Shi", "Liu", "the Seven", "Cinq", "Dieci", "Devyat", "Devyat'", "Oufi", "Öufi", "The Seven" }, text = "The twelve big Fixer organizations, each with a specialty: Zwei protects, Shi kills, Liu wages war, Seven investigates." },
	{ term = "Hana", match = { "Hana", "Hana's", "HANA" }, text = "The Association above the others. It licenses every Fixer, sets their Grade, and names the Colors." },
	{ term = "Grade", match = { "Grade 1", "Grade 2", "Grade 3", "Grade 4", "Grade 5", "Grade 6", "Grade 7", "Grade 8", "Grade 9", "GRADE 9" }, mid = { "Grade", "Grades" }, text = "A Fixer's rank, from 9 (just licensed) to 1. Above Grade 1 there are only the Colors." },
	{ term = "Color", match = { "Color Fixer", "Color Fixers", "COLOR FIXER", "Color's", "the Colors", "The Colors" }, mid = { "Color", "Colors" }, text = "A title Hana gives the few Fixers too strong to grade. The Red Mist was one: long dead, and an urban legend now. Each is worth an army." },
	{ term = "Syndicate", match = { "Syndicate", "Syndicates", "Syndicate's", "syndicate" }, text = "A criminal organization. Small ones hold a few streets; the biggest five are the Fingers." },
	{ term = "The Fingers", match = { "the Fingers", "the Five Fingers", "Finger's", "Fingers'", "The Fingers", "The Five Fingers" }, mid = { "Finger", "Fingers" }, text = "The five Syndicates that rule the Backstreets: the Thumb, the Index, the Middle, the Ring and the Pinky." },
	{ term = "The Thumb", match = { "the Thumb", "Thumb's", "THE THUMB", "The Thumb" }, text = "A Finger built on rank and manners. Speak out of turn to a superior and you pay for it." },
	{ term = "Capo", match = { "Capo", "Capos", "Capo's", "Soldato", "Soldatos", "Sottocapo", "Sottocapos", "Underboss" }, text = "Thumb ranks. Soldato is a soldier, Capo commands them, Sottocapo commands a region." },
	{ term = "The Index", match = { "the Index", "Index's", "THE INDEX", "The Index" }, text = "A Finger that follows Prescripts. Its Proxies carry out whatever the letters say, however strange." },
	{ term = "Prescript", match = { "Prescript", "Prescripts", "Prescript's" }, text = "An order from the Index, delivered by letter. It can ask for anything, and it must be done exactly." },
	{ term = "Proxy", match = { "Proselyte", "Proselytes", "Proxy's", "Messenger's" }, mid = { "Proxy", "Proxies", "Messenger", "Messengers" }, text = "Index ranks. Proselytes obey Prescripts, Proxies enforce them with blades, Messengers deliver them." },
	{ term = "The Middle", match = { "the Middle", "Middle's", "THE MIDDLE", "Little Brother", "Little Brothers", "Little Sister", "Little Sisters", "Little Sibling", "Little Siblings", "Big Brother", "Big Brothers", "Big Sister", "Big Sisters", "Big Sibling", "Big Siblings", "Younger Brother", "Younger Sister", "Older Brother", "Older Sister", "The Middle" }, text = "A Finger that calls itself a family. Wrong one member and the whole family repays it, with interest." },
	{ term = "The Pinky", match = { "the Pinky", "Pinky's", "THE PINKY", "The Pinky" }, text = "The fifth Finger, and the one nobody can describe. Whoever works for it never says so." },
	{ term = "The Ring", match = { "the Ring", "Ring's", "THE RING", "Maestro", "Maestros", "Docent", "Docents", "The Ring" }, text = "A Finger of artists who use people as material. An invitation to their exhibition is bad news." },
	{ term = "Rats", match = { "the Rats", "Rats'", "The Rats" }, mid = { "Rats", "Rat" }, text = "The lowest street gangs of the Backstreets. They rob whoever looks weak and answer to nobody." },
	{ term = "Workshop", match = { "Workshop", "Workshops", "Workshop's", "workshop" }, text = "A weapon maker's shop. The good ones sign their work; a Fixer's blade says who they can afford." },
	{ term = "Ahn", match = { "Ahn" }, text = "The City's money. A bowl of noodles is a few Ahn; a month's rent is a few hundred." },
	{ term = "District", match = { "District", "Districts", "District's" }, text = "The City has 26 Districts, each owned by one Wing and named by a number or the Wing's letter." },
	{ term = "Singularity", match = { "Singularity", "Singularities" }, text = "A Wing's impossible technology, protected by law. It is why each Wing is rich, and why it stays that way." },
	{ term = "The Head", match = { "the Head", "Head's", "THE HEAD", "Arbiter", "Arbiters", "Arbiter's", "the Claws", "the Eye", "Beholder", "Beholders", "The Head", "The Claws", "The Eye" }, mid = { "Claw", "Claws" }, text = "The rulers above the Wings. The Eye watches, the Arbiters judge, the Claws carry out the sentence." },
	{ term = "Taboo", match = { "Taboo", "Taboos" }, text = "The Head's few laws, like the ban on guns that fire too far. Breaking one brings the Claws." },
	{ term = "L Corp", match = { "L Corp", "L Corp's", "Lobotomy Corporation", "Lobotomy Corp" }, text = "Lobotomy Corporation, the Wing of District 12. It makes the City's energy from Abnormalities it contains underground." },
	{ term = "Abnormality", match = { "Abnormality", "Abnormalities", "Abnormality's" }, text = "A creature born from the human mind, kept in a cell by L Corp. Each has rules. Break them and it gets out." },
	{ term = "Enkephalin", match = { "enkephalin" }, text = "The green energy L Corp extracts from Abnormalities. It powers the City." },
	{ term = "E.G.O", match = { "E.G.O" }, text = "A weapon or armor drawn out of a mind. Some come from Abnormalities; a rare person manifests their own." },
	{ term = "Distortion", match = { "Distortion", "Distortions", "Distortion's", "DISTORTION" }, mid = { "Distort", "Distorts", "Distorted", "Distorting" }, text = "A person who broke and became a monster shaped like their own despair. It started after the White Nights." },
	{ term = "White Nights", match = { "White Nights", "White Night", "Dark Days", "the Light", "The Light" }, text = "Three days of light, then four of darkness, when L Corp fell. Distortions began afterwards." },
	{ term = "W Corp", match = { "W Corp", "W Corp's", "WARP" }, text = "The Wing of District 23. Its WARP trains cross the City in ten seconds. Passengers aren't told how." },
	{ term = "K Corp", match = { "K Corp", "K Corp's", "ampule", "ampoule" }, text = "The Wing of District 11. Its healing ampules can close almost any wound, for a price." },
	{ term = "R Corp", match = { "R Corp", "R Corp's", "Fourth Pack", "Rabbit Team", "Reindeer Team", "Rhino Team" }, mid = { "Rabbit", "Rabbits", "Reindeer", "Rhino", "Rhinos" }, text = "The Wing of District 18. It rents out armies: the Rabbit, Reindeer and Rhino teams of its Fourth Pack." },
	{ term = "T Corp", match = { "T Corp", "T Corp's" }, text = "The Wing of District 20. It collects and sells time itself. In its Backstreets, a day can cost you years." },
	{ term = "H Corp", match = { "H Corp", "H Corp's", "Hongyuan", "Daguanyuan" }, text = "The Wing of District 8, ruled from Hongyuan by old families. A family's fortune there can be measured in rooms." },
	{ term = "S Corp", match = { "S Corp", "S Corp's", "King's Court" }, text = "The Wing of District 19. A king's court of rigid classes; people who run from it are hunted." },
	{ term = "Smoke War", match = { "Smoke War" }, text = "The old war between Wings that left District 7 in ruins. Its veterans don't talk about it." },
	{ term = "Outskirts", match = { "Outskirts" }, text = "The wasteland beyond the City. No law, no Wings, and things that were never people." },
	{ term = "Bloodfiend", match = { "Bloodfiend", "Bloodfiends", "Bloodfiend's", "Kindred", "Hardblood", "Hemobar", "Hemobars" }, text = "People who must drink blood to live. They belong to Families, shape their blood into weapons, and hide in plain sight." },
	{ term = "Limbus Company", match = { "Limbus", "Mephistopheles" }, mid = { "Sinner", "Sinners" }, text = "A company that crosses the City by bus with twelve Sinners, collecting Golden Boughs." },
	{ term = "Golden Bough", match = { "Golden Bough", "Golden Boughs" }, mid = { "Bough", "Boughs" }, text = "A glowing branch left where an L Corp branch stood. It grants wishes badly. Many people want them." },
	{ term = "The Library", match = { "the Library", "Library's", "THE LIBRARY", "The Library" }, mid = { "Librarian", "Librarians" }, text = "It appeared where L Corp fell. Guests who accept its invitation fight for a book; those who lose become one." },
	{ term = "Peccatula", match = { "peccatul" }, text = "Small sin-creatures that hatch where a Golden Bough has been. Pests that bite." },
	{ term = "Kurokumo Clan", match = { "Kurokumo", "Wakashu" }, text = "A sword clan from the old days that now works as Thumb muscle. Its young members are called Wakashu." },
	{ term = "Blade Lineage", match = { "Blade Lineage" }, text = "Wandering swordsmen who lost their homeland and kept only the blade. They sell their skill to whoever pays." },
}
