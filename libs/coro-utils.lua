-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/coro-utils.lua

-- examples:

--[[
coroutine.exec(function()
	print(SysTime())
	coroutine.pause(1.5)
	print(SysTime())

	local succ, response, headers, code = coroutine.http.Fetch("https://gmod.one/ping.php")
	if succ then
		print("coroutine.http.Fetch response: ".. response)
	else
		print("coroutine.http.Fetch fail - reason: ".. response)
	end
end)
]]--

--[[
local function test()
	local fileName, gamePath, status, data = coroutine.await(file.AsyncRead, "cfg/skill_manifest.cfg.txt", "GAME")
	print("coroutine.await\n", fileName, gamePath, status, data)

	http.AsyncFetch = coroutine.makeAsync(http.Fetch, {2, 3})
	local body, size, headers, code = http.AsyncFetch("https://dummyjson.com/test", {
		["Cache-Control"] = "max-age=0"
	})

	if size then
		print("coroutine.async\n", "success", body, size, headers, code)
	else
		print("coroutine.async\n", "fail", body)
	end
end

coroutine.exec(test)
]]--


function coroutine.pause(delay)
	local co = coroutine.running()

	timer.Simple(delay, function()
		coroutine.resume(co)
	end)

	coroutine.yield()
end

function coroutine.async(fn)
	return function(...)
		local co = coroutine.running()

		fn(function(succ, err, ...)
			if succ == false then
				ErrorNoHaltWithStack(err .."\n")
			end

			coroutine.resume(co, err, ...)
		end, ...)

		return coroutine.yield()
	end
end

coroutine.http = setmetatable({}, {
	__call = coroutine.async(function(cback, HTTPRequest)
		HTTPRequest.success = function(code, body, headers)
			cback(true, body, headers, code)
		end
		HTTPRequest.failed = function(err)
			cback(false, err)
		end

		HTTP(HTTPRequest)
	end, false)
})

function coroutine.http.fetch(url, headers)
	return coroutine.http({method = "GET", url = url, headers = headers})
end

function coroutine.http.post(url, headers, body)
	return coroutine.http({method = "POST", url = url, headers = headers, body = body})
end


local unpack = table.unpack or unpack

function coroutine.await(fn, ...)
	local co = assert(coroutine.running(), "async function must be run within a coroutine")
	local args = {...}
	local completed, results = false

	args[#args + 1] = function(...)
		if coroutine.status(co) == "suspended" then
			coroutine.resume(co, ...)
		else
			results = {...}
			completed = true
		end
	end

	fn(unpack(args))

	if completed then
		return unpack(results)
	end

	return coroutine.yield()
end

function coroutine.makeAsync(fn, cbackPositions)
	if type(cbackPositions) ~= "table" then -- it can be single index or table
		cbackPositions = {cbackPositions}
	end

	return function(...)
		local co = assert(coroutine.running(), "async function must be run within a coroutine")
		local args = {...}
		local completed, results = false

		local function cback(...)
			if coroutine.status(co) == "suspended" then
				coroutine.resume(co, ...)
			else
				results = {...}
				completed = true
			end
		end

		for _, index in ipairs(cbackPositions) do
			table.insert(args, index, cback)
		end

		fn(unpack(args))

		if completed then
			return unpack(results)
		end

		return coroutine.yield()
	end
end

function coroutine.exec(asyncFn, ...)
	return coroutine.wrap(asyncFn)(...)
end
