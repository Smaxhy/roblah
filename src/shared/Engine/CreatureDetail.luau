--[[
	THE DETAIL PASS for creatures (Engine/Creatures calls it on every creature it builds).

	Every big block gets a darker band round its foot and a lighter lip along its top, and every
	big ball a darker underside. The creature then reads as lit from above and built out of
	something, instead of out of flat colors. The added parts carry the same `anim` group as the
	part they belong to, so they move with it.

		local parts = Detail.apply(parts)

	Pure Luau, like Creatures: plain tables in, plain tables out.
]]

local Detail = {}

local sin, cos, rad = math.sin, math.cos, math.rad

-- the same rotation Creatures uses for a part's `rot` (degrees, applied like CFrame.Angles)
local function euler(rx: number, ry: number, rz: number): { number }
	local ca, sa = cos(rad(rx)), sin(rad(rx))
	local cb, sb = cos(rad(ry)), sin(rad(ry))
	local cc, sc = cos(rad(rz)), sin(rad(rz))
	return {
		cb * cc, -cb * sc, sb,
		ca * sc + sa * sb * cc, ca * cc - sa * sb * sc, -sa * cb,
		sa * sc - ca * sb * cc, sa * cc + ca * sb * sc, ca * cb,
	}
end

local function turned(m: { number }?, x: number, y: number, z: number): (number, number, number)
	if not m then
		return x, y, z
	end
	return m[1] * x + m[2] * y + m[3] * z, m[4] * x + m[5] * y + m[6] * z, m[7] * x + m[8] * y + m[9] * z
end

local function shade(c: { number }, f: number): { number }
	return {
		math.clamp(math.floor(c[1] * f + 0.5), 0, 255),
		math.clamp(math.floor(c[2] * f + 0.5), 0, 255),
		math.clamp(math.floor(c[3] * f + 0.5), 0, 255),
	}
end

function Detail.apply(parts: any): any
	local out: any = {}
	for _, p: any in parts do
		table.insert(out, p)
		local plain: boolean = p.material ~= "neon" and not p.transparency and p.name ~= "Ground" and p.color ~= nil
		if plain and p.shape == "box" then
			local sx: number, sy: number, sz: number = p.size[1], p.size[2], p.size[3]
			if sy >= 0.6 and sx >= 0.6 and sz >= 0.45 and sx * sy * sz >= 0.9 then
				local m: { number }? = if p.rot then euler(p.rot[1], p.rot[2], p.rot[3]) else nil
				local dx, dy, dz = turned(m, 0, -sy * 0.5 + sy * 0.1, 0)
				table.insert(out, {
					name = (p.name or "Part") .. "Shade",
					shape = "box",
					size = { sx * 1.03, sy * 0.2, sz * 1.03 },
					pos = { p.pos[1] + dx, p.pos[2] + dy, p.pos[3] + dz },
					rot = p.rot,
					color = shade(p.color, 0.66),
					material = p.material,
					anim = p.anim,
				})
				local ux, uy, uz = turned(m, 0, sy * 0.5 - sy * 0.035, 0)
				table.insert(out, {
					name = (p.name or "Part") .. "Lip",
					shape = "box",
					size = { sx * 1.03, sy * 0.07, sz * 1.03 },
					pos = { p.pos[1] + ux, p.pos[2] + uy, p.pos[3] + uz },
					rot = p.rot,
					color = shade(p.color, 1.28),
					material = p.material,
					anim = p.anim,
				})
			end
		elseif plain and p.shape == "ball" then
			local d: number = math.min(p.size[1], p.size[2], p.size[3])
			if d >= 1 then
				table.insert(out, {
					name = (p.name or "Part") .. "Under",
					shape = "ball",
					size = { p.size[1] * 0.96, p.size[2] * 0.96, p.size[3] * 0.96 },
					pos = { p.pos[1], p.pos[2] - d * 0.07, p.pos[3] },
					rot = p.rot,
					color = shade(p.color, 0.68),
					material = p.material,
					anim = p.anim,
				})
			end
		end
	end
	return out
end

return Detail
