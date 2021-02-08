-- incredible-gmod.ru

local Panel = FindMetaTable("Panel")

function Panel:CenterX(fraction)
    fraction = fraction or 0.5
    self.X = self:GetParent():GetWide() * fraction - self:GetWide() * fraction
end

function Panel:CenterY(fraction)
    fraction = fraction or 0.5
    self.Y = self:GetParent():GetTall() * fraction - self:GetTall() * fraction
end
