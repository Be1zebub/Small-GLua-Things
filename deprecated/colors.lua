-- deprecated
-- use https://github.com/Be1zebub/Color.lua instead

local function ColorToCMYK(col)
	local K = math.max(col.r, col.g, col.b)
	local k = 255 - K
	return (K - col.r) / K, (K - col.g) / K, (K - col.b) / K, k
end

local color_formats = {
	{
		name = "rgb",
		tostring = function(c)
			return string.format("%s, %s, %s", c.r, c.g, c.b)
		end,
		tocolor = function(s)
			local r, g, b = s:match("([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)")

			if r and g and b then
				return Color(r, g, b)
			end
		end
	},
	{
		name = "hex",
		tostring = function(c)
    		return string.format("%x", (c.r * 0x10000) + (c.g * 0x100) + c.b):upper()
		end,
		tocolor = function(s)
			s = s:gsub("#", "")
    		local r, g, b = tonumber("0x".. s:sub(1,2)), tonumber("0x".. s:sub(3,4)), tonumber("0x".. s:sub(5,6))

    		if r and g and b then
				return Color(r, g, b)
			end
		end
	},
	{
		name = "hsl",
		tostring = function(c)
			local h, s, l = ColorToHSL(c)
			return string.format("%s, %s, %s", math.Round(h, 2), math.Round(s, 2), math.Round(l, 2))
		end,
		tocolor = function(s)
			local h, s, l = s:match("([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)")

			if h and s and l then
				return HSLToColor(h, s, l)
			end
		end
	},
	{
		name = "hsv",
		tostring = function(c)
			local h, s, v = ColorToHSV(c)
			return string.format("%s, %s, %s", math.Round(h, 2), math.Round(s, 2), math.Round(v, 2))
		end,
		tocolor = function(s)
			local h, s, v = s:match("([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)")

			if h and s and v then
				return HSVToColor(h, s, v)
			end
		end
	},
	{
		name = "cmyk",
		tostring = function(c)
			local c, m, y, k = ColorToCMYK(c)
			return string.format("%s, %s, %s, %s", math.Round(c, 1), math.Round(m, 1), math.Round(y, 1), math.Round(k, 1))
		end,
		tocolor = function(s)
			local c, m, y, k = s:match("([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)[ ,]+([-x.%x]+)")
			if not (c and m and y and k) then return end

			local mk = (1 - k)
			local r = 255 * (1 - c) * mk
			local g = 255 * (1 - m) * mk
			local b = 255 * (1 - y) * mk

		    return Color(r, g, b)
		end
	}
}
