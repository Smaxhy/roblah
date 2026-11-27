# v0.14: cutscenes

The request: once everything else was done, focus on animating cool cutscenes, with fights
where your character fights someone or meets someone: a cutscene that pops up and takes over
the full screen, either an actual fight focused on that moment or something important, where
you see your character walking, doing things, moving.

| Request | What it is now | Where |
|---|---|---|
| A cutscene that takes over the full screen | A 3D player that fills the screen (letterbox bars, a sky for the time of day, a set built from parts, two or more actors, a moving camera with wide, tracking, close, low, over-the-shoulder and high shots, subtitles, name plates, a title card). Tap anywhere to skip. | `client/UI/Stage.luau` (`Stage.play`) |
| You see your character walking, doing things, moving | The actors are built from your own avatar (look, clothes, held weapon) and those of the people you meet. They walk and run with a gait, turn to face each other, raise a guard, strike, flinch, fall, kneel, sit and stand. | `Stage.luau` (`newActor`, `Actor:update`) |
| Fights, with the fight itself acted out | Before the fight screen: you and your foe walk in from either side; a close-up of the foe with a name plate and a line; a close-up of you; a low shot and FIGHT. After it: the fight's own rounds acted out (whoever took a round lands a blow, a tie is a parry), then the blow that settled it, and VICTORY or DEFEAT. Creatures from the monster set fight as themselves. Long version for the first fight of a session, a boss and episode fights; a short one otherwise. | `Stage.fightIntro`, `Stage.fightOutro`; `client/App.luau` (`playClash`) |
| Meeting someone | Cards with a `scene` open with you walking up to the person, who speaks (or you do, or a narrator). 18 cards have one (episode turning points, a turf war's first word, a case opening, a rival's common enemy...). Spending time with your own people (parents, siblings, friends, mentor, rival, children) opens a short scene with that person in it, with their own look: the first time with each, then one time in four. | `Stage.meet`; `Engine/Sim.luau` (`sceneView`); `Engine/View.luau` (`pending.scene`); scenes on cards in `City/Events/` |
| Going somewhere | A delve or an expedition opens with you walking up to its way in (the set follows its purpose: an underpass to explore, an old L Corp corridor for a compliance audit, a pier for a wreck, an alley for an investigation or an escape), its name and purpose over the shot, and you heading in. Once per run. | `Stage.descent`, `Stage.descentSet`; `client/App.luau` (`openRun`) |
| Something important | A new part of life (a phase) opens with you walking out onto a roof at dusk, and the phase named. Activities are acted out in a few seconds: training on a straw dummy in a training room, running the roofs, study, work, rest, walking your blocks. | `Stage.moment`, `Stage.vignette` |
| Not getting in the way | Settings, Cutscenes: All, Fights only, or Off (saved with your settings). Everyday cutscenes play the first time and then now and then. Phones held upright get a wider lens and a camera further back. | `client/UI/Settings.luau`, `server/init.luau` (`setSetting`), `Stage.enabled` |

## Writing a scene on a card

```lua
scene = {
    set = "stairs",              -- street, alley, facility, rooftop, room, nest, underpass, hall, lake, stairs, gym
    time = "night",              -- night, dusk, day (indoor sets light themselves)
    title = "The Neighbor's Badge",
    kicker = "Across the landing",
    line = "They gave me a suit today. It fits like it was waiting for me.",
    voice = "other",             -- other (default), you, narrator
    reply = "It suits you.",     -- optional: your answer, close on you
    other = { name = "Ilse Brandt", role = "your neighbor, an L Corp agent", pose = "sit" },
    -- or other = { rel = "rival" } for someone from your own life, as you know them
    -- or other = { name = "...", foe = "syndicate" } to borrow a foe's look
}
```

The validator checks the keys and the set. Only this game's own people go in scenes; canon
characters never appear in one (see `docs/CANON.md`).

## Not tested in Roblox Studio

The cutscenes were built and checked headlessly: the screen renderer draws them on PC and phone
(`tests/gui_snapshot.luau`, `v14-*` states, copied to `screenshots/v14/`), and `tests/v13_check.luau` checks that scenes reach
the view. Nothing was run inside Roblox Studio for this version, so timing and the look in the
real engine (lighting in a ViewportFrame in particular) are worth a playtest.
