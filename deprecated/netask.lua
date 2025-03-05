-- The idea is to create a network wrapper
-- with an API in the style of dash netvar.

-- Imagine you need to write network code where the client asks the server "Give me the link to player A's avatar."
-- Usually, you'd go ahead and write net.Receive on the server side
-- and add net.Start on the client side.
-- You need to add rate limits, caching, and other things.
-- What you end up with is one big, unstructured mess of shitty code,
-- and you're writing the same code over and over, from project to project, feature to feature.
-- What if you just create a wrapper that does all the work for you – and you get an excellent structure for just a few lines of code?

-- Sounds great, the library helps to reduce the amount of network code by tens of times.
-- But I lost interest after developing the first version because I was unhappy with the result and also the poor project structure – which made the code hard to maintain.
-- This library could likely be a good solution with a more quality implementation.
-- Its AI era now, so maybe someday ill ask LLM to rewrite it for me.

--[[ usage examples:
	-- Client asks server
	NetAsk:Register("AvatarURL")
	:Cache(CLIENT) -- cache based on the ask arguments.
	:Cooldown(2) -- cooldown for client > server asks
	:Ask(CLIENT, net.WritePlayer) -- client ask
	:Answer(SERVER, function(ply, answer) -- server answer
		IncredibleAPI:Call("SteamAvatar", net.ReadPlayer(), SteamApiKey, function(avatar_url)
			answer(avatar_url)
		end)
	end, net.WriteString) -- function for response write
	:Read(CLIENT, net.ReadString) -- how client read answer from server

	if CLIENT then
		NetAsk._DEBUG = true -- turn on debugging to see how the cache works

		timer.Create("NetAsk/Debug/Cache+Cooldown", 0.5, 10, function()
			NetAsk("AvatarURL", function(avatar_url)
				print(avatar_url)
			end, LocalPlayer())
		end)
	end

	-- Server asks client

	NetAsk:Register("Screengrab")
	:Ask(SERVER, net.WriteUInt, 7) -- server asks
	:Answer(CLIENT, function(answer) -- client answer
		hook.Add("PostRender", "gmod.one/netask/screengrab", function()
			hook.Remove("PostRender", "gmod.one/netask/screengrab")

			local screenshoot = render.Capture({
				format = "jpeg",
				quality = net.ReadUInt(7),
				x = 0,
				y = 0,
				w = ScrW(),
				h = ScrH()
			})

			IncredibleAPI:Call("UploadImage", "https://x0.at/", screenshoot, function(img_id)
				answer(img_id)
			end, true)
		end)
	end, net.WriteString)
	:Read(SERVER, net.ReadString)

	NetAsk("Screengrab", Entity(1), function(img_id)
		for i, ply in ipairs(player.GetHumans()) do
			ply:SendLua('gui.OpenURL("https://x0.at/'.. img_id ..'.png")')
		end
	end, 100)

	-- Client asks server > Server asks target client

	NetAsk:Register("Screengrab")
	-- ask from server answer from client
	:Ask(SERVER, net.WriteUInt, 7) -- server asks
	:Answer(CLIENT, function(answer) -- client answer
		hook.Add("PostRender", "gmod.one/netask/screengrab", function()
			hook.Remove("PostRender", "gmod.one/netask/screengrab")

			local screenshoot = render.Capture({
				format = "jpeg",
				quality = net.ReadUInt(7),
				x = 0,
				y = 0,
				w = ScrW(),
				h = ScrH()
			})

			IncredibleAPI:Call("UploadImage", "https://x0.at/", screenshoot, function(img_id)
				answer(img_id)
			end, true)
		end)
	end, net.WriteString)
	:Read(CLIENT, net.ReadString) -- how client read answer from server
	-- ask from client answer from server
	:Ask(CLIENT, function(ply, quality) -- client (admin) asks server for another client screengrab
		net.WritePlayer(ply)
		net.WriteUInt(quality, 7)
	end)
	:Answer(SERVER, function(ply, answer)-- server answer
		NetAsk("Screengrab", net.ReadPlayer(), function(img_id) -- ask screengrab from target client
			answer(img_id)
		end, net.ReadUInt(7))
	end, net.WriteString)
	:CanAsk(SERVER, function(ply) -- can client ask server?
		return ply:IsAdmin()
	end)
	:Cooldown(5) -- cooldown for client > server asks
	:Read(SERVER, net.ReadString) -- how server read answer from client

	-- client
	NetAsk("Screengrab", function(img_id)
		gui.OpenURL("https://x0.at/".. img_id ..".png")
	end, LocalPlayer(), 100)
]]--

