# v0.17: the climb past every limit, and a lot more to see

The requests (in order): a female character to choose, with a snatched waist; better VFX and
animations; a lot more monsters and character designs; bio arms; unique ways of fighting and
fighting styles; trainers later in life; the mod menu with many more options, character
customization, and easier to reach; a better build and player experience, cooler effects,
lore-accurate; strength up to 300, even 400; super hard bosses and unique events; cooler PvP
where both players choose, in turns; ages that go super old (not only dying of old age),
especially Bloodfiends growing old and strong; a more accessible and better-looking store,
maybe with codes.

| Request | What it is now | Where |
|---|---|---|
| Choose a female character, with a snatched waist | The creator has a **Body** tab: Masculine or Feminine. A feminine build draws the torso in bands (chest, upper waist, a narrow waist, hips) and every outfit, coat and augment arm follows the same line; shoulders and arms sit a little in, lashes over the eyes. Mothers are drawn feminine, fathers masculine, everyone else is rolled. Six new premade characters, three with each build | `Engine/Avatar.luau` (shapeFeminine), `City/Cosmetics.luau` (body), `client/UI/QuickStart.luau`, `Engine/Sim.luau` (parents) |
| Better VFX and animations | A new effects layer: slashes, impact bursts, shockwaves, screen flashes, damage numbers, phase banners, heal crosses, guard shields, confetti, and the seven statuses each with their own look (Burn embers, Bleed drops, Tremor rings, Rupture cracks, Sinking drops, Poise glints, Charge bolts). On the boss battle screen, the new duel screen, the regular fight screen and the 3D cutscenes. Preview them from the mod menu's Effects tab | `client/UI/Vfx.luau`, `BattleView`, `DuelView`, `ClashView`, `Stage` |
| A lot more monsters | Twelve new creature shapes, animated, in four poses: the Stopped Clocktower, an ALEPH with a halo of arms, the Night's Sweepers (hooks, beaked masks), the Spider Doll, the Shadow Hound, the Lamp Moth, the Drifting Jelly, the Stitched Giant, the Many-Eyed Mound, the Scrap Golem, the Smiling Bloom, and the Whale over the Great Lake. Nine new foes and six new encounters for them; existing fights that mention moths, hounds, scrap or the whale now show them | `Engine/Creatures17.luau`, `City/Foes.luau`, `City/Events/Strange17.luau` |
| More character designs | Sixteen new outfits (training wraps, a noodle stall apron, an Office Rep's long coat, a Liu elder's robe, Zwei instructor's plate, duel whites, an investigator's trench, a clan haori, an Elder's gown, a hunter's red coat, fitter's overalls, clinic scrubs, the Lantern's coat, an evening coat and skirt, a jacket and pleated skirt, a Nest day dress), and every trainer has a look of their own. Nine are free in the creator; the organisations' ones are issued like every uniform (Zwei and Liu Directors get the plate and the elders' robe, a Kurokumo Captain the clan haori; the rest are worn by trainers and bosses) | `City/Cosmetics.luau`, `City/Trainers.luau` |
| Bio arms | A fourth gear slot, **Arm**: nine augment arms (Spring-Coil, Hidden-Blade, Reel-Chain, Surgeon's Needle, Workshop Piston, Furnace Knuckle, a Smoke War carapace graft, an R Corp surplus gauntlet, a K Corp grown arm). Each is drawn on your left arm, raises a stat's ceiling, and carries its own way of fighting | `City/Gear/Augments.luau`, `Engine/Avatar.luau` (augmentArm), `client/UI/Arsenal.luau` |
| Unique ways of fighting, fighting styles | 35 new ways of fighting: 9 from teachers with no organisation (Counter Stance, Breaking Hook, Step Inside, Flurry, Read the Opening, Long-Shot Draw with Luck, Still Mind with Mental Strength, Command with Charisma, Last Stand with Health), 17 from the schools' own instructors in their canon statuses (Zwei, Liu, Seven, Devyat', Shi, Cinq, Dieci, Öufi, the Thumb, the Index, the Middle, the Ring, the Kurokumo, the Blade Lineage, a Bloodfiend Elder, W Corp, K Corp), and 9 carried by the arms | `City/Techniques.luau` |
| Trainers later in life | 26 trainers. "Look for someone to train you" (from 18) brings one who'd take you on; ask, or prove yourself. Then "Train with ..." is an activity: every lesson grows their stat past its old limits; techniques at set lessons; limit courses after. Association instructors only take their own members. Masters for stats past 130, and two who only teach people past 200 whose names the City already knows | `Engine/Training.luau`, `City/Trainers.luau`, `City/Activities/Training.luau`, `City/Events/Trainers.luau` |
| Strength up to 300, even 400 | Stat tiers go to XXI (400), with perks at 200, 300 and 400; Speed brings a fifth coin at 200 and a sixth at 350. What raises the ceiling: trainers' limit courses, augment arms, extreme bosses beaten, a Color's name (now +40 to every stat), renown, and old blood | `City/init.luau` (stats, clash), `client/UI/Hud.luau` |
| Super hard bosses and unique events | Seven extreme bosses with Health in the thousands, base 18 to 27, three phases: the Night's Sweepers, a Messenger of the Index, the Last Hunter, an ALEPH-class breach (L Corp years), the Umber Lantern (a Color who took a contract on you), the Stopped Clocktower (a Star of the City), and a Claw of the Head (for an Impurity). Each is a one-time event that finds lives the City has started to fear; all can be walked away from. In the test runs: around 250 stats is a coin flip against the first three, the Color and the Clocktower need about 300, the Claw is the last wall (a quarter at 300, nine in ten at 350). Fights last 12 to 30 turns | `City/Bosses17.luau`, `City/Events/Extreme17.luau`, `tests/_extreme.luau` (probe) |
| Cooler PvP, both players choose, turn-based | Duels are fought in turns now: both players pick every turn (any way of fighting they have, Guard, Feint, Patch up, Yield), hidden until both are in. Strike against strike is a real clash; Guard takes less than half and steadies you; Feint beats a Guard; a strike catches a Feint. A friendly duel ends at first real blood; a blood duel goes to the end (yield in time). After 25 seconds the one who chose can go ahead. Leaving mid-duel yields | `Engine/Pvp.luau`, `server/Duels.luau`, `client/UI/DuelView.luau` |
| Ages that go super old; Bloodfiends grow old and strong | A body lasts as long as its lifespan: 63 for an ordinary one, pushed back by K Corp regeneration courses (from 40), a Workshop body (from 45), a body hardened past its limits, a Color's name. Bloodfiends last centuries, and their blood grows stronger with its years: Old Blood (25), Deep Blood (50), Elder Blood (80), Ancient Blood (120), Blood of Ages (180), Undying Blood (260), each breaking limits. New phases (Long Life at 90, The Ancient at 150) and events for very long lives | `Engine/Body.luau` (lifespan, wearYear, elderBlood), `City/init.luau` (longLife, elderBlood), `City/Events/LongLife17.luau`, `City/Phases.luau` |
| The mod menu: many more options, character customization, easier to reach | A **MOD** button at the top right on every screen, F2, and `/mod` (or `/admin`) in chat. Tabs: Server, Player (any stat to 400, careers, standing, flags...), Look (character customization for any player: body, skin, hair, eyes, outfit...), Power (every stat at 100-400, limit breaks, lifespan, make them a Color, old blood, techniques, trainers), Fights (start any boss battle, the extreme events), Codes, Effects | `client/UI/AdminMenu.luau`, `server/Admin.luau`, `client/App.luau` (quick bar) |
| The store: more accessible, better looking, codes | A **STORE** button at the top right on every screen. The store opens on a header with your Lunacy and Light, a "Have a code?" box, and aisles to jump to each section. Codes: written into `Config.codes` (a WELCOME code is there as an example) or made in game from the mod menu (saved in a DataStore, seen by every server); once per player; six wrong tries a minute | `client/UI/Social.luau`, `server/Codes.luau`, `shared/Config.luau` |
| Lore-accurate | Associations teach their own members their own statuses (the schools' canon mapping); the Night's Sweepers, the Index's Messengers and Prescripts, Hana's Colors and threat grades, the Head's Claws, ALEPH breaches in L Corp's years, Bloodfiend Families and Elders, G Corp's Smoke War grafts, R Corp's Rhino armor, K Corp's regeneration. Every person and boss is the game's own; no canon character appears. The era check and the content safety scan pass | `tests/era_check.luau`, `tests/safety_scan.py` |

## Caught in the final test pass

- Seven of the new outfits belong to organisations (the Zwei plate, a Liu elder's robe, an
  Office Rep's coat, a clan haori, an Elder's gown, a hunter's red coat, the Lantern's coat), and
  the creator was offering them. They're uniforms now, issued, never picked: Zwei and Liu
  Directors get the plate and the robe with the rank, a Kurokumo Captain the haori
  (`City/Careers`, `uniformTop`), and the rest are worn by trainers and bosses.
- The original pack's ways of fighting (Steady, Reckless, Careful) name no stat, so its duels
  had no strikes. They strike with the pack's fight stat now, as its old duels did
  (`Engine/Pvp.luau`). A feint uses Speed, or the pack's work stat where there's no Speed.
- A pack without long lives (the original) keeps the old-age ages it always had: wear from 50,
  hard from 65 (`Engine/Body.luau`).
- The ALEPH breach was the one extreme card without a threat-grade gate: it found every L Corp
  employee past 22, and the career check caught researchers dying to it at 26. It needs an
  Urban Plague's name now (renown rank 5), like the others (`City/Events/Extreme17.luau`). With
  it, dedicated researchers reach Head of Research about as often as in v0.16 (7 of 12, against
  8 of 12, on the same seeds).
- Phones: the duel screen writes Health on the bars (it overlapped the names) and its move
  buttons are tall enough for their descriptions. The store's Redeem button keeps what was
  typed, so a store that redraws itself never leaves it reading a box that's gone.

## Not tested in Roblox Studio

Built and checked headlessly: the engine (`tests/v17_check.luau`), the real server code with
two players (`tests/duel_check.luau`, `tests/battle_check.luau`), the full suite, and the
screen renderer (`v17-*` and `duel*` states). Nothing was run inside Roblox Studio for this
version. Things worth trying there first: the MOD and STORE buttons, F2 and `/mod`, a duel
with a friend, an extreme boss from the mod menu's Fights tab, and the Effects tab.
