-- from incredible-gmod.ru with <3'
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/servertime.lua

-- ServerTime() - get server os.time on clientside

if SERVER then
	local load_queue = {}

	hook.Add("PlayerInitialSpawn", "incredible-gmod.ru/ServerTime", function(ply)
		load_queue[ply] = true
	end)

	hook.Add("SetupMove", "incredible-gmod.ru/ServerTime", function(ply, _, cmd)
		if load_queue[ply] and not cmd:IsForced() then
			load_queue[ply] = nil

			net.Start("incredible-gmod.ru/ServerTime")
				net.WriteUInt(os.time() - CurTime(), 32)
			net.Send(ply)
		end
	end)

	util.AddNetworkString("incredible-gmod.ru/ServerTime")
else
	local start = 0

	function ServerTime()
		return start + CurTime()
	end

	net.Receive("incredible-gmod.ru/ServerTime", function()
		start = net.ReadUInt(32)
	end)
end
