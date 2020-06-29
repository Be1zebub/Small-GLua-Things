-- incredible-gmod.ru
-- get-keyname func

local Mouse2Name = {
	[MOUSE_MIDDLE] = "MIDDLE MOUSE",
	[MOUSE_4] = "MOUSE 4",
	[MOUSE_5] = "MOUSE 5",
	[MOUSE_WHEEL_UP] = "MOUSE WHEEL UP",
	[MOUSE_WHEEL_DOWN] = "MOUSE WHEEL DOWN"
}

local __a, __b, __c = isnumber, MOUSE_MIDDLE, input.GetKeyName

function GetKeyName(key)
	if not __a(key) then return "UNKNOWN KEY" end

	if key >= __b then
		return Mouse2Name[key] or "UNKNOWN MOUSE"
	end

	return __c(key) and __c(key):upper() or "UNKNOWN KEY"
end
