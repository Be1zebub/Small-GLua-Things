-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/http-material.lua

--[[ Example:
local httpMaterial = include("lib/http-material.lua")

local gorgeous = httpMaterial("https://github.com/Be1zebub/elite-emotes-collection/blob/main/gorgeous/pleasure.png?raw=true", "smooth mips")
hook.Add("HUDPaint", "incredible-gmod.ru/http-material", function()
	surface.SetDrawColor(255, 255, 255)
	gorgeous:Draw(32, 32, 64, 64)
end)

coroutine.wrap(function()
	local yoba = httpMaterial:Async("https://github.com/Be1zebub/elite-emotes-collection/blob/main/memes/yoba_code.png?raw=true")

	-- coroutine will sleep until material ready

	hook.Add("HUDPaint", "incredible-gmod.ru/http-material 2", function()
		surface.SetDrawColor(255, 255, 255)
		yoba:Draw(32 + 64, 32, 64, 64)
	end)
end)
]]--

file.CreateDir("http-material")

local httpMaterial = {}

function httpMaterial:Init(url, flags, ttl, cback)
	ttl = ttl or 86400

	local fname = url:match("([^/]+)$") -- get content after latest slash
	:gsub("[&?]([^/%s]+)=([^/%s]+)", "") -- strip query

	if fname:match("^.+(%..+)$") == nil then -- if filename have no extension
		fname = fname ..".png"
	end

	local path = "http-material/".. util.CRC(url) .."_".. fname
	self.path = "data/".. path

	if file.Exists(path, "DATA") and file.Time(path, "DATA") + ttl > os.time() then
		self:SetMaterial(
			Material(self.path, flags)
		)
		if cback then cback(self.material) end
	else
		self:Download(url, function(succ, result)
			if succ then
				file.Write(path, result)
				self:SetMaterial(
					Material(self.path, flags)
				)
				if cback then cback(self.material) end
			else
				ErrorNoHalt(string.format("Cant download http-material! Url: %s, reason: %s\nTryin with proxy...\n", url, reason))

				url = "https://proxy.duckduckgo.com/iu/?u=".. url
				self:Download(url, function(succ, result)
					if succ then
						file.Write(path, result)
						self:SetMaterial(
							Material(self.path, flags)
						)
						if cback then cback(self.material) end
					else
						ErrorNoHalt(string.format("Cant download http-material! Url: %s, reason: %s\n", url, reason))
						self:SetMaterial(
							Material("error")
						)
						if cback then cback(self.material) end
					end
				end)
			end
		end)
	end
end

function httpMaterial:SetMaterial(new)
	if self.OnMaterialChange then self:OnMaterialChange(new, self.material) end
	self.material = new
end

function httpMaterial:GetMaterial()
	return self.material
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

function httpMaterial:Draw(x, y, w, h, angle)
	if self.material == nil then return end

	surface.SetMaterial(self.material)
	surface[angle and "DrawTexturedRectRotated" or "DrawTexturedRect"](x, y, w, h, angle)
end

local constructor = {}

function constructor:New(url, flags, ttl, cback)
	local instance = setmetatable({}, {
		__index = httpMaterial,
		__call = httpMaterial.Draw
	})

	instance:Init(url, flags, ttl, cback)

	return instance
end

function constructor:Async(url, flags, ttl)
	local mat = self:New(url, flags, ttl)
	if mat.material then return mat end

	local co = coroutine.running()

	function mat:OnMaterialChange()
		coroutine.resume(co, mat)
	end

	return coroutine.yield()
end

setmetatable(constructor, {
	__call = constructor.New
})

return constructor
