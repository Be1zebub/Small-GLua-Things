-- incredible-gmod.ru

function NewAnimation(length, ease, cback, onend, delay)
    ease = ease or -1
    delay = delay or 0

    local systime = SysTime()
    local starttime, endtime = systime + delay, systime + delay + length
    local h_name = "incredible-gmod.ru/NewAnimation/".. delay .."/".. debug.traceback()
    local fraction, frac

    hook.Add("Think", h_name, function()
        systime = SysTime()
        if starttime > systime then return end

        fraction = math.Clamp(math.TimeFraction(starttime, endtime, systime), 0, 1)

        if ease < 0 then
            frac = fraction ^ (1 - fraction - 0.5)
        elseif ease > 0 and ease < 1 then
            frac = 1 - (1 - fraction) ^ (1 / ease)
        end

        cback(frac)

        if fraction == 1 then
            if onend then onend() end
            hook.Remove("Think", h_name)
        end
    end)
end
