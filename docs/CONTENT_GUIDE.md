# Content Guide

All story content lives in `src/shared/Content/`. The engine has no story baked into it.
To make a different game (your own setting, your own fan pack), you replace this folder.

```
Content/
  init.luau        -- the pack manifest: stats, zones, careers, forms, origins, activities...
  Events/
    Core.luau      -- engine hook events (breaking point, debt) – keep these ids
    *.luau         -- every other file returns an array of events
```

Every `Events/*.luau` file returns an array:

```lua
return {
	{ id = "...", title = "...", text = "...", ... },
	{ ... },
}
```

Run `lune run tests/run` after editing. It validates every id, key and reference and
plays thousands of lives to catch broken chains.

---

## Text tokens

These can be used in `text`, `log`, `label` and `hint`:

| Token | Becomes |
|---|---|
| `{name}` `{first}` `{last}` | the character's names |
| `{age}` `{year}` | current age / calendar year |
| `{zone}` | side + Ward ("the Gutters of Foundry Row") |
| `{district}` `{wardNumber}` | the Ward's name / number ("Foundry Row" / 7) |
| `{side}` | "the Charter" or "the Gutters" |
| `{corp}` | the company holding the Ward's charter ("the Ironmongers' Charter") |
| `{linked}` | first name of the linked friend (another player) the event is about |
| `{sender}` | inside `linked` effects: the first name of the player who sent them |
| `{career}` `{rank}` | career name / rank title (or "no one" / "") |
| `{currency}` | the pack's currency word ("scrip") |
| `{mother}` `{father}` `{sibling}` `{friend}` `{mentor}` `{rival}` `{child}` | first *living* relation of that kind (falls back to "someone") |
| `{newRelation}` | the relation added by this same result |
| `{actor}` `{actorDistrict}` | in events with `when.chronicle`: the other player who did it, and where |
| `{style}` | the character's fighting style |

Write cards in second person, present tense ("A man in a Sluice coat is knocking...").
Write `log` lines in second person, past tense ("You turned him away.").

---

## Conditions: `when` (events, activities) and `requires` (choices)

All keys are optional, and all of them must pass.

| Key | Example | Meaning |
|---|---|---|
| `minAge` / `maxAge` | `minAge = 18` | inclusive |
| `minYear` / `maxYear` | `minYear = 330` | calendar year (use for eras/timelines) |
| `side` / `notSide` | `side = "gutters"` or `{"charter"}` | which side of the Ward you live on |
| `district` / `notDistrict` | `district = "foundry"` or a list | which Ward you live in |
| `linked` | `linked = true` | a linked friend (another player) is online. The event picks one and `{linked}` names them |
| `linkedRough` | `linkedRough = true` | same, but both players turned on Rough Play |
| `career` | `career = "diver"` / `{"diver","brine"}` / `"none"` | current career id, `"none"` = unemployed |
| `anyCareer` | `anyCareer = true` | has any job |
| `minRank` | `minRank = 3` | rank index within current career (1 = lowest) |
| `form` | `form = "human"` / `{...}` | current form id |
| `world` | `world = { water = "low" }` or `{ water = {"low","normal"} }` | world-state values this year |
| `flags` / `notFlags` | `flags = {"owes_brine"}` | all present / none present |
| `min` / `max` | `min = { justice = 30, money = 100 }` | stat thresholds (`fortitude prudence temperance justice sanity money`) |
| `hasRelation` / `noRelation` | `hasRelation = "mother"` or `{"mother","father"}` | a *living* relation of any listed kind exists / doesn't |
| `hasGear` / `noGear` | `hasGear = "dock_knife"` or a list | carrying any of these items / none of them |
| `hasCondition` / `noCondition` | `hasCondition = "fog_lung"` or a list | has any of these conditions / none of them |
| `worldEvent` / `noWorldEvent` | `worldEvent = "breach_tidewell"` | a server-wide world event is on / isn't |
| `chance` | `chance = 0.25` | extra random gate |

---

## Results

A result is a flat table. All keys are optional.

```lua
{ log = "You won.", money = {20, 60}, sanity = 4, setFlags = {"saved_the_dog"} }
```

| Key | Example | Meaning |
|---|---|---|
| `log` | `"You ran."` | line added to the life log |
| `fortitude` `prudence` `temperance` `justice` `sanity` `money` | `5` or `{-8, -3}` | change (a `{min,max}` range is rolled) |
| `paycheck` | `0.35` | add this fraction of the current yearly salary |
| `setFlags` / `clearFlags` | `{"a","b"}` | story flags (any string) |
| `career` | `"diver"` | join a career at rank 1 (requirements are not re-checked) |
| `promote` | `true` | +1 rank in the current career |
| `quitCareer` | `true` | become unemployed |
| `side` | `"charter"` | move to that side of your Ward |
| `district` | `"kelpmarket"` | move to another Ward (you arrive in the Gutters) |
| `wage` | `{10, 30}` | money scaled by how well your Ward and side pay |
| `linked` | `{ money = 40, log = "{sender} sent you rent money." }` | effects delivered to the linked friend's life |
| `form` | `"tidetouched"` | change form |
| `gear` | `"oilskin"` | give an item (it replaces whatever is in that slot) |
| `loseGear` | `"oilskin"`, `"coat"` or `true` | lose that item, whatever is in that slot, or a random item |
| `condition` | `"broken_arm"` | add an injury or illness (an existing one restarts its timer) |
| `cure` | `"fog_lung"` or `"any"` | end that condition, or the first curable one |
| `quest` | `"missing_ferryman"` | start a side quest |
| `bond` | `{ 6, 12 }` | (interactions only) change your bond with the person this is about |
| `addRelation` | `{ kind = "friend", name = "Ossa Vell", bond = 60, age = {20,30} }` | name/bond/age optional |
| `relationBond` | `{ kind = "mother", amount = 10 }` | `kind` may also be `"family"` (all family) or `"all"` |
| `killRelation` | `"mother"` | first living relation of that kind dies |
| `schedule` | `{ event = "id", inYears = 2 }` or a list of these | queue a follow-up years later. When it comes due, its `when` is re-checked (minus `chance`) and it's skipped if that fails |
| `trigger` | `"event_id"` | queue another event this same year (same `when` re-check) |
| `die` | `"Drowned under the viaduct"` | the life ends with this cause |
| `cause` | `"Bitten in the shallows"` | if *this* result drops Fortitude to 0, this is the cause of death |

