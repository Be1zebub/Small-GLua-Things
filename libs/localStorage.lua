-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/localStorage.lua

-- js localStorage port with extended features.
-- see unit tests at EOF for examples.

sql.Query("CREATE TABLE IF NOT EXISTS `localStorage` (`key` TEXT PRIMARY KEY, `value` TEXT)")

local db = {cache = {}, initializedCache = {}}
local unitTestsReserve = {
	keys = {
		___unitTestString = true,
		___unitTestNumber = true,
		___unitTestTable = true
	},
	enable = true
}

function db:Get(key, decoder)
	key = tostring(key)

	if unitTestsReserve.enable and unitTestsReserve.keys[key] then
		ErrorNoHalt("localStorage key \"" .. key .. "\" is reserved for unit tests, sorry you can't use it.\n")
		return
	end

	if self.initializedCache[key] == nil then
		local value = sql.QueryValue("SELECT `value` FROM `localStorage` WHERE `key` = " .. sql.SQLStr(key) .. ";")

		if decoder and value then
			value = decoder(value)
		end

		self.initializedCache[key] = true
		self.cache[key] = value
	end

	return self.cache[key]
end

function db:Set(key, value, encoder)
	key = tostring(key)

	if unitTestsReserve.enable and unitTestsReserve.keys[key] then
		ErrorNoHalt("localStorage key \"" .. key .. "\" is reserved for unit tests, sorry you can't use it.\n")
		return
	end

	if value == nil then
		sql.Query("DELETE FROM `localStorage` WHERE `key` = " .. sql.SQLStr(key) .. ";")
	else
		encoder = encoder or tostring
		value = encoder(value)

		sql.Query("REPLACE INTO `localStorage` (`key`, `value`) VALUES (" .. sql.SQLStr(key) .. ", " .. sql.SQLStr(value) .. ");")
	end

	self.cache[key] = value
end

function db:Clear()
	self.cache = {}
	self.initializedCache = {}

	sql.Query("DELETE FROM `localStorage`; VACUUM;")
end

_G.localStorage = setmetatable({
	setItem = function(key, value, encoder)
		db:Set(key, value, encoder)
	end,
	getItem = function(key, decoder)
		return db:Get(key, decoder)
	end,
	removeItem = function(key)
		db:Set(key, nil)
	end,
	clear = function()
		db:Clear()
	end,
}, {
	__newindex = function(_, key, value) -- syntax sugar, its like setItem, but doesn't support encoder (always encodes value to string datatype)
		db:Set(key, value)
	end,
	__index = function(_, key) -- syntax sugar, its like getItem, but doesn't support decoder (always returns string datatype)
		return db:Get(key)
	end
})

-- unit tests
unitTestsReserve.enable = false

do  -- test random datatype key will work
	local testKey = function() end

	localStorage[testKey] = "0"
	assert(localStorage[testKey] == "0", "testKey should be 0")

	localStorage[testKey] = nil
	assert(localStorage[testKey] == nil, "testKey should be nil")
end

do -- basic test string key
	localStorage.___unitTestString = nil
	assert(localStorage.___unitTestString == nil, "testString value should be nil")

	localStorage.___unitTestString = 1
	assert(localStorage.___unitTestString == "1", "testString should be string 1")

	localStorage.___unitTestString = nil
end

do -- test encoding/decoding
	localStorage.setItem("___unitTestNumber", 1, tonumber)
	assert(isnumber(localStorage.getItem("___unitTestNumber", tonumber)), "testNumber should be number")

	localStorage.___unitTestNumber = nil
	assert(localStorage.___unitTestNumber == nil, "testNumber should be nil")
end

do -- test advanced encoding/decoding
	localStorage.setItem("___unitTestTable", {john = "doe"}, util.TableToJSON)
	assert(localStorage.getItem("___unitTestTable", util.JSONToTable).john == "doe", "testTable.john should be doe")

	localStorage.___unitTestTable = nil
end

unitTestsReserve.enable = true
(function() -- test reserved keys are not allowed to use
	local succ = pcall(localStorage.setItem, "___unitTestTable", "test")
	assert(succ == false, "setItem should fail for reserved key")
end)()
