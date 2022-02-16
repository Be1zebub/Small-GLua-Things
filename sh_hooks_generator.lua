-- idk who might need it, but:
-- incredible-gmod.ru

if not (debug.getmetatable(hook) and debug.getmetatable(hook).__call) then return end

setmetatable(hook, {__call = function(self, v)
    return {
        Add = function(self, name, func)
            hook.Add(v, name, func)
            return self
        end
    }
end})

--[[ EXAPLE:

hook("HUDPaint")
:Add("Text", function()
    draw.SimpleText("Hello world", "Default", ScrW() * 0.5, 32, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)
:Add("Box", function()
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(ScrW() * 0.5 - 64, 16, 128, 32)
end)

]]--
