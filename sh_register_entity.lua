function util.RegisterEntity(class, callback)
    ENT = {}

    ENT.Base = "base_entity"
    ENT.Type = "anim"
    ENT.Author       = "Beelzebub"
    ENT.Contact      = "beelzebub@incredible-gmod.ru"
    ENT.Category     = "incredible-gmod.ru"

    callback(ENT)

    AddCSLuaFile("cl.lua")

    if SERVER then
        include("sv.lua")
    else
        include("cl.lua")
    end

    scripted_ents.Register(ENT, class)

    ENT = nil
end

function util.LoadEntity(path)
    local class = path:match("([^/]+)$"):match("(.+)%..+")
    util.RegisterEntity(class, function()
        AddCSLuaFile(path)
        include(path)
    end)
end
