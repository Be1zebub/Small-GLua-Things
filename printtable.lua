-- from incredible-gmod.ru with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/printtable.lua
-- perfectly combines with https://github.com/Be1zebub/Small-GLua-Things/blob/master/better_tostring.lua

--[[
table.Print({
	"Hello world!",
	true,
	{
		[false] = "bad",
		[true] = "good",
		{},
		function() end,
		{"lorem ispum"}
	}
})

{
        "Hello world!",
        true,
        {
                [1] = {},
                [2] = function: 0xf0eaa590,
                [3] = {"lorem ispum"},
                [false] = "bad",
                [true] = "good"
        }
}

table.Print({test = 1, [1] = 2}, true) -- no pretty (if you dont need newlines & indent)
{[1] = 2, test = 1}
]]--

--[[
SetClipboardText(table.ToPlain({
    pos = ent:GetPos(),
    ang = ent:GetAngles()
}))
]]--

local format, concat, rep, ipairs, pairs, tostring = string.format, table.concat, string.rep, ipairs, pairs, tostring
local istable = {["table"] = true}
local isstring = getmetatable("")

function table.ToPlain(tbl, nopretty, lvl, already)
	already = already or {}
	lvl = lvl or 1

	local out = {}

	local len = 0
	for _ in pairs(tbl) do
		len = len + 1
	end

	if len == 0 then
		return "{}"
	end

	local isSeq = len == #tbl
	local last

	local not_isSeq = not isSeq

	if not_isSeq then
		local new = {}
		local id = 0

		for k, v in pairs(tbl) do
			id = id + 1
			new[id] = {k = k, v = v}
		end

		table.sort(new, function(a, b)
			if type(a.k) == "number" and type(b.k) == "number" then return a.k < b.k end
			return tostring(a.k) < tostring(b.k)
		end)

		tbl = new
	end

	for k, v in (isSeq and ipairs or pairs)(tbl) do
		if not_isSeq then
			k, v = v.k, v.v
		end

		if isSeq then
			k = ""
		elseif isstring ~= getmetatable(k) then
			k = "[".. tostring(k) .."] = "
		elseif k:find(" ", 1, true) then
			k = "[\"".. k .."\"] = "
		else
			k = k .." = "
		end

		if istable[type(v)] and already[v] == nil then
			last = v
			already[v] = true
			out[#out + 1] = k .. table.ToPlain(v, nopretty, lvl + 1, already)
		else
			last = v
			out[#out + 1] = k .. (
				isstring == getmetatable(v) and format("%q", v) or tostring(v)
			)
		end
	end

	if len == 1 and istable[type(last)] == nil then
		return "{".. out[1] .."}"
	end

	if nopretty then
		return "{".. concat(out, ", ") .."}"
	else
		local indent = rep("\t", lvl)
		return "{\n".. indent .. concat(out, ",\n" .. indent) .."\n".. rep("\t", lvl - 1) .."}"
	end
end

function table.Print(tbl, nopretty)
	print(table.ToPlain(tbl, nopretty))
end

PrintTable = table.Print

--[[ Bonus:
function table.Printf(tbl, indent)
	indent = indent or 0

	for k, v in pairs(tbl) do
		formatting = rep("   ", indent) .. k ..": "

		if istable[type(v)] then
			MsgC({255, 255, 0}, formatting)
			table.Printf(v, indent + 1)
		else
			MsgC({255, 255, 0}, formatting .. tostring(v))
		end
	end
end
]]--
