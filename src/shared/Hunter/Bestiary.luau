--[[
	THE BESTIARY (BitLeveling): what each monster of the live city is, where it comes from, how it
	fights and how it's beaten. Bodies and numbers are Hunter/Monsters.luau; this is the lore.

	CANON vs ORIGINAL. Solo Leveling's Gates have goblins, orcs and high orcs, ice elves (the Snow
	Folk) and ice bears, giants, giant ants, lizardmen, naga, golems, wyverns and dragons, demons
	and undead-like knights as monster TYPES. A family marked canon = true is one of those types,
	in this game's own designs and its own Gates: never a canon named individual (no Ant King or
	Queen, no Red Gate boss, no Demon Castle gatekeeper, no Monarch, no shadow soldier), and never
	a canon incident (Jeju's ants and Tokyo's giants stay with their own stories). Everything else
	is ORIGINAL to this game, and says so: kobolds, dwarves, forest and dark elves, lycans (not the
	System's steel-fanged ones), treants, the three-headed hounds (not the Demon Castle's)...

		Bestiary.FAMILIES[id]   { name, canon, note, habitat, behaviour, weakness, text }
		Bestiary.KINDS[kind]    { text, canon? (overrides the family's) }
		Bestiary.entry(kind)    everything about one kind, with its name, rank and numbers
]]

local Bestiary = {}

