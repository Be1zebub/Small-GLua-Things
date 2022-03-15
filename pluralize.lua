-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/pluralize.lua

local cases = {[0] = 3, [1] = 1, [2] = 2, [3] = 2, [4] = 2, [5] = 3}
function pluralize(n, titles)
    n = math.abs(n)
    return titles[
        (n % 100 > 4 and n % 100 < 20) and 2 or
        cases[(n % 10 < 5) and n % 10 or 5]
    ]
end

--[[
for i = -1, 9 do
    print(i, pluralize(i, {"секунда", "секунды", "секунд"}))    
end

-1   секунда
0    секунд
1    секунда
2    секунды
3    секунды
4    секунды
5    секунды
6    секунды
7    секунды
8    секунды
9    секунды
]]--
