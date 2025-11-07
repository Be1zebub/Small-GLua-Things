-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/args-debug.lua
-- from gmod.one with <3

-- sometimes you need to detour debug stuff to findout whats happening atm
-- eg smth rendering "Hello JohnDoe" on your screen, but you cant find which code do this
-- you can attach this tiny debugger to your detour & it will capture unique calls

local function debugArguments(duration, onFinish, argumentsFilter)
	local logs = {
		list = {},
		map = {}
	}

	timer.Simple(duration, function()
		PrintTable(logs.list)
		onFinish()
	end)

	if argumentsFilter then
		local newFilter = {}

		for _, v in ipairs(argumentsFilter) do
			newFilter[v] = true
		end

		argumentsFilter = newFilter
	end

	return function(...)
		local info = debug.getinfo(2, "Sln")
		local args = {...}

		if argumentsFilter then
			for i, v in ipairs(args) do
				if argumentsFilter[i] == nil then
					args[i] = nil
				end
			end
		end

		if logs.map[info.source] == nil then
			logs.map[info.source] = true
			table.insert(logs.list, {
				source = info.source,
				line = info.currentline,
				name = info.name,
				args = args
			})
		end
	end
end

do -- usage example
	draw._SimpleText = draw._SimpleText or draw.SimpleText

	local debugger = debugArguments(1, function()
		draw.SimpleText = draw._SimpleText
	end, {1, 5}) -- debug only text & color arguments

	function draw.SimpleText(...)
		debugger(...)
		draw._SimpleText(...)
	end
end
