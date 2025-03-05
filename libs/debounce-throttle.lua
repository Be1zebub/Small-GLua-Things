-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/debounce-throttle.lua


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
		local args = {...}

		timer.Create(timerName, timeout, 1, function()
			func(unpack(args))
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
			local args = {...}

			timer.Create(timerName, timeout - delta, 1, function()
				func(unpack(args))
			end)
		else
			func(...)
			timer.Create(timerName, timeout, 1, function() end)
		end
	end
end

-- simpler version of util.Throttle - i coded this to use it in fivem (cfx has no timer.Remove), ill leave it here for the history.
function util.ThrottleSimple(func, timeout)
	local throttle, running = false, false
	local args, lastCall

	return function(...)
		local prevCall = lastCall
		lastCall = SysTime()

		local delta = prevCall and lastCall - prevCall

		if running and delta and delta <= timeout then
			throttle = true
			args = {...}
		else
			func(...)
			running = true

			timer.Simple(timeout, function()
				running = false

				if throttle then
					func(unpack(args))
					args = nil
					throttle = false
				end
			end)
		end
	end
end
