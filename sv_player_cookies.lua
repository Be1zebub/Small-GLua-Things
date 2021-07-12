-- incredible-gmod.ru
-- Same as PData, but without stupid as fuck 'Unique' ID collisions & with caching
-- also its optimizated & have non-meta functions that allow you to change data of offline players.
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/sv_player_cookies.lua

if GetCookies then return end

local PLAYER = FindMetaTable("Player")

local SQLStr, sql, hook, SteamID64, pairs, sql_QueryValue, sql_Query, string_find = SQLStr, sql, hook, PLAYER.SteamID64, pairs, sql.QueryValue, sql.Query, string.find

local CookieCache = {}

function GetCookies(ply)
	if ply then
		return CookieCache[SteamID64(ply)]
	else
		return CookieCache	
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

function PLAYER:SetCookie(key, value)
	return SetCookie(SteamID64(self), key, value)
end

function PLAYER:GetCookie(key, default)
	return GetCookie(SteamID64(self), key, default)
end

function PLAYER:DeleteCookie(key)
	return DeleteCookie(SteamID64(self), key)
end

function PLAYER:FindCookie(cback, needle, startPos, noPatterns)
	FindCookie(SteamID64(self), cback, needle, startPos, noPatterns)
end

hook.Add("PlayerAuthed", "LoadCookies", function(ply)
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
