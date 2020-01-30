-- Still helpful&useful&comfy, but without stupid as fuck `Unique` ID collisions
-- This solution simply replaces the default pdata features, nothing more.

local PMETA = FindMetaTable("Player")

function PMETA:GetPData( name, default )
	name = Format( "%s[%s]", self:SteamID64(), name)
	local val = sql.QueryValue("SELECT value FROM playerpdata WHERE infoid = " .. SQLStr(name) .. " LIMIT 1")
	if val == nil then return default end

	return val
end

function PMETA:SetPData( name, value )
	name = Format("%s[%s]", self:SteamID64(), name)
	return sql.Query("REPLACE INTO playerpdata ( infoid, value ) VALUES ( " .. SQLStr(name) .. ", " .. SQLStr(value) .. " )") ~= false
end

function PMETA:RemovePData( name )
	name = Format("%s[%s]", self:SteamID64(), name)
	return sql.Query("DELETE FROM playerpdata WHERE infoid = " .. SQLStr(name)) ~= false
end
