-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/small/table-random.lua

-- iterates assoc tables once (the default one do table.Count + pairs)
-- and iterates nothing when its sequential

local random, GetKeys = math.random, table.GetKeys

function table.Random(tab, isSequential)
    local keys = isSequential and tab or GetKeys(tab)
    local key = keys[random(1, #keys)]
    return tab[key], key
end

--[[
print(table.Random({
    Hello = true,
    World = 1,
    Lorem = function() end,
    Ispum = "dolor"
}))
]]--
