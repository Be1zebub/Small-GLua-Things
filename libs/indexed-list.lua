-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/indexed-list.lua

-- A hybrid list/map for storing unique items by key while keeping their order. Fast lookups, easy iteration.

--[[ Indexing by a table key
local users = IndexedList({
	{id = 1, name = "John"},
	{id = 2, name = "Jane"},
	{id = 3, name = "Jim"},
}, "id")

print(users:Get(2).name)

users:Add({id = 4, name = "Jill"})
users:Remove(2)

print("iter:")
for _, value in users:Iter() do print(value.name) end
]]--

--[[ Arbitrary indexing
local fruits = IndexedList()

fruits:Add("Apple", 50)
fruits:Add("Banana", 100)
fruits:Add("Cherry", 150)
PrintTable(fruits)

print(fruits:Get(50))


fruits:Add("Cherry")
fruits:Remove(100)

print("iter:")
for _, value in fruits:Iter() do print(value) end
]]--

local iList = {}

function iList:Add(value, index)
	if not value then return end

	if index == nil then
		if self.index then
			assert(type(value) == "table", "value must be a table")
			index = value[self.index]
		else
			index = value
		end
	end

	if self.map[index] then return end

	self.map[index] = value
	self.list[#self.list + 1] = value

	return value
end

function iList:Remove(index)
	if not (index and self.map[index]) then
		return false
	end

	local value = self.map[index]

	for i = 1, #self.list do
		if self.list[i] == value then
			table.remove(self.list, i)
			self.map[index] = nil
			return true
		end
	end

	return false
end

function iList:Clear()
	self.list = {}
	self.map = {}
end

function iList:Get(index)
	if not index then return end

	return self.map[index]
end

function iList:GetAll()
	return self.list
end

function iList:GetCount()
	return #self.list
end

function iList:GetIndex()
	return self.index
end

function iList:Iter()
	return ipairs(self.list)
end

function IndexedList(values, index)
	local instance = setmetatable({
		list = {},
		map = {},
		index = index,
	}, {
		__index = iList
	})

	if values then
		for _, value in ipairs(values) do
			instance:Add(value)
		end
	end

	return instance
end
