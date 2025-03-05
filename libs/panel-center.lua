-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/panel-center.lua

local Panel = FindMetaTable("Panel")

function Panel:CenterX(fraction)
    fraction = fraction or 0.5
    self.X = self:GetParent():GetWide() * fraction - self:GetWide() * 0.5
end

function Panel:CenterY(fraction)
    fraction = fraction or 0.5
    self.Y = self:GetParent():GetTall() * fraction - self:GetTall() * 0.5
end
