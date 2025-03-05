-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/env.lua
-- .env file parser
-- with gmod & luvit runtimes auto support

local ENV = {
	_VERSION = 1.1,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/env.lua",
	_LICENSE = [[
		MIT LICENSE
		Copyright (c) 2022 gmod.one
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
	]]
}

function ENV:ParseLine(line)
	return line:match("(.+)=(.+)")
end

function ENV:Parse(content)
	if content == "" then
		return function() end
	end

	local pos, stop, key, value = 1

	return function()
		if stop then return end
		local i, j = string.find(content, "\n", pos, true)

		if i then
			key, value = self:ParseLine(content:sub(pos, i - 1))
			pos = j + 1
			return key, value
		else
			stop = true
			return self:ParseLine(content:sub(pos))
		end
	end
end

local META = {}
META.__index = META

local is = {
	luvit = _G.p and debug.getinfo(p).source == "bundle:/deps/pretty-print.lua",
	gmod = gmod ~= nil
}

local compat = { -- currently supports gmod & luvit
	file = (is.gmod and function(path)
		return assert(file.Exists(path, "DATA") and file.Read(path, "DATA"), "Invalid path!")
	end) or (is.luvit and function(path)
		return assert(require("fs").readFileSync(path), "Invalid path!")
	end),
	osenv = is.luvit and function()
		local copy = {}

		for k, v in pairs(require("env")) do
			copy[k] = v
		end

		return copy
	end
}

function META:__call(...)
	local env = compat.osenv and compat.osenv() or {}

	if ... then
		for _, path in ipairs({...}) do
			local content = assert(compat.file(path), "This file is empty!")

			for key, value in self:Parse(content) do
				env[key] = value
			end
		end
	end

	return env
end

function META:Read(path)
	local env = {}

	local content = assert(compat.file(path), "This file is empty!")

	for key, value in self:Parse(content) do
		env[key] = value
	end

	return env
end

return setmetatable(ENV, META)
