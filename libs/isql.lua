local isql = {
	_DESCRIPTION = "A async sql wrapper - an easy way to add mysql support to any addon in few minutes",
	_EXAMPLE = [[
		local db = isql("mysqloo", {
			host = "1.1.1.1",
			port = 3306,
			user = "johndoe",
			pass = "qwerty123",
			db   = "foobar"
		})

		function db:OnConnected()
			db:Query("CREATE TABLE IF NOT EXISTS `purchases` (`sid64` TEXT, `id` INTEGER);")
		end

		function db:OnConnectionFailed(reason)
			function PLAYER:FetchPurchases() return {} end
		end

		function PLAYER:FetchPurchases()
			return db:Query("SELECT `id` FROM `purchases` WHERE `sid64` = ?;", {self:SteamID64()})
		end
	]],
	_VERSION = 1.2,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/isql.lua",
	_LICENSE = [[
		MIT LICENSE
		Copyright (c) 2025 gmod.one
		Permission is hereby granted, free of charge, to any person obtaining a
		copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:
		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
		OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]]
}

local function OnConnectionFailed(me, reason, _credentials, _retry)
	ErrorNoHaltWithStack("Sql connection failed!\n".. reason .."\n")

	if _retry > 0 then
		me.driver.connect(me, _credentials, _retry - 1)
		return
	end

	me.connectionFailed = true

	if me.OnConnectionFailed then
		coroutine.wrap(me.OnConnectionFailed)(me, reason)
	else
		me.connectionFailReason = reason
	end
end

isql.drivers = {
	sqlite = {
		query = function(_, query, args)
			if args then
				if isstring(args) then
					args = {args}
				end

				local i = 0
				query = query:gsub("%?", function()
					i = i + 1

					if isstring(args[i]) then
						return sql.SQLStr(args[i])
					else
						return args[i]
					end
				end)
			end

			local data = sql.Query(query)

			if data ~= false then
				return data, sql.Query("SELECT last_insert_rowid();")
			end

			return data
		end,
		escape = function(_, str)
			return sql.SQLStr(str)
		end
	},
	mysqloo = {
		require = "mysqloo",
		global = "mysqloo",
		escape = function(self, str)
			return self.db:escape(str)
		end,
		_arg2setter = setmetatable({string = "setString", number = "setNumber", boolean = "setBoolean"}, {
			__index = function() return "setNull" end
		}),
		query = function(self, query, args)
			local co = coroutine.running()

			local smt = self.db[args and "prepare" or "query"](self.db, query)

			smt.onSuccess = co and function(this, data)
				coroutine.resume(co, data, this:lastInsert())
			end or nil

			function smt:onError(reason)
				ErrorNoHaltWithStack(string.format("sql Query Error!\nQuery: %s\n%s\n", query, reason))
				if co then coroutine.resume(co, false, reason) end
			end

			if args then
				for i, arg in ipairs(args) do
					smt[
						self.driver._arg2setter[type(arg)]
					](smt, i, arg)
				end
			end

			smt:start()

			if co then
				return coroutine.yield()
			end
		end,
		connect = function(self, credentials, _retry)
			_retry = _retry or 3
			self.db = self.module.connect(credentials.host, credentials.user, credentials.pass, credentials.db, credentials.port)

			self.db.onConnected = function(db)
				local success, reason = db:setCharacterSet("utf8mb4")

				if success then
					self:Query(string.format("ALTER DATABASE `%s` CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci", credentials.db))
				else
					ErrorNoHaltWithStack("Failed to set sql encoding!\n")
					ErrorNoHaltWithStack(reason .."\n")
				end

				self.connected = true
				if self.OnConnected then
					coroutine.wrap(self.OnConnected)(self)
				end

				for _, co in ipairs(self.queue) do
					if coroutine.status(co) == "suspended" then
						coroutine.resume(co)
					end
				end

				self.queue = {}
			end

			self.db.onConnectionFailed = function(_, reason)
				OnConnectionFailed(self, reason, credentials, _retry)
			end

			self.db:connect()

			timer.Create(("isql.keepalive/%s/%s:%s-%s-%s"):format(util.CRC(debug.traceback()), credentials.host, credentials.port, credentials.user, credentials.db), 60, 0, function()
				self.db:ping()
			end)
		end
	},
	tmysql4 = {
		require = "tmysql4",
		global = "tmysql",
		escape = function(self, str)
			return self.db:Escape(str)
		end,
		query = function(self, query, args)
			local co = coroutine.running()

			if args then
				local smt = self.db:Prepare(query)
				if co then
					table.insert(args, function(data)
						if data.status then
							coroutine.resume(co, data.data, data.lastid)
						else
							coroutine.resume(co, false, data.error)
						end
					end)
				end
				smt:Run(unpack(args))
			else
				self.db:Query(query, co and function(data)
					if data.status then
						coroutine.resume(co, data.data, data.lastid)
					else
						coroutine.resume(co, false, data.error)
					end
				end or nil)
			end

			if co then
				return coroutine.yield()
			end
		end,
		connect = function(self, credentials, _retry)
			_retry = _retry or 3
			local db, reason = self.module.initialize(credentials.host, credentials.user, credentials.pass, credentials.db, credentials.port)
			self.db = db

			if db then
				self:Query("SELECT 1;")

				self.connected = true
				if self.OnConnected then
					coroutine.wrap(self.OnConnected)(self)
				end

				for _, co in ipairs(self.queue) do
					if coroutine.status(co) == "suspended" then
						coroutine.resume(co)
					end
				end

				self.queue = {}
			else
				OnConnectionFailed(self, reason, credentials, _retry)
			end

			timer.Create(("isql.keepalive/%s/%s:%s-%s-%s"):format(util.CRC(debug.traceback()), credentials.host, credentials.port, credentials.user, credentials.db), 60, 0, function()
				self:Query("SELECT 1;")
			end)
		end
	}
}

