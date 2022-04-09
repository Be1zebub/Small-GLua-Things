-- from incredible-gmod.ru with love <3

local XML = {}
XML.__index = XML

function XML:New(tag, attributes, obj)
	attributes = attributes or {}

	local new = setmetatable(obj or {}, self)
	new.tag = tag
	new.attributes = attributes

	self.Init(new, attributes)
	return new
end

function XML:Init(attributes)
	self.Children = {}

	return self
end

function XML:Add(tag, attributes, return_parent)
	local new = XML(tag, attributes)
	new.parent = self

	self.Children[#self.Children + 1] = new

	return return_parent and self or new
end

function XML:AddGroup(...)
	for _, tag in ipairs({...}) do
		self:Add(tag[1], tag[2])
	end

	return self
end

function XML:GetElementByID(id)
	for i, child in ipairs(self.Children) do
		if child.id == id then
			return child
		else
			return child:GetElementByID(id)
		end
	end
end

function XML:GetElementsByTag(tag, found)
	found = found or {}

	for i, child in ipairs(self.Children) do
		if child.tag == tag then
			found[#found + 1] = child
		else
			child:GetElementsByTag(tag, found)
		end
	end

	return found
end

function XML:GetElementsByClass(class, found)
	found = found or {}

	for i, child in ipairs(self.Children) do
		if child.class == class then
			found[#found + 1] = child
		else
			child:GetElementsByClass(tag, found)
		end
	end

	return found
end

--[[
setmetatable(XML, {
	__call = XML.New
})

local xml = XML("body", {width = 50, height = "auto"})

xml:Add("header")
:AddGroup(
	{"text", {value = "Hi"}},
	{"text", {value = "Mom"}}
)

print( util.TableToJSON(xml, true) )

Result:
{
	"tag": "body",
	"attributes": {
		"height": "auto",
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
]]--
