-- LifeSim client entry. The installer clones this script into each player's PlayerGui.
-- (BitLeveling) the live city starts alongside the app; it does nothing on a server without it.
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
require(script:WaitForChild("App")).start()
