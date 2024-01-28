-- unfinished, iirc even didnt tested

local animations = {
	_VERSION = 1.0,
	_URL 	 = "https://github.com/Be1zebub/Small-GLua-Things/blob/master/animations.lua",
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

local storage = {}

if SERVER then
	util.AddNetworkString("incredible-gmod.ru/animations")

	local act
	function animations.start(ply, anim)
		if isnumber(anim) then
			act = anim
		elseif isstring(anim) and ply:LookupSequence(anim) then
			act = ply:GetSequenceActivity(ply:LookupSequence(anim))
		else
			act = -1
		end

		storage[ply] = act

		net.Start("incredible-gmod.ru/animations")
			net.WriteUInt(ply:EntIndex(), 7)
			net.WriteUInt(act + 1, 32)
		net.Broadcast()
	end

	function animations.stop(ply)
		storage[ply] = -1

		net.Start("incredible-gmod.ru/animations")
			net.WriteUInt(ply:EntIndex(), 7)
			net.WriteUInt(0, 32)
		net.Broadcast()
	end

	local seqid
	function animations.length(ply, anim)
		if isnumber(anim) then
			seqid = ply:SelectWeightedSequence(anim)
		elseif isstring(anim) then
			seqid = ply:LookupSequence(anim)
		else
			seqid = -1
		end

		return ply:SequenceDuration(seqid)
	end
else
	net.Receive("incredible-gmod.ru/animations", function()
		storage[Entity(net.ReadUInt(7))] = net.ReadUInt(32) - 1
	end)
end

function animations.get(ply)
	return storage[ply]
end

local PLAYER = FindMetaTable("Player")
local IsPlayingTaunt, AnimRestartGesture, AnimSetGestureWeight, Approach = PLAYER.IsPlayingTaunt, PLAYER.AnimRestartGesture, PLAYER.AnimSetGestureWeight, math.Approach

local weight, last_act, act = {}, {}
hook.Add("UpdateAnimation", "incredible-gmod.ru/animations", function(ply)
	if IsPlayingTaunt(ply) then return end

	act = storage[ply]
	if act == nil then return end

	if act ~= -1 then
		weight[ply] = Approach(weight[ply] or 0, 1, FrameTime() * 5)
		last_act[ply] = act
	else
		weight[ply] = Approach(weight[ply] or 0, 0, FrameTime() * 5)
	end

	if weight[ply] > 0 then
		AnimRestartGesture(ply, GESTURE_SLOT_CUSTOM, act ~= -1 and act or last_act[ply], true)
		AnimSetGestureWeight(ply, GESTURE_SLOT_CUSTOM, weight[ply])
	end
end)

return animations
