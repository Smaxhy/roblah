# BitLeveling

A Roblox life simulator set in the world of the original **Solo Leveling** manhwa (a
non-commercial fan game), built on the LifeSim blueprint kit below. Live a whole life before
and under the Gates; awaken or don't; raid, run, hide, rebuild. The world simulates its own
Gates (discovery, Association response, raids, Dungeon Breaks, Red Gates, Double Dungeons),
follows the manhwa's public timeline on the news, and has two worlds (Normal and High-Danger).
A live 3D city lets you walk as your own customizable **R6** character while Gates open around
you in real time.

- **Play:** open `build/BitLeveling.rbxlx` in Roblox Studio and press Play (build it with
  `bash tools/build_game.sh BitLeveling --no-test`).
- **Everything about it:** [`docs/BITLEVELING.md`](docs/BITLEVELING.md) (systems, canon vs.
  original content, the two worlds, the live city, R6 customization, testing).
- **The canon research:** [`docs/BITLEVELING_CANON.md`](docs/BITLEVELING_CANON.md).

---

# The LifeSim kit (v0.18) this is built on

A BitLife-style life simulator for Roblox, mostly GUI, with a procedural 3D city drawn behind
it. You live one life in the City, year by year, from birth to the end. The default content
pack is **A Life in the City**, a non-commercial fan work set in Project Moon's City
(*Lobotomy Corporation*, *Library of Ruina*, *Limbus Company*). The kit's original
starter pack, *Undermere*, is still included.

> **Fan work.** A Life in the City is not affiliated with or endorsed by Project Moon. Canon names
> and terms are used as in fan works, and all of the writing is original. Project Moon's fan
> rules ask for fan works to stay non-commercial. This copy has the Robux store **on**
> (`Config.store.sellInFanPacks = true`) because it's for a small private game. That's the
> owner's call; set it to `false` to sell nothing.

## What's in the box

| File | What it is |
|---|---|
| `build/LifeInTheCity.rbxlx` | A ready place. Open it in Studio and press Play. |
| `build/LifeSimKit.rbxmx` | The importable kit for dropping into your own place. |
| `src/` | The source the builds are made from (for editing with Rojo + VS Code). |
| `docs/CANON.md` | The canon bible the City content was written from (Districts, Wings, Fingers, Associations, L Corp, the Library, Limbus Company, career ladders, story hooks, Roblox safety notes). |
| `docs/CONTENT_GUIDE.md` | How to write events, careers, lore, chronicle acts, expeditions... |
| `docs/SETTING.md` | The Undermere starter setting. |
| `tests/` | Headless tests (Lune + Python): validation, thousands of simulated lives, career climbs, a Roblox content scan, UI and two-player tests. |

## New in v0.18

What each request became, and where it lives, is in `docs/PLAN_v0.18.md`.

**Real 3D effects.** Boss battles, duels and the 3D cutscenes now play on a real 3D stage in
the Workspace, not inside a picture frame, so Roblox's own particles, lights, beams, Bloom and
camera shake work on them. Every blow has a swing, an impact flash, sparks, a shockwave, a
camera shake and a small punch-in; heavy blows add an impact frame. Every status has its own
effect (Burn flames, Bleed drops, Tremor rings, Rupture cracks, Sinking blue drops, Poise
glints, Charge lightning), and there are heals, guards, phase changes, knock-downs and
a victory burst. The stage picks a set for each boss (an alley, a rooftop, a facility, the
lake...). The camera shake is RbxCameraShaker (Sleitnick, MIT), the UI springs are spr
(Fraktality, MIT), and several effect recipes are adapted from adnvli/vfxskill (MIT); their
licenses are in `vendor/`. **Settings > 3D fight effects**: Full, Lite (fewer particles and no
flashing lights, for slower phones) or Off (the flat fight screens).

**A lot more talents and traits.** 60 new talents across every rarity (15 Common, 13
Uncommon, 11 Rare, 9 Epic, 7 Legendary, 5 Unreal), and 36 **earned traits** that nobody picks:
a life grows into them by itself, the year it qualifies (Brawler after 15 fights won, Feared
at renown grade 4, Old Money after holding 100,000 Ahn, Survivor at 70, Iron Body at 150
Health...). The year's feed says "You've become something: ...".

**A bigger store, in the middle of the screen.** The store opens big and centered with a
header (your Lunacy and Light, the code box) and icon aisles: Featured, Everything, Lunacy,
Family names, Boosts, Passes, Looks. Featured shows the pass with everything first, then the
best value and the starter pack. Every item has an icon, and tags that say true things: Best
value, Starter, Permanent, Everything in one, Odds shown. Lunacy packs show how much Lunacy
each Robux buys. Cards light up when you point at them. The start menu has a store banner
too. There are no countdowns, no fake scarcity, and odds are shown before anything random.

**A mod menu you can give talents with.** Tabs with icons, and a player card with badges. The
new **Talents** tab shows what the player has (click a chip to take it away) and every talent
by rarity and sin, with search; and every trait, with a filter for the earned ones. Talent
cards make it their talent or add it as an extra; trait cards give or take away. The **Effects** tab can now play any 3D effect on the stage (you and a
training dummy) for a few seconds.

**Better sound.** Effects go through a compressor and an equalizer, vary a little in pitch and
volume each time, and on the 3D stage they come from where the blow lands. Heavy blows and
critical hits add a second sound and duck the music for a moment. The stage has its own echo
too: an alley at night, a stone hall for a boss, a hangar in the facility.

**Many more places to fight.** 16 new sets for the 3D stage (27 in all): a market, the docks, a
subway platform, a factory, a bridge, a construction site, a noodle bar, a library, a warehouse,
a sewer, a plaza, a train yard, a greenhouse, an office, a parking garage and an arcade. A street
fight lands in one of 14 places (the same fight keeps its place), Nest fights in their own, and
bosses and duels have theirs.

