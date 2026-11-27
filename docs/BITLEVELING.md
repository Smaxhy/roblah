# BitLeveling

A life simulator set in the world of the original **Solo Leveling** manhwa (non-commercial fan
game), built on the LifeSim blueprint kit in this repo. You live one life, year by year: born
before the Gates or under them, maybe awakening, maybe never. You also walk a live 3D city as
your own **R6** character, where Gates open in real time for everyone on the server.

You are never Sung Jinwoo, never the Shadow Monarch's vessel, never chosen. The System is his.
The world has its own story, and it goes on whether you're part of it or not.

- Canon research: [`BITLEVELING_CANON.md`](BITLEVELING_CANON.md). Every fact there has a confidence label, plus a list of popular claims that are **not** canon.
- Studio plugin, Blender pipeline, AI/terminal bridge: [`STUDIO_AND_BLENDER.md`](STUDIO_AND_BLENDER.md)
- Game content: `src/shared/Games/BitLeveling/`
- World simulation: `src/shared/Engine/HunterWorld.luau`
- Live city (server): `src/server/HunterLive/`
- Live city (client): `src/client/HunterLive.luau`, `src/client/UI/HunterBoard.luau`, `src/client/UI/R6Creator.luau`
- R6 rig and looks: `src/shared/Hunter/R6Rig.luau`, `src/shared/Hunter/Looks.luau`

## Canon vs. this game's own

Every lore entry in the in-game Archive is marked **[CANON]** or **[GAME]**.

| Canon (manhwa) | Original game content |
|---|---|
| Gates appear about 10 years before the story; ranks E to S; the Association measures them and sells raid rights | Which Gates open near *your* life, where, when, and what happens to them |
| An uncleared Gate breaks (Dungeon Break); about 7 days is typical, and Tokyo's broke in about 3 | Each Gate's own break clock (a spread around 7 days, shorter in a High-Danger World) |
| Red Gates: turn red once the raid is inside, sealed until the boss dies, readings are wrong | How often they happen, and the odds inside |
| Double Dungeons: extremely rare; the Cartenon Temple is the only canon one | Vanishingly rare, never repeatable anomalies that are **not** the Cartenon Temple and choose no one |
| Rank is fixed at awakening; reawakening is extremely rare | The odds of awakening by age, rank and class weights, and reawakening odds |
| Hunter classes: Fighter, Mage, Assassin, Tanker, Ranger, Healer | Class stat leanings |
| The public timeline: the first Gates, the dragon on the US West Coast and the National Level Hunters, Jeju's fall and the failed raids, Cha Hae-In (9th S-rank), Korea's 10th S-rank, the fourth Jeju raid, the Ahjin Guild, Tokyo's giants, Christopher Reed's death, Go Gunhee's death, the Gate over Seoul, the war, the rewritten world | Your firsthand experience of the parts you're there for (evacuating Jeju, sheltering in Tokyo...) |
| Hunters Association, Surveillance Team, Hunters / White Tiger / Fame / Ahjin guilds, the Hunter Bureau, Scavenger Guild, Draw Sword Guild | The small and mid-size guilds you actually work for, every NPC, every incident |

### How canon and your life coexist

