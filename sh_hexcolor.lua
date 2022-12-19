local bit = bit or bit32 -- LuaJIT and Lua 5.1 support
local bor, blsh = bit.bor, bit.lshift
return function(r, g, b)
	return bor(blsh(r, 16), blsh(g, 8), b)
end
