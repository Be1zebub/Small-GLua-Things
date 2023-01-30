-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/hook_expanded.lua

hook._GetTable = hook._GetTable or hook.GetTable

function hook.GetTable(event)
	if event then
		return hook._GetTable()[event] or {}
	else
		return hook._GetTable()
	end
end

function hook.Get(event, identifier)
	return hook.GetTable(event)[identifier]
end

function hook.Exists(event, identifier)
	return tobool(hook.Get(event, identifier))
end

function hook.Once(event, callback, identifier)
	identifier = identifier or debug.traceback()

	hook.Add(event, identifier, function()
		hook.Remove(event, identifier)
		callback()
	end)
end

for ClassName, Class in pairs(debug.getregistry()) do
	if FindMetaTable(ClassName) == nil or Class.IsValid == nil then continue end

	function Class:AddHook(event, callback)
		hook.Add(event, self, callback)

		if self.HooksTable == nil then
			self.HooksTable = {}
			local old = self.OnRemove
			self.OnRemove = function()
				for event in pairs(self.HooksTable) do
					hook.Remove(event, self)
				end
				if old then old(self) end
			end
		end

		self.HooksTable[eventName] = true
	end

	function Class:RemoveHook(event)
		hook.Remove(event, self)
		self.HooksTable[eventName] = nil
	end
end

hook.Paused = hook.Paused or {}

function hook.Pause(event, identifier)
	if hook.Paused[event] == nil then hook.Paused[event] = {} end

	if identifier then
		if hook.Paused[event][identifier] then return end

		hook.Paused[event][identifier] = (hook.GetTable()[event] or {})[identifier]
		hook.Remove(event, identifier)
	else
		for identifier, listener in pairs(hook.GetTable()[event] or {}) do
			if hook.Paused[event][identifier] then continue end

			hook.Paused[event][identifier] = (hook.GetTable()[event] or {})[identifier]
			hook.Remove(event, identifier)
		end
	end
end

function hook.PauseAll()
	for event in pairs(hook.GetTable()) do
		hook.Pause(event)
	end
end

function hook.UnPause(event, identifier)
	if hook.Paused[event] == nil then return end

	if identifier then
		if hook.Paused[event][identifier] == nil then return end
		hook.Add(event, identifier, hook.Paused[event][identifier])
		hook.Paused[event][identifier] = nil
	else
		for identifier in pairs(hook.Paused[event]) do
			hook.Add(event, identifier, hook.Paused[event][identifier])
			hook.Paused[event][identifier] = nil
		end
	end
end

function hook.UnPauseAll()
	for event in pairs(hook.Paused) do
		hook.UnPause(event)
	end
end
