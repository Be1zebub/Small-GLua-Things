-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/loader-min.lua

-- Universal addon loader

-- mini version of https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/loader.lua

local debug = true

local include_realm_order = {
	["sh"] = 1,
	["sv"] = 2,
	["cl"] = 3
}

local include_realm = {
	sv = SERVER and include or function() end,
	cl = SERVER and AddCSLuaFile or include,
	sh = function(f)
		AddCSLuaFile(f)
		return include(f)
	end
}

local dirColor

if debug then
	if SERVER then
		local function FormatColor(r, g, b)
			return string.format("\27[38;2;%d;%d;%dm", r, g, b)
		end

		local reset = "\27[0m "

		local debug_realms = {
			sv = FormatColor(3, 169, 244) .."server".. reset,
			cl = FormatColor(222, 169, 9) .."client".. reset,
			sh = FormatColor(3, 169, 244) .."sha".. FormatColor(222, 169, 9) .."red".. reset,
		}

		function debug(realm, path, lvl)
			MsgN(string.rep("\t", lvl - 1) .. debug_realms[realm] .. path)
		end

		dirColor = FormatColor(100, 150, 255)
	else
		local debug_realms = {
			sv = function()
				return Color(3, 169, 244), "server "
			end,
			cl = function()
				return Color(222, 169, 9), "client "
			end,
			sh = function()
				return Color(222, 169, 9), "sha", Color(3, 169, 244), "red "
			end
		}

		local white = Color(255, 255, 255)

		function debug(realm, path, lvl)
			MsgC(string.rep("\t", lvl - 1), debug_realms[realm]())
			MsgC(white, path, "\n")
		end
	end
else
	debug = function() end
end

local function IncludeDir(path, storage, _lvl)
	if path[#path] ~= "/" then
		path = path .."/"
	end
	_lvl = _lvl or 1

	if debug then
		MsgN(dirColor, string.rep("\t", _lvl - 1), "> IncludeDir(\"".. path:sub(1, #path - 1) .."\")")
		_lvl = _lvl + 1
	end

	local files, folders = file.Find(path .."*", "LUA")

	table.sort(files, function(a, b)
		local realm_a, realm_b = a:sub(1, 2), b:sub(1, 2)

		if include_realm[realm_a] == nil then realm_a = "sh" end
		if include_realm[realm_b] == nil then realm_b = "sh" end

		if include_realm_order[realm_a] ~= include_realm_order[realm_b] then
			return include_realm_order[realm_a] < include_realm_order[realm_b] -- by realm sh > sv > cl
		end

		return a:sub(3) < b:sub(3) -- alphabetically
	end)

	for _, f in ipairs(files) do
		local realm = f:sub(1, 2)
		realm = include_realm[realm] and realm or "sh"
		local fpath = path .. f

		include_realm[realm](fpath)
		if storage then storage[fpath] = v end
		debug(realm, fpath, _lvl)
	end

	for _, f in ipairs(folders) do
		local fpath = path .. f

		local dir
		if storage then
			dir = {isdir = true}
			storage[fpath] = dir
		end

		IncludeDir(fpath, dir, _lvl + 1)
	end

	return storage
end

return IncludeDir
