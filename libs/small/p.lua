-- a small & simple util for debugging
-- deps: https://github.com/Be1zebub/Small-GLua-Things/blob/master/printtable.lua

function p(...)
	local output = "\n"

	for i, v in ipairs({...}) do
		output = output .. string.format("%s. %s - %s", i, type(v), (
			type(v) == "table" and table.ToPlain(v) or tostring(v)
		))

		-- if i < #input then
			output = output .."\n"
		-- end
	end

	print(output)
end
