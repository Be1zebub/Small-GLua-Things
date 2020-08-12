-- incredible-gmod.ru
-- fun freecam script
-- ConCommand: freecam_frame

local input_IsMouseDown, input_IsKeyDown, draw_RoundedBox, input_GetCursorPos, input_SetCursorPos, CurTime_, draw_SimpleText = input.IsMouseDown, input.IsKeyDown, draw.RoundedBox, input.GetCursorPos, input.SetCursorPos, CurTime, draw.SimpleText
local render_RenderView, Vector_, Angle_, IsValid_, math_Round, isangle_ = render.RenderView, Vector, Angle, IsValid, math.Round, isangle
local TEXT_ALIGN_CENTER_, TEXT_ALIGN_TOP_, TEXT_ALIGN_BOTTOM_, TEXT_ALIGN_LEFT_ = TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, TEXT_ALIGN_BOTTOM, TEXT_ALIGN_LEFT
local MaxDist, color_black, player_GetAll, cam_Start3D, cam_End3D, render_SetColorMaterial, render_SetBlend, render_DrawBox, ColorAlpha_, team_GetColor, render_DrawWireframeBox = 7500*7500, Color(0, 0, 0), player.GetAll, cam.Start3D, cam.End3D, render.SetColorMaterial, render.SetBlend, render.DrawBox, ColorAlpha, team.GetColor, render.DrawWireframeBox
local LerpAngle_, LerpVector_ = LerpAngle, LerpVector

-- Не хочу запариваться с переносом этих вещей.. Мне чёта в падлу)
-- Это минифицированный набор типичных штук,которые я юзаю в своих UI.
Incredible_DsLogs=Incredible_DsLogs or{}Incredible_DsLogs.ColorSchemes={["dark"]={dark=Color(10,10,10),semi_light=Color(39,39,39),light=Color(51,51,51),lighter=Color(60,60,60),health=Color(91,46,186),armor=Color(31,87,231),red=Color(175,50,50),red_hover=Color(200,75,75),green=Color(50,170,80),green_hover=Color(75,195,105),btn=Color(39,62,75),btn_hover=Color(45,68,81)}}local a,b=CreateClientConVar("incdslogs_colorscheme","dark",true),ColorAlpha;Incredible_DsLogs.GetUIColor=function(c,d)local e=Incredible_DsLogs.ColorSchemes[a:GetString()]or Incredible_DsLogs.ColorSchemes["dark"]if d then local f=e[c]if not f then return end;return b(f,d)end;return e[c]end;function LeftText(a,b,c,d,e,f)return draw_SimpleText(a,b or"inc_roboto_small",c,d,e or color_white,TEXT_ALIGN_LEFT_,f and TEXT_ALIGN_TOP_ or TEXT_ALIGN_CENTER_)end function CenterText(a,b,c,d,e,f)return draw_SimpleText(a,b or"inc_roboto_small",c,d,e or color_white,TEXT_ALIGN_CENTER_,f and TEXT_ALIGN_TOP_ or TEXT_ALIGN_CENTER_)end
surface.CreateFont("inc_roboto_medium",{font="Roboto",extended=true,antialias=true,size=24,weight=500})surface.CreateFont("inc_roboto_semismall",{font="Roboto",extended=true,antialias=true,size=18,weight=500})surface.CreateFont("inc_roboto_small",{font="Roboto",extended=true,antialias=true,size=16,weight=500})surface.CreateFont("inc_roboto_superlarge",{font="Roboto",extended=true,antialias=true,size=48,weight=500})

local VecAngRound = function(v)
  local a=function(b)return math_Round(b)end;
  return isangle_(v)and Angle_(a(v.p),a(v.y),a(v.r))or Vector_(a(v.x),a(v.y),a(v.z))
end

local PANEL = {}

function PANEL:Init()
	self.VecPosition = FreecamPOS or ( LocalPlayer():GetPos() + Vector(0, 0, LocalPlayer():OBBMaxs().z) )
	self.AngRotate = FreecamANG or LocalPlayer():EyeAngles()
	self.CameraRoll = FreecamROLL or 0

	self:SetMouseInputEnabled(true)

	LocalPlayer():GetViewModel():SetNoDraw(true)
	for _, v in ipairs(ents.FindByClass("physgun_beam")) do
        if v:GetParent() == LocalPlayer() then
            v:SetNoDraw(true)
        end
    end
end

