-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/utils/no-error-models.lua
-- replacing  errors with cube model
-- draws text over errors (to understand what content is missing in the server content pack)

-- good thing, but ui & placeholder model is ugly.
-- if you would use it on your server, consider improving this.
-- I also recommend Ley's sexy errors (and alternatives) - you can use this script to render the UI when "developer 1", and replace the models with better looking script.

local color = {
    mdl = Color(220, 220, 220),
    hint = Color(200, 0, 0)
}
local errors, already = setmetatable({}, {__mode = "v"}), setmetatable({}, {__mode = "k"})
local index = 0
local max_dist = 512 ^ 2

hook.Add("HUDPaint", "gmod.one/no-errors", function()
    local ents = ents.GetAll()
    local ent

    for _ = 1, 8 do
        index = index + 1
        if index > #ents then index = 1 end

        ent = ents[index]
        if IsValid(ent) == false or (already[ent] and already[ent] == ent:GetModel()) then continue end

        if ent.errorMDL or (ent:GetModel() and util.IsValidModel(ent:GetModel()) == false) then
            if ent.errorMDL == nil or ent:GetModel() ~= "models/hunter/blocks/cube025x025x025.mdl" then
                ent.errorMDL = ent:GetModel()
            end
            ent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
            errors[#errors + 1] = ent
            already[ent] = ent.errorMDL
        end
    end

    color.hint.r = 150 + math.abs(math.sin(CurTime()) * 100)

    local rendered = 0
    local eye = EyePos()

    for i = #errors, 1, -1 do
        ent = errors[i]
        if IsValid(ent) == false then
            table.remove(errors, i)
            continue
        end

        if ent:GetPos():DistToSqr(eye) > max_dist then continue end

        local pos = ent:GetPos():ToScreen()
        if pos.visible == false then continue end

        draw.SimpleText("Model rendering error, it looks like you havent downloaded the server content!", "Default", pos.x, pos.y, color.hint, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        local _, th = draw.SimpleText("model has been replaced with a cube, to not look as ass", "Default", pos.x, pos.y, color.mdl, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(ent.errorMDL, "Default", pos.x, pos.y + th, color.mdl, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        rendered = rendered + 1
        if rendered == 16 then return end
    end
end)
