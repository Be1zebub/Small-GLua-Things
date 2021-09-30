-- incredible-gmod.ru

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

-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/thirdparty/pon.lua

function file.WritePon1(path, content, compress)
	content = pon.encode(content)
	
	file.Write(path, compress and util.Compress(content) or content)
end

function file.ReadPon1(path, decompress)
	local content = file.Read(path, "DATA")

	return pon.decode(
		decompress and util.Decompress(content) or content
	)
end