function PANEL:OnRemove()
	FreecamPOS = self.VecPosition
	FreecamANG = self.AngRotate
	FreecamROLL = self.CameraRoll

	LocalPlayer():GetViewModel():SetNoDraw(false)
	for _, v in ipairs(ents.FindByClass("physgun_beam")) do
        if v:GetParent() == LocalPlayer() then
            v:SetNoDraw(false)
        end
    end
end

local white_transparent = Color(255, 255, 255, 150)
local saved_ = Color(86, 250, 0, 175)
local frame_w = 0
local DrawCenterText = function(str, y)
	local _, tall = draw_SimpleText(str, "inc_roboto_medium", frame_w/2, y, white_transparent, TEXT_ALIGN_CENTER_, TEXT_ALIGN_TOP_)

	return y + tall
end

function PANEL:Paint(w, h)
	local x, y = self:LocalToScreen(self:GetPos())
	y = y - 25

	render_RenderView( {
		origin = self.VecPosition,
		angles = self.AngRotate,
		x = x, y = y,
		w = w, h = h
	})

	if not self.HideUI then
		local draw_v, draw_a = VecAngRound(self.VecPosition), VecAngRound(self.AngRotate)
		local _, tall = draw_SimpleText("Angle("..draw_a.p..", "..draw_a.y..", "..draw_a.r..")", "inc_roboto_medium", w / 2, h, white_transparent, TEXT_ALIGN_CENTER_, TEXT_ALIGN_BOTTOM_)
		draw_SimpleText("Vector("..draw_v.x..", "..draw_v.y..", "..draw_v.z..")", "inc_roboto_medium", w / 2, h - tall, white_transparent, TEXT_ALIGN_CENTER_, TEXT_ALIGN_BOTTOM_)
	
		frame_w = w

		if self.ShowControls then
			local pos = 0
			pos = DrawCenterText("Hold [LMB] + Rotate Mouse — Camera Rotate", pos)
			pos = DrawCenterText("Hold [RMB] — Roll Camera (L.Shift — SpeedUp)", pos)
			pos = DrawCenterText("Press [WASD] — Move Camera", pos)
			pos = DrawCenterText("Hold [L.Shift] — SpeedUp Camera Move&Rotate", pos)
			pos = DrawCenterText("Hold [L.Shift] + [L.Alt] — SpeedUp Only Camera Rotate", pos)
			pos = DrawCenterText("Scroll [Mouse Whell] — Zoom-in / Zoom-out", pos)
			pos = DrawCenterText("Press [P] — Save camera position", pos)
			pos = DrawCenterText("Press [R] — Return to "..(self.saved_position and "saved" or "original").." position", pos)

			--if self.ReturnToOriginalPos then
				pos = DrawCenterText("Press [L.Shift]/[L.Alt] — Change return speed", pos)
			--end

			pos = DrawCenterText("Press [Space] — Move up", pos)
			pos = DrawCenterText("Press [L.Ctrl] — Move down", pos)
			pos = DrawCenterText("Press [Z] — Restore position", pos)

			pos = DrawCenterText("Press [F2] — Hide UI", pos)
			pos = DrawCenterText("Press [F1] — Hide Controls", pos)
		else
			DrawCenterText("[F1] — Show Controls", 0)
		end
	
		if self.Saved then
			local _, tall = draw_SimpleText("Position has been saved", "inc_roboto_medium", w*0.5, h*0.5, saved_, TEXT_ALIGN_CENTER_, TEXT_ALIGN_TOP_)
			DrawCenterText("[R] — Smooth return to that position", h*0.5+tall)
		end
	end

	if self.HelpfulEsp then
		cam_Start3D(self.VecPosition, self.AngRotate)
			for _, ply in pairs(player_GetAll()) do
				if ply == LocalPlayer() then continue end
		        if ply:GetPos() == Vector_(0,0,0) then continue end
		        
		        if ply:GetPos():DistToSqr(self.VecPosition) > MaxDist then continue end

		        local pos, ang = ply:GetPos(), ply:GetAngles()
	            local min, max = ply:OBBMins(), ply:OBBMaxs()

	            render_SetColorMaterial()
	            render_SetBlend(1)
	            render_DrawBox(pos, ang, min, max, ColorAlpha_(team_GetColor(ply:Team()), 100))
	            render_DrawWireframeBox( pos, ang, min, max, color_black)
		    end
		cam_End3D()
	end
end

function PANEL:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end
	self.StartCapture = CurTime_() + 0.1
end

function PANEL:OnMouseWheeled(delta)
	local mult = input_IsKeyDown(KEY_LSHIFT) and 100 or 20
	local new = delta*mult

	local ang = self.AngRotate
	self.VecPosition = LerpVector_(0.5, self.VecPosition, self.VecPosition + Vector_(0, 0, 0) + ang:Forward()*new)
