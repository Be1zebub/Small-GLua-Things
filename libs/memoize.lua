-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/memoize.lua
-- simple caching lib

--[[ oop memoize implementation
features: varargs support, gc (manual)
deps: CurTime, timer.Create (you can also use libs/gtimer.lua)
api:
    api.getAvatar = memoize:new(api.getAvatar, 60) -- memoize function with 60 seconds ttl
    local new = api.getAvatar("userid")
    local cached_value = api.getAvatar("userid")

    api.findUsers = memoize:new(api.findUsers, 120, true) -- memoize function with 120 seconds ttl, enable varArgsSupport
    local new = api.findUsers("userid1", "userid2", "userid3")
    local cached_value = api.findUsers("userid1", "userid2", "userid3")

    api.findUsers:SetTTL(300) -- change ttl
    api.findUsers:CleanCache() -- purge cache
    api.findUsers:GrabageCollector() -- collect garbage
    api.findUsers:AutoClean(600) -- init automatic garbage collector with given interval
    api.findUsers:AutoClean() -- by default it will use ttl as iterval
]]--

local deps = { -- you can replace it with your own deps to run this lib in any runtime (eg i used it with Luvit)
	getTime = CurTime,
	timer = timer.Create
}

local memoize = {}

function memoize:Call(arg)
	if self.cache[arg] == nil or self.cache[arg].aliveUntil < deps.getTime() then
		self.cache[arg] = {
			value = self.func(arg),
			aliveUntil = deps.getTime() + self.ttl
		}
	end

	return self.cache[arg].value
end

function memoize:CallVarargs(...)
	local args = {...}
	local arg = args[1]
	local object = self.cache[arg]

	if object == nil then
		self.cache[arg] = {}
	end

	for i = 2, #args - 1 do
		local arg = args[i]
		local this = object[arg]

		if this == nil then
			this = {}
			object[arg] = this
		end

		object = this
	end

	arg = args[#args]
	if object[arg] == nil or object[arg].aliveUntil < deps.getTime() then
		object[arg] = {
			value = self.func(...),
			aliveUntil = deps.getTime() + self.ttl
		}
	end

	return object[arg].value
end

function memoize:SetTTL(ttl)
	self.ttl = ttl
end

function memoize:CleanCache()
	self.cache = {}
end

function memoize:DeepGrabageCollector(parent)
	for arg, object in pairs(parent) do
		if object.aliveUntil == nil then
			self:DeepGrabageCollector(object)
		elseif object.aliveUntil < time then
			parent[arg] = nil
		end
	end
end

function memoize:GrabageCollector()
	local time = deps.getTime()
	local cache = self.cache

	if self.varArgsSupport then
		self:DeepGrabageCollector(cache)
	else
		for arg, object in pairs(cache) do
			if object.aliveUntil < time then
				cache[arg] = nil
			end
		end
	end
end

function memoize:AutoClean(interval)
	deps.timer("memoize-" .. tostring(self), interval or self.ttl, 0, function()
		self:GrabageCollector()
	end)
end

return function(func, ttl, varArgsSupport, cache)
	return setmetatable({
		cache = cache or {},
		func = func,
		ttl = ttl,
		varArgsSupport = varArgsSupport -- old jit versions doesnt compile varargs functions, so due to perf - its better to use varargs functions only if we need it.
	}, {__index = memoize, __call = varArgsSupport and memoize.CallVarargs or memoize.Call})
end
