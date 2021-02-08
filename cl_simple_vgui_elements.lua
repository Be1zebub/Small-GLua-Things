-- incredible-gmod.ru

function AddProperty(self, name, construct)
	self["Set".. name] = function(me, ...)
		if construct then
			me[name] = construct(...)
		else
			me[name] = ...
		end
		return me
	end

	self["Get".. name] = function(me)
		return me[name]
	end
end


local PANEL = {}

PANEL.Color = Color(255, 255, 255)
AddProperty(PANEL, "Color")

PANEL.Material = Material("error")
AddProperty(PANEL, "Material")

function PANEL:Paint(w, h)
	surface.SetDrawColor(self.Color)
	surface.SetMaterial(self.Material)
	surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("Material", PANEL, "EditablePanel")

local PANEL = {}

PANEL.Color = Color(255, 255, 255)
AddProperty(PANEL, "Color")

function PANEL:Paint(w, h)
	surface.SetDrawColor(self.Color)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("Rect", PANEL, "EditablePanel")

local PANEL = {}

PANEL.Text = "Panel:SetText"
AddProperty(PANEL, "Text")

PANEL.Font = "DermaDefault"
AddProperty(PANEL, "Font")

PANEL.Color = Color(255, 255, 255)
AddProperty(PANEL, "Color")

function PANEL:Paint(w, h)
	draw.SimpleText(self.Text, self.Font, 0, 0, self.Color)
end

function PANEL:SetAlign(xalign, yalign)
	surface.SetFont(self.Font)
	local w, h = surface.GetTextSize(self.Text)

	local x, y = self:GetPos()

	if xalign == TEXT_ALIGN_CENTER then
		x = x - w / 2
	elseif xalign == TEXT_ALIGN_RIGHT then
		x = x - w
	end

	if yalign == TEXT_ALIGN_CENTER then
		y = y - h / 2
	elseif yalign == TEXT_ALIGN_BOTTOM then
		y = y - h
	end

	self:SetPos(math.ceil(x), math.ceil(y))
end

function PANEL:SizeToContents()
	surface.SetFont(self.Font)
	self:SetSize(surface.GetTextSize(self.Text))
end

vgui.Register("Text", PANEL, "EditablePanel")
