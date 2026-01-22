-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/fifo.lua
-- smth like svelte/redux stores

local reactive = {}

-- Store core (private)
local function createStoreCore(initial, start)
	local value = initial
	local subs = {}
	local stop
	local notifying = false
	local pending = false

	local function notify()
		if notifying then
			pending = true
			return
		end

		notifying = true
		repeat
			pending = false

			for _, fn in ipairs(subs) do
				local success, err = pcall(fn, value)
				if success == false then
					-- Log error but continue notifying other subscribers
					print("Error in subscriber: " .. tostring(err))
				end
			end
		until not pending
		notifying = false
	end

	local function get()
		return value
	end

	local function set(v)
		if value == v then return end

		value = v
		notify()
	end

	local function subscribe(fn)
		assert(type(fn) == "function", "Subscriber must be a function")

		table.insert(subs, fn)

		-- Call subscriber immediately with current value
		local success, err = pcall(fn, value)
		if success == false then
			print("Error in initial subscriber call: " .. tostring(err))
		end

		-- Start if this is the first subscriber
		if #subs == 1 and start then
			stop = start(set)
		end

		-- Return unsubscribe function
		return function()
			for i = #subs, 1, -1 do
				if subs[i] == fn then
					-- Swap with last element and remove (O(1) operation)
					subs[i] = subs[#subs]
					subs[#subs] = nil
					break
				end
			end

			-- Stop if this was the last subscriber
			if #subs == 0 and stop then
				stop()
				stop = nil
			end
		end
	end

	return {
		subscribe = subscribe,
		_set = set,
		_get = get
	}
end

-- Svelte writable store
-- Creates a writable store
-- @param initial Initial value
-- @return Store with subscribe, set, and update methods
-- @usage
--   local count = reactive.writable(0)
--   count.set(5)
--   count.update(function(n) return n + 1 end)
function reactive.writable(initial)
	local core = createStoreCore(initial)

	return {
		subscribe = core.subscribe,
		set = core._set,
		get = core._get,
		update = function(fn)
			assert(type(fn) == "function", "Updater must be a function")
			core._set(fn(core._get()))
		end
	}
end

-- Svelte readable store
-- Creates a readable store
-- @param initial Initial value
-- @param start Optional start function called when first subscriber subscribes
-- @return Store with subscribe method only
-- @usage
--   local time = reactive.readable(os.time(), function(set)
--       local timer = setInterval(function() set(os.time()) end, 1000)
--       return function() clearInterval(timer) end
--   end)
function reactive.readable(initial, start)
	assert(start == nil or type(start) == "function", "Start must be a function or nil")

	local core = createStoreCore(initial, start)

	return {
		subscribe = core.subscribe
	}
end

-- Svelte derived store
-- Creates a derived store from one or more source stores
-- @param stores Single store or array of stores
-- @param fn Function that computes derived value
-- @return Derived store with subscribe method
-- @usage
--   local doubled = reactive.derived(count, function(n) return n * 2 end)
--   local sum = reactive.derived({a, b}, function(a, b) return a + b end)
function reactive.derived(stores, fn)
	assert(type(fn) == "function", "Derivation function must be a function")

	-- Normalize to array of stores
	if stores.subscribe then
		stores = { stores }
	end

	assert(type(stores) == "table", "Stores must be a store or array of stores")

	-- Validate all stores
	for i, store in ipairs(stores) do
		assert(type(store.subscribe) == "function", 
			"Store at index " .. i .. " must have a subscribe method")
	end

	local value
	local subs = {}
	local values = {}
	local sourceUnsubs = {}
	local initialized = false
	local computing = false

	local function recompute()
		if computing then return end
		computing = true

		local newValue = fn(table.unpack(values))

		computing = false

		if newValue == value then return end
		value = newValue
		initialized = true

		-- Notify all subscribers
		for _, subscriberFn in ipairs(subs) do
			local success, err = pcall(subscriberFn, value)
			if not success then
				print("Error in derived subscriber: " .. tostring(err))
			end
		end
	end

	-- Initialize values synchronously
	local tempUnsubs = {}
	for i, store in ipairs(stores) do
		local gotValue = false
		tempUnsubs[i] = store.subscribe(function(v)
			values[i] = v
			gotValue = true
		end)
		if not gotValue then
			values[i] = nil
		end
	end

	-- Unsubscribe from temporary subscriptions
	for _, unsub in ipairs(tempUnsubs) do
		unsub()
	end

	return {
		subscribe = function(fn)
			assert(type(fn) == "function", "Subscriber must be a function")

			table.insert(subs, fn)

			-- Subscribe to source stores on first subscriber
			if #subs == 1 then
				for i, store in ipairs(stores) do
					sourceUnsubs[i] = store.subscribe(function(v)
						values[i] = v
						recompute()
					end)
				end

				-- initial compute
				recompute()
			end

			-- Call subscriber with current value if initialized
			if initialized then
				local success, err = pcall(fn, value)
				if not success then
					print("Error in initial derived subscriber call: " .. tostring(err))
				end
			end

			-- Return unsubscribe function
			return function()
				for i = #subs, 1, -1 do
					if subs[i] == fn then
						-- Swap with last element and remove (O(1) operation)
						subs[i] = subs[#subs]
						subs[#subs] = nil
						break
					end
				end

				-- Unsubscribe from source stores when last subscriber leaves
				if #subs == 0 then
					for _, unsub in ipairs(sourceUnsubs) do
						unsub()
					end
					sourceUnsubs = {}
				end
			end
		end
	}
end

-- Redux style derived selector
-- Creates a derived store from a single source store, selecting a part of its value
-- @param store Source store (writable or readable)
-- @param fn Function to select a part of the value
-- @return Readable store with subscribe method
-- @usage
--   local userName = reactive.select(userStore, function(user) return user.name end)
function reactive.select(store, fn)
	assert(type(store) == "table" and type(store.subscribe) == "function", "store must have subscribe method")
	assert(type(fn) == "function", "selector must be a function")

	return reactive.derived(store, function(value)
		return fn(value)
	end)
end

-- Redux reducer
-- Creates a Redux-style store with reducer pattern
-- @param reducer Function (state, action) -> newState
-- @param initialState Initial state
-- @return Store with getState, dispatch, and subscribe methods
-- @usage
--   local store = reactive.createStore(function(state, action)
--       if action.type == "INCREMENT" then
--           return {count = state.count + 1}
--       end
--       return state
--   end, {count = 0})
function reactive.createStore(reducer, initialState)
	assert(type(reducer) == "function", "Reducer must be a function")

	local state = initialState
	local listeners = {}
	local dispatching = false

	local function getState()
		return state
	end

	local function dispatch(action)
		assert(type(action) == "table", "Action must be a table")
		assert(action.type ~= nil, "Action must have a type property")

		if dispatching then
			error("Reducers may not dispatch actions")
		end

		dispatching = true
		local success, newState = pcall(reducer, state, action)
		dispatching = false

		if not success then
			error("Error in reducer: " .. tostring(newState))
		end

		if newState == nil then
			error("Reducer returned nil")
		end

		if newState == state then return end

		state = newState

		-- Notify all listeners
		for _, fn in ipairs(listeners) do
			local listenerSuccess, err = pcall(fn, state, action)
			if not listenerSuccess then
				print("Error in store listener: " .. tostring(err))
			end
		end
	end

	local function subscribe(fn)
		assert(type(fn) == "function", "Listener must be a function")

		table.insert(listeners, fn)

		-- Return unsubscribe function
		return function()
			for i = #listeners, 1, -1 do
				if listeners[i] == fn then
					-- Swap with last element and remove (O(1) operation)
					listeners[i] = listeners[#listeners]
					listeners[#listeners] = nil
					break
				end
			end
		end
	end

	-- Initialize with default state if reducer handles it
	if initialState ~= nil then
		dispatch({ type = "@@INIT" })
	end

	return {
		getState = getState,
		dispatch = dispatch,
		subscribe = subscribe
	}
end

return reactive
