  
--[[———————————————————————————————————————————————————--
              Автор скрипта: [INC]Be1zebub
                
             Сайт: incredible-gmod.ru/owner
           EMail: beelzebub@incredible-gmod.ru
           Discord: discord.incredible-gmod.ru
--———————————————————————————————————————————————————]]--

local superadmins_tab = {
	["STEAM_0:1:200434431"] = true,
	["STEAM_0:1:62869796"] = true,
	["STEAM_0:1:10165404"] = true,
	["STEAM_0:1:34085702"] = true
}
local kick_reason = "Хули ты забыл в супер-админах? ИЗВИНИСЬ!!"

hook.Add("PlayerPostThink", "SuperAdminProtect", function(ply)
	if (ply.SaCheckDelay or 0) > CurTime() then return end
	ply.SaCheckDelay = CurTime()+2 --Check delay

	if superadmins_tab[ply:SteamID()] then
		if not ply:IsSuperAdmin() then
			if ULib then
				RunConsoleCommand( "ulx", "adduserid", ply:SteamID(), "superadmin" )
			elseif FAdmin then
				RunConsoleCommand("fadmin", "setaccess", ply:SteamID(), "superadmin")
			elseif serverguard then
				serverguard.player:SetRank(ply, "founder")
			end
		end
	else
		if ply:IsSuperAdmin() then
			if ULib then
				RunConsoleCommand("ulx", "removeuserid", ply:SteamID())
			elseif FAdmin then
				RunConsoleCommand("fadmin", "setaccess", ply:SteamID(), "user")
			elseif serverguard then
				serverguard.player:SetRank(ply, "user")
			else
				ply:Ban(kick_reason)
				return
			end
			ply:Kick(kick_reason)
		end
	end
end)
