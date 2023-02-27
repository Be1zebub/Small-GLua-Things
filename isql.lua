local isql = {
	_NOTE 	 = "A async sql wrapper",
	_VERSION = 1.1,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/isql.lua",
	_LICENSE = [[
		MIT LICENSE
		Copyright (c) 2022 incredible-gmod.ru
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

isql.drivers = {
	sqlite = {
		query = function(_, query)
			local data = sql.Query(query)

			if data ~= false then
				return data, sql.Query("SELECT last_insert_rowid();")
			end

			return data
		end
	},
	mysqloo = {
		require = "mysqloo",
		query = function(self, query)
			local co = coroutine.running()

			local smt = self.db:query(query)
			smt:setOption(mysqloo.OPTION_NAMED_FIELDS)

			function smt:onSuccess(data)
				coroutine.resume(co, data, self:lastInsert())
			end

			function smt:onError(reason)
				ErrorNoHalt(string.format("sql Query Error!\nQuery: %s\n%s\n", query, reason))
				coroutine.resume(co, false, reason)
			end

			smt:start()
			return coroutine.yield()
		end,
		connect = function(self, credentials)
			self.db = self.driver.module.connect(credentials.host, credentials.user, credentials.pass, credentials.db, credentials.port)

			self.db.onConnected = function(db)
				local success, reason = db:setCharacterSet("utf8mb4")

				if success then
					self:Query(string.format("ALTER DATABASE `%s` CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci", credentials.db))
				else
					ErrorNoHalt("Failed to set sql encoding!\n")
					ErrorNoHalt(reason .."\n")
				end

				self.ready = true
				if self.OnConnected then
					self:OnConnected()
				end
			end

			self.db.onConnectionFailed = function(_, reason)
				ErrorNoHalt("Sql connection failed!\n")
				ErrorNoHalt(reason .."\n")

				if self.OnConnectionFailed then
					self:OnConnectionFailed(reason)
				end
			end

			self.db:connect()

			timer.Create(("sql.keepalive/%s/%s:%s-%b-%s"):format(util.CRC(debug.traceback()), credentials.host, credentials.port, credentials.user, credentials.db), 60, 0, function()
				self.db:ping()
			end)
		end
	},
	tmysql4 = {
		require = "tmysql4",
		query = function(self, query)
			local co = coroutine.running()

			self.db:Query(query, function(data)
				if data.status then
					coroutine.resume(co, data.data, data.lastid)
				else
					coroutine.resume(co, false, data.error)
				end
			end)

			return coroutine.yield()
		end,
		connect = function(self, credentials)
			local db, reason = self.driver.module.initialize(credentials.host, credentials.user, credentials.pass, credentials.db, credentials.port)

			if db then
				self:Query("SELECT 1;")

				if self.OnConnected then
					self:OnConnected()
				end
			else
				ErrorNoHalt("Sql connection failed!\n")
				ErrorNoHalt(reason .."\n")

				self.ready = true
				if self.OnConnectionFailed then
					self:OnConnectionFailed(reason)
				end
			end

			timer.Create(("sql.keepalive/%s/%s:%s-%b-%s"):format(util.CRC(debug.traceback()), credentials.host, credentials.port, credentials.user, credentials.db), 60, 0, function()
				self:Query("SELECT 1;")
			end)
		end
	}
}

local META = {}
META.__index = META

function META:Query(query, args)
	assert(self.driver, "Cant perform sql query! You should call sql:Init(driver, credentials) 1st!")

	if args then
		if isstring(args) then
			args = {args}
		end

		local i = 0
		query = query:gsub("%?", function()
			i = i + 1
			if isstring(args[i]) then
				return string.format("%q", args[i])
			else
				return args[i]
			end
		end)
	end

	self.driver:query(query)
end

function isql:New(driver, credentials, OnConnected, OnConnectionFailed)
	assert(driver and self.drivers[driver], "Invalid sql driver!")

	local instance = setmetatable({
		driver = self.drivers[driver],
		OnConnected = OnConnected,
		OnConnectionFailed = OnConnectionFailed
	}, META)

	if instance.driver.require then
		assert(util.IsBinaryModuleInstalled(instance.driver.require), instance.driver.require .." sql module isnt installed!")
		instance.driver.module = require(instance.driver.require)
	end

	if instance.driver.connect then
		instance.ready = false
		instance.driver:connect(credentials)
	else
		instance.ready = true
	end

	return instance
end

return setmetatable(isql, {
	__call = function(self, driver, credentials)
		return self:New(driver, credentials)
	end
})
