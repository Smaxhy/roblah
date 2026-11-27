# v0.18: real 3D effects, many more traits and talents, and a store worth opening

The requests (in order): actually good VFX, looking for VFX plugins on GitHub and using them; a
lot more traits and talents; the hair moving with the arms or legs when someone walks; a much
better store, with more appealing icons, a bigger menu, more in the middle of the screen, and
seen from the beginning; the mod menu can't give talents and needs to look a lot better; a
weird column of small squares on the fight screen; much better audio; "Decide what to do first"
with nothing on the screen; remove the "start a life at 18" option.

| Request | What it is now | Where |
|---|---|---|
| Actually good VFX, from GitHub plugins | Boss battles, duels and the 3D cutscenes play on a **real 3D stage** in the Workspace (the old ones were drawn inside ViewportFrames, where Roblox's particles, lights, beams and Bloom never render). The stage borrows the camera, the lighting (with Bloom) and the reverb for a mood, hides the HUD, and gives all of it back when it closes. An effect library on it: impacts (flash, sparks, shockwave, smoke), slashes (beams and a trail, then the impact), lightning, every status (Burn flames, Bleed drops, Tremor rings on the ground, Rupture cracks and shards, Sinking blue drops, Poise glints, Charge lightning), heals, guards, dust, anticipation glints, phase changes, knock-downs, victory bursts, model flashes and auras. The camera shakes (RbxCameraShaker by Sleitnick, MIT), punches in, and cuts an impact frame on heavy blows. Each boss gets a set (an alley, a rooftop, a facility, the lake, an underpass, a hall). The store's cards ease on springs (spr by Fraktality, MIT). Several particle recipes are adapted from adnvli/vfxskill (MIT). **Settings > 3D fight effects**: Full, Lite (fewer particles, no flashing lights) or Off (the flat fight screens of v0.17). The mod menu's Effects tab plays every 3D effect on the stage | `client/UI/World3D.luau`, `client/UI/Fx3D.luau`, `client/UI/Arena.luau`, `client/UI/Spring.luau`, `client/Vendor/`, `vendor/*-LICENSE.txt`, `BattleView`, `DuelView`, `Stage` |
| A lot more traits and talents | **60 new talents** (15 Common, 13 Uncommon, 11 Rare, 9 Epic, 7 Legendary, 5 Unreal), each with a sin, in the rolls like every other talent. **36 earned traits**: nobody picks them; a life grows into them by itself the year it qualifies (fights won, renown, money once held, children, close friends, a roof of your own, delves, cases, turf, stats past 150, every stat past 80, one stat at 250, long years, three lives in a family...). The year's feed says "You've become something: ...", and the trait shows up highlighted | `City/Traits/Talents3.luau`, `City/Traits/Earned.luau`, `Engine/Feats.luau` (earnTraits), `Engine/Validate.luau` |
| Hair moves with the arms and legs when walking | Every part from the head (hair, hats, the head itself) is tagged as the head's, and the stage figures keep those with the body, never in an arm or a leg group. All 31 hair styles were checked on a stage figure | `Engine/Avatar.luau` (onHead), `client/UI/Stage.luau` (classify), `tests/fx_check.luau` |
| A much better store: icons, bigger, in the middle, from the beginning | The store opens **big and centered** (almost the whole screen), on a header with your Lunacy and Light and the code box, and **icon aisles**: Featured, Everything, Lunacy, Family names, Boosts, Passes, Looks. Featured puts the pass with everything first, then the best value and the starter pack. Every item has an icon (or its look on you, or its swatch) and tags that only say true things: Best value, Starter, Permanent, Everything in one, Odds shown; Lunacy packs show how much Lunacy each Robux buys. Cards light up on a spring when you point at them. The **start menu** has a store banner with an "Open the store" button, beside the STORE button every screen already had. No countdowns, no fake scarcity, no "limited" badges, and odds before anything random (Roblox's rules on paid random items and misleading purchases) | `client/UI/Social.luau` (store), `client/UI/Intro.luau` (StartStore), `client/UI/Sheets.luau` (center) |
| The mod menu can't give talents, and should look a lot better | Tabs with icons, and a player card with badges (talent, form, age, money). A new **Talents** tab: what the player has (click one to take it away), every talent by rarity and sin with search, and every trait with a filter for the earned ones; a talent card can make it their talent, add it as an extra, or take it away; a trait card gives it or takes it away. The catalog is sent once when the menu opens. Everything is still checked on the server | `client/UI/AdminMenu.luau`, `server/Admin.luau` |
| A weird column of squares on the fight screen | The win confetti was being created inside a frame with a list layout, which stacked every piece in a column. Effects now draw on their own canvas on an ancestor with no layout, so they land where they're aimed | `client/UI/Vfx.luau` (overlay) |
| Much better audio | Every effect goes through a compressor and an equalizer on its sound group, and varies a little in pitch and volume each time it plays. On the 3D stage, sounds come from where the blow lands. Heavy blows and critical hits add a second sound and duck the music for a moment; each status has its own sound. The stage sets the echo for its mood (an alley at night, a stone hall for a boss, a hangar in the facility) and puts the old one back | `client/Sfx.luau`, `client/Music.luau` (duck), `client/UI/World3D.luau` (reverb), `client/UI/Arena.luau` |
| "Decide what to do first" with nothing on the screen | The client keeps track of the card it's waiting on. If the server says there's a decision and nothing is showing, it asks the server again for the whole state (the same as joining) and shows the card; if a pushed fight fails to draw, the decision comes back the next frame | `client/App.luau` (ensureDecision, resync) |
| Remove the "start a life at 18" option | Fixer's Road is off the start menu and the friends lobby (`hidden = true`, and `Config.devModes = false`). A life already on it carries on. The tests still use it to make grown-up lives quickly (`Config.devModes = true` in the harness). L Corp Agent (hired at 18, only in the age of L Corp) and Kindred (a Bloodline pass) are still on the menu: say if those should go too | `City/init.luau`, `shared/Config.luau`, `server/Progress.luau`, `client/UI/Intro.luau`, `client/UI/Lobby.luau` |
| (after the first build) Night is too dark: you can't see cutscenes or combat | The dark moods keep a night sky but light the people: ambient and exposure up (night ambient 44,46,66 to 112,116,146; the boss mood's dim red likewise), and the stage carries its own key light above and in front of where people stand and a softer fill from behind, so fighters are lit whatever the hour. The stage also re-applies its light every frame while it's up, since the city behind it tweens the clock to midnight when its scene changes. Checked in the renderer's approximation: Studio still to check | `client/UI/World3D.luau` (MOODS, StageLights, _step) |
| (after the first build) The Rats are a group, like bums: killing one, nobody cares | The Rats are a crowd nobody keeps score for (`nobody = true`): no standing with them (none shown under Standings or Who you know of), nothing lost for beating or killing one (a Rat, a rat boss or any street thug of theirs), no grudge and no reprisal cards. You still learn of them. The lore says so: no boss to answer to, no name to avenge | `City/Reputation.luau`, `Engine/Sim.luau` (addRep, rollReprisal, repView), `Engine/Known.luau`, `City/init.luau`, `City/Lore/Life.luau` |
| (later) Your own Office: choose its name and stuff, hire your friends, make a name, buy big buildings, lab experiments, be strong | A new Office asks for its **name, a motto and the sign's colour** (filtered by TextService on the server; letters, digits and a little punctuation). **Manage the Office** (You tab) opens its sheet: the sign; the money (what its Fixers earn and cost); **premises**: a rented room (2 desks), a storefront (5), a whole floor (10), a city block (20) and a tower (40), each paying more, the big ones wanting a bigger Office and a renown grade; **rooms**: training (+2 fight stat a year, grades rise faster), infirmary (+15 Health), archive (+1 work stat, +10% contracts), armory (+1 in fights), vault (4% interest), and a **lab**: an experiment costs an action and 2,000 Ahn (breakthrough: +5 to a stat's limit; a stronger you; a design to sell; nothing; an accident); **the roster** (grade, wage, what they bring in; let someone go: bond -10); **who'd join** (grown-ups with bond 40+, or 55+ for someone you've met; never a rival; a close friend starts at Grade 8; the first year's wage up front). Every year: wages paid (if the Office can't, the least loyal Fixer leaves), contracts earned, Fixers rise through the grades. In fights: +1 base with 3 Fixers, +2 with 8, +3 with 20, +1 for the armory. The mod menu can give an Office (op `office`) | `Engine/Office.luau`, `Engine/Renown.luau`, `Engine/Sim.luau` (officeAct, officeRename, foundOffice), `server/init.luau` (officeAct, officeName), `server/Admin.luau`, `client/UI/OfficeSheet.luau`, `client/UI/SidePanel.luau`, `client/App.luau`, `City/init.luau` (offices) |
| (later) A lot more fighting areas | 16 new sets for the 3D stage (27 in all): a market, the docks, a subway platform, a factory, a bridge, a construction site, a noodle bar, a library, a warehouse, a sewer, a plaza, a train yard, a greenhouse, an office, a parking garage and an arcade. Street fights pick one of 14 places, seeded by the foe and the year (the same fight keeps its place); Nest fights their own pool; bosses and duels have their own | `client/UI/Sets18.luau`, `client/UI/Stage.luau` (fightSet), `client/UI/Arena.luau` (setFor), `client/UI/DuelView.luau` |
| (later) Events in order: when something happens it's followed up, not one random card after another; a Library event makes the Library the main focus | **Focus**: the card that starts a thread (every card joined to another by `schedule`/`trigger`, or a subject with several cards: a codex entry, or the whole `lib_` family as "The Library") becomes the life's focus for 3 years after its last card. While it holds: its cards come 6x as often and everything else half as often (not a life's own story, not the world's milestones); a year with one of its follow-ups due brings one fewer unrelated card; the year's cards are put in order, the focus first; the card's band says "Following on · The Library". A stray card doesn't push aside a focus with something still to come | `Engine/Focus.luau`, `Engine/Sim.luau` (eventWeight, advance, ageUp, threadOf), `Engine/View.luau`, `client/UI/Feed.luau`, `City/init.luau` (focus) |
| (later) Make the events way harder, and MUCH harder random events | `pack.hardness`: every clash on an event card +1 base; a dangerous card (tag `danger`) +2 more and +1 coin in a fight, and it grows with you (+1 base per 35 points of the stat you face it with past 50, up to +5); dangerous cards come 1.5x as often from 14 on. **The dread roll**: on top of the year's cards, one more dangerous card (22% a year from 16, 32% from 24, 26% from 46; times the difficulty's hazard; halved while a focus holds). 12 new dread cards (`dr18_`), each a real fight with real pay, three of them with a follow-up a year later. The card preview shows the real odds (the same numbers the fight uses). The difficulty scales the extra hardness (`hardness`: A Gentler City 0.34, The City 1, the Backstreets at Night 1.34). A life's own story chapters keep their tuning. Measured on The City in 48 headless lives choosing at random (after the fixes below): median lifespan 26 (43 before), 42% reach 30, 19% reach 50 (47% before), 83% of lives born in the Backstreets end before 50; clashes are won 63% of the time. Tune `pack.hardness` to taste | `Engine/Sim.luau` (clashSides, eventWeight, rollDread), `City/Events/Dread18.luau`, `City/init.luau` (hardness) |
| (later) Higher-end dungeons much more rewarding | Every expedition has a tier from its strongest fight (base + coins: 9 / 11 / 13 / 14 for II to V; a boss battle is V): 8 at I, 10 at II, 7 at III, 7 at IV, 2 at V. A success pays its result times 1.5 / 2.5 / 4 / 6 (Ahn and wages; stats and renown less), plus a bonus haul at III and up (Ahn and renown; at IV and V a higher limit for your fight stat). The run's card says its tier and what it pays | `Engine/Expedition.luau` (tier, richer, finish), `City/init.luau` (expeditionPay) |
| (later) Cool boss cutscenes with fight VFX | Before a boss battle (when cutscenes are on): the boss walks in on its own ground (its Arena set), a gathering glow, dust, the camera shakes, a red phase burst and ring on the floor, its name plate in red with its title, a line, you raise your guard (a blue guard effect), a flash, and BOSS. Once per fight. A new cutscene beat plays any 3D effect on an actor (`{ "fx", kind, id }`) | `client/UI/Stage.luau` (bossIntro, fx beat), `client/App.luau` (openBattle) |
| (later) After death, easier to get to the menu; the menu has too much spacing and text | The death screen has **Back to the menu** and **Begin a new life** across its top, always in sight (and Back to the menu at the end of the book too). The start menu dropped its paragraph and the long mode descriptions; mode cards are shorter (120-156 px, were 170-260) and there's less space above and between | `client/UI/Screens.luau` (death), `client/UI/Intro.luau` (menu) |

