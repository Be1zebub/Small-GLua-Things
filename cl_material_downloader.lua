--[[———————————————————————————————————————————————————--
              Автор скрипта: [INC]Be1zebub
                
             Сайт: incredible-gmod.ru/owner
           EMail: beelzebub@incredible-gmod.ru
           Discord: discord.incredible-gmod.ru
--———————————————————————————————————————————————————]]--
local ImgURL_FetchDelay = 0
function DownloadMaterial(img_url, path)
    if file.Exists(path, "DATA") then
    	return Material("data/"..path, "noclamp smooth")
    else
    	if ImgURL_FetchDelay > CurTime() then return false end
	ImgURL_FetchDelay = CurTime() + 5
        http.Fetch(img_url, function(result)
            if (result) then
                file.Write(path, result)
            end
        end)
        return false
    end
end



--———> Usage Exapmle:
local img_size = {256, 241}
hook.Add("HUDPaint", "IncredibleImgURLExample", function()
	Mkdir("incredible_materials") -- its a custom func*
	local mat = DownloadMaterial("https://incredible-gmod.ru/assets/other/be1zebub_pixelart.png", "incredible_materials/be1ze_pixel.png")
	if not mat then return end
		
	surface.SetDrawColor(color_white)
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(ScrW()/2 - img_size[1]/2, ScrH()/2 - img_size[2]/2, img_size[1], img_size[2])
end)
