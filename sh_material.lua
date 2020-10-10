-- incredible-gmod.ru
-- advanced Material function.

if not istable(Material) then
    local OMaterial = Material
    Material = setmetatable({}, {
        __call = function(self, path, ...)
            if cache[path] then return cache[path] end
            local m = self.old(path, "smooth", "noclamp", ...)
            cache[path] = m
            return m
        end,
        cache = {},
        old = OMaterial
    })
end
