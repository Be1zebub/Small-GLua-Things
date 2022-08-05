-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/damage_types.lua

local DamageName = {}

for key, val in pairs(_G) do
	if isstring(key) and key:StartWith("DMG_") then
		DamageName[val] = key:sub(5):lower():gsub("^%l", string.upper)
	end
end

local CTakeDamageInfo = FindMetaTable("CTakeDamageInfo")

function CTakeDamageInfo:GetTypes(raw)
	local types, type = {}, self:GetDamageType()

	for enum, name in next, DamageName do
		if bit.band(type, enum) ~= 0 then
			types[#types + 1] = raw and enum or name
		end
	end

	return types
end

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
