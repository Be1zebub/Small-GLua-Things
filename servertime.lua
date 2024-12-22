-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/servertime.lua

-- synced shared unix time getter with ms precision (serverside timezone)
-- this required for  stabillity between restarts (eg saving entity cooldown dt between restarts)

local offset = 0

function ServerTime()
	return offset + CurTime()
end

if SERVER then
	offset = os.time() - CurTime()

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
		offset = net.ReadDouble()
	end)
end
