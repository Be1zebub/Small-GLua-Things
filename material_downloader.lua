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
        http.Fetch(img_url, function(result)
            if (result) then
                file.Write(path, result)
            end
        end)
    end
end
