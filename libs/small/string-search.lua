-- from gmod.one with <3
-- string.find + levenshtein distance

local insert, byte, min = table.insert, string.byte, math.min
local lower, gsub, find, ipairs = string.lower, string.gsub, string.find, ipairs
local tonum = {[true] = 0, [false] = 1}

function string.distance(str1, str2) -- levenshtein
    local len1, len2 = #str1, #str2
    local char1, char2, distance = {}, {}, {}
    gsub(str1, ".", function (c) insert(char1, byte(c)) end)
    gsub(str2, ".", function (c) insert(char2, byte(c)) end)
    for i = 0, len1 do
        distance[i] = {[0] = i}
    end
    for i = 0, len2 do distance[0][i] = i end
    for i = 1, len1 do
        for j = 1, len2 do
            distance[i][j] = min(
                distance[i-1][j] + 1,
                distance[i][j-1] + 1,
                distance[i-1][j-1] + tonum[char1[i] == char2[j]]
            )
        end
    end
    return distance[len1][len2]
end

local distance = string.distance

function string.search(str, tbl)
    str = gsub(lower(str), "%p", "")
    local valid = {}

    for i, name in ipairs(tbl) do
        if find(lower(name), str, 1, true) then
            valid[distance(name, str)] = name
        end
    end

    return valid
end
