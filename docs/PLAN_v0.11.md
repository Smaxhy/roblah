# A Life in the City: the plan for v0.11

Everything you asked for, mapped, then the order it was built in. Section 11 is what exists now.
Status key: **DONE** (built and tested), **LATER** (not in this update, and why).

---

## 1. Everything you asked, mapped

### Asked before (v0.10)

| You asked | Status | What exists |
|---|---|---|
| A lot more weapons, outfits, monsters | DONE | 60 weapon models, 46 new weapons, 16 new outfits and 29 upgraded uniforms, 12 new monster shapes, 39 new foes |
| Smoke War first, never played | DONE | It is over before any life starts |
| Age of L Corp: L Corp holds District 12 in the fallen Wing's place | DONE | First age you can be born into |
| Last year of L Corp: the Light, meant for 7 days, shines 3, then 4 Dark Days. Players only know it failed | DONE | White Nights and Dark Days events |
| Nobody knows "Distortion" or "E.G.O" in the Age of L Corp | DONE | Checked by a test over every line of text |
| Age of the Library: stands where L Corp was, E.G.O and Distortion possible, its rank is news (Urban Myth ... Star of the City) | DONE | Rank climbs by year and is announced |
| After the Library: second Light, full 7 days, Shin and Mang, Distortions remain, Limbus and Leviathan begin, L Corp is gone | DONE | Fourth age |
| Carmen speaks at the breaking point. Follow her: Distortion. Strong enough: E.G.O. In between: volatile E.G.O | DONE | Retuned this week so E.G.O takes a strong mind |
| Stats: Health, Strength, Speed, Intelligence, Charisma, Luck, Mental Strength, Sanity | DONE | All eight |
| Reputation with every faction; hurt a Finger and they come for you or your people | DONE | 11 factions, 20 reprisal events |
| Each District has its own places (District 21: the Great Lake) | DONE | 27 places |
| Difficulty before you start | DONE | Three levels |
| Red Mist is dead, only a legend | DONE | |
| 3 family/friend actions and 3 activity actions | DONE | Changing again below |
| Quieter sound effects | DONE | |
| Better explanations for deaths and events | DONE | Death report, WHY line. Reworked again below |
| No two lives alike | DONE | Variant lines, 45 characters with different names per life, repeat events avoided |
| UI covers the whole screen | DONE | HUD, menu, creator, death screen. Rebuilt again below |

### Asked now (v0.11)

| # | You asked | Status | Section |
|---|---|---|---|
| A | Focus hard on the UI. Rework and upgrade all of it. It must look a lot better | DONE | 3 |
| B | A lot more than 6 activities and a few scenes per life. Things need meaning | DONE | 4 |
| C | Story much easier to follow (10 minutes in, completely lost) | DONE | 5 |
| D | A lot more than 4 storylines, with a much more appealing story UI, strictly matching Project Moon lore, starting the way you laid out | DONE | 5, 6 |
| E | Stats need real impact | DONE | 2 |
| F | Each interaction unique, with options | DONE | 7 |
| G | A lot less text | DONE | 8 |
| H | Replace the Steady / Reckless / Careful system. Base encounters on stats and dominant stats | DONE | 2 |
| I | Upgrade cutscenes, battles, monsters | DONE | 9 |

Not in this update:

| Item | Status | Why |
|---|---|---|
| Roblox catalog hair and clothing meshes | LATER | Needs asset IDs picked inside Roblox Studio, which I can't open from here |
| Playing it in Roblox Studio before I hand it over | LATER | I test with an engine simulation and a screen renderer here. You are the first to run it in Roblox |

---

## 2. Stats that matter, and encounters built on them (E, H)

**Steady / Reckless / Careful is removed.** In a fight you choose which of your stats to fight with.

| Way to fight | Stat | What it does | Strong against | Weak against |
|---|---|---|---|---|
| Overpower | Strength | Biggest wins | Cunning foes | Quick foes |
| Outpace | Speed | You get away lighter when you lose | Brutes | Cunning foes |
| Outthink | Intelligence | Their coins land worse | Quick foes | Brutes |
| Talk down | Charisma | People only. Win and nobody bleeds | | |
| E.G.O / Volatile E.G.O | Mental Strength | As now, paid in Sanity | | |

