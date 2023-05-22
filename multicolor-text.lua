-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/multicolor-text.lua

-- it can render multi-line + multi-color text

function surface.DrawMulticolorText(x, y, font, text, maxW)
	surface.SetTextColor(255, 255, 255)
	surface.SetFont(font)
	surface.SetTextPos(x, y)

	local baseX = x
	local w, h = surface.GetTextSize("W")
	local lineHeight = h

	if maxW and x > 0 then
		maxW = maxW + x
	end

	for _, v in ipairs(text) do
		if isstring(v) then
			w, h = surface.GetTextSize(v)

			if maxW and x + w >= maxW then
				x, y = baseX, y + lineHeight
				v = v:gsub("^%s+", "")
			end

			surface.SetTextPos(x, y)
			surface.DrawText(v)

			x = x + w
		else
			surface.SetTextColor(v.r, v.g, v.b, v.a)
		end
	end

	return x, y
end

render.PushRenderTarget(GetRenderTarget("r*b text 123", 200, ScrH() - 32))
render.Clear(0, 0, 0, 0, true, true)

cam.Start2D()
	surface.DrawMulticolorText(32, 32, "DermaLarge", {
		"Hello",
		Color(255, 0, 0), " world!",
		Color(0, 255, 0), " lorem ipsum",
		Color(0, 0, 255), " dolor sit amet!"
	}, 200)
cam.End2D()

render.PopRenderTarget()

local text = CreateMaterial("r*b text 123", "UnlitGeneric", {
	["$translucent"] = 1,
	["$basetexture"] = "r*b text 123"
})

hook.Add("HUDPaint", "r*b text", function()
	local maxW = 64 + (SysTime() * 250) % 500
	local x, y = surface.DrawMulticolorText(256, 32, "DermaLarge", {
		"Hello",
		Color(255, 0, 0), " world!",
		Color(0, 255, 0), " lorem ipsum",
		Color(0, 0, 255), " dolor sit amet!"
	}, maxW)

	surface.SetDrawColor(255, 255, 255)
	surface.DrawRect(256, 32 + y, maxW, 2)

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(text)
	surface.DrawTexturedRect(0, 0, 200, ScrH() - 32)
end)
