-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/utils/grep.lua

-- its like grep (linux cli util for searching content in files)
-- but in gmod console (works on both realms)

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

-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/utf8.lua REQUIRED!

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
