--[[
	MORE CREATURES (v0.17): twelve new shapes for Engine/Creatures.luau, registered through its
	own `register` (Creatures.luau calls this module with it), drawn with the same builder.
	Original designs in the City's spirit: the Night's Sweepers, a Distortion that became a
	clocktower, an ALEPH-class thing out of containment, and the strange things of the
	Backstreets, the Outskirts and the Great Lake.

		clockwork   a clocktower with a face, turning gears and a swinging pendulum
		aleph       a tall pale figure with one eye and a halo of reaching arms
		sweeper     a hunched figure in a long coat, a beaked mask and a hooked pole
		spiderdoll  a porcelain doll's head on six thin legs
		shadowhound a lean dark hound with three pairs of eyes
		moth        a great moth with eye-spots on its wings, drawn to lamps
		jellyfish   a drifting bell with trailing, glowing threads
		stitched    a stitched-together giant with button eyes and one huge fist
		eyestalks   a mound covered in waving eyes on stalks
		scrapgolem  furniture and appliances that stood up: a fridge, a television, pipes
		bloomer     a flower taller than a person, smiling with too many teeth
		whale       a whale that swims through the air over the Great Lake
]]

return function(register, lib)
	local BRASS, STEEL, IRON, BONE, SOOT = lib.BRASS, lib.STEEL, lib.IRON, lib.BONE, lib.SOOT
	local shade, mix = lib.shade, lib.mix

	-- ── CLOCKWORK ───────────────────────────────────────────────────────────────
	register("clockwork", { color = { 120, 96, 60 }, eye = { 255, 230, 160 } }, nil, function(b, ctx)
		local iron = ctx.body
		local dark = shade(iron, 0.55)
		local eye, eyeMat = b:lit(ctx.eye)
		b:group("root", { 0, 0, 0 }, function()
			b:group("body", { 0, 1.0, 0 }, function()
				b:box("Base", { 3.2, 1.0, 3.2 }, { 0, 0.5, 0 }, dark, "metal")
				b:box("Tower", { 2.4, 4.4, 2.4 }, { 0, 3.2, 0 }, iron, "metal")
				b:box("Roof", { 2.9, 0.4, 2.9 }, { 0, 5.6, 0 }, dark, "metal")
				b:box("Spire", { 0.7, 1.4, 0.7 }, { 0, 6.4, 0 }, BRASS, "metal", { 0, 45, 0 })
				b:disc("Face", { 0, 4.2, -1.24 }, { 0, 0, -1 }, 2.0, 0.12, BONE, "plastic")
				for i = 0, 11 do
					local a = i * math.pi / 6
					b:box("Tick", { 0.08, 0.22, 0.04 }, { math.sin(a) * 0.82, 4.2 + math.cos(a) * 0.82, -1.32 }, SOOT, "plastic", { 0, 0, -i * 30 })
				end
				b:group("hands", { 0, 4.2, -1.36 }, function()
					b:box("HourHand", { 0.13, 0.62, 0.05 }, { 0, 4.47, -1.36 }, SOOT, "metal")
					b:box("MinuteHand", { 0.08, 0.86, 0.05 }, { 0.3, 4.52, -1.38 }, SOOT, "metal", { 0, 0, -40 })
				end)
				b:group("eye", { 0, 4.2, -1.42 }, function()
					b:ball("Eye", 0.36, { 0, 4.2, -1.42 }, eye, eyeMat)
				end)
				for _, side in { -1, 1 } do
					local g = if side < 0 then "gearL" else "gearR"
					b:group(g, { 1.26 * side, 2.6, 0 }, function()
						b:disc("Gear", { 1.26 * side, 2.6, 0 }, { side, 0, 0 }, 1.4, 0.16, BRASS, "metal")
						for t = 0, 7 do
							local a = t * math.pi / 4
							b:box("Tooth", { 0.12, 0.32, 0.32 }, { 1.3 * side, 2.6 + math.cos(a) * 0.74, math.sin(a) * 0.74 }, BRASS, "metal", { math.deg(a), 0, 0 })
						end
					end)
					b:spin(g, { 1, 0, 0 }, 0.25 * side)
				end
				b:group("pendulum", { 0, 3.0, -1.3 }, function()
					b:rod("Rod", { 0, 3.0, -1.3 }, { 0, 1.5, -1.3 }, 0.08, BRASS, "metal")
					b:disc("Bob", { 0, 1.35, -1.34 }, { 0, 0, -1 }, 0.62, 0.1, BRASS, "metal")
				end)
				b:face({ 0, 4.2, -1.3 }, 2.4)
			end)
		end)
		b.angle = 20
		b.height = 7.2
		b:spin("hands", { 0, 0, 1 }, -0.2)
		b:swing("pendulum", { 0, 0, 1 }, 18, 0.5)
		b:glow("eye", "pulse", 0.4)
		if ctx.pose == "strike" then
			b:shift("root", 0, 0, -1.0)
			b:turn("body", 10)
		elseif ctx.pose == "hurt" then
			b:turn("body", -6, 0, 6)
		elseif ctx.pose == "down" then
			b:turn("body", 0, 0, 80)
			b:shift("root", 0, -0.6, 0)
		end
	end)

	-- ── ALEPH ───────────────────────────────────────────────────────────────────
	register("aleph", { color = { 230, 228, 236 }, eye = { 255, 80, 80 } }, nil, function(b, ctx)
		local pale, dim = ctx.body, shade(ctx.body, 0.78)
		local eye, eyeMat = b:lit(ctx.eye)
		b:group("root", { 0, 3, 0 }, function()
			b:group("body", { 0, 3, 0 }, function()
				for i = 0, 4 do
					local w = 1.7 - i * 0.24
					b:box("Robe", { w, 1.0, w * 0.8 }, { 0, 0.9 + i * 0.92, 0 }, if i % 2 == 0 then pale else dim, "plastic")
				end
				b:group("head", { 0, 5.6, 0 }, function()
					b:ball("Head", 1.3, { 0, 5.95, 0 }, pale, "plastic")
					b:ball("Eye", 0.72, { 0, 5.95, -0.42 }, eye, eyeMat)
					b:ball("Pupil", 0.28, { 0, 5.95, -0.78 }, SOOT, "plastic")
				end)
				b:group("halo", { 0, 5.95, 0.6 }, function()
					for i = 0, 9 do
						local a = i * math.pi / 5
						local out = { math.cos(a) * 2.6, 5.95 + math.sin(a) * 2.6, 0.7 }
						b:rod("Arm", { math.cos(a) * 0.9, 5.95 + math.sin(a) * 0.9, 0.62 }, out, 0.12, dim, "plastic")
						b:ball("Hand", 0.32, out, pale, "plastic")
					end
					b:disc("Ring", { 0, 5.95, 0.64 }, { 0, 0, 1 }, 2.2, 0.08, eye, eyeMat)
				end)
				b:face({ 0, 5.95, -0.5 }, 1.6)
			end)
		end)
		b.angle = 8
		b.height = 8.8
		b:bob("root", 0.3, 0.35)
		b:spin("halo", { 0, 0, 1 }, 0.08)
		b:glow("head", "pulse", 0.5)
		if ctx.pose == "strike" then
			b:shift("root", 0, 0, -1.4)
			b:turn("head", 15)
		elseif ctx.pose == "hurt" then
			b:turn("body", -10, 0, 8)
		elseif ctx.pose == "down" then
			b:turn("body", 0, 0, 90)
			b:shift("root", 0, -2.4, 0)
		end
	end)

	-- ── SWEEPER ─────────────────────────────────────────────────────────────────
	register("sweeper", { color = { 30, 30, 36 }, eye = { 236, 70, 52 } }, nil, function(b, ctx)
		local coat, dark = ctx.body, shade(ctx.body, 0.6)
		local eye, eyeMat = b:lit(ctx.eye)
		b:group("root", { 0, 2.5, 0 }, function()
			b:group("body", { 0, 2.5, 0 }, function()
				b:box("CoatSkirt", { 1.9, 2.8, 1.4 }, { 0, 1.4, 0.1 }, coat, "fabric")
				b:box("Chest", { 1.7, 1.8, 1.2 }, { 0, 3.6, 0.2 }, coat, "fabric", { 14, 0, 0 })
				b:box("Collar", { 1.9, 0.6, 1.4 }, { 0, 4.4, 0.3 }, dark, "fabric", { 14, 0, 0 })
				b:group("head", { 0, 4.6, -0.1 }, function()
					b:box("Hood", { 1.2, 1.2, 1.2 }, { 0, 5.0, 0.0 }, dark, "fabric")
					b:box("Mask", { 0.9, 0.8, 0.2 }, { 0, 4.9, -0.62 }, BONE, "plastic")
					b:bone("Beak", { 0, 4.8, -0.7 }, { 0, 4.35, -1.7 }, 0.24, 0.3, BONE, "plastic")
					for _, side in { -1, 1 } do
						b:ball("Eye", 0.18, { 0.22 * side, 5.0, -0.74 }, eye, eyeMat)
					end
					b:box("HatBrim", { 1.9, 0.08, 1.9 }, { 0, 5.62, 0 }, SOOT, "fabric")
					b:box("HatCrown", { 1.0, 0.5, 1.0 }, { 0, 5.9, 0 }, SOOT, "fabric")
				end)
				b:group("pole", { 0.9, 3.4, -0.2 }, function()
					b:rod("Pole", { 0.95, 0.2, -0.4 }, { 0.95, 6.4, -0.2 }, 0.1, IRON, "metal")
					b:bone("Hook", { 0.95, 6.4, -0.2 }, { 0.95, 6.0, -1.1 }, 0.1, 0.1, STEEL, "metal")
					b:bone("HookTip", { 0.95, 6.0, -1.1 }, { 0.95, 5.5, -1.2 }, 0.08, 0.08, STEEL, "metal")
				end)
				b:group("lamp", { -0.9, 2.6, -0.3 }, function()
					b:rod("LampChain", { -0.95, 3.2, -0.3 }, { -0.95, 2.6, -0.3 }, 0.04, IRON, "metal")
					b:box("Lamp", { 0.36, 0.48, 0.36 }, { -0.95, 2.35, -0.3 }, { 255, 170, 90 }, "neon")
				end)
				b:face({ 0, 4.9, -0.7 }, 1.6)
			end)
		end)
		b.angle = 22
		b.height = 6.6
		b:bob("body", 0.06, 0.4)
		b:swing("lamp", { 0, 0, 1 }, 10, 0.6)
		b:swing("head", { 0, 1, 0 }, 12, 0.3)
		b:glow("lamp", "flicker", 0.7)
		if ctx.pose == "strike" then
			b:shift("root", 0, 0, -1.2)
			b:turn("pole", -55)
		elseif ctx.pose == "hurt" then
			b:turn("body", -10, 0, 8)
		elseif ctx.pose == "down" then
			b:turn("body", 0, 0, 88)
			b:shift("root", 0, -1.6, 0)
		end
	end)

	-- ── SPIDER DOLL ─────────────────────────────────────────────────────────────
	register("spiderdoll", { color = { 240, 226, 218 }, eye = { 120, 200, 255 } }, nil, function(b, ctx)
		local porcelain = ctx.body
		local dress = { 150, 40, 70 }
		local eye, eyeMat = b:lit(ctx.eye)
		b:group("root", { 0, 2.2, 0 }, function()
			b:group("body", { 0, 2.2, 0 }, function()
				b:ball("Head", 2.0, { 0, 2.6, 0 }, porcelain, "plastic")
				b:box("Bonnet", { 2.2, 0.5, 2.0 }, { 0, 3.5, 0.2 }, dress, "fabric")
				b:box("Ribbon", { 0.5, 0.4, 0.4 }, { 0.9, 3.4, -0.3 }, dress, "fabric", { 0, 0, 30 })
				for _, side in { -1, 1 } do
					b:disc("Eye", { 0.4 * side, 2.75, -0.95 }, { 0, 0, -1 }, 0.42, 0.06, eye, eyeMat)
					b:box("Lash", { 0.34, 0.05, 0.05 }, { 0.42 * side, 3.0, -0.95 }, SOOT, "plastic", { 0, 0, -12 * side })
					b:ball("Cheek", 0.26, { 0.55 * side, 2.35, -0.86 }, { 236, 150, 150 }, "plastic")
				end
				b:box("Mouth", { 0.3, 0.06, 0.05 }, { 0, 2.15, -0.98 }, { 120, 40, 50 }, "plastic")
				b:box("Crack", { 0.05, 0.7, 0.04 }, { -0.35, 2.4, -0.97 }, SOOT, "plastic", { 0, 0, 24 })
				for i = 1, 3 do
					for _, side in { -1, 1 } do
						local z = (i - 2) * 0.55
						local g = "leg" .. i .. (if side < 0 then "L" else "R")
						b:group(g, { 0.6 * side, 2.0, z }, function()
							b:bone("Leg", { 0.6 * side, 2.0, z }, { 2.0 * side, 3.0, z * 1.6 }, 0.12, 0.12, porcelain, "plastic")
							b:bone("Leg", { 2.0 * side, 3.0, z * 1.6 }, { 2.4 * side, 0.05, z * 2.0 }, 0.1, 0.1, porcelain, "plastic")
						end)
						b:swing(g, { 0, 0, 1 }, 6, 1.1, i * 0.3 + (if side < 0 then 0 else 0.5))
					end
				end
				b:face({ 0, 2.7, -1.0 }, 2.2)
			end)
		end)
		b.angle = 24
		b.height = 4.4
		b:bob("body", 0.12, 0.9)
		b:swing("body", { 0, 0, 1 }, 6, 0.5)
		if ctx.pose == "strike" then
			b:shift("root", 0, 0.6, -1.4)
			b:turn("body", 20)
		elseif ctx.pose == "hurt" then
			b:turn("body", -18, 0, 12)
		elseif ctx.pose == "down" then
			b:turn("body", 0, 0, 160)
			b:shift("root", 0, -0.4, 0)
		end
	end)

	-- ── SHADOW HOUND ────────────────────────────────────────────────────────────
	register("shadowhound", { color = { 24, 22, 30 }, eye = { 200, 120, 255 } }, nil, function(b, ctx)
		local fur, dark = ctx.body, shade(ctx.body, 0.6)
		local eye, eyeMat = b:lit(ctx.eye)
		b:group("root", { 0, 1.8, 0 }, function()
			b:group("body", { 0, 1.8, 0 }, function()
				b:box("Chest", { 1.6, 1.6, 1.8 }, { 0, 2.2, -0.6 }, fur, "fabric")
				b:box("Back", { 1.3, 1.2, 2.2 }, { 0, 2.1, 1.2 }, fur, "fabric")
				for i = 0, 5 do
					b:box("Spike", { 0.16, 0.7, 0.3 }, { 0, 3.0 + (i % 2) * 0.1, -1.0 + i * 0.5 }, dark, "plastic", { -20, 0, 0 })
				end
				for _, side in { -1, 1 } do
					for _, z in { -1.0, 1.6 } do
						local g = "leg" .. (if side < 0 then "L" else "R") .. tostring(z)
						b:group(g, { 0.55 * side, 1.6, z }, function()
							b:bone("Leg", { 0.55 * side, 1.6, z }, { 0.6 * side, 0.08, z - 0.2 }, 0.32, 0.32, dark, "fabric")
						end)
						b:swing(g, { 1, 0, 0 }, 10, 0.9, if z < 0 then 0 else 0.5)
					end
				end
				b:group("head", { 0, 2.6, -1.4 }, function()
					b:box("Skull", { 1.1, 0.9, 1.3 }, { 0, 2.7, -2.0 }, fur, "fabric")
					b:box("Snout", { 0.7, 0.5, 0.9 }, { 0, 2.45, -2.9 }, dark, "fabric")
					for _, side in { -1, 1 } do
						b:box("Ear", { 0.2, 0.6, 0.3 }, { 0.4 * side, 3.35, -1.8 }, dark, "fabric", { 0, 0, 12 * side })
						for row = 0, 2 do
							b:ball("Eye", 0.16, { (0.28 + row * 0.08) * side, 2.95 - row * 0.18, -2.62 + row * 0.12 }, eye, eyeMat)
						end
					end
					for i = -2, 2 do
						b:box("Tooth", { 0.07, 0.16, 0.06 }, { i * 0.12, 2.2, -3.3 }, BONE, "plastic")
					end
				end)
				b:group("tail", { 0, 2.4, 2.3 }, function()
					b:bone("Tail", { 0, 2.4, 2.3 }, { 0, 3.3, 3.4 }, 0.26, 0.26, dark, "fabric")
					b:bone("Wisp", { 0, 3.3, 3.4 }, { 0, 3.9, 3.7 }, 0.12, 0.12, eye, eyeMat)
				end)
				b:face({ 0, 2.8, -2.6 }, 1.6)
			end)
		end)
		b.angle = 34
		b.height = 4.2
		b:bob("body", 0.06, 0.5)
		b:swing("tail", { 1, 0, 0 }, 14, 0.8)
		b:glow("head", "blink", 0.2)
		if ctx.pose == "strike" then
			b:shift("root", 0, 0.3, -1.6)
			b:turn("head", -18)
		elseif ctx.pose == "hurt" then
			b:turn("body", -8, 0, 10)
			b:shift("root", 0, 0, 0.6)
		elseif ctx.pose == "down" then
			b:turn("body", 0, 0, 86)
			b:shift("root", 0, -0.9, 0)
		end
	end)

	-- ── MOTH ────────────────────────────────────────────────────────────────────
	register("moth", { color = { 170, 150, 120 }, eye = { 255, 220, 120 } }, nil, function(b, ctx)
		local dust, dark = ctx.body, shade(ctx.body, 0.6)
		local eye, eyeMat = b:lit(ctx.eye)
		b:group("root", { 0, 3.5, 0 }, function()
			b:group("body", { 0, 3.5, 0 }, function()
				b:ball("Thorax", 1.1, { 0, 3.6, 0 }, dark, "fabric")
				b:ball("Abdomen", 1.0, { 0, 3.0, 0.7 }, dust, "fabric")
				b:ball("Abdomen", 0.8, { 0, 2.5, 1.2 }, dark, "fabric")
				b:ball("Head", 0.7, { 0, 4.1, -0.5 }, dust, "fabric")
				b:ball("Fur", 0.9, { 0, 3.9, -0.2 }, mix(dust, { 255, 255, 255 }, 0.3), "fabric")
				for _, side in { -1, 1 } do
					b:ball("Eye", 0.3, { 0.24 * side, 4.15, -0.75 }, SOOT, "plastic")
					b:rod("Antenna", { 0.15 * side, 4.4, -0.6 }, { 0.8 * side, 5.4, -1.0 }, 0.06, dark, "plastic")
					local g = if side < 0 then "wingL" else "wingR"
					b:group(g, { 0.4 * side, 3.7, 0 }, function()
						b:box("Wing", { 2.8, 0.06, 2.2 }, { 1.8 * side, 3.9, -0.2 }, dust, "fabric", { 0, 0, -14 * side })
						b:box("Wing", { 2.0, 0.06, 1.6 }, { 1.4 * side, 3.3, 1.0 }, dark, "fabric", { 0, 0, -26 * side })
						b:disc("Spot", { 2.0 * side, 3.97, -0.3 }, { 0, 1, 0 }, 0.9, 0.04, eye, eyeMat)
						b:disc("SpotCore", { 2.0 * side, 4.0, -0.3 }, { 0, 1, 0 }, 0.4, 0.04, SOOT, "plastic")
					end)
					b:swing(g, { 0, 0, 1 }, 26, 1.6, if side < 0 then 0 else 0.5)
				end
				b:face({ 0, 4.1, -0.7 }, 1.4)
			end)
		end)
		b.angle = 14
		b.height = 5.6
		b:bob("root", 0.35, 0.9)
		b:glow("body", "pulse", 0.5)
		if ctx.pose == "strike" then
			b:shift("root", 0, 0.4, -1.6)
		elseif ctx.pose == "hurt" then
			b:turn("body", -16, 0, 14)
		elseif ctx.pose == "down" then
			b:turn("body", 0, 0, 90)
			b:shift("root", 0, -3.0, 0)
		end
	end)

	-- ── JELLYFISH ───────────────────────────────────────────────────────────────
	register("jellyfish", { color = { 150, 190, 240 }, eye = { 150, 255, 230 } }, nil, function(b, ctx)
		local bell = ctx.body
		local eye, eyeMat = b:lit(ctx.eye)
		b:group("root", { 0, 4.0, 0 }, function()
			b:group("bell", { 0, 4.6, 0 }, function()
				b:ball("Bell", 2.8, { 0, 4.8, 0 }, bell, "plastic")
				b:box("Rim", { 2.9, 0.3, 2.9 }, { 0, 4.0, 0 }, shade(bell, 0.8), "plastic")
				for i = 0, 5 do
					local a = i * math.pi / 3
					b:ball("Light", 0.32, { math.cos(a) * 0.8, 4.9, math.sin(a) * 0.8 }, eye, eyeMat)
				end
			end)
			for i = 0, 7 do
				local a = i * math.pi / 4
				local x, z = math.cos(a) * 1.1, math.sin(a) * 1.1
				local g = "thread" .. i
				b:group(g, { x, 3.9, z }, function()
					b:rod("Thread", { x, 3.9, z }, { x * 1.15, 1.7, z * 1.15 }, 0.08, shade(bell, 1.2), "plastic")
					b:rod("Thread", { x * 1.15, 1.7, z * 1.15 }, { x * 0.9, 0.3, z * 0.9 }, 0.06, eye, eyeMat)
				end)
				b:swing(g, { 1, 0, 1 }, 10, 0.4, i * 0.12)
			end
			b:face({ 0, 4.8, -1.2 }, 2.4)
		end)
		b.angle = 10
		b.height = 6.4
		b:bob("root", 0.5, 0.4)
		b:glow("bell", "pulse", 0.4)
		if ctx.pose == "strike" then
			b:shift("root", 0, -0.6, -1.4)
		elseif ctx.pose == "hurt" then
			b:turn("root", -12, 0, 10)
		elseif ctx.pose == "down" then
			b:shift("root", 0, -3.4, 0)
			b:turn("root", 0, 0, 30)
		end
	end)

	-- ── STITCHED GIANT ──────────────────────────────────────────────────────────
	register("stitched", { color = { 186, 150, 132 }, eye = { 40, 34, 34 } }, nil, function(b, ctx)
		local skin, cloth = ctx.body, { 90, 84, 70 }
		local thread = { 30, 26, 24 }
		b:group("root", { 0, 3.0, 0 }, function()
			b:group("body", { 0, 3.0, 0 }, function()
				for _, side in { -1, 1 } do
					b:box("Leg", { 1.0, 2.2, 1.0 }, { 0.65 * side, 1.1, 0 }, cloth, "fabric")
				end
				b:box("Torso", { 3.0, 2.6, 1.8 }, { 0, 3.5, 0 }, skin, "plastic")
				b:box("Patch", { 1.3, 1.1, 0.06 }, { -0.6, 3.8, -0.92 }, shade(skin, 0.8), "plastic")
				for i = 0, 5 do
					b:box("Stitch", { 0.06, 0.24, 0.06 }, { -1.25 + i * 0.25, 3.25, -0.95 }, thread, "plastic", { 0, 0, 30 })
				end
				b:box("Seam", { 3.02, 0.06, 0.06 }, { 0, 3.25, -0.92 }, thread, "plastic")
				b:group("head", { 0, 4.8, -0.2 }, function()
					b:box("Head", { 1.0, 1.0, 1.0 }, { 0, 5.3, -0.2 }, skin, "plastic")
					b:disc("Button", { -0.24, 5.4, -0.72 }, { 0, 0, -1 }, 0.3, 0.06, { 40, 34, 34 }, "plastic")
					b:disc("Button", { 0.24, 5.4, -0.72 }, { 0, 0, -1 }, 0.22, 0.06, { 150, 40, 40 }, "plastic")
					b:box("Mouth", { 0.5, 0.05, 0.05 }, { 0, 5.05, -0.72 }, thread, "plastic")
					for i = -2, 2 do
						b:box("Stitch", { 0.04, 0.16, 0.05 }, { i * 0.1, 5.05, -0.73 }, thread, "plastic")
					end
				end)
				b:group("armL", { -1.6, 4.4, 0 }, function()
					b:bone("Arm", { -1.6, 4.4, 0 }, { -1.9, 2.8, -0.2 }, 0.7, 0.7, skin, "plastic")
					b:box("Hand", { 0.7, 0.7, 0.7 }, { -1.95, 2.4, -0.2 }, skin, "plastic")
				end)
				b:group("armR", { 1.6, 4.4, 0 }, function()
					b:bone("Arm", { 1.6, 4.4, 0 }, { 2.1, 2.6, -0.3 }, 1.0, 1.0, shade(skin, 0.9), "plastic")
					b:box("Fist", { 1.5, 1.5, 1.5 }, { 2.2, 1.9, -0.3 }, shade(skin, 0.85), "plastic")
					b:box("Seam", { 1.52, 0.06, 0.06 }, { 2.2, 2.3, -1.06 }, thread, "plastic")
				end)
				b:face({ 0, 5.3, -0.7 }, 1.6)
			end)
		end)
		b.angle = 22
		b.height = 6.2
		b:bob("body", 0.08, 0.35)
		b:swing("armR", { 1, 0, 0 }, 6, 0.35)
		b:swing("head", { 0, 0, 1 }, 8, 0.25)
		if ctx.pose == "strike" then
			b:shift("root", 0, 0, -1.0)
			b:turn("armR", -70)
		elseif ctx.pose == "hurt" then
			b:turn("body", -8, 0, 8)
		elseif ctx.pose == "down" then
			b:turn("body", 0, 0, 84)
			b:shift("root", 0, -1.6, 0)
		end
	end)

	-- ── EYESTALKS ───────────────────────────────────────────────────────────────
	register("eyestalks", { color = { 90, 60, 80 }, eye = { 255, 230, 90 } }, nil, function(b, ctx)
		local flesh = ctx.body
		local eye, eyeMat = b:lit(ctx.eye)
		local rng = ctx.rng
		b:group("root", { 0, 0, 0 }, function()
			b:group("body", { 0, 1.2, 0 }, function()
				b:ball("Mound", 3.4, { 0, 1.2, 0 }, flesh, "plastic")
				b:ball("Mound", 2.2, { 0.8, 1.9, 0.6 }, shade(flesh, 1.15), "plastic")
				for i = 1, 7 do
					local a = i * 0.9 + rng.range(-0.2, 0.2)
					local r = 0.9 + rng.range(0, 0.6)
					local base = { math.cos(a) * r, 2.0, math.sin(a) * r - 0.2 }
					local top = { base[1] * 1.5, 3.2 + rng.range(0, 1.4), base[3] * 1.3 - 0.5 }
					local g = "stalk" .. i
					b:group(g, base, function()
						b:rod("Stalk", base, top, 0.18, shade(flesh, 0.9), "plastic")
						b:ball("Eyeball", 0.6, top, BONE, "plastic")
						b:ball("Iris", 0.3, { top[1], top[2], top[3] - 0.22 }, eye, eyeMat)
						b:ball("Pupil", 0.12, { top[1], top[2], top[3] - 0.34 }, SOOT, "plastic")
					end)
					b:swing(g, { 1, 0, 1 }, 14, 0.4 + rng.range(0, 0.4), rng.range(0, 1))
				end
				b:face({ 0, 3.6, -1.0 }, 2.6)
			end)
		end)
		b.angle = 18
		b.height = 5.4
		b:bob("body", 0.1, 0.3)
		b:glow("body", "blink", 0.15)
		if ctx.pose == "strike" then
			b:shift("root", 0, 0, -0.8)
			b:turn("body", 14)
		elseif ctx.pose == "hurt" then
			b:turn("body", -10, 0, 6)
		elseif ctx.pose == "down" then
			b:shift("root", 0, -0.8, 0)
			b:turn("body", 0, 0, 40)
		end
	end)

	-- ── SCRAP GOLEM ─────────────────────────────────────────────────────────────
	register("scrapgolem", { color = { 200, 200, 196 }, eye = { 120, 255, 160 } }, nil, function(b, ctx)
		local enamel = ctx.body
		local eye, eyeMat = b:lit(ctx.eye)
		b:group("root", { 0, 2.6, 0 }, function()
			b:group("body", { 0, 2.6, 0 }, function()
				for _, side in { -1, 1 } do
					b:rod("Pipe", { 0.6 * side, 2.0, 0 }, { 0.7 * side, 0.4, 0 }, 0.4, IRON, "metal")
					b:cyl("Wheel", 0.9, 0.3, { 0.7 * side, 0.45, 0 }, SOOT, "plastic", { 0, 0, 90 })
				end
				b:box("Fridge", { 2.0, 2.6, 1.4 }, { 0, 3.2, 0 }, enamel, "plastic")
				b:box("Handle", { 0.12, 1.0, 0.12 }, { 0.75, 3.5, -0.76 }, STEEL, "metal")
				b:box("Door", { 1.96, 0.05, 1.42 }, { 0, 3.8, 0 }, shade(enamel, 0.8), "plastic")
				b:group("head", { 0, 4.5, 0 }, function()
					b:box("TV", { 1.6, 1.2, 1.2 }, { 0, 5.1, 0 }, { 70, 56, 44 }, "wood")
					b:box("Screen", { 1.2, 0.85, 0.05 }, { -0.1, 5.1, -0.62 }, eye, eyeMat)
					b:rod("Aerial", { 0.2, 5.7, 0 }, { 0.7, 6.5, 0.2 }, 0.04, STEEL, "metal")
					b:rod("Aerial", { -0.2, 5.7, 0 }, { -0.8, 6.4, 0.1 }, 0.04, STEEL, "metal")
					b:box("Knob", { 0.14, 0.14, 0.08 }, { 0.62, 4.85, -0.62 }, BRASS, "metal")
				end)
				for _, side in { -1, 1 } do
					local g = if side < 0 then "armL" else "armR"
					b:group(g, { 1.0 * side, 4.0, 0 }, function()
						b:rod("Arm", { 1.0 * side, 4.0, 0 }, { 1.6 * side, 2.6, -0.3 }, 0.32, IRON, "metal")
						b:box("Claw", { 0.6, 0.5, 0.6 }, { 1.7 * side, 2.3, -0.35 }, STEEL, "metal")
					end)
					b:swing(g, { 1, 0, 0 }, 8, 0.5, if side < 0 then 0 else 0.5)
				end
				b:face({ 0, 5.1, -0.7 }, 1.8)
			end)
		end)
		b.angle = 24
		b.height = 6.6
		b:bob("body", 0.06, 0.6)
		b:glow("head", "flicker", 0.6)
		if ctx.pose == "strike" then
			b:shift("root", 0, 0, -1.0)
			b:turn("armR", -60)
			b:turn("armL", -40)
		elseif ctx.pose == "hurt" then
			b:turn("body", -8, 0, 10)
		elseif ctx.pose == "down" then
			b:turn("body", 0, 0, 82)
			b:shift("root", 0, -1.4, 0)
		end
	end)

	-- ── BLOOMER ─────────────────────────────────────────────────────────────────
	register("bloomer", { color = { 220, 90, 130 }, eye = { 255, 240, 160 } }, nil, function(b, ctx)
		local petal = ctx.body
		local leaf = { 70, 130, 70 }
		local eye, eyeMat = b:lit(ctx.eye)
		b:group("root", { 0, 0, 0 }, function()
			b:group("stem", { 0, 0.4, 0 }, function()
				b:rod("Stem", { 0, 0.2, 0 }, { 0.2, 4.2, -0.2 }, 0.36, leaf, "plastic")
				for _, side in { -1, 1 } do
					b:box("Leaf", { 1.4, 0.08, 0.6 }, { 0.8 * side, 1.6 + (side + 1) * 0.4, 0 }, leaf, "plastic", { 0, 0, 24 * side })
				end
				b:group("head", { 0.2, 4.4, -0.2 }, function()
					b:disc("Center", { 0.2, 4.8, -0.5 }, { 0, 0, -1 }, 1.4, 0.3, { 120, 70, 40 }, "plastic")
					for i = 0, 9 do
						local a = i * math.pi / 5
						b:box("Petal", { 0.6, 1.1, 0.1 }, { 0.2 + math.sin(a) * 1.1, 4.8 + math.cos(a) * 1.1, -0.42 }, if i % 2 == 0 then petal else shade(petal, 1.2), "fabric", { 0, 0, -math.deg(a) })
					end
					b:box("Mouth", { 0.9, 0.36, 0.08 }, { 0.2, 4.55, -0.68 }, { 40, 10, 20 }, "plastic")
					for i = -3, 3 do
						b:box("Tooth", { 0.1, 0.14, 0.06 }, { 0.2 + i * 0.12, 4.68, -0.72 }, BONE, "plastic")
					end
					for _, side in { -1, 1 } do
						b:ball("Eye", 0.22, { 0.2 + 0.32 * side, 5.05, -0.7 }, eye, eyeMat)
					end
				end)
			end)
			b:face({ 0.2, 4.8, -0.7 }, 2.4)
		end)
		b.angle = 14
		b.height = 6.2
		b:swing("stem", { 0, 0, 1 }, 6, 0.4)
		b:swing("head", { 1, 0, 0 }, 8, 0.6)
		b:glow("head", "pulse", 0.5)
		if ctx.pose == "strike" then
			b:turn("stem", 22)
			b:turn("head", 20)
		elseif ctx.pose == "hurt" then
			b:turn("stem", -14, 0, 10)
		elseif ctx.pose == "down" then
			b:turn("stem", 0, 0, 80)
		end
	end)

	-- ── WHALE ───────────────────────────────────────────────────────────────────
	register("whale", { color = { 70, 90, 120 }, eye = { 255, 240, 200 } }, nil, function(b, ctx)
		local hide, belly = ctx.body, mix(ctx.body, { 220, 220, 210 }, 0.6)
		local eye, eyeMat = b:lit(ctx.eye)
		b:group("root", { 0, 3.6, 0 }, function()
			b:group("body", { 0, 3.6, 0 }, function()
				b:box("Head", { 3.0, 2.6, 3.2 }, { 0, 3.8, -1.6 }, hide, "plastic")
				b:box("Body", { 3.2, 2.8, 3.4 }, { 0, 3.8, 1.4 }, hide, "plastic")
				b:box("Body", { 2.4, 2.0, 2.6 }, { 0, 3.9, 4.2 }, hide, "plastic")
				b:box("Belly", { 2.6, 0.6, 6.4 }, { 0, 2.55, 0.4 }, belly, "plastic")
				for i = 0, 5 do
					b:box("Groove", { 2.64, 0.05, 0.08 }, { 0, 2.3, -2.2 + i * 0.6 }, shade(belly, 0.7), "plastic")
				end
				for _, side in { -1, 1 } do
					b:ball("Eye", 0.32, { 1.52 * side, 3.6, -2.0 }, eye, eyeMat)
					b:box("Fin", { 1.8, 0.16, 0.9 }, { 2.1 * side, 2.9, -0.2 }, shade(hide, 0.85), "plastic", { 0, 20 * side, -24 * side })
					b:ball("Barnacle", 0.3, { 1.3 * side, 4.6, 0.8 }, BONE, "plastic")
				end
				b:box("Mouth", { 3.04, 0.06, 2.6 }, { 0, 3.2, -1.8 }, SOOT, "plastic")
				b:group("tail", { 0, 3.9, 5.4 }, function()
					b:box("Stock", { 1.2, 1.0, 2.0 }, { 0, 3.9, 6.2 }, hide, "plastic")
					b:box("Fluke", { 3.4, 0.16, 1.2 }, { 0, 3.95, 7.4 }, shade(hide, 0.85), "plastic")
				end)
				b:face({ 0, 3.8, -3.2 }, 3.2)
			end)
		end)
		b.angle = 50
		b.height = 6.4
		b:bob("root", 0.4, 0.25)
		b:swing("tail", { 1, 0, 0 }, 14, 0.35)
		b:swing("body", { 0, 0, 1 }, 4, 0.25)
		if ctx.pose == "strike" then
			b:shift("root", 0, 0, -2.0)
			b:turn("body", 10)
		elseif ctx.pose == "hurt" then
			b:turn("body", -8, 0, 12)
		elseif ctx.pose == "down" then
			b:shift("root", 0, -2.8, 0)
			b:turn("body", 0, 0, 160)
		end
	end)
end