- Every foe has a **temper** (Brute, Quick, Cunning) shown on the card with what beats it.
- The card shows your odds for each way, so your stats visibly decide the fight.
- **Dominant stat = your nature** (The Strong, The Quick, The Sharp, The Charming, The Unshaken). It is shown under your name, gives +1 on everything that uses that stat, and pulls events of that kind toward you. A strong life gets challenged; a charming one gets offers.
- **Stat tiers do things.** Every 20 points is a tier, and each tier has a named perk:

| Stat | Tier II (20) | Tier III (40) | Tier IV (60) | Tier V (80) |
|---|---|---|---|---|
| Health | Wounds mend faster | Take 10% less | | Take 20% less |
| Strength | | +1 when Overpowering | | Each coin hits harder |
| Speed | | +1 action a year | | +1 more action a year |
| Intelligence | Training gives more | Wages +15% | | +1 action a year |
| Charisma | | +1 time for people a year | Prices −10% | +1 more a year |
| Mental Strength | Lose 15% less Sanity | | Lose 30% less Sanity | E.G.O costs the minimum |

The stat panel shows your tier, the perk you have, and what the next one gives.

## 3. The UI, rebuilt (A)

Goal: big, clear, few words. Icons, meters and tiles instead of paragraphs.

- **One row of six tabs with icons**: DO, PEOPLE, STORY, YOU, CITY, MENU. Today there are 13 buttons in two clusters. Goals, Crew, Ranks, Store, Guide move inside the tab they belong to.
- **Middle of the screen is "this year"**, not a wall of log. A story strip on top (what your story is, what to do next), then this year's happenings as one-line rows with icons. Tap a row for the full text. Old years fold away.
- **Activities are tiles**: icon, name, what it gives as coloured chips, odds as a meter. Descriptions move to a hover or long-press.
- **Event cards**: a coloured label for which thread it belongs to (YOUR STORY, WORK, FAMILY, DISTRICT, THE CITY, CHANCE, GRUDGE), two sentences at most, big choice buttons with the stat icon, your number, the odds as a ring, and the outcome as chips.
- **Your panel**: figure, name, nature, tiered stat bars with perks, Sanity dial, conditions as icons.
- **Action counter** next to +1 YEAR so you always see what is left this year.
- Phone gets the same parts stacked, with a bottom bar.

## 4. More to do, with meaning (B)

- **More actions**: 4 a year instead of 3, up to 7 with Speed and Intelligence tiers. Time for people: 3, up to 5 with Charisma.
- **Work is something you do**: a jobs board for your career every year (contracts for Fixers, collections for Syndicates, shifts for Wings). Each job uses a stat, pays, and counts toward your next rank. The rank bar shows exactly what is missing.
- **Always a "next step"**: the story strip, your next rank, and one personal goal, each with progress. Tiles that advance one of them are flagged.
- **Bonds do something**: at high bond someone backs you in a fight once a year; at very high bond they take a blow for you.

## 5. A story you can follow (C, D)

- **Opening**: a short title sequence for the age you were born into, three lines, then your District, your family, your story's hook and first objective.
- **Story strip** always on screen: story name, chapter, objective, progress pips.
- **Story tab rebuilt**: a chapter timeline (done, now, ahead), the cast of your story with faces and one line each, and "so far" in three short bullets.
- **Fewer random cards per year**, and every card labelled with its thread.
- **The ages as set pieces**: the Light (three days, then four dark), the Library appearing, the second Light. Full-screen moments, not ordinary cards.
- **Carmen** gets her own full-screen scene.

## 6. Many more storylines, lore-strict (D)

10 existed. 14 were added (the plan was 8; the table is the first ten), each bound to the age and place where it can be true. The ones that find you as an adult are 5 short chapters with 3 endings; the two to be born into are 7:

