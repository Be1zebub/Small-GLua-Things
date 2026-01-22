-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/state-machine.lua

-- state management lib with autosync.

local allowUpdate = SERVER

local function newBag(bag, onChange)
	local proxy, mt = {}, {}

	function mt:__index(key)
		return bag[key]
	end

	function mt:__newindex(key, value)
		if allowUpdate == false or bag[key] == value then return end

		bag[key] = value
		if onChange then onChange(key, value) end
	end

	return setmetatable(proxy, mt)
end

local states = {}

local function assertReceivers(receivers)
	if istable(receivers) then
		for _, receiver in ipairs(receivers) do
			if (IsValid(receiver) and receiver:IsPlayer()) == false then
				error("receivers must be a player/table of players")
			end
		end
	elseif receivers ~= nil and (IsValid(receivers) and receivers:IsPlayer()) == false then
		error("receivers must be a player/table of players")
	end
end

local function destroyState(uid)
	assert(isstring(uid), "uid must be a string")
	if states[uid] == nil then return false end

	states[uid] = nil

	return true
end

local function mountState(uid, bag, onUpdate)
	assert(isstring(uid), "uid must be a string")

	if bag == nil then
		bag = {}
	else
		assert(istable(bag), "bag must be a table")
	end

	destroyState(uid)

	local state = {
		bag = newBag(bag, onUpdate)
	}

	states[uid] = state

	return state
end

local State = {}

if SERVER then
	function State:Mount(uid, bag, receivers)
		assertReceivers(receivers)

		local state = mountState(uid, bag, function(key, value)
			if state.receivers then
				net.Start("gmod.one/state:change")
					net.WriteString(uid)
					net.WriteType(key)
					net.WriteType(value)
				net.Send(state.receivers)
			end
		end)

		state.raw = bag
		state.receivers = receivers

		if state.receivers then
			net.Start("gmod.one/state:mount")
				net.WriteString(uid)
				net.WriteTable(bag)
			net.Send(state.receivers)
		end

		return state.bag
	end

	function State:Destroy(uid)
		local state = states[uid]

		if destroyState(uid) then
			net.Start("gmod.one/state:destroy")
				net.WriteString(uid)
			net.Send(state.receivers)
		end
	end

	function State:SetReceivers(uid, receivers)
		local state = states[uid]
		if not state then return end

		assertReceivers(receivers)
		state.receivers = receivers
	end

	function State:Sync(uid, receivers)
		local state = states[uid]
		if not state then return end

		assertReceivers(receivers)

		net.Start("gmod.one/state:mount")
			net.WriteString(uid)
			net.WriteTable(state.raw)
		net.Send(receivers)
	end
end

function State:Exists(uid)
	return states[uid] ~= nil
end

function State:GetBag(uid)
	local state = states[uid]
	return state and state.bag
end

if SERVER then
	util.AddNetworkString("gmod.one/state:mount")
	util.AddNetworkString("gmod.one/state:change")
	util.AddNetworkString("gmod.one/state:destroy")
else
	net.Receive("gmod.one/state:mount", function() -- full snapshot
		local uid = net.ReadString()
		local bag = net.ReadTable()
		mountState(uid, bag)
	end)

	net.Receive("gmod.one/state:change", function() -- delta
		local uid = net.ReadString()
		local bag = State:GetBag(uid)
		if not bag then return end

		local key = net.ReadType()
		local value = net.ReadType()

		allowUpdate = true
		bag[key] = value
		allowUpdate = false
	end)

	net.Receive("gmod.one/state:destroy", function()
		local uid = net.ReadString()
		destroyState(uid)
	end)
end

return State