**Your own Office.** Open one (a deed on the DO tab) and it asks for its name, a motto under
it and the colour of the sign; your words go through Roblox's text filter. **Manage the Office**
(the You tab) to hire your friends and family (grown-ups who trust you enough: bond 40, or 55 for
someone you've only met; a close friend comes in at Grade 8), let people go, move into bigger
buildings (a rented room, a storefront, a whole floor, a city block, a tower; each has more desks
and pays more, and the big ones want a bigger name), and build rooms: a training room (+2 to your
fight stat a year, and your Fixers rise faster), an infirmary, an archive, an armory, a vault
(interest) and a **lab** for experiments (one action and 2,000 Ahn: a breakthrough that raises
your limit, a stronger you, a design to sell, nothing, or an accident). Every year the Office pays
its Fixers, earns what they bring in, and its Fixers rise through the grades. Three or more Fixers
on the roster (and an armory) make you stronger in every fight.

**Events follow on.** The card that starts something (an invitation to the Library, a contract
on your head, a grudge) becomes what your life is about for a few years: its follow-ups come
first, in order, with one fewer unrelated card around them, more cards about the same thing
turn up, and the card says so ("Following on · The Library").

**Much harder events.** Every fight and check on an event card is harder, a dangerous card more
so (+3 base and one more coin in a fight), and a dangerous card grows with you, so a strong life
still meets its match. Dangerous cards come half again as often, and most years the City sends
one more on top (the **dread** roll), drawn from the dangerous cards and 12 new ones: a Shi
Association contract, a word out of place with the Thumb (and its Capo, a year later), your name
on an Index Prescript, the Middle's Book of Vengeance (and its Big Sister), the Kurokumo raising
the fee, a Cinq duel, twenty Rats, a block that Distorts, a Devyat' courier's trunk, a Workshop
prototype, a sold Seven file, and a bounty. Each is a real fight with a real death, and the ones
you win pay like it. In headless lives on The City (choosing at random), the median life is now
26 years (it was 43) and about one in five reach 50 (it was almost half); a player who picks
their fights lives longer. **A Gentler City** keeps only a third of the extra hardness; **the
Backstreets at Night** adds a third more. A life's own story chapters keep their own tuning.

**Dungeons pay like dungeons.** Every expedition has a tier now (I to V, from the strongest fight
in it), shown on its card. A tier III run pays 2.5x, a tier IV 4x and a tier V 6x, with a bonus
haul on top (Ahn, renown, and at IV and V a higher limit for your fight stat).

**Bosses make an entrance.** Before a boss battle, the boss walks in on its own ground in 3D:
a gathering glow, the floor answers it, a red burst and ring, its name in red with its title, a
line, you raise your guard, and BOSS.

**Fixed.**
- After a death, **Back to the menu** and **Begin a new life** sit at the top of the screen, not
  at the end of the book (and Back to the menu is at the end too). On a phone, a side drawer or
  sheet left open no longer covers the death screen: both close when a life ends.
- The start menu says less and sits tighter: no paragraph, shorter mode cards, less space above.
- Hair no longer swings with an arm or a leg when someone walks (every hair style was checked).
- The column of small squares over the fight screen (confetti caught in a list layout) is gone:
  effects draw on their own layer now.
- "Decide what to do first" with nothing on screen: the game notices the card it's waiting on
  isn't showing, asks the server again, and puts it back. A new life started while the last
  one's death scene was still playing no longer ends up under its death screen, with its cards
  hidden.
- A card could come back after you'd answered it (an update that crossed your answer on the way)
  and then do nothing when chosen. The screen now keeps the newest view of your life and fetches
  it again if a card has gone stale.
- Night was too dark to see on the 3D stage, in fights and cutscenes. The dark moods (night, a
  boss, the facility, a Distortion) still have a night sky but light the people: brighter
  ambient, a key light over where they stand and a softer fill from the other side. The stage
  also holds its own light while it's up, so the city behind it can't pull it back to midnight.
- The Rats are a crowd, not an outfit: the Backstreets' lowest, like bums with knives. Nobody
  keeps score of what happens to a Rat, so beating or killing one costs no standing, there's no
  standing with them to show, and nobody comes after you for it.
- The "start at 18" option (Fixer's Road) is gone from the start menu and the friends lobby.
  Lives already on it carry on. L Corp Agent (hired at 18) and Kindred (a Bloodline pass)
  are still there.

## New in v0.17

What each request became, and where it lives, is in `docs/PLAN_v0.17.md`.

**Choose a female character.** The creator has a Body tab: Masculine or Feminine. A feminine
build has narrower shoulders and a snatched waist, and every outfit follows the line.

**Stats up to 400.** Tiers go to XXI, with perks at 200, 300 and 400, and Speed brings extra
coins at 200 and 350. The ceiling rises through **trainers** (26 of them, found from 18:
lessons grow a stat past its old limits, teach techniques, then break limits), **augment
arms** (a new Arm slot: nine bio and mechanical arms, each drawn on your figure with its own
way of fighting), extreme bosses beaten, a Color's name and old blood.

**35 new ways of fighting.** From teachers with no organisation (a counter, a hook, footwork,
fighting with Luck, Mental Strength, Charisma or your own Health), from each Association's and
Syndicate's instructors in their canon statuses, and from the arms.

**Extreme bosses and unique events.** Seven bosses with Health in the thousands for lives past
250: the Night's Sweepers, a Messenger of the Index, the Last Hunter, an ALEPH breach, a Color
who took a contract on you, a Star of the City Distortion, and a Claw of the Head.

**Duels in turns.** Both players choose every move (any way of fighting, Guard, Feint, Patch
up, Yield), hidden until both are in: strike against strike is a clash, Guard beats a strike,
Feint beats a Guard.

**Very long lives.** A body lasts as long as its lifespan: K Corp courses and Workshop bodies
push it back. Bloodfiends last centuries and grow stronger with every stage of old blood.

**More to see.** Twelve new monsters (the Clocktower, an ALEPH, the Sweepers, a spider doll, a
shadow hound, a lamp moth, a drifting jelly, a stitched giant, a many-eyed mound, a scrap
golem, a smiling bloom, a whale over the Great Lake), sixteen new outfits, and a new effects
layer on every fight: slashes, impacts, damage numbers, banners, and each status's own look.
Nine of the outfits can be picked in the creator. Zwei and Liu Directors and Kurokumo Captains
are issued theirs with the rank. The rest are worn by the trainers and the bosses, the way every
uniform is issued, never picked.

**For you.** A MOD button (and F2, and `/mod` in chat) opens the mod menu, now in tabs, with
character customization for any player and many more options. A STORE button opens the store,
which now has a header, aisles, and a box for redeem codes (`Config.codes`, or made from the
mod menu).

## New in v0.16

What each request became, and where it lives, is in `docs/PLAN_v0.16.md`.

**Boss battles in turns.** The big bosses are no longer one tap. Picking "Fight the Capo" (or
the Sottocapo, Big Brother Ugo, Proxy Sereno, Docent Amadeo, Captain Sayo, the Rhino, the
Bellringer, the Hostess, and the bosses at the end of three adult stories) opens a full-screen
battle that lasts as many turns as it takes, usually six to twelve:

- The boss has its own Health bar, with marks where it changes **phase** (harder hits, new
  moves, a line when it happens). The Sottocapo has three.
- Every turn the boss **shows its next move**: what it is, how hard it hits, whether it's heavy,
  and **who it's aimed at** (one of you, or everyone).
- You pick your move: **strike** with one of your ways of fighting (each shows its odds and
  damage), **guard** (take less than half, and steady your next strike), **patch up** (twice a
  fight), or **get out**. If the move is aimed at you, your strike is a clash against it: win
  and you land your blow and take nothing; lose and it lands on you. If it's aimed at someone
  else, your blow lands unopposed.
- Damage is real Health: the City's lethality applies, and a boss can kill you mid-fight.
  They're meant to be brutal: with stats around 75 a regular boss is a coin flip at best; around
  90 you're favoured; the Sottocapo still kills a third of the fighters who reach her at 90.

**With friends, everyone chooses.** When someone in your crew starts a boss battle, everyone
else in the crew who's free gets **"Join the fight?"**. Each fighter picks their own move every
turn; the turn plays out when everyone has chosen (after 25 seconds, anyone who has chosen can
go ahead, and whoever hasn't guards). The boss has more Health for each fighter, but it can only
aim at one of you at a time: everyone else's blows land unopposed. On **crew expeditions**,
every member now picks too (not just the captain): the crew does what most of you pick, a tie
goes the captain's way, and after 20 seconds the captain can go with the picks so far. Nobody's
year turns while anyone in the crew is mid-fight.

## New in v0.15

What each request became, and where it lives, is in `docs/PLAN_v0.15.md`.

**A harder City.** Lives are much shorter now, the way they are in Project Moon's City: wounds hit
harder, foes grow stronger as you age (and as your name grows), danger comes far more often
between twenty-four and forty-five, and an ordinary body starts failing at sixty-three. In two
headless balance runs the median life fell from 66 to 40 and 47; more than half of the lives
born in the Backstreets ended before fifty.

**Every life its own.** Each life is dealt its own share of what can happen (from its seed): a
quarter of the ordinary cards never come up in that life, some come rarely, some often. A story
someone else on the server is living right now comes up far less, so two players don't live
the same story. Chains, stories and a career's own cards are never dealt away.

**Ten new adult stories.** The stories that find you as an adult were where lives repeated most.
Ten more now: *Missing* (a girl from downstairs and a crew of child pickpockets), *The Old
Office* (a dead Fixer's unfinished contracts), *The Parcel*, *The Quiet Tenant* (a retired
Grade 1 upstairs), *Clean Books* (keeping a Syndicate's ledgers), *Changing* (a childhood
friend beginning to Distort, after the Light), *The Grudge Book* (the Middle), *The Pit*,
*The Hand-Me-Down* (an inherited blade and its enemies) and *The Last Stop* (the bus that
runs in the Night). Five chapters each, three endings, hard fights in the later chapters.

**Big bosses.** Fights in phases against the people who run the streets: a Capo of the Thumb and
then the Sottocapo, a Big Brother of the Middle, a Proxy of the Index halfway through a
Prescript, a Docent of the Ring, a Captain of the Kurokumo Clan, R Corp's Rhino, and two
Distortions, the Bellringer and the Hostess. You fight through their people, then the boss
itself, with the full cutscene entrance. Every one can be avoided at the door (pay, talk,
kneel, run). They're hard: stats around 80 win about a third of the time. Each drops a
one-of-a-kind piece, and every kill is news across the server: other players live with the
consequences (the Thumb closing ranks, the Middle hunting for whoever stood beside you).

**Many more Distortions.** Fourteen new ones after the Light, each one person and one feeling: a
queue that never moves, a man who can't stop apologising, a Mirror Tailor, a landlord with
ninety-nine keys, a Candle Widow, a Glass Choir, a ledger that collects, a rust garden, a
shadow without its man, a noodle stall that never closes, a thousand paper cranes, rain
indoors, an echo in the stairwell, Peccatula in the market.

**Growing up.** Twenty-four new things to do between three and seventeen (puddles, blanket forts,
rooftop tag, the canal bank, the old Fixer at the noodle stall, a Fixer gym, courier runs,
the water tower, the Rats' corner, debate club and the pool for Nest kids...) and twenty new
childhood and teen cards, so the Thumb, the Fixers, the Night and the Wings arrive a piece at
a time instead of all at once at eighteen.

**More middle of life.** Eighteen new standalone cards for the years between twenty-two and
fifty: two clients for one job, a floor of the factory closing, a Syndicate landlord, a
Workshop fire, an old schoolfriend who runs the Rats, a counterfeit ampule, a grudge match,
burnout, a building coming down, crossfire, a forged inheritance, a wounded Fixer at the door,
the ration line, a back-alley surgeon, a letter from past the wall, an old debt, something in
the drains, two Offices at war.

## New in v0.14

What each request became, and where it lives, is in `docs/PLAN_v0.14.md`.

**Cutscenes.** Moments that matter take over the whole screen and are acted out in 3D by your
own character (your look, your clothes, your weapon) on a small set: a Backstreets street or
alley, an old L Corp corridor, a rooftop, an office, clinic, diner or library, the Nest, an
underpass, a hall, a pier on the Great Lake, a stairwell, a training room.

- **Fights.** You and your foe walk in from either side of the street. The camera cuts to the
  foe up close, with a name plate and a line, then to you, then a low shot and **FIGHT**. After
  the fight screen, the fight's own rounds are acted out: whoever took a round lands a blow, and
  a tie is a parry. Then the blow that settled it: the foe goes down, or you end up on one knee.
  The first fight of a session, a boss and the fights in episodes get the long version; everyday
  fights get a short one, so a life full of fights doesn't drag.
- **Meetings.** Cards with a scene (the turning points of episodes, a turf war's first word, a
  case opening, an enemy you share with a rival...) open with you walking up to whoever it is,
  and they speak, as themselves. **Spending time with your own people** (a parent, a sibling, a
  friend, your mentor, your rival, your child) puts that person in the scene, with the look
  they have on your family page: the first time with each of them, then now and then.
- **Your year.** Training on a straw dummy, running the roofs, studying, working, resting,
  walking your blocks, acted out in a few seconds (the first time each, then now and then).
- **Going in.** A delve found in the world or an expedition opens with you walking up to the way
  in (an underpass, an old L Corp corridor, a pier, a street, an alley), its name and purpose
  over the shot, and you heading inside.
- **A new part of life.** When a phase begins (Youth, Making a Name, Power, Legacy), you walk
  out onto a roof and it's named.

Tap anywhere to skip. **Settings, Cutscenes**: All, Fights only, or Off. On a phone held upright
the camera opens its lens and steps back so both people stay in the frame.

## New in v0.13

What each request became, and where it lives, is in `docs/PLAN_v0.13.md`.

**Less of the same.** A card this life has already seen gets rarer every time it comes up, jobs
come with twists (a client who lied, a rival on the same job, an audit, a tip, rain), and the
lines an activity gives you rotate from year to year.

**Episodes.** Sixteen short stories that happen once in a life, a few cards long, chained card
to card (sometimes years apart), each with three or four endings that are kept on the STORY tab.
A buried L Corp branch whose intercom still pages an agent who never clocked out; a TETH unit
behind a flooded wall and the four kinds of work; the L Corp agent across the landing; an energy
truck on its side; a Library book with a Fixer inside it; a fallen Wing's medal; supper with a
Bloodfiend Family; a Workshop's masterwork; your Office on fire; a debt to the Middle; someone
from past the wall; an hour T Corp lent you; a streetlight that follows you home; thirteen
umbrellas; the last contract; an apprentice. Everyone in them is this game's own.

**Ways in, found in the world.** Delves and expeditions are found as a card (a hatch behind a
boiler, a lift with one button too many, a letter): go in now (no menu, no action, the descent
plays out as cards), remember the way, or leave it. The DO tab lists only the places you know.
Eight new delves each have a purpose of their own: exploration, survival, investigation, escort,
salvage, negotiation, escape, compliance.

**A midgame of its own.** *Turf wars* in the Backstreets: step in under your own name or a
Finger's colours, take blocks from whoever holds them, walk and collect them, hold them through
raids and parleys, and see what happens when a Finger notices you hold the whole District.
*Cases*: five investigations worked a clue at a time, each needing a different stat, each with
a finale that closes it more than one way. *Rivals* can be beaten properly once a year in the
yard, or made into friends. A *household* can become a *marriage* at the District office (never
romance, never another player; `Config.marriage = false` turns it off).

**An endgame of its own.** A life has *phases* (Childhood, Youth, Making a Name, Power, Legacy),
each opening new things. *Legacy*: the last contract Hana offers its old Fixers, an apprentice
who can carry your name on, a seat at Hana's table, an endowment for the District, memoirs.

**Higher stats, real goals.** Stats can go past 100: renown grades raise the limit, feats and
deeds break limits, legendary gear and full sets raise them, and tiers VI and VII have perks of
their own. *47 feats* from bronze to mythic (an Urban Nightmare's grade, every block of a
District, a million Ahn, every stat at 100, a stat at 130, a fifth generation) with progress
bars; the gold and mythic ones break limits.

**Many more things to own.** 60 new items: one-of-a-kind finds from delves, episodes, turf wars
and cases; seven Workshop lines sold as sets with two- and three-piece bonuses; big-ticket
legendaries from 12,000 to 26,000 Ahn. What you replace goes in your *stash*: equip it back or
sell it.

**Better screens.** Event cards dressed for what they are (an episode's name and progress pips;
terminal, descent, blood, library, street, smoke, strange, nest, lake and gold papers; a RARE
ribbon). The **Arsenal** (gear in framed rarity tiles, set bonuses, broken limits, the stash),
the **Workshop** (tabs by slot and by set, grouped by rarity), the **Goals** sheet (your phase,
ambitions, cases, episodes and the feats board), a **turf map** on the CITY tab, your phase,
cases and episodes on the STORY tab, and job twists on the jobs board.

## New in v0.12

What each request became, and where it lives, is in `docs/PLAN_v0.12.md`.

**Playing with friends.** "With friends" opens a full-screen **lobby**. Whoever leads the crew is
the host and sets the age, the District, the side of the wall, the difficulty and how you begin;
everyone makes their character in the lobby, readies up, and starts the same year in the same
place, already friends. Friends can't be unlinked. A linked friend is one entry (older saves that
held them twice are mended), and what you do with them happens in their life too: the same change
to the bond on both sides and a line in their feed. Friends who play together age up together.
A linked friend's page shows **how strong they are now** (every stat, most Health, job, renown,
home, Office), and your **expeditions show up in their feed**: setting out, each fight, how it ended.

**Who you know of, and where you stand.** "Who you know of" (CITY tab) now has sections: the
Fingers (all five, the Pinky included), the Backstreets (Syndicates, the Kurokumo Clan, the Rats, the
Blade Lineage, the Night), Fixers and every Association (Hana, Zwei, Shi, Cinq, Liu, Seven, Devyat',
Dieci, Öufi, each with its number), the Wings (L, K, W, R, T, H, S, U, N and G Corp, each with its
letter) and above and beyond (the Head, the Eye and the Claws; Bloodfiends; Distortions; the
Library; Limbus Company; the Outskirts). You learn of them by reading their name on a card, living
in their District, working for them, or having any standing with them. **Your standing with a
faction is shown on its entry**, so the two lists always agree.

**A grown life matters.** **Renown** follows Hana's grades for a threat, from Known on Your Street
through Urban Myth, Urban Legend, Urban Plague, Urban Nightmare and Star of the City to Impurity;
each grade gives most Health and pay, and the big ones are news on the whole server. **Deeds**
(DO tab) open with renown: found and grow your own **Office** (it pays every year), take a
street, clear the Rats out of a District, fund a clinic or an academy, hunt an Urban Legend,
challenge a Capo, drive out a Finger's branch, be made a Color. Deeds change **the District for
everyone on the server** (safer, richer, or with your name on its streets: CITY tab, The Districts).
Jobs differ by rank and get much harder; corporation work hardest of all; some ages bring **hard
years** (a Year of Distortions, Everything Comes Due...).

**Somewhere to spend it.** Five markets (DO tab, Spend), browsing free and buying without an
action. The **Overpass Market**'s tables change with the streets (quiet, tense, a turf war), with
what the City is going through this week (a breach, a long Night, the Thumb collecting, Hana's
exams) and with hard years, and its prices move too. **K Corp** sells HP ampules that heal past
full, check-ups and regeneration courses (cheapest in District 11). A **prosthetics surgeon** fits
arms, knees, eyes, hearts and spines (frowned on in District 14). An **Office's front desk** hires
out escorts, bodyguards, tutors and go-betweens for grudges. A **letting agent** sells nine kinds of
**home**, from a flat with a steel door to a safehouse, a room in Hongyuan, a houseboat on the
Great Lake, a bunker in an old L Corp branch, a Nest apartment, a townhouse or a whole building:
each has upkeep, makes trouble rarer, and can be sold back for half.

**People.** **People you've met** (neighbours, coworkers, the cook at the night stall) show up
year to year with ways to talk to them; get close and ask them to be friends, or they drift away.
A close friend can be asked to **share a household**: two names on the District's register, half
the upkeep, a better year at home, a child taken in together. It's written to Roblox's rules on
purpose: a household, never romance, and never with another player.

**Every life its own.** Talents of Gifted and above **sleep until a rolled age**: early, on time or
late. When a Prodigy's gift wakes, a different door opens for each: an academy scholarship, an
Office that signs you at eighteen as a Grade 8, or Hana inviting a late bloomer to the exam.
**Canto names differ for every life.** Years can have a **mood** of their own (the Year of
Strangers, a Loud Year in the Streets, a Quiet Year, a Year of Long Nights...) that tilts what
happens and colours the year's card, and last year's themes come up less this year.

**Bloodfiends.** The Family's ranks fight you if you **sell it out**: a Fledgling first, then a
Hardblood Knight, then the Elder's Hand, and if you were one of them, the Elder herself. Pay the
blood-price or stand your ground. Weapons have abilities in combat, and Bloodfiends fight with
their blood.

**Fixes and lore.** "Decide what to do first" with nothing to decide; bought scrolls that didn't
work or show; every chip gives exactly what it says; "What's that?" tags only on cards that name the
thing; a life that became a book can't spend Ahn; the Districts are as far apart as they are; a
Library invitation takes you when you accept; cards say who "she" is; your family's Office or
Workshop is named; Health can go past its maximum; the WARP train keeps its secret; no canon
Limbus characters wandering into scenes; outfits match Project Moon's descriptions; ranks and
Sections follow the District.

## New in v0.11

The plan this was built from, request by request, is `docs/PLAN_v0.11.md`.

**Fighting by stat.** Steady / Reckless / Careful is gone. In a fight you choose which of your
stats to fight with (`pack.approaches`, `pack.tempers`):

| Way | Stat | It gives you | Beats | Poor against |
|---|---|---|---|---|
| Overpower | Strength | wins pay a quarter more | Cunning foes | Quick foes |
| Outpace | Speed | a loss costs you less | Brutes | Cunning foes |
| Outthink | Intelligence | their coins land worse | Quick foes | Brutes |
| Talk down | Charisma | people only: win, and nobody holds it against you | | |

Every foe has a temper (Brute, Quick, Cunning) and the card marks the way with the advantage.
Speed still sets how many coins you have and who strikes first.

**Stats that do things.** Every 20 points of a stat is a tier with a perk (`pack.stats.perks`):
Speed gives more to do in a year, Charisma more time for people, Mental Strength guards Sanity,
Health takes the edge off wounds, Intelligence raises wages. Your highest stat is your **nature**
(+1 on everything that uses it, and events of that kind find you more often). Hover a stat bar to
see what it's doing for you and what the next tier gives.

**More to do, and it counts.** Four actions a year, up to seven. A career puts three **jobs** on
your board each year (`City/Jobs.luau`): each is a check or a fight pitched at your rank, pays,
teaches, and counts toward your next promotion. The rank card shows exactly what the next rank is
waiting on. Someone you're close to stands with you in one fight a year; closer still, and once in
a life they get to you in time.

**A story you can follow.**
- An opening for the age you were born into: three lines, then your District and family.
- A story strip above the feed: your story, what to do now, its chapters, when the next comes.
- A story now **finds you again** when the first one ends: 12 second stories through your job, your
  District or the City (`Storylines/Second.luau`, `Second2.luau`), and 2 more to be born into.
  24 in all. Five of the second stories can find anyone, so two lives rarely get the same ones.
- The Story tab shows **who's in it**: the faces of your story with a line each (a storyline's
  `cast`), joined by anyone who has spoken in a chapter you've lived.
- Every card and feed row has the color and mark of its thread: your story, work, people, your
  District, the age, a grudge.
- Random cards are down from 2.5 a year to 1.4.
- The turning points are full-screen moments (`UI/Cutscene.luau`): the Light, the Dark Days, the
  Library, the second Light, the voice at the brink, E.G.O, a Distortion.

**People.** Spending time with someone opens a small scene with two or three choices, each
leaning on a different stat (`Events/Scenes.luau`): your mother at the stall, a sibling on the
roof, a friend at twenty to three.

**The UI, rebuilt.**
- The middle of the screen is a feed of cards, one line each, with what changed as chips. Tap one
  for the words. A new year is a gold rule across the feed, and the year behind it folds down to
  titles and chips, so only this year is there to read.
- Six tabs with icons in one row (DO, PEOPLE, STORY, YOU, CITY, MORE) replace thirteen buttons.
- Activities are tiles: icon, name, what it gives, the odds. The description is a hover away.
- Choices are buttons with a badge for the stat, your number, the odds as a number and a meter,
  and the outcome as chips.
- The Story tab is a chapter timeline with your goals and their progress.
- Event text shows two sentences; the rest is behind "more".
- Stat bars are one smooth fill with a notch at every tier and the tier on a tag.
- A quick check has its own card: the stat, what it was against, both sides' coins and totals,
  and a band that says how it went.
- Every panel, sheet, row and button is lit from above and answers the pointer
  (`Kit.depth`, `Kit.sheen`, `Kit.edge`); panels are solid, so nothing shows through an overlay.
- Your figure stands in light the color of your nature.

**Fights, monsters.** The fight is staged where the scene was, the fighters are larger, and the
header says how you're fighting and whether it has the advantage. Monsters get a shading pass
(`Engine/CreatureDetail.luau`) and a glow in their own color.

**Tests.** `tests/v11_check` covers every system above; `tests/story_check` plays all 24
storylines to their endings; `tests/odds` prints the odds table for any check.

## New in v0.10

**The ages of the City.** The Smoke War is over before any life begins: it's how Lobotomy
Corporation won its Wing. Four times to be born into, and everything in a life follows the one
you're in (`pack.calendar`, `pack.world`, `tests/era_check`):

| Age | What's true |
|---|---|
| The Age of L Corp | Lobotomy Corporation holds District 12 in the fallen Wing's place. Nobody has a word for Distortion or E.G.O. |
| Its last year | The Light: three White Nights, then four Dark Days. It was meant to shine seven. All anyone outside knows is that it failed. |
| The Age of the Library | A Library where L Corp stood. Hana's rank for it climbs: Canard, Urban Myth, Urban Legend, Urban Plague, Urban Nightmare, Star of the City, Impurity. People at the brink hear a voice. |
| After the Library | The Library is cast out and a second Light shines seven full days. Shin and Mang can be trained. Distortions never stopped. Limbus Company is on the road. |

The years are the game's own framing, long enough to live in. They are not canon dates.

**The voice.** After the Light, a mind at the bottom hears Carmen (the player sees her name; the
person living the life never learns it). It is a conversation now. Take her hand and you Distort.
Look at what she shows you and refuse, with enough Mental Strength, and you manifest E.G.O, which
keeps her out for good. Look and fall short and you come back with a **volatile E.G.O**: strong,
costly, and no protection the next time, when you can finish it, let it go out, or lose yourself.
You can always refuse to look at all: it costs weeks of your life and gives you nothing.
The checks against her don't grow with your age or the difficulty (they're `fixed`). E.G.O is
for a strong mind: with someone to hold on to, a Mental Strength of 90 wins about half the time and
75 about one in six; alone, 90 wins one in five (`lune run tests/odds mind` prints the table). A
middling mind can get there the long way, through a volatile E.G.O and a second coin-flip. E.G.O is
*used* in a fight (its own approach) and paid for in Sanity; the stronger the mind, the less it
costs. After the second Light, Shin and then up to three rings of Mang can be trained the same way.

