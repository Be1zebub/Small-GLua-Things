-- a replacement for DColorCube that renders the correct colors and has a nicer knob
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/colorcube.lua
-- from incredible-gmod.ru with <3

-- how it looks:
-- https://i.imgur.com/zfBZ1dR.png
-- https://cdn.discordapp.com/attachments/676069143463723018/972683973669027880/color-picker.webm

--[[ example:
	local custom = vgui.Create("DFrame")
	custom:SetSize(512, 256 + 25)
	custom:MakePopup()
	custom:SetTitle("     from incredible-gmod.ru with <3")
	custom.PaintOver = function(me, w, h)
		surface.SetDrawColor(me.cube:GetColor())
		surface.DrawRect(6, 7, 12, 12)
	end

	custom.cube = custom:Add("incredible-gmod.ru/ColorCube")
	custom.cube:Dock(FILL)

	local default = vgui.Create("DFrame")
	default:SetSize(512, 256 + 25)
	default:MakePopup()
	default:SetTitle("Default color cube (for a comparison)")
	default.y = custom:GetTall() + 8

	default:Add("DColorCube"):Dock(FILL)
]]--

local function ColorCube(hue, w, h, pixel_size, name)
	pixel_size = pixel_size or 1
	name = name or "incredible-gmod.ru/ColorCube/".. debug.traceback()

	local rt = GetRenderTarget(name, w, h)
	local materialData = {
		["$basetexture"] = rt:GetName()
	}

	render.PushRenderTarget(rt)
	render.Clear(0, 0, 0, 0, true, true)

	cam.Start2D()
		for x = 0, w - 1, pixel_size do
			for y = 0, h - 1, pixel_size do
				surface.SetDrawColor(HSVToColor(hue, 1 - x / w, 1 - y / h))
				surface.DrawRect(x, y, pixel_size, pixel_size)
			end
		end
	cam.End2D()

	render.PopRenderTarget()

	return CreateMaterial(name, "UnlitGeneric", materialData)
end

local function ColorToHex(col)
	return (col.r * 0x10000) + (col.g * 0x100) + col.b
end

local black, white = Color(0, 0, 0), Color(255, 255, 255)
local smooth_contrast = Color(0, 0, 0)

local function ColorContrast(col, smooth)
	if smooth then
		local c = 255 - ColorToHex(col) / 0x00ffff
		smooth_contrast.r, smooth_contrast.g, smooth_contrast.b = c, c, c
		return smooth_contrast
	else
		return ColorToHex(col) > 0xffffff * 0.5 and black or white
	end
end

local knob_mat = Material("dev/clearalpha")

file.CreateDir("incredible-gmod.ru")
if file.Exists("incredible-gmod.ru/color-picker-knob.png", "DATA") then
	knob_mat = Material("data/incredible-gmod.ru/color-picker-knob.png")
else
	http.Fetch("https://i.imgur.com/tI9UkDb.png", function(img)
		file.Write("incredible-gmod.ru/color-picker-knob.png", img)
		knob_mat = Material("data/incredible-gmod.ru/color-picker-knob.png")
	end)
end

local CUBE = {}

function CUBE:Init()
	self.hue = 0
	self.pixel_size = 1
	self.color = Color(255, 255, 255)
	self:SetCursor("hand")

	self.background = self:Add("EditablePanel")
	self.background:Dock(FILL)
	self.background:DockMargin(9, 9, 9, 9)
	self.background:SetCursor("hand")
	self.background.Paint = function(me, w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(self.material)
		surface.DrawTexturedRect(0, 0, w, h)
	end
	self.background.OnMousePressed = function(_, mcode)
		self:OnMousePressed(mcode)
	end

	self.knob = self:Add("incredible-gmod.ru/ColorCube/Knob")
	self.knob.OnDrag = function(me)
		self.color = HSVToColor(self.hue, 1 - (me.x + me:GetWide() * 0.5) / self:GetWide(), 1 - (me.y + me:GetTall() * 0.5) / self:GetTall())
		self.knob.contrast_color = ColorContrast(self.color, true)
		if self.OnChange then
			self:OnChange(self.color)
		end
	end
end

function CUBE:SetHue(hue)
	self.hue = hue
	self:InvalidateLayout()
end

function CUBE:GetHue()
	return self.hue
end

function CUBE:SetPixelSize(pixel_size)
	self.pixel_size = pixel_size
end

function CUBE:GetPixelSize()
	return self.pixel_size
end

function CUBE:SetColor(rgb)
	self.color = rgb

	local h, s, v = ColorToHSV(rgb)
	self.hue = h
	self.knob.x = s * self:GetWide() - self.knob:GetWide() * 0.5
	self.knob.y = v * self:GetTall() - self.knob:GetTall() * 0.5
	self.knob.contrast_color = ColorContrast(rgb, true)

	self:InvalidateLayout()

	if self.OnChange then
		self:OnChange(self.color)
	end
end

function CUBE:GetColor()
	return self.color
end

function CUBE:PerformLayout(w, h)
	self.knob:OnDrag()

	if self.hue == self.hue_prev then return end
	self.hue_prev = self.hue

	self.material = ColorCube(self.hue, w, h, self.pixel_size)
end

function CUBE:OnMousePressed(mcode)
	if mcode ~= MOUSE_LEFT then return end

	self.knob.Dragging = true
	self.knob:Think()
end

vgui.Register("incredible-gmod.ru/ColorCube", CUBE, "EditablePanel")

local KNOB = {}

function KNOB:Init()
	self:SetSize(18, 18)
	self:SetCursor("sizeall")
	self.Dragging = false
end

function KNOB:Paint(w, h)
	surface.SetMaterial(knob_mat)

	surface.SetDrawColor(self.contrast_color)
	surface.DrawTexturedRect(0, 0, w, h)

	surface.SetDrawColor(self:GetParent():GetColor())
	surface.DrawTexturedRect(2, 2, w - 4, h - 4)
end

function KNOB:OnMousePressed(mcode)
	if mcode ~= MOUSE_LEFT then return end

	self.Dragging = true
end

function KNOB:Think()
	if self.Dragging == false then return end

	if input.IsMouseDown(MOUSE_LEFT) == false then
		self.Dragging = false
		return
	end

	local parent = self:GetParent()
	local x, y = parent:LocalCursorPos()
	self.x = math.Clamp(x - self:GetWide() * 0.5, 0, parent:GetWide() - self:GetWide())
	self.y = math.Clamp(y - self:GetTall() * 0.5, 0, parent:GetTall() - self:GetTall())

	if self.OnDrag then
		self:OnDrag()
	end
end

vgui.Register("incredible-gmod.ru/ColorCube/Knob", KNOB, "EditablePanel")
