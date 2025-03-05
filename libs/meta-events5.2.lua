-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/meta-events5.2.lua
-- __len, __pairs, __ipairs meta table events support for lua 5.1 (this meta-events added in 5.2)

if tonumber((_VERSION:gsub("Lua ", ""))) < 5.2 and not lua52_meta_events_compat then
	lua52_meta_events_compat = true

	local __pairs = pairs
	function pairs(tbl)
		local mt = getmetatable(tbl)
		if mt and mt.__pairs then
			return mt:__pairs()
		else
			return __pairs(tbl)
		end
	end

	local __ipairs = ipairs
	function ipairs(tbl)
		local mt = getmetatable(tbl)
		if mt and mt.__ipairs then
			return mt:__ipairs()
		else
			return __ipairs(tbl)
		end
	end
end

-- to add __len support, make your instances with newproxy(true)
--[[ Example:
	local class = {}

	function class:__len()
		return 123
	end

	function class:new()
		local instance = newproxy(true)
		debug.setmetatable(instance, self)
		return instance
	end

	local instance = class:new()
	print(#instance)
]]--
-- Usage example: https://github.com/Be1zebub/Small-GLua-Things/blob/master/nwtable.lua
