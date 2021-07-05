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
-- @module slider

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


--- Creates a new instance.
--
-- @tparam args args
-- A table of arguments.
--
-- @treturn instance
function module:new(args)

    if not args.top or not args.left then
        error("Slider must have text, top and left")
    end

    local instance = { }

    instance.symbol = "$"
    instance.alignment = "center"
    instance.text_color = {0, 1, 1}
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

    instance.slider_y = instance.top + math.floor(instance.height / 2)
    instance.slider_x1 = instance.left
    instance.slider_x2 = instance.left + instance.width
    instance.slider_position = instance.slider_x2
    instance.text = instance.value

    -- centre text vertically by measure
    local measure_font = instance.font or love.graphics.getFont()
    local font_width, font_height = love.graphics.newText(measure_font, "$"):getDimensions()
    instance.font_height = font_height
    instance.symbol_xoffset = math.floor(font_width / 2)
    instance.symbol_yoffset = math.floor(font_height / 2)
    instance.text_y = instance.slider_y - (instance.font_height * 2)

    local osname = love.system.getOS()
    instance.mobile = osname == "Android" or osname == "iOS"

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
        love.graphics.translate(0, 2)
    end

    love.graphics.setColor(self.text_color)

    if self.font then
        love.graphics.setFont(self.font)
    end

    love.graphics.line(self.slider_x1, self.slider_y, self.slider_x2, self.slider_y)
    love.graphics.print(self.symbol, self.slider_position - self.symbol_xoffset, self.slider_y - self.symbol_yoffset)

    -- border
    --if self.focused then
        --love.graphics.rectangle("line", self.left, self.top, self.width, self.height)
    --end

    love.graphics.pop()
    love.graphics.printf(self.text, self.slider_x1, self.text_y, self.width, "center")

end

--- Placeholder function.
-- This element does not process any updates
--
-- @tparam number dt
-- delta time as given by Love
function module_mt:update(dt)

end

--- Process mouse/touch movement.
-- Call this from your main loop so the element knows when it has
-- focus, which flags the "focused" property true.
function module_mt:mousemoved(x, y, dx, dy, istouch)

    self.focused = self:testFocus(x, y)

    if self.down and self.focused then
        self.slider_position = math.max(self.slider_x1, math.min(self.slider_x2, x))
        self:calculate_value_from_position()
    end

end

--- Process pressed clicks/touches.
-- Call this from your main loop so the element knows when it is
-- pressed on, which flags the "down" property true.
function module_mt:mousepressed(x, y, button, istouch)

    if not self.disabled and not self.hidden then
        self.down = self.focused
    end

    if self.down and self.focused then
        self.slider_position = math.max(self.slider_x1, math.min(self.slider_x2, x))
        self:calculate_value_from_position()
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

function module_mt:set_maximum(maximum_value)
    self.maximum = maximum_value
    self.slider_position = self.slider_x2
    self:calculate_value_from_position()
end

function module_mt:calculate_value_from_position()
    local position_factor = math.ceil((self.slider_position - self.slider_x1) / 10)
    local width_factor = math.ceil(self.width / 10)
    local ratio = position_factor / width_factor
    self.value = math.ceil(self.maximum * ratio)
    if self.format_function then
        self.text = self.format_function(self.value)
    else
        self.text = self.value
    end
end

return module