Bestiary.FAMILIES = {
	goblins = {
		name = "Goblins", canon = true,
		note = "Canon type: goblins fill the low-rank Gates of the story's first raids. These tribes, and their shamans, riders and warbosses, are this game's own.",
		habitat = "E and D Gates: warrens, limestone caves, the rotted timber forts they build inside a dungeon.",
		behaviour = "A pack: grunts in front, an archer or two behind, a shaman keeping the rest alive, a warboss shouting at all of them.",
		weakness = "Kill the shaman first. A goblin pack without its healer breaks after the first two go down.",
		text = "Small, green, quick and spiteful. Alone, a goblin is something a careful E-rank handles with a pipe. They are never alone.",
	},
	kobolds = {
		name = "Kobolds", canon = false,
		note = "ORIGINAL: kobolds are not in Solo Leveling. This game's kobolds are small reptile-headed miners of the crystal Gates.",
		habitat = "E and D Gates: crystal-lined mines and the tunnels under them.",
		behaviour = "A swarm that digs. Tunnelers come up under you, slingers and trappers throw from the tunnel mouths, a foreman with a whip keeps them at it.",
		weakness = "They panic in the open. Pull them out of the tunnels and they scatter.",
		text = "Waist-high, rust-scaled, horned like little goats. Kobolds strip a Gate's crystal faster than any mining crew, and they defend a seam as if it were their young.",
	},
	vermin = {
		name = "Cave Vermin", canon = false,
		note = "ORIGINAL: the rats, bats and crawlers of low-rank cave Gates.",
		habitat = "E and D Gates: caves, sewers, the dark corners of every dungeon.",
		behaviour = "Swarms. Bats drop from the ceiling, rats come in waves, crawlers jump.",
		weakness = "Light and noise. Most of them are only brave in the dark.",
		text = "Every Gate has its vermin: things that live on what the bigger monsters leave. Raid teams kill them by the hundred and nobody counts.",
	},
	orcs = {
		name = "Orcs", canon = true,
		note = "Canon type: orcs are a common middle-rank Gate monster. These war bands and their shamans and berserkers are this game's own.",
		habitat = "C and B Gates: war camps, black stone mazes, the forts of a dungeon's second sky.",
		behaviour = "A war band: axe-armed warriors, archers on the flanks, a shaman throwing fire and patching wounds, berserkers who stop feeling pain, a warchief in front.",
		weakness = "Discipline. Orcs charge; a held line and a Tanker's provoke break the charge before it lands.",
		text = "Big, green-grey, tusked, and they fight as a band. A C-rank team that treats an orc war band like a goblin pack doesn't come home.",
	},
	high_orcs = {
		name = "High Orcs", canon = true,
		note = "Canon type: high orcs, and high orc shamans, are A-rank Gate monsters in the story. These warriors and their warlord are this game's own; no canon individual is among them.",
		habitat = "B and A Gates: fortress dungeons, war-camps under a red sky.",
		behaviour = "Elite war bands. Shamans call lightning and ward their warriors; berserkers charge; the warlord's war cry makes all of them faster and harder to stop.",
		weakness = "Their shamans. A high orc band with its shaman down is still deadly, but it can be outlasted.",
		text = "Taller than orcs, darker, armoured in iron, painted for war. They plan. They retreat to draw you in. Many raid teams have learned that the hard way.",
	},
	ogres = {
		name = "Ogres", canon = false,
		note = "ORIGINAL: ogres are this game's own.",
		habitat = "B and A Gates: caverns, hill forts, the ruins of something older than them.",
		behaviour = "Brutes. They slam the ground, hurl rocks, and the two-headed ogre mages freeze whatever their kin miss.",
		weakness = "Slow. Fight them where they can't reach you and they have only the rocks.",
		text = "Fat, enormous, and stronger than they look, which is very strong. An ogre hits like a falling wall.",
	},
	trolls = {
		name = "Trolls", canon = false,
		note = "ORIGINAL: trolls are this game's own.",
		habitat = "D to A Gates: caves, bogs, the frozen Gates (frost trolls).",
		behaviour = "Brutes that heal. A troll left alone for a few seconds closes its own wounds.",
		weakness = "Keep hitting it. A troll only mends when nothing has hurt it for a moment.",
		text = "Long-armed, hunched, long-nosed. Trolls are not clever and do not need to be: they get back up.",
	},
	giants = {
		name = "Giants", canon = true,
		note = "Canon type: giants come out of the story's S-rank Gate in Tokyo, a canon incident that stays its own. These hill, stone and frost giants are this game's own, from other Gates.",
		habitat = "B to S Gates: mountainsides, frozen plains, the biggest caverns a dungeon has.",
		behaviour = "Brutes the size of buildings. They stomp, throw boulders, and the frost giants freeze the ground around them.",
		weakness = "Their size. A giant can't see what's at its ankles, and it turns slowly.",
		text = "A giant is a city-block problem. When one comes out of a Gate, the Association closes the district before it asks anything else.",
	},
	ice_elves = {
		name = "Ice Elves", canon = true,
		note = "Canon type: the ice elves (the Snow Folk) are the monsters of the story's Red Gate. These hunters, mages and their warchief are this game's own; the Red Gate's boss is not among them.",
		habitat = "B to S Gates: frozen worlds, snowfields under a white sun, the frozen Gates that turn red.",
		behaviour = "Hunters. Scouts come fast and vanish, archers rain frost arrows, frost-mages freeze the ground, priestesses ward and heal, the warchief leads the hunt.",
		weakness = "They fight as one hunt. Break their line of sight to each other and the hunt falls apart.",
		text = "Pale as snow, tall and slender, long ears, eyes like ice in sunlight. Ice elves hunt Hunters the way Hunters hunt monsters: patiently, and for food.",
	},
	forest_elves = {
		name = "Forest Elves", canon = false,
		note = "ORIGINAL: forest elves are this game's own.",
		habitat = "D to B Gates: dark forests under a second sky, overgrown ruins.",
		behaviour = "Rangers and wardens. Archers volley from the trees, wardens close with twin blades, druids heal them and call up vines.",
		weakness = "Fire, and the open. Away from the trees they are only very good archers.",
		text = "Green leather, long ears, longer bows. Nobody knows if they are defending their forest or only their Gate. They don't talk to Hunters.",
	},
	dark_elves = {
		name = "Dark Elves", canon = false,
		note = "ORIGINAL: dark elves are this game's own.",
		habitat = "B to S Gates: lightless caverns, spider-haunted temples.",
		behaviour = "Assassins and sorcerers. Stalkers step out of shadows behind you, arbalests shoot from the dark, sorceresses drain the life out of you, the matriarch calls her spiders.",
		weakness = "Light. Flood the room and they lose half their tricks.",
		text = "Dusky grey skin, white hair, violet eyes. They keep giant spiders the way people keep dogs.",
	},
	dwarves = {
		name = "Dwarves", canon = false,
		note = "ORIGINAL: dwarves are not in Solo Leveling. This game's dwarves are the silent miners of the deep crystal Gates.",
		habitat = "D to A Gates: deep mines, rune-carved halls, forges that never go out.",
		behaviour = "Miners burrow, axe-guards hold a shield wall, thunderers throw blasting charges, runesmiths ward the line, a forge-lord leads with a hammer that sets the ground on fire.",
		weakness = "The shield wall turns: hit it from the side.",
		text = "Short, broad, braided beards, iron helmets. They look like dwarves out of a storybook, but they never speak, and they defend a crystal seam to the last.",
	},
	lizardfolk = {
		name = "Lizardmen", canon = true,
		note = "Canon type: lizardmen are a Gate monster in the story. These tribes, their shamans, croc-headed guards and bog toads are this game's own (the toads ORIGINAL).",
		habitat = "D to B Gates: swamps that smell of copper, flooded ruins.",
		behaviour = "Skirmishers throw javelins, warriors sweep with tail and spear, shamans spit poison and heal, croc-headed guards hold the line; the tribes keep bog toads.",
		weakness = "The cold. Lizardmen slow down when it's cold.",
		text = "Scaled, upright, with tails that hit as hard as their spears. They fight in the water if they can.",
	},
	naga = {
		name = "Naga", canon = true,
		note = "Canon type: naga appear among the story's Gate monsters. These sirens, four-armed myrmidons and tidecallers are this game's own.",
		habitat = "C to A Gates: flooded temples, sunken ruins, black-water caverns.",
		behaviour = "A naga's tail is as dangerous as its spear. Sirens shriek and heal, myrmidons fight with four blades, a tidecaller leads.",
		weakness = "Get off the water's edge. On dry stone they are slower than they look.",
		text = "A body like a person's above, a serpent's below, a cobra's hood around the head. They sing to each other in the dark.",
	},
	ants = {
		name = "Giant Ants", canon = true,
		note = "Canon type: giant ants overran Jeju Island from an S-rank Gate in the story, a canon incident that stays its own. These smaller colonies, in other Gates, are this game's own; there is no Ant King or Queen among them (the Hive Matron boss is ORIGINAL).",
		habitat = "D to A Gates: nests in red sand, tunnels under a dungeon's floor.",
		behaviour = "A colony: workers tunnel and swarm, soldiers charge with mandibles, spitters shoot acid, winged ants dive, royal guards plate themselves.",
		weakness = "Find the nest's centre. A colony without its guards falls back to protect it.",
		text = "The size of dogs, then of cars, then bigger. Every Hunter in Korea knows what ants can do to an island. These colonies are smaller. Nobody relaxes.",
	},
	beetles = {
		name = "Beetles", canon = false,
		note = "ORIGINAL: the armoured beetles of the mine Gates are this game's own.",
		habitat = "E to C Gates: mines, deserts of red sand, crystal caves.",
		behaviour = "Armoured brutes that charge, scarabs that swarm and burrow, bombardiers that spray scalding liquid.",
		weakness = "The joints under the shell, and the belly.",
		text = "Shells like plate armour, some glowing with the crystal they eat. Their shells sell well, after.",
	},
	mantises = {
		name = "Mantises", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "C to A Gates: overgrown ruins, jungles under a green sky.",
		behaviour = "Ambush hunters: still, then not. They leap, cut, and the ghost mantis steps out of nowhere.",
		weakness = "Patience. A mantis that misses its first strike is exposed.",
		text = "Folded scythes, triangular heads, and absolutely no hurry until they move.",
	},
	centipedes = {
		name = "Centipedes and Wyrms", canon = false,
		note = "ORIGINAL: this game's own (the System's penalty-zone centipedes are not these).",
		habitat = "D to S Gates: tunnels, deserts, the sand seas of the deepest Gates.",
		behaviour = "Burrowers: under the ground, then up beneath you. The sand wyrm splits the street with a quake.",
		weakness = "Keep moving. They come up where you were standing.",
		text = "Hundreds of legs, or none at all. You hear them before you see them, if you're listening.",
	},
	scorpions = {
		name = "Scorpions", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "D to A Gates: red deserts, sun-baked ruins.",
		behaviour = "Pincers to hold, a tail to sting. The emperor scorpion spits venom and shells up.",
		weakness = "Behind it. A scorpion turns slowly.",
		text = "The tail comes over the back faster than you expect, every time.",
	},
	spiders = {
		name = "Spiders", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "E to B Gates: webbed caves, dark forests, temples nobody tends.",
		behaviour = "Webs, ambushes, swarms of spiderlings; weavers call more of them; phase spiders blink across a room.",
		weakness = "Fire, and cutting the web before you walk into it.",
		text = "Eight legs, eight eyes, and a mark on the back that glows when it's hungry.",
	},
	wolves = {
		name = "Wolves", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "E to C Gates: forests, snowfields, the plains of a second sky.",
		behaviour = "A pack: fast, flanking, leaping. The alpha's howl drives them; frost wolves breathe ice.",
		weakness = "The alpha. Kill it and the pack hesitates.",
		text = "Grey wolves, dire wolves, frost wolves: the same hunt, at different sizes.",
	},
	bears = {
		name = "Bears", canon = true,
		note = "Canon type: ice bears are monsters of the story's Red Gate. These ice bears, cave bears and their alpha are this game's own (cave bears ORIGINAL).",
		habitat = "C to A Gates: caves, frozen worlds, the snowfields of a Red Gate.",
		behaviour = "Brutes: a charge, a slam, an alpha's roar; ice bears freeze the air around them.",
		weakness = "Their charge runs straight. Step aside.",
		text = "White as the snow they come out of, and twice the weight of a car.",
	},
	boars = {
		name = "Boars", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "E to C Gates: forests, farmland Gates, hill country.",
		behaviour = "Charges. Razorbacks go berserk when hurt; ironhide boars wear plate.",
		weakness = "A boar that has charged has to turn around.",
		text = "Tusks, bristles, a bad temper. Farm Gates leak boars more than anything else.",
	},
	great_cats = {
		name = "Great Cats", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "C to A Gates: jungles, storm plains, dusk forests.",
		behaviour = "Stalkers: a pounce from cover, a sabre bite, a thunder tiger's lightning.",
		weakness = "They hunt alone. Stand together.",
		text = "Black panthers you can't see at dusk, sabre cats, and tigers that crackle with storm.",
	},
	lycans = {
		name = "Lycans", canon = false,
		note = "ORIGINAL type: this game's lycans are not the System's steel-fanged ones.",
		habitat = "B and A Gates: moonlit forests, ruined villages under a second sky.",
		behaviour = "Wolf-headed hunters on two legs: a leap, a howl, and a packmaster who frenzies when hurt.",
		weakness = "Whatever the old stories say about silver, they bleed like anything else. Outlast the frenzy.",
		text = "A wolf that learned to stand. Lycans hunt in packs, and the packmaster remembers faces.",
	},
	harpies = {
		name = "Harpies and Birds", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "D to A Gates: cliffs, ruined towers, storm skies.",
		behaviour = "Fliers: dives from above, shrieks that shake you, a thunderbird's lightning.",
		weakness = "Ranged attacks, and a roof.",
		text = "Feathered wings, talons, and a scream you feel in your teeth.",
	},
	drakes = {
		name = "Wyverns and Drakes", canon = true,
		note = "Canon type: wyverns appear in the story. These wyverns, hatchlings, fire drakes and storm wyverns are this game's own (the drakes ORIGINAL).",
		habitat = "C to S Gates: mountain peaks, volcanic Gates, storm skies.",
		behaviour = "Fliers and brutes: dives, stinging tails, fire and storm.",
		weakness = "Their wings. Ground one and it's half the threat.",
		text = "Two legs and two wings: a wyvern is not a dragon. It doesn't need to be.",
	},
	dragonkin = {
		name = "Dragon-kin", canon = true,
		note = "Canon type: dragons are the race of the Monarch of Destruction. These dragon-kin are lesser, and this game's own; no named dragon is among them.",
		habitat = "A and S Gates: volcanic Gates, the deepest S-rank dungeons.",
		behaviour = "Fire and armour: breath that melts plate, tail sweeps, knights in black scale, flamecallers who drop meteors.",
		weakness = "None worth counting on. Bring more Hunters.",
		text = "Black scales, burning eyes. Dragon-kin are what the Association means when it says a Gate 'reads S'.",
	},
	golems = {
		name = "Golems", canon = true,
		note = "Canon type: golems are Gate monsters in the story. These mud, iron, crystal, stone and magma golems and the colossus are this game's own.",
		habitat = "E to S Gates: ruins, mines, the halls of whatever built them.",
		behaviour = "Brutes: slams, thrown boulders, quakes, and a stony guard that nothing gets through.",
		weakness = "The glowing core. Everything else is just stone.",
		text = "Nobody knows who builds golems inside a Gate. They guard something. They keep guarding it after it's gone.",
	},
	elementals = {
		name = "Elementals", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "E to S Gates: mana-saturated caverns, volcanic, frozen and storm Gates.",
		behaviour = "Casters: bolts, novas, lightning, meteors, with their element circling them.",
		weakness = "The core inside the element. Hit that, not the fire.",
		text = "Mana that took a shape: a wisp, a fire, a block of living ice, a storm with eyes.",
	},
	slimes = {
		name = "Slimes", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "E to B Gates: caves, sewers, crystal pools.",
		behaviour = "They split when hurt, spit acid, burn; a crowned slime calls more of them.",
		weakness = "The nucleus. Pop that and the jelly is just jelly.",
		text = "A wobbling ball of mana-jelly with a bright core. Children's cartoons make them cute. They are not cute.",
	},
	undead = {
		name = "The Restless Dead", canon = false,
		note = "ORIGINAL, apart from the undead-like knights (a canon type: armoured knights that serve in a dungeon). Skeletons, wraiths, liches and the Hollow King are this game's own; never shadow soldiers.",
		habitat = "E to S Gates: crypts, sunken archives, throne rooms of empty kingdoms.",
		behaviour = "Skeletons with shields and bows, mages, gaunt ghouls, wraiths that drain, grave knights, and liches that raise more of them.",
		weakness = "Light, and breaking whatever holds them together.",
		text = "Bones and cold light. Whatever kingdom these were, it was inside the Gate, and it ended a long time ago.",
	},
	demons = {
		name = "Demons", canon = true,
		note = "Canon type: demons are monsters of a demon dungeon in the story. These soldiers, knights, warlocks and nobles are this game's own designs; no canon demon lord or gatekeeper is among them.",
		habitat = "E to S Gates: castles of black stone, burning plains.",
		behaviour = "Imps throw fire, soldiers cleave, knights burn, warlocks drop meteors, a noble commands them all.",
		weakness = "Their pride: a demon noble fights its own battle and lets its soldiers die.",
		text = "Horns, burning eyes, iron and fire. Demons fight like an army, because that's what they are.",
	},
	hounds = {
		name = "Hell-hounds", canon = false,
		note = "ORIGINAL: this game's many-headed hounds are not the Demon Castle's gatekeeper.",
		habitat = "D to S Gates: burning plains, demon castles' outer walls.",
		behaviour = "Fire breath, leaps, howls; the more heads, the more fire.",
		weakness = "Every head breathes, but there is only one body.",
		text = "Black hounds with embers in their fur. The big ones have two heads, or three.",
	},
	plants = {
		name = "Living Plants", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "E to A Gates: dark forests, overgrown temples.",
		behaviour = "Mandrakes scream, vine lashers whip, spore shamblers poison the air, treants stomp and quake.",
		weakness = "Fire, of course.",
		text = "The forest inside a Gate is alive in a way the forest outside isn't.",
	},
	aquatic = {
		name = "The Deep", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "D to S Gates: flooded Gates, black seas inside a dungeon.",
		behaviour = "Merfolk with tridents, tidecallers, kraken spawn that lash and ink, and the abyssal serpent.",
		weakness = "Out of the water they bring with them, they tire.",
		text = "Some Gates open onto a sea. Something always comes up out of it.",
	},
	constructs = {
		name = "Constructs and Mimics", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "D to A Gates: vaults, treasure rooms, guarded halls.",
		behaviour = "Living armour guards, mimics wait, gargoyles dive, rune sentinels gaze.",
		weakness = "A mimic is a chest. Check chests.",
		text = "Things made to guard something. The treasure in a Gate's vault is sometimes the trap.",
	},
	minotaurs = {
		name = "Minotaurs", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "B to S Gates: labyrinths, maze dungeons of black stone.",
		behaviour = "Charges, axes, stomps; the champion's war cry.",
		weakness = "The charge. A minotaur that misses hits the wall.",
		text = "Bull-headed, axe-handed, and at home in a maze you are not.",
	},
	centaurs = {
		name = "Centaurs", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "C to A Gates: plains under a second sky.",
		behaviour = "Skirmishers throw javelins, archers volley, lancers charge.",
		weakness = "Close the distance; a centaur can't turn in a narrow street.",
		text = "Half horse, half rider, all hunter. They keep their distance until they don't.",
	},
	basilisks = {
		name = "Basilisks", canon = false,
		note = "ORIGINAL: this game's own.",
		habitat = "D to S Gates: deserts, stone ruins, caves.",
		behaviour = "A gaze that stiffens you, a tail that sweeps, spit; the cockatrice is small and vicious.",
		weakness = "Don't meet the gaze: step out of its line.",
		text = "Many-legged lizards with crests and eyes that make your limbs heavy.",
	},
}

