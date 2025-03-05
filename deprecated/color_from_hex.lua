-- deprecated
-- use https://github.com/Be1zebub/Color.lua instead

-- #754fd6 > Color(117, 79, 214)

function ColorFromHex(hex, alpha)
    hex = hex:gsub("#", "")
    return Color(tonumber("0x".. hex:sub(1, 2)), tonumber("0x".. hex:sub(3, 4)), tonumber("0x".. hex:sub(5, 6)), alpha or 255)
end
