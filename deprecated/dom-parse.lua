-- unfinished html/xml > dom parser
-- the main issue is innerHTML parsing

local NODE = {}

do
	local function Search(node, check)
		local list = {}

		if node.children == nil then return {} end

		for _, child in ipairs(node.children) do
			if check(child) then
				list[#list + 1] = child
			end

			local sub = Search(child, check)
			if #sub > 0 then
				for _, sub_child in ipairs(sub) do
					list[#list + 1] = sub_child
				end
			end
		end

		return list
	end

	function NODE:GetElementsByTagName(tag)
		return Search(self, function(child)
			return child.tag == tag
		end)
	end

	function NODE:GetElementsByClass(class)
		return Search(self, function(child)
			for _, c in ipairs(child.attributes.classList) do
				if c == class then return true end
			end
		end)
	end

	function NODE:GetElementsByID(id)
		return self:GetElementsByAttribute("id", id)
		-- return Search(self, function(child)
		-- 	return child.attributes.id == id
		-- end)
	end

	function NODE:GetElementsByAttribute(key, value)
		if value then
			return Search(self, function(child)
				return child.attributes[key] == value
			end)
		else
			return Search(self, function(child)
				return child.attributes[key] ~= nil
			end)
		end
	end

	-- todo: querySelector, querySelectorAll
end

function NODE:Debug()
	print(self:ToHTML())
end

function NODE:ToHTML()
	if self.tag == nil then -- its dom root
		local childrens = {}

		for i, child in ipairs(self.children) do
			childrens[i] = child:ToHTML()
		end

		return table.concat(childrens, " ")
	end

	local attributes

	if self.attributes then
		attributes = {}
		for key, value in pairs(self.attributes) do
			if key ~= "classList" then
				attributes[#attributes + 1] = value == "" and key or string.format("%s=\"%s\"", key, value)
			end
		end

		attributes = #attributes > 0 and table.concat(attributes, " ") or nil
	end

	if self.children then
		local childrens = {}

		for i, child in ipairs(self.children) do
			childrens[i] = child:ToHTML()
		end

		childrens = #childrens > 0 and (table.concat(childrens, " ") .." ") or ""

		local base = "<%s>%s</%s>"
		local open = attributes and (self.tag .." ".. attributes) or self.tag

		return base:format(open, childrens .. self.innerHTML, self.tag)
	else
		local base = "<%s/>"
		local open = attributes and (self.tag .." ".. attributes) or self.tag

		return base:format(open)
	end
end

local parser = {}

do
	local embedded_tags = {
		script = true,
		css = true,
		style = true
	}

	function parser.tags(html, strip_embedded, pos, tags)
		pos = pos or 1
		tags = tags or {}
		uidtagsqueue = {}
		uid = 0

		while true do
			local start, finish, tag_close, tag, attributes, tag_empty = html:find("<(/?)([%w_:-]+)%s-(.-)%s-(/?)%>", pos)
			if start == nil then break end

			if not (strip_embedded and embedded_tags[tag]) then
				local setid = uid

				if #tag_close == 1 then
					setid = uidtagsqueue[tag][#uidtagsqueue[tag]]
					table.remove(uidtagsqueue[tag], #uidtagsqueue[tag])
				else
					uidtagsqueue[tag] = uidtagsqueue[tag] or {}
					table.insert(uidtagsqueue[tag], uid)
				end

				tags[#tags + 1] = {
					start = start,
					finish = finish,
					tag = tag,
					attributes = attributes,
					isempty = #tag_empty == 1,
					is_close = #tag_close == 1,
					content = html:sub(start, finish),
					taguid = setid
				}

				uid = uid + 1
			end
			pos = finish + 1
		end

		return tags
	end

	local function findTagClose(tags, i, tag)
		for i2 = #tags, i + 1, -1 do
			local tag2 = tags[i2]

			if tag2.is_close and tag2.taguid == tag.taguid then
				return tag2, i2
			end
		end
	end

	local function parseAttributes(raw)
		local attributes = {}

		raw = raw:gsub("(%g+)=\"(.-)\"", function(key, value)
			attributes[key] = value
			return ""
		end)

		for key in raw:gmatch("%s(%g+)%s-") do
			attributes[key] = ""
		end

		local classList = {}

		if attributes.class then
			for class in attributes.class:gmatch("%g+") do
				classList[#classList + 1] = class
			end
		end

		attributes.classList = classList

		return attributes
	end

	function parser.dom(tags, parent, html)
		local i = 1
		while tags[i] do
			local tag = tags[i]

			if tag.isempty then
				parent.children[#parent.children + 1] = setmetatable({
					tag = tag.tag,
					attributes = parseAttributes(tag.attributes),
					parent = parent
				}, {__index = NODE})

				table.remove(tags, i)
			elseif tag.is_close == false then
				local close, pos = findTagClose(tags, i, tag)
				if close then
					-- innerHTML реализован некорректно, довольно топорная реализация с обрезанием вложенных элементов
					-- я попытался сделать более корретную реализацию, но забил на это т.к. для моих задач подходит и текущая убогая реализация
					local innerHTML = html:sub(tag.finish + 1, close.start - 1)
					:gsub("<.->.*<.->", "")
					:gsub("<.->", "")

					local node = {
						tag = tag.tag,
						attributes = parseAttributes(tag.attributes),
						children = {},
						innerHTML = innerHTML,
						parent = parent
					}

					parent.children[#parent.children + 1] = setmetatable(node, {__index = NODE})

					table.remove(tags, i)
					table.remove(tags, pos - 1)

					local child_tags = {}

					for i2 = pos - 2, i, -1 do
						child_tags[i2] = table.remove(tags, i2)
					end

					if #child_tags > 0 then
						parser.dom(child_tags, node, html)
					end
--[[
						local innerHTML = html
						local finish = close.start - 1

						for _, child in ipairs(child_tags) do -- rm child tags from it
							innerHTML = innerHTML:sub(1, child.start - 1) .. innerHTML:sub(child.finish + 1)
							finish = finish - (child.finish - child.start)
						end

						node.innerHTML = innerHTML:sub(tag.finish + 1, finish)
					else
						node.innerHTML = html:sub(tag.finish + 1, close.start - 1)
					end
]]--
				else
					parent.children[#parent.children + 1] = setmetatable({
						tag = tag.tag,
						attributes = parseAttributes(tag.attributes),
						parent = parent
					}, {__index = NODE})

					table.remove(tags, i)
				end
			else
				i = i + 1
			end
		end
	end
end

local function parse(html, strip_embedded)
	-- strip comments
	html = html:gsub("<!%-%-.-%-%->", "")

	-- strip javascript/css
--[[ not finished yet
	if strip_embedded then
		html = html
		:gsub("<script/?>.*</script>", "")
		:gsub("<css/?>.*</css>", "")
		:gsub("<style/?>.*</style>", "")

		:gsub("<script .-/?>.*</script>", "")
		:gsub("<css .-/?>.*</css>", "")
		:gsub("<style .-/?>.*</style>", "")

		-- print(html)
	end
]]--

	-- windows > unix line endings
	html = html:gsub("\r\n", "\n")

	local dom = setmetatable({
		children = {},
		--innerHTML = html
	}, {__index = NODE})

	local tags = parser.tags(html, strip_embedded)
	parser.dom(tags, dom, html)

	return dom
end

return parse