end

function PANEL:CaptureMouse()
	local x, y = input_GetCursorPos()

	local dx = x - (self.mx or 0)
	local dy = y - (self.my or 0)

	local centerx, centery = self:LocalToScreen(self:GetWide() * 0.5, self:GetTall() * 0.5)
	input_SetCursorPos(centerx, centery)
	self.mx = centerx
	self.my = centery

	return dx, dy, (self.StartCapture or 0) < CurTime_()
end

function PANEL:Think()
	local hide_cursor

	if input_IsKeyDown(KEY_F1) then
		if (self.NextControlsSwitch or 0) < CurTime_() then
			self.NextControlsSwitch = CurTime_() + 0.2
			self.ShowControls = not self.ShowControls
		end
	end

	if input_IsKeyDown(KEY_F2) then
		if (self.NextHideUI or 0) < CurTime_() then
			self.NextHideUI = CurTime_() + 0.2
			self.HideUI = not self.HideUI
		end
	end

	if input_IsKeyDown(KEY_P) then
		self.saved_position = self.VecPosition
		self.saved_ang_position = self.AngRotate

		if not self.Saved then
			self.Saved = true
			timer.Simple(2.5, function()
				self.Saved = false
			end)
		end
	end

	if input_IsKeyDown(KEY_Z) then
		self.saved_position = LocalPlayer():GetPos() + Vector(0, 0, LocalPlayer():OBBMaxs().z)
		self.saved_ang_position = LocalPlayer():EyeAngles()
		--self.CameraRoll = FreecamROLL or 0
		self.ReturnToOriginalPos = true
	end

	if self.ReturnToOriginalPos then
		if input_IsKeyDown(KEY_W)or input_IsKeyDown(KEY_S)or input_IsKeyDown(KEY_D)or input_IsKeyDown(KEY_A)or input_IsKeyDown(KEY_SPACE)or input_IsKeyDown(KEY_LCONTROL)then self.ReturnToOriginalPos=false end

		local way = self.saved_position or Vector_(0, 0, 0)
		local way_ang = self.saved_ang_position or Angle_(0, 0, 0)

		local dist = self.VecPosition:DistToSqr(way)
		local mult = 0.025 * (input_IsKeyDown(KEY_LSHIFT) and 1 or input_IsKeyDown(KEY_LALT) and 0.05 or 0.25)--dist > 25000 and 0.025 or 0.1

		self.VecPosition = LerpVector_(mult, self.VecPosition, way)
		self.AngRotate = LerpAngle_(mult, self.AngRotate, way_ang)

		if dist < 1000 then
			self.ReturnToOriginalPos = false
		end
		return
	end

	if not self:IsHovered() then return end

	if input_IsMouseDown(MOUSE_RIGHT) then
		local x, y = self:CaptureMouse()
		self.CameraRoll = self.CameraRoll + x * (input_IsKeyDown(KEY_LSHIFT) and 0.01 or 0.001)

		self:SetCursor("blank")
		hide_cursor = true
	end

	self.AngRotate = self.AngRotate + Angle(0, 0, self.CameraRoll)
	self.CameraRoll = Lerp(FrameTime()*25, self.CameraRoll, 0)

	if input_IsKeyDown(KEY_R) then
		self.ReturnToOriginalPos = true
		return
	end

	local ang = self.AngRotate
	local add = Vector(0, 0, 0)

	if input_IsKeyDown(KEY_W) then add = add + ang:Forward() end
	if input_IsKeyDown(KEY_S) then add = add - ang:Forward() end
	if input_IsKeyDown(KEY_D) then add = add + ang:Right() end
	if input_IsKeyDown(KEY_A) then add = add - ang:Right() end
	if input_IsKeyDown(KEY_SPACE) then add = add + ang:Up() end
	if input_IsKeyDown(KEY_LCONTROL) then add = add - ang:Up() end
	add = add * (input_IsKeyDown(KEY_LSHIFT) and not input_IsKeyDown(KEY_LALT) and 20 or 5)

	self.VecPosition = LerpVector_(0.5, self.VecPosition, self.VecPosition + add)

	if input_IsMouseDown(MOUSE_LEFT) then
		local x, y, capt = self:CaptureMouse()
		local mult = input_IsKeyDown(KEY_LSHIFT) and 25 or 100

		if self.AngRotate.p > 360 or self.AngRotate.p < -360 then
			self.AngRotate.p = 0
		end

		if self.AngRotate.y > 360 or self.AngRotate.y < -360 then
			self.AngRotate.y = 0
		end

		if capt then
			self.AngRotate = LerpAngle(0.5, self.AngRotate, self.AngRotate - Angle_(-y/mult, x/mult, self.CameraRoll))
		end

		self:SetCursor("blank")
		return
    end

    if hide_cursor then return end
    self:SetCursor("arrow")
