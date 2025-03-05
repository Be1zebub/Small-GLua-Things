-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/sh_benchmark.lua
-- from gmod.one with <3

local function sum(tbl)
	local out = 0

	for i = 1, #tbl do
		out = out + tbl[i]
	end

	return out
end

local function avg(tbl)
	return sum(tbl) / #tbl
end

local function median(tbl)
	table.sort(tbl)
	return #tbl % 2 == 0 && (tbl[#tbl * .5] + tbl[(#tbl * .5) + 1]) * .5 || tbl[math.ceil(#tbl * .5)]
end

local clock = os.clock
local function bench(func, times)
	local start = clock()

	for i = 1, times do
		func(i)
	end

	return clock() - start
end

local function benchmark(name, func, times, rep)
	local co = coroutine.running()
	timer.Simple(0, function()
		collectgarbage()
		coroutine.resume(co)
	end)
	coroutine.yield()

	local results = {}

	for i = 1, rep do
		results[i] = bench(func, times)
	end

	local sum, avg, median = sum(results), avg(results), median(results)
	print(name ..":\n\tsum = ".. sum .."\n\tavg = ".. avg .."\n\tmedian = ".. median)
	return sum, avg, median
end

--[[ usage example:

print(string.rep(" \n", 10))

local json_encoded = util.TableToJSON({[1] = "num", [true] = "bool", col = Color(255, 0, 0)})
local bins_encoded = bins.encode({[1] = "num", [true] = "bool", col = Color(255, 0, 0)})

coroutine.wrap(function()
	benchmark("json.encode", function()
		local encoded = util.TableToJSON({[1] = "num", [true] = "bool", col = Color(255, 0, 0)})
	end, 1000, 100)
	benchmark("json.decode", function()
		local decoded = util.JSONToTable(json_encoded)
	end, 1000, 100)
	benchmark("bins.encode", function()
		local encoded = bins.encode({[1] = "num", [true] = "bool", col = Color(255, 0, 0)})
	end, 1000, 100)
	benchmark("bins.decode", function()
		local decoded = bins.decode(bins_encoded)
	end, 1000, 100)
end)()
]]--
