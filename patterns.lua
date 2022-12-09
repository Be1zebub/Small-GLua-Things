-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/patterns.lua
-- A few useful lua patterns.

local word = "(%s?[%S]+)"
-- for word in string.gmatch("Hi mom!", word) do print(word) end

local filename = "([^/]+)$"
-- local fname = string.match("etc/test/file.txt", filename) > "file.txt"
-- local dirname = string.match("etc/test", filename) > "test"

local extension = "^.+(%..+)$"
-- local ext = string.match("file.txt", extension) > ".txt"

local without_extesion = "(.+)%..+"
-- local without_ext = string.match("etc/file.txt", without_extesion) > "etc/file"

local http_query = "?(.*)"
-- local without_query = string.gsub("https://my.site/?key=value", http_query_remove, "") > "https://my.site/"
-- local query = string.match("https://my.site/?key=value", http_query) > "key=value"

local xml = "<tag>(.-)</tag>"
local xml_cdata = "<avatarIcon><%!%[CDATA%[(.-)%]%]></avatarIcon>"
-- local innerHTML = string.match("<tag>Hi mom!</tag>", xml) > "Hi mom!"

local youtube_id = "[&?]v=([^&]*)"
-- local video_id = string.match("https://www.youtube.com/watch?v=Z8OkhuzIUhA", youtube_id) > "Z8OkhuzIUhA"

local rgb_hsv_hsl = "([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)"
local cmyk = "([x.%x]+)[ ,]+([x.%x]+)[ ,]+([x.%x]+)[ ,]+([-x.%x]+)"
-- local c, m, y, k = string.match("100, 0, 0, 0", cmyk)
-- local r, g, b = string.match("255, 0, 0", rgb_hsv_hsl)
-- local h, s, v = string.match("100, 0, 0", rgb_hsv_hsl)
-- local h, s, l = string.match("100, 0, 0", rgb_hsv_hsl)

local emoji = ":[%w%p]+:"
-- for emoji in string.gmatch(":wave: world! I love :moon:!", emoji) do print(emoji) end
