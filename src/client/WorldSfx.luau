--[[
	WORLD SOUNDS (BitLeveling): positional sound effects for the 3D world, played on this
	client. Weapons, magic, monsters, Gates and the city each have their own calls; every one
	resolves to a cue (one to four layered sounds), and every sound has a few recorded
	variants, a pitch range and a little volume jitter, so the same move never sounds the same
	twice.

		WorldSfx.start()                                 -- the sound group (idempotent; any call starts it)
		WorldSfx.play(name, at?, opts?) -> boolean       -- a sound, a cue, a namespaced name or an asset id
		WorldSfx.weapon(family, event, at?, opts?)       -- event: swing, hit, equip
		WorldSfx.magic(element, shape, at?, opts?)       -- shape: charge, cast, projectile, impact,
		                                                    explosion, nova, beam, buff, heal (and every
		                                                    SkillFx shape: see SHAPE_ALIAS)
		WorldSfx.monster(family, event, at?, opts?)      -- event: aggro, attack, hurt, death, step
		WorldSfx.monsterOf(model, event, opts?)          -- the same, from a live monster's model
		WorldSfx.gate(event, at?, opts?)                 -- hum (loop), open, surge, break, close,
		                                                    red (sting), redDrone (loop), enter, measure
		WorldSfx.city(event, at?, opts?)                 -- siren (loop), sirenBlip, panic, crowd,
		                                                    radio, beep, brake, door, crystal
		WorldSfx.loop(name, at, opts?) -> handle?        -- handle:stop(fade?), :Destroy(), :setVolume(v)

	at: a Vector3 (a spot in the world), a BasePart or Attachment (the sound rides along), a
	Model (its PrimaryPart), or nil (heard everywhere, not placed: cutscenes and the UI).
	opts: { volume, pitch, rank (1-6: bigger is lower and louder), power, tier, element, delay }

	Names: a sound ("blade.swish"), a cue ("weapon.blade.swing"), or a namespaced call that
	resolves like the functions above: "weapon.<family>.<event>", "magic.<element>.<shape>",
	"monster.<family>.<event>", "gate.<event>", "city.<event>". An asset id (a number,
	"rbxassetid://...", "rbxasset://sounds/...") plays as itself; the client's old
	rbxasset://sounds/*.wav files that no longer ship are mapped onto Roblox's own uploads of
	the same files (Sfx.LEGACY).

	The mix: everything goes through one SoundGroup (a compressor, a touch of low end) whose
	level follows the player's Effects volume setting (client/Sfx). At most MAX_VOICES sounds
	play at once (the quietest kind make way for the loudest), each sound at most `max` times
	at once, never twice in GAP seconds, and nothing plays beyond its own hearing range.
	Missing or removed audio just stays quiet: every Instance call is guarded.

	SOURCES (docs/SFX.md lists every id). Only two kinds of audio, both checked against the
	Creator Store's own records (apis.roblox.com toolbox-service: name, creator, published):
	  Roblox        uploads by Roblox itself (user 1): the classic client sounds (2009) and its
	                UI sets (2022-2024)
	  PSE           ProSoundEffects (user 7462895450): Roblox's licensed sound-effects partner
	                from the March 2022 audio update, free for every experience
	  built in      files that ship inside the Roblox client today (content/sounds in
	                rbxManifest.txt, client 0.748)
	Each variant below is { id, "its name in the Creator Store" }; tools/sfx/verify_ids.py
	re-checks every one of them.
]]

local WorldSfx = {}

WorldSfx.MAX_VOICES = 40
WorldSfx.GAP = 0.03
WorldSfx.GAIN = 0.75 -- the world's level against the UI's
WorldSfx.enabled = true
WorldSfx.onPlay = nil :: ((name: string, id: string, at: any) -> ())? -- (tests and debugging)
WorldSfx.stats = { played = 0, dropped = 0, failed = 0 }

-- ── the bank ────────────────────────────────────────────────────────────────
-- vol: the sound's level (before the cue's layer and the caller's volume)
-- pitch: { lo, hi } PlaybackSpeed range;  range: heard up to (studs);  min: full volume within
-- max: how many of this sound at once;  prio: 1 ambience, 2 normal, 3 important;  life: seconds
local SOUNDS: { [string]: any } = {}
local function S(name: string, def: any)
	SOUNDS[name] = def
end

