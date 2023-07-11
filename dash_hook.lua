-- dash hook fork (think commit is just a raw copy, to have git diff with next commit)
-- upstream licnese: https://github.com/SuperiorServers/dash/blob/master/LICENSE

local debug_info 	= debug.getinfo
local isstring 		= isstring
local isfunction 	= isfunction
local IsValid 		= IsValid

local hook_callbacks = {}
local hook_mapping   = {} -- Bidirectional mapping between indexes and ids (ids cannot be numbers)

local function GetTable() -- This function is now slow
	local ret = {}
	for name, callbacks in pairs(hook_callbacks) do
		ret[name] = {}
		for index, callback in pairs(callbacks) do
			local id = hook_mapping[name][index]
			if (id ~= nil) then
				ret[name][id] = callback
			end
		end
	end
	return ret
end

local function Exists(name, id)
	return (hook_mapping[name] ~= nil) and (hook_mapping[name][id] ~= nil)
end

local function Call(name, gm, ...)
	local callbacks = hook_callbacks[name]

	if (callbacks ~= nil) then

		local i = 1

		::runhook::
		local v = callbacks[i]
		if (v ~= nil) then
			local a, b, c, d, e, f = v(...)
			if (a ~= nil) then
				return a, b, c, d, e, f
			end
			i = i + 1
			goto runhook
		end
	end

	if (not gm) then
		return
	end

	local callback = gm[name]
	if (not callback) then
		return
	end

	return callback(gm, ...)
end

local function Run(name, ...)
	return Call(name, GAMEMODE, ...)
end

local function Remove(name, id)
	local callbacks = hook_callbacks[name]

	if (not callbacks) then
		return
	end

	local mapping = hook_mapping[name]
	local index = mapping[id]

	if (not index) then
		return
	end

	mapping[id], mapping[index] = nil, nil

	local count = callbacks[0]
	if (count == index) then
		callbacks[index] = nil

		-- Remove gap functions from the end
		index = index - 1
		while index > 0 and mapping[index] == nil do
			callbacks[index], index = nil, index - 1
		end
		callbacks[0] = index

		if (index == 0) then
			hook_callbacks[name] = nil
		end
	else
		-- Replace it with a "gap function" - when it is called later, it will pop the last callback off, call it, and replace itself
		callbacks[index] = function(...)
			local count = callbacks[0]
			assert(count > index)

			local id, callback = mapping[count], callbacks[count]
			mapping[count], callbacks[count] = nil, nil

			-- Remove gap functions from the end
			count = count - 1
			while count > index and mapping[count] == nil do
				callbacks[count], count = nil, count - 1
			end
			callbacks[0] = count

			mapping[index], mapping[id], callbacks[index] = id, index, callback

			return callback(...)
		end
	end
end

local function Add(name, id, callback)
	if isfunction(id) then
		callback = id
		id = debug_info(callback).short_src
	end

	if (not callback) then
		return
	end

	local callbacks, mapping = hook_callbacks[name], hook_mapping[name]
	if (callbacks == nil) then
		callbacks = {[0] = 0}
		hook_callbacks[name] = callbacks

		if (mapping == nil) then
			mapping = {}
			hook_mapping[name] = mapping
		end
	end

	if (not isstring(id)) then
		assert(not isnumber(id))
		local orig = callback
		callback = function(...)
			if IsValid(id) then
				return orig(id, ...)
			else
				Remove(name, id)
			end
		end
	end

	local index = mapping[id]
	if (index ~= nil) then
		callbacks[index] = callback
	else
		index = callbacks[0] + 1
		callbacks[index], mapping[id], mapping[index], callbacks[0] = callback, index, id, index
	end
end


hook = setmetatable({
	Remove = Remove,
	GetTable = GetTable,
	Exists = Exists,
	Add = Add,
	Call = Call,
	Run = Run
}, {
	__call = function(self, ...)
		return self.Add(...)
	end
})
