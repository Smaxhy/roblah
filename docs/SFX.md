# Sound effects (BitLeveling)

Everything the player hears that isn't music. There are three client modules:

| Module | What it does |
|---|---|
| `src/client/Sfx.luau` | The mix: one SoundGroup per bus, compressor and EQ, and the Effects volume setting (`Sfx.setVolume`, `Sfx.getVolume`, `Sfx.onVolume`). It also plays the app's named one-shots from `Config.sfx` (`Sfx.play("click")`) and maps the legacy files (`Sfx.soundId`). |
| `src/client/UiSounds.luau` | Every button in every GUI clicks on press and ticks softly on hover, including buttons made later. It also plays the app's named UI sounds and the spin ticker. |
| `src/client/WorldSfx.luau` | The 3D world: weapons, magic, monsters, Gates and the city, each placed where it happens. Also the opening and the title. |

`init.client.luau` starts all three before the opening plays, so even the opening's SKIP button clicks.

## Where the sounds come from

The rule is **real sounds only**: no invented ids. Every id used was looked up in the Roblox Creator Store's own records (`apis.roblox.com/toolbox-service/v1/items/details`), which give the asset's name, creator and published state. Only three kinds of source are used:

| Source | What it is | Why it's safe |
|---|---|---|
| **Roblox**, user 1 | Roblox's own uploads:<br>- the classic client sounds of 2009 (`swordslash.wav`, `HalloweenThunder.wav`...)<br>- its UI sets: `RBLX UI ... (SFX)` (2022), `Roblox_UI_*` (2023), `Roblox GUI - *` (2024) | Owned and published by Roblox. |
| **ProSoundEffects**, user 7462895450 | Roblox's licensed sound-effects partner. Its library arrived in the March 2022 audio update, with names like `Sword Hit 1 (SFX)`. | Free for every experience. It is the sound-effects counterpart of the `APMOfficial` music the game already uses in `Config.music`. |
| **Built in** | Files that ship inside the Roblox client today, under `rbxasset://sounds/`. | No download needed, so they can't be taken down. |

**The built-in files, verified.** The current client (version 0.748, per its `rbxManifest.txt`, which MaximumADHD/Roblox-Client-Tracker mirrors) ships exactly 11 files in `content/sounds`:

> action_falling.ogg, action_footsteps_plastic.mp3, action_get_up.mp3, action_jump.mp3, action_jump_land.mp3, action_swim.mp3, impact_explosion_03.mp3, impact_water.mp3, oof.ogg, ouch.ogg, volume_slider.ogg

