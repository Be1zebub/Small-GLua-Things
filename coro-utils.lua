-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/coro-utils.lua

--[[ Example:
coroutine.wrap(function()
	print(SysTime())
	coroutine.pause(1.5)
	print(SysTime())

	local succ, response, headers, code = coroutine.httpFetch("https://incredible-gmod.ru/ping.php")
	if succ then
		print("coroutine.httpFetch response: ".. response)
	else
		print("coroutine.httpFetch fail, reason: ".. response)
	end
end)()
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

coroutine.http = coroutine.async(function(cback, HTTPRequest)
	HTTPRequest.success = function(code, body, headers)
		cback(true, body, headers, code)
	end
	HTTPRequest.failed = function(err)
		cback(false, err)
	end

	HTTP(HTTPRequest)
end, false)

function coroutine.httpFetch(url, headers)
	return coroutine.http({method = "GET", url = url, headers = headers})
end

function coroutine.httpPost(url, headers, body)
	return coroutine.http({method = "POST", url = url, headers = headers, body = body})
end
