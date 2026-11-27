-- LifeSim client entry. The installer clones this script into each player's PlayerGui.
-- (BitLeveling) the opening plays first (a raid party walking into a Gate; Skip ends it), then
-- the live city starts alongside the app, and the app opens on the title screen (PLAY, then the
-- main menu: UI/TitleMenu). None of it does anything on a server without the live city.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("LifeSim")
local okCfg, Config = pcall(require, shared:WaitForChild("Config"))
local live = okCfg and type(Config) == "table" and type(Config.hunterLive) == "table" and Config.hunterLive.enabled ~= false
-- (BitLeveling) sound, before anything shows: the effects mix and its sources (Config.sfx), every
-- button's click and hover (UiSounds watches PlayerGui), and the 3D world's library (WorldSfx).
-- The app's own Sfx.start later is a no-op; a missing sound just stays quiet.
do
	local ok, err = pcall(function()
		if okCfg and type(Config) == "table" and type(Config.sfx) == "table" then
			require(script:WaitForChild("Sfx")).start(Config.sfx)
		end
		require(script:WaitForChild("UiSounds")).start()
		require(script:WaitForChild("WorldSfx")).start()
	end)
	if not ok then
		warn("[BitLeveling] sound failed to start: " .. tostring(err))
	end
end
if live and Config.hunterLive.opening ~= false then
	local ok, err = pcall(function()
		require(script:WaitForChild("OpeningCutscene")).play()
	end)
	if not ok then
		warn("[BitLeveling] opening cutscene failed: " .. tostring(err))
	end
end
-- (BitLeveling) capes, robe tails and scarves made with bones swing (SmartBone-style)
task.spawn(function()
	local ok, err = pcall(function()
		require(script:WaitForChild("ClothPhysics")).start()
	end)
	if not ok then
		warn("[BitLeveling] cloth physics failed: " .. tostring(err))
	end
end)
if live then
	task.spawn(function()
		local ok, err = pcall(function()
			require(script:WaitForChild("HunterLive")).start({
				backdrops = { require(script:WaitForChild("BackdropCity")), require(script:WaitForChild("Backdrop")) },
			})
		end)
		if not ok then
			warn("[BitLeveling] live city client failed: " .. tostring(err))
		end
	end)
end
require(script:WaitForChild("App")).start()
