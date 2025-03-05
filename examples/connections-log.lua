-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/example/connections-log.lua

-- simple connections-log example

local function dayCount()
	local current_date = os.date("!%d_%m_%Y", os.time() + 3 * 60 * 60) -- MSK TimeZoned TimeStamp
	local file_path = "connect-logs/all_" .. current_date .. ".txt"

	return file_path, file.Read(file_path, "DATA") or 0
end

function uniqueDayCount()
	local current_date = os.date("!%d_%m_%Y", os.time() + 3 * 60 * 60)
	local file_path = "connect-logs/unique_" .. current_date .. ".json"

	local data = file.Read(file_path, "DATA")
	local tab = util.JSONToTable(data) or {}

	return file_path, tab, table.Count(tab)
end

file.CreateDir("connect-logs")

gameevent.Listen("player_connect")
hook.Add("player_connect", "connect-logs", function(data)
	if data.bot == 1 then return end -- ignore bots

	local path, info = dayCount()
	file.Write(path, info + 1)

	path, info = uniqueDayCount()
	info[util.SteamIDTo64(data.networkid)] = true
	file.Write(path, info)
end)
