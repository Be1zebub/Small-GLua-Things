--[[——————————————————————————————————————————————--
               Developer: Be1zebub
             Website: incredible-gmod.ru
        EMail: beelzebub@incredible-gmod.ru
        Discord: discord.incredible-gmod.ru
--——————————————————————————————————————————————]]

function http.CoroFetch(url, headers)
	local running = coroutine.running()
	local resume = function(...) coroutine.resume(running, ...) end
	
	 http.Fetch(url, resume, nil, headers)

	return coroutine.yield()
end

function http.CoroPost(url, params, headers)
	local running = coroutine.running()
	local resume = function(...) coroutine.resume(running, ...) end
	
	 http.Post(url, params, resume, nil, headers)

	return coroutine.yield()
end

-- Usage example:
coroutine.wrap(function()
	local myuseragent = http.CoroFetch("https://incredible-gmod.ru/myuseragent.php")
	print(myuseragent)
end)()
