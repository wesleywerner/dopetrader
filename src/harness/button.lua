--[[
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

--- Provides a clickable button.
-- This acts similar to a @{hotspot}, with the exception you don't
-- specify the size, which is automatically measured from the button text.
-- It provides high flexibility as shown in @{switch-example.lua}
--
-- @author Wesley Werner
-- @license GPL v3
-- @module button

local module = { }

local module_mt = { }

--- A table of arguments for new instances.
-- In addition to the mentioned parameters, you can add any other keys
-- you want. All keys are copied to the instance, which allows
-- you to access them later through the instance.
--
-- @table args
--
-- @tfield number left
-- The left screen position.
--
-- @tfield number top
-- The top screen position.
--
-- @tfield function callback
-- The function fired when this control has focus and click/touch
-- is released on it.
--
-- @tfield string text
-- The text of the button. This is measured (with the current font)
-- to determine the element size.

--- Lists properties available on the instance.
-- @table instance
--
-- @tfield bool focused
-- true while the focus is over the button. This is determined
-- while you call @{mousemoved}
--
-- @tfield bool down
-- true while a click/touch is pressed on the button. This is determined
-- while you call @{mousepressed}
--
-- @tfield number left
-- The x position
--
-- @tfield number top
-- The y position
--
-- @tfield number width
-- The width of the element as calculated from the measured text
--
-- @tfield number height
-- The height of the element as calculated from the measured text
--
-- @tfield function callback
-- The function fired when this control has focus and click/touch
-- is released on it.


--- Creates a new instance.
--
-- @tparam args args
-- A table of arguments.
--
-- @treturn instance
function module:new(args)

    if not args.top or not args.left or not args.text then
        error("Button must have text, top and left")
    end

    local instance = { }

    instance.alignment = "center"
    instance.text_color = {0, 1, 1}
    instance.fill_color = {0, .2, .2}
    instance.disabled_color = {.7, .7, .7}

    -- copy arguments to the instance
    for k, v in pairs(args) do
        -- ensure callback is always a function
        if k == "callback" then
            if type(v) == "function" then
                instance[k] = v
            end
        else
            instance[k] = v
        end
    end

    -- apply instance functions
    setmetatable(instance, { __index = module_mt })

    -- centre text vertically by measure
    local measure_font = instance.font or love.graphics.getFont()
    local sample_width, sample_height = love.graphics.newText(measure_font, "XXX"):getDimensions()
    instance.y_offset = (instance.height / 2) - (sample_height / 2)

    local osname = love.system.getOS()
    instance.mobile = osname == "Android" or osname == "iOS"

    -- pad right aligned
    instance.title_padding = 10
    if instance.alignment == "right" then
        instance.right_padding = 10
    else
        instance.right_padding = 0
    end

    return instance

end

--- Tests if a point is over the element.
-- Used internally by @{mousemoved}
--
-- @tparam number x
-- The x position to test against
--
-- @tparam number y
-- The y position to test against
--
-- @treturn bool
-- true if the point is over the element
function module_mt:testFocus(x, y)

    return x > self.left and x < self.left + self.width
        and y > self.top and y < self.top + self.height

end

--- Placeholder function.
-- This element does not draw anything, this is user controlled
function module_mt.draw(self)
    if self.hidden then
        return
    end
    love.graphics.push()
    if self.down then
        love.graphics.translate(1, 2)
    end
    if self.disabled then
        -- no fill
    elseif self.focused or self.down then
        love.graphics.setColor(self.text_color)
        love.graphics.rectangle("fill", self.left, self.top, self.width, self.height)
    else
        love.graphics.setColor(self.fill_color)
        love.graphics.rectangle("fill", self.left, self.top, self.width, self.height)
    end
    -- border
    love.graphics.setColor(self.text_color)
    love.graphics.rectangle("line", self.left, self.top, self.width, self.height)
    -- text color
    if self.disabled then
        love.graphics.setColor(self.disabled_color)
    elseif self.focused or self.down then
        love.graphics.setColor(0, 0, 0)
    else
        love.graphics.setColor(self.text_color)
    end
    -- prevent font printing black outlines over current canvas
    --love.graphics.setBlendMode("alpha")
    if self.font then
        love.graphics.setFont(self.font)
    end
    if self.title then
        love.graphics.print(self.title, self.left + self.title_padding, self.top + self.y_offset)
    end
    love.graphics.printf(self.text, self.left, self.top + self.y_offset, self.width - self.right_padding, self.alignment)
    love.graphics.pop()
end

--- Placeholder function.
-- This element does not process any updates
--
-- @tparam number dt
-- delta time as given by Love
function module_mt:update(dt)
    if self.down and self.repeating and not self.disabled and not self.hidden then
        self.down_tics = self.down_tics - dt
        if self.down_tics < 0 then
            love.system.vibrate(.015)
            for n=1, self.repeating do
                self.callback(self)
            end
            self.down_tics = 0.15
            self.has_repeated = true
        end
    end
end

--- Process mouse/touch movement.
-- Call this from your main loop so the element knows when it has
-- focus, which flags the "focused" property true.
function module_mt:mousemoved(x, y, dx, dy, istouch)

    self.focused = self:testFocus(x, y)

end

--- Process pressed clicks/touches.
-- Call this from your main loop so the element knows when it is
-- pressed on, which flags the "down" property true.
function module_mt:mousepressed(x, y, button, istouch)

    if not self.disabled and not self.hidden then
        -- retest focus if position is given
        -- (widget collection may call without position for keyboard click)
        if x and y then
            self.focused = self:testFocus(x, y)
        end
        self.down = self.focused
        if self.down then
            self.down_tics = 0.4
            self.has_repeated = false
        end
    end

end

--- Process click/touch releases.
-- Call this from your main loop so the element knows when a press
-- is released from it, which flags the "down" property false
-- and fires the "callback" function if it is present.
function module_mt:mousereleased(x, y, button, istouch)

    if self.down and self.focused and self.callback and not self.has_repeated then
        love.system.vibrate(.015)
        self.callback(self)
    end

    -- unfocus for mobile
    if self.mobile then
        self.focused = false
    end
    self.down = false

end

return module
