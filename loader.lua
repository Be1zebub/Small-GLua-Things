-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/loader.lua

local Loader = {
	_VERSION = 1.4,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/loader.lua",
	_LICENSE = [[
		MIT LICENSE
		Copyright (c) 2022 incredible-gmod.ru
		Permission is hereby granted, free of charge, to any person obtaining a
		copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:
		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
		OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]],
	_DEBUG = false
}

Loader.REALM = CLIENT and "CLIENT" or "SERVER"

local include_realm = {
	sv = SERVER and include or function() end,
	cl = SERVER and AddCSLuaFile or include
}

include_realm.sh = function(f)
	AddCSLuaFile(f)
	return include(f)
end

function Loader:include(path, realm, _lvl)
	local worker = include_realm[realm]
	if worker == nil then
		realm, worker = "sh", include_realm.sh
	end

	if file.Exists(path, "LUA") then
		if self._DEBUG then
			print(string.rep("\t", _lvl or 0) .. realm .." > ".. path)
		end

		return worker(path)
	end
end

function Loader:GetFilename(path)
	return path:match(".+/(.+)%..+") or self:RemoveExt(path)
end

function Loader:GetFilenameWithExt(path)
	return path:match("([^/]+)$")
end

function Loader:RemoveExt(path)
	return path:match("(.+)%..+")
end

function Loader:GetCurrentDir()
	return debug.getinfo(1).source:match("@?(.*/)")
end

function Loader:Include(path, realm, _lvl)
	return self:include(path, realm or string.sub(self:GetFilename(path), 1, 2), _lvl)
end