- **Calendar.** Canon gives no calendar years, so years count from the first Gates: *Gate Year 0*. The story begins at Gate Year 10; the other public events sit at their relative years (approximate where canon is: see the brief).
- **News, not cameos.** Canon characters appear the way ordinary people meet them: on the news, when their public events happen. They're never your friends, and never somewhere canon doesn't put them.
- **Secrets stay secret.** The System, the Architect, the Monarchs' plots, what really happened in the Double Dungeon: none of it reaches the news, because nobody in the world could know. (A test checks this.)
- **Firsthand only if you're there.** A life in Jeju when it falls gets the evacuation; a life in Tokyo when the giants come gets that; everyone else reads it. Children never get the dangerous ones.
- **Korea's S-rank count.** Canon says Korea's 10th S-rank was recognised at the story's start, the first since the 9th two years earlier. So a life in Korea can't measure S-rank before Gate Year 11 (it reads A). After that, an S-rank would be Korea's 11th or later.
- **The ending.** Canon ends with time turned back to before the Gates and nobody remembering. When it happens in your life, you choose: **let it happen (canon)**, and your life goes on in a world with no Gates (your years aren't rewound: a simplification, said on the card), or **stay on this world line (non-canon)**, and the game says from then on that you're off the canon story.

## The two worlds

Picked on the start screen (the difficulty picker), for the whole life. They differ in how the
world behaves, not only in numbers:

| | Normal World | High-Danger World |
|---|---|---|
| Gates near you a year | about 6 | about 10, leaning higher-rank |
| Gates opening in streets | fewer | noticeably more (cityShare 0.10 vs 0.24) |
| Break clock | about 4 to 9 days | shorter (instability) |
| Association response | fast, usually enough | slower, stretched, sometimes not enough |
| Share of Gates that break (measured) | about 8% (1% in streets) | about 23% (12% in streets) |
| Red Gates / Double Dungeons | about 0.3% / 0.01% | about 1% / 0.07% |
| Breaks put down before they spread | usually | often not; an S-rank break can take a whole area |
| Wounds, foes | as written | heavier, stronger |
| The live city | a new Gate every few minutes | about twice as often |
| How long lives last (headless) | a careful player: median 75; choosing at random: about 31 | choosing at random: about 22 |

## The world simulation (Engine/HunterWorld.luau)

Every year of a life the world makes its own Gates around it, and runs each through its stages:

1. **Appeared**: a place (the city's own street names), a rank, a kind (ordinary, red, double), an environment and monsters.
2. **Discovered**: at once in a crowded street; days later in a forest; or never, until it breaks.
3. **Response**: the Association measures it (a Red Gate's or Double Dungeon's reading is wrong), and assigns a raid. Higher ranks take longer to field; an S-rank needs the top guilds together.
4. **Active**: the raid goes in. It can fail, and a second team may or may not get there in time.
5. **Resolved or escalated**: cleared, or a **Dungeon Break**: contained, spread, or (S-rank, rarely) an area lost.
6. **Aftermath**: casualties, damage to the city (a damaged city wears on everyone in it, and heals slowly), the news, and your record.

The Association isn't omniscient: response depends on the country's capacity, the city's Hunters,
the world, and how many big incidents it's already handling that year (strain).

**Being there.** A life is only pulled into an incident in its own city, and only when it's
really there: a working Hunter whose rank fits is called to raid it (never more than one rank
above their licence); a break in a busy street might catch you; a Gate might open in front of
you. At most two cards a year (three in High-Danger), most urgent first. Nobody under 13 gets
one, and minors are caught out less (they're in school or at home).

**What you can do depends on who you are.** Civilians get civilian choices (get clear, keep the
crowd moving, film it, call it in; run, shelter, pull someone out). Hunters get their own (hold
the cordon, go in before the Association, fight, hold the line, guide the evacuation, run). The
fight on a card is as strong as the Gate's rank, whoever you are, and the odds preview shows it,
with a warning line when the rank is above yours.

**The news.** Local incidents, the rest of the country, the world, and the canon timeline's public
events. Open **NEWS** on the dock: News, Incidents (what came of each Gate near you, and what you
did), Record (your awakening, raids, breaks, evacuations...), Live.

## The live city (server/HunterLive)

A walkable city built on the server (so everyone shares it): blocks of buildings, roads,
crosswalks, street lamps, a plaza with a news screen, a park, a parking lot, an industrial yard, a
construction site, a subway entrance, a Hunter Association branch and a guild tower. Two dozen
civilians walk its sidewalks.

Every few minutes (about twice as often if anyone on the server is living a High-Danger life),
a Gate opens at one of its sites, running the same engine on a clock:

- the portal opens (blue; there is no colour per rank in canon) and people react, each by temperament: most flee, some freeze, some help others, some shelter in doorways, some stand and film;
- police arrive and tape it off, with light bars and a siren; the Association's van arrives and measures it (the reading goes up on the news screen);
- a raid team walks in. It's cleared and the Gate closes, or it turns **red** and seals (the street goes red around it), or it **breaks**: monsters of its rank come out and chase whoever is nearest, civilians are knocked down (no gore: they fade and are carried off), and the Association sends Hunters to contain it;
- monsters drop **mana crystals** you can collect and sell.

**Walk the city** (dock) puts you in it as your R6 character. Your rank sets your health and speed;
civilians can only run, hide and help. **RESPOND** turns the nearest incident into a card in your
life. **HELP [E]** gets a frozen bystander moving. Hunters can **ATTACK [F / click]**. If a monster
brings you down, your life takes the injury, and it can kill you.

Admins (and anyone in Studio) get **TEST GATE**, **TEST BREAK** and **TEST RED GATE** buttons on
the dock, which open one at the site nearest them.

## The opening and the Gates

When you join, a short cutscene plays (`client/OpeningCutscene.luau`, Skip ends it): a night
street behind police tape, people filming at the cordon, the Association's van, and a raid party
of five (Tanker in front, then Fighter, Mage, Assassin, Healer) walking into a Gate one at a time.

Every Gate in the live city is drawn by `client/GateVfx.luau` as canon draws them: a **standing
whirlpool**, a vertical disc of spiral arms turning around a dark eye, with a bright rim, an inner
horizon, mana drawn in from around it, and a light. It swirls faster as a break nears, surges and
cracks the street when it breaks, turns red when a raid is sealed in, and collapses when it
closes. `tools/vfx/gate_sheet.luau` renders it offline.

## Weapons, rarities and the market

`Hunter/Weapons.luau` has **65 weapons in 28 families** (daggers, twin daggers, swords, katanas,
greatswords, rapiers, cleavers, scythes, spears, halberds, axes, hammers, maces, staffs, wands,
focus orbs, grimoires, bows, crossbows, gauntlets, claws, shields, lanterns, rods, chain-blades,
chakrams, kusarigama...), graded E to S, each with its own 3D model (`Hunter/WeaponModels.luau`).

Every weapon that drops is rolled for **stars**: ★ (70%), ★★ (24%, x1.35 power, glowing edges),
★★★ (6%, x1.8, a light of its own). On top of that, 1 in 60 is **Shiny** (x1.45 more, +6% heads
in every fight, gold trim and sparkles). Raids, breaks, Red Gates and Double Dungeons drop them;
harder places drop better ones. A better weapon goes in your hand, the rest to your stash.

**MARKET** on the dock is the Hunters' Market (`server/HunterMarket.luau`): list a weapon for
other players on the server to buy (up to six at once). A listed weapon is held in escrow on your
profile, so nothing is lost if the server closes; a sale made after your life ended waits in your
market wallet for the next one.

## Classes, skills and talents

Every awakened Hunter has a class (canon's six: Fighter, Mage, Assassin, Tanker, Ranger, Healer),
leaned by your stats and birth talents. Each class has **six skills** learned in order on the DO
tab, each needing a rank and enough of the class's main stat (`Games/BitLeveling/Skills.luau`).
At birth you get a **talent** from 50, by rarity (Ordinary to Unreal).

In the live city a class's skills power two abilities, **Q** and **R**, each with its own effect:
Cleave and Ground Slam (Fighter), Mana Bolt and Frost Nova (Mage), a dash strike and Bleed Flurry
(Assassin), Shield Bash and Provoke (Tanker), Piercing Arrow and Arrow Rain (Ranger), Mend and
Sanctuary (Healer).

## Monsters and bosses

The live city's breaks spawn **24 kinds of monster, four a rank** (`server/HunterLive/Monsters.luau`):
goblins, giant rats, cave bats and mana slimes at E; hobgoblins, armoured beetles, giant spiders
and dire wolves at D; orcs, lizardmen, cave trolls and naga at C; ice bears, ogres, wraiths and
iron golems at B; high orc warlords, wyverns, minotaurs and stone golems at A; dragon-kin,
colossi, abyssal serpents and the Hollow King at S. Each is built from parts with jointed limbs
and a gait (biped, four-legged, crawler, spider, flyer, floating, serpent, blob, golem), and
`client/MonsterAnim.luau` animates them on each player's machine: legs by speed, wingbeats,
tails, coils, a swing when they hit. A break brings two kinds. `tools/vfx/monster_sheet.luau`
renders the roster (`docs/images/monsters.png`).

In a life, raids have a **boss room** and Red Gates a throne: **12 bosses fought in turns**
(`Games/BitLeveling/Bosses.luau`, two a rank), with phases, moves telegraphed a turn ahead, and
friends on the server able to join. They're tuned by headless fights: a Hunter at the boss's rank
with middling stats wins about half the time alone, a strong one nearly always; a Red Gate's boss
is a rank above the reading, so run if you must.

## Stories and endings

Beyond the Gate incidents and canon headlines, a life can fall into one of **15 story arcs**
(`Events/Saga_*.luau`, about 130 cards), each running over several years with branches and ways to
fail: founding your own guild (a rival guild, a guild war, a collapse); rising in the Association
(a crime ring that under-reads Gates; Surveillance Team or Branch Director); turning rogue (prison,
testimony, or on the run); the Healer's Oath; the Wall (a Tanker holding a line); four for people
without a rank (a reporter and a buried story, a shelter network, a crystal tycoon, a researcher's
early-warning box); surviving a Red Gate and then a second one; the Hollow Door (a double dungeon
of the game's own, not Cartenon); passing your weapon to a child who awakens.

On the **non-canon world line** (choose to keep the Gates when canon rewrites the world) more open
up, and every card says it's non-canon: **five Monarch paths**, where the power of a Monarch who
died in canon (Rakan, Sillad, Querehsha, Legia, Tarnak) looks for a vessel: take the crown, refuse
it at the last moment, or be consumed; becoming a National Level Hunter; lending your body to a
Ruler; the Association's chair. Ashborn, Antares, Baran and Yogumunt are never offered.

Every life ends in one of **40 fates** (`Games/BitLeveling/Fates.luau`), rarity 1 to 5: the death
screen leads with it, the life's record is titled with it, and your profile collects them (a new
one pays 1 Glow; rare ones make the server's news). The **ENDINGS** tab on the news board lists
the ones you've found and a hint for each one you haven't.

## R6 character customization

`R6 LOOK` on the dock opens the creator: a turntable preview of a real R6 rig, and tabs:

- **Presets**: 16 whole outfits in a click (Association Agent, Surveillance Team, Guild Striker,
  Tanker, Assassin, Mage, Healer, Ranger, Collection Crew, Rogue Hunter, Raid Commander, Student,
  Office Worker, Shopkeeper, Martial Fighter, Frost Knight); then change anything.
- **Body**: 12 skin tones, 3 builds, and an **aura** (mana particles and a light, in one of 8
  colours or your rank's own).
- **Face**: 8 expressions, 8 eye colours, a **mana glow** in the eyes (6 colours), 6 brows,
  **14 scars and marks** (scar over the eye, across the nose, crossed, claw marks, burn,
  freckles, war paint, mana veins...), 16 accessories.
- **Head**: 46 Roblox-made hair accessories, 14 dyes, and **13 headwear pieces** (hood, raid
  helmet, knight's helm, horned helm, assassin's wrap, mage's hat, healer's veil, hard hat,
  goggles...). Helmets and hoods cover the hair.
- **Clothes**: 21 tops, 10 bottoms, 7 shoes, gloves, 22 colours for each part and a trim colour.
- **Gear**: 7 armour styles, **12 back items** (capes, quiver, raid pack, sheath, shield, staff,
  crystal crate, guild banner, mana wings) in their own colour, and a workshop weapon.

Randomize and Save. The server checks every field.

The rig is built from Parts (the six classic R6 parts, Motor6D joints, the standard attachments),
with the clothes and gear as shells welded to each limb and the face drawn on a plate. Nothing
depends on uploaded meshes or shirt templates that could go missing; the hair is Roblox's own
accessories, loaded by the server with InsertService the first time someone picks one (block
hair stands in if one can't load). Your rank is never picked here: it's what you awaken at.

`tools/avatar/r6_sheet.luau` builds contact sheets on real Roblox instance types (`-- presets`
for presets, headwear, back items and faces; `-- weapons` for every weapon), and
`node tools/gui_render/shoot.js --dump <json> --png <png>` draws them.

**Blender and Studio:** monsters, weapons and gear can wear smooth Blender-made meshes (a mesh
kit modeled by scripts in `tools/blender`). There is also a Studio plugin that installs, previews,
checks and play-tests the game, and a bridge for running Luau in Studio from a terminal or an AI
tool. All three are covered in [`STUDIO_AND_BLENDER.md`](STUDIO_AND_BLENDER.md).

## Testing

```
lune run tools/checkgame BitLeveling            # validate, lint, headless lives
lune run tests/hunterworld_check 100            # the world simulation's behaviour (see below)
lune run tests/fates_check 60                   # every ending reachable, every life ends in one
lune run tests/weapons_check                    # weapons, stars, Shiny, drops, the market's value
lune run tests/live_build_check                 # the live city, every look option, every monster (built and animated)
lune run tests/live_ui_check                    # the news board, the R6 creator and the market build
lune run tests/plugin_check                     # the Studio plugin (after bash tools/build_plugin.sh)
python3 tests/bridge_check.py                   # the Studio bridge
tools/blender/run.sh                            # the Blender mesh kit and its previews
lune run tests/compile_check                    # every .luau file parses
lune run tools/avatar/r6_sheet.luau             # R6 looks on real Roblox types (then shoot.js for a PNG)
python3 tests/safety_scan.py src/shared/Games/BitLeveling
bash tools/build_game.sh BitLeveling --no-test  # build/BitLeveling.rbxlx and build/BitLevelingKit.rbxmx
```

`hunterworld_check` checks: every Gate runs through its stages in order and ends; the
High-Danger World breaks more, kills more, answers later and opens more Gates in streets; Red
Gates are rare and Double Dungeons rarer; canon headlines land in their years; no secret canon
reaches the news; Jeju falls, its residents are evacuated, and it's restored after the fourth
raid; Korea has no S-rank before its canon 10th; lives are only pulled into incidents in their
own city; every life saves; raid and Red Gate boss rooms start fights in turns and are recorded
when they end.

What can't be tested here is the live game itself (Roblox Studio isn't available in this
environment): the Roblox-side code is syntax-checked, type-checked against Roblox's API
definitions, and the city, rigs and monsters are built on real Roblox instance types, but the
first real run is in Studio. Open `build/BitLeveling.rbxlx`, press Play, and use the TEST
buttons on the dock.

## Known limits

- The canon brief was gathered from search summaries, not by reading chapters; items marked LIKELY or lower should be checked against the chapter.
- The rewritten world doesn't turn your years back.
- The live city is one shared city: it's "your city" for whoever walks it, whatever their life's city is.
- NPC monsters and Hunters use simple chase-and-strike AI (no pathfinding around buildings).
- The Robux store is off (`fanWork = true`): Solo Leveling is someone else's IP.
- The kit's full-server harness tests (`tests/battle_check` and the others built on
  `tests/harness.luau`) don't boot under this Lune version, on the kit as imported too; the
  engine pieces they cover are tested directly by the checks above.
- The sheet renderer doesn't draw particles, lights or SurfaceGuis on parts, so auras and glows
  are checked structurally and the faces are rendered flat.
