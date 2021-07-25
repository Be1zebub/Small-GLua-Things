-- incredible-gmod.ru
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/sh_material_downloader.lua

local file, Material, Fetch, find = file, Material, http.Fetch, string.find

local errorMat = Material("error")
local WebImageCache = {}
function http.DownloadMaterial(url, path, callback, retry_count)
    if WebImageCache[url] then return callback(WebImageCache[url]) end

    local data_path = "data/".. path
    if file.Exists(path, "DATA") then
        WebImageCache[url] = Material(data_path, "smooth mips")
        callback(WebImageCache[url])
    else
        Fetch(url, function(img)
            if img == nil or find(img, "<!DOCTYPE HTML>", 1, true) then return callback(errorMat) end
            
            file.Write(path, img)
            WebImageCache[url] = Material(data_path, "smooth mips")
            callback(WebImageCache[url])
        end, function()
            if retry_count and retry_count > 0 then
                retry_count = retry_count - 1
                http.DownloadMaterial(url, path, callback, retry_count)
            else
                callback(errorMat)
            end
        end)
    end
end
--[[ Example:
http.DownloadMaterial("https://i.imgur.com/Msmeqkq.png", "beelze_pixel.png", function(example)
    local w, h = 128, 128

    hook.Add("HUDPaint", "http.DownloadMaterial", function()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(example)
        surface.DrawTexturedRect(ScrW() * 0.5 - w * 0.5, ScrH() * 0.5 - h * 0.5, w, h)
    end)
end)
]]--
