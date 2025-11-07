-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/args-debug.lua
-- from gmod.one with <3

-- it works like rendering throttle, this way you can push stuff in rendering stack eg in ENT:Think - no matter how much RenderingDebug will be called while some instance is alive

local queue = {list = {}, map = {}}

function RenderingDebug(drawStuff, extraUID)
	local info = debug.getinfo(1, "Sln")
	local uid = info.source .. ":" .. info.currentline

	if extraUID then -- eg you call RenderingDebug in loop, you can pass uid to make it render all stuff, not just a first call
		uid = uid .. ":" .. tostring(extraUID)
	end

	if queue.map[uid] then return end

	queue.map[uid] = true
	table.insert(queue.list, {
		drawStuff = drawStuff,
		ttl = CurTime() + 1,
		uid = uid
	})
end

hook.Add("HUDPaint", "RenderingDebug", function()
	for i = #queue.list, 1, -1 do
		local item = queue.list[i]

		if item.ttl < CurTime() then
			table.remove(queue.list, i)
			queue.map[item.uid] = nil
			continue
		end

		item.drawStuff()
	end
end)

for i = 1, 8 do
	RenderingDebug(function() -- it should render only first green box
		if i % 2 == 0 then
			surface.SetDrawColor(255, 0, 0, 255)
		else
			surface.SetDrawColor(0, 255, 0, 255)
		end
		surface.DrawRect(32, 32 * i, 32, 32)
	end)

	RenderingDebug(function() -- it should render all boxes, cuz we provided extraUID
		if i % 2 == 0 then
			surface.SetDrawColor(255, 0, 0, 255)
		else
			surface.SetDrawColor(0, 255, 0, 255)
		end
		surface.DrawRect(96, 32 * i, 32, 32)
	end, i)
end
