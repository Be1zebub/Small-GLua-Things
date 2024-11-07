-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/debounce-throttle.lua


--[[ usage example:
local search = util.Throttle(function(query)
	net.Start("logs/search")
		net.WriteString(query)
	net.SendToServer()
end, 250)

userinput.OnChange = function(me)
	search(me:GetValue())
end
]]--

local function GenerateTimer(prefix)
	local trace = debug.getinfo(2, "Sln")
	return prefix .. "/" .. util.CRC(debug.traceback()) .. " / " .. trace.short_src .. ":" .. trace.currentline
end


-- delays call, if previous delayed rm old delay
function util.Debounce(func, timeout)
	local timerName = GenerateTimer("util.Debounce")

	return function(...)
		timer.Create(timerName, timeout, 1, function()
			func(...)
		end)
	end
end

-- if previous called was recent, delay call
function util.Throttle(func, timeout)
	local timerName = GenerateTimer("util.Throttle")
	local lastCall

	return function(...)
		local prevCall = lastCall
		lastCall = SysTime()

		local delta = prevCall and lastCall - prevCall

		if delta and delta <= timeout then
			timer.Create(timerName, timeout - delta, 1, function()
				func(...)
			end)
		else
			func(...)
			timer.Create(timerName, timeout, 1, function() end)
		end
	end
end
