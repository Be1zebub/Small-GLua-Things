-- Shared CSGO Skins
-- (Данный скрипт не готовое решение а пример реализации так называемых скинов — как в CSGO)
-- https://i.imgur.com/V4ZBVxG.png

if SERVER then
	concommand.Add("CsGoSkinsTest", function(ply, _, args)
		local model = args[1]
		local material = args[2]

		ply:SetNWString("skin_"..tostring(model), tostring(material))
	end)
  -- Usage Example: CsGoSkinsTest "models/weapons/c_357.mdl" "models/XQM/BoxFull_diffuse"
else
	hook.Add("Think", "SkinsLikeCSGO", function()
		local ply = LocalPlayer()
		local viewmodel = ply:GetViewModel()
		local vm_model = viewmodel:GetModel()
		
		local new_material = ply:GetNWString("skin_"..vm_model) or ""
		viewmodel:SetMaterial( tostring(new_material) )
	end)
end
