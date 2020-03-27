--[[———————————————————————————————————————————————————--
                Developer: [INC]Be1zebub
                
            Website: incredible-gmod.ru/owner
           EMail: beelzebub@incredible-gmod.ru
           Discord: discord.incredible-gmod.ru
--———————————————————————————————————————————————————]]--


if CLIENT then return end --its server side lib ;) no reason to use it on the client realm

local apikey = "YOUR STEAM API KEY HERE! https://steamcommunity.com/dev/apikey"
local default_avatar = "https://i.imgur.com/T3EE95z.png"

local http_Fetch, util_JSONToTable, IsValid_ = http.Fetch, util.JSONToTable, IsValid
local PMETA = FindMetaTable("Player")
cachedAvatars = cachedAvatars or {}

function GetAvatarBySteam64(steamid)	
	if cachedAvatars[steamid] then
		return cachedAvatars[steamid]
	end

	http_Fetch("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key="..apikey.."&steamids="..steamid, function(body)
		if not body or body == "" then return default_avatar end
		local tbl = util_JSONToTable(body)
		if not tbl or not tbl.response or not tbl.response.players or not tbl.response.players[1] or not tbl.response.players[1].avatarfull then return default_avatar end

		local currentAvatar = tbl.response.players[1].avatarfull

		cachedAvatars[steamid] = currentAvatar
	end)
	
	return default_avatar
end

function PMETA:GetAvatar()
	if not IsValid_(self) then return default_avatar end

	return GetAvatarBySteam64(self:SteamID64())
end
