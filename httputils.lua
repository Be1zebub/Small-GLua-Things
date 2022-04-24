-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/httputils.lua
-- from incredible-gmod.ru with <3

local format, char, tonumber = string.format, string.char, tonumber

local http = http or {} -- path or create new lib

function http.Encode(str) -- encode query
	return (str:gsub("[^%w _~%.%-]", function(char)
		return format("%%%02X", char:byte())
	end):gsub(" ", "+"))
end

--[[
	print("https://google.it/search?q=".. http.Encode("incredible gmod ван лов <3"))
	  > https://google.it/search?q=incredible+gmod+%D0%B2%D0%B0%D0%BD+%D0%BB%D0%BE%D0%B2+%3C3
]]--

function http.Decode(str) -- decode query
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

	for k, v in str:gmatch("([^&=?]-)=([^&=?]+)") do
		query[k] = http.Decode(v)
	end

	return query
end

--[[
	PrintTable(http.ParseQuery("https://api.incredible-gmod.ru/donate/invoice/status/?serverid=1&invoiceid=591278392451"))
	  > serverid 	1
		invoiceid 	591278392451
]]--

function http.Query(tbl) -- format string query from table
	local out

	for k, v in pairs(tbl) do
		out = (out and (out .."&") or "") .. k .."=".. v
	end

	return "?".. out
end

--[[
	print(http.Query({serverid = 1, invoiceid = 591278392451}))
	  > ?serverid=1&invoiceid=591278392451
]]--

function http.PrepareUpload(url, content, filename) -- returns headers, prepared content
	local boundary = "fboundary".. math.random(1, 100)
	local header_bound = "Content-Disposition: form-data; name=\"file\"; filename=\"".. filename .."\"\r\nContent-Type: application/octet-stream\r\n"

	content = "--".. boundary .."\r\n".. header_bound .."\r\n".. content .."\r\n--" .. boundary .."--\r\n"

	return {
		{"Content-Length", #content},
		{"Content-Type", "multipart/form-data; boundary=".. boundary}
	}, content
end

--[[
	local image = file.Read("/home/me.jpg")
	local succ, res, result = pcall(http.request, "POST", http.PrepareUpload("https://api.incredible-gmod.ru/upload", image, "me.jpg"))
	print(result)
	  > https://incredible-gmod.ru/files/cxWJnf6
]]--

return http
