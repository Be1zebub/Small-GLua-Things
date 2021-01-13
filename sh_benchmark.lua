-- Lua Benchmark
-- incredible-gmod.ru

function Benchmark(uid, func, count, onfinish)
    timer.Simple(0, function() -- 1 tick delay
        local start = SysTime()
    
        for i = 1, count do
            func()    
        end
        
        print(uid, SysTime() - start)
        
        if onfinish then onfinish() end
    end)
end

--[[ EXAMPLE BENCH:

local tab = {}
for i = 1, 1000 do -- 1k
    table.insert(tab, i)    
end

local repeats = 100000 -- 100k

Benchmark("table.Random", function()
    local v = table.Random(tab)
end, repeats, function()
    Benchmark("math.random", function()
        local v = tab[ math.random(#tab) ]
    end, repeats)
end)

]]--