| Storyline | Where and when | Canon it stands on |
|---|---|---|
| The Sweepers' Hour | Backstreets, any age | Night in the Backstreets, 3:13 to 4:34 |
| Grade Nine | Fixers, any age | Hana's licences, Offices, Grades 9 to 1 |
| A Ticket to the Nest | Backstreets, any age | Nest residency belongs to Wing employees |
| The Prescript | Index streets, any age | Messengers, Proxies, Prescripts |
| Ten Seconds | District 23, any age | W Corp's WARP trains and their cleanup crews |
| Borrowed Hours | District 20, any age | T Corp collects time |
| The Fourth Pack | R Corp, any age | Rabbits, Reindeer, Rhinos; soldiers who are copies |
| What the Smoke Left | Age of L Corp only | The years after the Smoke War |
| The Portrait | Ring streets, any age | The Ring's Docents and exhibitions |
| Section Seven | Seven Association | Missing-person cases that, in the Library age, lead to the invitations |

No canon character is put in a scene they were not in. The age rules test runs over every new line.

## 7. Interactions that differ (F)

Spending time with someone opens a small scene with 2 or 3 options, each using a different stat, picked by who they are to you, how close you are, and what they do. Mother at the stall is not a friend on the roof.

## 8. Less text (G)

- Event text: two sentences shown, the rest behind "more".
- Choices: a label and chips. Hints move to hover or long-press.
- Log rows: one line each.
- Activity descriptions: hidden until asked for.
- Everything new is written short.

## 9. Battles, cutscenes, monsters (I)

- **Battle screen**: a staged backdrop, larger fighters, coins shown as coins, clear power numbers, the way you chose to fight and whether it has the advantage.
- **Cutscenes**: one shared full-screen player for the opening, the ages, Carmen, E.G.O and Distortion.
- **Monsters**: more detailed shapes, glowing eyes, a ground shadow, idle movement, better lighting.

---

## 10. Build order

1. Engine: fighting by stat, tempers, nature, tier perks, extra actions. Tests.
2. UI pass one: event cards, the fight picker, the middle of the screen, your panel.
3. UI pass two: six tabs, tiles, story tab, people scenes.
4. Content: interaction scenes, jobs board, 8+ storylines, opening and age set pieces.
5. Visuals: battle screen, monsters, cutscene player.
6. Text diet across old content, guide and tutorial rewritten.
7. Full test suite, screenshots of every screen (PC and phone), build, hand over.

Each step ends with the tests green before the next begins.

---

## 11. Status: what was built

Everything in sections 2 to 9 is built. One table, one row per thing you asked.

| # | You asked | Built |
|---|---|---|
| A | Rework and upgrade all of the UI | Six icon tabs in one row. The middle of the screen is a feed of cards with an icon tile, a title and chips; a new year is a gold rule, and the year behind it folds down to titles and chips. Stat bars are one smooth fill with a notch at every tier. Activities and jobs are tiles. Event cards have big choice buttons with the stat, your number, the odds and the outcome. A quick check has its own card. Sheets have a lit head band. Every panel, row and button is lit from above and answers the pointer. Your figure stands in light the color of your nature. Phone layouts for all of it. |
| B | More than 6 activities and a few scenes a life; things need meaning | 4 actions a year, up to 7 from Speed and Intelligence. 3 jobs a year on a board for your career; each pays, teaches and counts toward the next rank, and the rank card shows what is missing. 18 scenes with people. A second, third and fourth story in adult life. Close bonds back you in a fight and can save you once. |
| C | A story you can follow | An opening for the age you are born into. A story strip always on screen (story, what to do now, chapter pips, when the next comes). Every card carries the color and mark of the part of your life it belongs to. Random cards cut from 2.5 a year to 1.4. |
| D | A lot more than 4 storylines, better story UI, strict lore | 24 storylines: 12 to be born into, 12 that find you as an adult. The Story tab has a chapter timeline, the people in your story with their faces, what you did, and your goals. Each new story names the canon fact it stands on in its file header; none puts a canon character in a scene they were not in. |
| E | Stats with real impact | Tier perks every 20 points (more actions, more time for people, less Sanity lost, higher wages, lower prices, harder hits). Your highest stat is your nature: +1 on everything that uses it, and events of that kind find you more often. |
| F | Each interaction unique, with options | Spending time with someone opens a scene with two or three choices, each on a different stat, picked by who they are to you and how close you are. |
| G | A lot less text | Feed cards are one line, and older years show no body text at all. Event text shows two sentences with the rest behind "more". Activity descriptions and choice hints are tooltips. Everything written for v0.11 is two lines at most. |
| H | Replace Steady / Reckless / Careful; base encounters on stats | In a fight you choose the stat you fight with: Overpower (Strength), Outpace (Speed), Outthink (Intelligence), Talk down (Charisma, people only). Every foe has a temper (Brute, Quick, Cunning) that one of them beats. The card shows your odds for each. |
| I | Better cutscenes, battles, monsters | One full-screen cutscene player with seven looks (an age, the Light, the Dark Days, the voice, E.G.O, a Distortion, a story). The fight is staged where the scene was, with larger fighters and a line saying how you are fighting. Monsters have a shading pass and glow in their own color. |

