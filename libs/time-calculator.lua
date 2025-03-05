-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/time-calculator.lua

-- a time converter & calculator
-- a great way to parse simple encoded time like "1hour 30seconds" or "1w + 1d"
-- if you need time in configs, this is the best solution.

-- imagine ulx ban with this style duration, instead of non-obvious numbers

-- i use it in my discord bot "/remind" command - example: `/remind 1d + 4h remind me review #1965 pr` will ping user with ref-msg reply after 1 day and 4 hours
-- print(timeCalc("1h"), timeCalc("5s + 1m + 2s")) > 3600, 67

local time = {}

time.millisecond = 0.001
time.ms, time.milliseconds = time.millisecond, time.millisecond

time.second = 1
time.s, time.seconds = time.second, time.second

time.minute = 60
time.m, time.minutes = time.minute, time.minute

time.hour = 60 * 60
time.h, time.hours = time.hour, time.hour

time.day = 60 * 60 * 24
time.d, time.days = time.day, time.day

time.week = 60 * 60 * 24 * 7
time.w, time.weeks = time.week, time.week

time.month = 60 * 60 * 24 * 30
time.m, time.months = time.month, time.month

time.year = 60 * 60 * 24 * 365
time.y, time.years = time.year, time.year

local math = {
	["-"] = function(a, b) return a - b end,
	["+"] = function(a, b) return a + b end,
	["/"] = function(a, b) return a / b end,
	["*"] = function(a, b) return a * b end,
	["^"] = function(a, b) return a ^ b end,
	["%"] = function(a, b) return a % b end
}

local function lua_gsub(str, pattern, replacement, maxReplaces) -- puc/jit gsub wont match in passed parts (no way todo recursion)
	maxReplaces = maxReplaces or #str + 1

	for _ = 1, maxReplaces do
		local find_start, find_end = str:find(pattern)
		if find_start == nil then break end

		local found = str:sub(find_start, find_end)
		str = str:sub(1, find_start - 1) ..
			replacement(found:match(pattern))
		.. str:sub(find_end + 1)
	end

	return str
end

return function(str, maxReplaces)
	-- decode time
	str = str:lower():gsub("(%d+)(%a+)", function(len, key)
		if time[key] then
			return tonumber(len) * time[key]
		end
	end)

	-- do some math
	str = lua_gsub(str, "(%d+)%s-([-+/*^%%])%s-(%d+)", function(a, operator, b)
		return math[operator](tonumber(a), tonumber(b))
	end, maxReplaces or 30)

	return tonumber(str)
end
