-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/utils/bench.lua
-- simple benchmarking util.

-- usage:
-- bench.run(100 * 1000, 100, draw.NoTexture)

--[[ output example:
iterations: 100,000
repeats: 100
4.563 ms avg
4.279 ms median
456.295 ms total
45.629 ns per call avg
]]--

local bench = {}

function bench.run(iterations, repeats, func)
	local results = {}

	for i = 1, repeats do
		local start = SysTime()

		for _ = 1, iterations do
			func()
		end

		results[i] = SysTime() - start
	end

	local totalTime = bench.sum(results)
	local totalCalls = iterations * repeats

	print("iterations: " .. string.Comma(iterations))
	print("repeats: " .. string.Comma(repeats))
	print(bench.formatTime(totalTime / #results) .. " avg")
	print(bench.formatTime(bench.median(results)) .. " median")
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
	table.sort(tbl)
	return #tbl % 2 == 0 && (tbl[#tbl * .5] + tbl[(#tbl * .5) + 1]) * .5 || tbl[math.ceil(#tbl * .5)]
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
