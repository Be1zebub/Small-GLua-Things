local XML = {
	_VERSION = 1.0,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/xml.lua",
	_LICENSE = [[
		MIT LICENSE
		Copyright (c) 2022 incredible-gmod.ru
		Permission is hereby granted, free of charge, to any person obtaining a
		copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:
		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
		OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	]]
}
XML.__index = XML

-- todo:
-- 1. add XML:Parse (https://github.com/manoelcampos/xml2lua fork) - unfortunately it currently does not support void elements https://github.com/manoelcampos/xml2lua/issues/78

function XML:New(tag, attributes, isvoid, obj) -- void elements cant have children (since theres no end tag) example: <img src="xml.png">
	attributes = attributes or {}

	local new = setmetatable(obj or {}, self)
	new.tag = tag
	new.attributes = attributes
	new.isvoid = isvoid == true

	self.Init(new, attributes)
	return new
end

function XML:Init(attributes)
	self.Children = {}

	return self
end

function XML:Add(tag, attributes, isvoid, return_parent)
	local new = XML(tag, attributes, isvoid)
	self.Children[#self.Children + 1] = new

	return return_parent and self or new
end

function XML:AddGroup(...)
	for _, tag in ipairs({...}) do
		self:Add(tag[1], tag[2], tag[3])
	end

	return self
end

function XML:GetElementByTagName(tag)
	local found = {}

	for i, child in ipairs(self.Children) do
		if child.tag == tag then
			found[#found + 1] = child
		end
	end

	return found
end

function XML:GetElementByID(id)
	local found = {}

	for i, child in ipairs(self.Children) do
		if child.id == id then
			found[#found + 1] = child
		end
	end

	return found
end

local str = getmetatable("")

local function formatAttrValue(v)
	if getmetatable(v) == str then
		return string.format("%q", v)
	else
		return tostring(v)
	end
end

function XML:__tostring(lvl)
	lvl = lvl or 0

	local children = {}

	for i, child in ipairs(self.Children) do
		children[i] = child:__tostring(lvl + 1)
	end

	local attributes = {}

	for attr, value in pairs(self.attributes) do
		attributes[#attributes + 1] = attr .."=".. formatAttrValue(value)
	end

	if #children > 0 then
		return string.format("%s<%s%s>\n%s\n%s</%s>", string.rep("\t", lvl), self.tag, #attributes > 0 and (" ".. table.concat(attributes, " ")) or "", table.concat(children, "\n"), string.rep("\t", lvl), self.tag)
	elseif self.isvoid then
		return string.format("%s<%s%s>", string.rep("\t", lvl), self.tag, #attributes > 0 and (" ".. table.concat(attributes, " ")) or "")
	else
		return string.format("%s<%s%s></%s>", string.rep("\t", lvl), self.tag, #attributes > 0 and (" ".. table.concat(attributes, " ")) or "", self.tag)
	end
end

return setmetatable(XML, {
	__call = XML.New
})

--[[ Examples:
local xml = XML("body", {width = 50, height = 128})

xml:Add("header")
:AddGroup(
	{"text", {value = "Hi"}, true},
	{"text", {value = "Mom"}, true}
)

print( util.TableToJSON(xml, true) )
{
	"tag": "body",
	"attributes": {
		"height": 128.0,
		"width": 50.0
	},
	"Children": [
		{
			"tag": "header",
			"attributes": [],
			"Children": [
				{
					"tag": "text",
					"attributes": {
						"value": "Hi"
					},
					"Children": []
				},
				{
					"tag": "text",
					"attributes": {
						"value": "Mom"
					},
					"Children": []
				}
			]
		}
	]
}

print(xml)
<body height=128 width=50>
	<header>
		<text value="Hi">
		<text value="Mom">
	</header>
</body>
]]--
