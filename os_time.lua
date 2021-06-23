if istable(os.time) then return end

local old = os.time

local time = {}
time.second = 1
time.sec = 1
time.minute = time.second * 60
time.min = time.sec * 60
time.hour = time.minute * 60
time.day = time.hour * 24
time.week = time.day * 7
time.month = time.day * 30
time.year = time.month * 12
time.epoh = os.time({
    year = 1970,
    month = 1,
    day = 1,
    hour = 0
})
time.old = old
time.__call = function(_, dateData)
	return old(dateData)	
end

os.time = setmetatable({}, time)
