-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/servertime.lua

-- synced shared unix time getter with ms precision (serverside timezone)
-- this required for  stabillity between restarts (eg saving entity cooldown dt between restarts)

local offset = 0

function ServerTime()
	return offset + CurTime()
end

if SERVER then
	offset = os.time() - CurTime()

	local queue = {}

	hook.Add("PlayerInitialSpawn", "ServerTimeSync", function(ply)
		queue[ply] = true
	end)

	hook.Add("SetupMove", "ServerTimeSync", function(ply, _, cmd)
		if queue[ply] and not cmd:IsForced() then
			queue[ply] = nil

			net.Start("ServerTimeSync")
				net.WriteDouble(offset)
			net.Send(ply)
		end
	end)

	util.AddNetworkString("ServerTimeSync")
else
	net.Receive("ServerTimeSync", function()
		offset = net.ReadDouble()
	end)
end
