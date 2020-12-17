-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/sh_loader.lua

local Loader = {}
Loader.Debug = false

local include_realm = {
    sv = SERVER and include or function() end,
    cl = SERVER and AddCSLuaFile or include
}

include_realm.sh = function(f)
    include_realm.sv(f)
    include_realm.cl(f)
end

function Loader:GetFilename(path)
	return path:match("[^/]+$")
end

function Loader:Include(fpath)
	local realm = string.sub(self:GetFilename(fpath), 1, 2)

	local func = include_realm[realm]
	if func == nil then return false end

	if self.Debug then
		print(realm, fpath)
	end

	func(fpath)

	return true
end

function Loader:IncludeDir(path, recurse, loaded)
	loaded = loaded or {}

	local files, folders = file.Find(path .."/*", "LUA")

	for i, f in ipairs(files) do
		local fpath = path .."/".. f
		
		if self:Include(fpath) then
			table.insert(loaded, fpath)
		end
	end

	if recurse then
		for i, f in ipairs(folders) do
			if self.Debug then
				print("recurse", path .."/".. f)
			end

			self:IncludeDir(path .."/".. f, recurse, loaded)
		end
	end

	return loaded
end

return Loader
