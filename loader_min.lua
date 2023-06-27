-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/loader_min.lua

local include_realm = {
	sv = SERVER and include or function() end,
	cl = SERVER and AddCSLuaFile or include,
	sh = function(f)
		AddCSLuaFile(f)
		return include(f)
	end
}

local include_realm_order = {
	["sh"] = 1,
	["sv"] = 2,
	["cl"] = 3
}

local function IncludeDir(path, storage)
	if path[#path] ~= "/" then
		path = path .."/"
	end

	local files, folders = file.Find(path .."*", "LUA")

	table.sort(files, function(a, b)
		local realm_a, realm_b = a:sub(1, 2), b:sub(1, 2)

		if include_realm[realm_a] == nil then realm_a = "sh" end
		if include_realm[realm_b] == nil then realm_b = "sh" end

		if include_realm_order[realm_a] ~= include_realm_order[realm_b] then
			return include_realm_order[realm_a] < include_realm_order[realm_b] -- by realm sh > sv > cl
		end

		return a < b -- alphabetically
	end)

	for _, f in ipairs(files) do
		local load = include_realm[f:sub(1, 2)] or include_realm.sh

		if storage then storage[path .. f] = load(path .. f) end
	end

	for _, f in ipairs(folders) do
		IncludeDir(path .. f, storage)
	end

	return storage
end

return IncludeDir
