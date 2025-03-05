-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/damage-types.lua
-- ive did it to debug armor system

--[[ Usage example:
hook.Add("EntityTakeDamage", "PrintDamageTypes", function(target, dmg)
	if dmg:GetAttacker():IsPlayer() then
		dmg:GetAttacker():ChatPrint("youve deal damage: "..
			table.concat(dmg:GetTypes(), ", ")
		)
	end

	if target:IsPlayer() then
		target:ChatPrint("youve got damage: "..
			table.concat(dmg:GetTypes(), ", ")
		)
	end
end)
]]--

local enum2name = {}

for key, val in pairs(_G) do
	if isstring(key) and isnumber(val) and key:StartWith("DMG_") then
		enum2name[val] = key:sub(5):lower():gsub("^%l", string.upper)
	end
end

local CTakeDamageInfo = FindMetaTable("CTakeDamageInfo")

function CTakeDamageInfo:GetTypes(raw)
	local types, type = {}, self:GetDamageType()

	for enum, name in next, enum2name do
		if bit.band(type, enum) ~= 0 then
			types[#types + 1] = raw and enum or name
		end
	end

	return types
end











-- testingqqqq