**Stats.** The four virtues are gone from the City pack. Health, Strength, Speed, Intelligence,
Charisma, Luck, Mental Strength, and Sanity (`pack.stats`; the engine takes any list now, and
Undermere keeps its virtues).
- **Speed** is how many coins you bring to a fight, and who strikes first: the clearly faster side
  attacks one-sided before the clashing starts; the slower side has to clash for everything.
- **Charisma**: time with people goes further, prices come down, and talking is its own check.
- **Luck** is dealt at birth: tilts every coin, dodges bad years, brings finds.
- **Mental Strength** decides the brink, and what E.G.O costs.

**Reputation.** Every power in the City has a standing with you from -100 to 100
(`City/Reputation.luau`). Beat one of theirs and it drops; kill one of a Finger's own and it's a
blood debt. Bad standing brings reprisals, each faction in its own way (`Events/Reprisals.luau`):
the Thumb's corrections and ledger, a Prescript with your name on it, the Middle's Book. Some are
aimed at the people you love. The City tab shows where you stand.

**No two lives alike.**
- Ten storylines now (four new, each tied to an age), and the last six you lived are avoided.
- Events you met in your last lives come up far less in the next (`recentEvents`).
- Any line can be written several ways (`text = { "one", "another" }`); each life is dealt one.
- 45 recurring characters go by a different name and face in each life (`names = { ... }`).