### The 24 storylines

Born into (12): Collateral, Seven Days, The Invitation, The Book, A Quiet Heart, The Sweepers' Hour,
What the Smoke Left, Feather Fall, Courtesy, Borrowed Coat, The Voice, The Prescript.

Find you later (12): Grade Nine, The Fourth Pack, Ten Seconds, Borrowed Hours, The Prescript,
The Portrait, Section Seven, A Ticket to the Nest, The Arm, A Canard, The Company Flat, The Ampoule.

Five of the twelve can find anyone, three more need only a side of the wall or a District, and the
rest come through a career. A story you lived recently comes up a fifth as often in your next lives.

### Decisions I made that you may want changed

- Steady / Reckless / Careful still exists in the original Undermere pack. Only the City fights by stat.
- "Take her hand" on the voice card is labelled as ending the life. It tells the player the cost before they choose.
- Old event texts are shortened on screen, not rewritten. The full text is one tap away.
- Scenes with choices exist for "spend time" only. The other things you can do with a person are still one result each.
- The Store, Guidebook, Crew and Rankings sheets got the new chrome and rows, not a new layout.
- New story details (R Corp's tanks, the T Corp repossession, the clinic in Section Seven, the thing in the drain) are original scenes written on top of canon rules, not canon events.

### How it was checked

All of this ran on the final code.

| Check | Result |
|---|---|
| Type check (luau-lsp, whole project) | clean |
| Pack validation (City) | 0 errors, 0 warnings |
| Content scan for Roblox's Moderate bar (237 files) | 0 hits |
| Age rules over every line of text (1,919 entries, 6 rules) | every mention fits its age |
| `tests/v11_check`: fighting by stat, tempers, perks, nature, jobs, scenes, second stories, the story's cast, cutscenes | pass |
| `tests/story_check`: all 24 storylines played 25 times each | every chapter seen, every story reaches 3 or more endings, 300 of 300 births get a story |
| UI click-through, City pack | 7 of 7 cases |
| UI click-through, Undermere pack | 12 of 12 cases |
| Older suites: v5, avatar, emblem (87 icons), scene art, systems (both packs) | pass |
| `tests/city_check`: 30 dedicated lives for each of 34 careers, the ages, Bloodfiends, the chronicle, talents, modes, duels | pass. Every career's top rank is reachable (lowest: L Corp Branch Manager, 27% of dedicated lives). All 87 chronicle acts now reach other players' lives as rumours |
| Undermere, 300 lives | median life 76 years, the same as before this update (76 on the v0.9 code) |
| City, 305 lives played by a script | median life 55 years; 99% reach 18, 60% reach 50; 65% of event checks and fights won, 79% of jobs done well |
| Screens drawn from the real UI code | 34 of 34 on PC, 34 of 34 on a phone; a chosen set is in `screenshots/v11/` |

In the 305 lives: 939 adult stories began across 298 lives. The six most people can meet each turned
up in 38% to 53% of lives. 8 lives ended holding E.G.O, and 1 ended as a Distortion.

Two things the last check caught, both fixed: six acts from the turning points (killing a Capo,
a volatile E.G.O, refusing the voice, letting it go out, Shin, wrecking an exhibition) were
recorded but never reached other players, so six rumour cards were written
(`Events/Ages_Echoes.luau`); and its Bloodfiend test still pointed at the old breaking-point card
(the game was right, the test was out of date).

### Not done

- Nothing was run inside Roblox Studio. Everything here was checked with an engine simulation, a UI click-through on a stand-in for Roblox's GUI classes, and a screen renderer. You are the first to play it in Roblox.
- Roblox catalog hair and clothing meshes (needs asset IDs picked in Studio).
- The eight older story arcs are not converted to the storyline format.
