-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/worldbounds.lua

local airdrop_model = "models/props_junk/plasticbucket001a.mdl"

local max_map_size = Vector(1, 1, 1) * 2 ^ 15
local function TraceDirection(pos, dir)
	return util.TraceLine({
		start = pos,
		endpos = pos + dir * max_map_size,
		mask = MASK_NPCWORLDSTATIC
	}).HitPos
end

local function GetSkyboxCorners()
	local skyz = TraceDirection(vector_origin, Vector(0, 0, 1))
	local skysidex = TraceDirection(skyz, Vector(0, 1, 0))
	local skysidey = TraceDirection(skyz, Vector(-1, 0, 0))
	return TraceDirection(skysidex, Vector(1, 0, 0)), TraceDirection(skysidey, Vector(0, -1, 0))
end

local function GetWorldBounds()
	local corner1, corner2 = GetSkyboxCorners()
	return corner1, corner2, TraceDirection(corner1, Vector(0, 0, -1)), TraceDirection(corner2, Vector(0, 0, -1))
end

local function RandomPos(mins, maxs)
	return mins + Vector(math.random(), math.random(), math.random()) * (maxs - mins)
end

local function GetRandomSkyPos()
	local corner1, corner2 = GetSkyboxCorners()
	return RandomPos(corner1, corner2)
end

local function GetRandomGroundPos()
	return TraceDirection(GetRandomSkyPos(), Vector(0, 0, -1))
end

local function Distance2Ground(pos)
	return util.TraceLine({
		start = pos,
		endpos = pos + dir * max_map_size,
		filter = function() return false end
	}).HitPos:DistToSqr(pos)
end

if SERVER then
	local airdrops = {}
	local i = 0

	local function AirdropTest()
		i = i + 1
		if i > 25 then i = 1 end

		if IsValid(airdrops[i]) then
			airdrops[i]:Remove()
		end

		local pos = GetRandomSkyPos()

		local airdrop = ents.Create("prop_physics")
		airdrop:SetModel(airdrop_model)

		if i % 2 == 0 then
			airdrop:SetPos(TraceDirection(pos, Vector(0, 0, -1)))
		else
			pos = pos - Vector(0, 0, airdrop:OBBMaxs().z)
			airdrop:SetPos(pos)
		end

		airdrop:Spawn()

		local phys = airdrop:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end

		airdrops[i] = airdrop
	end
	timer.Create("AirdropTest", 0.1, 0, AirdropTest)
	AirdropTest()
else
	local corner1, corner2, corner3, corner4 = GetWorldBounds()
	local sprite, sprite_color = Material("sprites/gmdm_pickups/light"), Color(175, 255, 255)
	local beam, beam_color = Material("cable/new_cable_lit"), Color(128, 50, 100)
	local airdrop_color = Color(0, 255, 0)

	hook.Add("PreDrawEffects", "SkyboxCorners", function()
		cam.IgnoreZ(true)
			render.SetMaterial(sprite)
			render.DrawSprite(corner1, 512, 512, sprite_color)
			render.DrawSprite(corner2, 512, 512, sprite_color)
			render.DrawSprite(corner3, 512, 512, sprite_color)
			render.DrawSprite(corner4, 512, 512, sprite_color)

			for i, airdrop in ipairs(ents.GetAll()) do
				if airdrop:GetModel() == airdrop_model then
					render.DrawSprite(airdrop:GetPos(), 512, 512, airdrop_color)
				end
			end

			render.SetMaterial(beam)
			render.DrawBeam(corner1, corner2, 8, 0, 12, beam_color)
			render.DrawBeam(corner1, corner3, 8, 0, 12, beam_color)
			render.DrawBeam(corner2, corner4, 8, 0, 12, beam_color)
			render.DrawBeam(corner3, corner4, 8, 0, 12, beam_color)
		cam.IgnoreZ(false)
	end)
end

--[[
function Airdrop:Spawn()
    local sky = GetRandomSkyPos()
    sky.z = sky.z - self:OBBMaxs().z - 500

    local dirNormal = Vector(math.Rand(-1, 1), math.Rand(-1, 1))
    local path = {
        start = TraceDirection(sky, dirNormal),
        endpos = TraceDirection(sky, -dirNormal)
    }

    self:SetPos(path.start)
    self:MoveTo(path.endpos)
    -- self:SetDropPos(path.start + (path.endpos - path.start) * 0.5)
end

function Airdrop:MoveTo(endpos, len)
    local start = self:GetPos()
    local shoulddrop = true

    return self:NewAnimation(len or 10, 0.5, function(frac)
        self:SetPos(start + (endpos - start) * frac)
        if shoulddrop and frac >= 0.5 then
            shoulddrop = false
            self:DropPlayer()
        end
    end)
end

function Airdrop:NewAnimation(len, ease, cback)
    return self.Animations[table.insert(self.Animations, {
        start = SysTime(),
        endtime = SysTime() + len,
        ease = ease or -1,
        cback = cback
    })]
end

function Airdrop:Init()
    self.Animations = {}
end

function Airdrop:Think()
    local time = SysTime()

    for i, anim in ipairs(self.Animations) do
        local frac = math.Clamp((time - anim.start) / (time - anim.endtime), 0, 1)

        if anim.ease < 0 then
            frac = frac ^ (1 - frac - 0.5)
        elseif anim.ease > 0 and anim.ease < 1 then
            frac = 1 - (1 - frac) ^ (1 / anim.ease)
        end

        anim.cback(frac)

        if frac == 1 then
            table.remove(self.Animations, i)
        end
    end
end
]]