local CONNECTION = {}
do
	function CONNECTION:Query(query, args)
		assert(self.driver, "Cant perform sql query! You should call isql:New(driver, credentials) 1st!")

		if self:IsConnected() == false and coroutine.running() then
			table.insert(self.queue, coroutine.running())
			coroutine.yield()
		end

		return self.driver.query(self, query, args)
	end

	function CONNECTION:Escape(str)
		return self.driver.escape(self, str)
	end

	function CONNECTION:IsConnected()
		return self.connected
	end
end
isql.connectionClass = CONNECTION

local __newindex
do
	local handleNewIndex = {}

	function handleNewIndex:OnConnected(cback)
		if self:IsConnected() == false then return end
		coroutine.wrap(cback)(self)
	end

	function handleNewIndex:OnConnectionFailed(cback)
		if self:IsConnected() or self.connectionFailed == false then return end
		coroutine.wrap(cback)(self, self.connectionFailReason)
	end

	function __newindex(me, k, v)
		local handle = handleNewIndex[k]
		if handle == nil then return end

		handle(me, v)
		rawset(me, k, v)
	end
end

function isql:New(driver, credentials)
	assert(driver and self.drivers[driver], "Invalid sql driver!")

	local instance = setmetatable({
		driver = self.drivers[driver],
		queue = {},
		connected = false,
		connectionFailed = false,
		connectionFailReason = nil
	}, {
		__index = CONNECTION,
		__newindex = __newindex
	})

	if instance.driver.require then
		assert(util.IsBinaryModuleInstalled(instance.driver.require), instance.driver.require .." sql module isnt installed!")
		instance.module = require(instance.driver.require) or _G[instance.driver.global]
	end

	if instance.driver.connect then
		instance.driver.connect(instance, credentials)
	else
		instance.connected = true
		if self.OnConnected then
			coroutine.wrap(self.OnConnected)(self)
		end
	end

	return instance
end

return setmetatable(isql, {
	__call = function(self, driver, credentials)
		return self:New(driver, credentials)
	end
})
