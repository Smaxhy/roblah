# v0.8 content spec (City pack)

What players said about v0.7, and what this release fixes:
- Ages 1-10 feel like a speedrun. Nothing happens.
- Every life feels the same. Events are "mid". It doesn't feel like Limbus Company.
- The Thumb and Fixers "just show up like it's nothing". No build-up, no story early on.
- Too much text. Too easy.

So v0.8 has 2-3 events every year from age 1, story that starts in childhood and builds,
talking scenes with faces, fights you watch play out, and an illustration on every event.

Read `docs/CONTENT_GUIDE.md` for the event format (sections: Text tokens, Conditions,
Results, Events, The coin clash, Fights and checks). `docs/CANON.md` is the lore bible
(grep it, it's long). `docs/SETTING.md` is a short overview. District ids and sides
are in `src/shared/City/init.luau` (`pack.districts`, sides are `backstreets` and `nest`).

---

## Voice (this matters most)

Project Moon: bleak, specific, dry, sometimes absurd. People have their own agendas and
lie. The City is a machine that eats people and nobody is surprised.

- Short. Event `text`: 1-3 sentences, 280 characters at most. Choice `label`: 40 at most,
  an action ("Run", "Give him the coin", "Ask about the coat"). Result `log`: 1-2
  sentences, 160 at most.
- Concrete nouns. Names, objects, numbers, smells. "A door with three locks", not "a
  dangerous neighborhood".
- No AI tells. Never write:
  - "It's not X, it's Y" / "not X, but Y" / "less X than Y" constructions
  - rhetorical questions you answer yourself
  - three adjectives in a row; lists of three for rhythm
  - em-dashes (use a period, comma or colon)
  - "a testament to", "tapestry", "symphony", "in the heart of", "little did", "the weight
    of", "echoes of", "whispers", "something shifted", "and yet", "somehow", "a reminder that"
  - endings that explain the moral. End on an action or a line of dialogue.
- Kids sound like kids. Adults talk past each other. Nobody explains the lore in full
  sentences; they assume you know, or they're wrong about it.
- Dark is fine, cruelty is implied, never described.

## Roblox rules (hard limits, the game is rated Moderate)

- Violence: implied and short. No gore, no wounds described in detail, no torture.
- No romance or dating, no alcohol, drugs, smoking, vaping, gambling or betting, no
  profanity (not even "damn", "hell", "crap"), no self-harm or suicide, nothing sexual.
- Children: danger is implied and usually survivable. Never describe a child getting hurt.
- `python3 tests/safety_scan.py` must report 0 hits.

---

## New in v0.8

### `art` on events (required on everything you write)

The illustration at the top of the event card. One of:

| scene | what it shows |
|---|---|
| `home` | a small Backstreets apartment: window with City lights, a lamp, a door with three locks |
| `alley` | a narrow alley between towers: pipes, a flickering sign, puddles |
| `street` | a Backstreets street: shopfronts, wires overhead, people |
| `rooftop` | a roof with a water tank and pigeons; the WARP rail across the sky |
| `night` | the Night in the Backstreets: 3:13, an empty street lit red, shutters down |
| `nest` | the clean side: white towers, wide spotless streets, cameras |
| `checkpoint` | a Nest gate: barrier, guards, a line of people with papers |
| `wing` | a Wing's headquarters tower with its corporate light |
| `lcorp` | inside Lobotomy Corporation: long white corridor, containment doors |
| `office` | a Fixer office: desk, blinds, a sign on the door, a board of contracts |
| `workshop` | a weapon Workshop: racks of blades, sparks, forge glow |
| `diner` | a late-night diner: counter, neon, booths |
| `clinic` | a back-alley clinic: a cot, a lamp, bottles |
| `school` | a classroom or academy hall |
| `train` | a WARP train car or platform |
| `syndicate` | a Syndicate den: low red light, a table, people in coats |
| `hall` | a Finger's formal hall: long table, chandeliers, banners |
| `library` | the Library: endless shelves, warm gold light |
| `outskirts` | the Outskirts: wasteland, broken skyline, a wrong-colored sky |
| `ruins` | a collapsed block: rubble, dust, a bent streetlight |
| `market` | a street market: stalls, lanterns, a crowd |
| `arena` | a fight ring or cleared lot under floodlights |
| `theater` | a shuttered theater, red curtains (Bloodfiends) |
| `distortion` | warped space; a Distortion's domain |
| `underpass` | a concrete underpass or tunnel |
| `bus` | inside the Limbus Company bus |

### `dialogue`: talking scenes (events and results)

```lua
{
	id = "kl_ottavio_cane",
	title = "Ottavio's Cane",
	art = "street",
	text = "Ottavio is outside his shuttered office again, cane across his knees.",
	dialogue = {
		{ who = "ottavio", line = "You're the kid from 4B. Your mother know you're out?" },
		{ who = "ottavio", line = "Sit. If you're going to stare at the scars, you can hear the stories." },
	},
	choices = {
		{ label = "Sit down", result = { prudence = 1, setFlags = { "knows_fixers" }, log = "...",
			dialogue = { { who = "ottavio", line = "Grade 4. Twenty years. Then one bad Tuesday." } } } },
		...
	},
}
```

- Event `dialogue` plays line by line with the speaker's face, before the choices.
  Result `dialogue` plays after the outcome.
- `who` is one of:
  - a cast id (see Cast below) → that person's face
  - a foe id (see Foes) → that foe's look
  - `"you"` → the player. Use rarely, at most one line per scene, and never let it decide
    anything (the choices do that).
  - a relation token: `"{mother}"`, `"{father}"`, `"{sibling}"`, `"{child}"`, `"{friend}"`,
    `"{mentor}"`, `"{rival}"` → their name and face. Add `hasRelation` to `when` so they exist.
  - any plain name starting with a capital, like `"A Thumb Soldato"` or `"The Clerk"` →
    a silhouette.
- 1-5 lines per scene, 120 characters per line at most. Tokens work in lines.
- Put dialogue in about one event in three. When an event has dialogue, its `text` is just
  one or two sentences of scene-setting.

### Cast: faces for people who talk (`src/shared/City/Cast/<YourFile>.luau`)

```lua
return {
	{ id = "kl_mrs_hwang", name = "Mrs. Hwang", title = "Runs the noodle cart", look = {
		skin = "sand", hair = "bun", hairColor = "ash", eyes = "brown", outfit = "diner_whites", accessory = "none" } },
}
```

Recurring people need a cast entry. `look` is optional (without it they get a face made from
their id). Look ids (any of these, locked or not):

- skin: porcelain, fair, peach, sand, honey, olive, amber, bronze, umber, deep, ebony, pallid
- hair: crop, shorn, long, bun, braid, curls, slick, ponytail, bob, messy, spiky, twintails, sidecut, ridge, hood, cap, veil, tophat
- hairColor: ink, umber, chestnut, rust, straw, ash, charcoal, auburn, platinum, crimson, teal, lilac, mint, rose, midnight, ember, snow, enkephalin, gold, dawn, silverlight, bloodred
- eyes: dark, brown, hazel, green, blue, grey, amber, aug_red, aug_blue, aug_violet, aug_amber, light_gold, ego_glow, bf_red, bf_garnet
- outfit: streetwear, work_overalls, diner_whites, academy_uniform, hoodie, mechanic, night_coat, nest_suit, nest_formal, fixer_coat, office_jacket, zwei_style, liu_style, seven_style, devyat_style, cinq_style, hana_formal, color_coat, thumb_suit, sottocapo_suit, middle_jacket, index_whites, ring_smock, kurokumo_coat, lcorp_suit, lab_coat, manager_suit, cleanup_jumpsuit, pack_fatigues, bus_uniform, guest_attire, ego_mantle, rat_jacket, courier_vest, shi_robe, dieci_coat, oufi_suit, blade_lineage, inquisitor_robe, twinhook_coat, hunter_greatcoat, warp_conductor, bf_formal, bf_noble
- mark: none, freckles, scar, ink, patch, family_tattoo, gold_freckles
- accessory: none, glasses, round_glasses, scarf_red, scarf_grey, headband, earring, mask, sunglasses, fedora, monocle, half_mask, red_visor, big_shades, manager_visor
- weapon: none, pipe, knife, blade, revolver, sledge, knuckles, katana, spear, axe, greatsword, censer, liu_gauntlet, zwei_mace, hardblood_spear, green_baton

Cast ids are lowercase with underscores and start with your id prefix (below). Already in
`Cast/Core.luau`: `ottavio`, `pigeon_keeper`.

### `enemy` on fights: who you see across the fight screen

Every fight you write (`fight = true`) gets `enemy = "<foe id>"`. `foe` stays the name in
the text. Foe ids (`src/shared/City/Foes.luau`):

- kids and the street: `bully`, `street_kid`, `thug`, `rat`, `rat_boss`, `syndicate`, `workshop_brute`
- Fingers and Clans: `thumb_soldato`, `thumb_capo`, `middle_sibling`, `middle_big`, `index_proxy`, `index_messenger`, `ring_artist`, `kurokumo`
- Fixers: `fixer`, `zwei_fixer`, `shi_assassin`, `liu_fixer`, `seven_fixer`
- Wings, Corps, others: `wing_guard`, `kcorp_staff`, `rcorp_rabbit`, `wcorp_cleanup`, `lcorp_agent`, `bloodfiend`, `inquisitor`, `hunter`
- not people anymore: `sweeper`, `distortion`, `abnormality`, `ordeal`, `peccatula`, `beast`, `crow`

Kids fight bullies, street kids, stray beasts and crows. Not Thumb soldiers.

### Fighting styles are found, not picked

From v0.8 a life starts with no fighting style. It finds one through play, mostly ages
12-18. A result `style = "tremor"` gives that style (tremor, rupture, bleed, burn, sinking,
poise, charge). Condition `noStyle = true` limits an event to lives without a style yet.
Choices that lead to a style describe what you do, not the style's name; the result log
names it ("You fight like Tremor now: every hit keeps shaking them.").

### Knowing the City: lore unlocks in order

Faction content (the Fingers, Fixer Offices and Associations, Wings, L Corp, Bloodfiends,
Limbus Company, the Library, Distortions) is now locked until a life has heard of that
faction, and never shows before a minimum age. A life learns through events that set these
flags:

| flag | who | their own content shows from age |
|---|---|---|
| `knows_night` | the Night in the Backstreets, Sweepers | 6 |
| `knows_syndicates` | Syndicates, Rats, street gangs | 10 |
| `knows_fixers` | Fixers, Offices, Associations, Grades, Hana | 12 |
| `knows_wings` | the Wings, Nests, Feathers | 10 |
| `knows_distortions` | Distortions, E.G.O | 12 |
| `knows_thumb` | the Thumb | 14 |
| `knows_middle` | the Middle | 14 |
| `knows_index` | the Index, Prescripts, Proxies | 14 |
| `knows_ring` | the Ring | 15 |
| `knows_fingers` | the Fingers in general, the Clans (Kurokumo, Ricardo) | 14 |
| `knows_lcorp` | Lobotomy Corporation, Abnormalities | 14 |
| `knows_bloodfiends` | Bloodfiends, the Families | 14 |
| `knows_limbus` | Limbus Company | 16 |
| `knows_library` | the Library | 16 |

The story writer builds a ladder for each: a rumor (ages 5-12) that sets `knows_X`, a
sighting (ages 8-16, `when.flags = { "knows_X" }`) that sets `seen_X`, and a first brush
(ages 13-19, needs `seen_X`) that sets `met_X`. Everyone else: when your event mentions
a faction for the first time in a way the player would learn from, set its `knows_` flag
too. Never write a scene where a 7-year-old meets a Thumb Capo out of nowhere.

### Chapters

`src/shared/City/Chapters.luau` lists title cards by age (I. Born Under the Rail at 0, II.
The Rules of the Night at 6, ...). Each chapter has a story beat: an event with
`always = true, once = true, when = { minAge = A, maxAge = A }` (plus side or origin
conditions for variants) that fires the year the chapter starts.

---

## How many events now

Ages 1-3 get about 1.5 events a year, ages 4-60 about 2.5, elders 2. That's 25+ events per
childhood, so each age band needs a big pool or every life repeats. Write many, and make
them different from each other.

## Make every event earn its place

Mix formats:
- talking scene (dialogue, then a choice that matters)
- fight (`fight = true`, `enemy`, real stakes on both sides)
- check (a clash on a virtue that isn't a fight: lying, climbing, holding still, studying)
- quiet choice (no clash: who to help, what to keep, where to go)
- follow-up: plant a flag now, pay it off years later with `schedule = { event = "id", inYears = 3 }`
  (the follow-up has `weight = 0`)
- a short automatic event (`result` only) for texture, sparingly

Choices should differ in kind, not just in amount: a safe small option, a risky one with a
clash, a strange or costly one. Flags you set should come back later.

### Stakes (virtues are Fortitude = body, Prudence = mind, Temperance = skill/work,
Justice = nerve/fighting; Sanity runs from -45 to +45)

The player picks Steady, Reckless or Careful for every clash. Reckless makes wins pay more
and losses hurt a lot more; Careful softens both. So give every clash real numbers on both
sides, not flavor on the win side.

| ages | clash numbers (foe) | a win | a loss |
|---|---|---|---|
| 1-5 | avoid clashes; if any: `coins = 1, base = 1, coinPower = 2, fixed = true` | +1 virtue, sanity +2 | sanity -3 |
| 6-12 | `coins = 1, base = 2, coinPower = 2, fixed = true` (harder: base 3) | +1..2 virtue, 5-20 Ahn | fortitude -2..-5, sanity -3..-5 |
| 13-17 | `coins = 1-2, base = 3-4, coinPower = 2-3` | +2..3 virtue, 10-60 Ahn | fortitude -4..-10, sanity -4..-6 |
| adults | medium `2/4/3`, hard `3/5/3`, deadly `3/6/4`, boss `4/7/4` | +2..4, 40-300 Ahn | fights: fortitude {-14,-6} to {-24,-12}; sanity -4..-10 |

Foes grow stronger with the player's age automatically (unless `fixed = true`).

---

## Files and ids

Only create the files assigned to you. Don't edit other files. Every id, flag and cast id
you add starts with your prefix. Use `weight` 8-14 for normal events (more for things
that should come up often), `once = true` for most story events.

## Check your work

```
lune run tests/run 30          # validates everything, then plays 30 lives
python3 tests/safety_scan.py   # must say 0 hits
```

Fix every error. Warnings about line length mean: shorten.
