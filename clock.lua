local Clock = {
	_VERSION = 1.0,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/clock.lua",
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

--[[ Usage:
local clock = Clock() -- Garrysmod compat by default
function clock:OnWeek(function(curWeek, dateData)
	IGMWeeklyRewards:Reset()
end)

local clock = Clock("Luvit")
function clock:OnMinute(function(curMinute, dateData)
	git:PullUpdates(function(commits)
		if #commits > 0 then
			app:Restart()
		end
	end)
end)

local clock = Clock("Love2D")
local NextAd = (clock:GetMinute() + 10) % 60
function clock:OnMinute(function(curMinute, dateData)
	if curMinute == NextAd then
		NextAd = (curMinute + 10) % 60
		game:ShowAd()
	end
end)
function love.update(dt)
	clock.update(dt)
end
]]--

Clock.compatibility = {
	Garrysmod = {
		setInterval = function(self, cback)
			if self.TimerName then return end
			self.TimerName = debug.traceback()

			timer.Create(self.TimerName, 1, 0, cback)
		end,
		clearInterval = function(self)
			if self.TimerName == nil then return end

			timer.Remove(self.TimerName)
			self.TimerName = nil
		end
	},
	Luvit = {
		init = function(self)
			self.timer = require("timer")
		end,
		setInterval = function(self, cback)
			if self.TimerID then return end

			self.TimerID = self.timer.setInterval(1000, cback)
		end,
		clearInterval = function(self)
			if self.TimerID == nil then return end

			self.timer.clearInterval(self.TimerID)
			self.TimerID = nil
		end
	},
	Love2D = {
		init = function(self)
			local time = 0
			local timers = {}

			self.update = function(dt)
				time = time + dt

				for _, timer in pairs(timers) do
					if timer.next >= time then
						timer.next = time + timer.interval
						timer.cback()
					end
				end
			end

			self.timer = {}

			self.timer.setInterval = function(interval, cback)
				return table.insert(timers, {
					interval = interval,
					cback = cback,
					next = time + interval
				})
			end

			self.timer.clearInterval = function(timer)
				timers[timer] = nil
			end
		end,
		setInterval = function(self, cback)
			if self.TimerID then return end

			self.TimerID = self.timer.setInterval(1000, cback)
		end,
		clearInterval = function(self)
			if self.TimerID == nil then return end

			self.timer.clearInterval(self.TimerID)
			self.TimerID = nil
		end
	},
}

function Clock:SetCompatibility(name)
	self._compatibility = self.compatibility[name]
	if self._compatibility and self._compatibility.init then
		self._compatibility.init(self)
	end
end

local events_map = {
	sec = "OnSecond",
	min = "OnMinute",
	hour = "OnHour",
	day = "OnDay",
	yday = "OnYearDay",
	wday = "OnWeekDay",
	month = "OnMonth",
	year = "OnYear"
}

local events_map2 = {
	wday = {
		name = "OnWeek",
		get = function(self, curDay, dateData)
			if curDay == 1 and self.OnWeek then
				self:OnWeek(math.ceil((curDay + 1 + dateData.day) / 7), dateData)
			end
		end
	}
}

function Clock:Start(utc)
	local format = utc and "!*t" or "*t"
	local previous, now, cback = os.date(format)

	self._compatibility.setInterval(self, function()
		now = os.date(format)
		for name, value in pairs(now) do
			if value ~= previous[name] then
				if events_map[name] and self[events_map[name]] then
					self[events_map[name]](value, now)
				end

				if events_map2[name] and self[events_map2[name]] then
					self[events_map2[name]](value, now)
				end
			end
		end
	end)
end

function Clock:Stop()
	self._compatibility.clearInterval(self)
end

local getters = {
	GetSecond = function(dateData)
		return dateData.sec
	end,
	GetMinute = function(dateData)
		return dateData.min
	end,
	GetHour = function(dateData)
		return dateData.hour
	end,
	GetDay = function(dateData)
		return dateData.day
	end,
	GetYearDay = function(dateData)
		return dateData.yday
	end,
	GetWeekDay = function(dateData)
		return dateData.wday
	end,
	GetWeek = function(dateData)
		return math.ceil((dateData.wday + 1 + dateData.day) / 7)
	end,
	GetMonth = function(dateData)
		return dateData.month
	end,
	GetYear = function(dateData)
		return dateData.year
	end
}

for name, getter in pairs(getters) do
	Clock[name] = function(self, utc)
		return getter(os.date(utc and "!*t" or "*t"))
	end
end

return setmetatable(Clock, {
	__call = function(self, compatibility, utc)
		local instance = setmetatable({}, self)
		instance:SetCompatibility(compatibility or "Garrysmod")
		instance:Start(utc)
		return instance
	end
})
