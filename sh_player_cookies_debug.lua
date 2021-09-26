-- incredible-gmod.ru
-- wanna test lib? here is a small example of using it, you can check it out in the game:)
-- lib src: https://github.com/Be1zebub/Small-GLua-Things/blob/master/sh_player_cookies.lua

local StartMoney = 5000

local PLAYER = FindMetaTable("Player")

function PLAYER:GetMoney()
     return self:GetCookie("Money", 0) -- name, default value - optional
end

function PLAYER:CanAfford(num)
    return self:GetMoney() >= num
end

if CLIENT then
	hook.Add("HUDPaint", "CookiesTest", function()
		draw.SimpleText(string.Comma(LocalPlayer():GetMoney()) .."$", "DermaLarge", 4, 4, color_white)
	end)
	return
end

hook.Add("CookiesLoaded", "Money", function(ply)
    ply:NWCookie("Money", StartMoney, true, tonumber) -- name, default value - optional, networking global - optional, totype - optional
end)

function PLAYER:SetMoney(num)
    self:SetCookie("Money", num, true, true) -- name, value, networking - optional, networking global - optional
end

function PLAYER:AddMoney(num)
    self:SetMoney(math.max(self:GetMoney() + num, 0))
end

function PLAYER:TakeMoney(num)
    self:AddMoney(-num)
end
