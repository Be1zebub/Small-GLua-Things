-- simple helper

function resource.AddFolder(dir, recurse, pattern)
	local files, folders = file.Find(dir .. (pattern and ("/".. pattern) or "/*"), "GAME")

	for i, fname in ipairs(files) do
		resource.AddSingleFile(dir .."/".. fname)
	end

	if recurse then
		for i, subdir in ipairs(folders) do
			resource.AddFolder(dir .."/".. subdir, recurse, pattern)
		end
	end
end

--[[ Пример:
resource.AddFolder("materials/chatbox", true) -- иконочки чатика
resource.AddFolder("resource/fonts/notosans_*.ttf", false) -- шрифтики
]]--
