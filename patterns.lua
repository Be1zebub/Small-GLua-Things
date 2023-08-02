-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/patterns.lua
-- A few useful lua patterns.

-- I often reuse patterns from my previous projects and sometimes its hard to find pattern in ton lua script that ive developed before, so I decided to sotre them in one place.
-- feel free to contribute!

-- useful links:
-- https://gitspartv.github.io/lua-patterns
-- https://www.lua.org/pil/20.2.html

local utf8_chars = "[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]"
-- local without_russian = string.gsub("Привет world!", utf8_chars, "") > " world!"

local word = "(%s?[%S]+)"
-- for word in string.gmatch("Hi mom!", word) do print(word) end

local filename = "([^/]+)$"
-- local fname = string.match("etc/test/file.txt", filename) > "file.txt"
-- local dirname = string.match("etc/test", filename) > "test"

local filename_wihout_extension = ".+/(.+)%..+"
-- local fname = string.match("etc/test/file.txt", filename_wihout_extension) > "file"

local extension = "^.+(%..+)$"
-- local ext = string.match("file.txt", extension) > ".txt"

local without_extesion = "(.+)%..+"
-- local without_ext = string.match("etc/file.txt", without_extesion) > "etc/file"

local prefix = "^(.-_)"
-- local pre = string.match("sv_core.lua", prefix) > "sv_"

local http_query = "?(.*)"
local http_query_keyvalues = "([^%?&=]+)=?([^&]*)"
-- local without_query = string.gsub("https://my.site/?key=value", http_query, "") > "https://my.site/"
-- local query = string.match("https://my.site/?key=value", http_query) > "key=value"
-- for k, v in string.gmatch("https://my.site/?key=value&test=true", http_query_keyvalues) do print(k, v) end

local ipv4 = "(%d+)%.(%d+)%.(%d+)%.(%d+)"
local ipv6 = "([a-fA-F0-9]*):([a-fA-F0-9]*):([a-fA-F0-9]*)::([a-fA-F0-9]*)"
local host = "(.-):(.+)"
local port = ":(.+)$"
-- local cloudflare = {string.match("I use 1.1.1.1 dns", ipv4)} > {1, 1, 1, 1}
-- local google = {string.match("I use 2001:4860:4860::8888 dns", ipv6)} > {2001, 4860, 4860, 8888}
-- local addr = {string.match("1.1.1.1:80", host)} > {"1.1.1.1", "80"}
-- local port80 = string.match("1.1.1.1:80", port)

local steamid = "(STEAM_%d:%d:%d+)"
-- local steamid32 = string.match("My steamid is STEAM_0:1:62869796 :)", steamid) > "STEAM_0:1:62869796"

local xml = "<tag>(.-)</tag>"
local xml_cdata = "<avatarIcon><%!%[CDATA%[(.-)%]%]></avatarIcon>"
local xml_var = "([^<>]*)(<[^>]+.)([^<>]*)"
-- local innerHTML = string.match("<tag>Hi mom!</tag>", xml) > "Hi mom!"
-- local avatar = string.match("<avatarIcon><![CDATA[ https://avatars.cloudflare.steamstatic.com/c0b4eee47bebc4d88b5ec446c2ab4caa5bfa4872.jpg ]]></avatarIcon>", xml_cdata)
-- local key, value = string.match("<font=Default>Text!</font>", xml_var) > "font", "Default"

local youtube_id = "[&?]v=([^&]*)"
-- local video_id = string.match("https://www.youtube.com/watch?v=Z8OkhuzIUhA", youtube_id) > "Z8OkhuzIUhA"

-- "youtube.com/v/TTT", "http://youtube.com/watch?v=EEE", "https://youtu.be/SSS", "https://music.youtube.com/watch?v=TTT" support
-- local video_id = url:match("[&?]v=([^&]*)") or url:match("youtu%.be/(.*)") or url:match("youtube%.com/v/(.*)")

local rgb_hsv_hsl = "([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)"
local cmyk = "([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)[ ,]+([-x.%x]+)"
-- local c, m, y, k = string.match("100, 0, 0, 0", cmyk)
-- local r, g, b = string.match("255, 0, 0", rgb_hsv_hsl)
-- local h, s, v = string.match("100, 0, 0", rgb_hsv_hsl)
-- local h, s, l = string.match("100, 0, 0", rgb_hsv_hsl)

local emoji = ":[%w%p]+:" -- discord
-- for emoji in string.gmatch(":wave: world! I love :moon:!", emoji) do print(emoji) end

local mentions = {user = "<@!?(%d+)>", member = "<@!?(%d+)>", role = "<@&(%d+)>", channel = "<#(%d+)>"} -- discord
-- local channel_id = string.match("Welcome to <#676069143463723018> channel!", mentions.channel) > "676069143463723018"

local iso8601 = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%+%-])(%d?%d?)%:?(%d?%d?)"
-- local year, month, day, hour, minute, seconds, offsetsign, offsethour, offsetmin = string.match("2022-12-08T16:00:00.000Z", iso8601)

local len = "(%d*%.?%d+)([dwhm])"
-- for k, v in string.gmatch("1d is 24h", len) do print(k, v) end

local math = "(%d+)%s*([*%/-+^%%])%s*(%d+)"
-- local epoh_53years = string.gsub("2023 - 1970 years sience epoh start", math, function(a, operator, b) if operator == "-" then return tonumber(a) + tonumber(b) end end)
