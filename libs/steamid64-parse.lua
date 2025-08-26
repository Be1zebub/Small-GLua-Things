-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/steamid64-parse.lua

-- steamid64 parser & user accounts validator
-- production ready

local function ParseSteamID64(sid64)
	if type(sid64) ~= "string" or not sid64:match("^%d+$") or #sid64 > 20 then
		return nil, "invalid steamid64 format"
	end

	-- we cant work with unit64 directly, luajit got only double data-type
	local high, low = 0, 0

	for i = 1, #sid64 do
		local digit = tonumber(sid64:sub(i, i))

		local temp = low * 10 + digit
		high = high * 10 + math.floor(temp / 0x100000000)
		low = temp % 0x100000000
	end

	-- parse main details
	local details = {
		accountNumber = bit.rshift(low, 1),
		instance = bit.band(high, 0xFFFFF),
		accountType = bit.band(bit.rshift(high, 20), 0xF),
		universe = bit.band(bit.rshift(high, 24), 0xFF)
	}

	-- parse internal details
	-- steamid2: STEAM_X:Y:Z
	-- steamid3: [accountType:X:W]
	details.X = details.universe
	details.Y = bit.band(low, 0x1)
	details.Z = details.accountNumber
	details.W = details.Z * 2 + details.Y

	return details
end

local function IsValidUserSteamID64(sid64, desktopOnly)
	local details, reason = ParseSteamID64(sid64)
	if details == nil then
		return false, nil, reason
	end

	if desktopOnly and details.instance ~= 1 then
		-- instance id isn't usually used
		-- 0: all
		-- 1: desktop
		-- 2: console
		-- 4: web
		return false, details, "invalid instance"
	end

	if details.accountType ~= 1 then
		-- 0: bots/invalid accounts
		-- 1: individual (regular user profiles)
		-- 2: multi-seed accounts, eg cyber-cafe
		-- 3: game server
		-- 4: anon game server
		-- 5: pending verification
		-- 6: content server - unknown, probably deprecated & unused
		-- 7: groups/clans
		-- 8: chats/lobby/p2p chats
		-- 9: fake steamid's for ps3/x360
		-- 10: anon users

		return false, details, "invalid account type: not a user account"
	end

	if details.universe ~= 0 and details.universe ~= 1 then
		-- 0: invalid/unspecified is rare, but possible
		-- 1: public, common for user accounts
		-- 2: usually valve test accounts
		-- 3: internal valve accounts
		-- 4: dev accounts
		-- 5: deprecated, not used atm

		return false, details, "invalid universe: not a user account"
	end

	return true, details
end

--[[
local valid, details, reason = IsValidUserSteamID64("76561198086005321", true)

if valid then
	print("Valid user steamid64")
	PrintTable(details)
else
	print("Invalid user steamid64, reason: " .. reason)
	if details then PrintTable(details) end
end
]]--
