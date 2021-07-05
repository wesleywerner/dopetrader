--[[
   Copyright 2017 wesley werner <wesley.werner@gmail.com>

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

--- Provides collective management of buttons.
-- The collection handles batch event updating and focus tracking.
--
-- @author Wesley Werner
-- @license GPL v3
-- @module widgetcollection

local module = { }
local widgetcollection = { }
local thispath = select('1', ...):match(".+%.") or ""
local buttonModule = require(thispath.."button")
local labelModule = require(thispath.."label")
local sliderModule = require(thispath.."slider")

--- Returns a new widget collection instance.
--
function module:new()

    local instance = { controls={} }
    setmetatable(instance, { __index = widgetcollection })
    return instance

end

--- Creates an ordered list of keys mapped to positions.
-- This function is used internally by the collection.
--
-- @tparam table instance
-- The widget collection instance to work on.
local function mapkeys(instance)

    -- map control keys to position for sorting
    instance.keymap = { }
    for key, v in pairs(instance.controls) do
        table.insert(instance.keymap, {key=key, left=v.left, top=v.top})
    end

    -- order top first, then left second
    table.sort(instance.keymap, function(a, b)
        return (a.top == b.top) and (a.left < b.left) or (a.top < b.top)
        end)

end

--- Moves focus to the first element.
-- This function is used internally by the collection.
--
-- @tparam table instance
-- The widget collection instance to work on.
local function focusFirst(instance)

    instance.focusedKey = 1

end

--- Moves focus to the next element.
-- This function is used internally by the collection.
--
-- @tparam table instance
-- The widget collection instance to work on.
local function focusNext(instance, loop_limit)

    instance.focusedKey = instance.focusedKey + 1
    if instance.focusedKey > #instance.keymap then
        instance.focusedKey = 1
    end

    -- repeat this action while no focus is found, with a loop limiter
    local found_focus = false
    if loop_limit and loop_limit > 10 then
        return
    end

    -- apply focus
    for key, control in pairs(instance.controls) do
        local skip = control.hidden or control.disabled or not control.callback
        control.focused = not skip and (key == instance.keymap[instance.focusedKey].key)
        if control.focused then
            found_focus = true
        end
    end

    if not found_focus then
        focusNext(instance, (loop_limit or 0) + 1)
    end

end

--- Moves focus to the previous element.
-- This function is used internally by the collection.
--
-- @tparam table instance
-- The widget collection instance to work on.
local function focusPrev(instance, loop_limit)

    instance.focusedKey = instance.focusedKey - 1
    if instance.focusedKey < 1 then
        instance.focusedKey = #instance.keymap
    end

    -- repeat this action while no focus is found, with a loop limiter
    local found_focus = false
    if loop_limit and loop_limit > 10 then
        return
    end

    -- apply focus
    for key, control in pairs(instance.controls) do
        local skip = control.hidden or control.disabled or not control.callback
        control.focused = not skip and (key == instance.keymap[instance.focusedKey].key)
        if control.focused then
            found_focus = true
        end
    end

    if not found_focus then
        focusPrev(instance, (loop_limit or 0) + 1)
    end

end

--- Moves focus to the element with a given key.
-- This function is used internally by the collection.
--
-- @tparam table instance
-- The widget collection instance to work on.
--
-- @tparam string key
-- The key of the widget to get
local function focusByKey(instance, key)

    for i, map in ipairs(instance.keymap) do
        if map.key == key then
            instance.focusedKey = i
        end
    end

end

--- Add a button to the collection.
--
-- @tparam string key
-- The key of the button to add to the collection.
--
-- @tparam table parameters
-- The button parameters to pass to the button constructor.
--
-- @treturn button.instance
-- The created button element.
--
-- @see get
function widgetcollection:button(key, parameters)

    self.controls[key] = buttonModule:new(parameters)
    mapkeys(self)
    focusFirst(self)
    return self.controls[key]

end


function widgetcollection:label(key, parameters)

    self.controls[key] = labelModule:new(parameters)
    mapkeys(self)
    focusFirst(self)
    return self.controls[key]

end

function widgetcollection:slider(key, parameters)

    self.controls[key] = sliderModule:new(parameters)
    mapkeys(self)
    focusFirst(self)
    return self.controls[key]

end


--- Get the element in the collection that matches a key.
--
-- @tparam string key
-- The key of the element to find.
--
-- @treturn button.instance
-- The element instance.
function widgetcollection:get(key)

    return self.controls[key]

end

--- Process key presses to allow navigation with the TAB key
-- and selection with the RETURN key.
function widgetcollection:keypressed(key)

    if key == "tab" then
        local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
        if shift then
            focusPrev(self)
        else
            focusNext(self)
        end
    elseif key == "return" or key == "kpenter" then
        local control = self.controls[self.keymap[self.focusedKey].key]
        control:mousepressed()
    end

end

function widgetcollection:keyreleased(key,scancode)
    if key == "return" or key == "kpenter" then
        local control = self.controls[self.keymap[self.focusedKey].key]
        control:mousereleased()
    end
end

--- Process click/touch movement on all elements in the collection.
function widgetcollection:mousemoved(x, y, dx, dy, istouch)

    for key, control in pairs(self.controls) do
        control:mousemoved(x, y, dx, dy, istouch)
    end

end

--- Process click/touch presses on all elements in the collection.
function widgetcollection:mousepressed(x, y, button, istouch)

    for key, control in pairs(self.controls) do
        control:mousepressed(x, y, button, istouch)
    end

end

--- Process click/touch releases on all elements in the collection.
function widgetcollection:mousereleased(x, y, button, istouch)

    for key, control in pairs(self.controls) do
        control:mousereleased(x, y, button, istouch)
        -- move focus to touched control
        if control.focused then
            focusByKey(self, key)
        end
    end

end

--- Process updates on all elements in the collection.
--
-- @tparam number dt
-- delta time as given by Love
function widgetcollection:update(dt)

    for key, control in pairs(self.controls) do

        -- update control state
        control:update(dt)

    end

end

--- Process drawing on all elements in the collection.
function widgetcollection:draw()

    -- save state
    love.graphics.push()

    for key, control in pairs(self.controls) do
        control:draw()
    end

    -- restore state
    love.graphics.pop()

end

return module
