local hexadecimal, rgb, hex, index
local ipairs, tonumber = ipairs, tonumber
local string_sub, string_len, math_fmod, math_floor = string.sub, string.len, math.fmod, math.floor
local elems = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "A", "B", "C", "D", "E", "F"}
local len

local Color_Cache = {}

return function(r, g, b)
	rgb = {r, g, b}

	if Color_Cache[rgb] then
		return Color_Cache[rgb]
	end

	hexadecimal = "0x"

	for key, value in ipairs(rgb) do
		hex = ""

		while value > 0 do
			index = math_fmod(value, 16) + 1
			value = math_floor(value / 16)
			hex = elems[index] .. hex			
		end

		len = string_len(hex)
		if len == 0 then
			hex = "00"
		elseif len == 1 then
			hex = "0".. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	Color_Cache[rgb] = tonumber(hexadecimal)
	return Color_Cache[rgb]
end
