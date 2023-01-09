-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/cl_stencil_mask.lua
-- thx to stencil tutorial: https://github.com/Lexicality/stencil-tutorial

local function Mask(domask, dodraw, stencilCompareFunction)
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
	domask()

	render.SetStencilFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
	render.SetStencilCompareFunction(stencilCompareFunction)
	render.SetStencilReferenceValue(1)

	dodraw()

	render.SetStencilEnable(false)
	render.ClearStencil()
end

function draw.DrawMask(domask, dodraw)
	Mask(domask, dodraw, STENCILCOMPARISONFUNCTION_EQUAL)
end

function draw.DrawMaskInverted(domask, dodraw)
	Mask(domask, dodraw, STENCILCOMPARISONFUNCTION_NOTEQUAL)
end
