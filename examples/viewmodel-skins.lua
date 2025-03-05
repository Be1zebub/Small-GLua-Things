-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/example/viewmodel_skins.lua
-- example: https://i.imgur.com/V4ZBVxG.png https://i.imgur.com/JXGIlb2.png
-- Usage Example: vmskin_example "models/weapons/c_crowbar.mdl" "models/props_combine/combine_monitorbay_disp"

if SERVER then
	concommand.Add("vmskin_example", function(ply, _, args)
		local model = args[1]
		local material = args[2]

		ply:SetNWString("skin_" .. model, tostring(material))
	end)
else
	hook.Add("Think", "vmskin_example", function()
		local ply = LocalPlayer()
		local viewmodel = ply:GetViewModel()
		local vm_model = viewmodel:GetModel()

		local new_material = ply:GetNWString("skin_" .. vm_model) or ""
		viewmodel:SetMaterial(new_material)
	end)
end
