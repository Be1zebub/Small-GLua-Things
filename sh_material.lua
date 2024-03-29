-- incredible-gmod.ru
-- advanced Material function.

if not istable(Material) then
    local OMaterial = Material
    Material = setmetatable({
        cache = {},
        old = OMaterial
    }, {
        __call = function(self, path, ...)
            if self.cache[path] then return self.cache[path] end
            local m = self.old(path, "smooth mips")
            self.cache[path] = m
            return m
        end
    })
end