function Loader:ScanDir(path, cback, recursive, _lvl)
	_lvl = _lvl or 1

	if path[#path] ~= "/" then
		path = path .."/"
	end

	local files, folders = file.Find(path .. (recursive and "*" or "*.*"), "LUA")

	for _, f in ipairs(files) do
		cback(path .. f, _lvl)
	end

	if not recursive then return end

	for _, f in ipairs(folders) do
		self:ScanDir(path .. f, cback, recursive, _lvl)
	end
end

local is_client = {
	["sv"] = SERVER
}

local find_mode = {
	file = 1,
	files = 2,
	dir = 2,
	dirs = 2,
	lua = 3,
	all = 4
}

local find_dirs = {
	[2] = true,
	[4] = true
}

local find_pattern = {
	[1] = "*.*",
	[2] = "*",
	[3] = "*.lua",
	[4] = "*"
}

function Loader:Find(path, mode, search_path)
	mode = find_mode[mode] or find_mode.all

	if path[#path] ~= "/" then
		path = path .."/"
	end

	local skip_dirs = find_dirs[mode] == nil
	local files, dirs = file.Find(path .. find_pattern[mode], search_path or "LUA")
	local i, v = 1

	return function()
		if i > #files then
			if skip_dirs then return end
			v = dirs[i - #files]
		else
			v = files[i]
		end

		if v == nil then return end

		i = i + 1
		return path .. v, v, i > #files
	end
end

--[[
for path, name, isdir in loader:Find("addon_name/src/", "all") do
	print(path, name, isdir)
end
]]--

function Loader:IncludeDir(path, recursive, realm, storage, include_realm_order, force_realm, include_1st, _base_path_len, _lvl)
	_base_path_len = _base_path_len or #path + 2
	_lvl = _lvl or 1

	if path[#path] ~= "/" then
		path = path .."/"
	end

	if force_realm == nil then
		force_realm = {
			["init.lua"] = "sh"
		}
	end

	if include_1st == nil then
		include_1st = {
			"init.lua",
			"shared.lua"
		}
	end

	local include_order = {}

	for i, f in ipairs(include_1st) do
		include_order[f] = i
	end

	if include_realm_order == nil then
		include_realm_order = {
			["sh"] = 1,
			["sv"] = 2,
			["cl"] = 3
		}
	end

	local files, folders = file.Find(path .. (recursive and "*" or "*.*"), "LUA")

	if self._DEBUG and is_client[realm] ~= false then
		print(string.rep("\t", _lvl - 1) .."Loader:IncludeDir(".. (realm or "?") .. (recursive and ", recursive" or "") ..") > ".. path)
	end

	table.sort(files, function(a, b)
		if include_order[a] then
			if include_order[b] then return include_order[a] < include_order[b] end -- force load init.lua & shared.lua 1st
			return true
		end

		local realm_a = force_realm[a] or a:sub(1, 2)
		local realm_b = force_realm[b] or b:sub(1, 2)

		if include_realm_order[realm_a] ~= include_realm_order[realm_b] then
			return include_realm_order[realm_a] < include_realm_order[realm_b] -- by realm sh > sv > cl
		end

		return a < b -- alphabetically
	end)

	for _, f in ipairs(files) do
		if storage then
			storage[
				self:GetFilename(recursive and (path:sub(_base_path_len) .. f) or f)
			] = self:Include(path .. f, force_realm[f] or realm, _lvl)
		else
			self:Include(path .. f, force_realm[f] or realm, _lvl)
		end
	end

	if recursive ~= true then return end

	for _, f in ipairs(folders) do
		self:IncludeDir(path .. f, recursive, realm, storage, include_realm_order, force_realm, include_1st, _base_path_len, _lvl + 1)
	end
end

function Loader:IncludeDirRelative(recursive, realm, storage, include_realm_order, force_realm, include_1st)
	self:IncludeDir(self:GetCurrentDir(), recursive, realm, storage, include_realm_order, force_realm, include_1st)
end

function Loader:AddCsDir(path, recursive, _lvl)
	_lvl = _lvl or 1

	if path[#path] ~= "/" then
		path = path .."/"
	end

	local files, folders = file.Find(path .. (recursive and "*" or "*.*"), "LUA")

	if self._DEBUG then
		print(string.rep("\t", _lvl - 1) .."Loader:AddCsDir(".. (recursive and "recursive" or "") ..") > ".. path)
	end

	for _, f in ipairs(files) do
		if self._DEBUG then
			print(string.rep("\t", _lvl) .." ".. path .. f)
		end

		pcall(AddCSLuaFile, path .. f)
	end

	if not recursive then return end

	for _, f in ipairs(folders) do
		self:AddCsDir(path .. f, true, _lvl + 1)
	end
end

if SERVER then
	function Loader:ResourceAdd(path, recursive, pattern)
		if path[#path] ~= "/" then
			path = path .."/"
		end

		local files = file.Find(path .. (pattern or "*"), "GAME")

		for _, fname in ipairs(files) do
			resource.AddSingleFile(path .. fname)
		end

		if recursive then
			for _, fname in ipairs(folders) do
				self:ResourceAdd(path .. fname, recursive, pattern)
			end
		end
	end
end

function Loader:RegisterEntity(path, base, class, cback)
	local _ENT = ENT

	ENT = {
		Base       	= "base_entity",
		Type 		= "anim",
		Author		= "Beelzebub",
		Contact		= "https://discord.incredible-gmod.ru",
		Category    = "Incredible GMod"
	}

	if base then
		ENT.Type = nil
		ENT.Base = base
	end

	if file.IsDir(path) then
		if class == nil then
			class = path:match("([^/]+)$")
		end

		self:Include(path .."/sh.lua", "sh")
		self:Include(path .."/shared.lua", "sh")

		self:Include(path .."/cl.lua", "cl")
		self:Include(path .."/client.lua", "cl")
		self:Include(path .."/cl_init.lua", "cl")

		self:Include(path .."/sv.lua", "sv")
		self:Include(path .."/server.lua", "sv")
		self:Include(path .."/init.lua", "sv")
	else
		if class == nil then
			class = path:match("([%w_]*).lua")
		end

		self:Include(path)
	end

	if cback then cback(ENT) end

	if class then
		scripted_ents.Register(ENT, class)
	end

	ENT = _ENT
end

function Loader:Require(path)
	if util.IsBinaryModuleInstalled(path) then
		return require(path)
	end

	if file.IsDir(path, "LUA") then
		if path[#path] ~= "/" then
			path = path .."/"
		end

		return Loader:include(path .."init.lua")
	end

	return Loader:Include(path)
end

return Loader
