-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/server-time.lua

-- synced shared unix time getter with ms precision (serverside timezone)
-- this required for stability between restarts (eg saving entity cooldown dt between restarts)

ServerTimeOffset = ServerTimeOffset or 0
local offset = ServerTimeOffset

function ServerTime()
	return offset + CurTime()
end

if SERVER then
	ServerTimeOffset = os.time() - CurTime()
	offset = ServerTimeOffset

	local function Sync(targets)
		net.Start("ServerTimeSync")
			net.WriteDouble(offset)
		net.Send(targets)
	end

	util.AddNetworkString("ServerTimeSync")
	Sync(player.GetHumans())

	local queue = {}

	hook.Add("PlayerInitialSpawn", "ServerTimeSync", function(ply)
		queue[ply] = true
	end)

	hook.Add("SetupMove", "ServerTimeSync", function(ply, _, cmd)
		if queue[ply] and not cmd:IsForced() then
			queue[ply] = nil
			Sync(ply)
		end
	end)
else
	net.Receive("ServerTimeSync", function()
		ServerTimeOffset = net.ReadDouble()
		offset = ServerTimeOffset
	end)
end
