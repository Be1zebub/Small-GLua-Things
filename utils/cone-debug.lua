-- debug ents.FindInCone

local upcoming = {}

function debugoverlay.Cone(origin, normal, range, angleCos, ttl)
	local uid = debug.traceback()

	if isnumber(ttl) == false or ttl < 0.01 then
		ttl = 0.1
	end

	upcoming[uid] = {
		uid = uid,
		ttl = CurTime() + ttl,
		origin = origin,
		normal = normal:GetNormalized(),
		range = range,
		angleCos = angleCos
	}
end

local segments = 32

local mat = Material("models/shiny")
mat:SetFloat("$alpha", 0.25)

hook.Add("PostDrawOpaqueRenderables", "debugoverlay.Cone", function()
	if next(upcoming) == nil then return end

	for key, data in pairs(upcoming) do
		local startPos = data.origin
		local dir = data.normal
		local size = data.range
		local angleCos = data.angleCos

		local radius = math.tan(math.acos(angleCos)) * size
		local endPos = startPos + dir * size

		render.SetMaterial(mat)
		render.DrawSphere(startPos, size, 24, 16, color_white, true)

		local mins = Vector(-size, -size, -size)
		local maxs = Vector(size, size, size)
		render.DrawWireframeBox(startPos, angle_zero, mins, maxs, color_white, true)
		render.DrawBox(startPos, angle_zero, -mins, -maxs, color_white)

		local up = Vector(0, 0, 1)
		if math.abs(dir:Dot(up)) > 0.99 then
			up = Vector(1, 0, 0)
		end

		local right = dir:Cross(up)
		right:Normalize()

		up = right:Cross(dir)
		up:Normalize()

		render.SetColorMaterial()

		for i = 0, segments - 1 do
			local a1 = (i / segments) * math.pi * 2
			local a2 = ((i + 1) / segments) * math.pi * 2

			local p1 = endPos + (right * math.cos(a1) + up * math.sin(a1)) * radius
			local p2 = endPos + (right * math.cos(a2) + up * math.sin(a2)) * radius

			render.DrawBeam(p1, p2, 2, 0, 1, Color(17, 163, 204, 50))
			render.DrawBeam(startPos, p1, 2, 0, 1, Color(0, 124, 158, 50))
		end

		render.DrawLine(startPos, endPos, Color(0, 255, 0), true)

		for _, ent in ipairs(ents.FindInCone(startPos, dir, size, angleCos)) do
			render.DrawLine(
				startPos,
				ent:WorldSpaceCenter(),
				Color(255, 0, 0),
				true
			)
		end

		if data.ttl < CurTime() then
			upcoming[key] = nil
		end
	end
end)
