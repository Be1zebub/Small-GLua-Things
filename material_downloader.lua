--[[—————————————————————————————————————
        Incredible Material Downloader
          Credits: [INC]Be1zebub
          
	        Visit my GModDayz Server:
         http://incredible-gmod.ru/
—————————————————————————————————————]]--

function DownloadMaterial(img_url, path)
    if not file.Exists(path, "DATA") then
        http.Fetch(img_url, function(result)
            if (result) then
                file.Write(path, result)
            end
        end)
    end
end
