-- deprecated
-- it may be useful, but writing/reading files together with the serializer is not such a frequent operation to make special helper functions for it.

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
