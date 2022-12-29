-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/hash_color.lua

-- local color = HashColor("github.com")

local function CRC32(any)
	if type(any) ~= "string" then
		any = tostring(any)
	end

	return tonumber(util.CRC(any))
end

return function(any, hashFunc, hsvToColor)
	hashFunc = hashFunc or CRC32
	hsvToColor = hsvToColor or HSVToColor

	local hash = hashFunc(any)

	return hsvToColor(
		hash % 360,
		hash % 100,
		hash % 100
	)
end
