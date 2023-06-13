-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/await.lua

function await(fn, ...)
    local co = coroutine.running()

    fn(function(succ, err, ...)
        if succ == false then
            ErrorNoHaltWithStack(err .."\n")
        end

        coroutine.resume(co, err, ...)
    end, ...)

    return coroutine.yield()
end

function fetch(cback, url)
    http.Fetch(url, function(body, len, headers, code)
        cback(true, body, len, headers, code)
    end, function(err)
        cback(false, err)
    end)
end

local response = await(fetch, "https://google.com/")


-- if you doesnt wont to design your sync functions

function await(fn, cback_pos, ...)
    local co = coroutine.running()

    local args = {...}

    if cback_pos then
        for i = cback_pos, #args do
            args[i + 1], args[i] = args[i], nil
        end
    end

    args[cback_pos or #args + 1] = function(...)
        coroutine.resume(co, ...)
    end

    fn(unpack(args))

    return coroutine.yield()
end

local response = await(http.Fetch, 2, "https://google.com/")
