-- incredible-gmod.ru

function resource.AddFolder(name, recurse)
    local files, folders = file.Find(name .."/*", "GAME")

    for k, fname in pairs(files) do
        resource.AddSingleFile(name .."/".. fname)
    end

    if recurse then
        for k, fname in pairs(folders) do
            resource.AddFolder(name .."/".. fname, recurse)
        end
    end
end

--[[ Example:
resource.AddFolder("materials/chatbox", true) -- chatbox icons
resource.AddFolder("resource", true) -- fonts
]]--