---

## Events

```lua
{
	id = "silt_cistern_noise",          -- unique; prefix by area
	title = "Noise in the Cistern",     -- card title
	text = "Something knocks under the floor every night...",
	weight = 10,                        -- relative odds among eligible events (default 10)
	once = true,                        -- at most once per life (default false)
	cooldown = 5,                       -- years before it can repeat (default 3)
	tags = { "silt", "danger" },        -- free-form, for your own organizing
	when = { district = "drownside", side = "gutters", minAge = 8 },

	-- EITHER an automatic result...
	result = { log = "...", sanity = -2 },

	-- ...OR choices (the player must pick one)
	choices = {
		{ label = "Leave it be", result = { log = "...", sanity = -3 } },
		{ label = "Pay the plumber", hint = "30 scrip",
		  requires = { min = { money = 30 } },
		  result = { money = -30, log = "..." } },
		{ label = "Go down there",
		  clash = { stat = "justice", foe = "Cistern thing", coins = 2, base = 4, coinPower = 3 },
		  win  = { log = "...", money = {10, 40} },
		  lose = { log = "...", fortitude = {-10, -5} } },
	},
}
```

Events reached only through `schedule` or `trigger` should use `weight = 0`, so they never roll randomly.

---

## The coin clash

Each side flips coins every round:

* **Power = base + (heads × coin power)**
* Your side scales with the chosen stat (0–100) through the pack's **clash curve**
  (`pack.clash`). With the starter values:
  `coins = 1 + floor(stat/30)` (max 4), `base = 1 + floor(stat/16)`, `coinPower = 2 + floor(stat/50)`.
  Change `coinsEvery`, `maxCoins`, `baseEvery` and `powerEvery` to make characters outgrow
  foes faster or slower, then check the result with `lune run tests/clash_table`.
