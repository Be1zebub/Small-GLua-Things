-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/pluralize.lua
-- souse: https://internetbrains.blogspot.com/2010/01/javascript.html

local cases = {[0] = 3, [1] = 1, [2] = 2, [3] = 2, [4] = 2, [5] = 3}
function pluralize(n, titles)
	n = math.floor(math.abs(n))
	return titles[
		(n % 100 > 4 and n % 100 < 20) and 3 or
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
5    секунд
6    секунд
7    секунд
8    секунд
9    секунд

for _, i in ipairs({-1, 0, 1, 2, 5}) do
    print(i, pluralize(i, {"час", "часа", "часов"}))    
end

-1   час
0    часов
1    час
2    часа
5    часов
]]--
