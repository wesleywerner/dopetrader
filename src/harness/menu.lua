--[[
   Copyright 2018 wesley werner <wesley.werner@gmail.com>

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see http://www.gnu.org/licenses/.

]]--

--- A simple menu system for LÖVE.
--
-- @author Wesley Werner
-- @license GPL v3
-- @module menu

local menu = { }

-- stores the full menu structure
local db = { }

-- list of menus to draw
local shown = nil


--  _                 _
-- | | ___   ___ __ _| |___
-- | |/ _ \ / __/ _` | / __|
-- | | (_) | (_| (_| | \__ \
-- |_|\___/ \___\__,_|_|___/
--

--- Prepare menu for use.
-- Go over the menu items to measure and store their size.
local function initializeData (data, x, y, options)

	-- default offsets
	x, y = x or 0, y or 0

	-- default menu width
	local width = 0

	-- grab font infos
	local font = love.graphics.getFont ()
	local fontHeight = font:getHeight ()

	-- measure the longest item
	for index, value in ipairs (data) do
		local thisWidth = font:getWidth (value.title) + options.padding
		if thisWidth > width then
			width = thisWidth
		end
	end

	-- save the menu size
	data["_menu_x"] = x
	data["_menu_y"] = y
	data["_menu_width"] = width
	data["_menu_height"] = fontHeight * #data

	-- process each item
	for index, value in ipairs (data) do

		-- y-position of this menu item
		local itemPosition = (index - 1) * fontHeight

		-- store this key info
		value["_x"] = x
		value["_y"] = y + itemPosition
		value["_width"] = width
		value["_height"] = fontHeight
		value["_right"] = x + width
		value["_bottom"] = value["_y"] + fontHeight

		if type (value.items) == "table" then

			initializeData (value.items, x + width, itemPosition, options)

		end

	end

end


--                                           _
--  _ __ ___   ___ _ __  _   _    __ _ _ __ (_)
-- | '_ ` _ \ / _ \ '_ \| | | |  / _` | '_ \| |
-- | | | | | |  __/ | | | |_| | | (_| | |_) | |
-- |_| |_| |_|\___|_| |_|\__,_|  \__,_| .__/|_|
--                                    |_|

function menu:set (userdb, options)

	db = userdb

	-- default options
	options = options or { }
	options.padding = options.padding or 40

	initializeData (db, 0, 0, options)

end

function menu:mousepressed (x, y, button, istouch, presses)

	if not self.visible then
		return false
	end

	-- remove the menu position from the coordinates so that we
	-- can work with origin points
	x = x - self.x
	y = y - self.y

	-- click on any item in last displayed menu
	--local menu = shown[#shown]

	-- rebuild the shown menu tree.
	-- this allows the user to drill down sibling menus.
	local newtree = { }

	-- remember the previous parent
	local previousParent = nil

	for _, menu in ipairs (shown) do

		for index, item in ipairs (menu) do

			local inXBounds = x > item["_x"] and x < item["_right"]
			local inYBounds = y > item["_y"] and y < item["_bottom"]

			if inXBounds and inYBounds then

				if previousParent then
					table.insert (newtree, previousParent)
				end

				table.insert (newtree, menu)

				if type (item.callback) == "function" then

					item.callback (item.title)
					self:hide ()

				elseif type (item.items) == "table" then

					-- include this clicked submenu
					table.insert (newtree, item.items)

				end

			end

		end

		previousParent = menu

	end

	if #newtree == 0 then
		self:hide ()
	else
		shown = newtree
	end

end

function menu:mousemoved (x, y, dx, dy, istouch)

	if not self.visible then
		return false
	end

	if menu:mousemoved (x, y, dx, dy, istouch) then
		-- menu handled this event, exit this function
		return
	end

end

function menu:draw ()

	if not self.visible then
		return false
	end

	love.graphics.push ()
	love.graphics.translate (self.x, self.y)

	for _, menu in ipairs (shown) do

		self:drawBorder (
			menu["_menu_x"],
			menu["_menu_y"],
			menu["_menu_width"],
			menu["_menu_height"]
		)

		for _, value in ipairs (menu) do

			self:drawItem (
				value["_x"],
				value["_y"],
				value["_width"],
				value["_height"],
				value["title"]
			)

		end

	end

	love.graphics.pop ()

end

function menu:drawItem (x, y, width, height, title)

	love.graphics.setColor ({1, 1, 1})
	love.graphics.print (title, x, y)

end

function menu:drawBorder (x, y, width, height)

	-- outline
	love.graphics.setColor ({1, 1, 1})
	love.graphics.rectangle ("line", x, y, width, height)

end

function menu:show (x, y, options)

	-- store the display position
	self.x = x or 0
	self.y = y or 0

	-- display the root menu initially
	shown = { db }

	self.visible = true

end

function menu:hide ()

	self.visible = false
	shown = nil

end

return menu
