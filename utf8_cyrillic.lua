-- cyrillic only
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/utf8_cyrillic.lua

-- complete utf8 cases mapping:
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/utf8.lua

if utf8 == nil then utf8 = {} end

local uc_lc = {["А"]="а",["Б"]="б",["В"]="в",["Г"]="г",["Д"]="д",["Е"]="е",["Ё"]="ё",["Ж"]="ж",["З"]="з",["И"]="и",["Й"]="й",["К"]="к",["Л"]="л",["М"]="м",["Н"]="н",["О"]="о",["П"]="п",["Р"]="р",["С"]="с",["Т"]="т",["У"]="у",["Ф"]="ф",["Х"]="х",["Ц"]="ц",["Ч"]="ч",["Ш"]="ш",["Щ"]="щ",["Ъ"]="ъ",["Ы"]="ы",["Ь"]="ь",["Э"]="э",["Ю"]="ю",["Я"]="я"}

local lc_uc = {}
for uc, lc in pairs(uc_lc) do lc_uc[lc] = uc end

setmetatable(uc_lc, {__index = function(_, char) return char:lower() end})
setmetatable(lc_uc, {__index = function(_, char) return char:upper() end})

function utf8.lower(s)
    return (s:gsub(utf8.charpattern, uc_lc))
end

function utf8.upper(s)
    return (s:gsub(utf8.charpattern, lc_uc))
end

--print(utf8.lower("Привет World #123!"), utf8.upper("Hello Мир #321!"))
-- output: "привет world #123!", "HELLO МИР #321!"
