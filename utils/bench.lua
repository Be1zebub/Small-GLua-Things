-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/utils/bench.lua
-- simple benchmarking util.

-- usage:
-- bench.run(100 * 1000, 100, 10, draw.NoTexture)

--[[ output example:
iterations: 100,000
repeats: 100
4.519 ms avg
4.303 ms median (p50)
4.976 ms percentile p95
10.655 ms percentile p99
451.944 ms total
45.194 ns per call avg
]]--

local bench = {}
local SysTime = SysTime

function bench.run(iterations, repeats, warmup, func)
	for i = 1, warmup do
		for _ = 1, iterations do
			func()
		end
	end

	collectgarbage("collect")
	collectgarbage("stop")

	local results = {}

	for i = 1, repeats do
		local start = SysTime()

		for _ = 1, iterations do
			func()
		end

		results[i] = SysTime() - start
	end

	collectgarbage("restart")

	table.sort(results)

	local totalTime = bench.sum(results)
	local totalCalls = iterations * repeats

	print("iterations: " .. string.Comma(iterations))
	print("repeats: " .. string.Comma(repeats))
	print(bench.formatTime(totalTime / #results) .. " avg")
	print(bench.formatTime(bench.median(results)) .. " median (p50)")
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
	local n = #tbl
	if n % 2 == 0 then
		local mid = n / 2
		return (tbl[mid] + tbl[mid + 1]) / 2
	else
		return tbl[math.ceil(n / 2)]
	end
end

function bench.percentile(tbl, p)
	local index = math.max(1, math.ceil(#tbl * (p / 100)))
	return tbl[math.min(index, #tbl)]
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

return bench
