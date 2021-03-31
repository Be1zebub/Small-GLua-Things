setmetatable(_G, {__index = function(_, v) return v end})
debug.setmetatable(debug.getmetatable(""), {
    __add = function(s1, s2) return s1.." "..s2 end,
    __unm = function(self) return self:reverse() end
})
print(hello + -dlrow)