## Tests added

- `tests/fx_check.luau`: on the real client in the harness, every 3D effect plays on an open stage
  and puts something there (the particle ones emit); a heavy hit is about half the particles on
  Lite; closing the stage gives back the HUD, the camera and the lighting and leaves nothing in
  the Workspace; an Arena with you and a training dummy plays all its moves; the 3D effects
  setting is kept by the server (and a made-up value refused), Off has no stage, Lite keeps it;
  and no hair style has a part in an arm or a leg group.
- `tests/v18_check.luau`: each earned trait's need, met, brings it once (and a second year adds
  nothing), none comes early, and the yearly check grants them; all 60 new talents are in their
  rarity's rolls with a sin; no two traits share a name; Fixer's Road is hidden and the shipped
  config (`Config.devModes = false`) keeps it that way.
- `tests/v18_check.luau` (later): the Office (a name that's too short refused, a colour not on
  the list refused, "Office" not doubled; a close friend hired at Grade 8, a child, a rival and a
  cold acquaintance refused, a full room refused; a storefront bought, a floor refused until the
  Office grows; rooms built once; an experiment takes an action; the fight bonus; the year pays,
  and someone leaves when it can't; the dead come off the roster; the view); focus (a Library
  card makes the Library the focus, its cards 6x and the rest half, one fewer unrelated card with
  a follow-up due, the focus first in the year, a stray card doesn't push it aside, it lets go
  after its years; a card and its scheduled or triggered follow-up are one thread); harder cards
  (a dangerous card's foe +3 base and growing with the stat; the dread roll sends only dangerous
  cards; 12 dread cards); expedition tiers (a spread from I to V, higher tiers pay more).
