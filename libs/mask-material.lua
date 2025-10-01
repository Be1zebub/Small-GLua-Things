-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/mask-material.lua

-- https://github.com/melonstuff/melonsmasks based masked material generator
-- Its like Melon-masks, but generates material - when you need to pre-render a thing

--[[ Example:
local laserColor = Color(255, 0, 0, 255)
local smoothLaser = MaskMaterial("smoothLaserBeam55533", 32, 32, "UnlitGeneric", {
	["$additive"] = 1,
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1
})
:DrawMask(function(w, h)
	local maskTextureID = surface.GetTextureID("gui/gradient_down")

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetTexture(maskTextureID)
	surface.DrawTexturedRect(0, 0, w, h)
end)
:DrawDest(function(w, h)
	local laserTextureID = surface.GetTextureID("trails/laser")

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetTexture(laserTextureID)
	surface.DrawTexturedRect(0, 0, w, h)
end)

hook.Add("PreDrawEffects", "smoothLaserMaterialTest", function()
	local ply = LocalPlayer()
	local beamFrom, beamTo

	local vm = ply:GetViewModel()
	local muzzleID = vm:LookupAttachment("muzzle")

	if muzzleID <= 0 then
		beamFrom = EyePos() + ply:GetRight() * 6
		beamTo = ply:GetEyeTrace().HitPos
	else
		beamFrom = vm:GetAttachment(muzzleID).Pos
		beamTo = ply:GetEyeTrace().HitPos
	end

	render.SetMaterial(smoothLaser:GetMaterial())
	render.DrawBeam(beamFrom, beamTo, 3, 0, 1, laserColor)
end)
]]--

local maskedMaterial = {}
local maskTexture, maskMaterial, maskTextureSize

local function renewMask()
	local w, h = ScrW(), ScrH()
	local name = "gmod.one/mask-material/mask/" .. w .. "x" .. h

	maskTexture = GetRenderTarget(name, w, h)
	maskMaterial = CreateMaterial(name, "UnlitGeneric", {
		["$translucent"] = 1,
		["$basetexture"] = maskTexture:GetName()
	})
	maskTextureSize = Vector(w, h)
end

renewMask()
hook.Add("OnScreenSizeChanged", "gmod.one/mask-material/renew-mask", renewMask)

function maskedMaterial:DrawMask(drawMask)
	render.PushRenderTarget(maskTexture)
	render.Clear(0, 0, 0, 0, true, true)
	cam.Start2D()
		drawMask(maskTextureSize.x, maskTextureSize.y)
	cam.End2D()
	render.PopRenderTarget()

	return self
end

function maskedMaterial:DrawDest(drawDest)
	render.PushRenderTarget(self.texture)
	render.Clear(0, 0, 0, 0, true, true)
	cam.Start2D()
		drawDest(self.w, self.h)

		render.OverrideBlend(true, BLEND_ZERO, BLEND_SRC_ALPHA, BLENDFUNC_ADD)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(maskMaterial)
			surface.DrawTexturedRect(0, 0, maskTextureSize.x, maskTextureSize.y)
		render.OverrideBlend(false)
	cam.End2D()
	render.PopRenderTarget()

	return self
end

function maskedMaterial:GetMaterial()
	return self.material
end

function maskedMaterial:Draw(x, y, w, h)
	surface.SetMaterial(self:GetMaterial())
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(x, y, w, h)
end

local function MaskMaterial(name, w, h, shaderName, shaderParams)
	shaderName = shaderName or "UnlitGeneric"
	shaderParams = shaderParams or {
		["$translucent"] = 1
	}

	local textureName = "gmod.one/mask-material/dest/" .. name
	shaderParams["$basetexture"] = textureName

	return setmetatable({
		w = w,
		h = h,
		texture = GetRenderTarget(textureName, w, h),
		material = CreateMaterial(textureName, shaderName, shaderParams)
	}, {
		__index = maskedMaterial
	})
end

return MaskMaterial
