-- deprecaterd
-- good idea, bad design

if istable(os.time) then return end

local old = os.time

local time = {}

time.second = 1
time.sec = time.second
time.minute = time.second * 60
time.min = time.minute
time.hour = time.minute * 60
time.day = time.hour * 24
time.week = time.day * 7
time.month = time.day * 30
time.year = time.day * 365

time.epoh = os.time({
    year = 1970,
    month = 1,
    day = 1,
    hour = 0
})

local cur = {}
cur.wday = function() return os.date("*t").wday end
cur.yday = function() return os.date("*t").yday end

cur.sec   = function() return os.date("*t").sec   end
cur.min   = function() return os.date("*t").min   end
cur.hour  = function() return os.date("*t").hour  end
cur.day   = function() return os.date("*t").day   end
cur.month = function() return os.date("*t").month end
cur.year  = function() return os.date("*t").year  end

time.cur = setmetatable(cur, {
	__call = function(_, dateData)
		return old(dateData)
	end
})

time.old = old

os.time = setmetatable(time, {
	__call = function(_, dateData)
		return old(dateData)
	end
})
