-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/anti_steamid_spoof.lua

-- found exploit that allows to spoof a steamid
-- there is a way to steal a users token and use it to access any gmod servers under the steam ID of another user.
-- for example - with this exploit, an hacker can steal in-game valuables from other peoples accounts

-- This code fixes this problem, so I strongly recommend installing it on your server.
-- if you don't know how to install, just download this file in garrysmod/lua/autorun/server

-- thx to WayZer#0084 for the fix
-- more details about this exploit can be found in https:/discord.incredible-gmod.ru (#helpful channel)

hook.Add("PlayerInitialSpawn", "AntiSteamIDSpoof", function(ply)
    if game.SinglePlayer() then return end

    timer.Simple(0, function()
        if IsValid(ply) == false or ply:IsBot() or ply:IsListenServerHost() or ply.IsFullyAuthenticated == nil or ply:IsFullyAuthenticated() then return end

        ply:Kick("Your SteamID wasn't fully authenticated, try restarting steam.")
    end)
end)
