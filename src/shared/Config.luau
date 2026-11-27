--[[
	Kit settings. Safe to edit.
]]

return {
	-- Which content pack runs (Shared > Pack):
	--   "City"       the Project Moon City: a fan game, so the Robux store is switched off
	--   "Undermere"  the original setting (with the looks-only store)
	pack = "BitLeveling",
	-- (v0.18) show the game modes marked hidden (Fixer's Road) in the start menu and the lobby.
	-- Off for players; the headless tests turn it on.
	devModes = false,

	-- DataStore name. Change the suffix to wipe everyone's saves. Each pack needs its own,
	-- because a life from one pack can't be continued in the other.
	-- (The Undermere pack used "LifeSim_Undermere_v2".)
	dataStoreName = "LifeSim_BitLeveling_v1",

	-- The mod menu. These players (Roblox user ids) can start world events, change today's
	-- event, make any event happen to anyone, set stats, heal, give traits, rolls and more,
	-- and post announcements (filtered like chat). `owner` adds the place's owner, `studio`
	-- lets anyone use it while testing in Studio.
	admin = {
		users = { 523337247 },
		owner = true,
		studio = true,
	},

	-- (v0.13) A household of your own can become a marriage: a ceremony at the District office
	-- with family there, never romance (no dating, no kissing, nothing on screen) and never with
	-- another player. Roblox's maturity questionnaire may still count marriage as a "romance"
	-- theme: if your experience's label must stay at Mild, set this to false and households stay
	-- households.
	marriage = true,

	-- City news in the chat when a player on the server does something big.
	chatNews = true,
	-- show each player's title in their current life in front of their chat messages
	chatTags = true,

	-- A text life-sim doesn't need avatars walking around behind the UI.
	disableCharacters = true,

	-- Procedural 3D city drawn behind the UI (client-side only). Each Ward has its
	-- own spot, light and landmarks; see `backdrop` on each district in Content.
	backdrop = true,

	-- How many finished lives (lanterns) to keep per player.
	maxLanterns = 60,

	-- Sound effects. Each entry is an asset id (a number), an engine file ("rbxasset://sounds/..."),
	-- or { id = ..., volume = ..., pitch = ..., gain = ..., lazy = true }:
	--   volume  how loud Sfx.play(name) plays it (the app's named sounds; default `volume` below)
	--   pitch   a base pitch
	--   gain    a trim for when client/UiSounds or client/WorldSfx layer it (default 1)
	--   lazy    a long loop or ambience: loaded the first time it plays, not at the start
	-- Leave one out (or "") to silence it. A sound that can't load (taken down, or gone from the
	-- client) goes quiet, and every layer built on it just drops out.
	--
	-- (BitLeveling) client/UiSounds and client/WorldSfx build every click, slash, spell, roar,
	-- Gate and siren from the SOURCES below, each layered, pitched and sliced a little differently
	-- every time. Every id was looked up on 2026-11-27 through Roblox's own Creator Store API
	-- (apis.roblox.com/toolbox-service/v1/items/details), which returned the name and creator
	-- written next to it; docs/SFX.md has the whole list and how to check it again.
	--   [R]    uploaded by Roblox itself (creator "Roblox", id 1)
	--   [RP]   uploaded by "Roblox Presents" (4111519), Roblox's own events account
	--   [PSE]  Pro Sound Effects (creator "ProSoundEffects", 7462895450): the library of sound
	--          effects Roblox licensed in 2022, free to use in any Roblox experience
	--   [ENG]  a file that ships inside the Roblox client (content/sounds in the client's
	--          rbxManifest.txt, version 0.748.0.7481526, as mirrored by the public
	--          MaximumADHD/Roblox-Client-Tracker). Nothing to upload, nothing to take down.
	--   (The LifeSim kit shipped community re-uploads of another game's audio here; they are all
	--   gone. Every id below is checked by tools/sfx/verify_ids.py, and the music by its --music.)
	sfx = {
		volume = 0.3, -- v0.10: everything a good deal quieter; the buttons quieter still

		-- ── the app's named sounds (Sfx.play("click") anywhere). With client/UiSounds running
		-- each plays a layered version built from the sources; the id here is what plays without
		-- it.
		intro = { id = 9125404320, volume = 0.35 }, -- [PSE] Boom Impact Deep Distant Thumping Hits
		transition = { id = 15675046931, volume = 0.3 }, -- [R] Roblox_UI_Sweep
		click = { id = 15675032796, volume = 0.3 }, -- [R] Roblox_UI_Small_Click
		confirm = { id = 17208396156, volume = 0.3 }, -- [R] Roblox GUI - Select
		tab = { id = 17208408337, volume = 0.28 }, -- [R] Roblox GUI - Tab
		reroll = { id = 16480575861, volume = 0.3 }, -- [R] Roblox_Pinball_Big_Metal_Tally_01
		resonance = { id = 17208327798, volume = 0.3 }, -- [R] Roblox GUI - Aura
		bossStart = { id = 9114630316, volume = 0.35 }, -- [PSE] Gong Hit Resonant Trail 1
		defeat = { id = 9116407527, volume = 0.32 }, -- [PSE] Magic Rumbling Decay 2
		death = { id = 9116418234, volume = 0.3 }, -- [PSE] Magic Tone Falling Shimmer Flanged 1
		ego = { id = 9116422213, volume = 0.3 }, -- [PSE] Magic Transformation 17
		shatter = { id = 9114590297, volume = 0.28 }, -- [PSE] Glass Break 1

		-- ── the turn-based fights (the kit's clash screen): Roblox's and ProSoundEffects' own
		coin = { id = 9113849492, volume = 0.22 }, -- [PSE] Coins Or Keys Jingle 6
		tails = { id = 12222170, volume = 0.22 }, -- [R] switch.wav
		clash = 9119072660, -- [PSE] Shield Clang As Hit Metal Sword Hubcap 1
		clashWin = 9119747120, -- [PSE] Sword Impact 102
		parry = 9113449585, -- [PSE] Blade Hits Metal Rod On Knife Impacts 10
		evade = 9118158081, -- [PSE] Reversed Whoosh Backwards Hissing Burst 1
		guard = 9119074309, -- [PSE] Shield Impacts 2
		hit = 9117969717, -- [PSE] Punch Kit Beefy Hit 3
		slash = 9119746598, -- [PSE] Sword Hit 1
		pierce = 9113161406, -- [PSE] Arrow In And Hit 13
		blunt = 9117969420, -- [PSE] Punching Bag Hits 22
		crit = 9119747138, -- [PSE] Sword Impact 202
		stagger = 9113225986, -- [PSE] Axe Impact Giant Thuddy Hits On Wood Floor 5
		tremorBurst = 9114224721, -- [PSE] Earthquake Explosion 1
		burn = 9117987278, -- [PSE] Pyro Fire Ball Burst 12
		panic = 9125485274, -- [PSE] Deep Synth Drone Modulating Sub Rumble
		prescript = 9126073001, -- [PSE] Synth Sparkle Tone High Pitch Bell Tone Ding

		-- ══ SOURCES ══════════════════════════════════════════════════════════════════════════
		-- ── [ENG] engine files in the client
		eng_boom = "rbxasset://sounds/impact_explosion_03.mp3", -- the default Explosion
		eng_splash = "rbxasset://sounds/impact_water.mp3", -- a character landing in water
		eng_jump = "rbxasset://sounds/action_jump.mp3",
		eng_land = "rbxasset://sounds/action_jump_land.mp3",
		eng_fallwind = { id = "rbxasset://sounds/action_falling.ogg", lazy = true }, -- free-fall wind (a loop)
		eng_steps = { id = "rbxasset://sounds/action_footsteps_plastic.mp3", lazy = true }, -- footsteps (a loop)
		eng_slider = "rbxasset://sounds/volume_slider.ogg", -- the settings menu's slider tick

		-- ── [R] Roblox's own uploads (the 2009 library is the client's old content/sounds folder)
		rb_slash = 12222216, -- swordslash.wav
		rb_lunge = 12222208, -- swordlunge.wav
		rb_unsheath = 12222225, -- unsheath.wav
		rb_hit = 12222046, -- hit.wav
		rb_collide = 12221984, -- collide.wav
		rb_swoosh = 12222200, -- swoosh.wav
		rb_ping = 12221990, -- electronicpingshort.wav
		rb_thunder = 12222030, -- HalloweenThunder.wav
		rb_lightning = 12222019, -- HalloweenLightning.wav
		rb_rocketwhoosh = 12222095, -- Rocket whoosh 01.wav
		rb_glass = 12222005, -- glassbreak.wav
		rb_sling = 12222103, -- Rubber band sling shot.wav (a bowstring's snap, pitched)
		rb_victory = 12222253, -- victory.wav
		rb_pageturn = 12222076, -- pageturn.wav
		rb_switch = 12222170, -- switch.wav
		rb_cannon = 3149249837, -- Cannon_Explode
		rb_roar = 9120031442, -- Thunder With Lion Roar Searing Blast Growl 3 (SFX)
		rb_ufobeam = { id = 162670130, lazy = true }, -- UFO Beam (a beam's hum, 17 s)
		rb_laser = 9114277757, -- [PSE] Electric Zaps 12 (a laser's shot)
		rb_equip = 17208323435, -- [R] Roblox GUI - Equip
		rb_checkpoint = 9126072027, -- [PSE] Synth Sparkle Tone High Pitch Bell Tone Burst (a bright chime)

		-- ── [R] Roblox's interface sounds (Roblox_UI 2023, RBLX UI 2022, Roblox GUI 2024, Pinball 2024)
		ui_click = 15675032796, -- Roblox_UI_Small_Click
		ui_click2 = 15675059323, -- Roblox_UI_Bright_Click
		ui_select = 17208396156, -- Roblox GUI - Select
		ui_select2 = 10128760939, -- RBLX UI Select 01 (SFX)
		ui_select3 = 10066968815, -- RBLX UI Select 02 (SFX)
		ui_hover1 = 17208339919, -- Roblox GUI - Hover 01
		ui_hover2 = 17208343514, -- Roblox GUI - Hover 02
		ui_hover3 = 17208348006, -- Roblox GUI - Hover 03
		ui_back = 17208186900, -- Roblox GUI - Back
		ui_back2 = 10066914500, -- RBLX UI Back (SFX)
		ui_tab = 17208408337, -- Roblox GUI - Tab
		ui_swipe = 17208405682, -- Roblox GUI - Swipe
		ui_swipe2 = 10128766965, -- RBLX UI Swipe (SFX)
		ui_sweep = 15675046931, -- Roblox_UI_Sweep
		ui_paper = 15675037413, -- Roblox_UI_Paper_Swipe
		ui_purchase = 17208380755, -- Roblox GUI - Purchase
		ui_purchase2 = 10066947742, -- RBLX UI Purchase (SFX)
		ui_negative = 17208353912, -- Roblox GUI - Negative
		ui_delete = 10066926605, -- RBLX UI Delete (SFX)
		ui_notify = 17208361335, -- Roblox GUI - Notification High
		ui_notifyLow = 17208372272, -- Roblox GUI - Notification Low
		ui_toast = 99437156604053, -- PV_ToastNotif
		ui_pop = 15675055424, -- Roblox_UI_Cute_Pop
		ui_indicator = 15675085146, -- Roblox_UI_Indicator
		ui_stinger = 15675043410, -- Roblox_UI_Tonal_Stinger
		ui_aura = 17208327798, -- Roblox GUI - Aura
		ui_equip = 17208323435, -- Roblox GUI - Equip
		ui_pickup = 17208319162, -- Roblox GUI - Pickup
		ui_bubble = 17208204604, -- Roblox GUI - Bubble
		ui_whoosh1 = 15675024286, -- Roblox_UI_Whoosh_01
		ui_whoosh2 = 15675028888, -- Roblox_UI_Whoosh_02
		ui_whoosh3 = 15674975792, -- Roblox_UI_Whoosh_03
		ui_whoosh4 = 15675012262, -- Roblox_UI_Whoosh_04
		ui_coins = 127645268874265, -- CoinTransfer_01
		ui_tick = 16480551554, -- Roblox_Pinball_Small_Metal_Click_01
		ui_tick2 = 16480550292, -- Roblox_Pinball_Tiny_Button_Press_01
		ui_tally = 16480575861, -- Roblox_Pinball_Big_Metal_Tally_01
		ui_bells = 16480570986, -- Roblox_Pinball_Bumper_Low_Bells_02

		-- ── [PSE] weapons
		sw_swish1 = 9119749145, -- Sword Swish 102
		sw_swish2 = 9119749263, -- Sword Swish 5
		sw_fast1 = 9126013644, -- Swish Med High End Sharp Swords Fast Punches
		sw_fast2 = 9126013811, -- Swish Med High End Sharp Swords Fast Punches
		sw_fast3 = 9126014020, -- Swish Med High End Sharp Swords Fast Punches
		sw_hit1 = 9119746598, -- Sword Hit 1
		sw_hit2 = 9119746592, -- Sword Hit 2
		sw_hit3 = 9119746751, -- Sword Hit 4
		sw_impact1 = 9119747120, -- Sword Impact 102
		sw_impact2 = 9119747138, -- Sword Impact 202
		sw_impact3 = 9119747163, -- Sword Impact 302
		sw_draw = 9119742466, -- Sword Draw Clang Unsheathing Two Sabers 1
		sw_draw2 = 9119744642, -- Sword Draw Clang Unsheathing Two Sabers 29
		sw_stab = 9119746592, -- [PSE] Sword Hit 2 (the "Sword Stab" clip was filed under gore)
		kn_shing1 = 9116197252, -- Knife Shing 202
		kn_shing2 = 9116197044, -- Knife Shing 102
		wh_heavy1 = 9120728815, -- Whoosh Heavy Punches 1
		wh_heavy2 = 9120728883, -- Whoosh Heavy Punches 2
		wh_heavy3 = 9120729007, -- Whoosh Heavy Punches 3
		wh_thick1 = 9120742729, -- Whoosh Thick Quick Multiple Variations 1
		wh_thick2 = 9120742716, -- Whoosh Thick Quick Multiple Variations 2
		wh_air = 9113077334, -- Air Whoosh Heavy Bys And Impacts 1
		wh_slice = 9120972444, -- Wood Whoosh Slicing Air Quick Swings 1
		bl_sledge1 = 9125672726, -- Metal Impact Sledge Hammer Hits On 5 Ft I-Beam
		bl_sledge2 = 9125670743, -- Metal Impact Sledge Hammer Hits On 5 Ft I-Beam
		bl_metal = 9116651255, -- Metal Hits 2
		bl_boxing = 9113568548, -- Boxing Hits 13
		bl_body1 = 9113487341, -- Body Hit 1
		bl_body2 = 9113487470, -- Body Hit 2
		bl_punch = 9119061517, -- Sharp Punch 6
		sh_clang1 = 9119072660, -- Shield Clang As Hit Metal Sword Hubcap 1
		sh_clang2 = 9119072674, -- Shield Clang As Hit Metal Sword Hubcap 2
		sh_impact1 = 9119075623, -- Shield Impacts 16
		sh_impact2 = 9119074309, -- Shield Impacts 2
		xb_fire1 = 9114001369, -- Crossbow Fire 12
		xb_fire2 = 9114002577, -- Crossbow Fire 3
		xb_bolt1 = 9113998001, -- Crossbow Bolts Impact 3
		xb_bolt2 = 9113998866, -- Crossbow Bolts Impact 23
		xb_load = 9114004212, -- Crossbow Movement Latches 8
		ar_hit1 = 9113161129, -- Arrow In And Hit 5
		ar_hit2 = 9113161312, -- Arrow In And Hit 10
		ar_fly = 9113166206, -- Arrow Out Whooshing Pass By 1
		bw_creak = 9125407239, -- Bow Stretches Wood Creaking
		ch_whip1 = 9113612424, -- Buggy Whip Quick Swish Crack 2
		ch_whip2 = 9113611449, -- Buggy Whip Light Crack Swish Many Versions 6
		ch_crack = 9120663217, -- Whip Cracks 2
		ch_rattle1 = 9113763590, -- Chain Rattle Glassy Metal Rattle 3
		ch_rattle2 = 9113763589, -- Chain Rattle Glassy Metal Rattle 2
		rk_hit1 = 9118627392, -- Rock Impacts 8
		rk_hit2 = 9118607982, -- Rock Hits Rock On Rock Various Versions 6

		-- ── [PSE] the elements
		fi_ball = 9114428740, -- Fireball Pass By 1
		fi_burst1 = 9117987278, -- Pyro Fire Ball Burst 12
		fi_burst2 = 9117983605, -- Pyro Fire Ball Burst 9
		fi_burst3 = 9117984812, -- Pyro Fire Ball Burst 1
		fi_whoosh1 = 9114446852, -- Fire Whoosh 15
		fi_whoosh2 = 9114446277, -- Fire Whoosh 6
		fi_lick = 9114463219, -- Flame Licks 8
		fi_loop = { id = 9112780193, lazy = true }, -- Fireplace Constant Burning Flame 1
		ic_shatter = 9114855870, -- Ice Block Drop To Concrete Shatter 1
		ic_chunk = 9114865628, -- Ice Hammer Hitting Large Chunks 10
		ic_freeze = 9125611419, -- Ice Freeze Large Piece Crackles Liquid Nitrogen
		ic_crack = 9114858767, -- Ice Cracks 1
		el_zap1 = 9114277757, -- Electric Zaps 12
		el_zap2 = 9114277402, -- Electric Zaps 6
		el_zap3 = 9114277623, -- Electric Zaps 8
		el_burst1 = 9116275998, -- Lightning Flashes Quick Electrical Bursts 13
		el_burst2 = 9116276946, -- Lightning Flashes Quick Electrical Bursts 21
		el_charge = 9125980435, -- Spaceship Pre Blast Electric Charge Up Buzzy
		el_thunder1 = 9120016037, -- Thunder Cracks Big Rumbling Blasts Booming 1
		el_thunder2 = 9120020225, -- Thunder Lightning 3
		wi_howl = 9120697823, -- Whoosh By Howling Wind Light Rumbling 1
		wi_gusts = { id = 9113732046, lazy = true }, -- Cavernous Winds Empty Eerie Gusts Tonal 1
		wi_sonic = 9120769331, -- Wind Whoosh Sonic Boom Low End Impact 1
		ea_quake1 = 9114224354, -- Earthquake Explosion 1
		ea_quake2 = 9114224675, -- Earthquake Explosion 5
		ea_boulder = 9118585978, -- Rock Cracks Big Boulder Hits 4
		ea_debris = 9114221862, -- Earthquake Debris Rock Bursts Scattering 1
		ea_tumble = 9118693443, -- Rocks Tumble 2
		ea_rumble = { id = 9112775181, lazy = true }, -- Earthquake Rumble 2
		wa_splash = 9120585252, -- Water Splash Big Water Splash Dive In 1
		wa_puddle = 9125703162, -- Mud Puddle Splash Shallow Water Impacts
		wa_geyser = 9120558177, -- Water Geyser Gush Huge Rush Splash 1
		wa_bubbles = 9120310416, -- Underwater Bubbles Deeper Med Short Bursts 6
		ho_choir = { id = 9114791989, lazy = true }, -- Heavenly Presence Thick Melodic Choir Pad 1
		ho_chimes1 = 9116394545, -- Magic Glows Soft Clusters Of Chiming Hits 1
		ho_chimes2 = 9116395085, -- Magic Glows Soft Clusters Of Chiming Hits 5
		ho_bell = 9126073001, -- Synth Sparkle Tone High Pitch Bell Tone Ding
		ho_tree = 9119447936, -- Sparkle Bell Tree Wind Chimes 1
		vo_suck = 9113436640, -- Big Suck Deep Groaning Build Up Airy Rush 4
		vo_reverse = 9119707097, -- Swish Suck Reversed Metallic Swoosh Impact 1
		vo_blast = 9126050066, -- Synth Blast Space Explosion Reverberant Tail
		vo_drone = { id = 9114353038, lazy = true }, -- Evil Drone Deep Airy Swell 1
		ve_hiss = 9119991629, -- Termite Sprays Acid Hissing Bursts 1
		ve_sear = 9119166199, -- Sizzle Short And Explosive Sear 8
		ve_bloops = 9112752570, -- Bubbles Dribble Small Bloops 1
		ve_acid = { id = 9113040409, lazy = true }, -- Acid Sizzle 1
		ac_burst1 = 9116384485, -- Magic Burst 1
		ac_burst2 = 9116384483, -- Magic Burst 3
		ac_burst3 = 9116384473, -- Magic Burst 2
		ac_zoom = 9116411685, -- Magic Swoosh Fast Zooming Pass Bys 18
		ac_shimmerby = 9125647212, -- Magic Whooshes Pass Bys Metallic Shimmering
		ac_tube = 9125648149, -- Magic Zoom Up Sharp Tubular Whoosh Fast Hiss
		ac_poof1 = 9125640290, -- Magic Poofs Short Breathy Bursts
		ac_poof2 = 9116406610, -- Magic Poofs Thumpy Wheezy Exhale 1
		ac_pulse = 9116393976, -- Magic Glow Short Pulsing Bursts 9
		ac_transform = 9116422213, -- Magic Transformation 17
		ac_descend = 9114055470, -- Descending Synth Burst Tonal Light Phasing 2
		he_shimmer = 9116420454, -- Magic Tone Tonal Shimmer Shaking Rattle 3
		he_fall = 9116418234, -- Magic Tone Falling Shimmer Flanged 1
		he_sparkle = { id = 9125986205, lazy = true }, -- Sparkle Tone Constant High End Shimmer
		mg_rise1 = 9125805579, -- Rising Whoosh Hissing Build Up Ascending Swoosh
		mg_rise2 = 9125805781, -- Rising Whoosh Hissing Build Up Ascending Swoosh
		mg_warp = 9126102694, -- Time Warp Searing Build Up Large Suck Rumble
		mg_powerup = 9117886786, -- Power Up Sweeteners 17
		mg_synthup = 9117297453, -- Phasey Synth Power Up High Pitched Rise 2
		mg_laser = 9116225257, -- Laser Blast 101
		mg_field = { id = 9116386800, lazy = true }, -- Magic Force Field Constant 1
		mg_energyby = 9114340693, -- Energy Pass By Sci Fi Tonal Whooshes 1
		mg_explode = 9117876706, -- Power Explosions Big Heavy Searing Boom 2
		mg_bigboom = 9126102254, -- Time Warp Big Explosion Blast Boom Tonal Tail
		mg_whooshboom = 9120705982, -- Whoosh Explosion 1
		mg_shock = 9125934191, -- Shockwave Impact Huge Whooshing In Build Up
		mg_deepboom = 9125404320, -- Boom Impact Deep Distant Thumping Hits Booming
		mg_stinger = 9125641284, -- Magic Synth Stinger Glassine Multi Tone Burst
		mg_transition = 9116427346, -- Magic Transition 4
		mg_rumbledecay = 9116407527, -- Magic Rumbling Decay 2

		-- ── [PSE] monsters (creature and animal recordings; nothing human, nothing gory)
		mo_goblin1 = 9114624345, -- Goblin Growl 1
		mo_goblin2 = 9114624343, -- Goblin Growl 2
		mo_goblin3 = 9114624510, -- Goblin Growl 4
		mo_goblinStutter = 9114625189, -- Goblin Stutter 3
		mo_goblinCroak = 9114624129, -- Goblin Croak 5
		mo_brute1 = 9114629612, -- Goliath Vocal Deep Growling Voice 34
		mo_brute2 = 9116967287, -- Monster Vocals 1
		mo_brute3 = 9116967303, -- Monster Vocals 2
		mo_snort = 9113634952, -- Bull Goblin Snorts 7
		mo_bull = 9113635166, -- Bull Grunts Breathing Constant 1
		mo_wolf = 9120788137, -- Wolf Growl 3
		mo_wolfSnarl1 = 9120790555, -- Wolf Snarl 1
		mo_wolfSnarl2 = 9120791326, -- Wolf Snarl 6
		mo_lion1 = 9116302309, -- Lion Roar Short Blast Attack Angry Sharp 1
		mo_lion2 = 9116302323, -- Lion Roar Short Blast Attack Angry Sharp 2
		mo_lion3 = 9116302511, -- Lion Roar Short Blast Attack Angry Sharp 4
		mo_lionLow = 9116300504, -- Lion Roar Growl Exhale Low Rumble Breath 1
		mo_lionTired = 9116304872, -- Lion Roar Tired 12
		mo_lionPain = 9125628981, -- Lion Roar Painful Bellows Cries Whines
		mo_bugs1 = 9113977177, -- Creature Mix Big Flying Insects 1
		mo_bugs2 = 9113976170, -- Creature Mix Big Flying Insects 12
		mo_wings = 9114876115, -- Insect Wings 2
		mo_bee = 9113414492, -- Bee Various Buzzing Actions 7
		mo_chomp = 9114624343, -- [PSE] Goblin Growl 2 (a snap and growl; the bug chomp clip was filed under gore)
		mo_spider1 = 9113991080, -- Creature Vocal Spider Hiss Squawk 1
		mo_spider2 = 9125475729, -- Creature Vocal Spider Growl Belch Hiss Snarl
		mo_spiderAtk = 9125471800, -- Creature Mix Big Spider Attack Vocal Footsteps
		mo_spiderDie = 9113991846, -- Creature Vocal Spider Snarl Hiss Exhale 1
		mo_snake = 9119302978, -- Snake Hiss 2
		mo_snakeAtk1 = 9119300025, -- Snake Attack Vocal 7
		mo_snakeAtk2 = 9119300024, -- Snake Attack Vocal 6
		mo_hydra = 9114854828, -- Hydra Wet Throaty Hissing 1
		mo_ghost = 9114574159, -- Ghost Wind Slow Build And Decay Swirling 2
		mo_whisper = 9125440141, -- Choral Wind Eerie Vocal Whisper Wind Ghosts
		mo_demon1 = 9114228524, -- Eerie Whispering Eerie Reverberant Demon 2
		mo_demon2 = 9114228525, -- Eerie Whispering Eerie Reverberant Demon 3
		mo_demonRev = 9114039101, -- Demon Screams Reversed Hollow Voice 2
		mo_growlBurst = 9114315023, -- Energy Burst Growl 1
		mo_slime1 = 9119990452, -- Tentacle Slime 1
		mo_slime2 = 9119990528, -- Tentacle Slime 2
		mo_slime3 = 9119990321, -- Tentacle Slime 4
		mo_dissolve = 9113602577, -- Bubble Dissolve Giant 1
		mo_bat = 9125386815, -- Bat Noises Bursts Of Wings Flapping Fast Away
		mo_flap = 9114787449, -- Hawk Bird Wings Flap Flutter 1
		mo_screech1 = 9125474505, -- Creature Screech Pterodactyl Vocals
		mo_screech2 = 9125474863, -- Creature Screech Pterodactyl Vocals
		mo_shriek = 9113988191, -- Creature Vocal Pterodactyl Death Shriek 2
		mo_crabRoar = 9113987603, -- Creature Vocal Giant Crab Monster Roars 1
		mo_crab1 = 9113980480, -- Creature Mix Giant Crab Monster Roar Growl 2
		mo_crab2 = 9113980319, -- Creature Mix Giant Crab Monster Roar Growl 1
		mo_throat = 9113985466, -- Creature Roar Constant Deep Throaty Growls 3
		mo_breath = 9113984056, -- Creature Mix Weird Deep Monster Breathing 3
		mo_stomp1 = 9114165461, -- Dragon Footsteps 5
		mo_stomp2 = 9125404769, -- Boomy Footsteps Giant Thumpy Dinosaur Footsteps
		mo_leaves = { id = 9116258071, lazy = true }, -- Leaves Rustle Wind Blowing Through Trees 1
		mo_branch = 9120258724, -- Tree Branches Breaking Snapping Cracking 1
		mo_woodCreak = 9126263691, -- Wood Groan Creak Opening Wood Chest
		mo_underwater = 9120348411, -- Underwater Movement 14
		mo_gurgle = 9120005520, -- Throat Gurgle 1
		mo_stone = 9113807250, -- Cinder Block Slide On Stone Surface Course 4
		mo_metal = 9125819216, -- Robot Impact Miscellaneous Metal Clangs Clunks
		mo_fall = 9113479463, -- Body Falls 1

		-- ── [PSE] Gates
		gt_hum = { id = 9125567032, lazy = true }, -- Force Field Drone Constant Sci Fi Pulsing Hum
		gt_swirl = { id = 9114330786, lazy = true }, -- Energy Field Constant Rotating Swooshes 1
		gt_presence = { id = 9112777364, lazy = true }, -- Energy Presence 1
		gt_red = { id = 9114353261, lazy = true }, -- Evil Drone Deep Unsetting Rumbly Keening 1
		gt_redChoir = { id = 9125603019, lazy = true }, -- Heavenly Presence Eerie Choral Tones Dark
		gt_open = 9120057087, -- Time Warp Searing Build Up Boomy Explosion 5
		gt_surge = 9118747824, -- Rumble Constant Roar Energy Building 1
		gt_glass = 9114591736, -- Glass Breaks 6
		gt_close = 9126236071, -- Wind Suck Slow Backwards Swooshing Build Up
		gt_enter = 9126228631, -- Whoosh Back Zoom Swoosh Fast Camera In And Out
		gt_tunnel = 9125742262, -- Plasma Trails Constant Airy Whooshing Windy
		gt_meteor = 9114428748, -- Fireball Burning Whoosh By 2
		gt_mortar = 9116973611, -- Mortar Explosion 3

		-- ── [PSE] the city
		ct_siren = { id = 9112871822, lazy = true }, -- Siren Composite 1
		ct_sirenAway = 9117810961, -- Police Siren Slow Vehicle Away 2
		ct_yelp = { id = 9119165420, lazy = true }, -- Siren Yelp 1
		ct_panic1 = { id = 9114012460, lazy = true }, -- Crowd Panic 1
		ct_panic2 = 9114012583, -- Crowd Panic 2
		ct_street = { id = 9112879448, lazy = true }, -- Street Crowd 2
		ct_walkie1 = 9120456889, -- Walkie Talkie 12
		ct_walkie2 = 9120458059, -- Walkie Talkie 5
		ct_walkie3 = 9120456241, -- Walkie Talkie 1
		ct_static = 9118027586, -- Radio Static 9
		ct_skid = 9119186275, -- Skids Tire Screeches On Dirt Pavement 4
		ct_airbrake = 9113052763, -- Air Brakes Bus Truck Several Bursts 2
		ct_van = 9112968238, -- 1973 Dodge Tradesman Van 1
		ct_door = 9113204879, -- Audi Car Door Movement Opening Closing 1
		ct_vanDoor = 9120364883, -- Van Door Fumbly Hits 2
		ct_horn = 9120386436, -- Vehicle Horn Short Long Honks 13
		ct_alarm = { id = 9113719289, lazy = true }, -- Car Alarm Exterior Van Yelp Alarm
		ct_crystal = 9125530803, -- Electronic Blips Sharp Crystalline Beeps
		ct_gong = 9114630316, -- Gong Hit Resonant Trail 1
		ct_clock = 9113816351, -- Clock Mechanism 1
	},

	-- Background music, picked by mood. The game moves between moods on its own:
	-- battle in clashes, scary in breaches and fog, goofy in childhood, calm in the
	-- Charter, intense on dungeon runs, sad on the death screen, hero for big
	-- moments. A Ward can set its own mood with `music` in Content (districts).
	-- Players can mute it with the speaker button.
	music = {
		enabled = true,
		volume = 0.35,
		fade = 2.5, -- seconds to crossfade between tracks
		hold = 90, -- an ambient mood plays at least this long before the music may change
		moods = {
			boss = { 9042613158, 1837064066, 9040003655 }, -- Inevitable, The Destroyer, Terrorscape (APM, Roblox's music library)
			hero = { 9042616620, 1837063192, 1837079862 }, -- Last Charge, Releasing the Beast, Gatekeeper
			sad = { 1837083871 }, -- Give In To The Night
			angry = { 1837059295 }, -- Dawn of Destiny
			emotional = { 1837084344 }, -- Higher Ground
			goofy = { 1837065871, 1837065835 }, -- Devilishly Daring, Mischief and Mayhem
			calm = { 1837064422, 1837085693 }, -- Revelation, Ascendant
			uplifting = { 9041839737, 1837072312, 9041844265, 1837060654, 9042612250 }, -- Transcendance, Flower Duet, Whirlpool, The Last Fall, Restored
			semi = { 1837106380, 1837072359, 1837062973, 9039328128, 9041840070, 1837084291, 9042614810 }, -- Gymnopedie, Moonlight Sonata, Battle of Honour, Blood Moon Lullaby, Gravity, Higher Ground, Override
			scary = { 1837059475 }, -- Limitless Reach
			intense = { 1837068276, 9046420614, 1837064012, 9038213562, 1837081677, 9042611959, 9040003655, 1837059570, 9040002148, 9041848481, 9042613158, 1837064066 },
			battle = { 9038213241, 9046408415, 1837063626, 9038220273, 9038213597, 9046407900, 1845149698 }, -- Gekido, Furious, The Executioner, Zengeance, Kyoso, My Thunder, Seek N Destroy
			vocal = { 1837065029, 9038212468, 1837083988 }, -- You Stand Alone, Hunt Me Down, Shadows
			extra = { 122692586554943, 135720954799216, 134075603974035 },
			-- quieter tracks for the lore panel, the menus and slow years. Paste ids you're
			-- allowed to use (the Creator Store's music library is free for Roblox games).
			relaxing = { 1837106380, 1837072359, 1837064422, 1837085693, 1837072312 }, -- Gymnopedie, Moonlight Sonata, Revelation, Ascendant, Flower Duet
		},
		-- which mood plays where (the client picks the first that applies)
		-- Quick checks, the lore panel and celebrations don't change the music any more.
		places = {
			intro = "vocal",
			introNight = "scary", -- the join cinematic at 3:13
			menu = "semi",
			creator = "semi",
			duel = "battle",
			fight = "battle",
			boss = "boss",
			death = "sad",
			dungeon = "intense",
			containment = "battle",
			mission = "semi",
			trip = "uplifting",
			childhood = "relaxing",
			charter = "calm",
			gutters = "semi",
		},
		-- world events with no mood below play by their tone
		worldEventTones = { danger = "intense", strange = "scary" },
		-- world events change the mood while they're on
		worldEvents = {
			abnormality_breach = "scary",
			night_in_backstreets = "intense",
			thumb_crackdown = "angry",
			distortion_sighting = "scary",
			library_appears = "emotional",
			breach_tidewell = "scary",
			fog_week = "scary",
			lantern_festival = "uplifting",
			great_low_tide = "uplifting",
			company_strike = "angry",
		},
	},

	-- Server-wide world events (Content/WorldEvents.luau): a breach, a festival...
	worldEvents = {
		enabled = true,
		firstDelay = 180, -- seconds after the server starts before the first roll
		every = 540, -- seconds between rolls
		chance = 0.65, -- chance each roll starts one
	},

	-- (BitLeveling) THE LIVE CITY: Gates that open in real time in the walkable 3D city
	-- (server/HunterLive). `every` is the seconds between new Gates (a High-Danger life on the
	-- server makes it about half), `maxIncidents` how many run at once, `civilians` how many
	-- people walk the streets. Admins (and anyone in Studio) get a TEST GATE button.
	hunterLive = {
		enabled = true,
		opening = true, -- the opening cinematic when a player joins (a raid party walking into a Gate)
		firstDelay = 45,
		every = { 150, 320 },
		maxIncidents = 2,
		civilians = 24,
		cityName = "Seoul",
		country = "korea",
	},

	-- The store: Robux purchases that are looks only. Nothing here changes stats,
	-- money, Glow, odds, lifespans or leaderboard scores.
	-- Paste ids from the Creator Dashboard: Developer Products (kind = "product")
	-- and Game Passes (kind = "pass"). Leave id = 0 until you've made them; with
	-- testInStudio, items can be test-bought for free in Studio.
	-- (v0.17) REDEEM CODES: typed in the store's "Have a code?" box, once per player. Add your own
	-- here, or make them in game from the mod menu (Codes tab). Grants: "lunacy:N", "light:N",
	-- "rolls:N", "boost:heal", "boost:ahn:N", or a look ("outfit:color_coat", "body:feminine").
	-- expires = a Unix time (os.time()) after which the code stops working; leave it out to keep it.
	codes = {
		WELCOME = { grants = { "lunacy:60", "light:5" }, note = "Welcome to the City: 60 Lunacy and 5 Light." },
	},

	store = {
		testInStudio = true,
		-- A fan pack (like the City) sells nothing unless this is true. The owner's call: on for
		-- a small private game. The catalog comes from the pack (src/shared/City/Store.luau).
		sellInFanPacks = true,
		note = "Nothing here changes your odds, your money or your score.",
		items = {
			-- small
			{ key = "dye_lantern", kind = "product", id = 0, price = 25, tier = "Small", name = "Lantern Gold Dye", desc = "Hair that catches the lamplight.", grants = { "hairColor:lantern" } },
			{ key = "dye_tide", kind = "product", id = 0, price = 25, tier = "Small", name = "Tide Silver Dye", desc = "The color of the Mere at dawn.", grants = { "hairColor:tidesilver" } },
			{ key = "mark_gilt", kind = "product", id = 0, price = 35, tier = "Small", name = "Gilt Freckles", desc = "Freckles that shine like brass leaf.", grants = { "mark:gilt" } },
			-- medium
			{ key = "frame_crimson", kind = "product", id = 0, price = 79, tier = "Medium", name = "Crimson File", desc = "Red brackets on your file card.", grants = { "frame:crimson" } },
			{ key = "frame_brine", kind = "product", id = 0, price = 79, tier = "Medium", name = "Brine File", desc = "Sea-green brackets on your file card.", grants = { "frame:brine" } },
			{ key = "outfit_midnight", kind = "product", id = 0, price = 99, tier = "Medium", name = "Midnight Diver", desc = "Black canvas with a sea-glass collar.", grants = { "outfit:midnight" } },
			{ key = "outfit_rimward", kind = "product", id = 0, price = 99, tier = "Medium", name = "Rimward Finery", desc = "Cream, wine and brass. Dressed for the Charter galas.", grants = { "outfit:rimward" } },
			{ key = "hair_lamphat", kind = "product", id = 0, price = 129, tier = "Medium", name = "Lamplighter's Hat", desc = "A tall felt hat with a little lamp on the band.", grants = { "hair:lamphat" } },
			-- big
			{ key = "pack_parade", kind = "product", id = 0, price = 199, tier = "Big", name = "Lantern Parade", desc = "When a life ends, a whole parade of lanterns goes out with it.", grants = { "lantern:parade" } },
			{ key = "pass_patron", kind = "pass", id = 0, price = 299, tier = "Big", name = "Patron of the Mere", desc = "A patron's purple coat and file card, and a patron badge on every leaderboard. Forever.", grants = { "outfit:patron", "frame:patron", "badge:patron" } },
			{ key = "pack_gilded", kind = "product", id = 0, price = 499, tier = "Big", name = "The Gilded Charter", desc = "A gold coat, a gold file card, golden lanterns, and your name in gold on the rankings.", grants = { "outfit:gilded", "frame:gold", "lantern:gold", "badge:gilded" } },
		},
	},

	-- Print content-pack warnings to the Output window on server start.
	verboseValidation = true,
}