local NetAsk = {
	_VERSION = 1.0,
	_LICENSE = [[
		MIT LICENSE
		Copyright (c) 2021 gmod.one
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
	]],
	_DEBUG = false
}

local REALM = CLIENT and "CLIENT" or "SERVER"

local function debug(str)
	print("NetAsk DEBUG > ".. str .." - ".. REALM)
end

local function debug_tableToString(args)
	for i, v in ipairs(args) do
		args[i] = tostring(v)
	end

	return table.concat(args, ", ")
end

local function debug_varargToString(...)
	return debug_tableToString({...})
end

local CACHE = {}

local function cacheGet(node, args)
	for i = 1, #args do
		node = (node.child or {})[args[i]]
		if node == nil then return end
	end

	return node.results
end

local function cacheMake(node, args, results)
	local arg
	for i = 1, #args do
		arg = args[i]
		node.child = node.child or {}
		node.child[arg] = node.child[arg] or {}
		node = node.child[arg]
	end

	node.results = results
end

local MT = {}
MT.__index = MT

function MT:Cooldown(delay)
	delay = delay or 5

	if CLIENT then
		delay = delay + 0.2
		local nextAsk = 0

		self._Cooldown = function()
			if nextAsk > CurTime() then
				return true
			end

			nextAsk = CurTime() + delay

			return false
		end
	else
		local nextAsk = {}

		self:CanAsk(function(ply) -- check only asks from clientside
			local next = nextAsk[ply:SteamID64()]
			if next and next > CurTime() then
				return false
			end

			next = CurTime() + delay

			return true
		end)
	end

	return self
end

function MT:CanAsk(can)
	local old = self._CanAsk
	self._CanAsk = function(ply)
		if old and old(ply) == false then return false end

		return can(ply)
	end

	return self
end

function MT:Cache(realm)
	if realm then
		self._Cache = {}
	end

	return self
end

function MT:Read(realm, read, opts)
	if realm then
		self._Read = function()
			return read(opts)
		end
	end

	return self
end

function MT:Ask(realm, ask, opts)
	if not realm then return self end

	if SERVER then
		self._Ask = function(self, id, ply, ...)
			net.Start(self.NetString)
				net.WriteBool(true)
				net.WriteUInt(id, 32)
				if opts then
					ask(..., opts)
				else
					ask(...)
				end
			net.Send(ply)
		end
	else
		self._Ask = function(self, id, ...)
			net.Start(self.NetString)
				net.WriteBool(true)
				net.WriteUInt(id, 32)
				if opts then
					ask(..., opts)
				else
					ask(...)
				end
			net.SendToServer()
		end
	end

	return self
end

function MT:Answer(realm, answer, write, opts)
	if realm then
		self._Answer = {
			answer = answer,
			write = write,
			opts = opts
		}
	end

	return self
end

function MT:NewReceiver(cback, args, ply)
	if SERVER then
		local sid = ply:SteamID64()
		self.receivers[sid] = self.receivers[sid] or {}
		return table.insert(self.receivers[sid], {cback = cback, args = args})
	else
		return table.insert(self.receivers, {cback = cback, args = args})
	end
end

local function ReadAnswer(t, args, cback)
	if t._Cache then
		if NetAsk._DEBUG then debug(t.Name .." (cache make)") end

		local results = {t._Read()}

		cacheMake(t._Cache, args, results)

		cback(unpack(results))
	else
		if NetAsk._DEBUG then
			local answer = {t._Read()}
			debug(t.Name .." (answer result = ".. debug_tableToString(answer).. ")")
			cback(unpack(answer))
		else
			cback(t._Read())
		end
	end
end

local ReceiveAsk, ReceiveAnswer
if SERVER then
	ReceiveAsk = function(t, id, ply)
		if NetAsk._DEBUG then debug(t.Name .." (receive ask ".. id .." from ".. tostring(ply) ..")") end

		local AnswerObj = t._Answer
		if not AnswerObj then return end

		if t._CanAsk and t._CanAsk(ply) == false then return end

		AnswerObj.answer(ply, function(...)
			net.Start(t.NetString)
				net.WriteBool(false)
				net.WriteUInt(id, 32)
				AnswerObj.write(..., AnswerObj.opts)
			net.Send(ply)
		end)
	end

	ReceiveAnswer = function(t, id, ply)
		if NetAsk._DEBUG then debug(t.Name .." (receive answer ".. id .." from ".. tostring(ply) ..")") end

		local receivers = t.receivers[ply:SteamID64()]
		if not receivers then return end

		if NetAsk._DEBUG then debug(t.Name .." (receivers table found!)") end

		local data = receivers[id]
		if not data then return end

		if NetAsk._DEBUG then debug(t.Name .." (receiver found!)") end

		ReadAnswer(t, data.args, data.cback)
	end
