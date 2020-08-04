-- Интервальная итерация таблиц.
-- Позволяет сэкономить на циклах при помощи распределения нагрузки на временной промежуток.
-- Актуально в местах где не требуется мгновенный результат.

local lnum = 0
function IntervalLoop(time, tab, callback, notsequential)
    lnum = lnum + 1
    if notsequential then -- table.IsSequential это клёво, но хардкодинг не требует лишних циклов.
        timer.Create("IntervalLoop"..lnum, time, table.Count(tab), function()
            local k, v = next(tab)
            callback(v, k)
            tab[k] = nil
        end)
    else
        local i = 0
        timer.Create("IntervalLoop"..lnum, time, #tab, function()
            i = i + 1
            callback(tab[i], i)
        end)
    end
end
