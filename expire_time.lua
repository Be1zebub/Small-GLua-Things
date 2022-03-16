-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/expire_time.lua

local cases = {[0] = 3, [1] = 1, [2] = 2, [3] = 2, [4] = 2, [5] = 3}
local function pluralize(n, titles) -- https://github.com/Be1zebub/Small-GLua-Things/blob/master/pluralize.lua
	n = math.abs(n)
	return titles[
		(n % 100 > 4 and n % 100 < 20) and 3 or
		cases[(n % 10 < 5) and n % 10 or 6]
	]
end

local min, hour, day, week, year, t = 60, 60 * 60, 60 * 60 * 24, 60 * 60 * 24 * 7, 60 * 60 * 24 * 365
local function FormatExpireTime(time, precise)
	if precise then
		return expire_times[time] or tostring(time)
	else
		if time <= 0 or time == nil then return end

		if time < min then
			t = math.floor(time)
			return t .. pluralize(t, {" секунда", " секунды", " секунд"})
		end

		if time < hour then
			t = math.floor(time / min)
			return t .. pluralize(t, {" минута", " минуты", " минут"})
		end

		if time < day then
			t = math.floor(time / hour)
			return t .. pluralize(t, {" час", " часа", " часов"})
		end

		if time < week then
			t = math.floor(time / day)
			return t ..  pluralize(t, {" день", " дня", " дней"})
		end

		if time < year then
			t = math.floor(time / week)
			return t .. pluralize(t, {" неделя", " недели", " недель"})
		end

		t = math.floor(time / year)
		return t .. pluralize(t, {" год", " года", " лет"})
	end
end

--[[
5 минут
1 минута
3 года
7 недель
]]--