`swordslash.wav`, `swordlunge.wav`, `electronicpingshort.wav` and `collide.wav` are **not** among them. The game used to name those four (the live city's sirens, the swing sound, every SkillFx move), and in today's client they play silence.

Roblox uploaded the whole 2009 set as assets: each asset's description is its old path, `\sounds\<file>`. So the old paths now map onto those uploads:

| Old file | Roblox upload |
|---|---|
| swordslash.wav | 12222216 |
| swordlunge.wav | 12222208 |
| unsheath.wav | 12222225 |
| electronicpingshort.wav | 12221990 |
| collide.wav | 12221984 |
| … | 21 in all, in `WorldSfx.LEGACY_ID` and `Sfx.LEGACY` |

**What was left out, on purpose:**
- Anything ProSoundEffects files under "Gore - Blood", or whose description mentions wounds or bodies. The two "Sword Stab" clips and "Stab Twice" are examples. Blows land on metal and air instead.
- People screaming in pain, and "death cries".
- Voice lines.
- `Kid saying Ouch.wav`: children are never shown hurt.
- `uuhhh.wav`, the old "oof", which was withdrawn over licensing.
- Community re-uploads of other games' audio. The kit's old `Config.sfx` was mostly Limbus Company rips: `"LIMBUS COMPANY!"`, `"Proelium Fatale!"` and its clash sounds.

**Re-checking.** `python3 tools/sfx/verify_ids.py` checks every id in WorldSfx, UiSounds and `Config.sfx` against the Creator Store. It confirms each one exists, is published audio, and is by Roblox or ProSoundEffects. It also checks that the name written next to each WorldSfx id matches the store's name, that nothing mentions gore, and that every `rbxasset://` path is one the client ships. It exits 1 on any problem. Run it before a release: an upload can be taken down at any time. A missing sound just goes quiet, and nothing errors.

## WorldSfx

```lua
local WorldSfx = require(client.WorldSfx)
WorldSfx.weapon("katana", "swing", character)                         -- swing, hit, equip, crit
WorldSfx.weapon("greataxe", "hit", targetPos, { power = 420, element = "fire" })
WorldSfx.magic("frost", "nova", caster.Position, { tier = 5 })        -- an element and a shape
WorldSfx.monster("spider", "attack", model, { rank = 2 })              -- aggro, attack, hurt, death, step
WorldSfx.monsterOf(model, "death")                                     -- from the model's Kind/Rank/Gait
local hum = WorldSfx.gate("hum", gateCorePart, { rank = 4 })           -- loops hand back a handle
hum:stop(1.5)
WorldSfx.gate("break", pos, { rank = 5 })                              -- open, surge, break, close, red, enter, measure
local siren = WorldSfx.city("siren", policeCar)                        -- siren (loop), sirenBlip, panic, crowd,
WorldSfx.city("panic", pos, { duration = 6 })                          --   radio, beep, brake, door, crystal
WorldSfx.play("magic.fire.impact", pos)                                -- any of the above by name, a sound or cue
WorldSfx.play(9119746598, pos)                                         -- or an asset id
```

**Where a sound plays from (`at`):**
- a **Vector3** puts it at a point in the world;
- a **BasePart** or **Attachment** makes it ride along with that object;
- a **Model** uses its PrimaryPart;
- **nil** makes it heard everywhere, not placed (cutscenes, the title).

**Options (`opts`):**
- `volume`, `pitch`
- `rank`, `tier` or `power`: bigger things sound lower and louder
- `element`: an elemental monster's magic on top, or a weapon hit's elemental layer
- `delay`
- `near` / `far`: rolloff distances
- `duration`: a loop stops itself after this long; a one-shot repeats until it ends (a crowd running past)
- `fadeIn` (loops)

**Variety.** Every sound has two to six recordings and a pitch range. The variant never repeats twice in a row. Volume jitters ±8%. Each call is a cue of one to four layers: a katana swing is a swish plus a thin air layer 40% of the time; a greataxe hit is the hit, a heavy clunk under it and sometimes stone. So a long fight never repeats itself exactly.

**Limits.**
- At most `MAX_VOICES` (40) sounds play at once. When full, a more important sound takes the place of the oldest less important one.
- Each sound plays at most `max` times at once (default 4), and never twice within 30 ms.
- Nothing is made beyond its hearing range.
- Loops let go of their slot when stopped, or when the part they ride on is destroyed.

**Level.** Everything plays through the `BitLevelingWorld` SoundGroup, whose level follows the player's Effects volume (`Sfx.onVolume`).

### Weapons

`WorldSfx.weapon(family, event, at, opts)` handles all 53 families in `Hunter/Weapons`, grouped into 14 kinds of sound:

| Kind | Families | Swing | Hit |
|---|---|---|---|
| blade | sword, katana, odachi, twinswords, dagger(s) | sword swishes (and Roblox's classic slash) | sword hits, knife shing |
| heavy | greatsword, cleaver, scythe, axe(s), greataxe, halberd, glaive | thick quick whooshes | big impacts, a heavy clunk, sometimes stone |
| thrust | spear, trident, lance, rapier, sai | the classic lunge, thin sharp swishes | metallic swoosh-impacts |
| blunt | warhammer, hammer, mace, flail | heavy-punch whooshes, a bat swing | sledgehammer and railroad-hammer hits |
| bow | bow, longbow | the bow's creak, then the arrow going by | arrows landing |
| crossbow | crossbow, arbalest | crossbow shots | bolts landing |
| thrown | javelin, kunai, chakram | swooshes, a spinning metal tube | knife shing |
| chain | whip, chainblade, kusarigama | whip cracks over a chain's rattle | whip and chain hits |
| staff | staff, wand, orb, crystal, tome, codex, tablet | magic whooshes | magic poofs and bursts |
| fan | warfan | vortex wind bursts | wind |
| holy | censer, thurible, bell, rod, scepter, crescent | soft chimes | bell dings |
| fist | gauntlets | heavy-punch whooshes | punch-kit hits |
| claw | claws, katar | a punch whoosh with a blade's edge | blade and fist together |
| shield | shield, buckler, towershield | a low whoosh with armour rattling | shield impacts |

**Unknown families.** A family it doesn't know is sorted by its swing style (`fx`), then its class, then a word in its id ("crossbow", "hammer", "staff"...), and finally treated as a blade.

**Other events:**
- `equip` is the draw.
- `crit` is the family's hit with weight under it.
- `opts.element` on a hit adds that element's impact at 45%.

### Magic

`WorldSfx.magic(element, shape, at, opts)`.

**Elements.** fire, frost, lightning, wind, earth, water, holy, void, venom, arcane and healing. Also sonic (the sound school) and physical (the weapon arts). Aliases include ice, electric, light, shadow, poison, mana, life and sound. An unknown element is treated as arcane.

**Shapes.** charge (cast), projectile, impact, explosion, nova, beam, buff and heal. Every one of SkillFx's 34 shapes maps onto them:
- volley → projectile
- wave, lance, chain → beam
- spikes, strike, pillar, smite → impact
- meteor, implode, eruption → explosion
- shockwave, cone → nova
- aura, haste → buff
- motes, renew, cleanse → heal

A few kinds sound alike whatever the element, with the element's own layer on top:
- rain, field, storm, orbit → zone
- wall, dome, ward → shield
- dash, leap, blink → move
- construct → summon
- plus taunt, curse and slash

A tier of 5 or more on an impact also shakes the air.

### Monsters

`WorldSfx.monster(family, event, at, opts)` takes the events aggro, attack, hurt and death, plus step for giants, golems, dragons and fliers. The families are goblinoid, orc, elf, dwarf, giant, beast, insect, spider, reptile, undead, demon, golem, elemental, slime, flier, dragon, plant, aquatic and default.

Every voice is an animal, a creature or an effect:
- goblin growls and croaks;
- deep growling "goliath" voices for orcs;
- wolves, lions and a polar bear for beasts;
- insect wings and crab-claw clicks;
- spider hisses;
- snake and alligator hisses;
- whispers and ghostly exhales for the undead;
- energy growls for demons;
- stone cracking and grinding for golems;
- tentacle slime;
- pterodactyl screeches and wingbeats;
- Roblox's own thunder-and-lion-roar for dragons;
- creaking wood and leaves for plants;
- whales and water.

Nothing is a person screaming.

`rank` makes it bigger: lower and louder.

**Placing a monster in a family.** The live city's 24 kinds are mapped in `WorldSfx.KIND_FAMILY`. A new kind is placed by the first of these that applies:
1. its own `family` field (Bestiary data);
2. a word in its id or name (wyrm, skeleton, scorpion, treant...; "giant" counts only as a last resort, so a giant spider is a spider);
3. its gait;
4. `default`.

### Gates and the city

**Gate events:**

| Event | What it plays |
|---|---|
| `hum` (loop) | a deep pulsing magic drone |
| `open` | a time-warp build-up and suck, a reverse whoosh, a low sonic boom |
| `surge` | a boomy synth whomp and wind |
| `break` | an earthquake explosion, a space-blast tail, glass |
| `close` | a reverse suck and a power-down |
| `red` | a sci-fi alarm and a void boom |
| `redDrone` (loop) | a fast pulsing sub drone |
| `enter` | a reversed hiss and a transformation shimmer |
| `measure` | scanner beeps |

**City events:**

| Event | What it plays |
|---|---|
| `siren` (loop) | siren wails |
| `sirenBlip` | a blat |
| `panic` | people running past, yelling |
| `crowd` | a shouting crowd |
| `radio` | walkie-talkie squelches, no voices |
| `beep` | a short beep |
| `brake` | tyres chirping to a stop |
| `door` | a van door |
| `crystal` | a mana crystal's glint |

### Short names

The opening and the title call these: `nightWind`, `lightning`, `thunder`, `meteor`, `meteorImpact`, `debris`, `rumble`, `vanArrive`, `march`, `vanish`, `blink`, `whoosh`, `tunnel`, `taunt` and `titleSlam`.

## Wired in

**`client/WeaponFx`**
- `swing` plays the family's swing, by style.
- `hit` plays the element's impact (plus the family's blow when `opts.family` is given).
- `equip` plays the draw (with a ding for a Shiny weapon).
- `opts.sound = false` silences any of them.

**`client/HunterLive`.** The `sound(id, at, volume, pitch, opts)` helper takes a WorldSfx name or an asset id. The old `rbxasset://sounds/*.wav` constants SkillFx passes play the bank's sound for what they were used for, so every SkillFx move already makes a real sound. In `onFx`:

| fx | What plays |
|---|---|
| `swing` | the family's hit on every target; the swing too when WeaponFx didn't draw it |
| `slash` (an NPC Hunter's blow) | a sword's swing and hit, and the monster's hurt |
| `hit` (a monster's blow) | the monster's attack voice where it stands, and the blow where it lands |
| `kill` | the monster's death, and a mana crystal's glint |
| `enter` | `gate.enter` |
| `gateOpen` | `gate.open`, then the Gate's `hum` loop |
| `redGate` | `gate.red`; the hum gives way to the red drone |
| `break` | `gate.break`, then people running |
| `siren` | a blat and a radio squelch as the police arrive |

The Gate's siren is a real looped wail riding on the Gate. The siren handle takes the old PlaybackSpeed wobble as a gentle doppler, and `:Destroy()` stops it.

## For the integrator: calls the other streams' files should make

These are files this stream doesn't own. Each change is a few lines, and each one is safe if WorldSfx is missing.

### SkillFx: the move's own element and shape

SkillFx already calls `ctx.sound(id, at, volume, pitch)`, the HunterLive helper, which takes WorldSfx names. Add one line at the end of each of the three entry points.

```lua
-- in SkillFx.play(d), after `local ok, err = pcall(draw, d, info(d))`:
if ok and not (ab and ab.fx and E[ab.fx]) then -- (hand-made effects call their own sounds)
	local I = info(d)
	local shape = I.def.shape or d.shape or "cast"
	ctx.sound("magic." .. tostring(d.element or I.def.element or "arcane") .. "." .. shape,
		if shape == "projectile" or shape == "volley" or shape == "lance" or shape == "wave" then I.at else I.to,
		1, nil, { tier = I.tier })
end

-- in SkillFx.cast(d), inside its pcall after `local I = info(d)`: the gathering
ctx.sound("magic." .. tostring(d.element or I.def.element or "arcane") .. ".charge", I.at, 0.8, nil, { tier = I.tier })

-- in SkillFx.tick(d), where a storm's bolts land (in place of sound(THUD, I.at, 0.5, 1.2)):
ctx.sound("magic." .. tostring(I.def.element or "lightning") .. ".impact", I.targets[1] or I.at, 0.6, nil, { tier = I.tier })
```

Inside the hand-made effects, the four old constants can become element-aware names. Use `I.def.element` for `<el>`:

| Old constant | Use instead |
|---|---|
| `PING` (a cast) | `"magic.<el>.cast"` |
| `SLASH` | `"weapon.sword.swing"`, or `"magic.<el>.slash"` for an element-edged cut |
| `LUNGE` | `"magic.<el>.projectile"` (a dash: `"magic.<el>.move"`) |
| `THUD` | `"magic.<el>.impact"` (a big one: `"magic.<el>.explosion"`) |

Until then the old constants are mapped:

| Old constant | Plays |
|---|---|
| SLASH | `blade.swish` |
| LUNGE | `thrust.swish` |
| PING | `arcane.burst` |
| THUD | `earth.crack` |

The full grid: elements fire, frost, lightning, wind, earth, water, holy, void, venom, arcane (mana), healing (life), sonic (sound), physical. Shapes charge, cast, projectile, impact, explosion, nova, beam, buff, heal, and every SkillFx shape name. `tests/sfx_check` resolves every pair.

### MonsterAnim: aggro, attack, hurt, death per family

Every live monster model carries `Kind`, `Rank` and `Gait`, so `WorldSfx.monsterOf(model, event)` finds the family itself.

```lua
-- at the top of client/MonsterAnim.luau
local okW, WorldSfx = pcall(function()
	return require(script.Parent:WaitForChild("WorldSfx", 5))
end)
if not okW then
	WorldSfx = nil
end

-- in watchAttacks(model, r): an attack
model:GetAttributeChangedSignal("Attacking"):Connect(function()
	r.lastAttack = os.clock()
	if WorldSfx then
		WorldSfx.monsterOf(model, "attack")
	end
end)

-- in MonsterAnim.start, when a monster is first tracked (r just rigged): it notices you
if r and WorldSfx and math.random() < 0.6 then
	WorldSfx.monsterOf(model, "aggro")
end

-- the server's fx carry the rest: in client/HunterLive's onFx, "kill" plays the death and the
-- slash plays the hurt (once the server sends `kind`: below). Heavy walkers' steps, every few frames
-- of the gait's footfall (giants, golems, dragons, wyverns: rank 4 and up):
if WorldSfx and r.footfall then
	WorldSfx.monsterOf(model, "step", { volume = 0.6 })
end
```

### Server: say which monster it was

In `server/HunterLive/init.luau`, add `kind = m.kind` to the monster's fx so the client can pick its family. Until then the client falls back to a generic creature by rank.

```lua
fx("hit", { from = ..., to = ..., rank = m.rank, player = victim.UserId, kind = m.kind })   -- (all three "hit" calls)
fx("kill", { at = ..., rank = m.rank, kind = m.kind })
fx("slash", { from = ..., to = ..., rank = best.rank, kind = best.kind })                  -- (the monster hit)
```

### HunterLive: a Gate's hum from the start, and its close

`onFx` starts the hum on `gateOpen`, but a client that joins late builds Gates from the snapshot.

```lua
-- in buildGate(snap), after `local g = { ... }`:
g.hum = WorldSfx and WorldSfx.gate(if snap.red then "redDrone" else "hum", core, { rank = snap.rank, fadeIn = 2 })

-- in closeGate(g), before g.vfx:close(1.5):
if g.hum then g.hum:stop(1) end
if g.redHum then g.redHum:stop(1) end
if WorldSfx then WorldSfx.gate("close", g.center.Position, { rank = g.rank }) end
```

(Both `WorldSfx` and the helper are locals defined just above `onFx`. Move the `okWorldSfx` require to the top of the file when making these changes.)

## Tests

```
lune run tests/sfx_check             # UI buttons, every WorldSfx category, plays, ids, failures, the mix, loops,
                                     # then tests/cutscene_check and tests/title_check as their own runs
lune run tests/sfx_check -- quick    # without those two
python3 tools/sfx/verify_ids.py      # every id against the Creator Store (network)
python3 tools/sfx/verify_ids.py --table
```

`sfx_check` runs on real Roblox instance types with a fake clock. Lune can't play audio, so `Sound:Play` is recorded instead.

**What can't be checked here** is how the sounds actually sound. Volumes and pitch ranges were set from each recording's description and length. They should be listened to in Studio and tuned in WorldSfx's `S(...)` entries, where `vol` and `pitch` are per sound, or in a cue's layers.

## Every sound in WorldSfx's bank

Generated from the bank and the Creator Store (name, creator and length in seconds, as the store reports them). Each id is also written in a comment next to its use in `src/client/WorldSfx.luau`.

| sound | id | Creator Store name | creator | s |
|---|---|---|---|---|
| `blade.swish` | 9119749145 | Sword Swish 102 (SFX) | ProSoundEffects | 1 |
| `blade.swish` | 9119749263 | Sword Swish 5 (SFX) | ProSoundEffects | 1 |
| `blade.swish` | 9119749931 | Sword Swishes 2 (SFX) | ProSoundEffects | 1 |
| `blade.swish` | 9119750447 | Sword Swishes 9 (SFX) | ProSoundEffects | 0 |
| `blade.swish` | 9126013644 | Swish Med High End Sharp Swords Fast Punches (SFX) | ProSoundEffects | 0 |
| `blade.swish` | 12222216 | swordslash.wav | Roblox | 1 |
| `heavy.whoosh` | 9120742729 | Whoosh Thick Quick Multiple Variations 1 (SFX) | ProSoundEffects | 1 |
| `heavy.whoosh` | 9120742716 | Whoosh Thick Quick Multiple Variations 2 (SFX) | ProSoundEffects | 1 |
| `heavy.whoosh` | 9120742710 | Whoosh Thick Quick Multiple Variations 3 (SFX) | ProSoundEffects | 0 |
| `heavy.whoosh` | 9126229927 | Whoosh By Fast Airy Swooshing Whipping Thuds (SFX) | ProSoundEffects | 1 |
| `thrust.swish` | 12222208 | swordlunge.wav | Roblox | 1 |
| `thrust.swish` | 9119699577 | Swish High End Thin Sharp Thick 1 (SFX) | ProSoundEffects | 1 |
| `thrust.swish` | 9119691969 | Swish Brass Rod Airy Sharp Sword 8 (SFX) | ProSoundEffects | 1 |
| `blunt.whoosh` | 9120728815 | Whoosh Heavy Punches 1 (SFX) | ProSoundEffects | 1 |
| `blunt.whoosh` | 9120728883 | Whoosh Heavy Punches 2 (SFX) | ProSoundEffects | 1 |
| `blunt.whoosh` | 9113305619 | Baseball Bat Swing 5 (SFX) | ProSoundEffects | 1 |
| `fist.whoosh` | 9120729007 | Whoosh Heavy Punches 3 (SFX) | ProSoundEffects | 1 |
| `fist.whoosh` | 9120729005 | Whoosh Heavy Punches 4 (SFX) | ProSoundEffects | 1 |
| `fist.whoosh` | 9120729339 | Whoosh Heavy Punches 7 (SFX) | ProSoundEffects | 1 |
| `fist.whoosh` | 9120729412 | Whoosh Heavy Punches 8 (SFX) | ProSoundEffects | 1 |
| `bow.draw` | 9125407239 | Bow Stretches Wood Creaking Ripping Tearing  (SFX) | ProSoundEffects | 1 |
| `bow.release` | 9113167619 | Arrow Pass Bys 12 (SFX) | ProSoundEffects | 1 |
| `bow.release` | 9113166993 | Arrow Pass Bys 1 (SFX) | ProSoundEffects | 1 |
| `bow.release` | 9113167197 | Arrow Pass Bys 6 (SFX) | ProSoundEffects | 1 |
| `crossbow.fire` | 9114001369 | Crossbow Fire 12 (SFX) | ProSoundEffects | 1 |
| `crossbow.fire` | 9114002577 | Crossbow Fire 3 (SFX) | ProSoundEffects | 1 |
| `crossbow.fire` | 9114001362 | Crossbow Fire 14 (SFX) | ProSoundEffects | 1 |
| `thrown.whoosh` | 12222200 | swoosh.wav | Roblox | 0 |
| `thrown.whoosh` | 9116904947 | Metal Tube Swishes Single And Multiple 16 (SFX) | ProSoundEffects | 0 |
| `thrown.whoosh` | 9113166206 | Arrow Out Whooshing Pass By 1 (SFX) | ProSoundEffects | 3 |
| `whip.crack` | 9113612888 | Buggy Whip Quick Swish Crack 11 (SFX) | ProSoundEffects | 0 |
| `whip.crack` | 9113611449 | Buggy Whip Light Crack Swish Many Versions 6 (SFX) | ProSoundEffects | 1 |
| `whip.crack` | 9120669139 | Whip Swish 2 (SFX) | ProSoundEffects | 2 |
| `chain.rattle` | 9113760085 | Chain Movement 1 (SFX) | ProSoundEffects | 1 |
| `chain.rattle` | 9113760230 | Chain Movement 2 (SFX) | ProSoundEffects | 2 |
| `spell.whoosh` | 9116402961 | Magic Movement Airy Whips Swooshes 67 (SFX) | ProSoundEffects | 1 |
| `spell.whoosh` | 9125647922 | Magic Zoom Up Sharp Tubular Whoosh Fast Hiss (SFX) | ProSoundEffects | 1 |
| `spell.whoosh` | 9125648149 | Magic Zoom Up Sharp Tubular Whoosh Fast Hiss (SFX) | ProSoundEffects | 1 |
| `bell.chime` | 9116394545 | Magic Glows Soft Clusters Of Chiming Hits 1 (SFX) | ProSoundEffects | 1 |
| `bell.chime` | 9116394876 | Magic Glows Soft Clusters Of Chiming Hits 2 (SFX) | ProSoundEffects | 2 |
| `armor.rattle` | 9113156159 | Armor Metal 1 (SFX) | ProSoundEffects | 1 |
| `blade.draw` | 9119742466 | Sword Draw Clang Unsheathing Two Sabers 1 (SFX) | ProSoundEffects | 1 |
| `blade.draw` | 12222225 | unsheath.wav | Roblox | 1 |
| `equip.gear` | 17208323435 | Roblox GUI - Equip | Roblox | 1 |
| `blade.hit` | 9119746598 | Sword Hit 1 (SFX) | ProSoundEffects | 1 |
| `blade.hit` | 9119746592 | Sword Hit 2 (SFX) | ProSoundEffects | 1 |
| `blade.hit` | 9119746751 | Sword Hit 4 (SFX) | ProSoundEffects | 1 |
| `blade.hit` | 9119747120 | Sword Impact 102 (SFX) | ProSoundEffects | 1 |
| `blade.hit` | 9116196826 | Knife Shing 101 (SFX) | ProSoundEffects | 0 |
| `heavy.hit` | 9119747138 | Sword Impact 202 (SFX) | ProSoundEffects | 1 |
| `heavy.hit` | 9113225986 | Axe Impact Giant Thuddy Hits On Wood Floor 5 (SFX) | ProSoundEffects | 1 |
| `heavy.hit` | 9116673678 | Metal Impact Heavy Clunking Hits Scraping 1 (SFX) | ProSoundEffects | 1 |
| `thrust.hit` | 9119707097 | Swish Suck Reversed Metallic Swoosh Impact 1 (SFX) | ProSoundEffects | 1 |
| `thrust.hit` | 9119707271 | Swish Suck Reversed Metallic Swoosh Impact 2 (SFX) | ProSoundEffects | 1 |
| `thrust.hit` | 9113449585 | Blade Hits Metal Rod On Knife Impacts 10 (SFX) | ProSoundEffects | 1 |
| `blunt.hit` | 9125672726 | Metal Impact Sledge Hammer Hits On 5 Ft I- B (SFX) | ProSoundEffects | 1 |
| `blunt.hit` | 9116675967 | Metal Impact Railroad Hammer 1 (SFX) | ProSoundEffects | 1 |
| `blunt.hit` | 9117969687 | Punch Kit Beefy Hit 2 (SFX) | ProSoundEffects | 1 |
| `blunt.hit` | 12221984 | collide.wav | Roblox | 1 |
| `arrow.hit` | 9113162981 | Arrow In And Hit 6 (SFX) | ProSoundEffects | 1 |
| `arrow.hit` | 9113161406 | Arrow In And Hit 13 (SFX) | ProSoundEffects | 1 |
| `arrow.hit` | 9113161857 | Arrow In And Hit 19 (SFX) | ProSoundEffects | 1 |
| `bolt.hit` | 9113998001 | Crossbow Bolts Impact 3 (SFX) | ProSoundEffects | 1 |
| `bolt.hit` | 9113999645 | Crossbow Bolts Impact 38 (SFX) | ProSoundEffects | 1 |
| `bolt.hit` | 9113999366 | Crossbow Bolts Impact 30 (SFX) | ProSoundEffects | 0 |
| `knife.hit` | 9116197039 | Knife Shing 4 (SFX) | ProSoundEffects | 0 |
| `knife.hit` | 9116197041 | Knife Shing 3 (SFX) | ProSoundEffects | 0 |
| `whip.hit` | 9120200619 | Towel Cracks Low Intensity Whipping Hits 2 (SFX) | ProSoundEffects | 1 |
| `whip.hit` | 9113764229 | Chains And Metal Impacts 2 (SFX) | ProSoundEffects | 2 |
| `whip.hit` | 9113764330 | Chains And Metal Impacts 4 (SFX) | ProSoundEffects | 2 |
| `spell.hit` | 9116405618 | Magic Poofs Short Breathy Bursts Punchy 2 (SFX) | ProSoundEffects | 1 |
| `spell.hit` | 9116385087 | Magic Burst 5 (SFX) | ProSoundEffects | 2 |
| `bell.hit` | 9126073001 | Synth Sparkle Tone High Pitch Bell Tone Ding (SFX) | ProSoundEffects | 1 |
| `fist.hit` | 9117969717 | Punch Kit Beefy Hit 3 (SFX) | ProSoundEffects | 1 |
| `fist.hit` | 9117969878 | Punch Kit Beefy Hit 4 (SFX) | ProSoundEffects | 1 |
| `fist.hit` | 9117969420 | Punching Bag Hits 22 (SFX) | ProSoundEffects | 1 |
| `shield.hit` | 9119074309 | Shield Impacts 2 (SFX) | ProSoundEffects | 2 |
| `shield.hit` | 9119072660 | Shield Clang As Hit Metal Sword Hubcap 1 (SFX) | ProSoundEffects | 1 |
| `shield.hit` | 9119073323 | Shield Impacts 9 (SFX) | ProSoundEffects | 0 |
| `shield.hit` | 9119075967 | Shield Impacts 19 (SFX) | ProSoundEffects | 2 |
| `fire.whoosh` | 9114439868 | Fire Whoosh 11 (SFX) | ProSoundEffects | 1 |
| `fire.whoosh` | 9114442751 | Fire Whoosh 2 (SFX) | ProSoundEffects | 1 |
| `fire.ball` | 9114428740 | Fireball Pass By 1 (SFX) | ProSoundEffects | 4 |
| `fire.ball` | 9114428748 | Fireball Burning Whoosh By 2 (SFX) | ProSoundEffects | 5 |
| `fire.burst` | 9117983605 | Pyro Fire Ball Burst 9 (SFX) | ProSoundEffects | 1 |
| `fire.burst` | 9117987278 | Pyro Fire Ball Burst 12 (SFX) | ProSoundEffects | 1 |
| `fire.explode` | 9117982781 | Pyro Explosion 3 (SFX) | ProSoundEffects | 1 |
| `fire.explode` | 9117982785 | Pyro Explosion 4 (SFX) | ProSoundEffects | 1 |
| `fire.explode` | 3149249837 | Cannon_Explode | Roblox | 4 |
| `fire.explode` | 9114554567 | Gas Fire Explosion 3 (SFX) | ProSoundEffects | 4 |
| `fire.sizzle` | 9119165650 | Sizzle Short And Explosive Sear 4 (SFX) | ProSoundEffects | 1 |
| `frost.crackle` | 9114858583 | Ice Crackle Large Block Cracks 1 (SFX) | ProSoundEffects | 4 |
| `frost.chill` | 9125632802 | Lung Wind Whoosh Breathy Blasts Arctic Chill (SFX) | ProSoundEffects | 6 |
| `frost.shatter` | 9114855626 | Ice Block Drop To Concrete Shatter 1 (SFX) | ProSoundEffects | 1 |
| `frost.shatter` | 9114856749 | Ice Block Drop To Concrete Shatter 9 (SFX) | ProSoundEffects | 1 |
| `frost.shatter` | 9114855643 | Ice Block Drop To Concrete Shatter 2 (SFX) | ProSoundEffects | 2 |
| `frost.shatter` | 12222005 | glassbreak.wav | Roblox | 2 |
| `frost.cracks` | 9114858761 | Ice Cracks 2 (SFX) | ProSoundEffects | 6 |
| `volt.static` | 9114246318 | Electricity Static 1 (SFX) | ProSoundEffects | 3 |
| `volt.zap` | 9114277757 | Electric Zaps 12 (SFX) | ProSoundEffects | 1 |
| `volt.zap` | 9114277338 | Electric Zaps 4 (SFX) | ProSoundEffects | 2 |
| `volt.whoosh` | 9114276859 | Electric Whoosh Bys In Groups Buzzy 9 (SFX) | ProSoundEffects | 1 |
| `volt.burst` | 9116275992 | Lightning Flashes Quick Electrical Bursts 12 (SFX) | ProSoundEffects | 1 |
| `volt.burst` | 9116275998 | Lightning Flashes Quick Electrical Bursts 13 (SFX) | ProSoundEffects | 1 |
| `volt.burst` | 9113150065 | Arc Zaps Phasey Short Bursts Ringing Blast 1 (SFX) | ProSoundEffects | 2 |
| `volt.arc` | 9114237705 | Electric Arcing 6 (SFX) | ProSoundEffects | 2 |
| `volt.crack` | 9126067628 | Synth Lightning Crack Sharp Some Rolling Tai (SFX) | ProSoundEffects | 2 |
| `thunder` | 12222030 | HalloweenThunder.wav | Roblox | 4 |
| `thunder` | 12222019 | HalloweenLightning.wav | Roblox | 5 |
| `thunder` | 9120016738 | Thunder Distant Boom Thud Rapid Hits 2 (SFX) | ProSoundEffects | 4 |
| `thunder` | 9120016256 | Thunder Cracks Big Rumbling Blasts Booming 3 (SFX) | ProSoundEffects | 7 |
| `wind.suck` | 9126236071 | Wind Suck Slow Backwards Swooshing Build Up  (SFX) | ProSoundEffects | 4 |
| `wind.burst` | 9120749129 | Wind Burst Alien Vortex Blasts 1 (SFX) | ProSoundEffects | 1 |
| `wind.burst` | 9120748924 | Wind Burst Alien Vortex Blasts 2 (SFX) | ProSoundEffects | 2 |
| `wind.burst` | 9120749306 | Wind Burst Alien Vortex Blasts 7 (SFX) | ProSoundEffects | 2 |
| `wind.burst` | 9126229273 | Whoosh By Fast Airy Swooshing Whipping Thuds (SFX) | ProSoundEffects | 1 |
| `wind.big` | 9120749149 | Wind Burst Alien Vortex Blasts 4 (SFX) | ProSoundEffects | 3 |
| `wind.big` | 9120769331 | Wind Whoosh Sonic Boom Low End Impact 1 (SFX) | ProSoundEffects | 6 |
| `earth.rumble` | 9114032606 | Debris Movement 5 (SFX) | ProSoundEffects | 3 |
| `earth.scrape` | 9118617342 | Rock Impact Large Hit Scrape 1 (SFX) | ProSoundEffects | 1 |
| `earth.crack` | 9125869504 | Rock Cracks Rock Hitting Rock Impact Debris  (SFX) | ProSoundEffects | 1 |
| `earth.crack` | 9118587493 | Rock Drop On Concrete Drops Breaks 1 (SFX) | ProSoundEffects | 1 |
| `earth.crack` | 9118587494 | Rock Drop On Concrete Drops Breaks 2 (SFX) | ProSoundEffects | 1 |
| `earth.burst` | 9114221862 | Earthquake Debris Rock Bursts Scattering 1 (SFX) | ProSoundEffects | 5 |
| `earth.burst` | 9114086455 | Dirt Explosion 3 (SFX) | ProSoundEffects | 3 |
| `earth.quake` | 9114224432 | Earthquake Explosion 3 (SFX) | ProSoundEffects | 6 |
| `water.bubble` | 9113604979 | Bubble Whooshes Liquid Pass By 1 (SFX) | ProSoundEffects | 1 |
| `water.burst` | 9120502958 | Water Burst Boom Blast Hissing Spray 1 (SFX) | ProSoundEffects | 3 |
| `water.splash` | 9117822998 | Pool Jumps Splashes Water Impact Swimming 3 (SFX) | ProSoundEffects | 2 |
| `water.splash` | 9125703162 | Mud Puddle Splash Shallow Water Impacts Hits (SFX) | ProSoundEffects | 1 |
| `water.splash` | `rbxasset://sounds/impact_water.mp3` | impact_water.mp3 | built into the client | |
| `water.boom` | 9120503525 | Water Burst Boom Blast Some Whirring Hum 1 (SFX) | ProSoundEffects | 4 |
| `water.flow` | 9120674127 | Whirlpool Flowing 1 (SFX) | ProSoundEffects | 4 |
| `holy.rise` | 9125626856 | Light Cone Suck Synth And Reverse Cymbal Bui (SFX) | ProSoundEffects | 3 |
| `holy.chime` | 9116394756 | Magic Glows Soft Clusters Of Chiming Hits 3 (SFX) | ProSoundEffects | 3 |
| `holy.chime` | 9119447936 | Sparkle Bell Tree Wind Chimes 1 (SFX) | ProSoundEffects | 5 |
| `holy.ding` | 9126073011 | Synth Sparkle Tone High Pitch Bell Tone Ding (SFX) | ProSoundEffects | 3 |
| `holy.ding` | 9126072027 | Synth Sparkle Tone High Pitch Bell Tone Burs (SFX) | ProSoundEffects | 1 |
| `holy.swell` | 9125544480 | Energy Blast Big Deep Horn Swell Reverberant (SFX) | ProSoundEffects | 7 |
| `holy.choir` | 9113123536 | Angel Wails 5 (SFX) | ProSoundEffects | 6 |
| `void.suck` | 9118159096 | Reverse Suck 2 (SFX) | ProSoundEffects | 1 |
| `void.suck` | 9118808396 | Sci Fi Reverse Suck Close 3 (SFX) | ProSoundEffects | 1 |
| `void.reverse` | 9118158081 | Reversed Whoosh Backwards Hissing Burst 1 (SFX) | ProSoundEffects | 1 |
| `void.reverse` | 9118158113 | Reversed Whoosh Backwards Hissing Burst 2 (SFX) | ProSoundEffects | 1 |
| `void.boom` | 9120057087 | Time Warp Searing Build Up Boomy Explosion 5 (SFX) | ProSoundEffects | 2 |
| `void.boom` | 9120057111 | Time Warp Searing Build Up Boomy Explosion 4 (SFX) | ProSoundEffects | 2 |
| `void.blast` | 9126050066 | Synth Blast Space Explosion Reverberant Tail (SFX) | ProSoundEffects | 5 |
| `void.blast` | 9126102254 | Time Warp Big Explosion Blast Boom Tonal Tai (SFX) | ProSoundEffects | 6 |
| `void.whisper` | 9114228524 | Eerie Whispering Eerie Reverberant Demon 2 (SFX) | ProSoundEffects | 2 |
| `venom.bubble` | 9112872239 | Small Bubbles Water Surface Float Up Pop 5 (SFX) | ProSoundEffects | 1 |
| `venom.spray` | 9119991930 | Termite Sprays Acid Hissing Bursts 2 (SFX) | ProSoundEffects | 2 |
| `venom.spray` | 9119991802 | Termite Sprays Acid Hissing Bursts 3 (SFX) | ProSoundEffects | 2 |
| `venom.squish` | 9126209045 | Wet Newspaper Squish Sloshy Impact Suction 1 (SFX) | ProSoundEffects | 1 |
| `venom.squish` | 9116319322 | Liquid Squish 2 (SFX) | ProSoundEffects | 4 |
| `venom.squish` | 9120583506 | Water Slushing Slightly Goopy Squish 1 (SFX) | ProSoundEffects | 3 |
| `arcane.rise` | 9117297453 | Phasey Synth Power Up High Pitched Rise 2 (SFX) | ProSoundEffects | 3 |
| `arcane.burst` | 9116384485 | Magic Burst 1 (SFX) | ProSoundEffects | 3 |
| `arcane.burst` | 9116384473 | Magic Burst 2 (SFX) | ProSoundEffects | 3 |
| `arcane.burst` | 9116385087 | Magic Burst 5 (SFX) | ProSoundEffects | 2 |
| `arcane.shimmer` | 9125646918 | Magic Whooshes Pass Bys Metallic Shimmering  (SFX) | ProSoundEffects | 2 |
| `arcane.morph` | 9116421550 | Magic Transformation 6 (SFX) | ProSoundEffects | 1 |
| `arcane.beam` | 9114340693 | Energy Pass By Sci Fi Tonal Whooshes 1 (SFX) | ProSoundEffects | 3 |
| `arcane.blast` | 9114314399 | Energy Blasts 4 (SFX) | ProSoundEffects | 4 |
| `heal.sparkle` | 9125635426 | Magical Exit Sparkling Pass Bys Clinking Chi (SFX) | ProSoundEffects | 4 |
| `heal.fall` | 9116418035 | Magic Tone Falling Shimmer Flanged 3 (SFX) | ProSoundEffects | 3 |
| `heal.aura` | 17208327798 | Roblox GUI - Aura | Roblox | 2 |
| `buff.up` | 9117887138 | Power Up Sweeteners 3 (SFX) | ProSoundEffects | 2 |
| `buff.up` | 9117886660 | Power Up Sweeteners 16 (SFX) | ProSoundEffects | 1 |
| `move.whoosh` | 9126229488 | Whoosh By Fast Airy Swooshing Whipping Thuds (SFX) | ProSoundEffects | 1 |
| `move.whoosh` | 9116402961 | Magic Movement Airy Whips Swooshes 67 (SFX) | ProSoundEffects | 1 |
| `air.pound` | 9125577419 | Giant Air Blast Low Bursts Pound Many Versio (SFX) | ProSoundEffects | 2 |
| `magic.poof` | 9116406610 | Magic Poofs Thumpy Wheezy Exhale 1 (SFX) | ProSoundEffects | 1 |
| `magic.poof` | 9116405713 | Magic Poofs Short Breathy Bursts Punchy 2 (SFX) | ProSoundEffects | 1 |
| `goblin.growl` | 9114624345 | Goblin Growl 1 (SFX) | ProSoundEffects | 2 |
| `goblin.growl` | 9114624343 | Goblin Growl 2 (SFX) | ProSoundEffects | 3 |
| `goblin.stutter` | 9114625192 | Goblin Stutter 2 (SFX) | ProSoundEffects | 1 |
| `goblin.stutter` | 9114624510 | Goblin Growl 4 (SFX) | ProSoundEffects | 2 |
| `goblin.hurt` | 9114625189 | Goblin Stutter 3 (SFX) | ProSoundEffects | 2 |
| `goblin.croak` | 9114624129 | Goblin Croak 5 (SFX) | ProSoundEffects | 4 |
| `orc.growl` | 9114628321 | Goliath Vocal Deep Growling Voice 17 (SFX) | ProSoundEffects | 2 |
| `orc.growl` | 9114628620 | Goliath Vocal Deep Growling Voice 21 (SFX) | ProSoundEffects | 2 |
| `orc.attack` | 9114628357 | Goliath Vocal Deep Growling Voice 18 (SFX) | ProSoundEffects | 1 |
| `orc.attack` | 9114628818 | Goliath Vocal Deep Growling Voice 22 (SFX) | ProSoundEffects | 2 |
| `orc.groan` | 9113636490 | Bull Monster Groan 1 (SFX) | ProSoundEffects | 1 |
| `orc.groan` | 9113636681 | Bull Monster Groan 3 (SFX) | ProSoundEffects | 1 |
| `orc.groan` | 9113636491 | Bull Monster Groan 2 (SFX) | ProSoundEffects | 1 |
| `humanoid.hiss` | 9116430990 | Magic Vocal Hiss Sharp Swooshing Pass By 2 (SFX) | ProSoundEffects | 2 |
| `humanoid.grunt` | 9116451392 | Male Grunts Two Men Fighting With Spear 2 (SFX) | ProSoundEffects | 1 |
| `humanoid.grunt` | 9116451917 | Male Grunts Two Men Fighting With Spear 6 (SFX) | ProSoundEffects | 1 |
| `humanoid.grunt` | 9116451911 | Male Grunts Two Men Fighting With Spear 7 (SFX) | ProSoundEffects | 1 |
| `humanoid.grunt` | 9116451377 | Male Grunts Two Men Fighting With Spear 1 (SFX) | ProSoundEffects | 3 |
| `humanoid.hurt` | 9116451739 | Male Grunts Two Men Fighting With Spear 3 (SFX) | ProSoundEffects | 1 |
| `ghost.exhale` | 9114572768 | Ghostly Exhale Breathy Slow Cu 1 (SFX) | ProSoundEffects | 3 |
| `ghost.exhale` | 9114573102 | Ghostly Exhale Long Breathy Slow Cu 2 (SFX) | ProSoundEffects | 6 |
| `giant.voice` | 9114630281 | Goliath Vocal Deep Growling Voice 46 (SFX) | ProSoundEffects | 2 |
| `giant.step` | 9114080709 | Dinosaur Footsteps Boomy Thumps 16 (SFX) | ProSoundEffects | 2 |
| `beast.growl` | 9120788137 | Wolf Growl 3 (SFX) | ProSoundEffects | 2 |
| `beast.growl` | 9116311527 | Lion Snarl 3 (SFX) | ProSoundEffects | 1 |
| `beast.attack` | 9120790555 | Wolf Snarl 1 (SFX) | ProSoundEffects | 2 |
| `beast.attack` | 9116302323 | Lion Roar Short Blast Attack Angry Sharp 2 (SFX) | ProSoundEffects | 1 |
| `beast.attack` | 9117733732 | Polar Bear 1 (SFX) | ProSoundEffects | 2 |
| `beast.hurt` | 9116304872 | Lion Roar Tired 12 (SFX) | ProSoundEffects | 1 |
| `beast.die` | 9116306682 | Lion Roar Tired 33 (SFX) | ProSoundEffects | 1 |
| `insect.buzz` | 9113974108 | Creature Mix Big Flying Insects 1 (SFX) | ProSoundEffects | 1 |
| `insect.munch` | 9113986695 | Creatures Munch Army Of Crablike Insects 7 (SFX) | ProSoundEffects | 1 |
| `insect.click` | 9113957586 | Crab Claw Repetitive Clicks 8 (SFX) | ProSoundEffects | 0 |
| `insect.hurt` | 9113977066 | Creature Mix Big Flying Insects 35 (SFX) | ProSoundEffects | 0 |
| `spider.hiss` | 9113989919 | Creature Vocal Spider Hiss Exhale 1 (SFX) | ProSoundEffects | 1 |
| `spider.attack` | 9125471800 | Creature Mix Big Spider Attack Vocal Footste (SFX) | ProSoundEffects | 1 |
| `spider.attack` | 9113991185 | Creature Vocal Spider Hiss Squawk 4 (SFX) | ProSoundEffects | 1 |
| `spider.hurt` | 9113991277 | Creature Vocal Spider Hiss Squawk 7 (SFX) | ProSoundEffects | 1 |
| `spider.screech` | 9125478014 | Creature Vocal Spider Screech Low To Midrang (SFX) | ProSoundEffects | 2 |
| `reptile.hiss` | 9120049675 | Tiger Snake- Like Hisses 3 (SFX) | ProSoundEffects | 2 |
| `reptile.hiss` | 9114808824 | Hissing Alligator 1 (SFX) | ProSoundEffects | 4 |
| `reptile.attack` | 9119300025 | Snake Attack Vocal 7 (SFX) | ProSoundEffects | 1 |
| `reptile.attack` | 9119299847 | Snake Attack Vocal 4 (SFX) | ProSoundEffects | 1 |
| `reptile.hurt` | 9114854828 | Hydra Wet Throaty Hissing 1 (SFX) | ProSoundEffects | 3 |
| `reptile.die` | 9119302136 | Snake Growl 2 (SFX) | ProSoundEffects | 3 |
| `undead.whisper` | 9126213984 | Whisper Bursts Unintelligible Eerie Evil Gho (SFX) | ProSoundEffects | 2 |
| `undead.whisper` | 9114228524 | Eerie Whispering Eerie Reverberant Demon 2 (SFX) | ProSoundEffects | 2 |
| `undead.attack` | 9116430994 | Magic Vocal Hiss Sharp Swooshing Pass By 3 (SFX) | ProSoundEffects | 2 |
| `undead.wail` | 9114463908 | Flangy Synth Scream Otherworldly Wail Cry 3 (SFX) | ProSoundEffects | 2 |
| `demon.growl` | 9114315023 | Energy Burst Growl 1 (SFX) | ProSoundEffects | 2 |
| `demon.growl` | 9114315051 | Energy Burst Growl 2 (SFX) | ProSoundEffects | 2 |
| `demon.growl` | 9114315137 | Energy Burst Growl 3 (SFX) | ProSoundEffects | 2 |
| `demon.blast` | 9114046660 | Demon Vehicle Whooshy Metallic Blast 3 (SFX) | ProSoundEffects | 2 |
| `demon.voice` | 9118567832 | Robot Voice Nasty Growly 9 (SFX) | ProSoundEffects | 1 |
| `demon.die` | 9114039650 | Demon Screams Reversed Hollow Voice Suck 7 (SFX) | ProSoundEffects | 4 |
| `golem.roar` | 9119820079 | Synth Roar Growly Ascend Short Bursts 3 (SFX) | ProSoundEffects | 1 |
| `golem.grind` | 9114561298 | Gear Grind 2 (SFX) | ProSoundEffects | 2 |
| `golem.smash` | 9118617342 | Rock Impact Large Hit Scrape 1 (SFX) | ProSoundEffects | 1 |
| `golem.smash` | 9125869797 | Rock Drops Smashes Impacts Hits Some Rocking (SFX) | ProSoundEffects | 1 |
| `golem.crack` | 9125869495 | Rock Cracks Rock Hitting Rock Impact Debris  (SFX) | ProSoundEffects | 1 |
| `golem.crumble` | 9114221264 | Earthquake Debris 2 (SFX) | ProSoundEffects | 4 |
| `elemental.presence` | 9114343925 | Energy Presence 3 (SFX) | ProSoundEffects | 6 |
| `slime.squelch` | 9119990452 | Tentacle Slime 1 (SFX) | ProSoundEffects | 1 |
| `slime.squelch` | 9119990528 | Tentacle Slime 2 (SFX) | ProSoundEffects | 1 |
| `slime.squelch` | 9119990151 | Tentacle Slime 3 (SFX) | ProSoundEffects | 1 |
| `slime.splat` | 12222152 | splat.wav | Roblox | 0 |
| `slime.goo` | 9114631769 | Goo 1 (SFX) | ProSoundEffects | 3 |
| `flier.screech` | 9125474505 | Creature Screech Pterodactyl Vocals Screams  (SFX) | ProSoundEffects | 1 |
| `flier.flap` | 9113981169 | Creature Mix Pterodactyl Attack Wing Flaps 7 (SFX) | ProSoundEffects | 1 |
| `flier.flap` | 9125386815 | Bat Noises Bursts Of Wings Flapping Fast Awa (SFX) | ProSoundEffects | 3 |
| `flier.flap` | 9113992528 | Creature Wings 1 (SFX) | ProSoundEffects | 1 |
| `flier.hurt` | 9113988587 | Creature Vocal Pterodactyl Pained Screams 1 (SFX) | ProSoundEffects | 0 |
| `flier.hurt` | 9113988582 | Creature Vocal Pterodactyl Pained Screams 2 (SFX) | ProSoundEffects | 1 |
| `dragon.roar` | 9120031442 | Thunder With Lion Roar Searing Blast Growl 3 (SFX) | Roblox | 4 |
| `dragon.roar` | 9126100173 | Thunder With Lion Roar Growl Low Rumble Roar (SFX) | ProSoundEffects | 2 |
| `dragon.growl` | 9116300504 | Lion Roar Growl Exhale Low Rumble Breath 1 (SFX) | ProSoundEffects | 6 |
| `dragon.growl` | 9116292371 | Lion Roar Beast Snarl Inhale Exhale Breath 1 (SFX) | ProSoundEffects | 5 |
| `dragon.wail` | 9114166971 | Dragon Wailing 1 (SFX) | ProSoundEffects | 3 |
| `dragon.wail` | 9114166996 | Dragon Wailing 2 (SFX) | ProSoundEffects | 4 |
| `dragon.step` | 9114165326 | Dragon Footsteps 1 (SFX) | ProSoundEffects | 1 |
| `plant.rustle` | 9114576220 | Giant Leaves 1 (SFX) | ProSoundEffects | 2 |
| `plant.creak` | 9120839174 | Wood Door Creak Squeak 3 (SFX) | ProSoundEffects | 1 |
| `plant.snap` | 9113581977 | Branch Snap Wood Stick Crack Various Sizes 1 (SFX) | ProSoundEffects | 1 |
| `plant.snap` | 9113581599 | Branch Movement Crackling Impact 1 (SFX) | ProSoundEffects | 1 |
| `plant.splinter` | 9126239755 | Wood Crack Thick Splintering Bursts Creaking (SFX) | ProSoundEffects | 6 |
| `aquatic.whale` | 9120653665 | Whale Pass By Fat 1 (SFX) | ProSoundEffects | 2 |
| `aquatic.whale` | 9120653862 | Whale Pass By Fat 5 (SFX) | ProSoundEffects | 2 |
| `aquatic.hiss` | 9114854877 | Hydra Wet Throaty Hissing 3 (SFX) | ProSoundEffects | 3 |
| `aquatic.water` | 9114124038 | Dolphins Water Movement 6 (SFX) | ProSoundEffects | 1 |
| `monster.vocal` | 9116966503 | Monster Vocals 1 (SFX) | ProSoundEffects | 3 |
| `monster.vocal` | 9116966808 | Monster Vocals 5 (SFX) | ProSoundEffects | 2 |
| `monster.vocal` | 9116965705 | Monster Vocals 10 (SFX) | ProSoundEffects | 2 |
| `monster.growl` | 9113971433 | Creature Growls Lion 2 (SFX) | ProSoundEffects | 2 |
| `monster.growl` | 9113973128 | Creature Growls Lion 8 (SFX) | ProSoundEffects | 1 |
| `monster.die` | 9116967076 | Monster Vocals 7 (SFX) | ProSoundEffects | 5 |
| `gate.hum` | 9116390056 | Magic Glow Constant Deep Ticking Bassy Hum 1 (SFX) | ProSoundEffects | 14 |
| `gate.hum` | 9125485274 | Deep Synth Drone Modulating Sub Rumble Const (SFX) | ProSoundEffects | 14 |
| `gate.open` | 9126102694 | Time Warp Searing Build Up Large Suck Rumble (SFX) | ProSoundEffects | 3 |
| `gate.swoosh` | 9120698917 | Whoosh By Reverse Thick Airy Swoosh In 1 (SFX) | ProSoundEffects | 6 |
| `gate.whomp` | 9126087850 | Synth Whomp Boomy Pulsing Various Versions 1 (SFX) | ProSoundEffects | 1 |
| `gate.whomp` | 9119855787 | Synth Whomp Boomy Pulsing Various Versions 4 (SFX) | ProSoundEffects | 4 |
| `gate.quake` | 9114224721 | Earthquake Explosion 1 (SFX) | ProSoundEffects | 6 |
| `gate.quake` | 9114219864 | Earthquake Cracking 3 (SFX) | ProSoundEffects | 5 |
| `gate.suck` | 9118808396 | Sci Fi Reverse Suck Close 3 (SFX) | ProSoundEffects | 1 |
| `gate.suck` | 9114364773 | Extended Reverse Suck 8 (SFX) | ProSoundEffects | 7 |
| `gate.down` | 9117869522 | Power Down 3 (SFX) | ProSoundEffects | 3 |
| `gate.red` | 9119806932 | Synth Drone Deep Pulsing Sub Rumble Fast 1 (SFX) | ProSoundEffects | 14 |
| `gate.red` | 9113731775 | Cave Presence Constant Eerie Musical Hum 1 (SFX) | ProSoundEffects | 9 |
| `gate.alarm` | 9118805486 | Sci Fi Alarm Buzzing Rumble Reverberant 1 (SFX) | ProSoundEffects | 6 |
| `city.siren` | 9119164345 | Siren Variety 5 (SFX) | ProSoundEffects | 4 |
| `city.siren` | 9119164525 | Siren Variety 8 (SFX) | ProSoundEffects | 4 |
| `city.siren` | 9119165162 | Siren Variety 16 (SFX) | ProSoundEffects | 6 |
| `city.blat` | 9119162409 | Siren Blat 2 (SFX) | ProSoundEffects | 1 |
| `city.panic` | 9125905538 | Scream Pass Bys Individuals Running Yelling  (SFX) | ProSoundEffects | 2 |
| `city.panic` | 9125905515 | Scream Pass Bys Individuals Running Yelling  (SFX) | ProSoundEffects | 2 |
| `city.panic` | 9125906052 | Scream Pass Bys Individuals Running Yelling  (SFX) | ProSoundEffects | 3 |
| `city.crowd` | 9114360486 | Excited Foreign Crowd 3 (SFX) | ProSoundEffects | 3 |
| `city.radio` | 9120456889 | Walkie Talkie 12 (SFX) | ProSoundEffects | 1 |
| `city.radio` | 9120458059 | Walkie Talkie 5 (SFX) | ProSoundEffects | 1 |
| `city.radio` | 9120456673 | Walkie Talkie 7 (SFX) | ProSoundEffects | 1 |
| `city.radio` | 9118027586 | Radio Static 9 (SFX) | ProSoundEffects | 1 |
| `city.beep` | 9118777437 | Scanner Beeps 10 (SFX) | ProSoundEffects | 1 |
| `city.beep` | 9117060349 | Nasa Transmission Beep 2 (SFX) | ProSoundEffects | 1 |
| `city.beep` | 12221990 | electronicpingshort.wav | Roblox | 0 |
| `city.brake` | 9126104015 | Tire Chirp Engine Car In Short Punchy Skids  (SFX) | ProSoundEffects | 3 |
| `city.brake` | 9126103903 | Tire Chirp Engine Car In Short Punchy Skids  (SFX) | ProSoundEffects | 3 |
| `city.door` | 9112968542 | 1973 Dodge Tradesman Van 6 (SFX) | ProSoundEffects | 2 |
| `city.jingle` | 9113849492 | Coins Or Keys Jingle 6 (SFX) | ProSoundEffects | 1 |
| `cine.boom` | 9125484367 | Deep Hits Big Reverberant Booms Rumbling Tai (SFX) | ProSoundEffects | 4 |
| `cine.boom` | 9125404320 | Boom Impact Deep Distant Thumping Hits Boomi (SFX) | ProSoundEffects | 3 |
| `cine.whomp` | 9119882039 | Synth Whomps 38 (SFX) | ProSoundEffects | 1 |
| `cine.whomp` | 9119880580 | Synth Whomps 17 (SFX) | ProSoundEffects | 1 |
| `cine.shimmer` | 9116420445 | Magic Tone Tonal Shimmer Shaking Rattle 1 (SFX) | ProSoundEffects | 5 |
| `cine.gong` | 9114630316 | Gong Hit Resonant Trail 1 (SFX) | ProSoundEffects | 7 |
| `cine.tunnel` | 15675021174 | Roblox_UI_Loop_Air_Whooshes | Roblox | 11 |
| `cine.whiteout` | 9114364773 | Extended Reverse Suck 8 (SFX) | ProSoundEffects | 7 |
| `cine.zoom` | 9113168250 | Arrow Pass Bys Zooming Past 10 (SFX) | ProSoundEffects | 3 |
| `cine.meteor` | 12222095 | Rocket whoosh 01.wav | Roblox | 6 |
| `cine.meteor` | 9114428748 | Fireball Burning Whoosh By 2 (SFX) | ProSoundEffects | 5 |
| `cine.impact` | `rbxasset://sounds/impact_explosion_03.mp3` | impact_explosion_03.mp3 | built into the client | |
| `cine.roar` | 9116302511 | Lion Roar Short Blast Attack Angry Sharp 4 (SFX) | ProSoundEffects | 2 |
| `wind.night` | 9114228774 | Eerie Wind Constant 1 (SFX) | ProSoundEffects | 36 |
| `car.approach` | 9125349932 | 2001 Volkswagen Beetle Second Gear Approach  (SFX) | ProSoundEffects | 18 |
| `steps.march` | `rbxasset://sounds/action_footsteps_plastic.mp3` | action_footsteps_plastic.mp3 | built into the client | |

317 recordings, 310 distinct sources: 291 by ProSoundEffects, 16 by Roblox, 3 built-in files. Checked with tools/sfx/verify_ids.py on 2026-11-27.