end

vgui.Register("incredible-gmod.ru_FreeCamera", PANEL, "Panel")

local PANEL = {}

local cols = {
	red = Color(175, 50, 50),
	red_hover = Color(200, 75, 75)
}

function PANEL:Init()
	self["bg_blur"] = vgui.Create("Panel")
	self["bg_blur"]:SetSize(ScrW(), ScrH())
	self["bg_blur"].Paint = function(self, w, h)
		Derma_DrawBackgroundBlur(self, 0)
	end

	self.title = ""

	self.WorkSpace = vgui.Create("incredible-gmod.ru_FreeCamera", self)
	self.WorkSpace:SetSize(self:GetWide(), self:GetTall() - 25)
	self.WorkSpace:SetPos(0, 25)	

	self.CloseButton = vgui.Create("DButton", self)
    self.CloseButton:SetSize(50, 25)
    self.CloseButton:SetPos(self:GetWide() - self.CloseButton:GetWide(), 0)
    self.CloseButton:SetText("")

    self.CloseButton.DoClick = function(self)
        self:GetParent():Close()
    end

    self.CloseButton.Paint = function(self, w, h)
        local col = self:IsHovered() and cols.red_hover or cols.red
        draw_RoundedBox(0, 0, 0, w, h, col)

        if self:IsHovered() then
            CenterText("X", "inc_roboto_medium", w / 2, h / 2, Color(255, 255, 255, 150))
        end
    end
end

function PANEL:PerformLayout()
	if IsValid_(self.WorkSpace) then
		self.WorkSpace:SetSize(self:GetWide(), self:GetTall() - 25)
		self.WorkSpace:SetPos(0, 25)
	end
	if IsValid_(self.CloseButton) then
		self.CloseButton:SetSize(50, 25)
    	self.CloseButton:SetPos(self:GetWide() - self.CloseButton:GetWide(), 0)
    end
end

function PANEL:Paint(w, h)
	draw_RoundedBox(0, 0, 0, w, h, Incredible_DsLogs.GetUIColor("semi_light"))
    draw_RoundedBox(0, 0, 0, w, 25, Incredible_DsLogs.GetUIColor("dark"))

    if self.title then
        LeftText(self.title, "inc_roboto_semismall", 5, 12.5)
    end
end

function PANEL:SetTitle(str)
	self.title = str
end

function PANEL:OpenAnimation()
	local x = ScrW()/2 - self:GetWide()/2

	self:SetMouseInputEnabled(false)
	self:SetKeyBoardInputEnabled(false)

	self:SetPos(x, -self:GetTall())
	self:MoveTo(x, ScrH()/2 - self:GetTall()/2, 0.25, 0, -1, function()
		self:SetMouseInputEnabled(true)
		self:SetKeyBoardInputEnabled(true)
	end)

	self["bg_blur"]:SetAlpha(0)
	self["bg_blur"]:AlphaTo(255, 0.25)
end

function PANEL:Think()
	if input.IsKeyDown(KEY_ESCAPE) then
		self:Close()
		timer.Simple(0, function()
			if gui.IsGameUIVisible() then
				gui.HideGameUI()
			end
		end)
	end
end

function PANEL:Close()
	if self.Closing then return end
	self.Closing = true

	self:SetMouseInputEnabled(false)
	self:SetKeyBoardInputEnabled(false)

	local x = self:GetPos()

	self:MoveTo(x, ScrH(), 0.25, 0, -1, function()
		self:Remove()
	end)

	self["bg_blur"]:AlphaTo(0, 0.25)
end

function PANEL:OnRemove()
	if IsValid(self.bg_blur) then
		self.bg_blur:Remove()
	end
end

vgui.Register("incredible-gmod.ru_TestViewFrame", PANEL, "Panel")


local anti_duplicate
concommand.Add("freecam_frame", function()
	if IsValid(anti_duplicate) then return end

	local frame = vgui.Create("incredible-gmod.ru_TestViewFrame")
	frame:SetSize(ScrW() - 100, ScrH() - 100)
	frame:PerformLayout()
	frame:SetTitle("RenderView FreeCamera Test — incredible-gmod.ru")
	frame:OpenAnimation()
	frame:MakePopup()

	anti_duplicate = frame
end)
