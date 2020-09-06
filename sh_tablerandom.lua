-- Thats better then a shitty glua table.Random function

local random, GetKeys = math.random, table.GetKeys

function table.Random(tab, issequential)
    local keys = issequential and tab or GetKeys(tab)
    local rand = keys[random(1, #keys)]
    return tab[rand], rand 
end

--[[
print(table.Random({
    Hello = true,
    World = 1,
    Lorem = function() end,
    Ispum = "dolor"
}))
]]--
