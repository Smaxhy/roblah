# v0.15: what each request became

The request: focus on making the story less repetitive; a lower median lifespan and a harder
life, like the real City; many more options at younger ages; many more varied midgame events;
much harder mobs and fights; many more Distortions and bosses (big bosses of the Thumb and the
rest that you can fight); two players shouldn't get the same things, and their stories should
cross; and every other remark made in this chat.

| Request | What it is now | Where |
|---|---|---|
| The story is too repetitive | Measured first: two lives already shared only ~7% of their cards, but the stories that find you as an adult came from a pool of 11, so the same ones kept returning (one turned up in 6 of 24 lives). Ten new ones; in the balance run the adult stories now spread across 17. Each life is also dealt its own share of ordinary cards (fate) | `City/Storylines/Second3.luau`, `City/Events/Story_Second3.luau`, `City/Cast/Story_Second3.luau`, `Engine/Sim.luau` (fateOf, eventWeight) |
| Two players shouldn't get the same things | Fate: from a life's seed, a quarter of the ordinary cards never come up in that life, an eighth come rarely, a quarter come often. A story someone else on the server is living right now comes up at a tenth of its weight, for a new life and for a second story | `Engine/Sim.luau` (fateOf, storiesInPlay), `server/init.luau` (storiesInPlayFn) |
| Stories overlap with each other | Big bosses record chronicle acts; other players on the server get echo cards for each (the Thumb closing ranks after a Sottocapo falls, the Middle hunting for anyone who stood beside the one in Title 1, an R Corp curfew, a block that remembers everything the Bellringer took) | `City/Chronicle/Bosses15.luau`, `City/Events/Bosses_Echoes.luau` |
| Lower median, harder life | Lethality 1.7 to 1.9; foes grow +1 base every 6 years from 16 (was 7) up to +8 (was +6); danger cards come 1.25x from 18, 1.5x from 24, 1.25x from 46; an ordinary body starts failing at 63 (was 66). Two headless balance runs: median 66 to 40 and 47; reached 50: 68% to 45% and 48% | `City/init.luau` (clash.foeGrowth, lethality, dangerByAge, forms.human), `Engine/Sim.luau` (eventWeight) |
| Much harder mobs and fights; bosses of the Thumb and the rest | Eight big bosses in phases: you fight through their people (a hard fight), then the boss (three heavy coins, or four for the Sottocapo), with the full cutscene entrance (`clash.boss`). Not `fixed`: they grow with your age and your name. Stats around 80 win about a third of the time; around 100, most of the time. Every boss can be avoided at the door. Unique drops | `City/Events/Bosses_Fingers.luau`, `City/Gear/Bosses15.luau`, `Engine/Sim.luau` (res.boss), `Engine/Validate.luau` |
| Way more Distortions | Fourteen new Distortions after the Light (library era on), each one person and one feeling, plus Peccatula in the Limbus era; two Distortion bosses; the adult story *Changing* is about a friend beginning to Distort | `City/Events/Danger_Distortions2.luau`, `Bosses_Fingers.luau`, `Story_Second3.luau` |
| Many more options at younger ages | 24 new activities from 3 to 17 (some only for Nest kids, some only for the Backstreets, a few that can go wrong) and 20 new childhood and teen cards that bring the City in a piece at a time | `City/Activities/Youth15.luau`, `City/Events/Kids_More15.luau` |
| Many more varied midgame events | 18 new standalone cards for 22 to 50, plus the 50 chapters of the new adult stories and the boss and Distortion cards | `City/Events/Adult_Midgame15.luau` and the files above |
| Harder fights leave marks | New wounds: broken ribs, fever, a propellant scar, ringing ears | `City/Conditions/Wounds15.luau` |

## Earlier remarks, checked again

Every message in this chat was read again for this version. What was still open:

- *Stories that merge with other players' and impact each other's lives* (an early request):
  the boss echoes above, on top of the chronicle (90 acts with echoes) and linked friends.
- *Much more action at ages 1 to 10, and more build-up so the Thumb and Fixers don't just show
  up*: the new activities and childhood cards.
- *A much higher death rate, scarier events*: the difficulty above, the Distortions and bosses.
- *Many different story possibilities, some extremely traumatic*: *Changing*, *Missing*, *The
  Last Stop* and *The Grudge Book* are the darkest of the new stories (still within Roblox's
  rules: violence implied, children never hurt).
- *Better hairs from the Roblox marketplace, or better presets*: the 31 hair styles made in
  v0.9 stand; catalog meshes need asset ids from your own game and can't be checked here.

## Not tested in Roblox Studio

Built and checked headlessly (Lune, the validator, the screen renderer, the server tests).
Nothing was run inside Roblox Studio for this version.
