-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/utils/bench.lua
-- simple benchmarking util.

-- usage:
-- bench.run(100 * 1000, 100, draw.NoTexture)

--[[ output example:
iterations: 100,000
repeats: 100
5.059 ms avg
4.352 ms median
8.693 ms percentile p95
10.755 ms percentile p99
505.858 ms total
50.586 ns per call avg
]]--

local bench = {}

function bench.run(iterations, repeats, func)
	local results = {}

	for i = 1, repeats do
		collectgarbage("collect")

		local start = SysTime()

		for _ = 1, iterations do
			func()
		end

		results[i] = SysTime() - start
	end

	table.sort(results)

	local totalTime = bench.sum(results)
	local totalCalls = iterations * repeats

	print("iterations: " .. string.Comma(iterations))
	print("repeats: " .. string.Comma(repeats))
	print(bench.formatTime(totalTime / #results) .. " avg")
	print(bench.formatTime(bench.median(results)) .. " median")
	print(bench.formatTime(bench.percentile(results, 95)) .. " percentile p95")
	print(bench.formatTime(bench.percentile(results, 99)) .. " percentile p99")
	print(bench.formatTime(totalTime) .. " total")
	print(bench.formatTime(totalTime / totalCalls) .. " per call avg")
end

function bench.sum(tbl)
	local out = 0

	for i = 1, #tbl do
		out = out + tbl[i]
	end

	return out
end

function bench.median(tbl)
	return #tbl % 2 == 0
		and (tbl[#tbl * 0.5] + tbl[(#tbl * 0.5) + 1]) * 0.5
		or tbl[math.ceil(#tbl * 0.5)]
end

function bench.percentile(tbl, p)
	local index = math.ceil(#tbl * (p / 100))
	return tbl[index]
end

function bench.formatTime(seconds)
	local abs = math.abs(seconds)

	if abs >= 1 then
		return string.format("%.3f s", seconds)
	elseif abs >= 1e-3 then
		return string.format("%.3f ms", seconds * 1e3)
	elseif abs >= 1e-6 then
		return string.format("%.3f µs", seconds * 1e6)
	elseif abs >= 1e-9 then
		return string.format("%.3f ns", seconds * 1e9)
	else
		return string.format("%.3e s", seconds)
	end
end

timer.Simple(2, function()
	bench.run(100 * 1000, 100, draw.NoTexture)
end)

return bench
