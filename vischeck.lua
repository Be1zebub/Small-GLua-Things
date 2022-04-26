-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/vischeck.lua

local ENTITY = FindMetaTable("Entity")

function ENTITY:GetPositionDegress(pos)
    local diff = pos - self:EyePos()
    diff:Normalize()

    return math.abs(math.deg(math.acos(self:EyeAngles():Forward():Dot(diff))))
end

function ENTITY:IsScreenVisible(ent, degrees)
	return self:GetPositionDegress(ent:EyePos()) < (degrees or 90)
end

function ENTITY:InTrace(ent)
	return util.TraceLine({
		start = ent:EyePos(),
		endpos = self:EyePos()
	}).Entity == self
end

local _maxDist = 512 ^ 2
function ENTITY:CanSee(ent, maxDist)
	return self:EyePos():DistToSqr(ent:EyePos()) < (maxDist or _maxDist) and self:IsLineOfSightClear(ent:EyePos()) and self:IsScreenVisible(ent)
end
