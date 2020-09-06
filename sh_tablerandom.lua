-- Thats better then a shitty glua table.Random function

function table.Random(tab, issequential)
    local keys = issequential and tab or table.GetKeys(tab)
    local rand = keys[math.random(1, #keys)]
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
