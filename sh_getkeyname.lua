local Mouse2Name = {
	[MOUSE_MIDDLE] = "MIDDLE MOUSE",
	[MOUSE_4] = "MOUSE 4",
	[MOUSE_5] = "MOUSE 5",
	[MOUSE_WHEEL_UP] = "MOUSE WHEEL UP",
	[MOUSE_WHEEL_DOWN] = "MOUSE WHEEL DOWN",
	[NULL] = "UNKNOWN MOUSE"
}

local __a, __b, __c = isnumber, input.GetKeyName, MOUSE_MIDDLE

function GetKeyName(key)
	if not __a(key) then return "UNKNOWN KEY" end

	if key >= __c then
		return Mouse2Name[key]
	end

	return __b(key) and __b(key):upper() or "UNKNOWN KEY"
end