**You're told what's going on.** Every choice says what it gives or what it checks, with the odds
and who strikes first. Every event has a WHY line (your job, your District, the age, something you
did). The death screen says exactly what happened, in numbers, and what would have helped.

**The whole screen.** On a PC the game fills the window: you (figure, name, seven stat bars) on the
left, the story in the middle, the hub on the right. The start menu spreads out the same way: what
the game is and how hard it should be on the left, the ways to begin on the right, each saying what
it is. Family and friends have their own tab, their own three a year, and quick actions on every row.

**Also:** a difficulty picked before a life starts (three levels); places you can only go because
of your District (the Great Lake, the Time counters, the ampule clinics: 27 of them); 60 weapon
models held properly, 46 new weapons (light ones add Speed, heavy ones cost it), and each
organisation issues its own on your first day; 20 new clothing parts, sharper faction uniforms and
16 new outfits; 12 new monster shapes and 39 new foes; the Red Mist is long dead and only ever a
story; sound effects turned down.

## New in v0.9

**The lore pass.** Everything a player picks or meets now has to be true of the City.

- **The time frame is real.** The creator has a **When** tab: the age of L Corp (born around
  930), the last years of L Corp (950), after the Light (968), or let the City decide. Whatever
  the age, the life around it follows: no Library before the Light or after it's gone, no
  Distortions before the White Nights, no Limbus Company before its bus, no working L Corp after
  its fall. `tests/era_check` reads every line a player can see against the timeline
  (`pack.eraRules`) and fails the build on a mismatch. Known factions, families at birth, the
  daily event and what a breaking point looks like all follow the age too.
