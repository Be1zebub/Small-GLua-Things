local hexadecimal, rgb, hex, index
local ipairs, tonumber = ipairs, tonumber
local string_sub, string_len, math_fmod, math_floor = string.sub, string.len, math.fmod, math.floor

local Color_Cache = {}

return function(...)
	rgb = {...}

	if Color_Cache[rgb] then
		return Color_Cache[rgb]
	end

	hexadecimal = "0x"

	for key, value in ipairs(rgb) do
		hex = ""

		while value > 0 do
			index = math_fmod(value, 16) + 1
			value = math_floor(value / 16)
			hex = string_sub("0123456789ABCDEF", index, index) .. hex			
		end

		if string_len(hex) == 0 then
			hex = "00"
		elseif string_len(hex) == 1 then
			hex = "0".. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	Color_Cache[rgb] = tonumber(hexadecimal)
	return Color_Cache[rgb]
end
