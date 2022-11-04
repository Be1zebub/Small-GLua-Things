-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/onnetworkvarupdate.lua

local function OnNetworkVarUpdate(ent)
	--print("~ OnEntityCreated", ent)

	if ent.dt == nil then return end

	local meta = getmetatable(ent.dt)
	local __newindex = meta.__newindex
	function meta:__newindex(name, val)
		local old = self[name]
		__newindex(self, name, val)
		if val == old then return end
		hook.Run("OnNetworkVarUpdate", ent, name, old, val, 1)
	end

	for name, val in pairs(ent:GetNetworkVars() or {}) do
		--print("\t>", name, val)
		hook.Run("OnNetworkVarUpdate", ent, name, nil, val, 2)
	end

	timer.Simple(0, function()
		for name, val in pairs(ent:GetNetworkVars() or {}) do
			--print("\t>>", name, val)
			hook.Run("OnNetworkVarUpdate", ent, name, nil, val, 2)
		end
	end)

	local NetworkVar = ent.NetworkVar
	ent.NetworkVar = function(me, type, index, name, other)
		NetworkVar(me, type, index, name, other)
		me:NetworkVarNotify(name, function(ent, _, old, new)
			if old ~= new then
				hook.Run("OnNetworkVarUpdate", ent, name, old, new, 3)
			end
		end)
	end
end

if SERVER then
	hook.Add("OnEntityCreated", "OnNetworkVarUpdate", OnNetworkVarUpdate)
else
	hook.Add("NetworkEntityCreated", "OnNetworkVarUpdate", function(ent)
		timer.Simple(0.1 + LocalPlayer():Ping() / 1000, function()
			OnNetworkVarUpdate(ent)
		end)
	end)
end