- **Nothing is picked that a person in the City wouldn't pick.** The creator is looks only:
  face, hair, civilian clothes. No weapon (weapons are found, bought or issued), no sins (two
  are dealt at birth), no preset builds, no faction costumes. District, family, side of the
  wall, talent and sins are rolled, and the birth screen shows each one land.
- **Disciplines belong to organisations** (`src/shared/City/Schools.luau`). Nobody discovers a
  way of fighting on the street any more. Liu teaches Burn, Seven and Devyat' Rupture, Shi and
  Cinq Poise, Dieci Sinking, Zwei and Öufi Tremor, W Corp Charge, the Kurokumo and the Ring
  Bleed, the Thumb its rounds, R Corp whichever Pack you're assigned to; a small Office fights
  the way its Rep does. A veteran can show a teenager the basics, but past mastery 2 a
  discipline is only taught inside. A manual written for a school only works for people trained
  in it. Members wear the uniform.
- **One story per life**, told to you at birth: six so far, each built on how the City works
  (Collateral, Feather Fall, Courtesy, Borrowed Coat, The Voice, The Prescript). The Story tab
  shows what your life is about, what's next and every beat so far; story scenes carry a
  YOUR STORY band; a goal line sits over the report. Every birth gets one.
- **Understanding the world.** Event cards offer "What's that?" chips for City words (tap or
  hover); the City tab lists who you've heard of and what became of them; learning of a faction
  is a moment in the report.
- **Family tab**: the household, parents, brothers and sisters, children, with faces and bonds.
- **Childhood has things to do**: twelve activities for ages 2 to 13, each with an emblem, what
  it's good for, and a clear DONE THIS YEAR mark. Schooling is a choice at six (academy,
  workshop or the street); nobody is "at an academy" who never got into one.
- **Looks**: 31 hair styles rebuilt with volume (13 new); weapons are held in a raised fist
  with the grip through the hand; seven 3D monsters (crows, a Sweeper, a Distortion, an
  Abnormality, an Ordeal machine, Peccatula, a stray hound) with strike, hurt and down poses.
- **Fights and dying**: a wind-up and lunge, the figure flashing red with a cut across it, a
  staged knockout; a short death scene (the fall, the cause typed out, FILE CLOSED) before the
  end-of-life screen.
- **46 more talents** (90 in all), every one something a person is born with. Rarity tiers have
  in-world names (Ordinary, Promising, Gifted, Prodigy, One in a District, One in the City).
- Hover (or tap) any condition, gear or world chip to read what it is. The hub has two rows of
  bigger tabs. Fixed: mode cards jumping on hover, red bars in the intro, tutorial numbers on
  the frame, banners over event text.

## New in v0.8

**Born, not built**
- The creator is one screen: your character on a stage, tabs for Looks, Skin, Hair, Face, Outfit,
  Weapon, Extras and Sins, and **Be born**. No build types: fighting styles are found in play
  (25 discovery events in the teen years; everyone has one by 18).
- Your family, District and side of the wall (Backstreets or Nest) are **rolled at birth**, with a
  reveal: four reels spin and land with Limbus sounds. Light adds rarer families to the roll.
- 21 premade looks (14 free, 7 signature ones shown with a lock), 8 new detailed free outfits.

**A story that builds**
- Lives are told in **Cantos** (I-VIII) with **Intervallos** between them: a title card for each.
- Faction content waits until a life has heard of the faction and is old enough: no Thumb Capo at
  seven. Rumors and sightings come first (`pack.storyGates`, the `knows_` flags).
- **517 new events** (1,583 in all): 91 for ages 1-6, 115 for 7-12, 132 for 13-17, 129 adult,
  and 8 multi-part story arcs that start in childhood and pay off in adulthood.
- 2-3 events a year from age 4 (1-2 for toddlers), talking scenes with faces (cast portraits),
  and an illustration on every event card (26 drawn scenes).

**Fights and checks that matter**
- Fights are a face-off: you and the enemy on a stage, coins over your heads, the winner lunges,
  the loser reels, taunts in speech bubbles. 35 foes with looks (or creature shapes).
- Every risky choice shows its stakes (what a win gives, what a loss costs) and the virtue's
  emblem. Virtues show their level, I to V, then EX.
- **Reckless**: +1 power per coin, wins pay 1.5x, losses hit 2x, costs Sanity. **Careful**: -1 base,
  half the stakes either way. Harder overall: stats grow slower (kids 60%, everyone past 60 at 70%),
  foes grow with your age, the power curve is flatter. Clash wins run about 60%.

