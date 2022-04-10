local Loader = {
	_VERSION = 1.2,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/loader.lua",
	_LICENSE = [[
		MIT LICENSE
		Copyright (c) 2021 incredible-gmod.ru
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
	local worker = include_realm[realm or "sh"]
	if worker == nil then
		realm = "sh"
		worker = include_realm.sh
	end

	if file.Exists(path, "LUA") then
		if self._DEBUG then
			print(string.rep("\t", _lvl or 0) .. realm .." > ".. path)
		end

		return worker(path)
	end
end

function Loader:GetFilename(path, ext)
	return path:match(ext and ("([%w_]*).".. ext) or "([%w_]*).lua")
end

function Loader:GetFilenameWithExt(path)
	return path:match("([%w_]*).lua")
end

function Loader:RemoveExt(path)
	return path:match("(.+)%..+")
end

function Loader:Include(path, realm, _lvl)
	realm = realm or string.sub(self:GetFilename(path), 1, 2)
	return self:include(path, realm, _lvl)
end

function Loader:ScanDir(dir, cback, recursive, _lvl)
	_lvl = _lvl or 1

	local path = dir .."/"
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

function Loader:IncludeDir(dir, recursive, realm, storage, _base_path_len, _lvl)
	_base_path_len = _base_path_len or #dir + 2
	_lvl = _lvl or 1

	local path = dir .."/"
	local files, folders = file.Find(path .. (recursive and "*" or "*.*"), "LUA")

	if self._DEBUG and is_client[realm] ~= false then
		print(string.rep("\t", _lvl - 1) .."Loader:IncludeDir(".. (realm or "?") .. (recursive and ", recursive" or "") ..") > ".. dir)
	end

	for _, f in ipairs(files) do
		if storage then
			storage[self:GetFilename(recursive and (path:sub(_base_path_len) .. f) or f)] = self:Include(path .. f, realm, _lvl)
		else
			self:Include(path .. f, realm, _lvl)
		end
	end

	if not recursive then return end

	for _, f in ipairs(folders) do
		self:IncludeDir(path .. f, recursive, realm, storage, _base_path_len, _lvl + 1)
	end
end

function Loader:AddCsDir(dir, recursive, _lvl)
	_lvl = _lvl or 1

	local path = dir .."/"
	local files, folders = file.Find(path .. (recursive and "*" or "*.*"), "LUA")

	if self._DEBUG then
		print(string.rep("\t", _lvl - 1) .."Loader:AddCsDir(".. (recursive and "recursive" or "") ..") > ".. dir)
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
	function Loader:ResourceAdd(dir, recurse, pattern)
		local files, folders = file.Find(dir .. (pattern and ("/".. pattern) or "/*"), "GAME")

		for i, fname in ipairs(files) do
			resource.AddSingleFile(dir .."/".. fname)
		end

		if recurse then
			for i, subdir in ipairs(folders) do
				self:ResourceAdd(dir .."/".. subdir, recurse, pattern)
			end
		end
	end
end

Loader.__index = Loader
return Loader

