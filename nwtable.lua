-- from incredible-gmod.ru with <3

local NWTable = {
	_VERSION = 2.1,
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
	_G.NWTable = self
end

NWTable.list = {}

setmetatable(NWTable, {__call = function(_, uid)
	uid = uid or util.CRC(debug.traceback())

	if NWTable.list[uid] then
		return NWTable.list[uid]
	end

	local net_uid = "incredible-gmod.ru/nwtable/".. uid

	local instance, mt = {}, {}
	local storage = {}
	local settings = {
		WriteKey = net.WriteType,
		ReadKey = net.ReadType,
		LocalPlayer = false,
		AutoSync = true,
		uid = uid
	}

	function mt:settings()
		return settings
	end

	function mt:storage()
		return storage
	end

	do -- storage manipulation
		function mt:get(k)
			return storage[k]
		end

		function mt:set(k, v)
			storage[k] = v

			if settings.Write then
				net.Start(net_uid)
					net.WriteUInt(v == nil and 0 or 1, 2)
					settings.WriteKey.write(k, settings.WriteKey.opts)
					if v then settings.Write.write(v, settings.Write.opts) end
				if SERVER then
					if settings.LocalPlayer then
						net.Send(k)
					else
						local filter = settings.BoradcastFilter and settings.BoradcastFilter(k)
						if filter then
							net.Send(filter)
						else
							net.Broadcast()
						end
					end
				else
					net.SendToServer()
				end
			end

			return self
		end

		function mt:delete(k)
			self:set(k, nil)
			return self
		end

		function mt:clean(ply)
			net.Start(net_uid)
				net.WriteUInt(2, 2)
			if SERVER then
				if ply then
					net.Send(ply)
				else
					net.Broadcast()
				end
			else
				net.SendToServer()
			end

			return self
		end

		if SERVER then
			function mt:sync(ply)
				net.Start(net_uid)
					net.WriteUInt(3, 2)
					net.WriteTable(storage)

				if ply then
					net.Send(ply)
				else
					net.Broadcast()
				end

				return self
			end
		end
	end

	do -- meta events
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
			return rawget(mt, k) or self:get(k)
		end

		function mt:__newindex(k, v)
			self:set(k, v)
		end
	end

	do -- configuration
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

		function mt:Validate(REALM, func)
			if isfunction(REALM) then
				cback = REALM
			elseif REALM == false then
				return self
			end

			settings.Validate = func

			return self
		end

		function mt:Hook(REALM, cback)
			if isfunction(REALM) then
				cback = REALM
			elseif REALM == false then
				return self
			end

			settings.Hook = cback

			return self
		end

		function mt:WriteKey(REALM, write, opts)
			if isfunction(REALM) then
				write, opts = REALM, write
			elseif REALM == false then
				return self
			end

			settings.WriteKey = {
				write = write,
				opts = opts
			}

			return self
		end

		function mt:ReadKey(REALM, read, opts)
			if isfunction(REALM) then
				read, opts = REALM, read
			elseif REALM == false then
				return self
			end

			if REALM == false then return self end

			settings.ReadKey = {
				read = read,
				opts = opts
			}

			return self
		end

		function mt:Write(REALM, write, opts)
			if isfunction(REALM) then
				write, opts = REALM, write
			end

			if REALM == false then return self end

			settings.Write = {
				write = write,
				opts = opts
			}

			return self
		end

		function mt:Read(REALM, read, opts, autosync)
			if isfunction(REALM) then
				read, opts, autosync = REALM, read, opts
			end

			if REALM == false then return self end

			settings.Read = {
				read = read,
				opts = opts
			}

			local cooldown = {}
			local key, value, type

			net.Receive(net_uid, function(_, ply)
				if SERVER and settings.Cooldown then
					if (cooldown[ply] or 0) > CurTime() then return end
					cooldown[ply] = CurTime() + settings.Cooldown
				end

				type = net.ReadUInt(2)
				if type == 2 then -- clean
					storage = {}
					return
				elseif type == 3 then -- sync
					storage = net.ReadTable()
					return
				end

				key = settings.ReadKey.read(settings.ReadKey.opts)

				if type == 0 then -- delete
					value = nil
				elseif type == 1 then -- set
					value = settings.Read.read(settings.Read.opts)
					if (SERVER and settings.Validate and settings.Validate(ply, key, value)) or (CLIENT and settings.Validate and settings.Validate(key, value)) then return end
				end

				local new

				if settings.Hook and SERVER then
					new = settings.Hook(ply, key, value)
				elseif settings.Hook and CLIENT then
					new = settings.Hook(key, value)
				end

				if new ~= nil then
					value = new
				end

				if autosync and SERVER then
					self:set(key, value)
				else
					storage[key] = value
				end
			end)

			return self
		end

		function mt:NoSync()
			settings.AutoSync = false
			return self
		end
	end

	if SERVER then
		util.AddNetworkString(net_uid)
	end

	NWTable.list[uid] = instance
	return setmetatable(instance, mt)
end})

if SERVER then
	hook.Add("PlayerInitialSpawn", "incredible-gmod.ru/nwtable", function(ply)
		hook.Add("SetupMove", ply, function(self, pl, _, cmd)
			if self == pl and not cmd:IsForced() then
				hook.Remove("SetupMove", self)

				for _, nwtable in pairs(NWTable.list) do
					nwtable:sync(self)
				end
			end
		end)
	end)
end

return NWTable

--[[ Examples:
local money = NWTable("Money")
:Write(SERVER, net.WriteUInt, 32)
:Read(CLIENT, net.ReadUInt, 32)
:WriteKey(SERVER, net.WriteEntity)
:ReadKey(CLIENT, net.ReadEntity)
:LocalPlayer()
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
:Write(net.WriteString) -- write value (shared)
:Read(net.ReadString, true) -- read value (shared), autosync to all players when server receive value from client
:Cooldown(5) -- with 5 seconds cooldown for clients
:WriteKey(net.WriteUInt, 3)
:ReadKey(net.ReadUInt, 3)
:Validate(function(ply, index, value)
	return ply:IsMayor() and index > 0 and index < 8 and value:len() <= 512
end)

function GetLaw(index)
	return laws[index]
end

function GetLaws()
	return laws
end

if CLIENT then
	laws[1] = "Dont be an asshole" -- update in local storage, send to server storage with 5 seconds cooldown, server will autosync it to all players
end
]]--
