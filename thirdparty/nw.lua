-- license https://github.com/SuperiorServers/dash/blob/a0d4347371503b1577d72bed5f6df46d48909f56/LICENSE
-- src https://github.com/SuperiorServers/dash/blob/a0d4347371503b1577d72bed5f6df46d48909f56/lua/dash/libraries/nw.lua

--[[
local var = nw.Register 'MyVar' 	-- You MUST call this ALL shared
	var:Write(net.WriteUInt, 32) 	-- Write function
	var:Read(net.ReadUInt, 32) 		-- Read function
	var:SetPlayer() 				-- Registers the var for use on players
	var:SetLocalPlayer() 			-- Optionally set the var to only network to the player its set on, no need to call SetPlayer with this
	var:SetGlobal() 				-- Registers the var for use with nw.SetGlobal
	var:SetNoSync() 				-- Stops the var from syncing to new players, SetLocalPlayer does this for you.
	var:Filter(function(ent, value) -- Sets a var to only send to players you return in your callback
		return player.GetWhatever() -- return table players
	end)

nw.WaitForPlayer(player, callback) 	-- Calls your callback when the player is ready to recieve net messages

-- Set Functions
ENTITY:SetNetVar(var, value)
nw.SetGlobal(var, value)

-- Get functions
ENTITY:GetNetVar(var)
nw.GetGlobal(var)
]]


nw = nw or {
	Data = {
		[0] = {}
	},
	Vars = {},
	Mappings = {},
	Callbacks = {}
}

local vars 		= nw.Vars
local mappings 	= nw.Mappings
local data 		= nw.Data
local globals 	= data[0]
local callbacks = nw.Callbacks

local NETVAR 	= {}
NETVAR.__index 	= NETVAR

debug.getregistry().Netvar = NETVAR

local bitmap 	= {
	[3]		= 3,
	[7] 	= 4,
	[15] 	= 5,
	[31] 	= 6,
	[63] 	= 7,
	[127] 	= 8,
	[255] 	= 9,
	[511]	= 10
}

local bitcount 	= 2

local ENTITY 	= FindMetaTable 'Entity'

local pairs 	= pairs
local Entity 	= Entity

local net_WriteUInt = net.WriteUInt
local net_ReadUInt 	= net.ReadUInt
local net_Start 	= net.Start
local net_Send 		= (SERVER) and net.Send or net.SendToServer
local net_Broadcast = net.Broadcast
local player_GetAll = player.GetAll
local sorted_pairs 	= SortedPairsByMemberValue

function nw.Register(var) -- You must always call this on both the client and server. It will serioulsy break shit if you don't.
	local t = {
		Name = var,
		NetworkString = 'nw_' .. var,
		WriteFunc = net.WriteType,
		ReadFunc = net.ReadType,
		SendFunc = function(self, ent, value, recipients)
			if (recipients ~= nil) then
				net_Send(recipients)
			else
				net_Broadcast()
			end
		end,
	}
	setmetatable(t, NETVAR)
	vars[var] = t

	if (SERVER) then
		util.AddNetworkString(t.NetworkString)
	else
		net.Receive(t.NetworkString, function()
			local index, value = t:_Read()

			if (not data[index]) then
				data[index] = {}
			end

			local oldValue = data[index][var]
			data[index][var] = value

			t:_CallHook(index, value, oldValue)
		end)
	end

	return t:_Construct()
end

function NETVAR:Write(func, opt)
	self.WriteFunc = function(value)
		func(value, opt)
	end
	return self:_Construct()
end

function NETVAR:Read(func, opt)
	self.ReadFunc = function()
		return func(opt)
	end
	return self:_Construct()
end

function NETVAR:Filter(func)
	self.SendFunc = function(self, ent, value, recipients)
		net_Send(recipients or func(ent, value))
	end
	return self:_Construct()
end

function NETVAR:SetPlayer()
	self.PlayerVar = true
	return self:_Construct()
end

function NETVAR:SetLocalPlayer()
	self.LocalPlayerVar = true
	return self:_Construct()
end

function NETVAR:SetGlobal()
	self.GlobalVar = true
	return self:_Construct()
end

function NETVAR:SetNoSync()
	self.NoSync = true
	return self:_Construct()
end

function NETVAR:SetHook(name)
	self.Hook = name
	return self
end

function NETVAR:_Send(ent, value, recipients)
	net_Start(self.NetworkString)
		self:_Write(ent, value)
	self:SendFunc(ent, value, recipients)
end

function NETVAR:_CallHook(index, value, oldValue)
	if self.Hook then
		if (index ~= 0) then
			hook.Call(self.Hook, GAMEMODE, Entity(index), value, oldValue)
		else
			hook.Call(self.Hook, GAMEMODE, value, oldValue)
		end
	end
end

