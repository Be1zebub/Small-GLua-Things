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

-- wrapper which allows you to get rid of pyramids without using coroutine
local function Bench()
	local bench = {
		process = {},
		Start = function(self, count)
			self.count = count
			self:Run()
		end,
		Run = function(self, id, onfinish)
			id = (id or 0) + 1
			local process = self.process[id]
			if process == nil then return end
			
			Benchmark(process.uid, process.func, self.count, function()
				self:Run(id)
			end)
		end,
		Add = function(self, uid, func)
			table.insert(self.process, {uid = uid, func = func})
			return self
		end
	}
	bench.__index = bench
	
	return bench
end
    
--[[ Wrapper example:
    
Bench()
:Add("Default", function()
	local bool = isstring("qwerty")
end)
:Add("Metatable", function()
	local bool = isstring2("qwerty")
end)
:Add("AssocTable", function()
	local bool = isstring3("qwerty")
end)
:Add("Equal", function()
	local bool = isstring4("qwerty")
end)
:Start(10000000) -- 10 000 000

    
    Full code: https://github.com/Be1zebub/Small-GLua-Things/blob/master/benchmarks/isstring.lua
]]--
