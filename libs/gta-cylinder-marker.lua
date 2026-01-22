-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/gta-cylinder-marker.lua

-- generate & render hollow cylinder mesh
-- it looks like GTA marker

local function generateHollowCylinder(step, radius, height)
    local verts = {}

    local function tri(a, b, c)
        verts[#verts + 1] = a
        verts[#verts + 1] = b
        verts[#verts + 1] = c
    end

    for i = 0, 360 - step, step do
        local a1 = math.rad(i)
        local a2 = math.rad(i + step)

        local x1, y1 = math.cos(a1) * radius, math.sin(a1) * radius
        local x2, y2 = math.cos(a2) * radius, math.sin(a2) * radius

        local v1 = Vector(x1, y1, 0)
        local v2 = Vector(x2, y2, 0)
        local v3 = Vector(x1, y1, height)
        local v4 = Vector(x2, y2, height)

        -- нормали наружу
        local n1 = Vector(x1, y1, 0):GetNormalized()
        local n2 = Vector(x2, y2, 0):GetNormalized()
        local minV = 0
        local maxV = 0.99

        tri(
            { pos = v1, normal = n1, u = 0, v = minV },
            { pos = v2, normal = n2, u = 1, v = minV },
            { pos = v3, normal = n1, u = 0, v = 1 }
        )
        tri(
            { pos = v3, normal = n1, u = 0, v = maxV },
            { pos = v2, normal = n2, u = 1, v = minV },
            { pos = v4, normal = n2, u = 1, v = maxV }
        )
    end

    local obj = Mesh()
    obj:BuildFromTriangles(verts)
    return obj
end

local cylynder = {
    material = CreateMaterial("Orgs.CapturePointRadius", "UnlitGeneric", {
        ["$basetexture"] = "gui/gradient_down",
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1,
        ["$nocull"] = 1,
        ["$additive"] = 1,
        ["$translucent"] = 1
    }),
    mesh = generateHollowCylinder(orgsConfig.meshStep, math.sqrt(orgsConfig.captureDistance), orgsConfig.meshHeight)
}
cylynder.material:SetVector("$color", orgsConfig.meshColor:ToVector())
cylynder.material:SetFloat("$alpha", orgsConfig.meshAlpha / 255)

function ENT:DrawMesh()
    local matrix = Matrix()
    matrix:Translate(self:GetPos())

    cam.PushModelMatrix(matrix, true)
        render.SetMaterial(cylynder.material)
        cylynder.mesh:Draw()
    cam.PopModelMatrix()
end
