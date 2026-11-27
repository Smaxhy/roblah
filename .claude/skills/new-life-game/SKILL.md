---
name: new-life-game
description: Make a new BitLife-style Roblox life-sim game from a prompt with the lifesim blueprint (spec, content, maps, VFX, dungeons, bosses, store), then check and build it.
---

# New life game: prompt → spec → content → checks → build

The engine, UI, saves, fights, boss battles, dungeons, 3D stage and store are already in place.
A game is a folder of content: `src/shared/Games/<Id>/`. `Base.build` (src/shared/Base) turns
its `Spec.luau` and the content modules beside it into a full pack. Anything left out gets a
working default.

## 1. Scaffold
    lune run tools/newgame <Id> --title "Title"      # copies templates/Starter, points Config at it
    lune run tools/newgame --list                     # games and templates

## 2. Turn the prompt into the spec (src/shared/Games/<Id>/Spec.luau, fully commented)
- meta: title, tagline, currency word, premium name, actions per year
- stats: rename the 7 stat jobs (health, fight, speed, work, charm, luck, will) and the mood
- fighting: names of the 4 approaches. world: 2 sides (the rich one first) and districts
- origins, careers, gear slots, names
- theme: accent / crimson / money / panel / text colours. backdrop: "city" | "crater" | "none"
- places (3D maps): ground, skyline, time (night/dusk/day/inside), parts
  (box, cyl, ball, building, lamp, tree, pillar, glow, row), words, fights="street",
  bosses={ "<boss id>" }, scene = a 2D banner scene
- vfx.statuses: rename and tint burn, bleed, tremor, rupture, sinking, poise, charge
- intro lines, tuning (lethality, hardness, dread, focus topics), store

## 3. Write the content (shapes are at the top of each file)
- Events/*.luau: cards. Aim for 150+ (300+ for a full game), spread over child, teen, adult and
  old age. Use stat ids, never role words. Add `tags={"danger"}` to the hard ones.
- Careers, Activities, Gear, Foes (human looks, or creature shapes: beast, bird, tall, mass,
  blob, machine, swarm, crab, serpent, lamp, book, door, doll, armor, branches, watcher,
  mantis, rustback, parasol)
- Bosses: hp, moves, phases. A card's choice uses `battle = "<id>"` plus a `clash` fallback.
- Expeditions: dungeons, stage by stage. Tiers I–V come from the hardest clash, and harder
  runs pay more. Store: honest (no fake timers, odds shown before anything random).

## 4. Check, then build
    lune run tools/checkgame <Id>                     # validate + lint + headless lives
    python3 tests/safety_scan.py src/shared/Games/<Id>
    bash tools/build_game.sh <Id> [--shots]          # build/<Id>.rbxlx and build/<Id>Kit.rbxmx
Fix every ERROR. Target: median lifespan 30–60 and fights won 45–65%.

## Rules (Roblox Moderate)
- No romance or sexual content, alcohol (no taverns or ale), drugs, smoking, gambling,
  profanity or self-harm.
- Violence is implied, with no gore. Children are never shown hurt.
- Player-typed text goes through TextService. Admin powers are checked on the server
  (Config.admin).
- Games must be original, not recreations of existing games.
