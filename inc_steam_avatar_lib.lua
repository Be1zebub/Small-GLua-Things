--[[————————————————————————————————————————
     	Get Player Steam Avatar Lib
     	  Credists: [INC]Be1zebub
————————————————————————————————————————]]--

if CLIENT then return end --its server side lib ;)

local CFG = {
	steamapi		= "SUPER_SECRET_STEAM_API_KEY", -- https://steamcommunity.com/dev/apikey
	default_avatar 	= "https://i.imgur.com/T3EE95z.png", -- Default Avatar if API Error
	enable_caching 	= true, -- Required for reduce the number of API requests 						cachedAvatars[SteamID64]
	ent_save 		= true, -- Save avatar url in player entity 								(ply.SteamAvatar)
	pdata_save		= true, -- Save avatar in PData 									self:GetPData("SteamAvatar", "https://i.imgur.com/T3EE95z.png")
	data_save 		= true, -- Save Avatar in garrysmod/data folder						file.Read("steam_avatars/avatar_USER_STEAMID64.txt", "DATA")
}

cachedAvatars = cachedAvatars or {}

local PMETA = FindMetaTable("Player")

function PMETA:GetAvatar()
	if not self:IsValid() then return CFG.default_avatar end

	local steamid = self:SteamID64()

	if cachedAvatars[steamid] then
		return cachedAvatars[steamid]
	elseif self.SteamAvatar then
		return self.SteamAvatar
	elseif self:GetPData("SteamAvatar", false) then
		return self:GetPData("SteamAvatar", false)
	end

	local in_data_avatar = file.Read("steam_avatars/avatar_"..steamid..".txt", "DATA") or false
	if in_data_avatar then
		return in_data_avatar
	end

	local fUrl = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. CFG.steamapi .. "&steamids=" .. steamid
	http.Fetch(fUrl, function(body)
		if not body or body == "" then return end
		local tbl = util.JSONToTable(body)
		if not tbl or not tbl.response then return end

		local currentAvatar = tbl.response.players[1].avatarfull

		if CFG.enable_caching then
			cachedAvatars[steamid] = currentAvatar
		end
		if CFG.ent_save then
			self.SteamAvatar = currentAvatar
		end
		if CFG.pdata_save then
			self:SetPData("SteamAvatar", currentAvatar)
		end

		if CFG.data_save then
			if not file.Exists( "steam_avatars", "DATA" ) then
				file.CreateDir("steam_avatars")
			end
			file.Write("steam_avatars/avatar_"..steamid..".txt", currentAvatar)
		end
	end)

	return cachedAvatars[steamid] or self.SteamAvatar or self:GetPData("SteamAvatar", false) or file.Read("steam_avatars/avatar_"..steamid..".txt", "DATA") or CFG.default_avatar
end

function GetAvatarBySteam64(steam64)
	if cachedAvatars[steam64] then return cachedAvatars[steam64] end
	
	local fUrl = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. CFG.steamapi .. "&steamids=" .. steam64	
	http.Fetch(fUrl, function(body)
		if not body or body == "" then return end
		local tbl = util.JSONToTable(body)
		if not tbl or not tbl.response then return end

		local currentAvatar = tbl.response.players[1].avatarfull

		cachedAvatars[steam64] = currentAvatar

		if CFG.data_save then
			if not file.Exists( "steam_avatars", "DATA" ) then
				file.CreateDir("steam_avatars")
			end
			file.Write("steam_avatars/avatar_"..steamid..".txt", currentAvatar)
		end
	end)

	return cachedAvatars[steam64] or CFG.default_avatar
end

--[[————————————————————————————————————————
     	          Contacts:
       beelzebub@incredible-gmod.ru
          [INC]Beelzebub#0281
--————————————————————————————————————————--
       Visit my GModDayz Server:
   steam://connect/dayz.incredible-gmod.ru
	    & Brawl Server:
   steam://connect/brawl.incredible-gmod.ru
————————————————————————————————————————]]--
