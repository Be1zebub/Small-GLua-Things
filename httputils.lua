-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/httputils.lua
-- from incredible-gmod.ru with <3

local format, char, tonumber = string.format, string.char, tonumber

local http = http or {} -- path or create new lib

function http.Encode(str) -- encode URI https://en.wikipedia.org/wiki/Percent-encoding
	return (str:gsub("[^%w _~%.%-]", function(char)
		return format("%%%02X", char:byte())
	end):gsub(" ", "+"))
end

--[[
	print("https://google.it/search?q=".. http.Encode("incredible gmod ван лов <3"))
	  > https://google.it/search?q=incredible+gmod+%D0%B2%D0%B0%D0%BD+%D0%BB%D0%BE%D0%B2+%3C3
]]--

function http.Decode(str) -- decode URI https://en.wikipedia.org/wiki/Percent-encoding
	return (str:gsub("+", " "):gsub("%%(%x%x)", function(c)
		return char(tonumber(c, 16))
	end))
end

--[[
	print(http.Decode("https://google.it/search?q=incredible+gmod+%D0%B2%D0%B0%D0%BD+%D0%BB%D0%BE%D0%B2+%3C3"))
	  > https://google.it/search?q=incredible gmod ван лов <3
]]--

function http.ParseQuery(str) -- parse string query, returns assoc query table
	local query = {}

	for k, v in str:gmatch("([^%?&=]+)=?([^&]*)") do
		query[k] = http.Decode(v)
	end

	return query
end

--[[
	PrintTable(http.ParseQuery("https://api.incredible-gmod.ru/donate/invoice/status/?serverid=1&invoiceid=591278392451"))
	  > serverid 	1
		invoiceid 	591278392451
]]--

function http.Query(tbl, encode) -- format string query from table
	local out

	for k, v in pairs(tbl) do
		out = (out and (out .."&") or "") .. k .."=".. (encode == false and v or http.Encode(v))
	end

	return "?".. out
end

--[[
	print(http.Query({serverid = 1, invoiceid = 591278392451}))
	  > ?serverid=1&invoiceid=591278392451
]]--

local format = "--%s\r\n%s\r\n%s\r\n--%s--\r\n"

function http.PrepareUpload(content, filename) -- returns headers, prepared content
	local boundary = "fboundary".. math.random(1, 100)
	local header_bound = "Content-Disposition: form-data; name=\"file\"; filename=\"".. filename .."\"\r\nContent-Type: application/octet-stream\r\n"
	local data = format:format(boundary, header_bound, content, boundary)

	return {
		{"Content-Length", #data},
		{"Content-Type", "multipart/form-data; boundary=".. boundary}
	}, data
end

--[[ tested on api.vk.com (photos.getWallUploadServer method)
	local image = file.Read("/home/me.jpg")
	local headers, content = http.PrepareUpload(image, "me.jpg")
	local succ, res, result = pcall(http.request, "POST", "https://api.incredible-gmod.ru/upload", headers, content)
	print(result)
	  > https://incredible-gmod.ru/files/cxWJnf6
]]--

http.cookie = {}

function http.cookie.set(key, value, ttl)
	if ttl then return string.format("%s=%s; max-age=%s;", key, value, ttl) end
	return string.format("%s=%s;", key, value)
end

function http.cookie.delete(key)
	return key .."=; expires=Thu, 01 Jan 1970 00:00:00 GMT;"
end

return http
