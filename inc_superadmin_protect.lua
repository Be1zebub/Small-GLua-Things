--[[————————————————————————————————————————
      Super-Admin Protector for GMod
————————————————————————————————————————]]--

local superadmins_tab = {
	"STEAM_0:1:200434431",
	"STEAM_0:1:62869796",
	"STEAM_0:1:10165404",
	"STEAM_0:1:34085702"
}

hook.Add("PlayerPostThink", "SuperAdminProtect", function(ply)
  if (ply.SaCheckDelay or 0) > CurTime() then return end

	if table.HasValue( superadmins_tab, ply:SteamID() ) then
		if not ply:IsAdmin() then
			RunConsoleCommand( "ulx", "adduserid", ply:SteamID(), "superadmin" )
		end
	else
		if ply:IsSuperAdmin() then
			RunConsoleCommand( "ulx", "removeuserid", ply:SteamID() )
			ply:Kick( "Хули ты забыл в супер-админах? ИЗВИНИСЬ!!" )
		end
	end
  
  ply.SaCheckDelay = CurTime()+2 --Check delay
end)
