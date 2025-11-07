-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/args-debug.lua
-- from gmod.one with <3

-- it works like rendering throttle, this way you can push stuff in rendering stack eg in ENT:Think - no matter how much DrawDebugging will be called while some instance is alive

_G.DrawDebugging = {
	stack = {}
}

function DrawDebugging:Draw(hookName)
	local queue = self.stack[hookName]

	for i = #queue.list, 1, -1 do
		local item = queue.list[i]

		if item.ttl < CurTime() then
			table.remove(queue.list, i)
			queue.map[item.uid] = nil
			continue
		end

		item.draw()
	end
end

function DrawDebugging:Push(hookName, draw, extraUID)
	local info = debug.getinfo(1, "Sln")
	local uid = info.source .. ":" .. info.currentline

	-- eg you call RenderingDebug in loop, you can pass uid to make it render all stuff, not just a first call
	if extraUID then
		uid = uid .. ":" .. tostring(extraUID)
	end

	hookName = hookName or "2d"
	if self.stack[hookName] == nil then
		self.stack[hookName] = {
			list = {},
			map = {},
		}
	end

	if self.stack[hookName].map[uid] then return end

	self.stack[hookName].map[uid] = true
	table.insert(self.stack[hookName].list, {
		draw = draw,
		ttl = CurTime() + 1,
		uid = uid,
	})

	hook.Add(hookName, "DrawDebugging", function()
		self:Draw(hookName)
	end)
end

setmetatable(DrawDebugging, {
	__call = function(self, hookName, draw, extraUID)
		self:Push(hookName, draw, extraUID)
	end
})

--[[
for i = 1, 8 do
	DrawDebugging("HUDPaint", function() -- it should render only first green box
		if i % 2 == 0 then
			surface.SetDrawColor(255, 0, 0, 255)
		else
			surface.SetDrawColor(0, 255, 0, 255)
		end
		surface.DrawRect(32, 32 * i, 32, 32)
	end)

	DrawDebugging("HUDPaint", function() -- it should render all boxes, cuz we provided extraUID
		if i % 2 == 0 then
			surface.SetDrawColor(255, 0, 0, 255)
		else
			surface.SetDrawColor(0, 255, 0, 255)
		end
		surface.DrawRect(96, 32 * i, 32, 32)
	end, i)
end
]]--
