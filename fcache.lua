local fcache = {
  _VERSION      = 1.0,
  _URL 			= "https://github.com/Be1zebub/Small-GLua-Things/blob/master/fcache.lua",
  _LICENSE      = [[
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
  ]]
}

local cache = {}

local function cacheGet(name, args)
	local node = cache[name]
	if node == nil then return end

	if SysTime() <= node.time then
		for i = 1, #args do
			node = node.child[args[i]]
			if node == nil then return end
		end

		return node.results
	else
		cache[name] = nil
	end
end

local function cacheMake(name, args, results, time)
	if cache[name] == nil then cache[name] = {} end
	local node = cache[name]
	node.time = SysTime() + time

	local arg
	for i = 1, #args do
		arg = args[i]
		node.child = node.child or {}
		node.child[arg] = node.child[arg] or {}
		node = node.child[arg]
	end

	node.results = results
end

local unpack = unpack or table.unpack -- lua 5.3 compatibility

local function work(func, time)
	time = time or 30

	local name = tostring(func) .."/".. time .."/".. debug.traceback()
	return function(...)
		local args = {...}

		local results = cacheGet(name, args)
		if results == nil then
			results = {func(...)}
			cacheMake(name, args, results, time)
		end

		return unpack(results)
	end
end

local mt = {}
mt.__call = function(_, func, time)
	return work(func, time)
end
mt.getTable = function()
	return cache
end

setmetatable(fcache, mt)

--[[ deubg:
local random = fcache(math.random, 2)

local start = SysTime()
local function debug(repeats)
	repeats = repeats - 1
	if repeats <= 0 then return end

	print(math.Round(SysTime() - start, 1) ..": ".. random(1, 5))
	timer.Simple(0.5, function()
		debug(repeats)
	end)
end

debug(20)
]]--

return fcache
