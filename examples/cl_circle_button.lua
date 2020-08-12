-- incredible-gmod.ru
-- Circle button example

local math_Approach, sin, cos, rad = math.Approach, math.sin, math.cos, math.rad

local function GeneratePolyCircle(x, y, radius, quality)
    local circle = {}
    local tmp = 0
    local s, c

    for i = 1, quality do
        tmp = rad(i * 360) / quality
        s = sin(tmp)
        c = cos(tmp)

        circle[i] = {
            x = x + c * radius,
            y = y + s * radius,
            u = (c + 1) / 2,
            v = (s + 1) / 2
        }
    end

    return circle
end

local poly_circle = GeneratePolyCircle(32, 32, 32, 64)

concommand.Add("circlebtn_exapmle", function()
    local btn = vgui.Create("DButton")
    btn:SetText("")
    btn:SetSize(64, 64)
    btn:Center()
    btn:MakePopup()
    btn.DoClick = function(self)
        if not self.CircleHover then return end
        self:Remove()
    end
    btn.DrawAlpha = 0
    btn.Paint = function(self, w, h)
        self.DrawAlpha = math_Approach(self.DrawAlpha, self.CircleHover and 255 or 50, FrameTime()*650)

        draw.NoTexture()
        surface.SetDrawColor(ColorAlpha(color_white, self.DrawAlpha))
        surface.DrawPoly(poly_circle)

        local _, szy = draw.SimpleText("Circle Button", "DermaDefault", w/2, h/2, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Example", "DermaDefault", w/2, h/2 +szy, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local radius = btn:GetWide()/2
    btn.Think = function(self)
        local curx, cury = self:CursorPos()
        self.CircleHover = math.Distance(curx, cury, radius, radius) < radius
        self:SetCursor(self.CircleHover and "hand" or "arrow")
    end
end)