-- one line for every kind (and where a kind differs from its family on canon, it says so)
Bestiary.KINDS = {
	-- goblins
	goblin = { text = "The goblin every Hunter met first: a club, a grin, and twenty friends." },
	goblin_archer = { text = "Shoots from behind the others with a bow it stole or carved badly. It still hurts." },
	goblin_shaman = { text = "Feathers, a skull on a stick, and a mending chant. Kill it first." },
	hobgoblin = { text = "A bigger, drilled goblin with spear and shield. It holds the line and charges when told to." },
	goblin_wolfrider = { text = "A goblin on a dire wolf, spear down, coming fast. The wolf is the dangerous half." },
	goblin_warboss = { text = "The biggest goblin in the warren, in a horned helmet, with an axe it can barely lift. Its war cry makes the rest brave." },
	-- kobolds
	kobold = { text = "A kobold miner with a pick, in a swarm of others." },
	kobold_slinger = { text = "Throws crystal-ore stones with a sling, from the tunnel mouth." },
	kobold_tunneler = { text = "Wears a crystal lamp and digs under you." },
	kobold_trapper = { text = "Carries clay pots full of something that burns. Throws them." },
	kobold_foreman = { text = "Bigger, louder, with a whip. It doesn't fight much; it makes the others fight." },
	-- vermin
	giant_rat = { text = "A rat the size of a dog. They come in waves." },
	cave_bat = { text = "Drops from the ceiling in the dark." },
	cave_crawler = { text = "A pale cave cricket that jumps at your face." },
	shriek_bat = { text = "A bat with ears like sails. Its shriek knocks you off your feet." },
	-- orcs
	orc_scout = { text = "A lean, hooded orc with two knives that runs ahead of the band and comes at you from the side." },
	orc = { text = "An orc warrior with an axe: the backbone of every war band." },
	orc_archer = { text = "Shoots, then volleys the ground you're standing on." },
	orc_shaman = { text = "Throws fire and closes its warriors' wounds." },
	orc_berserker = { text = "Two axes, no armour, war paint. When it's hurt it gets faster." },
	orc_warchief = { text = "Armoured, horned, caped. It leads the charge, and its war cry carries." },
	-- high orcs
	high_orc = { text = "A high orc warrior: shield, axe, iron, and a plan." },
	high_orc_berserker = { text = "A high orc that has given up on armour and plans. It charges, slams and does not stop." },
	high_orc_shaman = { text = "Calls lightning down on you and wards its warriors from harm. A high orc shaman, not any particular one." },
	warlord = { text = "The High Orc Warlord: the band's war leader, an axe in one hand and the whole band behind it." },
	-- ogres
	ogre = { text = "Slams the ground and throws whatever's nearby." },
	ogre_mage = { text = "Two heads that argue, one staff that freezes you." },
	ogre_warlord = { text = "An ogre in plate with a spiked club, a war cry and a boulder for every Hunter." },
	-- trolls
	moss_troll = { text = "Overgrown and slow, and it mends while you catch your breath." },
	troll = { text = "The cave troll: long arms, a club, and wounds that close." },
	frost_troll = { text = "A white troll from the frozen Gates; the cold comes off it in waves." },
	troll_elder = { text = "An old troll with bones in its hair and a staff, that the others listen to." },
	-- giants
	giant_youngling = { text = "A young hill giant: only twice the height of a bus." },
	hill_giant = { text = "Stomps, and throws boulders the size of cars." },
	stone_giant = { text = "Grey as the mountain it came out of. It splits the ground." },
	frost_giant = { text = "Ice-blue, white-bearded, with an axe of ice. The ground freezes where it stands." },
	frost_giant_jarl = { text = "A crowned frost giant who breathes winter and leads others of its kind." },
	-- ice elves
	ice_elf_scout = { text = "Fast, hooded, two ice knives. It's behind you before you know it was there." },
	ice_elf_hunter = { text = "Hunts Hunters with a spear of ice and leaps from cover." },
	ice_elf_archer = { text = "Frost arrows, then a frost volley." },
	ice_elf_frostmage = { text = "Ice bolts, a frost nova, and a step through the snow." },
	ice_elf_priestess = { text = "Heals and wards the hunt. Find her first." },
	ice_elf_warchief = { text = "The hunt's leader: armoured in ice, with a war cry and an axe. An ice elf chieftain of this game's own, not the Red Gate's boss." },
	-- forest elves
	forest_elf_scout = { text = "A hooded archer in the trees." },
	forest_elf_warden = { text = "Twin blades and a leap: the forest's sword." },
	forest_elf_ranger = { text = "A longbow and volleys from cover." },
	forest_elf_druid = { text = "Heals the wardens and calls vines up out of the ground." },
	-- dark elves
	dark_elf_stalker = { text = "Steps out of the shadow behind you with two knives." },
	dark_elf_arbalest = { text = "A heavy crossbow from the dark, then a volley." },
	dark_elf_spellblade = { text = "A curved sword, a shadow step, a bolt of night." },
	dark_elf_sorceress = { text = "Drains the life out of you from across the room." },
	dark_elf_matriarch = { text = "The house's mother: a war cry, a drain, and her phase spiders." },
	-- dwarves
	dwarf_miner = { text = "Digs under you with a pick and a lamp." },
	dwarf_axeguard = { text = "Shield and axe, and a shield wall you can't get through from the front." },
	dwarf_thunderer = { text = "Throws blasting charges. Don't stand where it's looking." },
	dwarf_runesmith = { text = "Wards its kin with runes and calls lightning off its hammer." },
	dwarf_berserker = { text = "No helmet, two axes, a red mohawk, and it leaps." },
	dwarf_forgelord = { text = "The hall's lord: a hammer that slams fire into the ground, and the hall answers its war cry." },
	-- lizardfolk
	lizardman_skirmisher = { text = "Throws javelins and keeps its distance." },
	bog_toad = { canon = false, text = "A lizardfolk beast: a toad the size of a car with a tongue that hits like a whip (ORIGINAL)." },
	lizardman = { text = "A spear, a tail sweep, scales." },
	lizardman_shaman = { text = "Spits poison and heals its tribe." },
	lizardman_crocguard = { text = "A crocodile-headed guard with shield and club. It charges." },
	-- naga
	naga = { text = "A spear and a tail that sweeps your legs." },
	naga_siren = { text = "Its song is a shriek that knocks you back, and a mending for its kin." },
	naga_myrmidon = { text = "Four arms, four blades, a tail." },
	naga_tidecaller = { text = "Crowned in gold, calls the tide in shards of cold water, and leads." },
	-- ants
	ant_worker = { text = "Tunnels under you and comes up biting." },
	ant_soldier = { text = "A big head, bigger mandibles, and a charge." },
	ant_spitter = { text = "Shoots acid from a swollen abdomen." },
	winged_ant = { text = "Flies, dives, spits." },
	ant_royal_guard = { text = "Plated in gold-veined chitin, it shields and charges." },
	-- beetles
	scarab = { text = "Shiny, small, many, and they burrow." },
	beetle = { text = "Shell like plate armour, a glowing horn, a charge." },
	bombardier_beetle = { text = "Sprays a scalding jet from its back." },
	rhino_beetle = { text = "A horn like a lance and the weight of a truck behind it." },
	-- mantises
	blade_mantis = { text = "A leap, then a cut." },
	ghost_mantis = { text = "Pale, half-seen, and it steps out of nowhere." },
	reaper_mantis = { text = "Red scythes as long as a person." },
	-- centipedes
	tunnel_centipede = { text = "Under the ground, then spitting at you." },
	ironback_centipede = { text = "Armoured, and it charges and burrows." },
	sand_wyrm = { text = "A ringed worm the size of a train, with a round mouth full of teeth. It splits the ground." },
	-- scorpions
	scorpling = { text = "Small, many, and their stings add up." },
	sand_scorpion = { text = "Pincers and a sting, and a charge." },
	emperor_scorpion = { text = "Black and violet, it spits venom and shells up." },
	-- spiders
	spiderling = { text = "A hand-sized spider; there are always more." },
	spider = { text = "The giant spider: webs and a pounce." },
	weaver_spider = { text = "Webs the room and calls its spiderlings." },
	phase_spider = { text = "Blinks across the room through a web you can't see." },
	-- wolves
	grey_wolf = { text = "A pack wolf, fast and flanking." },
	dire_wolf = { text = "Bigger, faster, and it howls the pack in." },
	frost_wolf = { text = "Breathes ice." },
	wolf_alpha = { text = "The pack's leader: its howl drives them." },
	-- bears
	cave_bear = { canon = false, text = "A cave bear: a charge and a slam (ORIGINAL)." },
	ice_bear = { text = "An ice bear of the frozen Gates: a charge, a slam, and the cold." },
	ice_bear_alpha = { text = "The biggest of a frozen Gate's ice bears: a roar that drives the rest, a slam, a freeze. An alpha of this game's own, not the Red Gate's." },
	-- boars
	wild_boar = { text = "Charges first, thinks never." },
	razorback = { text = "Spiked, and it goes berserk when hurt." },
	ironhide_boar = { text = "A boar in natural plate." },
	-- great cats
	dusk_panther = { text = "Black, quiet, and it pounces." },
	sabre_cat = { text = "Sabre teeth and stripes; pounce and cleave." },
	thunder_tiger = { text = "Striped in storm, it pounces and calls lightning." },
	-- lycans
	ashen_lycan = { text = "A grey wolf-man that leaps and howls the pack in." },
	lycan_packmaster = { text = "Scarred and bracered, it leads and frenzies." },
	-- harpies
	gloom_crow = { text = "A black crow the size of a dog, diving in flocks." },
	harpy = { text = "Dives with talons and shrieks." },
	harpy_shrieker = { text = "Its shriek is a spell." },
	thunderbird = { text = "A storm with wings: lightning and dives." },
	-- drakes
	wyvern_hatchling = { text = "A young wyvern: dives and spits fire." },
	fire_drake = { canon = false, text = "A wingless-running drake that breathes fire and charges (ORIGINAL)." },
	wyvern = { text = "Dives, stings with its tail, breathes fire." },
	storm_wyvern = { text = "A wyvern of the storm Gates: lightning, dives, a tail sweep." },
	-- dragon-kin
	dragonkin_drakeling = { text = "A young dragon-kin: fire and a pounce." },
	dragonkin = { text = "Black scales, a burning breath, a tail that sweeps a street." },
	dragonkin_knight = { text = "A dragon-kin in black plate with a greatsword and fire." },
	dragonkin_flamecaller = { text = "Robed in red, it calls meteors down." },
	-- golems
	mud_golem = { text = "A lump of animated mud that slams." },
	iron_golem = { text = "Riveted iron, a glowing core, a slam and a guard." },
	crystal_golem = { text = "Glassy, crystal-crowned, shoots shards." },
	stone_golem = { text = "Mossy stone: slams, boulders, a stony guard." },
	magma_golem = { text = "Black rock with fire in the cracks; a nova of flame." },
	colossus = { text = "A golem the size of a building, rune-lit. Stomps and quakes." },
	-- elementals
	mana_wisp = { text = "A little ball of loose mana that shoots shards." },
	earth_elemental = { text = "Boulders circling a core of rock: quakes and thrown stone." },
	fire_elemental = { text = "A fire with a face: firebolts and novas." },
	frost_elemental = { text = "A cluster of living ice: shards and novas." },
	storm_elemental = { text = "A thundercloud with fists: lightning and a blink." },
	inferno_elemental = { text = "A fire the size of a house, crowned in black rock, that calls meteors." },
	-- slimes
	slime = { text = "The mana slime: hit it and it splits." },
	acid_slime = { text = "Spits acid, and splits." },
	magma_slime = { text = "A crusted slime of fire that bursts." },
	crowned_slime = { text = "A slime with a crown that calls more slimes." },
	-- undead
	skeleton = { text = "A skeleton soldier with a rusted sword and shield." },
	skeleton_archer = { text = "A skeleton with a bow." },
	skeleton_mage = { text = "Hooded bones that throw shadow." },
	ghoul = { text = "Grey, gaunt, fast, and it leaps. Ash-skinned, not rotting." },
	wraith = { text = "A hooded shape with a scythe of light that drains." },
	grave_knight = { canon = true, text = "An armoured knight of a dead kingdom: a cleave, a charge, a guard. A canon type (undead-like knights), never a shadow soldier." },
	lich = { text = "A crowned skull in a robe that raises grave knights, freezes and throws shadow." },
	hollow_king = { text = "Empty armour on an empty throne, crowned: it drains, rallies its wraiths and raises more." },
	bone_drake = { text = "A wyvern's skeleton with wings of cold light. It dives and breathes frost." },
	-- demons
	imp = { text = "A little red demon that hops, throws fire and blinks." },
	demon_soldier = { text = "Horned, armoured, with a glaive." },
	demon_knight = { text = "A burning sword, a shadow step, a nova of fire." },
	demon_warlock = { text = "Meteors, shadow bolts, wards." },
	demon_noble = { text = "Crowned, winged, burning. It commands demon soldiers and calls meteors. A noble of this game's own, never a canon demon lord." },
	-- hounds
	ember_hound = { text = "A black hound with embers in its fur that breathes fire." },
	twinhead_hound = { text = "Two heads, two breaths." },
	threehead_hound = { text = "Three heads, a mane of fire. Not a gatekeeper: just a hound." },
	-- plants
	mandrake = { text = "A root with a face. Its scream knocks you off your feet." },
	vine_lasher = { text = "A flower with whips." },
	spore_shambler = { text = "A walking mushroom that fills the air with spores." },
	treant = { text = "A tree that walks, stomps and lashes." },
	elder_treant = { text = "An old blossoming treant that quakes the ground and mends its forest." },
	-- aquatic
	reef_crab = { text = "A red crab that shells up." },
	merfolk_warrior = { text = "A trident and a charge, hovering on the water it brings." },
	merfolk_tidecaller = { text = "Cold water shards and mending." },
	kraken_spawn = { text = "Eight arms that lash, and ink." },
	abyss_serpent = { text = "A sea serpent from the deep Gates: freezing breath and a tail that sweeps a street." },
	-- constructs
	living_armor = { text = "Empty armour with a sword and shield." },
	mimic = { text = "A treasure chest. It is not a treasure chest." },
	gargoyle = { text = "A stone gargoyle that dives and guards." },
	rune_sentinel = { text = "A one-eyed rune construct with a gaze." },
	-- minotaurs
	minotaur_raider = { text = "A young minotaur with an axe and a charge." },
	minotaur = { text = "The minotaur: a greataxe, a charge, a slam." },
	minotaur_champion = { text = "Plate, cape, greataxe, war cry, stomp." },
	-- centaurs
	centaur_skirmisher = { text = "Javelins and a charge." },
	centaur_archer = { text = "Arrows and volleys at a gallop." },
	centaur_lancer = { text = "A lance and a charge that goes through you." },
	-- basilisks
	cockatrice = { text = "A small, vicious bird-lizard with a stiffening gaze." },
	basilisk = { text = "Eight legs, a crest, a gaze, a tail, spit." },
	elder_basilisk = { text = "An ancient basilisk whose gaze and tail shake the ground." },
}

