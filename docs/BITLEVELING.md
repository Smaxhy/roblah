# BitLeveling

A life simulator set in the world of the original **Solo Leveling** manhwa (non-commercial fan
game), built on the LifeSim blueprint kit in this repo. You live one life, year by year: born
before the Gates or under them, maybe awakening, maybe never. You also walk a live 3D city as
your own **R6** character, where Gates open in real time for everyone on the server.

You are never Sung Jinwoo, never the Shadow Monarch's vessel, never chosen. The System is his.
The world has its own story, and it goes on whether you're part of it or not.

- Canon research: [`BITLEVELING_CANON.md`](BITLEVELING_CANON.md). Every fact there has a confidence label, plus a list of popular claims that are **not** canon.
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

## R6 character customization

`R6 LOOK` on the dock opens the creator: a turntable preview of a real R6 rig, and tabs for
**Body** (12 skin tones, 3 builds), **Face** (8 expressions, 8 eye colours, 6 brows, 11
accessories), **Hair** (46 Roblox-made hair accessories, 14 dyes), **Clothes** (13 tops, 7
bottoms, 4 shoes, gloves, 22 colours for each part and a trim colour), and **Hunter Gear** (7
armour styles, 12 weapons). Randomize and Save. The server checks every field.

The rig is built from Parts (the six classic R6 parts, Motor6D joints, the standard attachments),
with the clothes and gear as shells welded to each limb and the face drawn on a plate. Nothing
depends on uploaded meshes or shirt templates that could go missing; the hair is Roblox's own
accessories, loaded by the server with InsertService the first time someone picks one (block
hair stands in if one can't load). Your rank is never picked here: it's what you awaken at.

`tools/avatar/r6_sheet.luau` builds a contact sheet of looks on real Roblox instance types;
`node tools/gui_render/shoot.js --dump tools/avatar/shots/r6.json --png tools/avatar/shots/r6.png`
draws it (faces and hair accessories show in game, not on the sheet).

**About Blender:** there's no Blender in this environment, and meshes made in Blender would need
uploading to Roblox under your account before a game could use them. The parts-built rig needs
neither. If you do want custom meshes later (hair, armour), make them in Blender, import them in
Studio as MeshParts, and add them to `Looks.luau` and `R6Rig.luau`.

## Testing

```
lune run tools/checkgame BitLeveling            # validate, lint, headless lives
lune run tests/hunterworld_check 100            # the world simulation's behaviour (see below)
lune run tests/live_build_check                 # the live city, R6 civilians and monsters on real Roblox types
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
own city; every life saves.

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
