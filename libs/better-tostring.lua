-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/better-tostring.lua
-- preview: https://cdn.discordapp.com/attachments/676069143463723018/1042870078284234882/image.png

-- this script replace __tostring metatable event in gmod classes
-- it makes lua syntax output & does not output unnecessary args (eg Vector(1) == Vector(1, 0, 0))

local format1quote = "%s(%q)"
local format1 = "%s(%s)"
local format2 = "%s(%s, %s)"
local format3 = "%s(%s, %s, %s)"
local format4 = "%s(%s, %s, %s, %s)"

local VECTOR = FindMetaTable("Vector")

function VECTOR:__tostring()
	if self.z == 0 then
		if self.y == 0 then
			return format1:format("Vector", math.Round(self.x, 3))
		end

		return format2:format("Vector", math.Round(self.x, 3), math.Round(self.y, 3))
	end

	return format3:format("Vector", math.Round(self.x, 3), math.Round(self.y, 3), math.Round(self.z, 3))
end

local ANGLE = FindMetaTable("Angle")

function ANGLE:__tostring()
	if self.r == 0 then
		if self.y == 0 then
			return format1:format("Angle", math.Round(self.p, 3))
		end

		return format2:format("Angle", math.Round(self.p, 3), math.Round(self.y, 3))
	end

	return format3:format("Angle", math.Round(self.p, 3), math.Round(self.y, 3), math.Round(self.r, 3))
end

local MATERIAL = FindMetaTable("IMaterial")

function MATERIAL:__tostring()
	return format1quote:format("Material", self:GetName())
end

local COLOR = FindMetaTable("Color")

function COLOR:__tostring()
	if self.a == 255 then
		return format3:format("Color", self.r, self.g, self.b)
	end

	return format4:format("Color", self.r, self.g, self.b, self.a)
end

-- print("", Material("color"), "\n", Color(255, 0, 0), "\n", Vector(1, 2), "\n", Angle(3))
