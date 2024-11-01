-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/lang.lua

--[[ usage:
    lang:Add("example", "Привет мир!")
    lang:Add("hi", "Hello {?}.")
    lang:Add("ban", "{?} banned {?}")
    lang:Add("time", "Your total time is {?}")

    if CLIENT then
        lang:ChatPrint("example")
        lang:Notify("hi", {LocalPlayer():Name()}, 5)
        utime.ui.text = lang:Format("time", {LocalPlayer():GetUTime()})
    else
        lang:ChatPrint(ply, "hi", {ply:Name()})
        lang:Notify(player.GetHumans(), "ban", {admin:Name(), target:Name()}, 3, NOTIFY_GENERIC)
    end

    lang:remove("time")
]]--

--[[ advanced usage:
    https://github.com/Be1zebub/csv2lang
]]--

local bitCount, placeholderCount

do
    function bitCount(num)
        return math.floor(
            math.log(
                tonumber(string.format("%u", num))
            , 2)
        ) + 1
    end

    function placeholderCount(str)
        local count = 0
        for s in string.gmatch(str, "{%?}") do
            count = count + 1
        end
        return count
    end
end

local list = {}
local map = {}
local bitcount = 0

local function find(uid)
    local phrase

    if isnumber(uid) then
        phrase = list[uid]
    else
        phrase = map[uid]
    end

    return assert(phrase, "Phrase " .. tostring(uid) .. " not found!")
end

local lang = {}

function lang:Add(name, text)
    local phrase = map[name]

    if phrase == nil then
        phrase = {
            text = text,
            placeholders = placeholderCount(text)
        }

        map[name] = phrase
        phrase.index = table.insert(list, phrase)
        bitcount = bitCount(#list)
    else
        phrase.text = text
        phrase.placeholders = placeholderCount(text)
    end

    return phrase
end

function lang:Remove(name)
    local phrase = map[name]
    if phrase == nil then return end

    map[name] = nil
    table.remove(list, phrase.index)

    for i, v in ipairs(list) do
        v.index = i
    end

    bitcount = bitCount(#list)
end

function lang:Get(uid)
    return find(uid).text
end

function lang:Format(uid, data)
    local phrase = find(uid)
    if data == nil or phrase.placeholders == 0 then return phrase.text end

    local i = 0

    return phrase.text:gsub("{%?}", function()
        i = i + 1
        return data[i]
    end)
end

if gmod then
    if CLIENT then
        function lang:Notify(uid, data, len, type)
            notification.AddLegacy(lang:Format(uid, data), type or NOTIFY_GENERIC, len or 3)
        end

        net.Receive("gmod.one/lang:Notify", function()
            local index = net.ReadUInt(bitcount)
            local phrase = find(index)

            local data = {}

            for i = 1, phrase.placeholders do
                data[i] = net.ReadString()
            end

            lang:Notify(index, data, net.ReadUInt(4), net.ReadUInt(3))
        end)

        function lang:ChatPrint(uid, data)
            chat.AddText(lang:Format(uid, data))
        end

        net.Receive("gmod.one/lang:ChatPrint", function()
            local index = net.ReadUInt(bitcount)
            local phrase = find(index)

            local data = {}

            for i = 1, phrase.placeholders do
                data[i] = net.ReadString()
            end

            lang:ChatPrint(index, data)
        end)
    else
        util.AddNetworkString("gmod.one/lang:Notify")

        function lang:Notify(targets, uid, data, len, type)
            local phrase = find(uid)

            net.Start("gmod.one/lang:Notify")
            net.WriteUInt(phrase.index, bitcount)

            for i = 1, phrase.placeholders do
                net.WriteString(data[i])
            end

            net.WriteUInt(math.min(len, 15), 4)
            net.WriteUInt(type, 3)

            if targets then
                net.Send(targets)
            else
                net.Broadcast()
            end
        end

        util.AddNetworkString("gmod.one/lang:ChatPrint")

        function lang:ChatPrint(targets, uid, data)
            local phrase = find(uid)

            net.Start("gmod.one/lang:ChatPrint")
            net.WriteUInt(phrase.index, bitcount)

            for i = 1, phrase.placeholders do
                net.WriteString(data[i])
            end

            if targets then
                net.Send(targets)
            else
                net.Broadcast()
            end
        end
    end
end

return lang
