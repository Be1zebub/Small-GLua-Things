-- incredible-gmod.ru
-- pon1 here: https://github.com/Be1zebub/Small-GLua-Things/blob/master/not_mine/pon1.lua

function file.WriteJson(path, content, compress)
	content = util.TableToJSON(content)
	file.Write(path, compress and util.Compress(content) or content)
end

function file.ReadJson(path, decompress)
	local content = file.Read(path, "DATA")
	
	return util.JSONToTable(
		decompress and util.Decompress(content) or content
	)
end

function file.WritePon1(path, content, compress)
	content = pon1.encode(content)
	file.Write(path, compress and util.Compress(content) or content)
end

function file.ReadPon1(path, decompress)
	local content = file.Read(path, "DATA")

	return pon1.decode(
		decompress and util.Decompress(content) or content
	)
end
