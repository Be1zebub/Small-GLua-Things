-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/listmap.lua
-- check unit test for details

-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/meta-events5.2.lua
-- required for __pairs / __ipairs support!

local function ListMap()
	local instance, mt = newproxy(true), {MetaName = "ListMap"}
	debug.setmetatable(instance, mt)

	local _list, _map, _len = {}, {}, 0

	function mt:__len() -- supported by userdata in 5.1
		return _len
	end

	local internal = {
		_mapInternal = _map,
		_listInternal = _list
	}

	function mt:__index(k)
		return internal[k] or (_map[k] or {}).value
	end

	function mt:__newindex(k, v)
		if _map[k] then
			if v == nil then
				_list[ _map[k].index ] = nil
				_map[k] = nil
				_len = _len - 1
			else
				_map[k].value = v
			end

			return
		end

		_len = _len + 1
		_map[k] = {
			value = v,
			key = k
		}
		_map[k].index = table.insert(_list, _map[k])
	end

	function mt:__pairs() -- 5.2 meta-events support required!
		local index, data = 0

		return function()
			index = index + 1
			data = _list[index]

			if data == nil then return nil end

			return data.key, data.value
		end
	end

	function mt:__ipairs() -- 5.2 meta-events support required!
		local index, data = 0

		return function()
			index = index + 1
			data = _list[index]

			if data == nil then return nil end

			return index, data.value
		end
	end

	return instance
end

local makeTest = true

if makeTest then
	local function compare(a, b)
		if type(a) ~= type(b) then
			return false
		end

		if istable(a) == false then
			return a == b
		end

		local lenA = 0
		local lenB = 0

		for k, v in pairs(a) do
			lenA = lenA + 1

			if compare(v, b[k]) == false then
				return false
			end
		end

		for k, v in pairs(b) do
			lenB = lenB + 1
		end

		return lenA == lenB
	end

	local function assertEqual(reason, a, b)
		if compare(a, b) == false then
			error("ListMap unit-test error! reason: " .. reason)
		end
	end

	local test = ListMap()
	test["one"] = "1"
	test["two"] = "01"
	test["three"] = "001"

	assertEqual("__len", #test, 3)
	assertEqual("__index", test["two"], "01")

	local ipairs_data = {}
	for i, v in ipairs(test) do ipairs_data[i] = v end
	assertEqual("__ipairs", ipairs_data, {
		[1] = "1",
		[2] = "01",
		[3] = "001"
	})

	local pairs_data = {}
	for k, v in pairs(test) do pairs_data[k] = v end
	assertEqual("__pairs", pairs_data, {
		["one"] = "1",
		["two"] = "01",
		["three"] = "001"
	})

	assertEqual("_mapInternal", test._mapInternal, {
		one = {
			index = 1,
			key = "one",
			value = "1"
		},
		three = {
			index = 3,
			key = "three",
			value = "001"
		},
		two = {
			index = 2,
			key = "two",
			value = "01"
		},
	})

	assertEqual("_listInternal", test._listInternal, {
		[1] = {
			index = 1,
			key = "one",
			value = "1"
		},
		[2] = {
			index = 2,
			key = "two",
			value = "01"
		},
		[3] = {
			index = 3,
			key = "three",
			value = "001"
		}
	})
end
