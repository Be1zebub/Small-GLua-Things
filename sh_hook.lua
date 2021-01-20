-- extending capabilities of the hook lib
-- incredible-gmod.ru

hook._GetTable = hook._GetTable or hook.GetTable

function hook.GetTable(eventName)
    if eventName then
        return hook._GetTable()[eventName] or {}
    else
        return hook._GetTable()
    end
end

function hook.Get(eventName, identifier)
    return hook.GetTable(eventName)[identifier]
end

function hook.Exists(eventName, identifier)
    return tobool(hook.Get(eventName, identifier))
end

for ClassName, Class in pairs(debug.getregistry()) do
    if istable(Class) and Class.IsValid and isstring(ClassName) then
        function Class:AddHook(eventName, callback)
            hook.Add(eventName, self, callback)
        end
    end
end
