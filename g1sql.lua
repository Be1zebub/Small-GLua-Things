-- g1sql

-- simple sync style mysqloo driver
-- designed to use in coroutines, fk callbacks
-- support prepared statements, transactions, sqlite sql.Query* style

assert(util.IsBinaryModuleInstalled("mysqloo"), "mysqloo modules isnt installed! get it from https://github.com/FredyH/MySQLOO")
require("mysqloo")

local db = {}

function db:IsConnected()
	if not self.conn then return false end
	return self.conn:status() == mysqloo.DATABASE_CONNECTED
end

function db:Connect(creds)
	local co = coroutine.running()

	self.conn = mysqloo.connect(
		creds.host,
		creds.user,
		creds.pw,
		creds.db,
		creds.port or 3306
	)

	self.conn.onConnected = function()
		if self.OnConnected then self:OnConnected() end
		if co then coroutine.resume(co, true) end
	end

	self.conn.onConnectionFailed = function()
		if self.OnConnectionFailed then self:OnConnectionFailed() end
		if co then coroutine.resume(co, false) end
	end

	self.conn:connect()

	if co then
		return coroutine.yield()
	end
end

-----

local type2setter = setmetatable({
	string = "setString",
	number = "setNumber",
	boolean = "setBoolean"
}, {
	__index = function() return "setNull" end
})

local function MakeSMT(conn, query, params)
	local method = conn[params and "prepare" or "query"]
	local smt = method(conn, query)

	if params then
		for i, arg in ipairs(params) do
			local setter = smt[
				type2setter[type(arg)]
			]

			setter(smt, i, arg)
		end
	end

	return smt
end

-----

function db._Query(conn, query, params)
	local co = coroutine.running()
	local smt = MakeSMT(conn, query, params)

	smt.onSuccess = co and function(this, rows)
		coroutine.resume(co, rows, this:lastInsert(), this)
	end
	smt.onError = function(_, reason, sql)
		ErrorNoHaltWithStack(string.format("mysqloo:Query Error!\nreason: %s\nquery: %s\n", reason, sql))
		if co then coroutine.resume(co, false, reason) end
	end

	smt:start()

	if co then
		return coroutine.yield()
	end
end

function db:Query(query, params)
	return self._Query(self.conn, query, params)
end

-----

function db._QueryRow(conn, query, params, row)
	local rows = db._Query(conn, query, params)
	return rows[row or 1]
end

function db:QueryRow(query, params, row)
	return self:_QueryRow(self.conn, query, params, row)
end

-----

function db._QueryValue(conn, query, params)
	local row = db._QueryRow(conn, query, params)
	return select(2, next(row))
end

function db:QueryValue(query, params)
	return self._QueryValue(self.conn, query, params)
end

-----

local Transaction = {}

function Transaction:Push(query, params)
	local smt = MakeSMT(self._conn, query, params)
	self.transaction:addQuery(smt)
	return self
end

function Transaction:Run()
	local co = coroutine.running()

	self._transaction.onSuccess = co and function()
		coroutine.resume(co, true)
	end
	self._transaction.onError = co and function(_, reason)
		ErrorNoHaltWithStack(string.format("transaction Error!\nreason: %s\n", reason))
		coroutine.resume(co, false, reason)
	end
	self._transaction:start()

	if co then
		return coroutine.yield()
	end
end

function db:Transaction()
	return setmetatable({
		_conn = self.conn,
		_transaction = self.conn:createTransaction()
	}, {__index = Transaction})
end

return function(creds)
	local _db = setmetatable({}, {__index = db})
	if creds then _db:Connect(creds)
	return _db
end
