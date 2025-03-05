-- deprecated
-- bad lua patterns used & less features
-- use https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/loader.lua instead
-- it has Loader:RegisterEntity(path, base, class, cback)

function util.RegisterEntity(class, path, callback)
	local _ENT
	ENT = {}

	ENT.Base 		= "base_entity"
	ENT.Type 		= "anim"
	ENT.Author 		= "Beelzebub"
	ENT.Contact 	= "beelzebub@gmod.one"
	ENT.Category 	= "gmod.one"

	if callback then callback(ENT) end

	pcall(AddCSLuaFile, path and path .."cl.lua" or "cl.lua")

	if SERVER then
		pcall(include, path and path .."sv.lua" or "sv.lua")
	else
		pcall(include, path and path .."cl.lua" or "cl.lua")
	end

	scripted_ents.Register(ENT, class)

	ENT = _ENT
end

function util.LoadEntity(path)
    local class = path:match("([^/]+)$"):match("(.+)%..+")

    util.RegisterEntity(class, path:match(".+/"), function()
        AddCSLuaFile(path)
        include(path)
    end)
end
