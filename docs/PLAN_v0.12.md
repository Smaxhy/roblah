# v0.12: what each request became

Every request for this version, in the order it came, with what was built and where it lives.
Engine code is in `src/shared/Engine/`, the City pack in `src/shared/City/`, the server in
`src/server/` and the screens in `src/client/UI/`. `tests/v12_check.luau` checks most of it.

| Request | What it is now | Where |
|---|---|---|
| A friends lobby with the host's settings | "With friends" opens a full-screen lobby: the host sets age, District, side, difficulty and how you begin; everyone makes a character, readies up, and starts in the same year and place, already linked | `server/Crews.luau`, `client/UI/Lobby.luau`, `tests/lobby_check.luau` |
| No unlinking | The server refuses it | `server/init.luau`, `tests/lobby_check.luau` |
| "Who you know of": all five Fingers, the Wings, many more | 38 entries in five sections, learned from cards that name them, your District, your job, or a standing | `Engine/Known.luau`, `City/init.luau` (storyGates, knownGroups) |
| A linked friend shown twice; what you do with them should happen to them | One entry per friend (old saves mended); bonds move on both sides, their feed says what you did | `Engine/Sim.luau` (linkFriend, applyLinked), `Engine/Effects.luau` |
| Every action gives the stats its chips say | Chips are computed with the life's own numbers | `Engine/Report.luau`, `tests/chips_check.luau` |
| Glossary tags matching ordinary words | Names only, by case and context | `Engine/Sim.luau` (termMatches), `tests/tags_check.luau` |
| A life that became a book can't spend Ahn | Endings stop the life cleanly | `Engine/Body.luau` (endings) |
| Interact with people you've only met | Acquaintances: met year to year, talked to, befriended, or drifting away | `Engine/People.luau`, `City/init.luau` (acquaintances, interactions) |
| District distances; how a Library invitation works; who "her" is | Travel lore fixed; accepting the invitation takes you; no card opens on a bare pronoun | `City/Events/*`, `tests/v12_check.luau` |
| Say what your family owns | Households: the family Office, Workshop or stall, named | `City/Events/Life_Household.luau`, YOU tab |
| Expeditions seen by the other person | Linked friends' feeds: setting out, each fight, how it ended | `Engine/Expedition.luau` (news) |
| Health past its maximum, more canon | Most Health grows with Strength, Grade, form, gear and renown; ampules heal past full | `Engine/Body.luau` |
| The WARP train's secret | Kept | `City/Events/Wings_WCorp.luau` |
| Weapon abilities; Bloodfiend blood attacks | Weapons and foes fight with abilities (bleed, volley, guard, riposte...); Hardblood costs blood | `Engine/Clash.luau`, `City/init.luau` (abilities), `City/Foes.luau` |
| Bought scrolls didn't work or show | Books and scrolls show on the YOU tab and can be read | `client/UI/SidePanel.luau` |
| Friends' current stats | A linked friend's page shows every stat, most Health, job, renown, home and Office | `Engine/Sim.luau` (friendSheet), `client/UI/Sheets.luau` |
| Many more ways to spend money, harder mobs | Five markets and nine homes; foes and corporation work much harder | `Engine/Market.luau`, `City/Markets.luau`, `City/Jobs.luau` |
| The overpass sells more and changes with events | The Overpass Market: stock and prices follow the streets, world events and hard years | `City/Markets.luau` |
| Bloodfiend ranks; hunted if you sell them out | Fledgling, Hardblood Knight, Elder's Hand and the Elder come for you in turn | `City/Events/Bloodfiend_Hunt.luau`, `City/Foes.luau` |
| Friends ageing up without each other | Fixed: a crew ages together | `server/Crews.luau` |
| No canon Limbus people in scenes | Removed | `City/Events/Limbus_*.luau` |
| Different missions as you rank up | Jobs written for each rank; higher ranks get harder ones | `City/Jobs.luau`, `Engine/Jobs.luau` |
| Standings agree with "Who you know of" | A standing is shown on its faction's entry | `Engine/Known.luau`, CITY tab |
| Prodigies unlock things at different ages; different Canto names | Gifts that wake early, on time or late, each with its own opening; Canto titles and lines differ per life | `Engine/Talent.luau`, `City/Events/Prodigy.luau`, `City/Chapters.luau` |
| Buy houses, or something more adventurous | Nine homes, from a steel-door flat to a houseboat, a buried bunker or a whole building | `City/Markets.luau` (homes) |
| A marriage system | A household partner, within Roblox's rules: never romance, never another player | `City/init.luau` (share_household), `City/Events/Household.luau` |
| Outfits that match Project Moon | Uniforms per faction | `City/Cosmetics.luau`, `City/Careers/*` |
| Accurate ranks; Sections by District | Regional Sections and branches follow the District's direction | `City/init.luau` (directions), `City/Careers/*` |
| Much harder at certain ages | Hard years (crises) at the ages that bring them | `City/init.luau` (crises), `Engine/Body.luau` |
| "Decide what to do first" bug | A card that can't be answered is let go | `Engine/Sim.luau` |
| Much harder corporation missions | Corporation jobs pitched far higher | `City/Jobs.luau` |
| Too repetitive; the UI should feel different | Year moods that tilt events and colour the year's card, tag fatigue, Cantos per life | `Engine/Mood.luau`, `client/UI/Feed.luau` |
| The story loses meaning after 18; a bigger impact on the world; more ranks | Renown grades, deeds, your own Office, District holds shared by the server | `Engine/Renown.luau`, `City/Activities/Deeds.luau`, `server/City.luau` |

## Balance, from the headless runs

With markets in, a random player lives to a median of about 56 (the v0.11 baseline was 55):
80% reach 30, about 60% reach 50, about a quarter reach 70. Most adults reach the first three
renown grades; the top grades stay rare.

## Not tested in Roblox Studio

All of this was built and tested headlessly (Lune, the screen renderer, two- and three-player
server tests). Nothing was run inside Roblox Studio for this version.
