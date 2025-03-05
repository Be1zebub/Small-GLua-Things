-- deprecated
-- use https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/coro-utils.lua

function MakeCoroFunc(func)
	return function(...)
		local running = coroutine.running()
		local resume = function(...) coroutine.resume(running, ...) end

		func(resume, ...)

		return coroutine.yield()
	end
end

http.CoroFetch = MakeCoroFunc(function(resume, url, headers)
	http.Fetch(url, resume, nil, headers)
end)

http.CoroPost = MakeCoroFunc(function(resume, url, params, headers)
	http.Post(url, params, resume, nil, headers)
end)

-- Usage example:
coroutine.wrap(function()
	local myuseragent = http.CoroFetch("https://gmod.one/myuseragent.php")
	print(myuseragent)
end)()
