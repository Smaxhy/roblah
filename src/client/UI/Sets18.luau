--[[
	MORE PLACES TO FIGHT (v0.18): sixteen more sets for the 3D stage, made with the same builder
	as the first eleven (UI/Stage.luau). Each is dressed behind and around where people stand
	(x -3..3 on the floor at y 0, the camera out at +z), lit by its own lamps, and says which
	way its light falls (`time`). They're the City's ordinary places; nobody from canon is in them.

		market       a backstreet night market under a string of lanterns
		docks        a pier, containers, black water and a crane
		subway       an underground platform with a train standing at it
		factory      a Workshop floor after hours: presses, a conveyor, embers
		bridge       a steel bridge over a canal
		construction a tower going up: girders, scaffolding, work lights
		noodle       a noodle shop near closing
		library      a reading floor of tall shelves and warm lamps
		warehouse    racks of crates, a roll-up door, a forklift
		sewer        a walkway by a channel under the streets
		plaza        a Nest plaza: white stone, a fountain, glass towers
		trainyard    a freight yard: rails, boxcars, a signal
		greenhouse   a glasshouse on a Nest roof
		office       an Office after hours: desks, cabinets, the contract board
		parking      a parking deck: pillars, painted bays, two cars
		arcade       a basement arcade, every screen lit
]]

