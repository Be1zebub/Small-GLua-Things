-- first in, first out
-- a simple queue buffer

local fifo = {}

function fifo:push(value)
	return table.insert(self, value)
end

function fifo:pop()
	return table.remove(self, 1)
end

function fifo:clear()
	for i = 1, #self do
		self[i] = nil
	end
end

function fifo:isEmpty()
	return #self == 0
end

return function(storage)
	return setmetatable(storage or {}, {__index = fifo})
end
