-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/stencil-mask.lua
-- thx to stencil tutorial: https://github.com/Lexicality/stencil-tutorial

-- Simple stencil-mask wrapper
--[[ usage example:
draw.DrawMask(function()
	surface.DrawPoly(GenerateStar(0, 0, 256, 256))
end, function()
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(fooBar)
	surface.DrawTexturedRect(0, 0, 256, 256)
end)
]]--

local function Mask(doMask, doDraw, stencilCompareFunction)
	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_ZERO)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(1)

	draw.NoTexture()
	surface.SetDrawColor(255, 255, 255, 255)
	doMask()

	render.SetStencilFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(stencilCompareFunction)
	render.SetStencilReferenceValue(1)

	doDraw()

	render.SetStencilEnable(false)
	render.ClearStencil()
end

function draw.DrawMask(doMask, doDraw)
	Mask(doMask, doDraw, STENCILCOMPARISONFUNCTION_EQUAL)
end

function draw.DrawMaskInverted(doMask, doDraw)
	Mask(doMask, doDraw, STENCILCOMPARISONFUNCTION_NOTEQUAL)
end
