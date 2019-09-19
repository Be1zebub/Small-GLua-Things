-- Shared CSGO Skins
-- (Данный скрипт - это не готовое решение, а пример реализации так называемых скинов — как в CSGO)
-- Примеры: https://i.imgur.com/V4ZBVxG.png https://i.imgur.com/JXGIlb2.png

if SERVER then
	concommand.Add("csgoskin_example", function(ply, _, args)
		local model = args[1]
		local material = args[2]

		ply:SetNWString("skin_"..tostring(model), tostring(material))
	end)
  -- Usage Example: csgoskin_example "models/weapons/c_357.mdl" "models/XQM/BoxFull_diffuse"
else
	hook.Add("Think", "SkinsLikeCSGO", function()
		local ply = LocalPlayer()
		local viewmodel = ply:GetViewModel()
		local vm_model = viewmodel:GetModel()
		
		local new_material = ply:GetNWString("skin_"..vm_model) or ""
		viewmodel:SetMaterial( tostring(new_material) )
	end)
end
