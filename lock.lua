-- lock queue mechanism

local function example()
    local lock = require("lock")
    local queue = lock()

    function http.request(params, cback)
        params.failed = function(reason)
            if cback then cback(false, {reason = reason}) end
            queue:unlock()
        end

        params.success = function(code, body, headers)
            if (headers["Content-Type"] or ""):find("application/json") then
                body = json.decode(body)
            end

            if cback then cback(true, {code = code, body = body, headers = headers}) end
            queue:unlock()
        end

        if queue.locked then
            queue:push(HTTP, params)
        else
            queue:lock()
            queue:push(HTTP, params)
        end
    end

    -- it will perform http request & lock queue
    http.request({
        method = "POST",
        url = "https://mysite.com/login",
        body = base64.encode("login:password")
    }, function(succ, response)
        print("Login", succ)
        PrintTable(response)
    end)

    -- it will push request to queue
    -- when previous request is completed, it will unlock queue & perform next request (this)
    http.request({
        method = "GET",
        url = "https://mysite.com/@me?format=json"
    }, function(succ, response)
        print("@me", succ)
        PrintTable(response)
    end)
end
example = nil

local lock = {}

function lock:lock()
    self.locked = true
end

function lock:unlock()
    self.locked = false
    if #self == 0 then return end

    local args = {table.remove(self, 1)}
    local func = table.remove(args, 1)

    func(unpack(args))
end

function lock:push(func, ...)
    table.insert(self, {func, ...})
end

return function()
	return setmetatable({locked = false}, {__index = lock})
end
