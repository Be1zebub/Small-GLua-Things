-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/sh_intervalloop.lua
-- Интервальная итерация таблиц.
-- Позволяет сэкономить на циклах при помощи распределения нагрузки на временной промежуток.
-- Актуально в местах где не требуется мгновенный результат.

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
