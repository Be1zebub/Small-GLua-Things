-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/better_tostring.lua

local VECTOR = FindMetaTable("Vector")

function VECTOR:__tostring()
	return "Vector(".. math.Round(self.x, 3) ..", ".. math.Round(self.y, 3) ..", ".. math.Round(self.z, 3) ..")"
end

local ANGLE = FindMetaTable("Angle")

function ANGLE:__tostring()
	return "Angle(".. math.Round(self.p, 3) ..", ".. math.Round(self.y, 3) ..", ".. math.Round(self.r, 3) ..")"
end
