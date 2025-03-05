-- education purpose only!!!
-- this code will break _G behavior!

-- check this one too btw:
-- https://gist.github.com/noaccessl/76efe3edf15507c4f1652975d3a8befb

setmetatable(_G, {__index = function(_, k) return k end})

debug.setmetatable(debug.getmetatable(""), {
    __add = function(s1, s2) return s1.." "..s2 end,
    __unm = function(self) return self:reverse() end
})
print(hello + -dlrow)
