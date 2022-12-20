-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/http-material.lua

--[[ Example:
local httpMaterial = include("lib/http-material.lua")
local gorgeous = httpMaterial("https://github.com/Be1zebub/elite-emotes-collection/blob/main/gorgeous/pleasure.png?raw=true", "smooth mips")
hook.Add("HUDPaint", "incredible-gmod.ru/http-material", function()
	surface.SetDrawColor(255, 255, 255)
	gorgeous:Draw(32, 32, 64, 64)
end)
]]--

file.CreateDir("http-material")

local httpMaterial = {}
httpMaterial.__index = httpMaterial

function httpMaterial:Init(url, flags, ttl, cback)
	ttl = ttl or 86400

	local fname = url:match("([^/]+)$"):gsub("[&?]([^/%s]+)=([^/%s]+)", "")
	if fname:match("^.+(%..+)$") == nil then
		fname = fname ..".png"
	end

	local uid = util.CRC(url)  .."_".. fname
	local path = "http-material/".. uid

	if file.Exists(path, "DATA") and file.Time(path, "DATA") + ttl > os.time() then
		self.material = Material("data/".. path, flags)
	else
		self:Download(url, function(succ, result)
			if succ then
				file.Write(path, result)
				self.material = Material("data/".. path, flags)
				if cback then cback(self.material) end
			else
				ErrorNoHalt(string.format("Cant download http-material! Url: %s, reason: %s\n", url, reason))

				url = "https://proxy.duckduckgo.com/iu/?u=".. url
				self:Download(url, function(succ, result)
					if succ then
						file.Write(path, result)
						self.material = Material("data/".. path, flags)
						if cback then cback(self.material) end
					else
						ErrorNoHalt(string.format("Cant download http-material! Url: %s, reason: %s\n", url, reason))
						self.material = Material("error")
						if cback then cback(self.material) end
					end
				end)
			end
		end)
	end
end

function httpMaterial:Download(url, cback, retry)
	retry = retry or 3

	if engine.TickCount() == 0 then -- Valve http doesnt works before 1st tick
		hook.Add("Tick", "httpMaterial".. url, function()
			hook.Remove("Tick", "httpMaterial".. url)
			self:Download(url, cback, retry)
		end)
		return
	end

	http.Fetch(url, function(raw, _, _, code)
		if not raw or raw == "" or code ~= 200 or raw:find("<!DOCTYPE HTML>", 1, true) then
			if retry - 1 <= 0 then return cback(false, "retry") end
			self:Download(url, cback, retry - 1)
			return
		end

		cback(true, raw)
	end, function(err)
		if retry - 1 <= 0 then return cback(false, err) end
		self:Download(url, cback, retry - 1)
	end)
end

function httpMaterial:GetMaterial()
	return self.material
end

function httpMaterial:Draw(x, y, w, h)
	if self.material == nil then return end

	surface.SetMaterial(self.material)
	surface.DrawTexturedRect(x, y, w, h)
end

setmetatable(httpMaterial, {
	__call = httpMaterial.Draw
})

local function new(url, flags, ttl, cback)
	local instance = setmetatable({}, httpMaterial)
	instance:Init(url, flags, ttl, cback)
	return instance
end

--[[ test:
local gorgeous = new("https://github.com/Be1zebub/elite-emotes-collection/blob/main/gorgeous/pleasure.png?raw=true", "smooth mips")
hook.Add("HUDPaint", "incredible-gmod.ru/http-material", function()
	surface.SetDrawColor(255, 255, 255)
	gorgeous:Draw(32, 32, 64, 64)
end)
]]--

return new