- `tests/fx_check.luau` (later): the boss intro plays to the end on its own ground (7.5 s) with no
  warnings and leaves nothing in the Workspace.
- `tests/gui_snapshot.luau` (later): `v18-office-name` (a new Office asking for its name, a motto
  and a colour, typed in) and `v18-office` (the sign hung, a storefront bought). The mod menu can
  give an Office (op `office`).
- `tests/ui_smoke.luau`: Fixer's Road is not on the start menu.
- `tests/gui_snapshot.luau`: new states `v18-menu-store` (the store opened from the start
  menu's banner), `v18-store`, `v18-store-lunacy`, `v18-talents`, `v18-fx-preview`; the
  renderer draws the 3D stage (parts, lights, particles) from the dump.

## Caught in the final test pass

- Two talents had the same name as another trait: "Quick Study" (new) and "Workshop Hands"
  (from v0.9). They're "Read Once" and "Clever Hands" now (their ids, and so old saves, are
  unchanged), and the validator refuses two traits with one name from now on.
- The new talent file had 57 talents, not 60: three more (Chin Up, Iron Knuckles, Never Kneels),
  for the two sins the set used least (Pride and Wrath).
- The content scan flagged the earned trait "Luck of the Damned" ("damned" reads as mild
  profanity to Roblox's filter). It's "Impossible Luck" now.
- A job's card could promise less money than it paid: the job's own +1 Intelligence was applied
  first and, crossing into a tier whose perk raises wages, the paycheck was worked out on the new
  wage. Pay is now worked out from the wage before the result's own stat gains, as the card says
  (`Engine/Effects.luau`). This was older than v0.18; the new talents' different rolls exposed it.
- The two-player UI test sometimes looked for a card while the meeting scene before it was still
  playing, now for real, on the 3D stage. That test's scheduler drops whatever is still waiting
  after a while, so the scene was cut off halfway and its card never came. The test now plays with
  cutscenes off (as the screenshot test does), and gives the linked card more turns to come up
  (it sometimes ran out of turns in v0.17 too). In the game, the stuck-card recovery now counts
  an open 3D stage as something showing, so pressing DECIDE never cuts a scene short.
- A race older than v0.18: when a life ended, the death scene played inside the update that
  reported it. If the next life (an heir, a fresh start) began before that scene finished, the
  old update then switched to the death screen on top of a life that was still going, and that
  life's next card never showed (the card check only runs on the life screen). Now the death
  screen only follows a scene if no newer life has started meanwhile (`client/App.luau`). One
  of the ways "Decide what to do first" could come with nothing on screen.
- A card could go stale and stay. An update about your life sent while you were choosing (a world
  event, the day's event) could arrive after the answer to your choice and put the old card back.
  Choosing it then got "Nothing to decide" from the server, and the screen showed the same card
  again, forever. Now every view of a life the server sends is numbered (`Engine/Sim.luau`), the
  screen keeps the newest, and a card the server no longer has makes the screen fetch the life
  again (`client/App.luau`). The same family of bug as "Decide what to do first" with nothing on
  screen, the other way round.
- A 3D effect that comes a beat after its blow (a slash's impact) could try to draw into a stage
  that had just closed, and a flat effect into a fight screen that was already gone. Both are
  dropped now (`Fx3D.luau`, `Vfx.luau`). In the test harness this crashed the run; in Roblox it
  would have been an error in the output.
- The City UI test plays cards, not boss battles or expeditions: a card that started a battle, or
  an activity that started an expedition, left the life stuck in it for the rest of the run (the
  test then failed with "nobody died"). The test now leaves a battle the way a player can (Get
  out, then Continue) and plays an expedition's stage cards. The L Corp career checks climb at least 12 lives (a quarter reach Head of Research,
  so 4 lives was sometimes none). The headless life runs (`tests/run.luau`) give a form that lives
  for centuries (a Bloodfiend) the years to reach its end, instead of failing it at 200.
- Balance after the new talents and earned traits, from a 45-life headless run: median lifespan
  43, 47% reach 50, the longest life 171. v0.15 aimed for this and measured a median of 40 and 47,
  45 to 48% reaching 50, so the new traits don't make lives meaningfully longer.
- Two fixed-seed checks followed lives whose random path changed with the new talents: the job
  twists check followed a life that never took a job (it gets one now), and the drifting-friend
  check followed a life that died that very year (it tries another life then).
- The 3D slash and the Charge status put their effects on the stage a beat after the call (the
  impact lands 0.07 s later; Charge is lightning, not particles). Nothing was wrong with them; the
  test now waits a moment and counts everything new on the stage.
- (later) The focus at first ran in every pack with its default numbers, and while it held, the
  cards a linked friend shares came half as often: the original pack's two-player test failed
  waiting for one. Now the focus runs only in a pack that sets it up (the City), and cards with a
  linked friend, scenes with people, a life's own story and the world's milestones are never
  made rarer by it. The two-player test passed 12 of 12 after.
- (later) A card could promise a Sanity loss and take one less: the same result's +1 Mental
  Strength was applied first and, crossing into a tier whose perk guards Sanity, softened it.
  The guard is now the one you had when it hit, as the card says (`Engine/Effects.luau`,
  `Sim:changeSanity`). Older than v0.18, like the pay one; the harder cards' different rolls
  exposed it.
- (later) On a phone, a side drawer left open (the You tab, say) stayed over the death screen, so
  the way back to the menu was hidden. The drawer and any open sheet now close when a life ends.
- (later) The mod menu's "give an Office" reached the screen as a pushed update, which didn't ask
  for the Office's name; pushed updates ask too now.
- (later) The harder cards first ignored the difficulty, so A Gentler City was barely gentler.
  The extra hardness now follows the difficulty (a third of it there, a third more at Night).
- (later) The storyline check found a second story (The Pit) that reached only one of its endings
  in 38 lives: its lives were dying before its last chapter. Two causes. The harder cards also
  hardened a life's own story chapters, which were tuned on their own; a story's chapters keep
  their tuning now (the hardness is for the City's cards). And a lost dread fight took 50 to 110
  Health once the City's damage was applied, so losing one was almost always death; their losses
  are about two-thirds of that now (a lost dread fight still hurts badly; two will kill you). The
  check also stopped blaming a story for a life the City killed before its ending (it counted
  lives that died between 30 and 45 as stories that never ended).

## Known: the two-player UI test is random

`tests/ui_smoke.luau` (original pack) plays several random lives with a second player, and some
runs fail on luck rather than a fault: player 1 dies before the linked card comes up, or a later
step (a crew proposal, a duel challenge) finds a life that ended or is too young. v0.17 failed
about one run in three the same way. The failure that pointed at the game (a card that never
came) had two causes, both fixed above. After the fixes it still came up once in nine runs, in
a run that wasn't instrumented, and not in the six instrumented runs after it, so a rarer
cause may remain. In the game, the card check runs every 2 seconds and the DECIDE button
fetches the card from the server again. The other cases in the file pass every run.

## Not checked

- Nothing here was run in Roblox Studio. The 3D stage, the particles, Bloom, the reverb and the
  camera shake were checked in the headless harness (what's created, where, and that it's all
  cleaned up) and in the renderer's approximation, not in the real engine. Play a boss battle,
  a duel and the mod menu's Effects tab in Studio before publishing.
- The Office's name and motto go through Roblox's text filter on the server
  (`TextService:FilterStringAsync`); the headless tests can't run the real filter, so how it
  treats a name is for Studio (or a live server) to show. A name it rejects, or turns to #'s, is
  refused with a message.
- The boss intro was checked headless (it plays to the end, no warnings, nothing left behind),
  not seen in the real engine: watch one in Studio.
- How hard the harder cards are was measured in headless lives (above), with the scripted
  choices the test makes; real players choose better and worse than that.
