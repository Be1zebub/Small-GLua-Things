-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/vischeck.lua

local ENTITY = FindMetaTable("Entity")

function ENTITY:GetViewAngle(pos)
    local diff = pos - self:EyePos()
    diff:Normalize()

    return math.abs(math.deg(math.acos(self:EyeAngles():Forward():Dot(diff))))
end

function ENTITY:InFov(ent, fov)
	return self:GetViewAngle(ent:EyePos()) < (fov or 88)
end

function ENTITY:InTrace(ent)
	return util.TraceLine({
		start = ent:EyePos(),
		endpos = self:EyePos()
	}).Entity == self
end

local _maxDist = 512 ^ 2
function ENTITY:IsScreenVisible(ent, maxDist, fov)
	return self:EyePos():DistToSqr(ent:EyePos()) < (maxDist or _maxDist) and self:IsLineOfSightClear(ent:EyePos()) and self:InFov(ent, fov)
end


--[[ for SENTs:
function ENT:Draw(f)
	self.LastDraw = FrameNumber()
	self:DrawModel(f)
end

function ENT:IsVisible()
	return self.LastDraw == FrameNumber()
end
]]--
