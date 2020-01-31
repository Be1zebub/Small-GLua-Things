--[[——————————————————————————————————————————————--
	     Developer: [INC]Be1zebub

	 Website: incredible-gmod.ru/owner
	EMail: beelzebub@incredible-gmod.ru
	Discord: discord.incredible-gmod.ru
--——————————————————————————————————————————————]]--

local phpurl = "Your self hosted .php api interface, .php script from - https://github.com/Be1zebub/Small-GLua-Things/blob/master/inc_discord_post.php" --Link to your .php
local RoflanChelik = "https://i.imgur.com/T3EE95z.png" --Default Avatar (if SteamAPI grants ERROR)

function doWebhookPost(txt, nick, webhook, avatar)
	local nickname = nick or "Roflan Nickname"
	local postAvatar = avatar or RoflanChelik -- Require my Steam Avatar Library https://github.com/Be1zebub/Small-GLua-Things/blob/master/inc_steam_avatar_lib.lua

	http.Post( phpurl, { content = txt, username = nickname, url = webhook, avatar_url = postAvatar })
end

-- Usage expample:
hook.Add("DoPlayerDeath", "IncrdibleLogs_KillDeath", function(ply)
	local txt4post = "\n> Victim: " .. ply:Nick() .. "   (||" .. ply:SteamID() .. "||)" .. "\n> Death Reason: " .. tostring(ply.DeathMsg or "???")
	local nickname = "Death: " .. ply:Nick()
    
	doWebhookPost(txt4post, nickname, "https://discordapp.com/api/webhooks/channelid/webhookid", ply.DsPostAvatar)
end)

--required: https://github.com/Be1zebub/Small-GLua-Things/blob/master/inc_discord_post.php
