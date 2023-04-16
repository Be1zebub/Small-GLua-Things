-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/listmap.lua

local function ListMap()
	local instance, mt = newproxy(true), {MetaName = "listmap"}
	debug.setmetatable(instance, mt)
	local _list, _map, _len = {}, {}, 0

	function mt:__len()
		return _len
	end

	function mt:__index(k)
		return _map[k]
	end

	function mt:__newindex(k, v)
		if _map[k] then
			if v then
				_map[k].value = v
			else
				_list[ _map[k].index ] = nil
				_map[k] = nil
				_len = _len - 1
			end

			return
		end

		_len = _len + 1
		_map[k] = {
			value = v
		}
		_map[k].index = table.insert(_list, _map[k])
	end

	-- for __pairs / __ipairs support: https://github.com/Be1zebub/Small-GLua-Things/blob/master/meta-events5.2.lua

	function mt:__pairs()
		return pairs(_map)
	end

	function mt:__ipairs()
		return ipairs(_list)
	end

	return instance
end

--[[ test:
	local humans = player.GetAll()

	local players = ListMap()
	players[humans[1]:SteamID64()] = humans[1]
	players[humans[3]:SteamID64()] = humans[3]

	print(#players) -- 2
	PrintTable(players)
	players[humans[1]:SteamID64()] = nil
	print(#players) -- 1
	PrintTable(players)
]]--
