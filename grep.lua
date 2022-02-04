-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/grep.lua

--[[ suppored flags
    r = recursive
    n = print line number with output lines
    i = ignore case distinctions
    e = use patterns
    s = stop parse file on first match found
]]--

--[[ Examples:
    lua_run grep("self.slider = self:Add", "rni", "inc_ui/elements")
    lua_run grep("Beelzebub was killed by Entity [421][trigger_hurt] with a trigger_hurt", "rn", "darkrp_logs", "DATA")
    grep -rni "PANEL:OnValueChange" inc_ui/elements
    grep -rn "Beelzebub was killed by Entity [421][trigger_hurt] with a trigger_hurt" darkrp_logs DATA
    grep_cl -n thirdperson cvar DATA
]]--

do -- https://github.com/Be1zebub/Small-GLua-Things/blob/master/sh_utf8.lua
    if not utf8 then utf8 = {} end

    local pattern, rawget, gsub, lower, upper = "[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*", rawget, string.gsub, string.lower, string.upper

    local upper2lower = {["А"]="а",["Б"]="б",["В"]="в",["Г"]="г",["Д"]="д",["Е"]="е",["Ё"]="ё",["Ж"]="ж",["З"]="з",["И"]="и",["Й"]="й",["К"]="к",["Л"]="л",["М"]="м",["Н"]="н",["О"]="о",["П"]="п",["Р"]="р",["С"]="с",["Т"]="т",["У"]="у",["Ф"]="ф",["Х"]="х",["Ц"]="ц",["Ч"]="ч",["Ш"]="ш",["Щ"]="щ",["Ъ"]="ъ",["Ы"]="ы",["Ь"]="ь",["Э"]="э",["Ю"]="ю",["Я"]="я"}
    local lower2upper = {}
    for upper, lower in pairs(upper2lower) do lower2upper[lower] = upper end

    -- thx to Spar, mt.__index is a beatiful idea
    setmetatable(upper2lower, {__index = function(self, char)
        return rawget(self, char) or lower(char)
    end})

    setmetatable(lower2upper, {__index = function(self, char)
        return rawget(self, char) or upper(char)
    end})

    function utf8.lower(s)
        return (gsub(s, pattern, upper2lower))
    end

    function utf8.upper(s)
        return (gsub(s, pattern, lower2upper))
    end

    --print(utf8.lower("Привет World #123!"), utf8.upper("Hello Мир #321!"))
    -- output: "привет world #123!", "HELLO МИР #321!"
end

local clouds, alizarin, orange, concrete, green_sea = Color(236, 240, 241), Color(231, 76, 60), Color(243, 156, 18), Color(149, 165, 166), Color(22, 160, 133) -- https://flatuicolors.com/palette/defo

function grep(needle, flags, path, searchPath, searchPattern)
    --print("needle = ", needle, "\n", "flags = ", flags, "\n", "path = ", path, "\n", "searchPath = ", searchPath, "\n", "searchPattern = ", searchPattern)

    path = path or ""
    flags = flags or {}
    searchPath = searchPath or "LUA"

    if isstring(flags) then
        local f = {}
        for flag in flags:gmatch(".") do
            f[flag] = true
        end
        flags = f
    elseif istable(flags) and flags[1] then
        for i, flag in ipairs(flags) do
            flags[flag] = true
            flags[i] = nil
        end
    end

    local files, dirs = file.Find(path .. (searchPattern or "/*"), searchPath)

    local line_num, line_content, fstart, fend, fpath
    for i, fname in ipairs(files) do
        fpath = path .."/".. fname
        local f = file.Open(fpath, "r", searchPath)

        line_num = 0
        repeat
            line_num = line_num + 1
            line_content = f:ReadLine()

            if flags.i then
                fstart, fend = utf8.lower(line_content):find(utf8.lower(needle), 1, not flags.e)
            else
                fstart, fend = line_content:find(needle, 1, not flags.e)
            end

            if fstart then
                MsgC(clouds, "\t- ", orange, fpath)
                if flags.n then
                    MsgC(clouds, ":", green_sea, line_num)
                end
                MsgC("\n", concrete, line_content:sub(1, fstart - 1), alizarin, line_content:sub(fstart, fend), concrete, line_content:sub(fend + 1))

                if flags.s then break end
            end
        until f:EndOfFile()

        f:Close()
    end

    if flags.r then
        for i, dir in ipairs(dirs) do
            grep(needle, flags, path .."/".. dir, searchPath, searchPattern)
        end
    end
end

if SERVER then
    concommand.Add("grep", function(ply, cmd, args, argsStr)
        if IsValid(ply) then return end
        grep(args[2], args[1]:gsub("-", ""), args[3], args[4], args[5])
    end)
else
    concommand.Add("grep_cl", function(ply, cmd, args, argsStr)
        if ply:IsSuperAdmin() == false then return end
        grep(args[2], args[1]:gsub("-", ""), args[3], args[4], args[5])
    end)
end
