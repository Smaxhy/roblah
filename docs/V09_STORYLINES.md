# Storylines (v0.9): the main story of a life

What players said after v0.8:
- "The beginning feels very repetitive, and the story seems to be going everywhere. It
  doesn't feel like it's matching up."
- "It feels boring at times. I'm lost, and I still feel like a side character at 18."
- "Make so many different story possibilities, some extremely traumatic."
- "I need players to feel more involved in the Limbus world and understand what's going on."

So every life that starts at birth now lives ONE main story, rolled at birth. Its scenes
("beats") come at fixed ages from 1 to about 24, each one following from the last, with the
player's choices carried in flags. Random events are filler around it. The player sees
YOUR STORY and the current goal at all times.

Read first: `docs/V08_SPEC.md` (voice, Roblox rules, `art` scenes, `dialogue`, cast, `enemy`,
the stakes table: all of it applies) and the model storyline: `src/shared/City/Storylines/Core.luau`
and `src/shared/City/Events/Story_Collateral.luau`. Copy its structure.

## The files

- `src/shared/City/Storylines/<Yours>.luau` returns a list of storyline definitions:

```lua
{
	id = "sl_collateral",            -- unique; also set as a flag on the life
	name = "Collateral",             -- shown as YOUR STORY (2-4 words)
	hook = "Your father borrowed from a Syndicate lender. He had one thing to put up against the loan. It was you.",
	tone = "grim",                   -- grim | tragic | strange | hopeful
	weight = 10,
	when = { side = "backstreets", hasRelation = "father" },  -- optional: who can be born into it
	goal = "Grow. Somebody is keeping count.",                -- the first objective
	cantos = { [2] = "one line under Canto II's title", [3] = "...", [4] = "...", [5] = "..." },
}
```
  `when` is checked at birth, so it can only use: `side` ("backstreets" / "nest"), `flags` /
  `notFlags` with origin flags (foundling, fixer_blood, nest_born, lcorp_family,
  smoke_war_family, runaway_family, hongyuan_family, bf_family_raised), `district`,
  `hasRelation` / `noRelation` (mother, father, sibling). Cantos start at ages 0, 6, 12, 16,
  20, 30, 45, 60 (I-VIII); give lines for II to V.
- `src/shared/City/Events/Story_<Name>.luau`: the beats: ordinary events with
  `story = "<storyline id>"`. The engine only fires them in lives on that story, so they need
  no flag condition for that.
- `src/shared/City/Cast/Story_<Yours>.luau`: faces for the recurring people.

## New result keys

- `goal = "short sentence"`: the player's current objective (shown in the Story tab and on
  the HUD). Set it whenever the situation changes. Up to 90 characters, written to the player.
- `storyEnd = "Name: what happened"`: this choice ends the story with that ending (shown on
  the life's book and counted in the player's collection). Up to 80 characters. Every
  storyline has 3 to 5 different endings, reached by different choices; at least one good
  and one bad.

## How to build a storyline (11 to 15 beats)

| age | beat |
|---|---|
| 1 | the opening: the premise as a scene, with a small choice (toddler actions) |
| 3-5 | the first sign: the thing comes back; a face is put to it |
| 6-8 | you find out what it is. Set the first real `goal` |
| 9-11 | you try something; a recurring person explains part of the City |
| 12-13 | the turn: the worst thing happens, or the best thing is taken away |
| 14-15 | three ways forward (each sets a different flag) |
| 16-17 | THE CLIMAX: up to 5 choices, some locked by earlier flags or money, at least one fight |
| 18 | what you are now: one variant per climax outcome |
| 20-21 | the truth about something from childhood |
| 23-25 | the ending: 3-5 choices with `storyEnd` |

Rules that keep it from stalling:
- Every beat is `always = true, once = true, when = { minAge = N, maxAge = N }` (plus flag
  conditions for variants). At any age where you write variants, exactly one must fit every
  life: cover each outcome flag, or add a fallback variant with `notFlags`.
- Don't depend on a relative being alive at later ages: write "your father", not `{father}`,
  unless the beat's `when` has `hasRelation` and there's a variant for when they're gone.
  A storyline can create its own people with `addRelation` (see CONTENT_GUIDE).
- Story beats may have up to 5 choices (other events 4).
- Half of lives die before 32. The ending must come by 25. A later epilogue is optional.

What makes the player the main character (the whole point):
- The story is about THEM. People come to them, want something from them, are afraid of
  them, remember what they did. The first scene already singles them out.
- Choices come back. If a 4-year-old bit the clerk, the clerk mentions it at 16.
- One recurring adversary and one recurring ally, each with a face (cast) and their own wants.
- The climax at 16-17 is a real win or a real loss, and the scene at 18 shows who they've
  become because of it.
- Reward the big beats: virtues (+2 to +4), Ahn, Sanity, an item (`gear = "<existing id>"`,
  see `src/shared/City/Gear/*.luau`), a trait (`addTrait = "<existing id>"`).

Teach the City (players often don't know Limbus Company):
- Each storyline properly introduces 2 to 4 pieces of the City (a Finger, Fixers, a Wing, the
  Night, Distortions...) through a person explaining it in their own words, the way Varga
  does at age 11. Set the matching `knows_` flag in that result (the list is in V08_SPEC).
- Use the real terms; `src/shared/City/Glossary.luau` gives the player a one-line
  explanation of each on the card. Stay consistent with it and with `docs/CANON.md`.

How dark:
- Players asked for traumatic stories: loss of a parent, being sold, hunted, betrayed,
  left behind, a sibling who Distorts, a home erased. Write them: tone "tragic" or "grim".
- Roblox Moderate rules still hold: nothing graphic, no gore, a child is never shown being
  hurt (it happens off the page or to adults), no self-harm or suicide, no romance, alcohol,
  drugs, smoking, gambling or profanity. Implication does the work: "Sweepers leave hats."

Length and voice: as in V08_SPEC (text up to 280 characters, labels up to 40, logs up to
160, dialogue lines up to 120, no em-dashes, no AI tells). Most beats open with 1-3 lines
of dialogue. Every beat has `art`.

## Check your work

```
lune run tests/story_check      # every storyline: opening always fires, beats in order, 2+ endings reached
lune run tests/run 30           # validation + lives
python3 tests/safety_scan.py    # 0 hits
```
`story_check` prints one line per storyline and FAIL lines for problems. All of yours must
pass, including "most lives that reach 30 should have an ending".
