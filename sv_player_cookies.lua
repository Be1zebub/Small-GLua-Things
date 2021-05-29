-- incredible-gmod.ru
-- Same as PData, but without stupid as fuck 'Unique' ID collisions & with caching

local PLAYER = FindMetaTable("Player")

local SQLStr, sql, hook, SteamID64, pairs = SQLStr, sql, hook, PLAYER.SteamID64, pairs

local CookieCache = {}

function GetCookies(ply)
	if ply then
		return CookieCache[ply:SteamID64()]
	else
		return CookieCache	
	end
end

function SetCookie(sid, key, value)
	CookieCache[sid][key] = value

	return sql.Query("REPLACE INTO `playercookie` (`SteamID`, `Value`, `Key`) VALUES (".. SQLStr(sid) ..", ".. SQLStr(value) ..", ".. SQLStr(key) ..");") ~= false
end

function GetCookie(sid, key, default)
	if CookieCache[sid][key] then
		return CookieCache[sid][key]
	end

	local val = sql.QueryValue("SELECT `Value` FROM `playercookie` WHERE `SteamID` = ".. SQLStr(sid) .." AND `Key` = ".. SQLStr(key) .." LIMIT 1;")

	return val or default
end

function DeleteCookie(sid, key)
	CookieCache[sid][key] = nil

	return sql.Query("DELETE FROM `playercookie` WHERE `SteamID` = ".. SQLStr(sid) .. " AND `Key` = ".. SQLStr(key) ..";") ~= false
end

function ClearCookie(key)
	for k, v in pairs(CookieCache) do
		CookieCache[k][key] = nil
	end

	return sql.Query("DELETE FROM `playercookie` WHERE `Key` = ".. SQLStr(key) ..";") ~= false
end

function PLAYER:SetCookie(key, value)
	return SetCookie(SteamID64(self), key, value)
end

function PLAYER:GetCookie(key, default)
	return GetCookie(SteamID64(self), key, default)
end

function PLAYER:DeleteCookie(key)
	return DeleteCookie(SteamID64(self), key)
end

hook.Add("PlayerAuthed", "LoadCookies", function(ply)
	local sid = SteamID64(ply)
	CookieCache[sid] = {}

	local data = sql.Query("SELECT * FROM playercookie WHERE SteamID = ".. SQLStr(sid) .." LIMIT 1;")

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
	sql.Query("CREATE TABLE IF NOT EXISTS `playercookie` (`SteamID` TEXT, `Key` TEXT NOT NULL, `Value` TEXT);")
end)
