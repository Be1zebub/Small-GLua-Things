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
hook.Add("HUDPaint", "IncredibleImgURLExample", function()
	Mkdir("incredible_materials") -- its custom func *
	local mat = DownloadMaterial("https://incredible-gmod.ru/assets/other/be1zebub_pixelart.png", "incredible_materials/be1ze_pixel.png")
	if not mat then return end
	
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(ScrW()/2-128, ScrH()/2-120.5, 256, 241)
end)
