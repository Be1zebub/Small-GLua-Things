-- incredible-gmod.ru
-- simple connections-log example

function IncredibleConnectLogs_DayCount()
	local current_date = os.date("!%d_%m_%Y", os.time() + 3 * 60 * 60) -- MSK TimeZoned TimeStamp
	local file_path = "incredible_connectlogs/all_"..current_date..".txt"

	return file_path, file.Read(file_path, "DATA") or 0
end

function IncredibleConnectLogs_UniqueDayCount()
	local current_date = os.date("!%d_%m_%Y", os.time() + 3 * 60 * 60)
	local file_path = "incredible_connectlogs/unique_"..current_date..".json"

	local data = file.Read(file_path, "DATA")
	local tab = util.JSONToTable(data) or {}

	return file_path, tab, table.Count(tab)
end

gameevent.Listen("player_connect")
hook.Add("player_connect", "Incredible_PlayerConnectLogs", function(data)
	if data.bot == 1 then return end -- ignore bots

	if not file.Exists("incredible_connectlogs", "DATA") then
		file.CreateDir("incredible_connectlogs")
	end

	local path, info = IncredibleConnectLogs_DayCount()
	file.Write(path, info + 1)


	path, info = IncredibleConnectLogs_UniqueDayCount()
	info[util.SteamIDTo64(data.networkid)] = true --insert or rewrite key
	file.Write(path, info)
end)
