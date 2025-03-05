-- deprecated
-- this can be useful, but its not such a complicated operation to create special helper functions for it.

-- education purpose only!
-- I didnt delete it only because it might be useful for someone to learn about this optimization method.

--[[ it can be replaced just with
local len, i = #tbl, 0
timer.Create("iterate-my-table", 0, len, function()
	i = i + 1
	handle(tbl[i], i)
	if i == len then onFinish() end
end)
]]--

local lnum = 0
function IntervalLoop(time, tab, callback, notsequential, onfinish)
    lnum = lnum + 1
    local uid = "IntervalLoop".. lnum

    if notsequential then -- table.IsSequential это клёво, но хардкодинг не требует лишних циклов.
        local count = table.Count(tab)
        timer.Create(uid, time, count, function()
            local k, v = next(tab)
            callback(v, k)
            tab[k] = nil
        end)

        if onfinish then
            timer.Simple(time * count, onfinish)
        end
    else
        local count = #tab
        local i = 0
        timer.Create(uid, time, count, function()
            i = i + 1
            callback(tab[i], i)
        end)

        if onfinish then
            timer.Simple(time * count, onfinish)
        end
    end

    return {
        Stop = function()
            return timer.Stop(uid)
        end,
        Remove = function()
            timer.Remove(uid)
        end,
        Pause = function()
            return timer.Pause(uid)
        end,
        TimeLeft = function()
            return timer.TimeLeft(uid)
        end,
        RepsLeft = function()
            return timer.RepsLeft(uid)
        end
    }
end
