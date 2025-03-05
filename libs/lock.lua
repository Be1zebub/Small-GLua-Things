-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/lock.lua

-- lock queue mechanism

local function usageExample() -- gc will collect it, so dont care about define
	local lock = require("lock")
	local queue = lock()

	function http.request(params, cback)
		params.failed = function(reason)
			if cback then
				cback(false, {reason = reason})
			end

			queue:UnLock()
		end

		params.success = function(code, body, headers)
			if cback then
				cback(true, {code = code, body = body, headers = headers})
			end

			queue:UnLock()
		end

		if queue:IsLocked() then
			queue:Push(HTTP, params)
		else
			queue:Lock()
			HTTP(params)
		end
	end

	-- it will perform http request & lock queue
	http.request({
		method = "POST",
		url = "https://mysite.com/login",
		body = base64.encode("login:password")
	}, function(succ, response)
		print("Login", succ)
		PrintTable(response)
	end)

	-- it will push request to queue
	-- when previous request is completed, it will unlock queue & perform next request (this)
	http.request({
		method = "GET",
		url = "https://mysite.com/@me?format=json"
	}, function(succ, response)
		print("@me", succ)
		PrintTable(response)
	end)
end

local LOCK = {}

function LOCK:IsLocked()
	return self.locked
end

function LOCK:Lock()
	self.locked = true
end

function LOCK:UnLock()
	self.locked = false
	if #self == 0 then return end

	local args = {table.remove(self, 1)}
	local func = table.remove(args, 1)

	self.locked = true
	func(unpack(args))
end

function LOCK:Push(func, ...)
	table.insert(self, {func, ...})
end

return function()
	return setmetatable({locked = false}, {__index = LOCK})
end
