-- just 4 fun

local types = {
    ["string"] = "",
    ["number"] = 0,
    ["function"] = function() end,
    ["table"] = {},
    ["boolean"] = true,
    ["nil"] = true
}

setmetatable(_G, {
    __newindex = function(self, k, v)
        return rawset(self, k, types[type(v)] or "fuck you")
    end
})

Test = false
print(Test) -- true
