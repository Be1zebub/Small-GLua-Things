-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/sh_utf8.lua

if not utf8 then utf8 = {} end -- compability with non-glua things

local upper2lower = {["А"]="а",["Б"]="б",["В"]="в",["Г"]="г",["Д"]="д",["Е"]="е",["Ё"]="ё",["Ж"]="ж",["З"]="з",["И"]="и",["Й"]="й",["К"]="к",["Л"]="л",["М"]="м",["Н"]="н",["О"]="о",["П"]="п",["Р"]="р",["С"]="с",["Т"]="т",["У"]="у",["Ф"]="ф",["Х"]="х",["Ц"]="ц",["Ч"]="ч",["Ш"]="ш",["Щ"]="щ",["Ъ"]="ъ",["Ы"]="ы",["Ь"]="ь",["Э"]="э",["Ю"]="ю",["Я"]="я"}
local lower2upper = {}
for upper, lower in pairs(upper2lower) do lower2upper[lower] = upper end

-- thx to Spar, mt.__index is a beatiful idea
setmetatable(upper2lower, {__index = string.lower})
setmetatable(lower2upper, {__index = string.upper})

local pattern, gsub = utf8.charpattern, string.gsub

function utf8.lower(s)
    return (gsub(s, pattern, upper2lower))
end

function utf8.upper(s)
    return (gsub(s, pattern, lower2upper))
end

--print(utf8.lower("Привет World #123!"), utf8.upper("Hello Мир #321!"))
-- output: "привет world #123!", "HELLO МИР #321!"
