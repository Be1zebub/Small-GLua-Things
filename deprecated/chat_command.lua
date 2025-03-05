-- chat (or console) commands wrapper
-- iirc unfinished & never tested

-- at first glance, this library seems unfinished, and some of the stylistic practices used are bad, so im not going to touch it anyway.

-- idea was great, but huh - its easier for me to code a new one from scratch, then refine this one.

local command = {}

do
	command.__index = command

	function command:SetCooldown(delay)
		self.Cooldown = delay
	end

	function command:GetCooldown()
		return self.Cooldown
	end

	function command:TestCooldown(uid)
		if self.Cooldown == nil then return false end
		if (self.cooldown[uid] or 0) > CurTime() then return true, math.Round(self.cooldown[uid] - CurTime(), 1) end

		self.cooldown[uid] = CurTime() + self.Cooldown
		return false
	end

	function command:SetSilent(bool)
		self.Silent = bool
	end

	function command:IsSilent()
		return self.Silent == true
	end

	function command:SetArgParser(index, parse)
		self.parse[index] = parse
	end

	function command:ParseArg(index, arg)
		if self.parse[index] then
			return self.parse[index](arg)
		end

		return arg
	end

	function command:Init()
		self.cooldown = {}
		self.silent = true
	end
end

local commands = {list = {}, map = {}}

do
	local meta = {}
	meta.__index = meta

	function meta:Add(name, cback)
		if self.map[name] then
			self.map[name].cback = cback
			return
		end

		local instance = setmetatable({cback = cback}, command)
		instance:Init()
		instance.index = table.insert(self.list, instance)
		self.map[name] = instance
		return instance
	end

	function meta:Remove(name)
		if self.map[name] then
			table.remove(self.list, self.map[name].index)
			self.map[name] = nil

			for i, cmd in ipairs(self.list) do
				cmd.index = i
			end
		end
	end

	function meta:Exists(name)
		return self:Get(name) ~= nil
	end

	function meta:Get(name)
		return name and self.map[name]
	end

	function meta:Run(ply, msg)
		local parse = msg:gmatch("(%s?[%S]+)")
		local cmd = self:Get(parse())
		if cmd == nil then return end

		local iscooldown, cooldown = cmd:TestCooldown(ply)
		if iscooldown then
			return cmd:IsSilent(), "Command use fail. Reason: cooldown ".. cooldown
		end

		local args = {}
		while true do
			local arg = parse()
			if arg == nil then break end

			arg = cmd:ParseArg(#args + 1, arg)
			args[#args + 1] = arg
		end

		return cmd:IsSilent(), cmd.cback(ply, args, cmd:ParseArg(0, msg:sub(#cmd_str + 2)))
	end

	function meta:Listen(identifier)
		if identifier == nil then
			identifier = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/commands.lua/".. util.CRC(debug.traceback())
		end

		hook.Add("PlayerSay", identifier, function(ply, msg)
			local silent, reply = self:Run(ply, msg)
			if reply then ply:ChatPrint(reply) end
			if silent ~= nil then
				return silent
			end
		end)

		return function()
			hook.Remove("PlayerSay", identifier)
		end
	end

	setmetatable(commands, meta)
end

return commands