**Screens and sound**
- The join intro is black now, with scanlines, embers, glitches and Don Quixote's shout.
- On a PC everything lives in one hub on the right: Activities, City (today's event first),
  Light, You, Archive, and Goals / Crew / Ranks / Store / Guide / Menu.
- Limbus sound effects for clicks, coins, clashes, parries, crits, staggers, Tremor Bursts,
  E.G.O and deaths (`Config.sfx`), boss music for boss fights, and calmer music that holds a mood
  for at least 90 seconds and plays fights over the top.
- Starting lives as a crew closes the crew sheet first; the tour waits for a clear screen.
- Emblems: shape-drawn logos for virtues, currencies, approaches, styles, sins, factions and tabs.

## New in v0.7

- **A join cinematic.** The clock runs out at 3:13 in District 23, the Night in the Backstreets
  slams in, a montage of the City (Wings, Fixers, the Fingers, Lobotomy Corporation,
  Bloodfiends) plays over camera shots of the 3D skyline, then the title drops in. It plays in
  full on a first join and as a short sting on later joins, then goes straight to the modes.
- **Game modes:** *A Life in the City* (from birth), *Fixer's Road* (a Grade 9 Fixer at 18),
  *L Corp Agent* (hired at 18 in the age of the Wings), and *Kindred* (a Bloodfiend from the
  first night, unlocked by becoming a Bloodfiend once, the Bloodline pass, or 8 Light).
- **A three-step creator:** (1) **your character**: a big turning figure, 10 premade
  identities (Office Fixer, Liu Firebrand, Blade Lineage, Kindred...), then every piece of the
  look, including a **signature weapon** (katanas, greatswords, spears, axes, censers); (2) your
  **sins** and talent; (3) a build card (Tremor Bruiser, Bleed Assassin...) and where you're
  born. The full creator is one tap away.
- **Affinities (the seven sins):** Wrath, Lust, Sloth, Gluttony, Gloom, Pride, Envy. Pick up to
  two; talents of your sins come up 3x as often within whatever rarity you roll (the rarity
  odds never change), and a matching talent **resonates** (+3% heads). 44 talents, a talent of
  every sin at every rarity.
- **Talents:** every life is born with one, from Common to **Unreal**, at real, shown odds.
  Free rerolls every day; more with Lunacy.
- **Lunacy:** a premium currency bought with Robux (the store's "Robux buy" packs) and
  earned a little by playing. It buys talent rerolls, family-name rolls, boosts and Light.
- **Gear with buffs and debuffs**, style weapons, armor that resists statuses, **boss drops
  and unique items**, and **books** that teach abilities.
- **Factions:** Offices, Associations, Fingers, Wings and Families recruit you; faction wars
  break out as world events.
- **Fixer rankings:** a Fixers leaderboard (best grade reached) and a Fights board.
- **Duels** with linked friends and crewmates, seen by both from their own side. Blood duels
  if you both play rough.
- **Aging up together:** in a crew, everyone readies up and the year turns for all.
- **The City is deadlier:** harder fights as you age, Fortitude losses hit 45% harder, and
  far scarier events.
- **A guidebook** (the **?** on the HUD, the start menu, Menu): how to play, then every stat,
  status, build, talent (with odds), trait, gear, book, career, faction, mode, family name,
  world event and expedition, built from the game data, with search.
- **Easier to read:** long event scenes show their opening with **More**; choices show one
  odds line; shorter tour.
- **By the numbers (City pack):**
  - 1,066 events (271 new), with 185 real fights;
  - 27 expeditions (16 new, including 4 crew raids and 3 faction-war runs);
  - 19 world events (6 faction wars) and 26 bad-luck hazards;
  - 82 gear items (39 unique drops), 23 books and 44 talents;
  - 221 lore entries, 82 records and 76 titles;
  - 49 outfits, 20 signature weapons and 10 premade identities.

## Quick start

**Option A: just play it.** Open `build/LifeInTheCity.rbxlx` in Roblox Studio and press **Play**.

**Option B: import into your own place.**
1. In Studio, right-click **ServerScriptService** and pick **Insert from File...**, then choose `build/LifeSimKit.rbxmx`.
2. Save the place (**File > Save to Roblox** or **Publish to Roblox**), or the kit is gone the next time you open it.
3. Press **Play**.

Use one option, not both: the place already contains the kit. If there are two copies, the
extra one prints a warning in Output and doesn't run. If you imported an older kit, delete it
before inserting this one.

The kit installs itself on start. It moves `Shared` to `ReplicatedStorage.LifeSim`, gives
each player the UI, and starts the server. That's why `LifeSimKit` looks emptier while the
game runs; everything goes back when you press Stop.

**Two players in Studio:** **Test** tab, **Clients and Servers**, 2 players, **Start**. Use
**Start with friends** on the start menu, or **Life > Friends** to link lives.

### Saving
Saves use ProfileStore (session-locked DataStores). In an unpublished place, or with API
access off, saves fall back to memory and are lost when you stop. To test real saves,
**publish** the place, then turn on **Game Settings > Security > Enable Studio Access to API
Services**. City saves live in the `LifeSim_City_v1` slot (separate from Undermere's).

## The first minute

1. **The intro cinematic** (above). Any key, tap or Skip ends it. Menu > Display > *Intro when
   you join* sets Full, Short or Off.
2. **The mode select:** *Continue* (if a life is going), a card per game mode, then *With
   friends* (everyone in your crew makes a character, the captain starts all the lives at
   once, in the same District and year, linked from day one), *Guidebook*, *Archive* and
   *Menu*.
3. **The creator, in three steps:**
   - **Character:** pick an identity or build your own: skin, hair and color, eyes and marks,
     clothes (over 50 outfits), a signature weapon, extras. A name.
   - **Affinity:** up to two sins, then your talent (reroll it).
   - **Build:** a build card and where you're born. **Begin**.
4. **The full creator** (*Full creator*):
   - name and looks (skin, hair, hair color, eyes, clothes, marks, accessories, frame: 124 options);
   - **when you're born** (below);
   - where you come from (9 origins);
   - **how you fight** (a style);
   - **traits** (pick 2 of 32);
   - **10 bonus stat points**;
   - your **family name**.
5. **A quick tour** points at +1 Year, Activities, Lore, the City panel and Life.
6. **The opening years** are written to hook a new player: a first memory for each origin
   at 2, the "home before three" rule at 3, a first friend at 5, and childhood scenes that
   teach the City by playing it.

## How it plays

- **The City:** twelve Districts, each held by its Wing (District 12 has none). Inside each
  District's walls is the **Nest**: clean, watched, expensive. Outside is the **Backstreets**,
  where most people live. Every night at 3:13 the Sweepers come. Be home.
- **When you're born** decides which chapters of history you live through. The City's
  history runs through four eras: the age of the Wings (L Corp runs District 12), the White
  Nights and Dark Days (978), the Library (979–982), and the Distortion era, when Limbus
  Company's bus is on the roads (983+). You can be born in one of three eras:
  - **The age of the Wings** (around 930). There's time to climb all the way up L Corp
    before the fall.
  - **Before the White Nights** (around 950).
  - **After the Light** (around 968). You grow up with the Library and the Distortions.

  The history milestones always fire for everyone living through them.
- **Careers to the top.** Every ladder can be climbed by someone who commits to it:
  - **Lobotomy Corporation:** Clerk → Agent Levels 1–5 → Department Captain → **Branch
    Manager**.
  - **L Corp Research:** Lab Assistant → **Head of Research** ("or just be a scientist").
  - **The Wings:** a District's own Wing (Class 1 → Executive), K Corp, W Corp cleanup, R Corp
    Packs, T Corp, H Corp's Hongyuan household.
  - **Fixers:** an Office, Grade 9 → Grade 1, maybe a Color.
  - **Associations:** Zwei, Liu, Seven, Devyat', Shi, Cinq, Dieci, Öufi and Hana, with
    Sections and Directors.
  - **Syndicates:** the Thumb (Soldato → Sottocapo), the Middle (Little Sibling → Great
    Sibling), the Index, the Ring and the Kurokumo Clan.
  - **Limbus Company:** the LCCB, LCE and LCD.
  - **Ordinary lives:** workshop, diner, academy, courier, clinic, Nest records office,
    landlord.
- **Fights only when it's a fight.** Most risky choices are **quick checks**: a small card,
  a few coins, success or failure. Only real fights (someone attacks you, a duel, a raid, a
  reception, a breach, a Distortion) open the full **fight screen** with Limbus-style statuses:
  - **Tremor:** bursts knock a coin away.
  - **Rupture:** every hit lands harder.
  - **Bleed:** they lose power when they act.
  - **Burn:** it ticks every round.
  - **Sinking:** they land fewer heads.
  - **Poise:** your crits.
  - **Charge:** builds to a discharge.

  Your **fighting style** marks the opponent with its status. Drill it (Activities) to raise
  its mastery and potency. Foes grow tougher as your life goes on.
- **Coin clashes:** your heads chance is **50% + Sanity**, so a shaken mind fails more. You
  choose how you go in: Steady, Reckless or Careful.
- **Canon encounters:**
  - **The Sinners:** each of the twelve has a story of their own that changes your life.
  - **Limbus Company's staff:** Dante, Vergilius and Charon.
  - **Ricardo:** Big Brother of the Middle, in District 21's Great Lake chapter and in District 8.
  - **L Corp:** the Sephirot as department heads, and 39 Abnormalities with their best work types.
  - **The Library:** invitations, receptions, and Roland and Angela.
  - **The Fingers:** the Thumb's manners, the Middle's Book of Vengeance, the Index's Prescripts.
  - **Lore you can uncover:** L Corp's secrets for the curious, the Night's rules, Golden
    Boughs and the Mirror Dungeon.
- **Arcs that span years.** A kid you shared bread with at 5 turns up at 30 as a Fixer, a
  Syndicate boss or a Rat, depending on what you did. Your academy rival becomes a Thumb Capo.
  The Fixer who walked you home offers you a job. There are dozens of these.
- **The Archive (lore):** 173 entries in plain words, 18 of them secret. What you find stays
  across every life. On a wide screen it sits on the left of your life; on a phone it slides in.
- **Today in the City:** one daily event for everyone, changing at midnight (UTC).
- **The shared world:** big deeds go into the server's **chronicle**: manifesting E.G.O,
  becoming a Distortion, a Grade 1 license, a written-in-the-Book grudge, a breach suppressed.
  52 kinds of deed each have **echo** events in other players' lives, which name the player who
  did it. The biggest go out in **chat** as `[CITY]` news, and every player's chat messages show
  their current title (`[Grade 7 Fixer]`).
- **Family names:** roll for a surname in the Lore/You panel. The odds are shown up front
  (Common 60%, Uncommon 25%, Rare 10%, Epic 4%, Legendary 1%), and a pity counter guarantees a
  Rare within 10 rolls. Rarer names carry a trait for every life. Rolls are earned (one a day,
  one per finished life, more for big moments), never sold.
- **Also in v0.5:**
  - expeditions (solo or crews; 11, including the Mirror Dungeon, a reception crew and a
    containment job);
  - side quests (9);
  - world events (13, era-gated);
  - ambitions (three goals at a time);
  - records and titles;
  - heirs and family lines;
  - linked lives with friends;
  - rankings;
  - a daily streak.

## Game modes

| Mode | Starts | Unlock |
|---|---|---|
| A Life in the City | Born: the age, District, family and side of the wall are rolled (or pick the age on the When tab) | open |
| Fixer's Road | 18, a Grade 9 Fixer who just passed Hana's exam. **Off the menus since v0.18** (`hidden = true`): lives already on it carry on, and the tests still use it (`Config.devModes`) | hidden |
| L Corp Agent | 18, hired by Lobotomy Corporation. Only in the age of L Corp | open |
| Kindred | 18, a newly made Bloodfiend of the Morvaine Family, with Hardblood | become a Bloodfiend in any life, the Bloodline pass, or 8 Light |

Your talent and sins still apply in every mode. A crew that starts together uses the
captain's mode (everyone needs it unlocked). Modes live in `pack.modes` in
`src/shared/City/init.luau`.

## Talents

Every life is born with one random talent and two of the seven sins. Nobody picks either. A
talent of one of your sins resonates (+3% heads in every clash), and a family's sins lean its
next child's talent the same way (3x as likely inside whatever rarity is rolled; the rarity
odds never move). The odds are real and shown on the creator's Talent tab:

| Tier | Odds | For example |
|---|---|---|
| Ordinary | 52% | Quick Hands (Lust): Justice grows 25% faster |
| Promising | 26% | Short Fuse (Wrath): +1 power per heads in fights |
| Gifted | 13% | Iron Stomach (Gluttony): 25% less Fortitude damage, +10 Fortitude |
| Prodigy | 6.5% | Born at 3:13 (Gloom): +2 coins in Prudence checks, +12 starting Sanity |
| One in a District | 2.2% | Born to Rule (Pride): +1 coin in every clash |
| One in the City | 0.3% | Echo of the Red Mist (Wrath): +2 coins, +3 base, +2 potency, 40% less damage |

A talent is something a person is born with. Techniques belong to organisations (see
Disciplines). 3 free rerolls a day (5 with VIP), then Lunacy. The guidebook lists all 90.

## Gear, boss drops and books

- **Every weapon, armor and charm** has buffs, and most have a debuff: power in clashes on one
  stat, coins in fights, heads chance, status resistance, less Fortitude damage, yearly
  Sanity or Ahn costs.
- **Style weapons** (Quake Hammer for Tremor, Crack-Point Spear for Rupture...) only work with
  their own fighting style.
- **Armor resists statuses:** a Fireproof Duster takes Burn off the foe in a fight.
- **Boss drops and unique items** are never sold: legendary weapons, armor and charms from
  the City's named terrors, raids and faction wars.
- **Books** turn up in fights, expeditions and odd shops. Reading one (an activity) teaches
  an ability for good. Unread books pass to your heir.

## Playing with friends

- **Linked lives:** link with a friend (Life > Friends) and your lives cross.
- **Crews** (up to 4): start lives together (same District and year, the captain's mode),
  run expeditions together (the captain calls the shots), and **age up together**: everyone
  presses Age Up, and the year turns for the whole crew once all are ready. After 20 seconds the
  captain can go on with whoever is ready, or switch it off.
- **Duels:** challenge a linked friend or crewmate (Crew > Duel). Each of you fights with your
  best of Justice and Fortitude, your style, mastery, gear, traits and talent, and you both
  watch the same fight from your own side. One duel per pair per year. A friendly duel ends at
  first blood; if you both play rough, it's a **blood duel** and the loser can die.
- **Faction wars and world events** reach everyone on the server at once.

## Disciplines

There are no builds to pick. What a life can do comes from where it has been.

A **discipline** is a way of fighting, and each one belongs to the organisation that trains it
(`src/shared/City/Schools.luau`):

| Fights on | Taught by |
|---|---|
| Burn | the Liu Association, the Thumb |
| Rupture | the Seven Association, the Devyat' Association, K Corp, Limbus Company's LCCB |
| Poise | the Shi Association, the Cinq Association, the Blade Lineage |
| Sinking | the Dieci Association, R Corp's Reindeer |
| Tremor | the Zwei Association, the Öufi Association, the Middle, T Corp |
| Charge | W Corp, the Index, R Corp's Rhinos |
| Bleed | the Kurokumo Clan, the Ring, R Corp's Rabbits, Bloodfiend Families |

- Join one and you're taught its discipline (and issued its uniform). A small Fixer Office
  fights the way its Rep does, so that one is rolled when you sign on.
- A teenager can be shown the basics by somebody who was trained there (the `tt_` events).
- Outside the organisation a discipline stops at mastery 2. Inside, it goes to 5.
- Changing organisations means retraining: half of what you knew carries over.
- The Blade Lineage has no organisation left to lock it away: it's handed from one person to
  the next, and it can be taken all the way.
- A manual written for a school (`book.schools`) only works for someone trained in it.

Style traits (Aftershock, Deep Cuts, Kindling...) still only work with their own status.

## E.G.O and Bloodfiends

- **E.G.O:** at your breaking point (Sanity at the bottom), look your own Distortion in the eye.
  Win, and you manifest **E.G.O**: a form with an extra coin and more power in every clash. Lose,
  and you become a Distortion.

  L Corp Agents can also earn **E.G.O gear** from the Abnormalities they work with well:
  Penitence, Solemn Lament, Justitia and the Lamp.
- **Bloodfiends** (Limbus Company, Canto VII) are a path you can choose:
  - **Ways in:**
    - help Livia of the Morvaine Family in an alley, and she later offers you the Kindred's gift;
    - a Bloodfiend you know offers it at your deathbed;
    - La Manchaland's starving staff (Limbus era, District 16);
    - the **Raised by a Family** origin, whose Family asks you once, at 18.
  - **What changes:** you heal fast, age slowly, and fight with **Hardblood**.
  - **The cost:**
    - **the Thirst:** Sanity drains a little every year, and **Hemobars** or the Family cellar
      fill it back up;
    - Fixer Offices take contracts on you;
    - at your breaking point you don't Distort: you fight to keep your name, or are lost to
      the Thirst.
  - **Life as Kindred:**
    - serve a Bloodfiend Family, from Fledgling up to Steward;
    - live by its Taboo: a Child never turns against their Parent;
    - fight rival Families;
    - make at most two Kindred of your own;
    - outlive everyone you know.
  - **Roblox-safe:** a Bloodfiend here never feeds on a person.

## Layouts: phone, tablet, PC and console

The UI picks a layout from the screen:
- **Wide screens (PC, console):** the Archive panel docked on the left and the City/You panel
  on the right of your life.
- **Phones:** those panels become drawers.

Gamepads work: **B** closes sheets, and console screens get a bigger scale. Players can set
the size themselves in **Menu > Display**: Auto, Small, Big or Huge.

## Menu and settings

**Menu** (on the HUD and the start menu):
- **Sound:** music and effects volume, saved per player.
- **Display:** interface size; screen shake and flashes on or off; **3D fight effects** (Full,
  Lite with fewer particles and no flashing lights, or Off for the flat fight screens); intro
  when you join (Full, Short, Off); cutscenes (All, Fights only, Off).
- **Family name:** the surname roll.
- **Guidebook:** how to play and what everything does (also the **?** on the HUD).
- **Store:** Lunacy, rolls, boosts, passes and looks.
- **Quick tour:** the tour again.
- **Watch the intro:** the full opening again.
- **Mod menu:** only for admins.

`LifeSimKit > Shared > Config`:
- `pack`: `"City"` (default) or `"Undermere"`.
- `backdrop`: the 3D city behind the UI (`false` if your place has its own scenery).
- `chatNews` / `chatTags`: `[CITY]` news lines in chat; titles in front of chat names.
- `music`: tracks by mood, and which mood plays where (see Music).
- `admin`: who gets the mod menu (below).
- `dataStoreName`: change the suffix to wipe all saves.

## The store

Open from the **STORE** button at the top right, **Menu > Store**, the store banner on the start
menu, and the family-name roll. Since v0.18 it opens big and centered, on a header (your Lunacy
and Light, the code box) and aisles with icons: **Featured** (the pass with everything, then the
best value and the starter pack), Everything, and one per section. The tags only say true
things (Best value, Starter, Permanent, Everything in one, Odds shown), Lunacy packs show how much
Lunacy each Robux buys, and nothing counts down or claims to be running out. Prices are
suggestions; the catalog is in `src/shared/City/Store.luau`.

**Two currencies:**
- **Robux** buys **Lunacy** packs, passes (forever) and looks.
- **Lunacy** buys rolls, boosts and Light in game, after a confirm, and rerolls your talent in
  the creator. Players also earn a little by playing: 10 a day (20 with VIP), 2 per finished
  life, and 3 per new Record.

| Section | Items |
|---|---|
| Lunacy (Robux) | 60 (25 R$), 250 (89 R$, +30 free), 700 (229 R$, +100 free), 1,600 (449 R$, +300 free, the best rate) |
| Family names (Lunacy) | 3 rolls (40), 12 rolls (130), a Rare-or-better roll (75), 5 of them (300) |
| Boosts (Lunacy) | Second Wind: a full heal for the life you're living (50). A Fortune: 2,000 Ahn (60). A Master's Lesson: +2 style mastery (60). 6 Light (45), 25 Light (160) |
| Passes (Robux, forever) | Third Trait (149 R$). Born Gifted: +4 creator points (149 R$). Bloodline: the Kindred mode and the Raised by a Family origin, with Bloodfiend looks (199 R$). Wing VIP (399 R$): both perks, plus 2 more free talent rerolls and double Lunacy every day, a free family-name roll daily, +1 Light per finished life, a star in your chat tag, a VIP coat and frame |
| Looks (Robux) | E.G.O Wardrobe (129 R$), Signature Arms: Gilded Katana, Jade Halberd, Obsidian Greatsword (79 R$), File Card Set (59 R$), Rare Dyes (39 R$) |

**Talent rerolls** (in the creator): 3 free a day (5 with VIP), then 30 Lunacy each. A
**Rare-or-better** reroll costs 150 Lunacy, and Legendary or better is guaranteed within 10 of
them.

Boosts bought between lives wait for the next life.

**Rolls and Lunacy rerolls are paid random items:**
- their odds are shown before buying;
- the server checks Roblox's `PolicyService` and hides them from players where paid random
  items are restricted (those players still get the free daily rerolls);
- when you set up the experience, answer Roblox's questionnaire to say it has paid random items.

**To sell for real:**
1. Creator Dashboard > your experience > **Monetization**. Make a **Developer Product** for each
   Lunacy pack and look, and a **Game Pass** for each pass.
2. Paste each id into its item's `id` in `src/shared/City/Store.luau`, and match the price.
3. Publish.

Purchases are granted on the server, and receipts are remembered so nothing is granted twice.
With `testInStudio = true`, everything can be "bought" for free in Studio to try it.

## Mod menu

Whitelisted in `Config.admin`:
- the user id **523337247**;
- the place owner;
- anyone in Studio (`owner` and `studio` can be turned off).

Every action is checked on the server, and logged to Output as `[LifeSim admin] ...`.

**For the whole server:**
- start or end any world event;
- set today's event;
- send an announcement (filtered by Roblox's text filter).

**For a player in the server:**
- fire any event into their life (for example `bf_gift_offer` to offer the Kindred's gift);
- set what they are (human, E.G.O, Bloodfiend);
- set a stat, Sanity, money or age;
- heal them;
- add or remove a trait;
- set their fighting style and mastery;
- give gear;
- add a condition;
- end their life;
- set their talent (any tier, Unreal included);
- give surname rolls, Light or Lunacy;
- unlock every cosmetic, origin and mode.

The **Talents** tab (v0.18) shows the talents and traits the player has (click one to take it
away) and every talent by rarity and sin, with search, and every trait, with a filter for the
earned ones. A talent card can make it their talent, add it as an extra, or take it away; a
trait card gives it or takes it away. The **Effects** tab plays any 3D fight effect on the stage
for a few seconds (you and a training dummy), and the flat ones over the menu.

## Music

`Config.music` maps moods to tracks from Roblox's free music library (about 50, including
quieter tracks for menus, the lore panel and slow years) and decides which mood plays where:
- your District;
- the Nest or the Backstreets;
- childhood;
- fights;
- the death screen;
- world events, by name or by tone.

To add tracks, paste ids you're allowed to use from the Creator Store (**Audio > Music**) into
a mood. The official Project Moon soundtracks aren't included: they're copyrighted, and
Roblox only plays audio uploaded with permission.

## Text and safety

- **Names typed by players** pass through Roblox's text filter (`FilterStringAsync` + broadcast
  filtering) before anyone else sees them. A name that comes back filtered is refused, and the
  game rolls a random one.
- **Announcements** are filtered the same way.
- **Chat tags and news** are made from game data, not player text.

The City pack is written for Roblox's **Moderate** maturity label:
- violence is implied, never graphic;
- no gore detail, cannibalism, sexual or romantic content, alcohol, drugs, smoking, gambling,
  profanity or self-harm;
- the breaking point is a *Distortion*;
- the Sin of Lust is called *Desire*.

`python3 tests/safety_scan.py` checks all of it.

## Writing your own content

The City pack lives in `src/shared/City/`, and almost everything is a folder of modules that
`init.luau` merges. Several people can write at once, and duplicate ids are reported. Formats
are in **`docs/CONTENT_GUIDE.md`** (see "The City pack's layout"); canon facts are in
**`docs/CANON.md`**. The server validates the whole pack on start and prints any mistakes to
**Output**.

## Developing with Rojo (recommended)

```bash
rojo serve default.project.json
```
Connect with the Rojo plugin in Studio, then edit `src/` in VS Code. Changes sync live.
`./build.sh` runs every test and rebuilds both files in `build/`.

## Tests (no Studio needed)

```bash
lune run tests/run 2000
```
Validates the pack and plays 2,000 lives. Lives are born in every era, share one server
chronicle, and get a daily event. It reports lifespans, deaths, causes, clashes, expeditions
and events that never fire.

```bash
lune run tests/city_check 30
```
City checks:
- every era of birth starts in its years;
- every career can be joined;
- dedicated lives climb each ladder (the rate of reaching the top is printed for every
  career; Branch Manager and Head of Research must be reachable);
- every chronicle deed is recorded and echoes;
- talents land at their stated odds (200,000 rolls), every sin has a talent at every rarity,
  and leaning toward a sin never moves the rarity odds;
- every game mode starts at the right age, job, form and era;
- Fixer grades map right (Grade 9 to a Color), and a duel replays the same from both sides.

```bash
python3 tests/safety_scan.py
```
Roblox content scan of every City string.

```bash
lune run tests/era_check          # add "list" to see every mismatch
```
The timeline audit (v0.9): every line a player can read is checked against `pack.eraRules`.
Nothing may mention Limbus Company before its bus, the Library outside its years, Distortions
before the White Nights, or a working L Corp after its fall, unless its conditions already keep
it to the right age. Run it after writing content.

```bash
lune run tests/story_check
```
Storylines (v0.9): every birth gets one, each opens, its beats come at their ages, and each
reaches at least two endings.

```bash
bash tools/avatar/shoot.sh hair weapons creatures
```
Contact sheets of the figures (hair styles, held weapons, the 3D monsters in every pose),
drawn by the real viewer code. PNGs land in `tools/avatar/shots/`.

```bash
lune run tests/v5_check
lune run tests/ui_smoke
LIFESIM_PACK=Undermere lune run tests/ui_smoke
```
- `v5_check`: traits, builds, statuses, fights vs checks, lore, the chronicle and the daily.
- `ui_smoke` on the City pack: the full intro cinematic, the mode select, the quick creator
  with talent rerolls, the guidebook, the full creator with eras, side panels, settings,
  family names, Lunacy purchases, the Bloodline pass unlocking Kindred, the mod menu and
  whole lives, through the real server and client.
- `ui_smoke` on Undermere: every screen, plus a two-player test: linked lives, a crew
  expedition, aging up together (a ready check), and a duel in turns (v0.17), played out to
  the end on player 1's real duel screen while player 2 answers through the server.

```bash
lune run tests/v13_check
lune run tests/v12_check
lune run tests/lobby_check
lune run tests/tags_check
lune run tests/chips_check
```
- `v17_check` (v0.17): stats to 400 (tiers, perks, extra coins), lifespans and old blood,
  trainers (a whole course: techniques and limit breaks), augment arms (bought, worn, drawn,
  fought with), every technique a real way of fighting, the extreme bosses, duels in turns, a
  feminine build's waist, and the twelve new creature shapes. `lune run tests/v17_check`
- `duel_check` (v0.17): a duel in turns on the real server with two players: the challenge,
  hidden choices, the wait, going ahead, the end. `lune run tests/duel_check`
- `v16_check` (v0.16): every battle choice names a real boss and keeps its clash fallback;
  picking one starts a fight in turns (the card says so, with no style picker); nothing else
  moves mid-fight; the boss shows its next move and you see your odds; guarding, patching up
  (twice) and getting out work; bosses change phase; fights last; a win gives the choice's win.
- `battle_check` (v0.16): the same on the real server with two players in a crew: the invite,
  joining (the boss gets more Health), the turn waiting for both, no choosing twice, going ahead
  after the wait, and both lives cleared at the end.
- `v15_check` (v0.15): two lives are dealt different shares of the City, and chains, stories
  and career cards are never dealt away; a story someone else on the server is living comes up
  far less; the ten new adult stories each have chapters at 0, 1, 3, 5 and 7 years and endings
  on the last; every big boss's approach leads to its boss card, every win records an act that
  other players hear about, and drops gear that exists; the new Distortions only come after the
  Light; children have the new things to do; the City is harder (danger by age, lethality, a
  shorter lifespan).
- `v13_check` (v0.13): a way in found in the world starts a delve straight away and is
  remembered; an episode's cards know their episode and step, follow each other, and keep their
  ending; turf wars (joining, taking and losing blocks, what they pay, the fight with whoever
  holds a block, holding the whole District); cases opened, worked, finished and closed; feats
  and phases at the right time; stats past 100 (renown, limit breaks, gear, sets, tier VI); the
  stash (equip, sell); set bonuses; rivals made friends; a household made a marriage, and the
  switch that turns it off; job twists. (v0.14) Every card with a scene carries it to the
  screen with a look for whoever is in it, and an evening with someone you know opens a short
  scene with that person in it. The cutscenes themselves are drawn by `gui_snapshot` (the
  `v14-*` states: a fight walking in, the close-up, FIGHT, the exchange, the fall; a meeting on
  the stairs; a creature in the street; the L Corp corridor; training; a new part of life;
  going into a delve).
- `v12_check` (v0.12): cards that can't be answered are let go; linked friends are one entry,
  what you do with them reaches them, and they show their current stats; who you know of, with
  the standing on each entry; markets (stock and prices that change), homes, hired help and
  K Corp's ampules; selling out a Bloodfiend Family and its hunt; gifts that wake at different
  ages; Canto names per life; households (never romance, never another player); people you've
  met; year moods and tag fatigue; renown grades, deeds, Offices and District holds; harder,
  different jobs at higher ranks.
- `lobby_check`: three players start lives together on the real server code.
- `tags_check` / `chips_check`: "What's that?" tags only where a card names the thing; every
  chip gives what it says.

Other tools:
- `tests/clash_table`: odds by stat;
- `tests/avatar_check`: every look at every age;
- `tests/systems_check`: expeditions, crews, quests and scores;
- `tests/harm_report`: the harshest events.

## Libraries & tools (checked on GitHub)

| Project | Use | Notes |
|---|---|---|
| [rojo-rbx/rojo](https://github.com/rojo-rbx/rojo) | Sync files into Studio, build `.rbxlx`/`.rbxmx` | used to build this kit (7.7.1) |
| [lune-org/lune](https://github.com/lune-org/lune) | Run Luau outside Roblox | runs the tests (0.11.1) |
| [JohnnyMorganz/luau-lsp](https://github.com/JohnnyMorganz/luau-lsp) | Type checking with Roblox API types | VS Code extension + CLI |
| [MadStudioRoblox/ProfileStore](https://github.com/MadStudioRoblox/ProfileStore) | Session-locked saves | **bundled**, Apache-2.0 (see `vendor/`) |

Avoid random free models and unknown plugins. They're the usual way Roblox games get
backdoored.

## Licenses

The kit code and the Undermere content are yours to use and change. The City pack is a fan
work: Project Moon's names, terms and characters belong to Project Moon. Their fan rules ask fan
works not to be sold; this copy's store is on by the owner's choice, for a small private game. ProfileStore is by loleris (MAD STUDIO), Apache License 2.0; see
`vendor/ProfileStore-LICENSE.txt`.
