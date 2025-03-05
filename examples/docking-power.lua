-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/example/docking-power.lua

-- Panel:Dock usage example
-- this script was created as a quick demo of Docking, so more ppl can learn it.
-- docking system is great, without it vgui literally has no right to live - vgui is terrible, but docking saves it a little bit.

if IsValid(_DockingPower) then
	_testDock:Remove()
end

_DockingPower = vgui.Create("DPanel")
_DockingPower:SetSize(512, 512)
_DockingPower:Center()

local function PaintColor(me, w, h)
	surface.SetDrawColor(me.backgroundColor)
	surface.DrawRect(0, 0, w, h)
end

local left = _DockingPower:Add("EditablePanel")
left:SetWide(256 - 16)
left:Dock(LEFT)
left:DockMargin(0, 0, 32, 0)
left.backgroundColor = Color(255, 52, 94)
left.Paint = PaintColor
left.Think = function(me)
	me:SetWide(256 + 64 * math.sin(SysTime() * 2))
end

local top = _DockingPower:Add("EditablePanel")
top:SetTall(256 - 16)
top:Dock(TOP)
top.backgroundColor = Color(52, 255, 94)
top.Paint = PaintColor

local fill = _DockingPower:Add("EditablePanel")
fill:Dock(FILL)
fill:DockMargin(0, 32, 0, 0)
fill.backgroundColor = Color(52, 94, 255)
fill.Paint = PaintColor
