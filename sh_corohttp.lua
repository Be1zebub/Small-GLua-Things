-- incredible-gmod.ru
-- coroutine http lib

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
	local myuseragent = http.CoroFetch("https://incredible-gmod.ru/myuseragent.php")
	print(myuseragent)
end)()
