-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/blur_sex.lua

local boxSize = 24

local blur_box = {}
local function CreateBlurBox(x, y, w, h)
	render.CapturePixels()
	blur_box = {}

	for _x = 1, w, boxSize do
		for _y = 1, h, boxSize do
			local color = {r = 0, g = 0, b = 0}

			local len = 0
			for x2 = 0, boxSize, 2 do
				for y2 = 0, boxSize, 2 do
					local r, g, b = render.ReadPixel(x + _x + x2, y + _y + y2)
					color.r = color.r + r
					color.g = color.g + g
					color.b = color.b + b

					len = len + 1
				end
			end

			color.r = color.r / len
			color.g = color.g / len
			color.b = color.b / len

			blur_box[#blur_box + 1] = {
				x = x + _x,
				y = y + _y,
				col = color
			}
		end
	end
end

local everyFrames = 5
local nextRerender = 0

local function MakeIt()
	if nextRerender > FrameNumber() then return end
	nextRerender = FrameNumber() + everyFrames

	local ply = LocalPlayer()
	local peXXis = ply:LookupBone("ValveBiped.Bip01_Pelvis")
	local peXXis_pos = ply:GetBonePosition(peXXis):ToScreen()

	CreateBlurBox(peXXis_pos.x - boxSize * 4, peXXis_pos.y - boxSize * 4, boxSize * 8, boxSize * 8)
end

hook.Add("HUDPaint", "BlurSex", function()
	MakeIt()

	for i, box in ipairs(blur_box) do
		surface.SetDrawColor(box.col.r, box.col.g, box.col.b)
		surface.DrawRect(box.x, box.y, boxSize, boxSize)
	end
end)
