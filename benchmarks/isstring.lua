local timer_Simple, print, SysTime, isstring, type = timer.Simple, print, SysTime, isstring, type

-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/sh_benchmark.lua
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

local type, getmetatable = type, getmetatable

local str = getmetatable("")

local function isstring2(var)
	return getmetatable(var) == str
end

local str2 = {["string"] = true}
local function isstring3(var)
	return str2[type(var)] or false
end

local str3 = "string"
local function isstring4(var)
	return type(var) == str3
end

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
