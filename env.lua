local ENV = {
	_VERSION = 1.0,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/env.lua",
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
	]]
}

function ENV:ParseLine(line)
	return line:match("(.+)=(.+)")
end

function ENV:Parse(content)
	if content == "" then
		return function() end
	end

	local pos, stop = 1

	return function()
		if stop then return end
		local i, j = string.find(content, "\n", pos, true)

		if i then
			pos = j + 1
			return self:ParseLine(string.sub(content, pos, i - 1))
		else
			stop = true
			return self:ParseLine(string.sub(content, pos))
		end
	end
end

local META = {}

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

return setmetatable(ENV, META)
