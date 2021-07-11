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

--- Provides a label control.
--
-- @author Wesley Werner
-- @license GPL v3
-- @module label

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
-- The text of the label. This is measured (with the current font)
-- to determine the element size.

--- Lists properties available on the instance.
-- @table instance
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

    if not args.top or not args.left or not args.text then
        error("Label must have text, top and left")
    end

    local instance = { }

    instance.border = true
    instance.alignment = "center"
    instance.text_color = {0, 1, 1}

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
    instance:set_alignment(instance.alignment)

    return instance

end

function module_mt:set_alignment(value)
    if value then
        self.alignment = value
        if self.alignment == "right" then
            self.right_padding = 10
        else
            self.right_padding = 0
        end
    end
end

function module_mt:set_font(font)
    self.font = font
    local sample_width, sample_height = love.graphics.newText(font, "Test"):getDimensions()
    self.y_offset = (self.height / 2) - (sample_height / 2)
end


--- Placeholder function.
-- This element does not draw anything, this is user controlled
function module_mt.draw(self)
    if self.hidden then
        return
    end
    love.graphics.setColor(self.text_color)
    -- border
    if self.border then
        love.graphics.rectangle("line", self.left, self.top, self.width, self.height)
    end
    -- prevent font printing black outlines over current canvas
    --love.graphics.setBlendMode("alpha")
    if self.font then
        love.graphics.setFont(self.font)
    end
    if self.title then
        love.graphics.print(self.title, self.left + self.title_padding, self.top + self.y_offset)
    end
    if self.valign == "top" then
        love.graphics.printf(self.text, self.left, self.top, self.width - self.right_padding, self.alignment)
    else
        love.graphics.printf(self.text, self.left, self.top + self.y_offset, self.width - self.right_padding, self.alignment)
    end
end

--- No functionality
function module_mt:update(dt)

end

--- No functionality
function module_mt:mousemoved(x, y, dx, dy, istouch)

end

--- No functionality
function module_mt:mousepressed(x, y, button, istouch)

end

--- No functionality
function module_mt:mousereleased(x, y, button, istouch)

end

return module