-- ·· weapons: swings (PSE, and Roblox's classic sword sounds) ··
S("blade.swish", { vol = 0.6, pitch = { 0.94, 1.12 }, range = 120, v = {
	{ 9119749145, "Sword Swish 102 (SFX)" }, -- PSE
	{ 9119749263, "Sword Swish 5 (SFX)" }, -- PSE
	{ 9119749931, "Sword Swishes 2 (SFX)" }, -- PSE
	{ 9119750447, "Sword Swishes 9 (SFX)" }, -- PSE
	{ 9126013644, "Swish Med High End Sharp Swords Fast Punches (SFX)" }, -- PSE
	{ 12222216, "swordslash.wav" }, -- Roblox (the classic sword slash)
} })
S("heavy.whoosh", { vol = 0.65, pitch = { 0.82, 0.98 }, range = 130, v = {
	{ 9120742729, "Whoosh Thick Quick Multiple Variations 1 (SFX)" }, -- PSE
	{ 9120742716, "Whoosh Thick Quick Multiple Variations 2 (SFX)" }, -- PSE
	{ 9120742710, "Whoosh Thick Quick Multiple Variations 3 (SFX)" }, -- PSE
	{ 9126229927, "Whoosh By Fast Airy Swooshing Whipping Thuds (SFX)" }, -- PSE
} })
S("thrust.swish", { vol = 0.6, pitch = { 0.95, 1.15 }, range = 110, v = {
	{ 12222208, "swordlunge.wav" }, -- Roblox (the classic sword lunge)
	{ 9119699577, "Swish High End Thin Sharp Thick 1 (SFX)" }, -- PSE
	{ 9119691969, "Swish Brass Rod Airy Sharp Sword 8 (SFX)" }, -- PSE
} })
S("blunt.whoosh", { vol = 0.6, pitch = { 0.85, 1.0 }, range = 120, v = {
	{ 9120728815, "Whoosh Heavy Punches 1 (SFX)" }, -- PSE
	{ 9120728883, "Whoosh Heavy Punches 2 (SFX)" }, -- PSE
	{ 9113305619, "Baseball Bat Swing 5 (SFX)" }, -- PSE
} })
S("fist.whoosh", { vol = 0.55, pitch = { 0.95, 1.15 }, range = 100, v = {
	{ 9120729007, "Whoosh Heavy Punches 3 (SFX)" }, -- PSE
	{ 9120729005, "Whoosh Heavy Punches 4 (SFX)" }, -- PSE
	{ 9120729339, "Whoosh Heavy Punches 7 (SFX)" }, -- PSE
	{ 9120729412, "Whoosh Heavy Punches 8 (SFX)" }, -- PSE
} })
S("bow.draw", { vol = 0.4, pitch = { 1.1, 1.3 }, range = 70, v = {
	{ 9125407239, "Bow Stretches Wood Creaking Ripping Tearing  (SFX)" }, -- PSE
} })
S("bow.release", { vol = 0.6, pitch = { 0.95, 1.1 }, range = 130, v = {
	{ 9113167619, "Arrow Pass Bys 12 (SFX)" }, -- PSE
	{ 9113166993, "Arrow Pass Bys 1 (SFX)" }, -- PSE
	{ 9113167197, "Arrow Pass Bys 6 (SFX)" }, -- PSE
} })
S("crossbow.fire", { vol = 0.6, pitch = { 0.92, 1.08 }, range = 130, v = {
	{ 9114001369, "Crossbow Fire 12 (SFX)" }, -- PSE
	{ 9114002577, "Crossbow Fire 3 (SFX)" }, -- PSE
	{ 9114001362, "Crossbow Fire 14 (SFX)" }, -- PSE
} })
S("thrown.whoosh", { vol = 0.55, pitch = { 1.0, 1.2 }, range = 110, v = {
	{ 12222200, "swoosh.wav" }, -- Roblox
	{ 9116904947, "Metal Tube Swishes Single And Multiple 16 (SFX)" }, -- PSE
	{ 9113166206, "Arrow Out Whooshing Pass By 1 (SFX)" }, -- PSE
} })
S("whip.crack", { vol = 0.6, pitch = { 0.95, 1.15 }, range = 130, v = {
	{ 9113612888, "Buggy Whip Quick Swish Crack 11 (SFX)" }, -- PSE
	{ 9113611449, "Buggy Whip Light Crack Swish Many Versions 6 (SFX)" }, -- PSE
	{ 9120669139, "Whip Swish 2 (SFX)" }, -- PSE
} })
S("chain.rattle", { vol = 0.4, pitch = { 0.95, 1.15 }, range = 80, v = {
	{ 9113760085, "Chain Movement 1 (SFX)" }, -- PSE
	{ 9113760230, "Chain Movement 2 (SFX)" }, -- PSE
} })
S("spell.whoosh", { vol = 0.5, pitch = { 0.95, 1.2 }, range = 110, v = {
	{ 9116402961, "Magic Movement Airy Whips Swooshes 67 (SFX)" }, -- PSE
	{ 9125647922, "Magic Zoom Up Sharp Tubular Whoosh Fast Hiss (SFX)" }, -- PSE
	{ 9125648149, "Magic Zoom Up Sharp Tubular Whoosh Fast Hiss (SFX)" }, -- PSE
} })
S("bell.chime", { vol = 0.45, pitch = { 0.95, 1.15 }, range = 110, v = {
	{ 9116394545, "Magic Glows Soft Clusters Of Chiming Hits 1 (SFX)" }, -- PSE
	{ 9116394876, "Magic Glows Soft Clusters Of Chiming Hits 2 (SFX)" }, -- PSE
} })
S("armor.rattle", { vol = 0.35, pitch = { 0.9, 1.1 }, range = 70, v = {
	{ 9113156159, "Armor Metal 1 (SFX)" }, -- PSE
} })
S("blade.draw", { vol = 0.5, pitch = { 0.95, 1.1 }, range = 80, v = {
	{ 9119742466, "Sword Draw Clang Unsheathing Two Sabers 1 (SFX)" }, -- PSE
	{ 12222225, "unsheath.wav" }, -- Roblox (the classic sword drawn)
} })
S("equip.gear", { vol = 0.45, pitch = { 0.95, 1.1 }, range = 70, v = {
	{ 17208323435, "Roblox GUI - Equip" }, -- Roblox
} })

-- ·· weapons: hits ··
S("blade.hit", { vol = 0.65, pitch = { 0.92, 1.1 }, range = 130, v = {
	{ 9119746598, "Sword Hit 1 (SFX)" }, -- PSE
	{ 9119746592, "Sword Hit 2 (SFX)" }, -- PSE
	{ 9119746751, "Sword Hit 4 (SFX)" }, -- PSE
	{ 9119747120, "Sword Impact 102 (SFX)" }, -- PSE
	{ 9116196826, "Knife Shing 101 (SFX)" }, -- PSE
} })
S("heavy.hit", { vol = 0.75, pitch = { 0.82, 0.98 }, range = 150, v = {
	{ 9119747138, "Sword Impact 202 (SFX)" }, -- PSE
	{ 9113225986, "Axe Impact Giant Thuddy Hits On Wood Floor 5 (SFX)" }, -- PSE
	{ 9116673678, "Metal Impact Heavy Clunking Hits Scraping 1 (SFX)" }, -- PSE
} })
S("thrust.hit", { vol = 0.6, pitch = { 0.95, 1.12 }, range = 120, v = {
	{ 9119707097, "Swish Suck Reversed Metallic Swoosh Impact 1 (SFX)" }, -- PSE
	{ 9119707271, "Swish Suck Reversed Metallic Swoosh Impact 2 (SFX)" }, -- PSE
	{ 9113449585, "Blade Hits Metal Rod On Knife Impacts 10 (SFX)" }, -- PSE
} })
S("blunt.hit", { vol = 0.75, pitch = { 0.85, 1.0 }, range = 150, v = {
	{ 9125672726, "Metal Impact Sledge Hammer Hits On 5 Ft I- B (SFX)" }, -- PSE
	{ 9116675967, "Metal Impact Railroad Hammer 1 (SFX)" }, -- PSE
	{ 9117969687, "Punch Kit Beefy Hit 2 (SFX)" }, -- PSE
	{ 12221984, "collide.wav" }, -- Roblox
} })
S("arrow.hit", { vol = 0.6, pitch = { 0.95, 1.1 }, range = 110, v = {
	{ 9113162981, "Arrow In And Hit 6 (SFX)" }, -- PSE
	{ 9113161406, "Arrow In And Hit 13 (SFX)" }, -- PSE
	{ 9113161857, "Arrow In And Hit 19 (SFX)" }, -- PSE
} })
S("bolt.hit", { vol = 0.65, pitch = { 0.92, 1.06 }, range = 110, v = {
	{ 9113998001, "Crossbow Bolts Impact 3 (SFX)" }, -- PSE
	{ 9113999645, "Crossbow Bolts Impact 38 (SFX)" }, -- PSE
	{ 9113999366, "Crossbow Bolts Impact 30 (SFX)" }, -- PSE
} })
S("knife.hit", { vol = 0.55, pitch = { 1.0, 1.2 }, range = 100, v = {
	{ 9116197039, "Knife Shing 4 (SFX)" }, -- PSE
	{ 9116197041, "Knife Shing 3 (SFX)" }, -- PSE
} })
S("whip.hit", { vol = 0.6, pitch = { 0.95, 1.12 }, range = 110, v = {
	{ 9120200619, "Towel Cracks Low Intensity Whipping Hits 2 (SFX)" }, -- PSE
	{ 9113764229, "Chains And Metal Impacts 2 (SFX)" }, -- PSE
	{ 9113764330, "Chains And Metal Impacts 4 (SFX)" }, -- PSE
} })
S("spell.hit", { vol = 0.55, pitch = { 0.95, 1.15 }, range = 120, v = {
	{ 9116405618, "Magic Poofs Short Breathy Bursts Punchy 2 (SFX)" }, -- PSE
	{ 9116385087, "Magic Burst 5 (SFX)" }, -- PSE
} })
S("bell.hit", { vol = 0.45, pitch = { 0.95, 1.12 }, range = 110, v = {
	{ 9126073001, "Synth Sparkle Tone High Pitch Bell Tone Ding (SFX)" }, -- PSE
} })
S("fist.hit", { vol = 0.7, pitch = { 0.9, 1.08 }, range = 120, v = {
	{ 9117969717, "Punch Kit Beefy Hit 3 (SFX)" }, -- PSE
	{ 9117969878, "Punch Kit Beefy Hit 4 (SFX)" }, -- PSE
	{ 9117969420, "Punching Bag Hits 22 (SFX)" }, -- PSE
} })
S("shield.hit", { vol = 0.7, pitch = { 0.9, 1.05 }, range = 140, v = {
	{ 9119074309, "Shield Impacts 2 (SFX)" }, -- PSE
	{ 9119072660, "Shield Clang As Hit Metal Sword Hubcap 1 (SFX)" }, -- PSE
	{ 9119073323, "Shield Impacts 9 (SFX)" }, -- PSE
	{ 9119075967, "Shield Impacts 19 (SFX)" }, -- PSE
} })

-- ·· magic, by element ··
S("fire.whoosh", { vol = 0.6, pitch = { 0.9, 1.1 }, range = 140, v = {
	{ 9114439868, "Fire Whoosh 11 (SFX)" }, -- PSE
	{ 9114442751, "Fire Whoosh 2 (SFX)" }, -- PSE
} })
S("fire.ball", { vol = 0.6, pitch = { 0.95, 1.12 }, range = 160, life = 6, v = {
	{ 9114428740, "Fireball Pass By 1 (SFX)" }, -- PSE
	{ 9114428748, "Fireball Burning Whoosh By 2 (SFX)" }, -- PSE
} })
S("fire.burst", { vol = 0.7, pitch = { 0.9, 1.1 }, range = 160, v = {
	{ 9117983605, "Pyro Fire Ball Burst 9 (SFX)" }, -- PSE
	{ 9117987278, "Pyro Fire Ball Burst 12 (SFX)" }, -- PSE
} })
S("fire.explode", { vol = 0.8, pitch = { 0.85, 1.05 }, range = 220, prio = 3, life = 7, v = {
	{ 9117982781, "Pyro Explosion 3 (SFX)" }, -- PSE
	{ 9117982785, "Pyro Explosion 4 (SFX)" }, -- PSE
	{ 3149249837, "Cannon_Explode" }, -- Roblox
	{ 9114554567, "Gas Fire Explosion 3 (SFX)" }, -- PSE
} })
S("fire.sizzle", { vol = 0.4, pitch = { 0.9, 1.2 }, range = 90, v = {
	{ 9119165650, "Sizzle Short And Explosive Sear 4 (SFX)" }, -- PSE
} })
S("frost.crackle", { vol = 0.5, pitch = { 0.95, 1.2 }, range = 110, life = 5, v = {
	{ 9114858583, "Ice Crackle Large Block Cracks 1 (SFX)" }, -- PSE
} })
S("frost.chill", { vol = 0.45, pitch = { 0.9, 1.1 }, range = 130, life = 7, v = {
	{ 9125632802, "Lung Wind Whoosh Breathy Blasts Arctic Chill (SFX)" }, -- PSE
} })
S("frost.shatter", { vol = 0.65, pitch = { 0.95, 1.18 }, range = 140, v = {
	{ 9114855626, "Ice Block Drop To Concrete Shatter 1 (SFX)" }, -- PSE
	{ 9114856749, "Ice Block Drop To Concrete Shatter 9 (SFX)" }, -- PSE
	{ 9114855643, "Ice Block Drop To Concrete Shatter 2 (SFX)" }, -- PSE
	{ 12222005, "glassbreak.wav" }, -- Roblox
} })
S("frost.cracks", { vol = 0.6, pitch = { 0.85, 1.0 }, range = 160, life = 7, v = {
	{ 9114858761, "Ice Cracks 2 (SFX)" }, -- PSE
} })
S("volt.static", { vol = 0.4, pitch = { 0.95, 1.2 }, range = 100, v = {
	{ 9114246318, "Electricity Static 1 (SFX)" }, -- PSE
} })
S("volt.zap", { vol = 0.6, pitch = { 0.95, 1.2 }, range = 140, v = {
	{ 9114277757, "Electric Zaps 12 (SFX)" }, -- PSE
	{ 9114277338, "Electric Zaps 4 (SFX)" }, -- PSE
} })
S("volt.whoosh", { vol = 0.55, pitch = { 0.95, 1.15 }, range = 140, v = {
	{ 9114276859, "Electric Whoosh Bys In Groups Buzzy 9 (SFX)" }, -- PSE
} })
S("volt.burst", { vol = 0.7, pitch = { 0.92, 1.12 }, range = 170, v = {
	{ 9116275992, "Lightning Flashes Quick Electrical Bursts 12 (SFX)" }, -- PSE
	{ 9116275998, "Lightning Flashes Quick Electrical Bursts 13 (SFX)" }, -- PSE
	{ 9113150065, "Arc Zaps Phasey Short Bursts Ringing Blast 1 (SFX)" }, -- PSE
} })
S("volt.arc", { vol = 0.5, pitch = { 0.95, 1.1 }, range = 130, v = {
	{ 9114237705, "Electric Arcing 6 (SFX)" }, -- PSE
} })
S("volt.crack", { vol = 0.75, pitch = { 0.9, 1.05 }, range = 220, prio = 3, v = {
	{ 9126067628, "Synth Lightning Crack Sharp Some Rolling Tai (SFX)" }, -- PSE
} })
S("thunder", { vol = 0.8, pitch = { 0.9, 1.05 }, range = 600, min = 60, prio = 3, life = 9, v = {
	{ 12222030, "HalloweenThunder.wav" }, -- Roblox
	{ 12222019, "HalloweenLightning.wav" }, -- Roblox
	{ 9120016738, "Thunder Distant Boom Thud Rapid Hits 2 (SFX)" }, -- PSE
	{ 9120016256, "Thunder Cracks Big Rumbling Blasts Booming 3 (SFX)" }, -- PSE
} })
S("wind.suck", { vol = 0.45, pitch = { 0.95, 1.15 }, range = 120, life = 6, v = {
	{ 9126236071, "Wind Suck Slow Backwards Swooshing Build Up  (SFX)" }, -- PSE
} })
S("wind.burst", { vol = 0.6, pitch = { 0.92, 1.15 }, range = 150, v = {
	{ 9120749129, "Wind Burst Alien Vortex Blasts 1 (SFX)" }, -- PSE
	{ 9120748924, "Wind Burst Alien Vortex Blasts 2 (SFX)" }, -- PSE
	{ 9120749306, "Wind Burst Alien Vortex Blasts 7 (SFX)" }, -- PSE
	{ 9126229273, "Whoosh By Fast Airy Swooshing Whipping Thuds (SFX)" }, -- PSE
} })
S("wind.big", { vol = 0.75, pitch = { 0.85, 1.0 }, range = 220, prio = 3, life = 8, v = {
	{ 9120749149, "Wind Burst Alien Vortex Blasts 4 (SFX)" }, -- PSE
	{ 9120769331, "Wind Whoosh Sonic Boom Low End Impact 1 (SFX)" }, -- PSE
} })
S("earth.rumble", { vol = 0.45, pitch = { 0.9, 1.1 }, range = 120, v = {
	{ 9114032606, "Debris Movement 5 (SFX)" }, -- PSE
} })
S("earth.scrape", { vol = 0.65, pitch = { 0.9, 1.08 }, range = 140, v = {
	{ 9118617342, "Rock Impact Large Hit Scrape 1 (SFX)" }, -- PSE
} })
S("earth.crack", { vol = 0.7, pitch = { 0.9, 1.12 }, range = 160, v = {
	{ 9125869504, "Rock Cracks Rock Hitting Rock Impact Debris  (SFX)" }, -- PSE
	{ 9118587493, "Rock Drop On Concrete Drops Breaks 1 (SFX)" }, -- PSE
	{ 9118587494, "Rock Drop On Concrete Drops Breaks 2 (SFX)" }, -- PSE
} })
S("earth.burst", { vol = 0.8, pitch = { 0.88, 1.05 }, range = 220, prio = 3, life = 7, v = {
	{ 9114221862, "Earthquake Debris Rock Bursts Scattering 1 (SFX)" }, -- PSE
	{ 9114086455, "Dirt Explosion 3 (SFX)" }, -- PSE
} })
S("earth.quake", { vol = 0.8, pitch = { 0.9, 1.05 }, range = 260, prio = 3, life = 8, v = {
	{ 9114224432, "Earthquake Explosion 3 (SFX)" }, -- PSE
} })
S("water.bubble", { vol = 0.5, pitch = { 0.95, 1.2 }, range = 110, v = {
	{ 9113604979, "Bubble Whooshes Liquid Pass By 1 (SFX)" }, -- PSE
} })
S("water.burst", { vol = 0.65, pitch = { 0.92, 1.1 }, range = 150, v = {
	{ 9120502958, "Water Burst Boom Blast Hissing Spray 1 (SFX)" }, -- PSE
} })
S("water.splash", { vol = 0.65, pitch = { 0.92, 1.15 }, range = 140, v = {
	{ 9117822998, "Pool Jumps Splashes Water Impact Swimming 3 (SFX)" }, -- PSE
	{ 9125703162, "Mud Puddle Splash Shallow Water Impacts Hits (SFX)" }, -- PSE
	{ "rbxasset://sounds/impact_water.mp3", "impact_water.mp3" }, -- built in
} })
S("water.boom", { vol = 0.75, pitch = { 0.88, 1.02 }, range = 200, prio = 3, life = 6, v = {
	{ 9120503525, "Water Burst Boom Blast Some Whirring Hum 1 (SFX)" }, -- PSE
} })
S("water.flow", { vol = 0.5, pitch = { 0.95, 1.1 }, range = 130, life = 6, v = {
	{ 9120674127, "Whirlpool Flowing 1 (SFX)" }, -- PSE
} })
S("holy.rise", { vol = 0.5, pitch = { 0.95, 1.1 }, range = 130, life = 6, v = {
	{ 9125626856, "Light Cone Suck Synth And Reverse Cymbal Bui (SFX)" }, -- PSE
} })
S("holy.chime", { vol = 0.5, pitch = { 0.95, 1.12 }, range = 140, life = 6, v = {
	{ 9116394756, "Magic Glows Soft Clusters Of Chiming Hits 3 (SFX)" }, -- PSE
	{ 9119447936, "Sparkle Bell Tree Wind Chimes 1 (SFX)" }, -- PSE
} })
S("holy.ding", { vol = 0.55, pitch = { 0.95, 1.1 }, range = 150, v = {
	{ 9126073011, "Synth Sparkle Tone High Pitch Bell Tone Ding (SFX)" }, -- PSE
	{ 9126072027, "Synth Sparkle Tone High Pitch Bell Tone Burs (SFX)" }, -- PSE
} })
S("holy.swell", { vol = 0.7, pitch = { 0.92, 1.05 }, range = 220, prio = 3, life = 8, v = {
	{ 9125544480, "Energy Blast Big Deep Horn Swell Reverberant (SFX)" }, -- PSE
} })
S("holy.choir", { vol = 0.4, pitch = { 0.98, 1.05 }, range = 160, life = 8, v = {
	{ 9113123536, "Angel Wails 5 (SFX)" }, -- PSE
} })
S("void.suck", { vol = 0.6, pitch = { 0.9, 1.1 }, range = 140, v = {
	{ 9118159096, "Reverse Suck 2 (SFX)" }, -- PSE
	{ 9118808396, "Sci Fi Reverse Suck Close 3 (SFX)" }, -- PSE
} })
S("void.reverse", { vol = 0.55, pitch = { 0.9, 1.1 }, range = 130, v = {
	{ 9118158081, "Reversed Whoosh Backwards Hissing Burst 1 (SFX)" }, -- PSE
	{ 9118158113, "Reversed Whoosh Backwards Hissing Burst 2 (SFX)" }, -- PSE
} })
S("void.boom", { vol = 0.75, pitch = { 0.88, 1.05 }, range = 200, prio = 3, v = {
	{ 9120057087, "Time Warp Searing Build Up Boomy Explosion 5 (SFX)" }, -- PSE
	{ 9120057111, "Time Warp Searing Build Up Boomy Explosion 4 (SFX)" }, -- PSE
} })
S("void.blast", { vol = 0.8, pitch = { 0.88, 1.0 }, range = 260, prio = 3, life = 8, v = {
	{ 9126050066, "Synth Blast Space Explosion Reverberant Tail (SFX)" }, -- PSE
	{ 9126102254, "Time Warp Big Explosion Blast Boom Tonal Tai (SFX)" }, -- PSE
} })
S("void.whisper", { vol = 0.4, pitch = { 0.85, 1.05 }, range = 90, v = {
	{ 9114228524, "Eerie Whispering Eerie Reverberant Demon 2 (SFX)" }, -- PSE
} })
S("venom.bubble", { vol = 0.45, pitch = { 0.95, 1.2 }, range = 100, v = {
	{ 9112872239, "Small Bubbles Water Surface Float Up Pop 5 (SFX)" }, -- PSE
} })
S("venom.spray", { vol = 0.55, pitch = { 0.95, 1.15 }, range = 130, v = {
	{ 9119991930, "Termite Sprays Acid Hissing Bursts 2 (SFX)" }, -- PSE
	{ 9119991802, "Termite Sprays Acid Hissing Bursts 3 (SFX)" }, -- PSE
} })
S("venom.squish", { vol = 0.55, pitch = { 0.95, 1.15 }, range = 120, v = {
	{ 9126209045, "Wet Newspaper Squish Sloshy Impact Suction 1 (SFX)" }, -- PSE
	{ 9116319322, "Liquid Squish 2 (SFX)" }, -- PSE
	{ 9120583506, "Water Slushing Slightly Goopy Squish 1 (SFX)" }, -- PSE
} })
S("arcane.rise", { vol = 0.5, pitch = { 0.95, 1.12 }, range = 130, v = {
	{ 9117297453, "Phasey Synth Power Up High Pitched Rise 2 (SFX)" }, -- PSE
} })
S("arcane.burst", { vol = 0.6, pitch = { 0.92, 1.15 }, range = 150, v = {
	{ 9116384485, "Magic Burst 1 (SFX)" }, -- PSE
	{ 9116384473, "Magic Burst 2 (SFX)" }, -- PSE
	{ 9116385087, "Magic Burst 5 (SFX)" }, -- PSE
} })
S("arcane.shimmer", { vol = 0.5, pitch = { 0.95, 1.15 }, range = 140, v = {
	{ 9125646918, "Magic Whooshes Pass Bys Metallic Shimmering  (SFX)" }, -- PSE
} })
S("arcane.morph", { vol = 0.5, pitch = { 0.95, 1.15 }, range = 120, v = {
	{ 9116421550, "Magic Transformation 6 (SFX)" }, -- PSE
} })
S("arcane.beam", { vol = 0.55, pitch = { 0.95, 1.1 }, range = 160, v = {
	{ 9114340693, "Energy Pass By Sci Fi Tonal Whooshes 1 (SFX)" }, -- PSE
} })
S("arcane.blast", { vol = 0.7, pitch = { 0.9, 1.05 }, range = 200, prio = 3, v = {
	{ 9114314399, "Energy Blasts 4 (SFX)" }, -- PSE
} })
S("heal.sparkle", { vol = 0.5, pitch = { 0.98, 1.12 }, range = 120, life = 6, v = {
	{ 9125635426, "Magical Exit Sparkling Pass Bys Clinking Chi (SFX)" }, -- PSE
} })
S("heal.fall", { vol = 0.45, pitch = { 0.98, 1.1 }, range = 120, v = {
	{ 9116418035, "Magic Tone Falling Shimmer Flanged 3 (SFX)" }, -- PSE
} })
S("heal.aura", { vol = 0.45, pitch = { 0.95, 1.08 }, range = 110, v = {
	{ 17208327798, "Roblox GUI - Aura" }, -- Roblox
} })
S("buff.up", { vol = 0.5, pitch = { 0.95, 1.12 }, range = 110, v = {
	{ 9117887138, "Power Up Sweeteners 3 (SFX)" }, -- PSE
	{ 9117886660, "Power Up Sweeteners 16 (SFX)" }, -- PSE
} })
S("move.whoosh", { vol = 0.55, pitch = { 0.95, 1.15 }, range = 110, v = {
	{ 9126229488, "Whoosh By Fast Airy Swooshing Whipping Thuds (SFX)" }, -- PSE
	{ 9116402961, "Magic Movement Airy Whips Swooshes 67 (SFX)" }, -- PSE
} })
S("air.pound", { vol = 0.7, pitch = { 0.88, 1.05 }, range = 160, v = {
	{ 9125577419, "Giant Air Blast Low Bursts Pound Many Versio (SFX)" }, -- PSE
} })
S("magic.poof", { vol = 0.5, pitch = { 0.95, 1.15 }, range = 110, v = {
	{ 9116406610, "Magic Poofs Thumpy Wheezy Exhale 1 (SFX)" }, -- PSE
	{ 9116405713, "Magic Poofs Short Breathy Bursts Punchy 2 (SFX)" }, -- PSE
} })

-- ·· monster voices (PSE): never a person's scream, never anything gory ··
S("goblin.growl", { vol = 0.6, pitch = { 1.0, 1.2 }, range = 120, v = {
	{ 9114624345, "Goblin Growl 1 (SFX)" }, -- PSE
	{ 9114624343, "Goblin Growl 2 (SFX)" }, -- PSE
} })
S("goblin.stutter", { vol = 0.6, pitch = { 1.0, 1.2 }, range = 110, v = {
	{ 9114625192, "Goblin Stutter 2 (SFX)" }, -- PSE
	{ 9114624510, "Goblin Growl 4 (SFX)" }, -- PSE
} })
S("goblin.hurt", { vol = 0.55, pitch = { 1.05, 1.25 }, range = 100, v = {
	{ 9114625189, "Goblin Stutter 3 (SFX)" }, -- PSE
} })
S("goblin.croak", { vol = 0.55, pitch = { 1.0, 1.15 }, range = 110, life = 6, v = {
	{ 9114624129, "Goblin Croak 5 (SFX)" }, -- PSE
} })
S("orc.growl", { vol = 0.7, pitch = { 0.92, 1.08 }, range = 150, v = {
	{ 9114628321, "Goliath Vocal Deep Growling Voice 17 (SFX)" }, -- PSE
	{ 9114628620, "Goliath Vocal Deep Growling Voice 21 (SFX)" }, -- PSE
} })
S("orc.attack", { vol = 0.65, pitch = { 0.92, 1.08 }, range = 140, v = {
	{ 9114628357, "Goliath Vocal Deep Growling Voice 18 (SFX)" }, -- PSE
	{ 9114628818, "Goliath Vocal Deep Growling Voice 22 (SFX)" }, -- PSE
} })
S("orc.groan", { vol = 0.6, pitch = { 0.92, 1.1 }, range = 120, v = {
	{ 9113636490, "Bull Monster Groan 1 (SFX)" }, -- PSE
	{ 9113636681, "Bull Monster Groan 3 (SFX)" }, -- PSE
	{ 9113636491, "Bull Monster Groan 2 (SFX)" }, -- PSE
} })
S("humanoid.hiss", { vol = 0.45, pitch = { 1.05, 1.25 }, range = 100, v = {
	{ 9116430990, "Magic Vocal Hiss Sharp Swooshing Pass By 2 (SFX)" }, -- PSE
} })
S("humanoid.grunt", { vol = 0.55, pitch = { 0.95, 1.12 }, range = 100, v = {
	{ 9116451392, "Male Grunts Two Men Fighting With Spear 2 (SFX)" }, -- PSE
	{ 9116451917, "Male Grunts Two Men Fighting With Spear 6 (SFX)" }, -- PSE
	{ 9116451911, "Male Grunts Two Men Fighting With Spear 7 (SFX)" }, -- PSE
	{ 9116451377, "Male Grunts Two Men Fighting With Spear 1 (SFX)" }, -- PSE
} })
S("humanoid.hurt", { vol = 0.5, pitch = { 0.95, 1.12 }, range = 100, v = {
	{ 9116451739, "Male Grunts Two Men Fighting With Spear 3 (SFX)" }, -- PSE
} })
S("ghost.exhale", { vol = 0.5, pitch = { 0.9, 1.1 }, range = 110, life = 7, v = {
	{ 9114572768, "Ghostly Exhale Breathy Slow Cu 1 (SFX)" }, -- PSE
	{ 9114573102, "Ghostly Exhale Long Breathy Slow Cu 2 (SFX)" }, -- PSE
} })
S("giant.voice", { vol = 0.8, pitch = { 0.78, 0.92 }, range = 220, prio = 3, v = {
	{ 9114630281, "Goliath Vocal Deep Growling Voice 46 (SFX)" }, -- PSE
} })
S("giant.step", { vol = 0.7, pitch = { 0.85, 1.0 }, range = 180, v = {
	{ 9114080709, "Dinosaur Footsteps Boomy Thumps 16 (SFX)" }, -- PSE
} })
S("beast.growl", { vol = 0.6, pitch = { 0.92, 1.1 }, range = 130, v = {
	{ 9120788137, "Wolf Growl 3 (SFX)" }, -- PSE
	{ 9116311527, "Lion Snarl 3 (SFX)" }, -- PSE
} })
S("beast.attack", { vol = 0.7, pitch = { 0.92, 1.1 }, range = 150, v = {
	{ 9120790555, "Wolf Snarl 1 (SFX)" }, -- PSE
	{ 9116302323, "Lion Roar Short Blast Attack Angry Sharp 2 (SFX)" }, -- PSE
	{ 9117733732, "Polar Bear 1 (SFX)" }, -- PSE
} })
S("beast.hurt", { vol = 0.6, pitch = { 1.0, 1.15 }, range = 120, v = {
	{ 9116304872, "Lion Roar Tired 12 (SFX)" }, -- PSE
} })
S("beast.die", { vol = 0.6, pitch = { 0.92, 1.05 }, range = 130, v = {
	{ 9116306682, "Lion Roar Tired 33 (SFX)" }, -- PSE
} })
S("insect.buzz", { vol = 0.5, pitch = { 0.95, 1.2 }, range = 100, v = {
	{ 9113974108, "Creature Mix Big Flying Insects 1 (SFX)" }, -- PSE
} })
S("insect.munch", { vol = 0.55, pitch = { 0.95, 1.15 }, range = 100, v = {
	{ 9113986695, "Creatures Munch Army Of Crablike Insects 7 (SFX)" }, -- PSE
} })
S("insect.click", { vol = 0.45, pitch = { 0.9, 1.2 }, range = 90, v = {
	{ 9113957586, "Crab Claw Repetitive Clicks 8 (SFX)" }, -- PSE
} })
S("insect.hurt", { vol = 0.5, pitch = { 0.95, 1.2 }, range = 100, v = {
	{ 9113977066, "Creature Mix Big Flying Insects 35 (SFX)" }, -- PSE
} })
S("spider.hiss", { vol = 0.55, pitch = { 0.92, 1.12 }, range = 110, v = {
	{ 9113989919, "Creature Vocal Spider Hiss Exhale 1 (SFX)" }, -- PSE
} })
S("spider.attack", { vol = 0.6, pitch = { 0.92, 1.12 }, range = 120, v = {
	{ 9125471800, "Creature Mix Big Spider Attack Vocal Footste (SFX)" }, -- PSE
	{ 9113991185, "Creature Vocal Spider Hiss Squawk 4 (SFX)" }, -- PSE
} })
S("spider.hurt", { vol = 0.55, pitch = { 1.0, 1.2 }, range = 110, v = {
	{ 9113991277, "Creature Vocal Spider Hiss Squawk 7 (SFX)" }, -- PSE
} })
S("spider.screech", { vol = 0.6, pitch = { 0.88, 1.0 }, range = 130, v = {
	{ 9125478014, "Creature Vocal Spider Screech Low To Midrang (SFX)" }, -- PSE
} })
S("reptile.hiss", { vol = 0.55, pitch = { 0.92, 1.1 }, range = 120, v = {
	{ 9120049675, "Tiger Snake- Like Hisses 3 (SFX)" }, -- PSE
	{ 9114808824, "Hissing Alligator 1 (SFX)" }, -- PSE
} })
S("reptile.attack", { vol = 0.6, pitch = { 0.92, 1.1 }, range = 120, v = {
	{ 9119300025, "Snake Attack Vocal 7 (SFX)" }, -- PSE
	{ 9119299847, "Snake Attack Vocal 4 (SFX)" }, -- PSE
} })
S("reptile.hurt", { vol = 0.5, pitch = { 1.0, 1.15 }, range = 110, v = {
	{ 9114854828, "Hydra Wet Throaty Hissing 1 (SFX)" }, -- PSE
} })
S("reptile.die", { vol = 0.55, pitch = { 0.85, 1.0 }, range = 120, v = {
	{ 9119302136, "Snake Growl 2 (SFX)" }, -- PSE
} })
S("undead.whisper", { vol = 0.45, pitch = { 0.88, 1.05 }, range = 100, v = {
	{ 9126213984, "Whisper Bursts Unintelligible Eerie Evil Gho (SFX)" }, -- PSE
	{ 9114228524, "Eerie Whispering Eerie Reverberant Demon 2 (SFX)" }, -- PSE
} })
S("undead.attack", { vol = 0.5, pitch = { 0.92, 1.1 }, range = 110, v = {
	{ 9116430994, "Magic Vocal Hiss Sharp Swooshing Pass By 3 (SFX)" }, -- PSE
} })
S("undead.wail", { vol = 0.45, pitch = { 0.92, 1.08 }, range = 120, v = {
	{ 9114463908, "Flangy Synth Scream Otherworldly Wail Cry 3 (SFX)" }, -- PSE
} })
S("demon.growl", { vol = 0.6, pitch = { 0.85, 1.0 }, range = 140, v = {
	{ 9114315023, "Energy Burst Growl 1 (SFX)" }, -- PSE
	{ 9114315051, "Energy Burst Growl 2 (SFX)" }, -- PSE
	{ 9114315137, "Energy Burst Growl 3 (SFX)" }, -- PSE
} })
S("demon.blast", { vol = 0.6, pitch = { 0.9, 1.05 }, range = 140, v = {
	{ 9114046660, "Demon Vehicle Whooshy Metallic Blast 3 (SFX)" }, -- PSE
} })
S("demon.voice", { vol = 0.5, pitch = { 0.85, 1.0 }, range = 110, v = {
	{ 9118567832, "Robot Voice Nasty Growly 9 (SFX)" }, -- PSE
} })
S("demon.die", { vol = 0.55, pitch = { 0.9, 1.05 }, range = 140, life = 6, v = {
	{ 9114039650, "Demon Screams Reversed Hollow Voice Suck 7 (SFX)" }, -- PSE
} })
S("golem.roar", { vol = 0.6, pitch = { 0.75, 0.9 }, range = 160, v = {
	{ 9119820079, "Synth Roar Growly Ascend Short Bursts 3 (SFX)" }, -- PSE
} })
S("golem.grind", { vol = 0.5, pitch = { 0.8, 0.95 }, range = 120, v = {
	{ 9114561298, "Gear Grind 2 (SFX)" }, -- PSE
} })
S("golem.smash", { vol = 0.75, pitch = { 0.85, 1.0 }, range = 170, v = {
	{ 9118617342, "Rock Impact Large Hit Scrape 1 (SFX)" }, -- PSE
	{ 9125869797, "Rock Drops Smashes Impacts Hits Some Rocking (SFX)" }, -- PSE
} })
S("golem.crack", { vol = 0.6, pitch = { 0.9, 1.1 }, range = 130, v = {
	{ 9125869495, "Rock Cracks Rock Hitting Rock Impact Debris  (SFX)" }, -- PSE
} })
S("golem.crumble", { vol = 0.75, pitch = { 0.88, 1.0 }, range = 200, prio = 3, life = 6, v = {
	{ 9114221264, "Earthquake Debris 2 (SFX)" }, -- PSE
} })
S("elemental.presence", { vol = 0.5, pitch = { 0.95, 1.12 }, range = 120, life = 7, v = {
	{ 9114343925, "Energy Presence 3 (SFX)" }, -- PSE
} })
S("slime.squelch", { vol = 0.55, pitch = { 0.9, 1.2 }, range = 100, v = {
	{ 9119990452, "Tentacle Slime 1 (SFX)" }, -- PSE
	{ 9119990528, "Tentacle Slime 2 (SFX)" }, -- PSE
	{ 9119990151, "Tentacle Slime 3 (SFX)" }, -- PSE
} })
S("slime.splat", { vol = 0.5, pitch = { 0.9, 1.15 }, range = 100, v = {
	{ 12222152, "splat.wav" }, -- Roblox
} })
S("slime.goo", { vol = 0.55, pitch = { 0.9, 1.1 }, range = 110, v = {
	{ 9114631769, "Goo 1 (SFX)" }, -- PSE
} })
S("flier.screech", { vol = 0.55, pitch = { 1.0, 1.2 }, range = 140, v = {
	{ 9125474505, "Creature Screech Pterodactyl Vocals Screams  (SFX)" }, -- PSE
} })
S("flier.flap", { vol = 0.55, pitch = { 0.92, 1.15 }, range = 120, v = {
	{ 9113981169, "Creature Mix Pterodactyl Attack Wing Flaps 7 (SFX)" }, -- PSE
	{ 9125386815, "Bat Noises Bursts Of Wings Flapping Fast Awa (SFX)" }, -- PSE
	{ 9113992528, "Creature Wings 1 (SFX)" }, -- PSE
} })
S("flier.hurt", { vol = 0.5, pitch = { 1.0, 1.2 }, range = 120, v = {
	{ 9113988587, "Creature Vocal Pterodactyl Pained Screams 1 (SFX)" }, -- PSE
	{ 9113988582, "Creature Vocal Pterodactyl Pained Screams 2 (SFX)" }, -- PSE
} })
S("dragon.roar", { vol = 0.85, pitch = { 0.88, 1.0 }, range = 300, min = 30, prio = 3, life = 7, v = {
	{ 9120031442, "Thunder With Lion Roar Searing Blast Growl 3 (SFX)" }, -- Roblox
	{ 9126100173, "Thunder With Lion Roar Growl Low Rumble Roar (SFX)" }, -- PSE
} })
S("dragon.growl", { vol = 0.7, pitch = { 0.8, 0.95 }, range = 200, v = {
	{ 9116300504, "Lion Roar Growl Exhale Low Rumble Breath 1 (SFX)" }, -- PSE
	{ 9116292371, "Lion Roar Beast Snarl Inhale Exhale Breath 1 (SFX)" }, -- PSE
} })
S("dragon.wail", { vol = 0.7, pitch = { 0.88, 1.02 }, range = 220, prio = 3, life = 6, v = {
	{ 9114166971, "Dragon Wailing 1 (SFX)" }, -- PSE
	{ 9114166996, "Dragon Wailing 2 (SFX)" }, -- PSE
} })
S("dragon.step", { vol = 0.65, pitch = { 0.85, 1.0 }, range = 160, v = {
	{ 9114165326, "Dragon Footsteps 1 (SFX)" }, -- PSE
} })
S("plant.rustle", { vol = 0.5, pitch = { 0.9, 1.1 }, range = 100, v = {
	{ 9114576220, "Giant Leaves 1 (SFX)" }, -- PSE
} })
S("plant.creak", { vol = 0.55, pitch = { 0.85, 1.05 }, range = 110, v = {
	{ 9120839174, "Wood Door Creak Squeak 3 (SFX)" }, -- PSE
} })
S("plant.snap", { vol = 0.6, pitch = { 0.9, 1.1 }, range = 120, v = {
	{ 9113581977, "Branch Snap Wood Stick Crack Various Sizes 1 (SFX)" }, -- PSE
	{ 9113581599, "Branch Movement Crackling Impact 1 (SFX)" }, -- PSE
} })
S("plant.splinter", { vol = 0.65, pitch = { 0.9, 1.05 }, range = 150, life = 7, v = {
	{ 9126239755, "Wood Crack Thick Splintering Bursts Creaking (SFX)" }, -- PSE
} })
S("aquatic.whale", { vol = 0.6, pitch = { 0.85, 1.05 }, range = 150, v = {
	{ 9120653665, "Whale Pass By Fat 1 (SFX)" }, -- PSE
	{ 9120653862, "Whale Pass By Fat 5 (SFX)" }, -- PSE
} })
S("aquatic.hiss", { vol = 0.55, pitch = { 0.9, 1.1 }, range = 120, v = {
	{ 9114854877, "Hydra Wet Throaty Hissing 3 (SFX)" }, -- PSE
} })
S("aquatic.water", { vol = 0.5, pitch = { 0.95, 1.15 }, range = 110, v = {
	{ 9114124038, "Dolphins Water Movement 6 (SFX)" }, -- PSE
} })
S("monster.vocal", { vol = 0.6, pitch = { 0.9, 1.1 }, range = 130, v = {
	{ 9116966503, "Monster Vocals 1 (SFX)" }, -- PSE
	{ 9116966808, "Monster Vocals 5 (SFX)" }, -- PSE
	{ 9116965705, "Monster Vocals 10 (SFX)" }, -- PSE
} })
S("monster.growl", { vol = 0.6, pitch = { 0.92, 1.1 }, range = 130, v = {
	{ 9113971433, "Creature Growls Lion 2 (SFX)" }, -- PSE
	{ 9113973128, "Creature Growls Lion 8 (SFX)" }, -- PSE
} })
S("monster.die", { vol = 0.55, pitch = { 0.9, 1.05 }, range = 130, life = 6, v = {
	{ 9116967076, "Monster Vocals 7 (SFX)" }, -- PSE
} })

-- ·· Gates ··
S("gate.hum", { vol = 0.5, pitch = { 0.95, 1.05 }, range = 160, min = 12, prio = 1, v = {
	{ 9116390056, "Magic Glow Constant Deep Ticking Bassy Hum 1 (SFX)" }, -- PSE (loops)
	{ 9125485274, "Deep Synth Drone Modulating Sub Rumble Const (SFX)" }, -- PSE (loops)
} })
S("gate.open", { vol = 0.85, pitch = { 0.92, 1.05 }, range = 320, min = 30, prio = 3, life = 6, v = {
	{ 9126102694, "Time Warp Searing Build Up Large Suck Rumble (SFX)" }, -- PSE
} })
S("gate.swoosh", { vol = 0.6, pitch = { 0.92, 1.05 }, range = 260, min = 25, prio = 2, life = 8, v = {
	{ 9120698917, "Whoosh By Reverse Thick Airy Swoosh In 1 (SFX)" }, -- PSE
} })
S("gate.whomp", { vol = 0.6, pitch = { 0.9, 1.05 }, range = 220, min = 20, v = {
	{ 9126087850, "Synth Whomp Boomy Pulsing Various Versions 1 (SFX)" }, -- PSE
	{ 9119855787, "Synth Whomp Boomy Pulsing Various Versions 4 (SFX)" }, -- PSE
} })
S("gate.quake", { vol = 0.9, pitch = { 0.88, 1.0 }, range = 400, min = 40, prio = 3, life = 9, v = {
	{ 9114224721, "Earthquake Explosion 1 (SFX)" }, -- PSE
	{ 9114219864, "Earthquake Cracking 3 (SFX)" }, -- PSE
} })
S("gate.suck", { vol = 0.7, pitch = { 0.92, 1.05 }, range = 260, min = 25, prio = 3, life = 8, v = {
	{ 9118808396, "Sci Fi Reverse Suck Close 3 (SFX)" }, -- PSE
	{ 9114364773, "Extended Reverse Suck 8 (SFX)" }, -- PSE
} })
S("gate.down", { vol = 0.5, pitch = { 0.85, 1.0 }, range = 200, min = 20, v = {
	{ 9117869522, "Power Down 3 (SFX)" }, -- PSE
} })
S("gate.red", { vol = 0.55, pitch = { 0.92, 1.02 }, range = 200, min = 16, prio = 1, v = {
	{ 9119806932, "Synth Drone Deep Pulsing Sub Rumble Fast 1 (SFX)" }, -- PSE (loops)
	{ 9113731775, "Cave Presence Constant Eerie Musical Hum 1 (SFX)" }, -- PSE (loops)
} })
S("gate.alarm", { vol = 0.7, pitch = { 0.92, 1.02 }, range = 300, min = 30, prio = 3, life = 7, v = {
	{ 9118805486, "Sci Fi Alarm Buzzing Rumble Reverberant 1 (SFX)" }, -- PSE
} })

-- ·· the city ··
S("city.siren", { vol = 0.5, pitch = { 0.97, 1.03 }, range = 320, min = 24, prio = 1, v = {
	{ 9119164345, "Siren Variety 5 (SFX)" }, -- PSE (an ambulance-style wail)
	{ 9119164525, "Siren Variety 8 (SFX)" }, -- PSE
	{ 9119165162, "Siren Variety 16 (SFX)" }, -- PSE
} })
S("city.blat", { vol = 0.5, pitch = { 0.95, 1.05 }, range = 260, min = 20, v = {
	{ 9119162409, "Siren Blat 2 (SFX)" }, -- PSE
} })
S("city.panic", { vol = 0.45, pitch = { 0.95, 1.08 }, range = 150, max = 3, v = {
	{ 9125905538, "Scream Pass Bys Individuals Running Yelling  (SFX)" }, -- PSE (people running past)
	{ 9125905515, "Scream Pass Bys Individuals Running Yelling  (SFX)" }, -- PSE
	{ 9125906052, "Scream Pass Bys Individuals Running Yelling  (SFX)" }, -- PSE
} })
S("city.crowd", { vol = 0.4, pitch = { 0.95, 1.05 }, range = 160, v = {
	{ 9114360486, "Excited Foreign Crowd 3 (SFX)" }, -- PSE (shouting, no words you'd catch)
} })
S("city.radio", { vol = 0.45, pitch = { 0.95, 1.08 }, range = 90, v = {
	{ 9120456889, "Walkie Talkie 12 (SFX)" }, -- PSE (squelch and beeps, no voices)
	{ 9120458059, "Walkie Talkie 5 (SFX)" }, -- PSE
	{ 9120456673, "Walkie Talkie 7 (SFX)" }, -- PSE
	{ 9118027586, "Radio Static 9 (SFX)" }, -- PSE
} })
S("city.beep", { vol = 0.4, pitch = { 0.95, 1.1 }, range = 80, v = {
	{ 9118777437, "Scanner Beeps 10 (SFX)" }, -- PSE
	{ 9117060349, "Nasa Transmission Beep 2 (SFX)" }, -- PSE
	{ 12221990, "electronicpingshort.wav" }, -- Roblox
} })
S("city.brake", { vol = 0.7, pitch = { 0.95, 1.05 }, range = 200, min = 20, prio = 3, life = 5, v = {
	{ 9126104015, "Tire Chirp Engine Car In Short Punchy Skids  (SFX)" }, -- PSE
	{ 9126103903, "Tire Chirp Engine Car In Short Punchy Skids  (SFX)" }, -- PSE
} })
S("city.door", { vol = 0.5, pitch = { 0.95, 1.05 }, range = 90, v = {
	{ 9112968542, "1973 Dodge Tradesman Van 6 (SFX)" }, -- PSE
} })
S("city.jingle", { vol = 0.4, pitch = { 1.0, 1.2 }, range = 70, v = {
	{ 9113849492, "Coins Or Keys Jingle 6 (SFX)" }, -- PSE
} })

-- ·· cinematic (the opening, the title) ··
S("cine.boom", { vol = 0.9, pitch = { 0.95, 1.02 }, range = 300, prio = 3, life = 7, v = {
	{ 9125484367, "Deep Hits Big Reverberant Booms Rumbling Tai (SFX)" }, -- PSE
	{ 9125404320, "Boom Impact Deep Distant Thumping Hits Boomi (SFX)" }, -- PSE
} })
S("cine.whomp", { vol = 0.55, pitch = { 0.95, 1.05 }, range = 200, max = 6, v = {
	{ 9119882039, "Synth Whomps 38 (SFX)" }, -- PSE
	{ 9119880580, "Synth Whomps 17 (SFX)" }, -- PSE
} })
S("cine.shimmer", { vol = 0.5, pitch = { 0.98, 1.05 }, range = 200, life = 6, v = {
	{ 9116420445, "Magic Tone Tonal Shimmer Shaking Rattle 1 (SFX)" }, -- PSE
} })
S("cine.gong", { vol = 0.35, pitch = { 0.95, 1.0 }, range = 300, life = 10, v = {
	{ 9114630316, "Gong Hit Resonant Trail 1 (SFX)" }, -- PSE
} })
S("cine.tunnel", { vol = 0.6, pitch = { 1.0, 1.08 }, range = 200, prio = 1, v = {
	{ 15675021174, "Roblox_UI_Loop_Air_Whooshes" }, -- Roblox (loops)
} })
S("cine.whiteout", { vol = 0.7, pitch = { 0.98, 1.02 }, range = 300, prio = 3, life = 8, v = {
	{ 9114364773, "Extended Reverse Suck 8 (SFX)" }, -- PSE
} })
S("cine.zoom", { vol = 0.55, pitch = { 1.0, 1.1 }, range = 200, life = 5, v = {
	{ 9113168250, "Arrow Pass Bys Zooming Past 10 (SFX)" }, -- PSE
} })
S("cine.meteor", { vol = 0.6, pitch = { 0.85, 1.05 }, range = 600, min = 60, max = 6, life = 7, v = {
	{ 12222095, "Rocket whoosh 01.wav" }, -- Roblox
	{ 9114428748, "Fireball Burning Whoosh By 2 (SFX)" }, -- PSE
} })
S("cine.impact", { vol = 0.7, pitch = { 0.85, 1.05 }, range = 600, min = 60, max = 6, life = 5, v = {
	{ "rbxasset://sounds/impact_explosion_03.mp3", "impact_explosion_03.mp3" }, -- built in
} })
S("cine.roar", { vol = 0.85, pitch = { 0.8, 0.9 }, range = 300, min = 30, prio = 3, v = {
	{ 9116302511, "Lion Roar Short Blast Attack Angry Sharp 4 (SFX)" }, -- PSE
} })
S("wind.night", { vol = 0.35, pitch = { 0.95, 1.02 }, range = 400, min = 60, prio = 1, v = {
	{ 9114228774, "Eerie Wind Constant 1 (SFX)" }, -- PSE (loops: the night over the city)
} })
S("car.approach", { vol = 0.6, pitch = { 0.95, 1.05 }, range = 260, min = 20, cut = 3.4, v = {
	{ 9125349932, "2001 Volkswagen Beetle Second Gear Approach  (SFX)" }, -- PSE (cut short: a vehicle pulling up)
} })
S("steps.march", { vol = 0.5, pitch = { 0.92, 1.0 }, range = 120, min = 10, prio = 1, v = {
	{ "rbxasset://sounds/action_footsteps_plastic.mp3", "action_footsteps_plastic.mp3" }, -- built in (loops)
} })
WorldSfx.SOUNDS = SOUNDS

-- ── cues: what each call plays (layers of sounds) ───────────────────────────
-- a layer: { "sound", vol?, pitch?, delay?, chance? }  (vol and pitch multiply the sound's own)
local CUES: { [string]: any } = {}
WorldSfx.CUES = CUES
local function C(name: string, layers: any)
	CUES[name] = layers
end

-- ·· weapons: a category per family (Hunter/Weapons.FAMILIES); unknown families fall back by
-- their swing style (fx), then their class, then a word in their name ··
WorldSfx.WEAPON_CATEGORY = {
	sword = "blade", katana = "blade", odachi = "blade", twinswords = "blade", dagger = "blade", daggers = "blade",
	greatsword = "heavy", cleaver = "heavy", scythe = "heavy", axe = "heavy", axes = "heavy", greataxe = "heavy",
	halberd = "heavy", glaive = "heavy",
	spear = "thrust", trident = "thrust", lance = "thrust", rapier = "thrust", sai = "thrust",
	warhammer = "blunt", hammer = "blunt", mace = "blunt", flail = "blunt",
	bow = "bow", longbow = "bow", crossbow = "crossbow", arbalest = "crossbow",
	javelin = "thrown", kunai = "thrown", chakram = "thrown",
	whip = "chain", chainblade = "chain", kusarigama = "chain",
	staff = "staff", wand = "staff", orb = "staff", crystal = "staff", tome = "staff", codex = "staff", tablet = "staff",
	warfan = "fan",
	censer = "holy", thurible = "holy", bell = "holy", rod = "holy", scepter = "holy", crescent = "holy",
	gauntlets = "fist", claws = "claw", katar = "claw",
	shield = "shield", buckler = "shield", towershield = "shield",
}
local STYLE_CATEGORY = {
	slash = "blade", smash = "blunt", thrust = "thrust", shot = "bow", throw = "thrown", spell = "staff",
	gust = "fan", heal = "holy", punch = "fist", lash = "chain", bash = "shield",
}
local CLASS_CATEGORY = { fighter = "blade", tanker = "shield", assassin = "blade", ranger = "bow", mage = "staff", healer = "holy" }
local WORD_CATEGORY = { -- (in order: the first word found in an unknown family's id decides)
	{ "crossbow", "crossbow" }, { "bow", "bow" }, { "shield", "shield" }, { "hammer", "blunt" }, { "mace", "blunt" },
	{ "maul", "blunt" }, { "club", "blunt" }, { "axe", "heavy" }, { "great", "heavy" }, { "scythe", "heavy" },
	{ "spear", "thrust" }, { "lance", "thrust" }, { "pike", "thrust" }, { "rapier", "thrust" }, { "whip", "chain" },
	{ "chain", "chain" }, { "knife", "thrown" }, { "star", "thrown" }, { "staff", "staff" }, { "wand", "staff" },
	{ "orb", "staff" }, { "book", "staff" }, { "fan", "fan" }, { "bell", "holy" }, { "lantern", "holy" },
	{ "fist", "fist" }, { "glove", "fist" }, { "claw", "claw" }, { "blade", "blade" }, { "sword", "blade" },
}
WorldSfx.WEAPON_CATEGORIES = { "blade", "heavy", "thrust", "blunt", "bow", "crossbow", "thrown", "chain", "staff", "fan", "holy", "fist", "claw", "shield" }
WorldSfx.WEAPON_EVENTS = { "swing", "hit", "equip", "crit" }

C("weapon.blade.swing", { { "blade.swish" }, { "thrust.swish", 0.3, 1.1, 0, 0.4 } })
C("weapon.blade.hit", { { "blade.hit" }, { "blade.swish", 0.25, 1.25, 0, 0.5 } })
C("weapon.blade.equip", { { "blade.draw" } })
C("weapon.heavy.swing", { { "heavy.whoosh" }, { "blade.swish", 0.35, 0.8 } })
C("weapon.heavy.hit", { { "heavy.hit" }, { "blunt.hit", 0.45, 0.85, 0.01 }, { "earth.crack", 0.25, 1, 0.02, 0.5 } })
C("weapon.heavy.equip", { { "blade.draw", 0.9, 0.82 }, { "armor.rattle", 0.6 } })
C("weapon.thrust.swing", { { "thrust.swish" } })
C("weapon.thrust.hit", { { "thrust.hit" }, { "blade.hit", 0.35, 1.2, 0, 0.6 } })
C("weapon.thrust.equip", { { "equip.gear" }, { "armor.rattle", 0.5, 1.1 } })
C("weapon.blunt.swing", { { "blunt.whoosh" } })
C("weapon.blunt.hit", { { "blunt.hit" }, { "earth.crack", 0.3, 1.05, 0.01, 0.4 } })
C("weapon.blunt.equip", { { "equip.gear", 1, 0.9 }, { "armor.rattle", 0.7, 0.9 } })
C("weapon.bow.swing", { { "bow.draw", 0.8 }, { "bow.release", 1, 1, 0.07 } })
C("weapon.bow.hit", { { "arrow.hit" } })
C("weapon.bow.equip", { { "bow.draw", 0.7, 1.1 } })
C("weapon.crossbow.swing", { { "crossbow.fire" }, { "bow.release", 0.5, 1.15, 0.03 } })
C("weapon.crossbow.hit", { { "bolt.hit" } })
C("weapon.crossbow.equip", { { "equip.gear" }, { "crossbow.fire", 0.25, 1.3 } })
C("weapon.thrown.swing", { { "thrown.whoosh" } })
C("weapon.thrown.hit", { { "knife.hit" } })
C("weapon.thrown.equip", { { "equip.gear", 1, 1.1 } })
C("weapon.chain.swing", { { "whip.crack" }, { "chain.rattle", 0.7 } })
C("weapon.chain.hit", { { "whip.hit" } })
C("weapon.chain.equip", { { "chain.rattle" } })
C("weapon.staff.swing", { { "spell.whoosh" } })
C("weapon.staff.hit", { { "spell.hit" } })
C("weapon.staff.equip", { { "arcane.morph", 0.6 }, { "equip.gear", 0.6 } })
C("weapon.fan.swing", { { "wind.burst", 0.8 }, { "spell.whoosh", 0.35, 1.1 } })
C("weapon.fan.hit", { { "wind.burst", 0.6, 1.15 } })
C("weapon.fan.equip", { { "spell.whoosh", 0.6 } })
C("weapon.holy.swing", { { "bell.chime" }, { "spell.whoosh", 0.3, 1.1 } })
C("weapon.holy.hit", { { "bell.hit" }, { "holy.chime", 0.35, 1.1 } })
C("weapon.holy.equip", { { "bell.chime", 0.8, 1.1 } })
C("weapon.fist.swing", { { "fist.whoosh" } })
C("weapon.fist.hit", { { "fist.hit" } })
C("weapon.fist.equip", { { "equip.gear" }, { "armor.rattle", 0.5 } })
C("weapon.claw.swing", { { "fist.whoosh", 1, 1.15 }, { "blade.swish", 0.5, 1.25 } })
C("weapon.claw.hit", { { "blade.hit", 0.8, 1.2 }, { "fist.hit", 0.5, 1.1 } })
C("weapon.claw.equip", { { "blade.draw", 0.7, 1.25 } })
C("weapon.shield.swing", { { "fist.whoosh", 1, 0.82 }, { "armor.rattle", 0.5 } })
C("weapon.shield.hit", { { "shield.hit" } })
C("weapon.shield.equip", { { "armor.rattle" }, { "shield.hit", 0.3, 1.1 } })

-- ·· magic: every element has the nine shapes (missing ones fall back: see SHAPE_FALLBACK) ··
WorldSfx.ELEMENTS = { "fire", "frost", "lightning", "wind", "earth", "water", "holy", "void", "venom", "arcane", "healing", "sonic", "physical" }
WorldSfx.SHAPES = { "charge", "cast", "projectile", "impact", "explosion", "nova", "beam", "buff", "heal" }
local ELEMENT_ALIAS = {
	ice = "frost", cold = "frost", electric = "lightning", thunder = "lightning", storm = "lightning",
	air = "wind", rock = "earth", stone = "earth", light = "holy", radiant = "holy", shadow = "void",
	dark = "void", poison = "venom", acid = "venom", mana = "arcane", none = "arcane", magic = "arcane",
	life = "healing", heal = "healing", nature = "healing", sound = "sonic", steel = "physical",
}
WorldSfx.ELEMENT_ALIAS = ELEMENT_ALIAS
-- every SkillFx shape (Abilities.SHAPES) onto the nine, plus a few kinds of their own
local SHAPE_ALIAS = {
	gather = "charge", channel = "charge", release = "cast",
	volley = "projectile", bolt = "projectile", missile = "projectile",
	wave = "beam", lance = "beam", chain = "beam", ray = "beam",
	spikes = "impact", strike = "impact", pillar = "impact", smite = "impact", hit = "impact",
	meteor = "explosion", implode = "explosion", eruption = "explosion", blast = "explosion",
	shockwave = "nova", cone = "nova", burst = "nova",
	rain = "zone", field = "zone", storm = "zone", orbit = "zone",
	wall = "shield", dome = "shield", ward = "shield",
	aura = "buff", haste = "buff",
	motes = "heal", renew = "heal", cleanse = "heal",
	dash = "move", leap = "move", blink = "move",
	construct = "summon",
}
WorldSfx.SHAPE_ALIAS = SHAPE_ALIAS
local SHAPE_FALLBACK = {
	charge = "cast", cast = "impact", projectile = "cast", impact = "cast", explosion = "impact",
	nova = "explosion", beam = "projectile", buff = "cast", heal = "buff",
}
local MAGIC: { [string]: { [string]: any } } = {
	fire = {
		charge = { { "fire.whoosh", 0.6, 0.85 }, { "fire.sizzle", 0.5 } },
		cast = { { "fire.whoosh" } },
		projectile = { { "fire.ball" } },
		impact = { { "fire.burst" }, { "fire.sizzle", 0.4, 1, 0.05, 0.6 } },
		explosion = { { "fire.explode" }, { "fire.burst", 0.5, 0.85, 0.02 } },
		nova = { { "fire.whoosh", 0.9, 0.8 }, { "fire.explode", 0.7, 1.05, 0.05 } },
		beam = { { "fire.whoosh", 1, 0.9 }, { "fire.ball", 0.5, 1.1 } },
		buff = { { "fire.whoosh", 0.6, 1.1 }, { "buff.up", 0.6 } },
		heal = { { "fire.sizzle", 0.4, 1.2 }, { "heal.sparkle", 0.8 } },
	},
	frost = {
		charge = { { "frost.crackle", 0.8 } },
		cast = { { "frost.chill", 0.8 }, { "spell.whoosh", 0.5, 1.1 } },
		projectile = { { "spell.whoosh", 0.9, 0.95 }, { "frost.crackle", 0.4, 1.2 } },
		impact = { { "frost.shatter" } },
		explosion = { { "frost.shatter", 1, 0.9 }, { "frost.cracks", 0.7, 1, 0.05 } },
		nova = { { "frost.chill" }, { "frost.cracks", 0.8, 1, 0.1 } },
		beam = { { "frost.chill", 0.9 }, { "frost.crackle", 0.5 } },
		buff = { { "frost.crackle", 0.6, 1.2 }, { "buff.up", 0.6 } },
		heal = { { "frost.chill", 0.4, 1.2 }, { "heal.sparkle", 0.8 } },
	},
	lightning = {
		charge = { { "volt.static" } },
		cast = { { "volt.zap" } },
		projectile = { { "volt.whoosh" }, { "volt.zap", 0.4, 1.2 } },
		impact = { { "volt.burst" } },
		explosion = { { "volt.crack" }, { "thunder", 0.7, 1.05, 0.08 } },
		nova = { { "volt.burst", 1, 0.9 }, { "volt.arc", 0.6 } },
		beam = { { "volt.arc" }, { "volt.zap", 0.6 } },
		buff = { { "volt.static", 0.7, 1.2 }, { "buff.up", 0.6 } },
		heal = { { "volt.static", 0.3, 1.3 }, { "heal.sparkle", 0.8 } },
	},
	wind = {
		charge = { { "wind.suck" } },
		cast = { { "wind.burst" } },
		projectile = { { "wind.burst", 0.8, 1.1 }, { "move.whoosh", 0.5 } },
		impact = { { "wind.burst", 1, 0.95 } },
		explosion = { { "wind.big" } },
		nova = { { "wind.big", 0.9, 1.05 } },
		beam = { { "wind.burst", 1, 0.9 }, { "wind.suck", 0.4, 1.2 } },
		buff = { { "move.whoosh", 0.7 }, { "buff.up", 0.6 } },
		heal = { { "wind.suck", 0.4, 1.2 }, { "heal.sparkle", 0.8 } },
	},
	earth = {
		charge = { { "earth.rumble" } },
		cast = { { "earth.scrape" } },
		projectile = { { "heavy.whoosh", 0.8, 0.8 }, { "earth.rumble", 0.4 } },
		impact = { { "earth.crack" } },
		explosion = { { "earth.burst" }, { "earth.crack", 0.5, 0.9, 0.04 } },
		nova = { { "earth.quake" } },
		beam = { { "earth.scrape" }, { "earth.crack", 0.6, 1, 0.08 } },
		buff = { { "earth.rumble", 0.7 }, { "buff.up", 0.6, 0.9 } },
		heal = { { "earth.rumble", 0.3 }, { "heal.sparkle", 0.8 } },
	},
	water = {
		charge = { { "water.bubble" } },
		cast = { { "water.burst" } },
		projectile = { { "water.bubble", 0.8, 0.9 }, { "spell.whoosh", 0.5 } },
		impact = { { "water.splash" } },
		explosion = { { "water.boom" }, { "water.splash", 0.6, 0.9, 0.05 } },
		nova = { { "water.boom", 0.9 }, { "water.flow", 0.5 } },
		beam = { { "water.flow" }, { "water.burst", 0.5 } },
		buff = { { "water.bubble", 0.7, 1.2 }, { "buff.up", 0.6 } },
		heal = { { "water.flow", 0.5, 1.1 }, { "heal.sparkle" } },
	},
	holy = {
		charge = { { "holy.rise" } },
		cast = { { "holy.chime" } },
		projectile = { { "arcane.shimmer", 0.9, 1.1 }, { "holy.ding", 0.4 } },
		impact = { { "holy.ding" }, { "holy.chime", 0.4, 1.1 } },
		explosion = { { "holy.swell" }, { "holy.ding", 0.6, 0.9 } },
		nova = { { "holy.swell", 0.8 }, { "holy.chime", 0.6 } },
		beam = { { "holy.rise", 0.8 }, { "holy.ding", 0.5, 1, 0.1 } },
		buff = { { "holy.chime", 0.8 }, { "buff.up", 0.6 } },
		heal = { { "holy.chime" }, { "heal.sparkle", 0.8 }, { "holy.choir", 0.35, 1, 0.1 } },
	},
	void = {
		charge = { { "void.suck" }, { "void.whisper", 0.5 } },
		cast = { { "void.reverse" } },
		projectile = { { "void.reverse", 0.9, 0.9 }, { "spell.whoosh", 0.4, 0.8 } },
		impact = { { "void.boom" } },
		explosion = { { "void.blast" } },
		nova = { { "void.suck", 0.8, 0.85 }, { "void.blast", 0.8, 1.05, 0.2 } },
		beam = { { "void.reverse" }, { "arcane.beam", 0.6, 0.8 } },
		buff = { { "void.whisper", 0.6 }, { "buff.up", 0.5, 0.85 } },
		heal = { { "void.suck", 0.3, 1.3 }, { "heal.sparkle", 0.7 } },
	},
	venom = {
		charge = { { "venom.bubble" } },
		cast = { { "venom.spray" } },
		projectile = { { "venom.spray", 0.7, 1.15 }, { "spell.whoosh", 0.4 } },
		impact = { { "venom.squish" }, { "venom.bubble", 0.4, 1, 0.05 } },
		explosion = { { "venom.spray" }, { "venom.squish", 0.8, 0.85, 0.04 } },
		nova = { { "venom.spray", 1, 0.85 }, { "venom.bubble", 0.6 } },
		beam = { { "venom.spray" } },
		buff = { { "venom.bubble", 0.7 }, { "buff.up", 0.5 } },
		heal = { { "venom.bubble", 0.4, 1.2 }, { "heal.sparkle", 0.8 } },
	},
	arcane = {
		charge = { { "arcane.rise" } },
		cast = { { "arcane.burst" } },
		projectile = { { "arcane.shimmer" } },
		impact = { { "arcane.burst", 1, 1.05 }, { "magic.poof", 0.4 } },
		explosion = { { "arcane.blast" }, { "arcane.burst", 0.5, 0.85 } },
		nova = { { "arcane.blast", 0.9 }, { "arcane.morph", 0.5 } },
		beam = { { "arcane.beam" } },
		buff = { { "arcane.morph" }, { "buff.up", 0.6 } },
		heal = { { "arcane.morph", 0.5, 1.1 }, { "heal.sparkle", 0.8 } },
	},
	healing = {
		charge = { { "holy.rise", 0.6, 1.1 } },
		cast = { { "bell.chime" } },
		projectile = { { "arcane.shimmer", 0.8, 1.15 } },
		impact = { { "heal.fall" } },
		explosion = { { "heal.sparkle" }, { "holy.chime", 0.6 } },
		nova = { { "heal.sparkle" }, { "heal.aura", 0.7 } },
		beam = { { "arcane.shimmer", 0.8, 1.1 }, { "holy.ding", 0.4 } },
		buff = { { "heal.aura" }, { "buff.up", 0.5, 1.1 } },
		heal = { { "heal.sparkle" }, { "heal.fall", 0.6, 1.05, 0.15 } },
	},
	sonic = { -- (the sound school): air thumps and ringing bells
		charge = { { "bell.chime", 0.6, 0.8 } },
		cast = { { "air.pound", 0.8, 1.1 }, { "bell.hit", 0.4, 0.8 } },
		projectile = { { "air.pound", 0.6, 1.25 }, { "move.whoosh", 0.4 } },
		impact = { { "air.pound" }, { "bell.hit", 0.5, 0.7 } },
		explosion = { { "air.pound", 1, 0.85 }, { "wind.big", 0.5 } },
		nova = { { "air.pound", 1, 0.9 }, { "bell.chime", 0.5, 0.75 } },
		beam = { { "arcane.beam", 0.8, 1.2 }, { "bell.hit", 0.4 } },
		buff = { { "bell.chime" }, { "buff.up", 0.5 } },
		heal = { { "bell.chime", 0.6, 1.15 }, { "heal.sparkle", 0.7 } },
	},
	physical = { -- (steel: the arts of the blade, spear, fist and shield)
		charge = { { "blade.draw", 0.6 } },
		cast = { { "blade.swish" } },
		projectile = { { "thrown.whoosh" } },
		impact = { { "blade.hit" } },
		explosion = { { "heavy.hit" }, { "earth.crack", 0.6 } },
		nova = { { "heavy.whoosh" }, { "air.pound", 0.7 } },
		beam = { { "thrust.swish" }, { "thrust.hit", 0.5, 1, 0.1 } },
		buff = { { "armor.rattle" }, { "buff.up", 0.6 } },
		heal = { { "heal.fall", 0.6 } },
	},
}
WorldSfx.MAGIC = MAGIC
-- kinds of move that sound alike whatever the element (the element's own layer is added on top)
local MAGIC_KIND: { [string]: any } = {
	zone = { { "@nova", 0.6 }, { "@charge", 0.4 } },
	shield = { { "air.pound", 0.5, 1.1 }, { "@buff" } },
	move = { { "move.whoosh" }, { "@cast", 0.4 } },
	summon = { { "@charge" }, { "arcane.morph", 0.6 }, { "@impact", 0.6, 1, 0.3 } },
	taunt = { { "air.pound" }, { "shield.hit", 0.6, 0.95 } },
	curse = { { "void.whisper", 0.6 }, { "@cast" } },
	slash = { { "blade.swish" }, { "@impact", 0.45 } },
	tick = { { "@impact", 0.5 } },
}

-- ·· monsters ··
WorldSfx.MONSTER_FAMILIES = { "goblinoid", "orc", "elf", "dwarf", "giant", "beast", "insect", "spider", "reptile", "undead", "demon", "golem", "elemental", "slime", "flier", "dragon", "plant", "aquatic", "default" }
WorldSfx.MONSTER_EVENTS = { "aggro", "attack", "hurt", "death" }
local MONSTER: { [string]: { [string]: any } } = {
	goblinoid = {
		aggro = { { "goblin.growl" } }, attack = { { "goblin.stutter" } }, hurt = { { "goblin.hurt" } },
		death = { { "goblin.croak", 0.9, 1.08 } },
	},
	orc = {
		aggro = { { "orc.growl" } }, attack = { { "orc.attack" }, { "heavy.whoosh", 0.35, 0.9, 0.05 } },
		hurt = { { "orc.groan" } }, death = { { "orc.groan", 1, 0.82 }, { "orc.growl", 0.4, 0.72, 0.12 } },
	},
	elf = {
		aggro = { { "humanoid.hiss", 0.9, 1.15 } }, attack = { { "humanoid.grunt", 1, 1.15 }, { "spell.whoosh", 0.4, 1.1 } },
		hurt = { { "humanoid.hurt", 1, 1.15 } }, death = { { "ghost.exhale", 0.6, 1.2 }, { "heal.fall", 0.4, 0.9, 0.1 } },
	},
	dwarf = {
		aggro = { { "humanoid.grunt", 1, 0.85 } }, attack = { { "humanoid.grunt", 1, 0.88 }, { "blunt.whoosh", 0.45 } },
		hurt = { { "humanoid.hurt", 1, 0.85 } }, death = { { "orc.groan", 0.7, 1.15 }, { "armor.rattle", 0.6, 0.9, 0.1 } },
	},
	giant = {
		aggro = { { "giant.voice" }, { "giant.step", 0.6, 1, 0.1 } },
		attack = { { "giant.voice", 0.7, 1.05 }, { "heavy.whoosh", 0.6, 0.7 }, { "giant.step", 0.8, 1, 0.15 } },
		hurt = { { "orc.attack", 0.9, 0.72 } },
		death = { { "giant.voice", 1, 0.85 }, { "cine.boom", 0.6, 1, 0.45 }, { "earth.burst", 0.4, 1, 0.5 } },
		step = { { "giant.step" } },
	},
	beast = {
		aggro = { { "beast.growl" } }, attack = { { "beast.attack" } }, hurt = { { "beast.hurt" } }, death = { { "beast.die" } },
	},
	insect = {
		aggro = { { "insect.buzz" } }, attack = { { "insect.munch" }, { "insect.click", 0.6 } },
		hurt = { { "insect.hurt" }, { "insect.click", 0.5, 1.1 } },
		death = { { "insect.click", 0.8, 0.8 }, { "slime.splat", 0.4 }, { "insect.hurt", 0.6, 0.75, 0.05 } },
	},
	spider = {
		aggro = { { "spider.hiss" } }, attack = { { "spider.attack" } }, hurt = { { "spider.hurt" } },
		death = { { "spider.screech", 1, 0.88 } },
	},
	reptile = {
		aggro = { { "reptile.hiss" } }, attack = { { "reptile.attack" } }, hurt = { { "reptile.hurt", 0.8 } },
		death = { { "reptile.die" } },
	},
	undead = {
		aggro = { { "undead.whisper" } }, attack = { { "undead.attack" }, { "void.reverse", 0.4 } },
		hurt = { { "undead.wail", 0.7 } }, death = { { "ghost.exhale" }, { "void.suck", 0.5, 1, 0.1 } },
	},
	demon = {
		aggro = { { "demon.growl" }, { "void.whisper", 0.4 } }, attack = { { "demon.blast" }, { "demon.growl", 0.5 } },
		hurt = { { "demon.voice" } }, death = { { "demon.die" }, { "void.boom", 0.5, 1, 0.1 } },
	},
	golem = {
		aggro = { { "golem.roar" }, { "golem.grind", 0.6 } }, attack = { { "golem.smash" }, { "earth.crack", 0.5, 0.9, 0.03 } },
		hurt = { { "golem.crack" } }, death = { { "golem.crumble" }, { "cine.boom", 0.45, 1.05, 0.2 } },
		step = { { "giant.step", 0.7, 0.9 }, { "golem.grind", 0.3 } },
	},
	elemental = { -- (an elemental also gets its element's magic on top: opts.element)
		aggro = { { "elemental.presence" } }, attack = { { "arcane.burst", 0.6, 0.9 } }, hurt = { { "magic.poof" } },
		death = { { "arcane.blast", 0.8 }, { "heal.fall", 0.4, 0.8, 0.2 } },
	},
	slime = {
		aggro = { { "slime.squelch", 1, 0.9 } }, attack = { { "slime.squelch" }, { "slime.splat", 0.6 } },
		hurt = { { "slime.squelch", 0.9, 1.2 } }, death = { { "slime.goo" }, { "slime.splat", 0.8, 0.9, 0.05 } },
	},
	flier = {
		aggro = { { "flier.screech" } }, attack = { { "flier.flap" }, { "flier.screech", 0.5, 1.1 } },
		hurt = { { "flier.hurt" } }, death = { { "flier.hurt", 1, 0.8 }, { "flier.flap", 0.5, 0.9 } },
		step = { { "flier.flap", 0.6 } },
	},
	dragon = {
		aggro = { { "dragon.roar" } }, attack = { { "dragon.growl" }, { "heavy.whoosh", 0.5, 0.6 } },
		hurt = { { "dragon.wail", 0.8, 1.1 } }, death = { { "dragon.wail", 1, 0.85 }, { "cine.boom", 0.6, 1, 0.6 } },
		step = { { "dragon.step" } },
	},
	plant = {
		aggro = { { "plant.rustle" } }, attack = { { "plant.creak" }, { "whip.crack", 0.5, 0.8 } },
		hurt = { { "plant.snap" } }, death = { { "plant.splinter" }, { "plant.rustle", 0.5, 0.9, 0.1 } },
	},
	aquatic = {
		aggro = { { "aquatic.whale" } }, attack = { { "aquatic.hiss" }, { "water.splash", 0.6 } },
		hurt = { { "aquatic.water" } }, death = { { "aquatic.whale", 1, 0.8 }, { "water.splash", 0.6, 0.9, 0.1 } },
	},
	default = {
		aggro = { { "monster.growl" } }, attack = { { "monster.vocal" } }, hurt = { { "monster.growl", 0.9, 1.15 } },
		death = { { "monster.die" } },
	},
}
WorldSfx.MONSTER = MONSTER
local MONSTER_EVENT_ALIAS = { spot = "aggro", notice = "aggro", roar = "aggro", strike = "attack", swing = "attack", hit = "hurt", die = "death", dead = "death", kill = "death", walk = "step" }
-- the live city's monster kinds (Hunter/Monsters.DEFS); new kinds are placed by a `family` field
-- if they have one, then by words in their id or name, then by their gait
WorldSfx.KIND_FAMILY = {
	goblin = "goblinoid", hobgoblin = "goblinoid", giant_rat = "beast", cave_bat = "flier", slime = "slime",
	beetle = "insect", spider = "spider", dire_wolf = "beast", orc = "orc", lizardman = "reptile", troll = "giant",
	naga = "reptile", ice_bear = "beast", ogre = "giant", wraith = "undead", iron_golem = "golem", warlord = "orc",
	stone_golem = "golem", wyvern = "dragon", minotaur = "beast", dragonkin = "dragon", colossus = "golem",
	abyss_serpent = "aquatic", hollow_king = "undead",
}
local FAMILY_WORDS = {
	{ "goblin", "goblinoid" }, { "kobold", "goblinoid" }, { "gremlin", "goblinoid" }, { "orc", "orc" }, { "elf", "elf" },
	{ "elv", "elf" }, { "dwar", "dwarf" }, { "troll", "giant" }, { "ogre", "giant" },
	{ "cyclop", "giant" }, { "dragon", "dragon" }, { "drake", "dragon" }, { "wyvern", "dragon" },
	{ "wyrm", "dragon" }, { "golem", "golem" }, { "colossus", "golem" }, { "gargoyle", "golem" }, { "statue", "golem" },
	{ "construct", "golem" }, { "elemental", "elemental" }, { "spirit", "elemental" }, { "wisp", "elemental" },
	{ "slime", "slime" }, { "ooze", "slime" }, { "jelly", "slime" }, { "spider", "spider" }, { "arachn", "spider" },
	{ "scorpion", "spider" }, { "beetle", "insect" }, { "ant", "insect" }, { "wasp", "insect" }, { "bee", "insect" },
	{ "mantis", "insect" }, { "centipede", "insect" }, { "locust", "insect" }, { "insect", "insect" },
	{ "serpent", "aquatic" }, { "kraken", "aquatic" }, { "shark", "aquatic" }, { "squid", "aquatic" }, { "crab", "aquatic" },
	{ "fish", "aquatic" }, { "naga", "reptile" }, { "lizard", "reptile" }, { "snake", "reptile" }, { "basilisk", "reptile" },
	{ "croc", "reptile" }, { "wraith", "undead" }, { "ghost", "undead" }, { "skelet", "undead" }, { "lich", "undead" },
	{ "ghoul", "undead" }, { "specter", "undead" }, { "spectre", "undead" }, { "revenant", "undead" }, { "hollow", "undead" },
	{ "demon", "demon" }, { "imp", "demon" }, { "fiend", "demon" }, { "devil", "demon" }, { "bat", "flier" },
	{ "harpy", "flier" }, { "bird", "flier" }, { "griffin", "flier" }, { "gryphon", "flier" }, { "raven", "flier" },
	{ "treant", "plant" }, { "plant", "plant" }, { "vine", "plant" }, { "mandrake", "plant" }, { "fung", "plant" },
	{ "wolf", "beast" }, { "bear", "beast" }, { "rat", "beast" }, { "boar", "beast" }, { "hound", "beast" },
	{ "lion", "beast" }, { "tiger", "beast" }, { "minotaur", "beast" }, { "beast", "beast" },
	-- (last: "giant" and "titan" are as often a size as a kind: a giant spider is a spider)
	{ "giant", "giant" }, { "titan", "giant" },
}
local GAIT_FAMILY = { flyer = "flier", blob = "slime", golem = "golem", spider = "spider", crawler = "insect", serpent = "reptile", float = "undead", quad = "beast" }

-- ·· Gates and the city ··
C("gate.hum", { { "gate.hum" } })
C("gate.open", { { "gate.open" }, { "gate.swoosh", 0.6, 1, 0.05 }, { "wind.big", 0.5, 0.85, 0.35 } })
C("gate.surge", { { "gate.whomp" }, { "wind.big", 0.45, 0.8, 0.02 } })
C("gate.break", { { "gate.quake" }, { "void.blast", 0.7, 0.9, 0.05 }, { "frost.shatter", 0.45, 0.62, 0.02 } })
C("gate.close", { { "gate.suck" }, { "gate.down", 0.5, 1, 0.4 } })
C("gate.red", { { "gate.alarm" }, { "void.boom", 0.6, 0.85, 0.05 } })
C("gate.redDrone", { { "gate.red" } })
C("gate.enter", { { "void.reverse", 0.7, 1.05 }, { "arcane.morph", 0.5, 0.9 } })
C("gate.measure", { { "city.beep" }, { "city.beep", 0.6, 1.25, 0.18 } })
C("city.siren", { { "city.siren" } })
C("city.sirenBlip", { { "city.blat" } })
C("city.panic", { { "city.panic" } })
C("city.crowd", { { "city.crowd" }, { "city.panic", 0.5, 1, 0.4, 0.6 } })
C("city.radio", { { "city.radio" } })
C("city.beep", { { "city.beep" } })
C("city.brake", { { "city.brake" } })
C("city.door", { { "city.door" } })
C("city.crystal", { { "holy.ding", 0.5, 1.2 }, { "city.jingle", 0.6, 1.1, 0.04 } })
-- short names (the opening and the title call these)
C("nightWind", { { "wind.night" } })
C("lightning", { { "volt.crack" }, { "volt.burst", 0.6, 0.9, 0.02 } })
C("meteor", { { "cine.meteor" } })
C("meteorImpact", { { "cine.impact" }, { "earth.crack", 0.5, 0.85, 0.03 } })
C("debris", { { "earth.burst", 0.8 }, { "earth.crack", 0.6, 1, 0.05 } })
C("rumble", { { "earth.quake", 0.9 }, { "gate.whomp", 0.5, 0.8 } })
C("vanArrive", { { "car.approach" } })
C("march", { { "steps.march" } })
C("vanish", { { "magic.poof" }, { "move.whoosh", 0.7, 0.9 } })
C("blink", { { "move.whoosh", 0.9, 1.1 }, { "arcane.morph", 0.4, 1.2 } })
C("whoosh", { { "heavy.whoosh" } })
C("tunnel", { { "cine.tunnel" } })
C("taunt", { { "air.pound" }, { "shield.hit", 0.6, 0.95 }, { "orc.growl", 0.25, 1.3, 0.05 } })
C("titleSlam", { { "cine.boom" }, { "cine.gong", 0.6, 1, 0.05 } })
WorldSfx.GATE_EVENTS = { "hum", "open", "surge", "break", "close", "red", "redDrone", "enter", "measure" }
WorldSfx.CITY_EVENTS = { "siren", "sirenBlip", "panic", "crowd", "radio", "beep", "brake", "door", "crystal" }
local LOOPING = {
	["gate.hum"] = true, ["gate.redDrone"] = true, ["city.siren"] = true, ["gate.red"] = true, ["cine.tunnel"] = true,
	nightWind = true, march = true, tunnel = true, ["wind.night"] = true, ["steps.march"] = true,
}

-- ── the engine ──────────────────────────────────────────────────────────────
local started = false
local group: any = nil
local anchor: any = nil
local active: { any } = {}
local perName: { [string]: number } = {}
local lastAt: { [string]: number } = {}
local lastVariant: { [string]: number } = {}
local sfxModule: any = nil
local rng = Random.new()

local function service(name: string): any
	local ok, s = pcall(function()
		return game:GetService(name)
	end)
	return if ok then s else nil
end

local function now(): number
	return os.clock()
end

-- client/Sfx: the effects-volume setting and the legacy-id map (loaded once, if it's there)
local function sfx(): any?
	if sfxModule == nil then
		sfxModule = false
		pcall(function()
			local here = (script :: any).Parent
			local m = here and here:FindFirstChild("Sfx")
			if m then
				sfxModule = require(m :: any)
			end
		end)
	end
	return if sfxModule then sfxModule else nil
end

local function effectsVolume(): number
	local S = sfx()
	if S and S.getVolume then
		local ok, v = pcall(S.getVolume)
		if ok and type(v) == "number" then
			return v
		end
	end
	return 0.8
end

local function applyLevel()
	if group then
		pcall(function()
			group.Volume = WorldSfx.GAIN * math.clamp(effectsVolume() / 0.8, 0, 1.25)
		end)
	end
end

-- the files the Roblox client ships today under content/sounds (rbxManifest.txt, client 0.748)
WorldSfx.BUILT_IN = {
	"action_falling.ogg", "action_footsteps_plastic.mp3", "action_get_up.mp3", "action_jump.mp3", "action_jump_land.mp3",
	"action_swim.mp3", "impact_explosion_03.mp3", "impact_water.mp3", "oof.ogg", "ouch.ogg", "volume_slider.ogg",
}
-- the client's older sound files, no longer shipped, and Roblox's own 2009 uploads of the same
-- files (creator Roblox, user 1; each asset's description is its old path, "\sounds\<file>")
WorldSfx.LEGACY_ID = {
	["swordslash.wav"] = 12222216, ["swordlunge.wav"] = 12222208, ["unsheath.wav"] = 12222225,
	["electronicpingshort.wav"] = 12221990, ["collide.wav"] = 12221984, ["hit.wav"] = 12222046,
	["swoosh.wav"] = 12222200, ["glassbreak.wav"] = 12222005, ["halloweenthunder.wav"] = 12222030,
	["halloweenlightning.wav"] = 12222019, ["rocket whoosh 01.wav"] = 12222095, ["button.wav"] = 12221967,
	["clickfast.wav"] = 12221976, ["switch.wav"] = 12222170, ["snap.wav"] = 12222140, ["splat.wav"] = 12222152,
	["pageturn.wav"] = 12222076, ["victory.wav"] = 12222253, ["bass.wav"] = 12221944, ["flashbulb.wav"] = 12221996,
	["kerplunk.wav"] = 12222054,
}

-- an id as a SoundId: numbers, "rbxassetid://", "rbxasset://"; the client's old sound files
-- that no longer ship become Roblox's own uploads of them
function WorldSfx.resolveId(raw: any): string?
	if type(raw) == "string" then
		local file = string.match(string.lower(raw), "^rbxasset://sounds/(.+)$")
		if file and WorldSfx.LEGACY_ID[file] then
			return "rbxassetid://" .. tostring(WorldSfx.LEGACY_ID[file])
		end
	end
	local S = sfx()
	local resolve = S and (S.resolveId or S.soundId)
	if resolve then
		local ok, id = pcall(resolve, raw)
		if ok and type(id) == "string" then
			return id
		end
	end
	if type(raw) == "number" then
		return "rbxassetid://" .. tostring(raw)
	elseif type(raw) == "string" and raw ~= "" then
		return if string.match(raw, "^%d+$") then "rbxassetid://" .. raw else raw
	end
	return nil
end

function WorldSfx.start()
	if started then
		return
	end
	started = true
	pcall(function()
		local ss = service("SoundService")
		local g = Instance.new("SoundGroup")
		g.Name = "BitLevelingWorld"
		g.Volume = 0.6
		pcall(function()
			local comp = Instance.new("CompressorSoundEffect")
			comp.Threshold = -16
			comp.Ratio = 2.5
			comp.Attack = 0.005
			comp.Release = 0.15
			comp.GainMakeup = 2
			comp.Parent = g
			local eq = Instance.new("EqualizerSoundEffect")
			eq.LowGain = 2
			eq.MidGain = 0
			eq.HighGain = 0.5
			eq.Parent = g
		end)
		g.Parent = ss
		group = g
	end)
	applyLevel()
	local S = sfx()
	if S and S.onVolume then
		pcall(S.onVolume, applyLevel)
	end
	-- load the sounds of a fight in the background, so the first swing isn't silent
	task.spawn(function()
		pcall(function()
			local cp = service("ContentProvider")
			local list = {}
			for _, name in { "blade.swish", "blade.hit", "heavy.whoosh", "heavy.hit", "fist.hit", "fist.whoosh", "spell.whoosh", "gate.open", "gate.hum", "city.siren", "fire.burst", "monster.growl" } do
				for _, v in SOUNDS[name].v do
					local s = Instance.new("Sound")
					s.SoundId = WorldSfx.resolveId(v[1]) or ""
					table.insert(list, s)
				end
			end
			if cp and #list > 0 then
				cp:PreloadAsync(list)
			end
		end)
	end)
end

-- where a sound sits: a fresh Attachment at a point (on Terrain, or an invisible anchor at the
-- origin), the part or attachment it was given, or (nil) the group: heard everywhere
local function holderFor(at: any): (any, any) -- (parent, temp-to-destroy)
	if at == nil then
		return group, nil
	end
	local kind = typeof(at)
	if kind == "Instance" then
		if at:IsA("BasePart") or at:IsA("Attachment") then
			return at, nil
		elseif at:IsA("Model") then
			local p = at.PrimaryPart or at:FindFirstChildWhichIsA("BasePart", true)
			if p then
				return p, nil
			end
		end
		return group, nil
	elseif kind == "Vector3" then
		local ws = service("Workspace")
		local base = nil
		pcall(function()
			base = ws:FindFirstChildOfClass("Terrain")
		end)
		if not base then
			if not (anchor and anchor.Parent) then
				local p = Instance.new("Part")
				p.Name = "WorldSfxAnchor"
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = false
				p.CanTouch = false
				p.Transparency = 1
				p.Size = Vector3.new(0.2, 0.2, 0.2)
				p.CFrame = CFrame.new()
				p.Parent = ws
				anchor = p
			end
			base = anchor
		end
		local a = Instance.new("Attachment")
		a.Name = "WorldSfx"
		a.Position = at
		a.Parent = base
		return a, a
	end
	return group, nil
end

local function positionOf(at: any): Vector3?
	local kind = typeof(at)
	if kind == "Vector3" then
		return at
	elseif kind == "Instance" then
		local ok, p = pcall(function()
			if at:IsA("BasePart") then
				return at.Position
			elseif at:IsA("Attachment") then
				return at.WorldPosition
			elseif at:IsA("Model") then
				return at:GetPivot().Position
			end
			return nil
		end)
		return if ok then p else nil
	end
	return nil
end

local function tooFar(at: any, range: number): boolean
	local p = positionOf(at)
	if not p then
		return false
	end
	local ok, far = pcall(function()
		local cam = (service("Workspace") :: any).CurrentCamera
		return cam and (cam.CFrame.Position - p).Magnitude > range * 1.1
	end)
	return ok and far == true
end

local function release(entry: any)
	if entry.gone then
		return
	end
	entry.gone = true
	perName[entry.name] = math.max(0, (perName[entry.name] or 1) - 1)
	local i = table.find(active, entry)
	if i then
		table.remove(active, i)
	end
	pcall(function()
		entry.sound:Destroy()
	end)
	if entry.temp then
		pcall(function()
			entry.temp:Destroy()
		end)
	end
end

-- sounds whose holder went away (a Gate's model destroyed with its hum on it) let go of their place
local function prune()
	for i = #active, 1, -1 do
		local e = active[i]
		local gone = true
		pcall(function()
			gone = e.sound == nil or e.sound.Parent == nil
		end)
		if gone then
			release(e)
		end
	end
end

-- make room: the oldest of the same sound, or the oldest of the least important
local function makeRoom(name: string, def: any): boolean
	prune()
	if (perName[name] or 0) >= (def.max or 4) then
		for _, e in active do
			if e.name == name and not e.loop then
				release(e)
				break
			end
		end
	end
	if #active < WorldSfx.MAX_VOICES then
		return true
	end
	local prio = def.prio or 2
	local victim = nil
	for _, e in active do
		if not e.loop and (e.prio or 2) <= prio and (victim == nil or (e.prio or 2) < (victim.prio or 2) or ((e.prio or 2) == (victim.prio or 2) and e.t < victim.t)) then
			victim = e
		end
	end
	if victim then
		release(victim)
		return true
	end
	return false
end

local function pick(name: string, def: any): any
	local n = #def.v
	if n <= 1 then
		return def.v[1]
	end
	local i = rng:NextInteger(1, n)
	if i == lastVariant[name] then
		i = (i % n) + 1
	end
	lastVariant[name] = i
	return def.v[i]
end

-- one sound, once (or looping); returns its entry
local function playSound(name: string, at: any, vol: number, pitch: number, loop: boolean?, opts: any?): any?
	local def = SOUNDS[name]
	if not def or not WorldSfx.enabled then
		return nil
	end
	WorldSfx.start()
	local t = now()
	if not loop and t - (lastAt[name] or -1) < WorldSfx.GAP then
		WorldSfx.stats.dropped += 1
		return nil
	end
	local range = (opts and type(opts.far) == "number" and opts.far) or def.range or 140
	if not loop and tooFar(at, range) then
		WorldSfx.stats.dropped += 1
		return nil
	end
	if not makeRoom(name, def) then
		WorldSfx.stats.dropped += 1
		return nil
	end
	lastAt[name] = t
	local variant = pick(name, def)
	local id = WorldSfx.resolveId(variant[1])
	if not id then
		return nil
	end
	local entry: any = { name = name, prio = def.prio or 2, t = t, loop = loop == true }
	local ok = pcall(function()
		local parent, temp = holderFor(at)
		entry.temp = temp
		local s = Instance.new("Sound")
		s.Name = name
		s.SoundId = id
		local lo, hi = def.pitch[1], def.pitch[2]
		s.PlaybackSpeed = math.clamp(pitch * (lo + rng:NextNumber() * (hi - lo)), 0.2, 3)
		s.Volume = math.clamp(vol * (def.vol or 0.6) * (0.92 + rng:NextNumber() * 0.16), 0, 3)
		s.Looped = loop == true
		s.RollOffMode = Enum.RollOffMode.InverseTapered
		s.RollOffMinDistance = (opts and type(opts.near) == "number" and opts.near) or def.min or 10
		s.RollOffMaxDistance = range
		pcall(function()
			s.SoundGroup = group
		end)
		s.Parent = parent
		entry.sound = s
		entry.baseVolume = s.Volume
		perName[name] = (perName[name] or 0) + 1
		table.insert(active, entry)
		if loop then
			pcall(function()
				s.AncestryChanged:Connect(function(_, parentNow)
					if parentNow == nil then
						release(entry)
					end
				end)
			end)
		end
		s:Play()
	end)
	if not ok then
		WorldSfx.stats.failed += 1
		if entry.sound then
			release(entry)
		elseif entry.temp then
			pcall(function()
				entry.temp:Destroy()
			end)
		end
		return nil
	end
	WorldSfx.stats.played += 1
	if WorldSfx.onPlay then
		pcall(WorldSfx.onPlay :: any, name, id, at)
	end
	if not loop then
		pcall(function()
			entry.sound.Ended:Once(function()
				release(entry)
			end)
		end)
		task.delay(def.life or 4, function()
			release(entry)
		end)
		if def.cut then
			-- (a long recording used for its first moments: fade it out)
			task.delay(def.cut, function()
				pcall(function()
					if not entry.gone then
						game:GetService("TweenService"):Create(entry.sound, TweenInfo.new(0.5), { Volume = 0 }):Play()
					end
				end)
				task.delay(0.55, function()
					release(entry)
				end)
			end)
		end
	end
	return entry
end

-- the layers of a cue: "@shape" layers stand for the current element's own cue for that shape
local function playLayers(layers: any, at: any, opts: any, element: string?)
	local volume = (opts and opts.volume) or 1
	local pitch = (opts and opts.pitch) or 1
	local delay0 = (opts and opts.delay) or 0
	local any = false
	for _, layer in layers do
		local name, lv, lp, ld, chance = layer[1], layer[2] or 1, layer[3] or 1, layer[4] or 0, layer[5]
		if chance == nil or rng:NextNumber() < chance then
			local function go()
				if string.sub(name, 1, 1) == "@" then
					local sub = WorldSfx.magicCue(element or "arcane", string.sub(name, 2))
					if sub then
						playLayers(sub, at, { volume = volume * lv, pitch = pitch * lp, near = opts and opts.near, far = opts and opts.far })
					end
				else
					playSound(name, at, volume * lv, pitch * lp, nil, opts)
				end
			end
			local d = delay0 + ld
			if d > 0 then
				task.delay(d, go)
			else
				go()
			end
			any = true
		end
	end
	return any
end

-- a one-shot cue again and again for opts.duration seconds (every opts.every, about 1.6 s):
-- a crowd running past, a barrage. Returns a handle with :stop() like a loop's.
local function repeating(layers: any, at: any, opts: any): any
	local handle: any = { stopped = false }
	local every = (opts and opts.every) or 1.6
	local untilT = now() + opts.duration
	local function again()
		if handle.stopped or now() > untilT then
			return
		end
		playLayers(layers, at, opts)
		task.delay(every * (0.8 + rng:NextNumber() * 0.4), again)
	end
	again()
	function handle.stop(_self: any)
		handle.stopped = true
	end
	handle.Destroy = handle.stop
	return handle
end

-- size: a rank (1-6) or a tier, or a power: bigger things are lower and louder
local function sized(opts: any?): (number, number)
	local r = opts and (opts.rank or opts.tier)
	if type(r) ~= "number" and opts and type(opts.power) == "number" then
		r = math.clamp(1 + math.log(math.max(opts.power, 1), 10) * 1.6, 1, 6)
	end
	if type(r) ~= "number" then
		return 1, 1
	end
	r = math.clamp(r, 1, 7)
	return 0.8 + r * 0.06, 1.12 - r * 0.045
end
local function withSize(opts: any?): any
	local v, p = sized(opts)
	local o = table.clone(opts or {})
	o.volume = (o.volume or 1) * v
	o.pitch = (o.pitch or 1) * p
	return o
end

-- ── the calls ───────────────────────────────────────────────────────────────
function WorldSfx.weaponCategory(family: string?, style: string?): string
	local f = if type(family) == "string" then string.lower(family) else ""
	local cat = WorldSfx.WEAPON_CATEGORY[f]
	if cat then
		return cat
	end
	if table.find(WorldSfx.WEAPON_CATEGORIES, f) then
		return f
	end
	if style and STYLE_CATEGORY[style] then
		return STYLE_CATEGORY[style]
	end
	-- the family's own data (Hunter/Weapons), if this client has it
	local ok, def = pcall(function()
		local hunter = service("ReplicatedStorage"):FindFirstChild("LifeSim")
		hunter = hunter and hunter:FindFirstChild("Hunter")
		local m = hunter and hunter:FindFirstChild("Weapons")
		local W = m and require(m :: any)
		return W and W.FAMILIES and W.FAMILIES[f]
	end)
	if ok and type(def) == "table" then
		if def.fx and STYLE_CATEGORY[def.fx] then
			return STYLE_CATEGORY[def.fx]
		elseif def.class and CLASS_CATEGORY[def.class] then
			return CLASS_CATEGORY[def.class]
		end
	end
	for _, w in WORD_CATEGORY do
		if string.find(f, w[1], 1, true) then
			return w[2]
		end
	end
	return "blade"
end

function WorldSfx.weaponCue(family: string?, event: string?, style: string?): any
	local cat = WorldSfx.weaponCategory(family, style)
	local ev = if event == "shot" or event == "fire" or event == "attack" then "swing" elseif event == "impact" or event == "land" then "hit" elseif event == "draw" or event == "unsheath" then "equip" else (event or "swing")
	if ev == "crit" then
		-- a critical blow: the family's own hit, with weight under it
		local hit = CUES["weapon." .. cat .. ".hit"] or CUES["weapon.blade.hit"]
		local out = table.clone(hit)
		table.insert(out, { "heavy.hit", 0.55, 0.85, 0.015 })
		table.insert(out, { "air.pound", 0.45, 1.05, 0.02 })
		return out
	end
	return CUES["weapon." .. cat .. "." .. ev] or CUES["weapon." .. cat .. ".swing"]
end

-- opts: power, stars (3 is a touch brighter), element (adds the element's impact on a hit), style
function WorldSfx.weapon(family: string?, event: string?, at: any?, opts: any?): boolean
	local layers = WorldSfx.weaponCue(family, event, opts and opts.style)
	if not layers then
		return false
	end
	local o = table.clone(opts or {})
	if type(o.power) == "number" then
		o.volume = (o.volume or 1) * math.clamp(0.85 + math.log(math.max(o.power, 1), 10) * 0.08, 0.85, 1.25)
	end
	if o.stars and o.stars >= 3 then
		o.pitch = (o.pitch or 1) * 1.03
	end
	local any = playLayers(layers, at, o)
	if (event == "hit" or event == "impact") and o.element and o.element ~= "none" and o.element ~= "physical" then
		WorldSfx.magic(o.element, "impact", at, { volume = (o.volume or 1) * 0.45, power = o.power })
	end
	return any
end

function WorldSfx.element(element: string?): string
	local e = if type(element) == "string" then string.lower(element) else "arcane"
	e = ELEMENT_ALIAS[e] or e
	return if MAGIC[e] then e else "arcane"
end

function WorldSfx.shape(shape: string?): string
	local s = if type(shape) == "string" then shape else "cast"
	return SHAPE_ALIAS[s] or s
end

-- the layers for an element and a shape (after aliases and fallbacks)
function WorldSfx.magicCue(element: string?, shape: string?): any
	local el = MAGIC[WorldSfx.element(element)]
	local s = WorldSfx.shape(shape)
	if MAGIC_KIND[s] then
		return MAGIC_KIND[s]
	end
	local guard = 0
	while not el[s] and guard < 6 do
		s = SHAPE_FALLBACK[s] or "cast"
		guard += 1
	end
	return el[s] or el.cast
end

-- opts: tier / rank / power (size), volume, pitch
function WorldSfx.magic(element: string?, shape: string?, at: any?, opts: any?): boolean
	local el = WorldSfx.element(element)
	local layers = WorldSfx.magicCue(el, shape)
	if not layers then
		return false
	end
	local o = withSize(opts)
	-- an S-rank impact also shakes the air
	local s = WorldSfx.shape(shape)
	local big = (opts and ((opts.tier or opts.rank or 0) >= 5)) and (s == "impact" or s == "explosion" or s == "nova")
	local any = playLayers(layers, at, o, el)
	if big then
		playSound("air.pound", at, (o.volume or 1) * 0.5, 0.85)
	end
	return any
end

function WorldSfx.monsterFamily(kindOrFamily: any, def: any?, gait: string?): string
	if type(def) == "table" and type(def.family) == "string" and MONSTER[def.family] then
		return def.family
	end
	local k = if type(kindOrFamily) == "string" then string.lower(kindOrFamily) else ""
	if MONSTER[k] then
		return k
	end
	if WorldSfx.KIND_FAMILY[k] then
		return WorldSfx.KIND_FAMILY[k]
	end
	local text = k .. " " .. string.lower(if type(def) == "table" and type(def.name) == "string" then def.name else "")
	for _, w in FAMILY_WORDS do
		-- whole-word-ish: "imp" shouldn't catch "impaler" in a name's middle, "ant" not "giant"
		local i = string.find(text, w[1], 1, true)
		if i and (i == 1 or string.match(string.sub(text, i - 1, i - 1), "[%s_%-]")) then
			return w[2]
		end
	end
	if gait and GAIT_FAMILY[gait] then
		return GAIT_FAMILY[gait]
	end
	return "default"
end

function WorldSfx.monsterCue(family: string?, event: string?): any
	local fam = MONSTER[WorldSfx.monsterFamily(family)] or MONSTER.default
	local ev = MONSTER_EVENT_ALIAS[event or ""] or event or "aggro"
	return fam[ev] or MONSTER.default[ev] or (if ev == "step" then { { "giant.step", 0.4, 1.2 } } else MONSTER.default.aggro)
end

-- opts: rank (1-6), element (for elementals: its magic on top), volume, pitch
function WorldSfx.monster(family: string?, event: string?, at: any?, opts: any?): boolean
	local layers = WorldSfx.monsterCue(family, event)
	local o = withSize(opts)
	local any = playLayers(layers, at, o)
	if WorldSfx.monsterFamily(family) == "elemental" and opts and opts.element then
		local shape = if event == "attack" then "cast" elseif event == "death" then "explosion" elseif event == "hurt" then "impact" else "charge"
		WorldSfx.magic(opts.element, shape, at, { volume = (o.volume or 1) * 0.7, rank = opts.rank })
	end
	return any
end

-- a live monster's model (Kind, Rank and Gait attributes; Hunter/Monsters.build)
function WorldSfx.monsterOf(model: Instance, event: string, opts: any?): boolean
	local kind, rank, gait = nil, nil, nil
	pcall(function()
		kind = model:GetAttribute("Kind")
		rank = model:GetAttribute("Rank")
		gait = model:GetAttribute("Gait")
	end)
	local def = nil
	pcall(function()
		local hunter = service("ReplicatedStorage"):FindFirstChild("LifeSim")
		hunter = hunter and hunter:FindFirstChild("Hunter")
		local m = hunter and hunter:FindFirstChild("Monsters")
		local M = m and require(m :: any)
		def = M and M.DEFS and M.DEFS[kind]
	end)
	local o = table.clone(opts or {})
	o.rank = o.rank or rank
	return WorldSfx.monster(WorldSfx.monsterFamily(kind, def, gait), event, model, o)
end

-- a loop (a Gate's hum, a siren, the red Gate's drone): a handle to stop it
function WorldSfx.loop(name: string, at: any?, opts: any?): any?
	local layers = CUES[name]
	local soundName = if layers then layers[1][1] else name
	if not SOUNDS[soundName] then
		return nil
	end
	local o = withSize(opts)
	local entry = playSound(soundName, at, (o.volume or 1) * ((layers and layers[1][2]) or 1), o.pitch or 1, true, o)
	if not entry then
		return nil
	end
	local s = entry.sound
	local fade = opts and opts.fadeIn
	if fade and fade > 0 then
		pcall(function()
			local target = s.Volume
			s.Volume = 0
			game:GetService("TweenService"):Create(s, TweenInfo.new(fade), { Volume = target }):Play()
		end)
	end
	local handle: any = { sound = s, name = soundName }
	function handle.stop(_self: any, seconds: number?)
		if handle.stopped then
			return
		end
		handle.stopped = true
		local t = if type(_self) == "number" then _self else seconds
		if t and t > 0 then
			pcall(function()
				game:GetService("TweenService"):Create(s, TweenInfo.new(t), { Volume = 0 }):Play()
			end)
			task.delay(t, function()
				release(entry)
			end)
		else
			release(entry)
		end
	end
	handle.Destroy = handle.stop
	function handle.setVolume(_self: any, v: number)
		pcall(function()
			s.Volume = entry.baseVolume * v
		end)
	end
	if opts and type(opts.duration) == "number" and opts.duration > 0 then
		task.delay(opts.duration, function()
			handle:stop(0.6)
		end)
	end
	-- (a caller that wobbles PlaybackSpeed, as the old siren ping did, gets a gentle doppler)
	return setmetatable(handle, {
		__newindex = function(t, k, v)
			if k == "PlaybackSpeed" and type(v) == "number" then
				pcall(function()
					s.PlaybackSpeed = 1 + (v - 0.97) * 0.08
				end)
			else
				rawset(t, k, v)
			end
		end,
	})
end

function WorldSfx.gate(event: string, at: any?, opts: any?): any
	local name = "gate." .. tostring(event)
	if name == "gate.hum" or name == "gate.redDrone" then
		return WorldSfx.loop(name, at, opts)
	end
	local layers = CUES[name]
	if not layers then
		return false
	end
	if opts and type(opts.duration) == "number" then
		return repeating(layers, at, withSize(opts))
	end
	return playLayers(layers, at, withSize(opts))
end

function WorldSfx.city(event: string, at: any?, opts: any?): any
	local name = "city." .. tostring(event)
	if name == "city.siren" then
		return WorldSfx.loop(name, at, opts)
	end
	local layers = CUES[name]
	if not layers then
		return false
	end
	if opts and type(opts.duration) == "number" then
		return repeating(layers, at, opts)
	end
	return playLayers(layers, at, opts)
end

-- anything by name: a sound, a cue, "weapon.<family>.<event>", "magic.<element>.<shape>",
-- "monster.<family>.<event>", "gate.<event>", "city.<event>", or an asset id
function WorldSfx.play(name: any, at: any?, opts: any?): any
	if type(name) == "number" then
		return WorldSfx.playId(name, at, opts)
	end
	if type(name) ~= "string" or name == "" then
		return false
	end
	if string.find(name, "://", 1, true) or string.match(name, "^%d+$") then
		return WorldSfx.playId(name, at, opts)
	end
	-- (a loop hands back its handle, truthy, so a caller can stop it)
	if CUES[name] then
		if LOOPING[name] then
			return WorldSfx.loop(name, at, opts) or false
		end
		if opts and type(opts.duration) == "number" then
			return repeating(CUES[name], at, opts)
		end
		return playLayers(CUES[name], at, opts)
	end
	if SOUNDS[name] then
		if LOOPING[name] then
			return WorldSfx.loop(name, at, opts) or false
		end
		return playSound(name, at, (opts and opts.volume) or 1, (opts and opts.pitch) or 1, nil, opts) ~= nil
	end
	local a, b, c = string.match(name, "^(%a+)[%.:]([%w_]+)[%.:]?([%w_]*)$")
	if a == "weapon" then
		return WorldSfx.weapon(b, if c ~= "" then c else "swing", at, opts)
	elseif a == "magic" then
		return WorldSfx.magic(b, if c ~= "" then c else "cast", at, opts)
	elseif a == "monster" then
		return WorldSfx.monster(b, if c ~= "" then c else "aggro", at, opts)
	elseif a == "gate" then
		return WorldSfx.gate(b, at, opts) ~= false
	elseif a == "city" then
		return WorldSfx.city(b, at, opts) ~= false
	elseif a and MAGIC[WorldSfx.element(a)] and (ELEMENT_ALIAS[a] or MAGIC[a]) then
		-- "fire.impact", "frost:nova"
		return WorldSfx.magic(a, b, at, opts)
	end
	return false
end

-- the old sound files SkillFx and others still name (rbxasset://sounds/*.wav, which the client
-- no longer ships) play the bank's sound for what they were used for
WorldSfx.LEGACY_SOUND = {
	["rbxasset://sounds/swordslash.wav"] = "blade.swish",
	["rbxasset://sounds/swordlunge.wav"] = "thrust.swish",
	["rbxasset://sounds/electronicpingshort.wav"] = "arcane.burst",
	["rbxasset://sounds/collide.wav"] = "earth.crack",
	["rbxasset://sounds/unsheath.wav"] = "blade.draw",
}

-- an asset id as it is (a SoundId the bank doesn't know)
function WorldSfx.playId(id: any, at: any?, opts: any?): boolean
	local legacy = type(id) == "string" and WorldSfx.LEGACY_SOUND[id]
	if legacy then
		local o = table.clone(opts or {})
		-- (the old ping was pitched all over the place; a recording takes a narrower range)
		o.pitch = math.clamp(o.pitch or 1, 0.6, 1.6)
		return playSound(legacy, at, o.volume or 1, o.pitch) ~= nil
	end
	local resolved = WorldSfx.resolveId(id)
	if not resolved then
		return false
	end
	if not SOUNDS[resolved] then
		SOUNDS[resolved] = { vol = 1, pitch = { 1, 1 }, range = 200, v = { { resolved, "(asset id)" } } }
	end
	return playSound(resolved, at, (opts and opts.volume) or 1, (opts and opts.pitch) or 1) ~= nil
end

-- stop everything (a cutscene skipped, the city left)
function WorldSfx.stopAll()
	for i = #active, 1, -1 do
		release(active[i])
	end
end

function WorldSfx.activeCount(): number
	return #active
end

-- every id in the bank (tests, the verifier)
function WorldSfx.ids(): { any }
	local out = {}
	for name, def in SOUNDS do
		for _, v in def.v do
			if v[2] ~= "(asset id)" then
				table.insert(out, { name = name, id = v[1], label = v[2] })
			end
		end
	end
	return out
end

return WorldSfx
