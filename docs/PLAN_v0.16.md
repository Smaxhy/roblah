# v0.16: battles in turns, and friends who choose

The request: in big battles or events with friends, everyone needs the option, not only the
squad leader; turn-based battles against super-strong bosses; fights against big bosses should
last longer, not be one-tap moves.

| Request | What it is now | Where |
|---|---|---|
| Turn-based battles on super-strong bosses | A choice can carry `battle = "<boss>"`: instead of one clash, a full-screen fight in turns. Bosses have Health with phase marks, a move list, and they show the next move and who it's aimed at, one turn ahead. Every turn you strike (with any of your ways of fighting, each with its odds and damage), guard, patch up (twice) or get out. A strike against a move aimed at you is a clash: win it and your blow lands while theirs doesn't. Damage is real Health, with the City's lethality | `Engine/Battle.luau`, `City/Bosses.luau` (12 bosses), `Engine/Sim.luau` (choose, battleAct, battleView), `Engine/View.luau` |
| Fights against big bosses last longer | The twelve big bosses (the Thumb's Capo and Sottocapo, a Big Brother of the Middle, a Proxy of the Index, a Docent of the Ring, a Kurokumo Captain, R Corp's Rhino, the Bellringer, the Hostess, and the end of *The Grudge Book*, *The Pit* and *Changing*) are battles now: six to twelve turns in the test runs, with two or three phases | `City/Events/Bosses_Fingers.luau`, `City/Events/Story_Second3.luau` |
| Super-strong | Bosses don't grow with your age in a battle (their Health and phases are the curve); with stats around 75 a regular boss is a coin flip at best, around 90 you're favoured; the Sottocapo still kills a third of fighters at 90. Talking a boss down is a card choice, not a blow | `City/Bosses.luau`, `tests/_battle.luau` (probe) |
| Friends get the option too, in battles | A crewmate who starts a boss battle invites everyone in the crew who's free; each fighter picks their own move every turn; the turn plays when all have chosen, or after 25 seconds whoever has chosen can go ahead. More fighters, more boss Health, but it aims at one at a time | `server/Battles.luau`, `client/App.luau`, `client/UI/BattleView.luau` |
| ... and in events with friends | Crew expeditions: every member picks (not just the captain). The crew does what most pick; ties go the captain's way; after 20 seconds the captain can go with the picks so far. The card shows each option's picks and yours | `server/Crews.luau` (crewChoose, tally), `client/App.luau` (openRun) |
| Nobody gets ahead | A crew's year doesn't turn while anyone in it is mid-fight; nothing else can be done mid-fight | `server/Crews.luau` (ageUp), `Engine/Sim.luau` |

## Not tested in Roblox Studio

Built and checked headlessly: the engine (`tests/v16_check.luau`), the real server code with
two players (`tests/battle_check.luau`), the UI smoke test with the starter pack's two-player
crew run, and the screen renderer (`v16-*` states). Nothing was run inside Roblox Studio for
this version.