function NETVAR:_Construct()
	local WriteFunc = self.WriteFunc
	local ReadFunc 	= self.ReadFunc

	if self.PlayerVar then
		self._Write = function(self, ent, value)
			net_WriteUInt(ent:EntIndex(), 8)
			WriteFunc(value)
		end
		self._Read = function(self)
			return net_ReadUInt(8), ReadFunc()
		end
	elseif self.LocalPlayerVar then
		self._Write = function(self, ent, value)
			WriteFunc(value)
		end
		self._Read = function(self)
			return LocalPlayer():EntIndex(), ReadFunc()
		end
		self.SendFunc = function(self, ent, value, recipients)
			net_Send(ent)
		end
	elseif self.GlobalVar then
		self._Write = function(self, ent, value)
			WriteFunc(value)
		end
		self._Read = function(self)
			return 0, ReadFunc()
		end
	else
		self._Write = function(self, ent, value)
			net_WriteUInt(ent:EntIndex(), 13)
			WriteFunc(value)
		end
		self._Read = function(self)
			return net_ReadUInt(13), ReadFunc()
		end
	end

	nw.Mappings = {}
	mappings = nw.Mappings
	for k, v in sorted_pairs(vars, 'Name', false) do
		local c = #mappings + 1
		vars[k].ID = c
		mappings[c] = v
		if bitmap[c] then
			bitcount = bitmap[c]
		end
	end

	return self
end

function nw.GetGlobal(var)
	return globals[var]
end

function ENTITY:GetNetVar(var)
	local index = self:EntIndex()
	return data[index] and data[index][var]
end

if (SERVER) then
	util.AddNetworkString 'nw.PlayerSync'
	util.AddNetworkString 'nw.NilEntityVar'
	util.AddNetworkString 'nw.NilPlayerVar'
	util.AddNetworkString 'nw.EntityRemoved'
	util.AddNetworkString 'nw.PlayerRemoved'

	net.Receive('nw.PlayerSync', function(len, pl)
		if (pl.EntityCreated ~= true) then
			hook.Call('PlayerEntityCreated', GAMEMODE, pl)

			pl.EntityCreated = true

			for index, _vars in pairs(data) do
				for var, value in pairs(_vars) do
					local ent = Entity(index)
					if (not vars[var].LocalPlayerVar and not vars[var].NoSync) or (ent == pl) then
						vars[var]:_Send(ent, value, pl)
					end
				end
			end

			if (callbacks[pl] ~= nil) then
				for i = 1, #callbacks[pl] do
					callbacks[pl][i](pl)
				end
			end
			callbacks[pl] = nil
		end
	end)

	hook.Add('EntityRemoved', 'nw.EntityRemoved', function(ent)
		local index = ent:EntIndex()

		if (index ~= 0) and (data[index] ~= nil) then -- For some reason this kept getting called on Entity(0), not sure why...
			if ent:IsPlayer() then
				net_Start('nw.PlayerRemoved')
					net_WriteUInt(index, 8)
				net_Broadcast()
			else
				net_Start('nw.EntityRemoved')
					net_WriteUInt(index, 13)
				net_Broadcast()
			end

			data[index] = nil
		end
	end)

	function nw.WaitForPlayer(pl, cback)
		if (pl.EntityCreated == true) then
			cback(pl)
		else
			if (callbacks[pl] == nil) then
				callbacks[pl] = {}
			end
			callbacks[pl][#callbacks[pl] + 1] = cback
		end
	end

	function nw.SetGlobal(var, value)
		globals[var] = value
		if (value ~= nil) then
			vars[var]:_Send(0, value)
		else
			net_Start('nw.NilEntityVar')
				net_WriteUInt(0, 13)
				net_WriteUInt(vars[var].ID, bitcount)
			vars[var]:SendFunc(0, value)
		end
	end

	function ENTITY:SetNetVar(var, value)
		local index = self:EntIndex()

		if (not data[index]) then
			data[index] = {}
		end

		data[index][var] = value

		if (value ~= nil) then
			vars[var]:_Send(self, value)
		else
			if self:IsPlayer() then
				net_Start('nw.NilPlayerVar')
				net_WriteUInt(index, 8)
			else
				net_Start('nw.NilEntityVar')
				net_WriteUInt(index, 13)
			end
			net_WriteUInt(vars[var].ID, bitcount)
			vars[var]:SendFunc(self, value)
		end
	end
else
	hook.Add('InitPostEntity', 'nw.InitPostEntity', function()
		net_Start('nw.PlayerSync')
		net_Send()
	end)

	local function nwNilVar(index, id)
		if data[index] and mappings[id] then
			local oldValue = data[index][mappings[id].Name]
			data[index][mappings[id].Name] = nil
			mappings[id]:_CallHook(index, nil, oldValue)
		end
	end

	net.Receive('nw.NilEntityVar', function()
		nwNilVar(net_ReadUInt(13), net_ReadUInt(bitcount))
	end)

	net.Receive('nw.NilPlayerVar', function()
		nwNilVar(net_ReadUInt(8), net_ReadUInt(bitcount))
	end)

	net.Receive('nw.EntityRemoved', function()
		data[net_ReadUInt(13)] = nil
	end)

	net.Receive('nw.PlayerRemoved', function()
		data[net_ReadUInt(8)] = nil
	end)
end
