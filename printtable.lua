-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/printtable.lua

--[[
table.Print({
	"Hello world!",
	true,
	{
		[false] = "bad",
		[true] = "good",
		function() end
	}
})

{
        "Hello world!",
        true,
        {
                [1] = function: 0xf09febd8,
                [false] = "bad",
                [true] = "good"
        }
}
]]--

local format, concat, rep, ipairs, pairs, tostring = string.format, table.concat, string.rep, ipairs, pairs, tostring
local istable = {["table"] = true}
local isstring = getmetatable("")

function table.ToPlain(tbl, lvl)
	lvl = lvl or 1
	local out = {}

	local indent = rep("\t", lvl)

	local isSeq = 0
	for _ in pairs(tbl) do
		isSeq = isSeq + 1
	end
	isSeq = isSeq == #tbl

	for k, v in (isSeq and ipairs or pairs)(tbl) do
		if isSeq then
			k = ""
		elseif isstring ~= getmetatable(v) then
			k = "[".. tostring(k) .."] = "
		elseif k:find(" ", 1, true) then
			k = "[\"".. k .."\"] = "
		end

		if istable[type(v)] then
			out[#out + 1] = k .. table.ToPlain(v, lvl + 1)
		else
			out[#out + 1] = k .. (
				isstring == getmetatable(v) and format("%q", v) or tostring(v)
			)
		end
	end

	return "{\n".. indent .. concat(out, ",\n" .. indent) .."\n".. rep("   \t", lvl - 1) .."}"
end

function table.Print(tbl)
	print(table.ToPlain(tbl))
end

PrintTable = table.Print