-- the fight-screen foe (Games/BitLeveling/Foes.luau) a family's Gate shows, by rank
Bestiary.FOES = {
	goblins = "foe_goblins", kobolds = "foe_kobolds", vermin = "foe_vermin", orcs = "foe_orcs",
	high_orcs = "foe_high_orcs", ogres = "foe_ogres", trolls = "foe_trolls", giants = "foe_giants",
	ice_elves = "foe_ice_elves", forest_elves = "foe_forest_elves", dark_elves = "foe_dark_elves",
	dwarves = "foe_dwarves", lizardfolk = "foe_lizardfolk", naga = "foe_naga", ants = "foe_ants",
	beetles = "foe_beetles", mantises = "foe_insects", centipedes = "foe_insects", scorpions = "foe_insects",
	spiders = "foe_spiders", wolves = "foe_wolves", bears = "foe_bears", boars = "foe_boars",
	great_cats = "foe_great_cats", lycans = "foe_lycans", harpies = "foe_harpies", drakes = "foe_drakes",
	dragonkin = "foe_dragonkin", golems = "foe_golems", elementals = "foe_elementals", slimes = "foe_slimes",
	undead = "foe_undead_high", demons = "foe_demons", hounds = "foe_hounds", plants = "foe_plants",
	aquatic = "foe_aquatic", constructs = "foe_constructs", minotaurs = "foe_minotaurs",
	centaurs = "foe_centaurs", basilisks = "foe_basilisks",
}
-- (where a family looks different low and high: rank <= `upTo` shows `id`)
Bestiary.FOES_LOW = {
	dwarves = { upTo = 2, id = "foe_dwarves_low" },
	undead = { upTo = 3, id = "foe_undead_low" },
	demons = { upTo = 1, id = "foe_imps" },
}
function Bestiary.foeFor(family: string, rank: number): string?
	local low = Bestiary.FOES_LOW[family]
	if low and rank <= low.upTo then
		return low.id
	end
	if family == "centipedes" and rank >= 6 then
		return "foe_wyrms"
	end
	return Bestiary.FOES[family]
end

local LETTERS = { "E", "D", "C", "B", "A", "S" }

-- everything about one kind (the numbers come from Hunter/Monsters)
function Bestiary.entry(kind: string): any?
	local k = Bestiary.KINDS[kind]
	if not k then
		return nil
	end
	local Monsters = require(script.Parent:WaitForChild("Monsters")) :: any
	local d = Monsters.DEFS[kind]
	if not d then
		return nil
	end
	local f = Bestiary.FAMILIES[d.family] or {}
	local canon = if k.canon ~= nil then k.canon else f.canon == true
	return {
		kind = kind,
		name = d.name,
		rank = d.rank,
		rankLetter = LETTERS[d.rank],
		family = d.family,
		familyName = f.name,
		canon = canon,
		origin = if canon then "canon type" else "original",
		note = f.note,
		habitat = f.habitat,
		behaviour = d.beh,
		howItFights = f.behaviour,
		weakness = f.weakness,
		text = k.text,
		familyText = f.text,
		hp = d.hp,
		dmg = d.dmg,
		speed = d.speed,
		specials = d.sp,
	}
end

return Bestiary
