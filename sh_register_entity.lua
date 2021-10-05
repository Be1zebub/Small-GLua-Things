function util.RegisterEntity(class, callback, path)
    ENT = {}

    ENT.Base = "base_entity"
    ENT.Type = "anim"
    ENT.Author       = "Beelzebub"
    ENT.Contact      = "beelzebub@incredible-gmod.ru"
    ENT.Category     = "incredible-gmod.ru"

    callback(ENT)

    pcall(AddCSLuaFile, path and path .."cl.lua" or "cl.lua")

    if SERVER then
        pcall(include, path and path .."sv.lua" or "sv.lua")
    else
        pcall(include, path and path .."cl.lua" or "cl.lua")
    end

    scripted_ents.Register(ENT, class)

    ENT = nil
end

function util.LoadEntity(path)
    local class = path:match("([^/]+)$"):match("(.+)%..+")
    util.RegisterEntity(class, function()
        AddCSLuaFile(path)
        include(path)
    end, path:match(".+/"))
end
