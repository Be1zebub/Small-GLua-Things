-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/cookies-example.lua

-- Same as PData, but without stupid as fuck 'Unique' ID collisions & with caching
-- also its optimizated & have non-meta functions that allow you to change data of offline players.
-- Also, since September 9 2021, lib has a networking functionality. you dont need netvars for simple things anymore.

-- usage example: https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/cookies-example.lua

-- non-global version: https://github.com/Be1zebub/Small-GLua-Things/blob/master/cookies.lua (does not create global and meta functions, returns lib functions in table)

if GetCookies then return end

local PLAYER, ENTITY = FindMetaTable("Player"), FindMetaTable("Entity")
local SteamID64 = PLAYER.SteamID64

local CookieCache = {}

function GetCookies(ply)
	if ply then
		return CookieCache[SteamID64(ply)] or {}
	else
		return CookieCache
	end
end

if SERVER then
	util.AddNetworkString("gmod.one/cookie_lib")

	local SQLStr, sql, hook, pairs, sql_QueryValue, sql_Query, string_find, EntIndex = SQLStr, sql, hook, pairs, sql.QueryValue, sql.Query, string.find, ENTITY.EntIndex
	local net_Start, net_WriteString, net_WriteType, net_WriteBool, net_WriteUInt, net_Send, net_Broadcast = net.Start, net.WriteString, net.WriteType, net.WriteBool, net.WriteUInt, net.Send, net.Broadcast
	local empty_func = function(a) return a end

	local function NWCookie(ply, key, val, global)
		net_Start("gmod.one/cookie_lib")
			net_WriteString(key)
			net_WriteType(val)
		if global then
			net_WriteBool(true)
			net_WriteUInt(EntIndex(ply), 7)
			net_Broadcast()
		else
			net_Send(ply)
		end
	end

	function SetCookie(sid, key, value)
		CookieCache[sid][key] = value

		return sql_Query("REPLACE INTO `playercookie` (`SteamID`, `Value`, `Key`) VALUES (".. SQLStr(sid) ..", ".. SQLStr(value) ..", ".. SQLStr(key) ..");") ~= false
	end

	local temp
	function GetCookie(sid, key, default)
		temp = CookieCache[sid][key]
		if temp then
			return temp
		end

		temp = sql_QueryValue("SELECT `Value` FROM `playercookie` WHERE `SteamID` = ".. SQLStr(sid) .." AND `Key` = ".. SQLStr(key) .." LIMIT 1;")

		return temp or default
	end

	function DeleteCookie(sid, key)
		CookieCache[sid][key] = nil

		return sql_Query("DELETE FROM `playercookie` WHERE `SteamID` = ".. SQLStr(sid) .. " AND `Key` = ".. SQLStr(key) ..";") ~= false
	end

	function ClearCookie(key)
		for k, v in pairs(CookieCache) do
			CookieCache[k][key] = nil
		end

		return sql_Query("DELETE FROM `playercookie` WHERE `Key` = ".. SQLStr(key) ..";") ~= false
	end

	function FindCookie(sid, cback, needle, startPos, noPatterns)
		if CookieCache[sid] == nil then return end

		for key, val in pairs(CookieCache[sid]) do
			if string_find(key, needle, startPos, noPatterns) then
				cback(key, val)
			end
		end
	end

	local SetCookie, GetCookie, DeleteCookie = SetCookie, GetCookie, DeleteCookie

	function PLAYER:SetCookie(key, value, nw, global)
		if nw then
			NWCookie(self, key, value, global)
		end

		return SetCookie(SteamID64(self), key, value)
	end

	function PLAYER:GetCookie(key, default)
		return GetCookie(SteamID64(self), key, default)
	end

	function PLAYER:DeleteCookie(key, nw, global)
		if nw then
			NWCookie(self, key, nil)
		end
		return DeleteCookie(SteamID64(self), key)
	end

	function PLAYER:NWCookie(key, default, global, totype)
		totype = totype or empty_func
		NWCookie(self, key, totype(self:GetCookie(key, default)), global)
	end

	function PLAYER:FindCookie(cback, needle, startPos, noPatterns)
		FindCookie(SteamID64(self), cback, needle, startPos, noPatterns)
	end

	hook.Add("PlayerInitialSpawn", "LoadCookies", function(ply)
		local sid = SteamID64(ply)
		CookieCache[sid] = {}

		local data = sql_Query("SELECT * FROM `playercookie` WHERE `SteamID` = ".. SQLStr(sid) ..";")

		if not data then
			return hook.Run("CookiesLoaded", ply)
		end

		local cache = CookieCache[sid]
		for k, v in pairs(data) do
			cache[v.Key] = v.Value
		end

		hook.Run("CookiesLoaded", ply)
	end)

	hook.Add("InitPostEntity", "CreateCookiesTable", function()
		sql_Query("CREATE TABLE IF NOT EXISTS `playercookie` (`SteamID` TEXT, `Key` TEXT NOT NULL, `Value` TEXT);")
	end)
else
	local net_ReadString, net_ReadType, net_ReadBool, net_ReadUInt, LocalPlayer, IsValid, Entity = net.ReadString, net.ReadType, net.ReadBool, net.ReadUInt, LocalPlayer, IsValid, Entity

	local localSID, localPlayer

	local k, v, ply, sid
	net.Receive("gmod.one/cookie_lib", function()
		k, v = net_ReadString(), net_ReadType()

		if net_ReadBool() then
			ply = Entity(net_ReadUInt(7))
			if IsValid(ply) == false then return end
			sid = SteamID64(ply)

			CookieCache[sid] = CookieCache[sid] or {}
			CookieCache[sid][k] = v
		else
			if localSID == nil then
				localPlayer = LocalPlayer()
				localSID = SteamID64(localPlayer)
			end

			CookieCache[localSID] = CookieCache[localSID] or {}
			CookieCache[localSID][k] = v
		end
	end)

	function GetCookie(ply, key, default)
		return GetCookies(ply or localPlayer)[key] or default
	end

	function PLAYER:GetCookie(key, default)
		return GetCookie(self, key, default)
	end
end
