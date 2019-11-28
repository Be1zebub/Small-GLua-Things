--[[—————————————————————————————————————
        Incredible Material Downloader
          Credits: [INC]Be1zebub
          
	 Visit my GModDayz Server:
         http://incredible-gmod.ru
—————————————————————————————————————]]--

function DownloadMaterial(img_url, path)
    if file.Exists(path, "DATA") then
    	return Material("data/"..path, "noclamp smooth")
    else
    	if (LocalPlayer().ImgURL_FetchDelay or 0) > CurTime() then return false end
	LocalPlayer().ImgURL_FetchDelay = CurTime() + 5
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
