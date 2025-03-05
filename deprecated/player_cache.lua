-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/deprecated/player_cache.lua

-- probably never tested (idunno)
-- but just in case, im putting it in deprecated ¯\_(ツ)_/¯

local count, all, humans, bots = 0, {}, {}, {}

player.cache = {}

do -- getters
	function player.cache.GetCount()
		return count
	end

	function player.cache.GetAll()
		return all
	end

	function player.cache.GetHumans()
		return humans
	end

	function player.cache.GetBots()
		return bots
	end
end

do -- iterators
	-- usage: for i, ply in player.cache.IteratorHumans() do print(i, ply) end

	local iterator = ipairs(all)

	function player.cache.IteratorAll()
		return iterator, all, 0
	end

	local iterator_humans = ipairs(humans)

	function player.cache.IteratorHumans()
		return iterator_humans, humans, 0
	end

	local iterator_bots = ipairs(bots)

	function player.cache.IteratorBots()
		return iterator_bots, bots, 0
	end
end

do
	local map = {}

	local function Initialize(ply)
		count = count + 1

		local mapping = {}

		mapping.all = table.insert(all, ply)
		if ply:IsBot() then
			mapping.bots = table.insert(bots, ply)
		else
			mapping.humans = table.insert(humans, ply)
		end

		map[ply] = mapping
	end

	for _, ply in ipairs(player.GetAll()) do
		Initialize(ply)
	end

	hook.Add("OnEntityCreated", "player.cache.*", function(ply)
		if ply:IsPlayer() then
			Initialize(ply)
		end
	end)

	local iter = {
		all = player.cache.IteratorAll,
		humans = player.cache.IteratorHumans,
		bots = player.cache.IteratorBots
	}

	local function Remove(name, cache, index)
		table.remove(cache, index)

		for i, ply in iter[name]() do
			map[ply][name] = i
		end
	end

	hook.Add("EntityRemoved", "player.cache.*", function(ply)
		if ply:IsPlayer() and map[ply] then
			count = count - 1

			local mapping = map[ply]

			Remove("all", all, mapping.all)

			if mapping.bots then
				Remove("bots", bots, mapping.bots)
			else
				Remove("humans", humans, mapping.humans)
			end
		end
	end)
end