return function(SETS, h)
	local TIMES, NEON, WINDOW_LIT = h.TIMES, h.NEON, h.WINDOW_LIT

	local function pick(r, list)
		return list[math.floor(r() * #list) + 1]
	end

	-- towers far off, with lit windows (rows go further back)
	local function skyline(b, r, z: number, rows: number)
		for i = -12, 12 do
			for row = 0, rows - 1 do
				local hh = r(16, 44) + row * 10
				local zz = z - row * 18
				local x = i * 6 + r(-2, 2)
				b.box(x, hh / 2 - 6, zz, r(4, 7), hh, 4, { 18 + row * 4, 20 + row * 4, 30 + row * 6 }, "plastic")
				for _ = 1, 4 do
					if r() < 0.55 then
						b.box(x + r(-2, 2), r(-4, hh - 8), zz + 2.05, 0.6, 0.8, 0.1, pick(r, WINDOW_LIT), "neon")
					end
				end
			end
		end
	end

	function SETS.market(b, r, time)
		local t = TIMES[time] or TIMES.night
		b.box(0, -0.5, 0, 70, 1, 30, { 40, 38, 42 }, "concrete")
		-- the stalls along the back: a counter, an awning, a pole and the goods
		for i = -5, 5 do
			local x = i * 5.2
			local awning = pick(r, { { 170, 50, 50 }, { 60, 110, 160 }, { 200, 150, 50 }, { 70, 130, 90 }, { 150, 80, 150 } })
			b.box(x, 1.1, -4.6, 4.6, 2.2, 1.6, { 82, 62, 46 }, "wood")
			b.box(x, 3.9, -4.2, 5, 0.25, 2.6, awning, "fabric")
			b.box(x - 2.3, 2.6, -5.4, 0.18, 5.2, 0.18, { 60, 60, 64 }, "metal")
			for k = -2, 2 do
				if r() < 0.7 then
					b.box(x + k * 0.8, 2.45, -4.4, 0.6, 0.5, 0.5, pick(r, { { 220, 120, 60 }, { 120, 180, 80 }, { 230, 210, 140 }, { 200, 60, 70 } }), "plastic")
				end
			end
		end
		-- the lantern string over the lane, and the light it puts down
		b.box(0, 6.1, -1.5, 52, 0.05, 0.05, { 40, 40, 40 }, "metal")
		for i = -12, 12 do
			b.ball(i * 2.1, 5.9 + math.sin(i * 0.7) * 0.2, -1.5, 0.45, pick(r, { { 255, 170, 80 }, { 255, 110, 90 }, { 255, 220, 140 } }), "neon")
		end
		b.cyl(0, 0.03, 0.2, 14, 0.02, { 255, 190, 120 }, "neon", 0.88)
		-- crates out front at the edges
		b.box(-12, 0.6, 1.8, 1.4, 1.2, 1.2, { 110, 86, 60 }, "wood")
		b.box(-10.6, 0.45, 2.2, 1, 0.9, 1, { 96, 74, 52 }, "wood")
		b.box(12, 0.5, 2, 2.2, 1, 1.2, { 90, 70, 50 }, "wood")
		-- the buildings above the stalls
		for i = -6, 6 do
			b.building(i * 9 + r(-1, 1), -12, r(7, 9), r(14, 26), 6, { 40, 36, 44 }, r, 0.35)
		end
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end

	function SETS.docks(b, r, time)
		local t = TIMES[time] or TIMES.night
		-- the planks of a pier, the black water past them
		for i = -14, 14 do
			b.box(i * 1.6, -0.3, -0.5, 1.5, 0.6, 12, if i % 2 == 0 then { 92, 70, 52 } else { 84, 64, 48 }, "wood")
		end
		b.box(0, -1.4, -30, 200, 0.4, 50, { 14, 22, 34 }, "glass", 0.1)
		for _, x in { -14, -7, 7, 14 } do
			b.cyl(x, 0.5, -6, 0.8, 1, { 50, 52, 56 }, "metal") -- bollards
		end
		-- containers stacked behind
		for i = -3, 3 do
			b.box(i * 6.4, 1.6, -9, 6, 3.2, 2.6, pick(r, { { 150, 60, 40 }, { 50, 90, 130 }, { 160, 130, 50 }, { 70, 110, 80 } }), "metal")
			if r() < 0.6 then
				b.box(i * 6.4 + r(-1, 1), 4.8, -9, 6, 3.2, 2.6, pick(r, { { 120, 50, 40 }, { 40, 70, 110 }, { 140, 110, 40 } }), "metal")
			end
		end
		-- a crane, and lights on the far shore
		b.box(-20, 12, -24, 1, 24, 1, { 180, 150, 40 }, "metal")
		b.box(-14, 23.5, -24, 14, 0.8, 0.8, { 180, 150, 40 }, "metal")
		for i = -20, 20 do
			if r() < 0.5 then
				b.box(i * 4, 0.5, -60, 0.8, 0.6, 0.2, pick(r, WINDOW_LIT), "neon")
			end
		end
		b.lamp(6, -4.5)
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end

	function SETS.subway(b, r, time)
		local t = TIMES.inside
		-- an underground platform: tiles, the yellow line, the rails below, a stopped car
		b.box(0, -0.5, 0, 70, 1, 10, { 120, 118, 110 }, "concrete")
		b.box(0, 0.01, -3.4, 70, 0.02, 0.4, { 230, 200, 60 }, "plastic")
		b.box(0, -1.6, -7.5, 70, 0.6, 6, { 40, 38, 36 }, "concrete")
		for _, z in { -6.4, -8.6 } do
			b.box(0, -1.2, z, 70, 0.2, 0.2, { 120, 120, 126 }, "metal")
		end
		b.box(-6, 1.8, -7.6, 26, 4.4, 3, { 150, 158, 166 }, "metal")
		for i = -5, 5 do
			b.box(-6 + i * 2.3, 2.6, -6.05, 1.6, 1.2, 0.1, { 220, 236, 255 }, "neon", 0.2)
		end
		b.box(-6, 0.6, -6.05, 26, 0.3, 0.12, { 200, 60, 50 }, "plastic")
		-- the tiled wall across the tracks, a timetable board, the ceiling lights
		b.box(0, 3, -10.5, 70, 9, 0.6, { 200, 196, 184 }, "plastic")
		b.box(12, 4.6, -10.1, 6, 1.6, 0.1, { 30, 30, 34 }, "plastic")
		b.box(12, 4.6, -10.0, 5.6, 0.3, 0.05, { 255, 170, 60 }, "neon")
		for i = -6, 6 do
			b.box(i * 5, 7.2, -2, 3, 0.15, 0.4, { 236, 244, 255 }, "neon")
		end
		b.box(0, 7.6, -3, 70, 0.4, 14, { 90, 90, 96 }, "concrete")
		for _, x in { -12, 12 } do
			b.box(x, 3.6, -1.5, 1, 7.2, 1, { 170, 166, 156 }, "concrete")
		end
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end

	function SETS.factory(b, r, time)
		local t = TIMES.inside
		-- a Workshop floor after hours: presses, a conveyor, chains, embers still glowing
		b.box(0, -0.5, 0, 60, 1, 24, { 64, 62, 58 }, "concrete")
		b.box(0, 7, -6, 60, 14, 0.8, { 76, 70, 64 }, "metal")
		for i = -4, 4 do
			local x = i * 6
			b.box(x, 2.2, -4.2, 2.6, 4.4, 2, { 90, 96, 100 }, "metal")
			b.box(x, 4.8, -4.2, 1.2, 0.8, 1.2, { 60, 64, 68 }, "metal")
			b.box(x + 0.9, 2.6, -3.15, 0.3, 0.3, 0.1, pick(r, { { 255, 90, 40 }, { 90, 255, 120 }, { 255, 200, 60 } }), "neon")
		end
		b.box(0, 1, -1.9, 60, 0.3, 1.2, { 40, 40, 44 }, "metal")
		for i = -14, 14 do
			if r() < 0.4 then
				b.box(i * 2, 1.35, -1.9, 0.9, 0.4, 0.7, { 150, 120, 80 }, "wood")
			end
		end
		for _, x in { -9, -2, 5, 12 } do
			b.box(x, 9, -2.5, 0.12, 6, 0.12, { 120, 120, 126 }, "metal")
			b.box(x, 5.9, -2.5, 0.6, 0.6, 0.6, { 70, 70, 76 }, "metal")
		end
		for _ = 1, 10 do
			b.ball(r(-14, 14), r(0.1, 0.4), r(-1, 2), 0.15, { 255, 150, 60 }, "neon")
		end
		b.box(0, 12.6, -1, 60, 0.6, 14, { 50, 48, 46 }, "metal")
		for i = -3, 3 do
			b.box(i * 8, 12, -1, 2.4, 0.2, 2.4, { 255, 230, 180 }, "neon")
		end
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end

	function SETS.bridge(b, r, time)
		local t = TIMES[time] or TIMES.night
		-- a steel bridge over a canal: the deck, the trusses, the rail and the drop
		b.box(0, -0.5, 0, 80, 1, 12, { 46, 46, 52 }, "concrete")
		for _, z in { -5.6, 5.6 } do
			b.box(0, 0.9, z, 80, 0.2, 0.2, { 110, 110, 118 }, "metal")
			for i = -20, 20 do
				b.box(i * 2, 0.45, z, 0.12, 0.9, 0.12, { 110, 110, 118 }, "metal")
			end
		end
		for i = -8, 8 do
			b.box(i * 5, 5, -6.2, 0.6, 10, 0.6, { 70, 80, 96 }, "metal")
			b.box(i * 5 + 2.5, 5.5, -6.2, 0.4, 11, 0.4, { 70, 80, 96 }, "metal")
		end
		b.box(0, 10.2, -6.2, 84, 0.8, 0.8, { 70, 80, 96 }, "metal")
		b.box(0, -14, -30, 200, 0.4, 60, { 12, 20, 30 }, "glass", 0.15)
		for i = -3, 3 do
			b.lamp(i * 12, -5)
		end
		skyline(b, r, -50, 2)
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end

	function SETS.construction(b, r, time)
		local t = TIMES[time] or TIMES.night
		-- a tower going up: bare girders, scaffolding, sand, tape and a crane hook
		b.box(0, -0.5, 0, 60, 1, 24, { 70, 64, 56 }, "concrete")
		for i = -4, 4 do
			b.box(i * 5, 8, -6, 0.5, 16, 0.5, { 160, 80, 40 }, "metal")
		end
		for lvl = 1, 4 do
			b.box(0, lvl * 4, -6, 44, 0.5, 0.5, { 160, 80, 40 }, "metal")
		end
		for i = -3, 3 do
			b.box(i * 6 + 2, 2.5, -3.6, 0.15, 5, 0.15, { 140, 140, 150 }, "metal")
			b.box(i * 6 + 2, 3, -3.6, 3, 0.15, 1, { 120, 90, 60 }, "wood")
		end
		b.box(-13, 0.6, 1.6, 4, 1.2, 3, { 180, 160, 110 }, "concrete")
		b.box(0, 0.6, -2.6, 30, 0.08, 0.08, { 255, 210, 40 }, "neon")
		b.box(12, 0.9, 1.8, 2.4, 1.8, 1.6, { 230, 160, 40 }, "metal")
		b.box(12.2, 1.5, 2.65, 0.3, 0.3, 0.05, { 90, 255, 120 }, "neon")
		b.box(4, 9, -2, 0.1, 10, 0.1, { 60, 60, 64 }, "metal")
		b.box(4, 4, -2, 0.8, 0.6, 0.4, { 200, 160, 40 }, "metal")
		for _, x in { -14, 14 } do
			b.box(x, 3.5, -1, 0.2, 7, 0.2, { 60, 60, 64 }, "metal")
			b.box(x, 7, -1, 1.2, 0.5, 0.8, { 255, 240, 200 }, "neon")
			b.cyl(x, 0.03, 0.5, 9, 0.02, { 255, 240, 210 }, "neon", 0.88)
		end
		skyline(b, r, -40, 2)
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end

	function SETS.noodle(b, r, time)
		local t = TIMES.inside
		-- a noodle shop near closing: the counter, stools, the pots, paper lanterns
		b.box(0, -0.5, 0, 40, 1, 16, { 96, 70, 52 }, "wood")
		b.box(0, 4.5, -5.5, 40, 9, 0.6, { 140, 110, 80 }, "wood")
		b.box(0, 1.2, -3.8, 22, 2.4, 1.4, { 120, 80, 52 }, "wood")
		b.box(0, 2.45, -3.8, 22.4, 0.12, 1.6, { 70, 44, 30 }, "wood")
		for i = -4, 4 do
			b.cyl(i * 2.4, 0.9, -2.4, 0.9, 0.12, { 170, 40, 40 }, "fabric")
			b.cyl(i * 2.4, 0.45, -2.4, 0.2, 0.9, { 60, 60, 64 }, "metal")
		end
		for i = -3, 3 do
			b.cyl(i * 3, 3, -4.6, 1, 1.2, { 200, 200, 196 }, "metal")
			b.ball(i * 3, 4, -4.6, 0.9, { 230, 230, 230 }, "plastic", 0.7)
		end
		for i = -4, 4 do
			b.ball(i * 2.6, 6.4, -3, 0.8, { 255, 120, 80 }, "neon")
		end
		b.box(0, 7.6, -5.1, 9, 1.2, 0.1, { 30, 20, 16 }, "wood")
		b.box(0, 7.6, -5.0, 8, 0.6, 0.05, { 255, 210, 120 }, "neon")
		b.box(-14, 3.5, -5.1, 5, 4, 0.1, { 40, 60, 90 }, "glass", 0.4)
		b.cyl(0, 0.04, -1, 12, 0.02, { 255, 200, 140 }, "neon", 0.88)
		return { time = t, marks = { left = -2.2, right = 2.2 } }
	end

	function SETS.library(b, r, time)
		local t = TIMES.inside
		-- a reading floor: tall shelves, a gallery above, warm lamps, a long table at the back
		b.box(0, -0.5, 0, 60, 1, 24, { 110, 76, 52 }, "wood")
		for i = -4, 4 do
			local x = i * 5
			b.box(x, 6, -5.6, 4.6, 12, 1.2, { 70, 46, 32 }, "wood")
			for row = 0, 7 do
				local y = 0.9 + row * 1.35
				local k = -2
				while k < 1.9 do
					local w = r(0.6, 1.2)
					b.box(x + k + w / 2, y + 0.45, -4.95, w, r(0.7, 1), 0.4, pick(r, { { 140, 40, 40 }, { 40, 70, 120 }, { 60, 100, 60 }, { 150, 120, 60 }, { 90, 60, 110 }, { 200, 190, 170 } }), "plastic")
					k += w + 0.08
				end
			end
		end
		b.box(0, 12.6, -2, 60, 0.6, 12, { 80, 56, 40 }, "wood")
		b.box(0, 13.4, 3.9, 60, 0.15, 0.15, { 200, 170, 90 }, "metal")
		b.box(0, 0.9, -3, 10, 0.2, 1.6, { 100, 66, 44 }, "wood")
		for _, x in { -3.5, 3.5 } do
			b.box(x, 1.4, -3, 0.3, 0.8, 0.3, { 60, 50, 40 }, "metal")
			b.ball(x, 1.95, -3, 0.5, { 255, 220, 150 }, "neon")
		end
		for i = -3, 3 do
			b.ball(i * 8, 10.5, -1, 1, { 255, 226, 170 }, "neon")
		end
		b.cyl(0, 0.04, 0, 16, 0.02, { 255, 214, 160 }, "neon", 0.9)
		return { time = t, marks = { left = -2.2, right = 2.2 } }
	end

	function SETS.warehouse(b, r, time)
		local t = TIMES.inside
		b.box(0, -0.5, 0, 64, 1, 28, { 70, 70, 74 }, "concrete")
		b.box(0, 8, -9, 64, 16, 0.8, { 90, 92, 96 }, "metal")
		-- racks of crates
		for i = -4, 4 do
			local x = i * 7
			for lvl = 0, 2 do
				b.box(x, lvl * 2.6 + 0.2, -6.5, 5.4, 0.2, 2.2, { 200, 110, 40 }, "metal")
				for k = -1, 1 do
					if r() < 0.75 then
						b.box(x + k * 1.7, lvl * 2.6 + 1.1, -6.5, 1.4, 1.5, 1.6, pick(r, { { 150, 116, 80 }, { 130, 100, 70 }, { 90, 110, 140 } }), "wood")
					end
				end
			end
			b.box(x - 2.7, 3.6, -6.5, 0.2, 7.4, 2.2, { 50, 80, 140 }, "metal")
			b.box(x + 2.7, 3.6, -6.5, 0.2, 7.4, 2.2, { 50, 80, 140 }, "metal")
		end
		-- a roll-up door, a forklift, the high lamps
		b.box(-14, 4, -8.5, 7, 7, 0.2, { 110, 112, 118 }, "metal")
		for k = 0, 9 do
			b.box(-14, 0.8 + k * 0.7, -8.4, 7, 0.06, 0.1, { 80, 82, 88 }, "metal")
		end
		b.box(13, 1.1, -1.5, 2.2, 1.4, 3, { 220, 170, 40 }, "metal")
		b.box(13, 2.6, -2.4, 0.2, 3.2, 0.2, { 40, 40, 44 }, "metal")
		b.box(13, 0.6, -3.4, 1.8, 0.12, 1.2, { 60, 60, 64 }, "metal")
		for i = -3, 3 do
			b.box(i * 9, 15, -2, 3, 0.3, 1, { 255, 240, 210 }, "neon")
		end
		b.cyl(0, 0.04, 0, 14, 0.02, { 255, 240, 214 }, "neon", 0.9)
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end

	function SETS.sewer(b, r, time)
		local t = TIMES.night
		-- under the streets: a walkway by a channel of dark water, pipes, a grate of light above
		b.box(0, -0.5, 0, 70, 1, 8, { 62, 66, 60 }, "concrete")
		b.box(0, -1.6, -6.5, 70, 0.4, 5, { 30, 46, 40 }, "glass", 0.2)
		b.box(0, 4, -10, 70, 12, 1, { 54, 60, 54 }, "concrete")
		b.box(0, 9, -5, 70, 1, 12, { 46, 50, 46 }, "concrete")
		b.box(0, 7, -9.2, 70, 0.7, 0.7, { 100, 90, 70 }, "metal")
		b.box(0, 2, -9.3, 70, 0.4, 0.4, { 80, 74, 60 }, "metal")
		b.box(6, 8.55, -1, 3, 0.1, 3, { 160, 200, 255 }, "neon", 0.4)
		b.cyl(6, 0.03, -1, 5, 0.02, { 170, 210, 255 }, "neon", 0.85)
		for i = -5, 5 do
			b.ball(i * 6 + r(-1, 1), -1.3, -6.5, 0.4, { 120, 255, 170 }, "neon", 0.5)
		end
		b.box(-12, 0.04, 1, 0.2, 0.02, 6, { 120, 180, 140 }, "neon", 0.6)
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end

	function SETS.plaza(b, r, time)
		local t = TIMES[time] or TIMES.night
		-- a Nest plaza: white stone, a fountain, glass towers, a screen with the rankings on it
		for i = -10, 10 do
			for k = -2, 2 do
				b.box(i * 3, -0.5, k * 3 - 2, 2.95, 1, 2.95, if (i + k) % 2 == 0 then { 214, 214, 220 } else { 196, 198, 206 }, "plastic")
			end
		end
		b.cyl(0, 0.5, -8, 6, 1, { 200, 204, 210 }, "concrete")
		b.cyl(0, 0.9, -8, 5.4, 0.2, { 120, 180, 230 }, "glass", 0.3)
		b.cyl(0, 2, -8, 0.6, 3, { 220, 224, 230 }, "concrete")
		b.ball(0, 3.8, -8, 1.2, { 180, 220, 255 }, "neon", 0.5)
		for i = -5, 5 do
			local x = i * 9 + r(-1, 1)
			local hgt = r(30, 70)
			b.box(x, hgt / 2, -26, r(6, 8), hgt, 6, { 70, 90, 120 }, "glass", 0.2)
			for _ = 1, 6 do
				b.box(x + r(-2.5, 2.5), r(2, hgt - 2), -22.9, 0.8, 0.5, 0.1, { 220, 236, 255 }, "neon")
			end
		end
		b.box(14, 9, -20, 10, 5.6, 0.4, { 20, 24, 30 }, "plastic")
		b.box(14, 9, -19.75, 9.4, 5, 0.05, { 80, 200, 255 }, "neon", 0.25)
		for _, x in { -12, 12 } do
			b.lamp(x, -3)
		end
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end

	function SETS.trainyard(b, r, time)
		local t = TIMES[time] or TIMES.night
		-- a freight yard: rails, sleepers, boxcars, a signal, light masts
		b.box(0, -0.5, 0, 80, 1, 30, { 64, 58, 54 }, "concrete")
		for _, z in { -3.5, -7.5, 3.5 } do
			for _, dz in { -0.7, 0.7 } do
				b.box(0, 0.08, z + dz, 80, 0.15, 0.15, { 140, 130, 120 }, "metal")
			end
			for i = -26, 26 do
				b.box(i * 1.5, 0.02, z, 0.3, 0.06, 2.2, { 70, 54, 40 }, "wood")
			end
		end
		for i = -3, 3 do
			b.box(i * 9.5, 2.2, -7.5, 9, 3.6, 2.8, pick(r, { { 120, 50, 36 }, { 60, 80, 100 }, { 100, 90, 60 } }), "metal")
			b.box(i * 9.5, 2.2, -6.08, 2.4, 2.6, 0.06, { 40, 40, 44 }, "metal")
		end
		b.box(10, 2.5, -3.2, 0.25, 5, 0.25, { 50, 50, 54 }, "metal")
		b.ball(10, 5, -3.2, 0.5, { 255, 60, 50 }, "neon")
		b.ball(10, 4.3, -3.2, 0.5, { 60, 60, 60 }, "plastic")
		for i = -4, 4 do
			b.box(i * 10, 9, -14, 0.4, 18, 0.4, { 50, 50, 54 }, "metal")
			b.box(i * 10, 18, -14, 2, 0.6, 1, { 255, 236, 200 }, "neon")
		end
		skyline(b, r, -36, 2)
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end

	function SETS.greenhouse(b, r, time)
		local t = TIMES[time] or TIMES.night
		-- a glasshouse on a Nest roof: planters in rows, panes overhead, grow-lights
		b.box(0, -0.5, 0, 50, 1, 22, { 120, 112, 100 }, "concrete")
		for i = -4, 4 do
			b.box(i * 5, 0.6, -4.5, 4, 1.2, 1.6, { 90, 66, 48 }, "wood")
			for k = -1, 1 do
				b.ball(i * 5 + k * 1.2, 1.6, -4.5, r(0.8, 1.3), pick(r, { { 60, 140, 70 }, { 80, 160, 60 }, { 50, 120, 80 } }), "plastic")
			end
			b.box(i * 5, 6, -4.5, 3, 0.2, 0.6, { 255, 120, 220 }, "neon")
		end
		for i = -5, 5 do
			b.box(i * 5, 5, -7, 0.2, 10, 0.2, { 220, 224, 230 }, "metal")
		end
		b.box(0, 5, -7.2, 52, 10, 0.1, { 180, 220, 230 }, "glass", 0.7)
		b.box(0, 10, -1, 52, 0.1, 14, { 180, 220, 230 }, "glass", 0.8)
		skyline(b, r, -30, 2)
		b.cyl(0, 0.03, 0, 12, 0.02, { 255, 170, 230 }, "neon", 0.9)
		return { time = t, marks = { left = -2.2, right = 2.2 } }
	end

	function SETS.office(b, r, time)
		local t = TIMES.inside
		-- an Office after hours: desks, filing cabinets, the board of open contracts, blinds
		b.box(0, -0.5, 0, 44, 1, 18, { 92, 84, 74 }, "wood")
		b.box(0, 4.5, -5.5, 44, 9, 0.6, { 170, 160, 140 }, "plastic")
		for _, x in { -9, 9 } do
			b.box(x, 1.1, -3.4, 4, 0.2, 2, { 110, 80, 56 }, "wood")
			b.box(x, 0.55, -3.4, 3.6, 1.1, 1.6, { 90, 64, 44 }, "wood")
			b.box(x + 0.8, 1.6, -3.6, 1.2, 0.8, 0.1, { 40, 44, 50 }, "plastic")
			b.box(x + 0.8, 1.6, -3.55, 1, 0.6, 0.05, { 120, 220, 160 }, "neon", 0.3)
			b.box(x - 1.2, 1.25, -3.2, 0.9, 0.1, 0.6, { 230, 226, 210 }, "plastic")
		end
		for i = -2, 2 do
			b.box(i * 1.1 - 15, 1.5, -4.8, 1, 3, 1, { 120, 124, 130 }, "metal")
		end
		b.box(0, 4.6, -5.1, 7, 3.6, 0.1, { 120, 90, 60 }, "wood")
		for _ = 1, 9 do
			b.box(r(-3, 3), r(3.2, 6), -5.0, 0.8, 1, 0.05, pick(r, { { 240, 236, 220 }, { 250, 230, 170 }, { 230, 210, 210 } }), "plastic")
		end
		for _, x in { -15, 15 } do
			b.box(x, 5, -5.1, 6, 4, 0.1, { 30, 40, 60 }, "glass", 0.3)
			for k = 0, 7 do
				b.box(x, 3.2 + k * 0.5, -5.0, 6, 0.08, 0.05, { 200, 190, 170 }, "plastic")
			end
		end
		b.box(0, 8.4, -1, 1.6, 0.2, 1.6, { 255, 236, 200 }, "neon")
		b.cyl(0, 0.03, 0, 10, 0.02, { 255, 236, 200 }, "neon", 0.9)
		return { time = t, marks = { left = -2.2, right = 2.2 } }
	end

	function SETS.parking(b, r, time)
		local t = TIMES.inside
		-- a parking deck: a low concrete ceiling, pillars, painted bays, two cars
		b.box(0, -0.5, 0, 70, 1, 30, { 86, 86, 90 }, "concrete")
		b.box(0, 6.5, -2, 70, 0.8, 30, { 96, 96, 100 }, "concrete")
		for i = -6, 6 do
			b.box(i * 5.5, 0.02, -5, 0.15, 0.02, 4.5, { 230, 230, 230 }, "plastic")
			if i % 2 == 0 then
				b.box(i * 5.5, 3, -9, 1.1, 6, 1.1, { 120, 120, 124 }, "concrete")
				b.box(i * 5.5, 1.2, -8.43, 1.12, 0.4, 0.02, { 230, 200, 40 }, "plastic")
			end
		end
		for _, x in { -11, 8.25 } do
			local col = pick(r, { { 160, 40, 40 }, { 40, 70, 120 }, { 200, 200, 196 }, { 30, 30, 34 } })
			b.box(x, 0.8, -5, 2.4, 1, 4.4, col, "metal")
			b.box(x, 1.6, -5.2, 2.1, 0.8, 2.4, col, "metal")
			b.box(x, 1.6, -5.2, 2.15, 0.6, 2.2, { 60, 80, 100 }, "glass", 0.4)
		end
		for i = -4, 4 do
			b.box(i * 8, 6, -2, 2.8, 0.15, 0.4, { 230, 240, 255 }, "neon")
		end
		b.box(0, 3, -12, 70, 6, 0.4, { 50, 50, 54 }, "concrete")
		b.box(18, 4.5, -11.7, 3, 0.9, 0.1, { 90, 255, 120 }, "neon")
		return { time = t, marks = { left = -2.4, right = 2.4 } }
	end

	function SETS.arcade(b, r, time)
		local t = TIMES.inside
		-- an arcade in a basement: cabinets in a row, every screen lit, a loud carpet
		b.box(0, -0.5, 0, 50, 1, 20, { 46, 30, 60 }, "fabric")
		b.box(0, 5, -6, 50, 10, 0.6, { 30, 24, 40 }, "plastic")
		for i = -7, 7 do
			local x = i * 2.8
			b.box(x, 1.6, -4.6, 1.8, 3.2, 1.4, { 26, 26, 34 }, "plastic")
			b.box(x, 2.3, -3.88, 1.4, 1, 0.05, pick(r, NEON), "neon", 0.15)
			b.box(x, 3.05, -3.9, 1.6, 0.3, 0.05, pick(r, NEON), "neon")
		end
		for _ = 1, 10 do
			b.box(r(-20, 20), 0.01, r(-3, 3), r(0.4, 1.2), 0.01, r(0.4, 1.2), pick(r, NEON), "neon", 0.6)
		end
		b.box(0, 8.6, -5.6, 12, 1.4, 0.1, { 255, 70, 140 }, "neon")
		return { time = t, marks = { left = -2.2, right = 2.2 } }
	end
end
