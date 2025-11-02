-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/localStorage.lua

-- js localStorage inspired, extended features included.
-- see unit tests for examples.

local unitTestsReserve = {
	__unitTestString = true,
	__unitTestNumber = true,
	__unitTestTable = true
}

local DB = {} -- database driver

function DB:New(parent, name)
	name = "local-storage/" .. name

	sql.Query("CREATE TABLE IF NOT EXISTS `" .. name .. "` (`key` TEXT PRIMARY KEY, `value` TEXT)")

	return setmetatable({
		parent = parent,
		name = name,
		cache = {},
		initializedCache = {},
		queries = {
			get = "SELECT `value` FROM `" .. name .. "` WHERE `key` = %s;",
			set = "REPLACE INTO `" .. name .. "` (`key`, `value`) VALUES (%s, %s);",
			delete = "DELETE FROM `" .. name .. "` WHERE `key` = %s;",
			clear = "DELETE FROM `" .. name .. "`; VACUUM;",
		},
		runningUnitTests = false
	}, {__index = DB})
end


function DB:RunUnitTests()
	self.runningUnitTests = true -- allow using reserved keys for unit tests, regular usage of this keys is blocked.

	local localStorage = self.parent -- its basically the localStorage instance, you make it like this myAddon.storage = lib.localStorage("myAddon")

	do  -- test random datatype key will work (syntax sugar will make tostring for keys)
		local testKey = function() end

		localStorage[testKey] = "0"
		assert(localStorage[testKey] == "0", "testKey should be 0")

		localStorage[testKey] = nil
		assert(localStorage[testKey] == nil, "testKey should be nil")
	end

	do -- basic test string key (syntax sugar will make tostring for keys)
		localStorage.__unitTestString = nil
		assert(localStorage.__unitTestString == nil, "testString value should be nil")

		localStorage.__unitTestString = 1
		assert(localStorage.__unitTestString == "1", "testString should be string 1")

		localStorage.__unitTestString = nil
	end

	do -- test encoding/decoding (if string datatype is not enough, use :Set/:Get with encoder/decoder instead of syntax sugar)
		localStorage:Set("__unitTestNumber", 1, tonumber)
		assert(isnumber(localStorage:Get("__unitTestNumber", tonumber)), "testNumber should be number")

		localStorage.__unitTestNumber = nil
		assert(localStorage.__unitTestNumber == nil, "testNumber should be nil")
	end

	do -- test advanced encoding/decoding (same, but lets try a complex encoder/decoder to make sure everything works good)
		localStorage:Set("__unitTestTable", {john = "doe"}, util.TableToJSON)
		assert(localStorage:Get("__unitTestTable", util.JSONToTable).john == "doe", "testTable.john should be doe")

		localStorage.__unitTestTable = nil
	end

	self.runningUnitTests = false

	(function() -- test if reserved keys are not allowed to use (this keys are allowed to use only when unit tests are running, runningUnitTests thing)
		local succ = pcall(localStorage.Set, localStorage, "__unitTestTable", "test")
		assert(succ == false, "localStorage:Set should fail for reserved key! Unit tests are broken")
	end)()
end

function DB:ValidateKey(key)
	local originalKey = tostring(key)

	key = originalKey:gsub("`", "``"):gsub("[%c]", "") -- escape backticks & remove control characters
	assert(#key > 0, "localStorage key `" .. originalKey .. "` is empty or contains only control characters!")

	if self.runningUnitTests ~= true and unitTestsReserve[key] then
		error("localStorage key `" .. key .. "` is reserved for unit tests, sorry you can't use it.")
		return
	end

	return key
end

function DB:Get(key, decoder)
	key = self:ValidateKey(key)

	if self.initializedCache[key] == nil then
		local value = sql.QueryValue(self.queries.get:format(sql.SQLStr(key)))

		if decoder and value then
			value = decoder(value)
		end

		self.initializedCache[key] = true
		self.cache[key] = value
	end

	return self.cache[key]
end


function DB:Set(key, value, encoder)
	key = self:ValidateKey(key)

	if value == nil then
		sql.Query(self.queries.delete:format(sql.SQLStr(key)))
	else
		encoder = encoder or tostring
		value = encoder(value)

		sql.Query(self.queries.set:format(sql.SQLStr(key), sql.SQLStr(value)))
	end

	self.cache[key] = value
end

function DB:Clear()
	self.cache = {}
	self.initializedCache = {}

	sql.Query(self.queries.clear)
end

----------------------

local STORAGE = {} -- local storage driver

function STORAGE:New(name)
	local instance = {
		name = name,
		db = nil,
	}

	local db = DB:New(instance, name)
	instance.db = db

	setmetatable(instance, {
		__newindex = function(me, key, value)
			me:Set(key, value, nil)
		end,
		__index = function(me, key)
			return STORAGE[key] or me:Get(key, nil)
		end
	})

	db:RunUnitTests()

	return instance
end

function STORAGE:Set(key, value, encoder)
	self.db:Set(key, value, encoder)
end

function STORAGE:Get(key, decoder)
	return self.db:Get(key, decoder)
end

function STORAGE:Clear()
	self.db:Clear()
end

local globalStorage = nil
local lib = {
	localStorage = function(name) -- use this in most cases
		assert(isstring(name), "localStorage name must be a string")
		assert(name ~= "__globalStorage", "localStorage name cant be a __globalStorage, it's reserved")

		local originalKey = name
		name = name:gsub("`", "``"):gsub("[%c]", "") -- escape backticks & remove control characters
		assert(#name > 0, "localStorage name `" .. originalKey .. "` is empty or contains only control characters!")

		return STORAGE:New(name)
	end,
	globalStorage = function() -- meh, idk why someone would need this, but at least you got a free cache -_-
		if globalStorage == nil then
			globalStorage = STORAGE:New("__globalStorage")
		end

		return globalStorage
	end
}

return setmetatable(lib, {  -- prevent modifying lib table
	__index = function(_, key)
		return lib[key]
	end,
	__newindex = function()
		error("Nope, you can't modify localStorageLib table, it's read only.")
	end
})
