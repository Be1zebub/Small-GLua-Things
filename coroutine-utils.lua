local unpack = table.unpack or unpack

function coroutine.await(asyncFn, ...)
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

	asyncFn(unpack(args))

	if completed then
		return unpack(results)
	end

	return coroutine.yield()
end

function coroutine.async(asyncFn, cbackPositions)
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

		asyncFn(unpack(args))

		if completed then
			return unpack(results)
		end

		return coroutine.yield()
	end
end

function coroutine.exec(asyncFn, ...)
	return coroutine.wrap(asyncFn)(...)
end

--[[
local function test()
	local fileName, gamePath, status, data = coroutine.await(file.AsyncRead, "cfg/skill_manifest.cfg.txt", "GAME")
	print("coroutine.await\n", fileName, gamePath, status, data)

	http.AsyncFetch = coroutine.async(http.Fetch, {2, 3})
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