* Gear, conditions, forms and the **approach** then adjust your side for that one clash.
* **Heads chance = 50% + sanity%** (clamped 5%–95%). A shaken mind flips worse.
* The higher power wins the round and the loser loses one coin. A tie re-flips.
* The side that runs out of coins loses.
* Optional clash keys: `sanity` (the foe's own sanity, which shifts its odds the same way),
  `ignoreSanity = true` (the player flips at a fair 50%, used by the breaking point) and
  `assist = true` (in a linked-friend event, the friend adds +1 coin to your side).
* Forms can add coins/base (see `pack.forms`). Surfaced coins never drop below 25% heads.

Foe difficulty reference (starter curve, Sanity 0, Steady):

| Feel | coins | base | coinPower | about even at a stat of | at stat 60 |
|---|---|---|---|---|---|
| easy | 1 | 2 | 2 | 20 | 100% |
| medium | 2 | 4 | 3 | 50 | 84% |
| medium-hard | 2 | 5 | 3 | 60 | 54% |
| hard | 3 | 6 | 3 | 80 | 23% |
| brutal | 4 | 8 | 4 | over 100 (needs gear, Sanity or a good approach) | 0% |

### Approaches

Every clash choice asks how the player goes in. `pack.approaches` lists them in `order`;
each has a `name`, a `desc` (shown on the card), an optional `clash = { coins, base, coinPower }`
adjustment, and an optional `after` result that's applied once the clash ends, win or lose.
The starter pack has **Steady** (no change), **Reckless** (+1 coin, then -4 Sanity and up to
-3 Fortitude) and **Careful** (+2 base, -1 coin). The event card shows the odds for each.

---

## Wards and sides

The city is split into **districts** (`pack.districts`, called Wards here). Every district
has the same two **sides** (`pack.sides`): a walled company enclave (`charter`) and the
slums around it (`gutters`). Each district sets its own wealth (pay), danger, rent, buy-in
price and birth odds. Each side multiplies rent, pay and danger.

* Events tagged `"danger"` become more or less likely with the side's and district's danger.
  Sides and districts can also weight other tags through `tagWeights`. The starter pack uses
  `crime`, `luxury`, `salvage`, `faith` and `study`.
* A side with `evictOnDebt = true` (the Charter) serves a **notice to quit** the first year
  you end in debt there. Stay in debt for more than `evictGrace` years in a row (default 1)
  and you're thrown out to the arrival side (the Gutters). Ending a year out of debt clears
  the notice.
* **Hazards** (`Content/Hazards.luau`) are yearly bad luck. The chance per year is
  `side.hazardChance x district.danger`. Each hazard has `id`, `title`, optional `side`,
  optional `district`, `weight`, `when` and `result`.

## Gear

`pack.gear` has `slots` (the starter pack uses `tool`, `coat` and `charm`), an `order` (the
workshop's list) and one entry per item:

```lua
oilskin = {
	name = "Oilskin Coat", slot = "coat", price = 50,
	desc = "Keeps the fog off, mostly.",                 -- flavor, shown in the workshop
	effect = "+1 base in Fortitude clashes, hazards 15% less likely", -- what it does, in words
	clash = { fortitude = { base = 1 } },                -- per-stat coins / base / coinPower
	hazardGuard = 0.85,                                  -- multiplies the yearly hazard chance
	-- optional: minAge = 14, requires = { career = "diver" }, yearly = { sanity = 1 }
},
```

An activity with `shop = true` opens the workshop instead of running a result. Buying
doesn't use an action. Events can hand out or take gear with the `gear` and `loseGear` results.

## Conditions (injuries and illnesses)

`pack.conditions` holds lasting effects that tick every year until they run out:

```lua
broken_arm = {
	name = "Broken Arm", years = 2,
	desc = "-1 coin in Justice clashes, -1 base in Temperance clashes.",
	gainLog = "Your arm is broken. It will take a long time to set.", -- logged when it starts
	clash = { justice = { coins = -1 }, temperance = { base = -1 } },
	-- optional: healLog = "..." (logged when it runs out), yearly = { sanity = -2 }
	-- (any result, applied each year), curable = false (a stitcher can't fix it)
},
```

Hazards and lost clashes add them with `condition = "id"`. The starter stitcher activity
uses `cure = "any"`.

## Records

`pack.records` are achievements checked when a life ends. Each one gives 1 Glow the first
time a player earns it.

```lua
{ id = "old_bones", name = "Old Bones", desc = "Live to 80.", check = { when = { minAge = 80 } } },
```

`check` can use `when` (any condition from the table above, tested on the final life),
`bornSide`, `minPeakMoney`, `minPeakRank`, `minMoves`, `minChildren`, `heir = true`
and `causeHas` (text in the cause of death).

## Linked friends

Players in the same server can link lives in the Friends tab. Events with
`when = { linked = true }` only fire while a linked friend is online, and `{linked}` names
that friend. A result's `linked = {...}` is applied to that friend's life (their log gets
the line, with `{sender}` as your first name). Linked effects can't use `linked`, `die`,
`schedule` or `trigger`. `linkedRough = true` gates events where friends can hurt each other;
both players must turn on Rough Play.

## Expeditions (`Content/Expeditions.luau`, `MoreExpeditions.luau`, `QuestExpeditions.luau`)

Missions, dungeons, trips and containment jobs: a run of stages, each a card with choices.
Solo, or a crew of players (the captain chooses; everyone gets the results; clashes are fought
by the crew member best at that stat with +1 coin per extra member, up to +3).

```lua
my_dive = {
	name = "The Sunken Strongroom", kind = "dungeon",       -- mission | dungeon | trip | containment
	desc = "...", minAge = 16, cost = 10, cooldown = 2,     -- cooldown is in years, per life
	crew = { min = 1, max = 4 }, length = 4,                -- length is shown on the card
	when = { district = "foundry" },                       -- who can see it (any condition)
	start = "door",
	stages = {
		door = {
			title = "The Door", text = "...", tone = "danger",   -- tone is optional
			choices = {
				{ label = "Pick the lock", clash = { stat = "temperance", foe = "The lock", coins = 2, base = 5, coinPower = 3 },
				  win = { log = "{champion} got it open." }, lose = { fortitude = -4, log = "..." },
				  winNext = "vault", loseNext = "flood" },
				{ label = "Leave", ["end"] = "retreat", result = { log = "{crew} turned back." } },
			},
		},
		-- more stages...
	},
	success = { wage = { 80, 160 }, log = "..." }, fail = { sanity = -3, log = "..." },
}
```
A choice leads on with `next` (or `winNext`/`loseNext` after a clash) or ends the run with
`end` (`winEnd`/`loseEnd`): `"success"`, `"fail"` or `"retreat"`. A choice with neither ends it
as a success. Tokens: `{crew}` ("you" or "your crew"), `{crewNames}`, `{champion}`.
A finished success sets the flag `done_<id>`; crews patch each other up on the way home (half
the Fortitude the run cost after a success, a third after turning back).

## Side quests (`Content/Quests.luau`)

```lua
missing_ferryman = {
	name = "The Missing Ferryman", desc = "...", giver = "The harbormaster", expires = 6,
	steps = {
		{ text = "Ask around the docks.", hint = "Activities: Ask about the empty ferry",
		  onStart = { setFlags = { "q_ferry_ask" } },          -- runs when the step begins
		  check = { when = { flags = { "q_ferry_clue" } } },   -- when the step is done
		  doneLog = "A net-mender saw the ferry stop at the cannery." },
		{ text = "Search the cannery pilings.", onStart = { setFlags = { "q_ferry_search" } },
		  check = { when = { flags = { "done_cannery_pilings" } } } },
	},
	reward = { wage = { 80, 150 }, log = "..." },
}
```
Start a quest from any event or activity result with `quest = "id"`. Steps usually set a flag
that opens a quest activity (`Content/QuestActivities.luau`) or expedition
(`Content/QuestExpeditions.luau`), or `schedule` a scene. `check` uses the same keys as
Records. Players see their quests under **Life > Quests**.

## World events (`Content/WorldEvents.luau`)

Server-wide happenings. `name`, `headline` (the banner), `text`, `minutes` (how long it lasts),
`weight`, `tone` (`"danger"`/`"strange"`), `district` (where it's centered), `tagWeights`
(events with those tags get likelier), `startEvent` (queued in everyone's life),
`expedition` (open while it lasts) and `endText`. Events that only happen during one use
`when = { worldEvent = "id" }`.

## Ambitions and titles (`Content/Ambitions.luau`, `Content/Ribbons.luau`)

Ambitions: `id`, `name`, `desc`, `minAge`, `maxAge`, `weight`, `when` (who can draw it),
`check` (when it's met), `reward` (a result) and `progress` (for the bar: `{ money = N }`,
`{ age = N }`, `{ rank = N }`, `{ stat = "justice", target = N }`,
`{ tally = "clashesWon", target = N }`, `{ children = N }`).

Titles: checked top to bottom when a life ends; the first `check` that passes names the life.
The last one has no check. `check` takes the Records keys plus `minGeneration` and
`tally = { clashesWon = 40 }` (tallies: `clashesWon`, `clashesLost`, `reckless`,
`expeditions`, `ambitions`, `interactions`, `quests`).

## Interactions (`pack.interactions` in `init.luau`)

Things you do with one person from the People tab. `name`, `desc` (`{rel}` names them),
`kinds` (which relation kinds), `linked = true/false` (only/never linked friends),
`online`, `minAge`, `relMinAge`, `relMaxAge`, `minBond`, `maxBond`, `cost`, `cooldown`
(years, per person), then a `result` or a `clash` + `win` + `lose`. Use `bond = {min,max}` to
change the bond with them, and `logs = { mother = "..." }` to vary the line by who they are.

## Cosmetics (`Content/Cosmetics.luau`)

Categories: skin, hair (with a `style` the avatar draws), hairColor, outfit (`shirt`,
`pants`, `shoes`, and optional `belt`, `apron`, `vest`, `tie`, `robe`, `buttons`, `collar`),
mark (`style` and optional `color`) and frame (the file card's bracket color). An option is
locked by `glow = N`, `record = "id"`, `daily = 7` (a login streak) or `store = "item_key"`
(Config.store). Skin tones can't be locked. Gear, conditions and forms change the figure
through their own `look` fields.

## Packs

`Shared/Pack.luau` picks the content pack from `Config.pack`: `"City"` (the Project Moon City,
in `Shared/City/`) or `"Undermere"` (the original setting, in `Shared/Content/`). Both use the
same format. A pack with `fanWork = true` turns the Robux store off: fan games stay non-commercial.

## Fights and checks

Not every risky choice is a fight. A pack with `quickChecks = true` shows ordinary clashes as a
quick **check** (a small card with the coins and SUCCESS/FAILED). Only a clash with
`fight = true` gets the full fight screen, uses the player's **fighting style**, and can carry a
foe status:

```lua
clash = { stat = "justice", foe = "A Thumb Soldato", coins = 2, base = 5, coinPower = 3,
          fight = true, status = { id = "burn", potency = 2 } }  -- status: the foe's own
```

Use `fight = true` when the scene really is a fight (a brawl, a duel, a mugging, a breach).
Talking, sneaking, studying, climbing, enduring: those are checks.

### Status effects (fights only)

Every heads a side lands builds its status by its potency, whether it won the round or not.

| Status | Kind | Effect |
|---|---|---|
| Tremor | mark | x2 per heads; at 5 it bursts and the target loses a coin (staggered) |
| Rupture | mark | hits on the target land harder: +1 power per point (max 6), -1 a round |
| Bleed | mark | the target loses power when it lands heads (max 5), -1 each time |
| Burn | mark | the target loses half the burn in power every round (max 3), -1 a round |
| Sinking | mark | x2 per heads; the target's heads chance drops 5% per point, -1 a round |
| Poise | buff | x2 per heads; each heads may crit and count twice (15% per point, max 75%) |
| Charge | buff | +1 a round and +1 per heads; at 4 it discharges for +(potency + 2) power |

## Fighting styles, mastery and the build

```lua
pack.styles = {
	order = { "tremor", "rupture", ... },
	tremor = { name = "Tremor", desc = "...", color = { r, g, b }, status = "tremor" },
}
pack.maxMastery = 5            -- training levels; potency = 1 + floor(mastery / 2) (+ traits)
pack.build = { points = 10, maxPer = 5, perPoint = 2 }   -- bonus stat points at creation
pack.statuses = { tremor = { name = "Tremor", color = {...} }, ... }  -- optional UI names/colors
```

Results: `mastery = 1` (train), `style = "bleed"` (learn a new style).
Conditions: `style = "rupture"`, `minMastery = 3`. Token: `{style}`.

## Traits

```lua
pack.traitPicks = 2            -- how many a player picks at creation
pack.traits = {
	order = { ... },
	steady_hands = {
		name = "Steady Hands", desc = "...",
		pick = true,                  -- can be picked at creation
		category = "mind",            -- optional grouping
		stats = { temperance = 4 },   -- one-off, when gained
		sanity = 3, money = 50, flags = { "..." },
		clash = { prudence = { base = 1 }, any = { coins = 0 } },  -- every clash of that stat / any
		fight = { coins = 0, base = 1, coinPower = 0, potency = 1 },  -- fights only
		heads = 3,                    -- +% heads chance in every clash
		inherit = true,               -- heirs inherit it
	},
}
```

Results: `addTrait = "id"` / `removeTrait = "id"` (or lists). Conditions: `trait = "id"`
(any of a list), `noTrait = "id"`.

## Lore: the Archive (codex)

```lua
pack.codex = {
	categories = { { id = "city", name = "The City" }, ... },
	entries = { { id = "city_head", category = "city", title = "The Head", text = "...", secret = false }, ... },
}
```

An entry unlocks with a result `codex = "id"` (or a list), or with `codex = "id"` on an event
(it unlocks when the event shows up). Found entries are kept for the account, across lives,
and show in the Archive side panel. `secret = true` entries are hidden until found and counted
apart ("2/10 secrets"). Write entries in an in-world voice, a few short paragraphs each.

## Today in the City (daily events)

```lua
pack.daily = {
	order = { "thumb_tribute", ... },
	thumb_tribute = { name = "Tribute Day", desc = "...", event = "daily_thumb_tribute" },
}
```

The same daily event runs on every server, changing at 00:00 UTC. One activity with
`daily = true` (no `result` needed beyond a short log line) lets a player trigger today's event
once a day. Events and activities can also check `when = { daily = "thumb_tribute" }`.

## The chronicle: lives that cross

```lua
pack.chronicle = {
	thumb_betrayed = { text = "{name} crossed the Thumb in {district}.", announce = true, tone = "danger" },
}
```

A result `chronicle = "thumb_betrayed"` records the deed for this server: it shows in everyone's
City panel, goes into the chat if `announce = true`, and switches on events written for other
players: `when = { chronicle = "thumb_betrayed" }`. In those events `{actor}` is the player who
did it and `{actorDistrict}` where. This is how one player's story reaches another's.

A result `announce = "text"` posts one line of city news to the chat (rate-limited per player).
A result `rolls = 1` gives family-name rolls for a big moment.

## Family names (surname rolls)

```lua
pack.surnames = {
	tiers = { { id = "common", name = "Common", weight = 60, color = {...}, trait = nil, desc = "..." }, ... },
	names = { common = { ... }, uncommon = { ... }, rare = { ... }, epic = { ... }, legendary = { ... } },
	pityAt = 10, pityTier = "rare",
}
```

Rolls are earned, never sold. Tiers can grant a trait to every life that carries the name.

## Intro

The join cinematic (`client/UI/Intro.luau`) plays in full on a player's first join, and as a
short title sting on later joins (Menu > Display > Intro when you join: Full, Short, Off). It
hands straight over to the mode select.

```lua
pack.intro = {
	cold = { place = "District 23 · The Backstreets", from = "03:12:55", to = "03:13:00",
	         stamp = "The Night in the Backstreets", line = "Get indoors." },
	cards = { { word = "Wings", line = "...", shot = "nest", color = { r, g, b } }, ... },
	title = "...", subtitle = "...",
	lines = { "..." }, -- packs without cards: plain narration instead of the montage
}
```

`cold` is the cold open: a clock ticks to `to`, the screen jolts, and `stamp` slams in.
`cards` is the montage, one diagonal title card per entry. `shot` picks a camera shot in the
3D City (`client/BackdropCity.luau`, `SHOTS`: `alley`, `night`, `nest`, `lcorp`, `fingers`,
`city`, `title`); add your own there.

## More of everything

Extra content can live in its own files, merged in by `init.luau`: `MoreActivities.luau`,
`QuestActivities.luau`, `CareerActivities.luau` (activity lists), `MoreCareers.luau` and
`MoreExpeditions.luau` (`{ order = { ids }, [id] = def }`), and any module in `Events/`.

## The City pack's layout (`src/shared/City/`)

The City pack (the default, `Config.pack = "City"`) keeps almost everything in folders, and
`init.luau` merges every module in each folder. Several writers can work at once without
touching the same file. Each folder is merged in a fixed order: `Core` first, then the
others by name. A duplicate id across files is reported as a validation error; it never
silently overwrites another entry.

| Folder | Each module returns |
|---|---|
| `Events/`, `Activities/`, `Lore/`, `Ambitions/`, `Records/` | a list |
| `Careers/`, `Traits/`, `Daily/`, `WorldEvents/`, `Gear/`, `Expeditions/`, `Quests/` | `{ order = { ids }, [id] = def }`; every id must be in `order` |
| `Chronicle/`, `Conditions/` | `{ [id] = def }` |
| `Ribbons/` (titles) | a list. Titles from other files go just before the catch-all, or before the title named in `before = "id"` |

Single files: `Hazards.luau`, `Surnames.luau`, `Cosmetics.luau`.

Conventions:
- **Id prefixes.** Every id a writer adds starts with their area's prefix: `bs_` for
  Backstreets life, `lc_`/`wg_` for L Corp and the Wings, `fx_`/`fn_` for Fixers and the
  Fingers, `lib_`/`lim_` for the Library and Limbus.
- **Eras.** `world.era` follows the year: `wings` up to 977, `white_nights` in 978,
  `library` from 979 to 982, and `limbus` from 983. Gate content with
  `when = { world = { era = "limbus" } }`.
- **Eras of birth.** The player picks one in the creator (`pack.calendar.eras`):
  - `wings`, born around 930: time to climb L Corp to Branch Manager;
  - `twilight`, born around 950;
  - `distortion`, born around 968.
- **Canon.** Facts come from `docs/CANON.md`.
- **Checks.** `lune run tests/city_check` checks the City pack:
  - every career can be joined and climbed;
  - every chronicle act is recorded and echoes into other players' lives.

  `python3 tests/safety_scan.py` scans all City text for content Roblox doesn't allow.

The pack's words for shared screens live in `pack.meta`: `releaseVerb` ("Shelve"),
`releaseToast`, `heldBy`, `unheld`, `unheldShort`, `arrivalName`, `emptyLedger`, `dailyTitle`.

## v0.7 features (City pack)

### Gear with Limbus-style effects (`Gear/*.luau`)
| Field | Meaning |
|---|---|
| `rarity` | `common` / `uncommon` / `rare` / `epic` / `legendary` / `unreal`; shown in color |
| `effect` | plain words, buffs first, then "Debuff: ..." |
| `clash = { stat = { coins, base, coinPower } }` | in every clash on that stat |
| `fight = { coins, base, coinPower, potency }` | in fights only |
| `style = "tremor"` | the item's buffs only work with that fighting style |
| `heads = n` | +/- heads chance in every clash |
| `resist = { burn = 2 }` | lowers that status on the foe by 2 in fights |
| `toughness = 0.85` | take 15% less Fortitude damage |
| `yearly = { sanity = -1, money = -15 }` | a yearly debuff (or buff) |
| `hazardGuard = 0.8` | yearly bad luck is 20% less likely |
| `unique = true` | never sold. For boss drops and rewards: `result = { gear = "id" }` |

Look kinds: knife, pole, pistol, sword, hammer, gauntlet, book, greatcoat, jacket, coat, stone,
token, bell.

### Books (`Books/*.luau`)
`{ order = {...}, [id] = { name, desc, rarity, trait = "ability_trait", mastery = n } }`.
Give one with `result = { book = "id" }`; check for one with `when/requires = { hasBook = "id" }`
(or `noBook`). Holding a book adds a "Read: ..." activity, and reading it teaches its trait.
Unread books pass to heirs. Put the abilities they teach in a `Traits/` file (earned, no `pick`).

### Talents (`Traits/Talents.luau`)
Every life is born with one talent. It's a trait with `talent = "common" | "uncommon" | "rare" |
"epic" | "legendary" | "unreal"`; the odds are set in `pack.talents`. Trait fields for talents
(and any trait):

| Field | Meaning |
|---|---|
| `growth = 1.3` or `{ justice = 1.5 }` | stats grow faster from results |
| `masteryGrowth = 2` | style mastery grows faster |
| `toughness = 0.8` | take less Fortitude damage |

### Affinities: the seven sins (`pack.affinities` in `init.luau`)
`{ order = { ids }, [id] = { name, color, desc } }`. Give every talent `affinity = "wrath"`
(or another sin). A player leans toward up to two sins in the creator: within the rolled
rarity, talents of those sins are `Sim.AFFINITY_WEIGHT` (3) times as likely; the rarity odds
never move. A talent that matches resonates: `pack.affinityResonance` (+3%) heads in every
clash. Heirs keep their parent's sins. The City check wants a talent of every sin at every
rarity.

### Looks: signature weapons and identities (`Cosmetics.luau`)
`weapon = { name, options = { { id, name, kind, color, trim, glow | record | store } } }` is
the signature weapon drawn in the hand from 16 on, unless real gear is held. Kinds: knife,
pole, pistol, sword, katana, greatsword, spear, axe, hammer, gauntlet, censer.
`identities = { { id, name, desc, look = { category = optionId } } }` are the premade
characters the creator offers first; locked picks fall back to free ones.

### Danger
`pack.lethality` multiplies every Fortitude loss (1.45 in the City), and
`pack.clash.foeGrowth` makes foes tougher as you age. Write fights and deadly choices knowing
that losses hit harder.

### Milestones
`always = true` on an event (with `once = true`) means it fires whenever it's eligible, on top of
the random roll. Use it for the world's turning points.

### Game modes (`pack.modes` in `init.luau`)
`{ id, name, tagline, desc, color, era, unlock = { record, pass, light }, start = { age, form,
career, rank, traits, stats, money, flags, mastery, books, log } }`

### Fixer rankings (`pack.rankings` in `init.luau`)
`pack.rankings.fixer = { careers = { [careerId] = { gradeForRank1, gradeForRank2, ... } },
colorFlag = "color_fixer" }`. Grades run 1 (Grade 9) to 9 (Grade 1); the color flag is 10.
The best one a life reaches goes on the **Fixers** leaderboard (ties go to fights won). The
**Fights** board counts fights won in one life.

### The guidebook (`Guide.luau`, `server/Guide.luau`)
`pack.guide.basics = { { title, text } }` is the "Start here" page. Everything else in the
guidebook is built from the pack: stats, statuses, styles and build types, talents with their
odds, pickable traits, gear (`effect`, `rarity`, `unique`), books, careers, `pack.factions`,
modes, family names, world events and expeditions. Write `desc` and `effect` lines so they
read well on their own there.

### Factions (`Factions.luau`)
`{ order = { ids }, [id] = { name, kind, desc, join, perks, career, color } }`, shown in the
guidebook's Factions page. `perks` is what joining gives you (and costs you), in plain words.

### Store items priced in Lunacy (`Store.luau`)
Robux items have `kind = "product" | "pass"`, `id` and `price`. Items with `lunacy = cost`
instead are bought in game with Lunacy (`storeSpend`, after a confirm). Lunacy itself is
sold with `grants = { "lunacy:N" }`. `random = true` items must show `odds` (the validator
checks), and the server hides them where Roblox restricts paid random items.

## Pack manifest (`Content/init.luau`)

`meta`, `calendar`, `stats`, `clash`, `sides`, `districts`, `world`, `careers`, `forms`, `origins`,
`activityCategories`, `activities`, `gear`, `conditions`, `approaches`, `records`, `hazards`,
`relationKinds`, `interactions`, `cosmetics`, `expeditions`, `quests`, `worldEvents`, `ambitions`,
`ribbons`, `names`, `epitaphs` and `hooks`. A district can also set `music` (a mood from
Config.music) and `backdrop = { tint, fog, clock, haze }` for its spot in the 3D city.
Open the file. Every field is commented.

## Roblox content rules

This kit targets Roblox's **Moderate** maturity label. Keep violence implied and focused on the aftermath. No gore
detail, no sexual or romantic content, no alcohol or drugs, no gambling, no profanity,
and no self-harm. Relationships are family, friends, mentors, rivals and adopted children.

## New in v0.10: what content can do now

**Stats are the pack's own.** `pack.stats.order` lists them, `vital` names the one that kills at
zero, and `roles` says which stat does which job (`fight`, `work`, `will`, and optionally `speed`,
`charm`, `luck`). A result key, a `min`/`max` condition or a clash `stat` can be any stat in the
list. `birth = { min, max }` on a stat deals it its own way at birth; `grow` and `growPicks` are
what children pick up just by growing.

**Speed.** With a `speed` role, a fight's coins come from Speed and the faster side strikes first.
A clash can set `speed = n` for its foe; a foe in `Foes.luau` can be `speed = +/-n` quicker or
slower than its coins say. Gear, traits and conditions can carry `speed`, `luck` and `charm`.

**Variants.** `text`, `title`, `log`, a choice `label` and a dialogue `line` can each be a list:
`text = { "one way", "another way" }`. Each life is dealt one, always the same one.

**Cast names.** `names = { "Mr. Osei", "Mr. Baek" }` on a cast entry gives them other names (and
faces) in other lives. Wherever an event's words use the first `name`, the life's own is put in.
`short = "Varga"` does the same for a short form.

**Reputation.** `pack.reputation` (see `City/Reputation.luau`). Results: `rep = { thumb = -30 }`.
Conditions: `minRep = { thumb = 20 }`, `maxRep = { thumb = -20 }`. A foe with `faction = "thumb"`
costs standing when beaten. A faction's `reprisal` events (weight 0) are queued by the engine when
standing is at its `grudge` or worse.

**Luck.** `lucky = true` on an event makes it likelier for the lucky; `unlucky = true`, less.

**Approaches with a price.** `sanityCost = { base, per, min }` on an approach is paid in Sanity,
less for a stronger `will` stat. `requires` (conditions) and `fightOnly` say who can take it.

**Districts.** An activity with `when = { district = "d21" }` in the `district` category is a
place only people living there can go. `pack.districtEventBoost` makes District events likelier.

**People.** `pack.meta.socialPerYear` gives interactions (and `social`/`family`/"people"
activities) their own yearly budget.

**Difficulty.** `pack.difficulties` (order, default, and per level: name, desc, lethality,
foeBase, hazard, score).

**Issued gear.** `issue = "<gear id>"` on a career hands it over on the first day.

**Ages.** A `pack.world` variable with `byYear` follows the calendar; `hide = { value = true }`
keeps a value out of the City tab. `pack.eraRules` words are checked by `tests/era_check`.
`pack.eraBound` (`careers`, `flags`, `traits`, `forms`) says which ages a thing exists in, so a
condition on it counts as an age condition.

**Checks that don't grow.** `fixed = true` on a clash keeps it out of the age curve
(`pack.clash.foeGrowth`) and the difficulty's `foeBase`. Use it when the thing you're up against is
yourself (the brink, Shin, a ring of Mang), so the odds depend on the stat and nothing else. With
the City's curve, a fixed foe of 2 coins / 5 base / +3 is about 20% at a stat of 55, 55% at 75 and
85% at 90; `lune run tests/odds` prints the table for any foe.

**The menu.** `pack.meta.about` is one paragraph on what the game is; the wide start menu shows it.
A mode's `desc` is shown on its card there.

## New in v0.11: what content can do now

**Ways of fighting.** An approach with `stat = "<stat id>"` is a way of fighting with that stat
(fights only). `beats` and `loses` name tempers (`pack.tempers`): +2 or -2 base
(`pack.matchup`). `only = "person"` hides it against creatures and anything `mute`.
`bloodless = true`: winning costs no standing with the foe's faction. `foeHeads = -10` spoils
their coins. A foe's `temper` goes in `City/Foes.luau` (the `TEMPER` table); a clash can set
its own with `temper = "brute"`.

**Tier perks.** `pack.stats.perks.<stat>[tier] = { name, desc, <effect> }`, tiers 2 to 5 (every
20 points). Effects: `actions`, `social`, `toughness`, `sanityGuard`, `wage`, `price`,
`training`, `egoMin = true`, `stance = { base, coinPower }`.

**Nature.** `pack.stats.natures` (order, min, a name and desc per stat). An event leans toward
a nature through the stats its choices test, or say so with `draws = "charisma"`.
`pack.natureDraw` is how much likelier.

**Jobs.** `City/Jobs.luau`: families of jobs by career. A job is `{ id, name, line, stat | fight
= true (+ foe, enemy, temper), tier, pay, win, lose, cost, rep, minRank, when }`. It is pitched at
the stat the next rank asks for, so it needs no numbers of its own.

**Scenes with someone.** An event with `social = { kinds, minBond, maxBond, relMinAge,
relMaxAge, minAge, maxAge }` and `weight = 0` is a scene "spend time" can open. Use `{rel}` for
their name; a `bond` in a result lands on them.

**Second stories.** A storyline with `act = 2` finds a grown life between stories. Its beats use
`when = { storyYear = n }` (years since it began; also `minStoryYear`, `maxStoryYear`).

**A story's cast.** `cast = { "cast_id", { who = "{mother}", line = "Counts heads at ten past three" } }`
on a storyline puts those people in the Story tab with their faces. A cast id shows its `title`
under the name; `line` replaces it (70 characters at most). Relation tokens show the life's own
family. Anyone who speaks in a chapter the life has lived is added after them, five in all.

**Threads.** A card's thread is worked out from its conditions (story, work, people, District,
age, grudge, brink...). Set `thread = "work"` to say it yourself.

**Cutscenes.** `cutscene = { style, kicker, title, lines }` on an event plays before its card;
on a result, before its words. Styles: `age`, `light`, `dark`, `voice`, `ego`, `distortion`,
`story`. An age's `opening = { three lines }` (in `pack.calendar.eras`) plays at birth.

**Scenes (v0.14).** `scene = { set, time, title, kicker, line, voice, reply, other, stand }` on
an event plays a 3D scene before its card: you walk up to `other` and they speak `line` (or you
do, `voice = "you"`, or a narrator). `other = { name, role, pose = "sit" | nil, look?, age? }`
for one of this game's own people, `{ rel = "rival" }` for someone from your own life, or
`{ name, foe = "<foe id>" }` to borrow a foe's look. Sets: `street`, `alley`, `facility`,
`rooftop`, `room`, `nest`, `underpass`, `hall`, `lake`, `stairs`, `gym`. Leave `other` out and you
walk in alone while the line is narrated. Scenes on "spend time" cards come for free: the
person you're with is put in them. Never put a canon character in a scene. Full example in
`docs/PLAN_v0.14.md`.

**Keep it short.** A card shows about two sentences before "more". A feed row shows one line.
Activity and job descriptions are tooltips. Write the first sentence so it stands alone.

## New in v0.18: earned traits, more talents, the 3D stage, your Office, focus, harder cards

- **An earned trait** is a trait with an `earn` table: nobody picks it and no card gives it; it
  comes by itself the first year its need holds (`Engine/Feats.luau`, earnTraits), with a line
  in that year's feed. The need keys are the feats' own: `age`, `money`, `peakMoney`, `renown`
  (grade), `stat = { strength = 150 }`, `anyStat`, `allStats`, `flags = { ... }`, `episodes`,
  `cases`, `blocks`, `office`, `home`, `children`, `closeFriends`, `married`, `uniques`,
  `legendary`, `delves`, `form`, `careerTop`, `lives`, `clashes` (fights won). Every key in a
  need must hold. Put them in `City/Traits/Earned.luau` (and its `order`); the validator checks
  the keys. A trait's effects are the usual ones (`stats`, `clash`, `fight`, `heads`, `sanity`,
  `toughness`, `money`).
- **A talent** is a trait with a `tier` (common to unreal) and an `affinity` (one of the seven
  sins), listed in the pack's talent pools; `City/Traits/Talents3.luau` has 60 more. Names
  must be unique across every talent and trait (the validator says which clash).
- **The 3D stage** draws boss battles and duels. A boss picks its set from its id
  (`Arena.setFor` in `client/UI/Arena.luau`: clock, claw, index and messenger fight in the
  street; whale and lake by the lake; aleph and breach in the facility; color and lantern on a
  rooftop; sweeper, night, hunter, thumb and capo in an alley; any creature in an underpass;
  the rest in a hall). Add a word there for a new boss that needs another place. Statuses get
  their own effect by id (`burn, bleed, tremor, rupture, sinking, poise, charge` in
  `client/UI/Fx3D.luau`); a new status falls back to a plain hit.
- **A hidden game mode** (`hidden = true` in `pack.modes`) is off every menu and can't be
  started, unless `Config.devModes` is on (the tests use that). Lives already in it carry on.
- **Your own Office** is tuned in `pack.offices` (`City/init.luau`): `hireAge`, `hireBond` (and
  `hireBondMet` for someone you've only met), `colors` (the sign's colours: `{ id, name, color }`),
  `grades[1..9]` (`wage`, `earn` a year), `buildings` (`name, desc, price, crew` desks, `income`
  multiplier, `minSize` of the Office, `minRenown` grade), `rooms` (`id, name, desc, price,
  building` it needs) and `experiment` (`cost`, weighted `outcomes` with `stat`, `limitBreak`,
  `money`, `health`, `sanity`, `text`, `tone`). `Engine/Office.luau` runs it.
- **Follow-ups make a focus** (`Engine/Focus.luau`): any card joined to another by `schedule`
  or `trigger` is a thread; when one comes up it's the life's focus. Cards that share a codex
  entry are one subject, and so is a whole family of ids listed in `pack.focus.topics` (with a
  name in `pack.focus.names`, as `lib_` is "The Library"). An event can name its subject with
  `focus = "key"`. Tuning: `pack.focus` (`years`, `boost`, `others`, `minTopic`).
- **Harder cards** (`pack.hardness`): every clash on an event card gets `cardBase`; a card
  tagged `danger` (or with `dread = true`) gets `dangerBase` more, `dangerCoins` in a fight and
  grows with the stat it's faced with (`match`). `fixed = true` on a clash opts it out (a ledge
  doesn't get stronger), and a storyline's own chapters (`story = ...`) keep their tuning. The
  difficulty scales it (`pack.difficulties[id].hardness`). A **dread card** (`dread = true`) is drawn by the yearly dread roll
  (`hardness.dread`) along with every other `danger` card, and comes `dreadWeight` times as
  often; put them in `City/Events/Dread18.luau` and give each a real price and real pay.
- **An expedition's tier** is worked out from its strongest clash (base + coins; a `battle`
  makes it V); `pack.expeditionPay[tier]` multiplies what a success pays and adds a `bonus`
  (`limitBreakFight = n` raises the limit of the life's fight stat). Write a run's `success` for
  an ordinary run; the tier makes a hard one pay.

## New in v0.17: trainers, techniques, arms, extreme bosses, long lives

- **A trainer** is one entry in `City/Trainers.luau`: `id, name, short, role, stat, gain, also,
  fee, when` (who can find them; `school = "zwei"` for an Association's own), `accept` and/or
  `test` (asking, or proving yourself), `teaches = { { id = "tq_x", at = 3 } }`, `limit = { per,
  every, times }`, and the lines (`text, line, yes, no, farewell`). Their meeting card and their
  lesson activity are built from it; give them a `look` in the LOOKS table at the bottom.
- **A technique** is an approach in `City/Techniques.luau` with `requires = { flags = { "tq_x" } }`
  (a trainer sets the flag) or `requires = { hasGear = "aug_x" }` (an arm). Use the stat's
  matchup (STR/SPD/INT helpers) and the canon status of the school that owns it.
- **An augment arm** is gear with `slot = "arm"` and `look.kind` one of `Avatar.armKinds`
  (`arm_piston`, `arm_blade`, `arm_chain`, `arm_furnace`, `arm_carapace`, `arm_rhino`,
  `arm_grown`, `arm_spring`, `arm_needle`); pair it with its `arm_*` technique.
- New result keys: `lifespan = years` (a body that lasts longer), `train = { find | start |
  lesson | leave }`. New conditions: `school = "zwei"`, `bloodYears = n` (years as a Bloodfiend).
- **An extreme boss** goes in `City/Bosses17.luau` (same fields as `City/Bosses.luau`); start it
  from a one-time event with a `battle` choice and keep the clash fallback. Probe its odds with
  `lune run tests/_extreme <boss>`.
- **A creature shape** goes in `Engine/Creatures17.luau` with `register(id, defaults, variants, fn)`,
  drawn with the builder (`box, ball, cyl, bone, rod, disc, group, swing, bob, spin, glow`),
  with poses for strike, hurt and down; then a foe in `City/Foes.luau` and a `match` word.

## New in v0.16: battles in turns

A choice with `battle = "<boss id>"` is fought in turns instead of one clash (Engine/Battle.luau).
Keep its `clash`, `win` and `lose`: the clash is the fallback for a pack without that boss, and
`win` / `lose` are what the battle gives at its end (a loss without its Health part: the fight
took that already). `fled = { ... }` is what getting out gives (default: a little Sanity).

Bosses live in `City/Bosses.luau`: `name`, `title`, `enemy` (a foe id for the look), `hp`,
`coins` / `base` / `coinPower` (what a strike has to beat when the move is aimed at you),
`temper`, `cause`, `moves` (`{ id, name, text, power, weight, target = "one" | "all", heavy,
base, coins, coinPower, condition }`), `phases` (`{ at, line, base, coinPower, power, moves }`)
and `barks` (`start`, `hurt`, `phase`). `power` is Health before the City's lethality.

## New in v0.15: what content can do now

**Fate.** Every life is dealt its own share of ordinary cards from its seed (Engine/Sim.luau,
`fateOf`): a quarter never come up, an eighth rarely, a quarter often. Cards that continue
something (`when.flags`, `when.anyFlags`, `when.chronicle`), a career's own cards
(`when.career`), story beats and `always` cards are left alone. `fateFree = true` on an event
keeps it out of the draw; `pack.fate = false` turns the whole thing off.

**Boss fights.** `clash.boss = true` marks a fight as a boss: the client gives it the full
cutscene entrance whatever its coins. Bosses should not be `fixed` (they grow with age and
renown). The pattern in `Events/Bosses_Fingers.luau`: an approach card whose fight `win`
has `trigger = "<boss card>"`, a boss card with `weight = 0`, and a way out on both.

**Danger by age.** `pack.dangerByAge = { { from, mult }, ... }` multiplies cards tagged
"danger" from each age on (City: 1.25x from 18, 1.5x from 24, 1.25x from 46).

**Stories in play.** The server tells the Sim which stories its players are living
(`sim.storiesInPlayFn`); those come up at a tenth of their weight for anyone else.

## New in v0.13: what content can do now

**Episodes.** `City/Episodes.luau` names them: `{ name, of (how many cards), theme, color }`.
Every card of one carries `episode = "<id>"` and its `step`; the first has a weight and a `when`,
the rest are `weight = 0` and come by `trigger` (at once) or `schedule` (years later). A result
with `episodeEnd = "How it ended."` closes it: kept on the STORY tab and celebrated. A chained
card that names something era-bound (L Corp, the Library) needs the same `world = { era }` gate
as the first.

**How a card looks.** `theme = "terminal" | "delve" | "blood" | "library" | "street" | "smoke" |
"strange" | "nest" | "lake" | "gold"` (or its episode's), and `rare = true` for a gold ribbon.

**Ways in.** `City/Entrances.luau`: an expedition with an entrance gets a one-time card that
finds it (`title`, `text`, `weight`, `when`, `go`, `later`, `leave` and their logs). A result
with `expedition = "<id>"` starts it straight away, with no action spent. Expeditions can say
their `purpose`, `length` and `depthWord`.

**Turf.** `City/Turf.luau` (blocks, factions with a `foe` and a `rep`, who contests, income).
Results: `turfJoin = "crew" | "<faction>"`, `turfTake = n`, `turfLose = n`, `turfGuard = true`,
`turfLeave = true`. An activity with `turfFoe = true` fights whoever holds a block.

**Cases.** `City/Cases.luau`: `{ name, desc, clues, stat, foe, coins, base, coinPower, steps, finale }`.
Results: `caseOpen`, `caseClue`, `caseClose` (an id). Working and finishing a case on the DO
tab is made for you.

**Feats and phases.** `City/Feats.luau` (tiers, and `need = { age, money, renown, stat, anyStat,
allStats, flags, episodes, cases, blocks, office, home, children, closeFriends, married,
uniques, legendary, delves, clashes, lives, form, careerTop }`, optional `limitBreak` and
`reward`). `City/Phases.luau`: `{ id, name, from, line, unlocks, color }`.

**Limits.** A result with `limitBreak = { strength = 5 }` (or `all = 5`) lets a stat go further
past 100 for the rest of the life. Gear, forms and renown grades can do it with `capBonus`.

**Gear.** New fields: `capBonus`, `set` (a line in `City/GearSets.luau`: a bonus at two pieces
and at three), `keep = true` (can't be sold), `value` (what a Workshop pays), `priceCut`,
`training`. Replaced gear goes to the stash.

**People.** `marry = true` (a household made a marriage, when `pack.marriage.on`) and
`reconcile = true` (a rival becomes a friend); without a scene's person, the first of that kind.
