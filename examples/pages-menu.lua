-- vgui layout guide
-- use it for educational purposes if you want to learn vgui

local menu
local pages = {}
local itemsPerPage = 5

for page_id = 1, 3 do -- generate empty pages for debug (you should get real pages from the server or from somewhere else)
	pages[page_id] = {}

	for item_id = 1, itemsPerPage do
		pages[page_id][item_id] = {
			somePageData = "just a test",
			uid = page_id .."_".. item_id,
			debug_uid = true
		}
	end
end

local page_id = 1

concommand.Add("pages_menu", function(ply)
	if IsValid(menu) then menu:Remove() end

	menu = vgui.Create("DFrame")
	menu:SetSize(420, math.min(720, ScrH()))
	menu:Center()
	menu:MakePopup()
	menu:SetTitle("Pages menu - Page #".. page_id)
	menu.Think = function(me)
		if input.IsKeyDown(KEY_ESCAPE) then
			me:Remove()
		end
	end

	menu.search = menu:Add("DTextEntry")
	menu.search:Dock(TOP)
	menu.search:SetPlaceholderText("Search...")
	menu.search:SetTall(24)
	menu.search.OnEnter = function(me)
		local userinput = me:GetText()
		local userinput_lower = userinput:lower()

		menu.controls:SetVisible(userinput == "")

		if menu.controls:IsVisible() then
			menu:setPage(page_id)
		else
			menu:clearPage()
		end

		local visible = 0

		for page_id, page in ipairs(pages) do
			for item_id, item in ipairs(page) do
				if item.uid:lower():find(userinput_lower, 1, true) then
					menu:addPageItem(item)

					visible = visible + 1
					if visible >= itemsPerPage then return end
				end
			end
		end
	end
	menu.search.OnLoseFocus = menu.search.OnEnter

	menu.content = menu:Add("EditablePanel")
	menu.content:Dock(FILL)
	menu.content:DockMargin(0, 8, 0, 8)

	menu.controls = menu:Add("EditablePanel")
	menu.controls:Dock(BOTTOM)
	menu.controls:SetTall(32)

	local polyMargin = 8

	menu.controls.right = menu.controls:Add("DButton")
	menu.controls.right:Dock(RIGHT)
	menu.controls.right:SetWide(menu.controls:GetTall())
	menu.controls.right:DockMargin(4, 0, 0, 0)
	menu.controls.right:SetText("")
	menu.controls.right.PaintOver = function(me, w, h)
		surface.SetDrawColor(50, 50, 50, (me:IsHovered() and me:GetDisabled() == false) and 255 or 215)
		draw.NoTexture()
		surface.DrawPoly({
			{x = polyMargin, y = polyMargin},
			{x = w - polyMargin, y = h * 0.5},
			{x = polyMargin, y = h - polyMargin}
		})
	end
	menu.controls.right.DoClick = function(me)
		menu:nextPage()
	end

	menu.controls.left = menu.controls:Add("DButton")
	menu.controls.left:Dock(RIGHT)
	menu.controls.left:SetWide(menu.controls:GetTall())
	menu.controls.left:DockMargin(4, 0, 0, 0)
	menu.controls.left:SetText("")
	menu.controls.left.PaintOver = function(me, w, h)
		surface.SetDrawColor(50, 50, 50, (me:IsHovered() and me:GetDisabled() == false) and 255 or 215)
		draw.NoTexture()
		surface.DrawPoly({
			{x = polyMargin, y = h * 0.5},
			{x = w - polyMargin, y = polyMargin},
			{x = w - polyMargin, y = h - polyMargin}
		})
	end
	menu.controls.left.DoClick = function(me)
		menu:prevPage()
	end

	menu.controls.input = menu.controls:Add("DTextEntry")
	menu.controls.input:Dock(RIGHT)
	menu.controls.input:SetWide(menu.controls:GetTall() * 3)
	menu.controls.input:SetPlaceholderText("Page number...")
	menu.controls.input:SetText(page_id)

	menu:InvalidateLayout(true)

	local item_tall = menu.content:GetTall() / itemsPerPage - (4 * 0.8)

	menu.AddPageItem = function(me, item)
		local item_p = me.content:Add("DButton")
		item_p:SetTall(item_tall)
		item_p:Dock(TOP)
		item_p:DockMargin(0, 0, 0, 4)
		item_p:SetText(item.debug_uid and ("UID: ".. item.uid) or "")
	end

	menu.IsPageExists = function(me, id)
		return tobool(pages[id])
	end

	menu.ClearPage = function(me)
		for i, child in ipairs(me.content:GetChildren()) do
			child:Remove()
		end
	end

	menu.SetPage = function(me, id)
		local page = pages[id]
		if page == nil then return false end


		me.controls.right:SetDisabled(id >= #pages)
		me.controls.left:SetDisabled(id <= 1)

		page_id = id
		me.controls.input:SetText(id)

		me:ClearPage()

		for i, item in ipairs(page) do
			me:AddPageItem(item)
		end

		return true
	end

	menu.NextPage = function(me)
		return me:SetPage(page_id + 1)
	end

	menu.PrevPage = function(me)
		return me:SetPage(page_id - 1)
	end

	menu:SetPage(page_id)
end)
