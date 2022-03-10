local NWTable = {
	_VERSION = 1.0,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/nwtable.lua",
	_LICENSE = [[
		MIT LICENSE
		Copyright (c) 2022 incredible-gmod.ru
		Permission is hereby granted, free of charge, to any person obtaining a
		copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:
		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
		OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]]
}

function NWTable:SetGlobal()
	_G.NWTable = getmetatable(self).__call
end

local write, key, value, new
setmetatable(NWTable, {__call = function(_, uid)
	uid = uid or util.CRC(debug.traceback())
	local net_uid = "incredible-gmod.ru/nwtable/".. uid

	local storage = {}
	local settings = {
		WriteKey = net.WriteType,
		ReadKey = net.ReadType,
		uid = uid
	}
	local instance = {}
	local mt = {}

	function mt:__len()
		return #storage
	end

	function mt:__pairs()
		return pairs(storage)
	end

	function mt:__ipairs()
		return ipairs(storage)
	end

	function mt:__index(k)
		return rawget(mt, k) or storage[k]
	end

	function mt:__newindex(k, v)
		storage[k] = v

		if settings.Write then
			net.Start(net_uid)
				settings.WriteKey.write(k, settings.WriteKey.opts)
				settings.Write.write(v, settings.Write.opts)
			if SERVER then
				((settings.LocalPlayer and net.Send) or (settings.Filter and settings.BoradcastFilter()) or net.Broadcast)(k)
			else
				net.SendToServer()
			end
		end
	end

	function mt:GetSettings()
		return settings
	end

	function mt:BoradcastFilter(fn)
		settings.BoradcastFilter = fn
		return self
	end

	function mt:LocalPlayer()
		settings.LocalPlayer = true
		return self
	end

	function mt:Cooldown(cd)
		settings.Cooldown = cd
		return self
	end

	function mt:Validate(func, REALM)
		if REALM == false then return self end
		settings.Validate = func

		return self
	end

	function mt:Hook(cback, REALM)
		if REALM == false then return self end
		settings.Hook = cback

		return self
	end

	function mt:WriteKey(write, opts, REALM)
		if REALM == false then return self end
		settings.WriteKey = {
			write = write,
			opts = opts
		}

		return self
	end

	function mt:ReadKey(read, opts, REALM)
		if REALM == false then return self end
		settings.ReadKey = {
			read = read,
			opts = opts
		}

		return self
	end

	function mt:Write(write, opts, REALM)
		if REALM == false then return self end
		settings.Write = {
			write = write,
			opts = opts
		}

		return self
	end

	function mt:Read(read, opts, REALM)
		if REALM == false then return self end
		settings.Read = {
			read = read,
			opts = opts
		}

		local cooldown = {}
		net.Receive(net_uid, function(len, ply)
			if SERVER and settings.Cooldown then
				if (cooldown[ply] or 0) > CurTime() then return end
				cooldown[ply] = CurTime() + settings.Cooldown
			end

			key = settings.ReadKey.read(settings.ReadKey.opts)
			value = settings.Read.read(settings.Read.opts)

			if (SERVER and settings.Validate and settings.Validate(ply, key, value)) or (CLIENT and settings.Validate and settings.Validate(key, value)) then return end

			if settings.Hook and SERVER then
				new = settings.Hook(ply, key, value)
			elseif settings.Hook and CLIENT then
				new = settings.Hook(key, value)
			end

			if new ~= nil then
				value = new
			end

			storage[key] = value
		end)

		return self
	end

	if SERVER then
		util.AddNetworkString(net_uid)
	end

	return setmetatable(instance, mt)
end})

return NWTable

--[[ Examples:
local money = NWTable("Money")
:Write(net.WriteUInt, 32, SERVER)
:Read(net.ReadUInt, 32, CLIENT)
:WriteKey(net.WriteEntity)
:ReadKey(net.ReadEntity)

function PLAYER:GetMoney()
	return money[self] or 0
end

if SERVER then
	function PLAYER:SetMoney(amnt)
		money[self] = amnt
	end
end

------------------

local laws = NWTable("Laws")
:Write(net.WriteString, nil, CLIENT)
:Read(net.ReadString, nil, SERVER)
:WriteKey(net.WriteUInt, 3)
:ReadKey(net.ReadUInt, 3)
:Validate(function(ply, index, value)
	return ply:IsMayor() and index > 0 and index < 8 and value:len() <= 512
end)
:Cooldown(5)

function GetLaw(index)
	return laws[index]
end

function GetLaws()
	return laws
end

if CLIENT then
	local cooldown = 0
	function UpdateLaw(index, law_phrase)
		if LocalPlayer():IsMayor() == false or index < 1 or index > 7 or law_phrase:len() > 512 then return false end

		if cooldown > CurTime() then return false end
		cooldown = CurTime() + 5

		laws[index] = law_phrase
		return true
	end
end
]]--
