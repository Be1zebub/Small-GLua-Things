-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/better_tostring.lua

local format1_q = "%s(%q)"
local format3 = "%s(%s, %s, %s)"
local format4 = "%s(%s, %s, %s, %s)"

local VECTOR = FindMetaTable("Vector")

function VECTOR:__tostring()
	return format3:format("Vector", math.Round(self.x, 3), math.Round(self.y, 3), math.Round(self.z, 3))
end

local ANGLE = FindMetaTable("Angle")

function ANGLE:__tostring()
	return format3:format("Angle", math.Round(self.p, 3), math.Round(self.y, 3), math.Round(self.r, 3))
end

local MATERIAL = FindMetaTable("IMaterial")

function MATERIAL:__tostring()
	return format1_q:format(self:GetName())
end

local COLOR = FindMetaTable("Color")

function COLOR:__tostring()
	if self.a == 255 then
		return format3:format("Color", self.r, self.g, self.b)
	else
		format4:format("Color", self.r, self.g, self.b, self.a)
	end
end
