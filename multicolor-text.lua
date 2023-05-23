-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/multicolor-text.lua

-- it can render multi-line + multi-color text
-- this is a heavy function, you shouldnt call it every frame - use render targets to render text 1 time and copy it to the material
-- learn how to use rendertargets here: https://wiki.facepunch.com/gmod/render.PushRenderTarget
-- preview: https://cdn.discordapp.com/attachments/565108080300261398/1110373812970725377/2023-05-23_08-08-42.mp4

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

			if maxW and x + w > maxW then
				v:gsub("(%s?[%S]+)", function(word)
					w, h = surface.GetTextSize(word)

					if x + w >= maxW then
						x, y = baseX, y + lineHeight
						word = word:gsub("^%s+", "")
						w, h = surface.GetTextSize(word)

						if x + w >= maxW then
							word:gsub("[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*", function(char)
								w, h = surface.GetTextSize(char)

								if x + w >= maxW then
									x, y = baseX, y + lineHeight
								end

								surface.SetTextPos(x, y)
								surface.DrawText(char)

								x = x + w
							end)

							return
						end
					end

					surface.SetTextPos(x, y)
					surface.DrawText(word)

					x = x + w
				end)
			else
				surface.SetTextPos(x, y)
				surface.DrawText(v)

				x = x + w
			end
		else
			surface.SetTextColor(v.r, v.g, v.b, v.a)
		end
	end

	return x, y
end

local x, y = 0, 0

hook.Add("HUDPaint", "r*b text", function()
	local maxW = gui.MouseX() - 256

	surface.SetDrawColor(0, 0, 0, 125)
	surface.DrawRect(256, 32, maxW, y)

	x, y = surface.DrawMulticolorText(256, 32, "DermaLarge", {
		"Hello",
		Color(255, 0, 0), " world!",
		Color(0, 255, 0), " lorem ipsum",
		Color(0, 0, 255), " dolor sit amet!",
		Color(255, 255, 255), " consecteturadipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
	}, maxW)
end)