else
	ReceiveAsk = function(t, id)
		if NetAsk._DEBUG then debug(t.Name .." (receive ask ".. id ..")") end

		local AnswerObj = t._Answer
		if not AnswerObj then return end

		AnswerObj.answer(function(...)
			net.Start(t.NetString)
				net.WriteBool(false)
				net.WriteUInt(id, 32)
				AnswerObj.write(..., AnswerObj.opts)
			net.SendToServer()
		end)
	end

	ReceiveAnswer = function(t, id)
		if NetAsk._DEBUG then debug(t.Name .." (receive answer ".. id ..")") end

		local data = t.receivers[id]
		if not data then return end

		if NetAsk._DEBUG then debug(t.Name .." (receiver found!)") end

		ReadAnswer(t, data.args, data.cback)
	end
end

NetAsk.list = {}

function NetAsk:Register(name)
	local t = {
		Name = name,
		NetString = "gmod.one/netask/".. name,
		receivers = {}
	}

	setmetatable(t, MT)
	self.list[name] = t

	if SERVER then
		util.AddNetworkString(t.NetString)
		net.Receive(t.NetString, function(_, ply)
			local isask, id = net.ReadBool(), net.ReadUInt(32)
			if isask then
				ReceiveAsk(t, id, ply)
			else
				ReceiveAnswer(t, id, ply)
			end
		end)
	else
		net.Receive(t.NetString, function()
			local isask, id = net.ReadBool(), net.ReadUInt(32)
			if isask then
				ReceiveAsk(t, id)
			else
				ReceiveAnswer(t, id)
			end
		end)
	end

	return t
end

function NetAsk:Get(name)
	return self.list[name]
end

local function GetAskCache(t, cback, args)
	if t._Cache then
		local cache = cacheGet(t._Cache, args)

		if cache then
			if NetAsk._DEBUG then debug(name .." (cache)") end
			cback(unpack(cache))
			return
		end

		return true
	end

	return false
end

if CLIENT then
	function NetAsk:Ask(name, cback, ...)
		local t = self:Get(name)
		if t == nil then return end

		local args = {...}
		if GetAskCache(t, cback, args) then return end

		if t._Cooldown and t._Cooldown() then
			self:AddQueueAsk(name, cback, args)
			return
		end

		if t._CanAsk and t._CanAsk(LocalPlayer()) == false then return end

		if self._DEBUG then
			debug(name .." (ask args = ".. debug_varargToString(...) ..")")
		end

		t._cback = cback
		local id = t:NewReceiver(cback, args)

		if self._DEBUG then
			debug(name .." (ask id = ".. id ..")")
		end

		t:_Ask(id, ...)
	end

	NetAsk.QueueAsk = {}
	function NetAsk:AddQueueAsk(name, cback, args)
		self.QueueAsk[name] = self.QueueAsk[name] or {}
		table.insert(self.QueueAsk[name], {
			cback = cback,
			args = args
		})
	end

	hook.Add("Think", "gmod.one/NetAsk/AskQueue", function()
		for name, asks in pairs(NetAsk.QueueAsk) do
			local t = NetAsk:Get(name)
			if t == nil then
				NetAsk.QueueAsk[name] = nil
				continue
			end

			local k, ask = next(asks)
			if k == nil then
				NetAsk.QueueAsk[name] = nil
				continue
			end

			if t._Cooldown() then continue end

			NetAsk:Ask(name, ask.cback, unpack(ask.args))
			asks[k] = nil
		end
	end)
else
	function NetAsk:Ask(name, ply, cback, ...)
		local t = self:Get(name)
		if t == nil then return end

		local args = {...}
		if GetAskCache(t, cback, args) then return end

		if self._DEBUG then
			debug(name .." (ask from ".. ply:Nick() .."(".. ply:SteamID64() ..") args = ".. debug_varargToString(...) ..")")
		end

		t._cback = cback
		local id = t:NewReceiver(cback, args, ply)

		if self._DEBUG then
			debug(name .." (ask id = ".. id ..")")
		end

		t:_Ask(id, ply, ...)
	end
end

function NetAsk:CanAsk(name, ply)
	local t = self:Get(name)
	if t == nil then return false end

	if CLIENT then
		ply = LocalPlayer()
	end
	if IsValid(ply) == false then return false end

	return t:_CanAsk(ply) ~= false
end

setmetatable(NetAsk, {
	__call = function(self, name, cback, ...)
		return self:Ask(name, cback, ...)
	end
})

--_G.NetAsk = NetAsk
return NetAsk
