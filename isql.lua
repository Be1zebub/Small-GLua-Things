local isql = {
	_NOTE 	 = "A async sql wrapper - a easy way to add mysql support to any addon in few minutes",
	_EXAMPLE = [[
		local db = isql("mysqloo", {
			host = "1.1.1.1",
			port = 3306,
			user = "johndoe",
			pass = "qwerty123",
			db   = "foobar"
		})

		db:Query("CREATE TABLE IF NOT EXISTS `purchases` (`sid64` TEXT, `id` INTEGER);")

		function PLAYER:FetchPurchases()
			return db:Query("SELECT `id` FROM `purchases` WHERE `sid64` = ?;", self:SteamID64())
		end
	]],
	_VERSION = 1.2,
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
						self._arg2setter[type(arg)]
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

				self.ready = true
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
				ErrorNoHaltWithStack("Sql connection failed!\n".. reason .."\n")

				if _retry > 0 then self.driver.connect(self, credentials, _retry - 1) end

				if self.OnConnectionFailed then
					coroutine.wrap(self.OnConnectionFailed)(self, reason)
				end
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

				self.ready = true
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
				ErrorNoHaltWithStack("Sql connection failed!\n".. reason .."\n")

				if _retry > 0 then self.driver.connect(self, credentials, _retry - 1) end

				if self.OnConnectionFailed then
					coroutine.wrap(self.OnConnectionFailed)(self, reason)
				end
			end

			timer.Create(("isql.keepalive/%s/%s:%s-%s-%s"):format(util.CRC(debug.traceback()), credentials.host, credentials.port, credentials.user, credentials.db), 60, 0, function()
				self:Query("SELECT 1;")
			end)
		end
	}
}

local META = {}
META.__index = META

function META:Query(query, args)
	assert(self.driver, "Cant perform sql query! You should call isql:New(driver, credentials, OnConnected, OnConnectionFailed) 1st!")

	if self.ready == false and coroutine.running() then
		table.insert(self.queue, coroutine.running())
		coroutine.yield()
	end

	return self.driver.query(self, query, args)
end

function META:Escape(str)
	return self.driver.escape(self, str)
end

function isql:New(driver, credentials, OnConnected, OnConnectionFailed)
	assert(driver and self.drivers[driver], "Invalid sql driver!")

	local instance = setmetatable({
		driver = self.drivers[driver],
		OnConnected = OnConnected,
		OnConnectionFailed = OnConnectionFailed,
		queue = {}
	}, META)

	if instance.driver.require then
		assert(util.IsBinaryModuleInstalled(instance.driver.require), instance.driver.require .." sql module isnt installed!")
		instance.module = require(instance.driver.require) or _G[instance.driver.global]
	end

	if instance.driver.connect then
		instance.ready = false
		instance.driver.connect(instance, credentials)
	else
		instance.ready = true
		if self.OnConnected then
			coroutine.wrap(self.OnConnected)(self)
		end
	end

	return instance
end

if util.IsBinaryModuleInstalled == nil then -- util.IsBinaryModuleInstalled still doesnt merged :(
	-- src: https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/extensions/util.lua#L369-L397

	--[[---------------------------------------------------------
		Name: IsBinaryModuleInstalled( name )
		Desc: Returns whether a binary module with the given name is present on disk
	-----------------------------------------------------------]]
	local suffix = ({"osx64","osx","linux64","linux","win64","win32"})[
		( system.IsWindows() && 4 || 0 )
		+ ( system.IsLinux() && 2 || 0 )
		+ ( jit.arch == "x86" && 1 || 0 )
		+ 1
	]
	local fmt = "lua/bin/gm" .. (CLIENT && "cl" || "sv") .. "_%s_%s.dll"
	function util.IsBinaryModuleInstalled( name )
		if ( !isstring( name ) ) then
			error( "bad argument #1 to 'IsBinaryModuleInstalled' (string expected, got " .. type( name ) .. ")" )
		elseif ( #name == 0 ) then
			error( "bad argument #1 to 'IsBinaryModuleInstalled' (string cannot be empty)" )
		end

		if ( file.Exists( string.format( fmt, name, suffix ), "GAME" ) ) then
			return true
		end

		-- Edge case - on Linux 32-bit x86-64 branch, linux32 is also supported as a suffix
		if ( jit.versionnum != 20004 && jit.arch == "x86" && system.IsLinux() ) then
			return file.Exists( string.format( fmt, name, "linux32" ), "GAME" )
		end

		return false
	end
end

return setmetatable(isql, {
	__call = function(self, driver, credentials, OnConnected, OnConnectionFailed)
		return self:New(driver, credentials, OnConnected, OnConnectionFailed)
	end
})
