-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/hash_color.lua

-- local color = HashColor("github.com")

local function CRC32(any)
	if type(any) ~= "string" then
		any = tostring(any)
	end

	return tonumber(util.CRC(any))
end

return function(any, hashFunc, hslToColor)
	hashFunc = hashFunc or CRC32
	hslToColor = hslToColor or HSLToColor

	local hash = hashFunc(any)

	return hslToColor(
		hash % 360,
		hash % 100,
		(hash * 0.5) % 100
	)
end
