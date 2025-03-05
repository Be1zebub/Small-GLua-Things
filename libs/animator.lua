-- from gmod.one with <3
-- https://github.com/Be1zebub/Small-GLua-Things/blob/master/libs/animator.lua

-- Panel:NewAnimation clone - but not tied to a specific class (using this lib, you can animate anything - not just panels)
-- https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/extensions/client/panel/animation.lua#L20-L136

--[[ Example:
local function entityRotate(ent, deltaYaw, length)
	local yaw = ent:GetAngles().y
	local targetYaw = yaw + deltaYaw

	NewAnimation(length)
	.Think = function(_, frac)
		if ent:IsValid() == false then return false end

		local ang = ent:GetAngles()
		ang.y = Lerp(frac, yaw, targetYaw)
		ent:SetAngles(ang)
	end
end
]]--

local animations = {}

local function AnimationThinkInternal()
	local currentTime = SysTime()

	for i = #animations, 1, -1 do
		local anim = animations[i]
		anim.index = i

		if currentTime >= anim.StartTime then
			local fraction = math.TimeFraction(anim.StartTime, anim.EndTime, currentTime)
			fraction = math.Clamp(fraction, 0, 1)

			local result

			if anim.Think then
				local easedFraction = fraction ^ anim.Ease

				if anim.Ease < 0 then
					easedFraction = fraction ^ (1.0 - ((fraction - 0.5)))
				elseif anim.Ease > 0 and anim.Ease < 1 then
					easedFraction = 1 - ((1 - fraction) ^ (1 / anim.Ease))
				end

				result = anim:Think(easedFraction)
			end

			if fraction == 1 or result == false then
				if anim.OnEnd then
					anim:OnEnd()
				end
				table.remove(animations, i)
			end
		end
	end

	if #animations == 0 then
		hook.Remove("Think", "gmod.one/animator")
	end
end

local META = {}

function META:Stop()
	if self.index == nil then return end

	if self.OnEnd then
		self:OnEnd()
	end

	table.remove(animations, self.index)
	self.index = nil

	if #animations == 0 then
		hook.Remove("Think", "gmod.one/animator")
	end
end

function NewAnimation(length, delay, ease, callback)
	if delay == nil then delay = 0 end
	if ease == nil then ease = -1 end

	local startTime = delay + SysTime()

	local anim = setmetatable({
		EndTime = startTime + length,
		StartTime = startTime,
		Ease = ease,
		OnEnd = callback,
	}, {__index = META})

	anim.index = table.insert(animations, anim)

	if #animations == 1 then
		hook.Add("Think", "gmod.one/animator", AnimationThinkInternal)
	end

	return anim
end
