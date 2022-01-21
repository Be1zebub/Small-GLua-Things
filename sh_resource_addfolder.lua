-- incredible-gmod.ru

function resource.AddFolder(name, recurse)
    local files, folders = file.Find(name .."/*", "GAME")

    for i, fname in ipairs(files) do
        resource.AddSingleFile(name .."/".. fname)
    end

    if recurse then
        for i, fname in ipairs(folders) do
            resource.AddFolder(name .."/".. fname, recurse)
        end
    end
end

--[[ Пример:
resource.AddFolder("materials/chatbox", true) -- иконочки чатика
resource.AddFolder("resource/fonts/notosans_*.ttf", false) -- шрифтики
]]--
