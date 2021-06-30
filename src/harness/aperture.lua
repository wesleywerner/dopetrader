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

--- Provides a scrollable view.
-- Like the photographer who touches the tips of her thumbs together, framing a shot.
--
-- @author Wesley Werner
-- @license GPL v3
-- @module aperture

local module = {}
local thispath = select('1', ...):match(".+%.") or ""
local tween = require(thispath.."tween")
local aperture = {}

--- A table of arguments for new apertures.
-- In addition to the mentioned parameters, you can add any other keys
-- you want. All keys are copied to the aperture instance, which allows
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
-- @tfield number width
-- The width in pixels.
--
-- @tfield number height
-- The height in pixels.
--
-- @tfield[opt] number pages
-- Sets the total number of pages available to scroll through.
--
-- @tfield[opt] number duration
-- The time in seconds the scroll animation lasts.
-- The default is 1 second.
--
-- @tfield[opt] string easing
-- The easing function used for the scroll animation.
-- The default is "outCubic".
--
-- @tfield[opt] bool landscape
-- Landscape controls horizontal scrolling.
-- The default is false (vertical scrolling).
--
--
-- @tfield[opt] number factor
-- The size of each scroll step. You can set this to a fraction too.
-- The default is 1 and scrolls a full page each time.
-- A factor of 0.5 steps half a page at a time.


--- Lists properties available on the aperture instance.
-- @table instance
--
-- @tfield bool focused
-- true while the cursor is over the aperture. This is determined automatically
-- while you call @{mousemoved}
--
-- @tfield table hotspots
-- A collection of @{hotspot}s contained within the aperture that were added
-- via the @{insert} function.


--- Creates a new aperture.
--
-- @tparam args args
-- A table of arguments.
--
-- @treturn instance
-- A new aperture instance
function module:new(args)

  local instance = { }

  -- copy arguments to the instance
  for k, v in pairs(args) do
    instance[k] = v
  end

  -- set defaults
  instance.duration = instance.duration or 1
  instance.pages = instance.pages or 1
  instance.easing = instance.easing or "outCubic"
  instance.factor = instance.factor or 1
  instance.yoffset = 0
  instance.xoffset = 0
  instance.page = 1

  -- keep a collection of embedded hotspots
  instance.hotspots = {}

  -- apply instance functions
  setmetatable(instance, { __index = aperture })

  -- apply first time tweening
  instance:applytween()

  return instance

end

--- Inserts a control into the aperture.
-- This can be a hotspot, button or switch.
--
-- @tparam hotspot hotspot
-- The @{hotspot} to insert.
function aperture:insert(hotspot)
  table.insert(self.hotspots, hotspot)
end

--- Process apeture animations.
-- Call this in you main game loop.
--
-- @tparam number dt
-- Time delta as given by the Love callback
function aperture:update(dt)
  self.complete = self.tween:update(dt)
end

--- Converts screen coordinates to local points.
--
-- @tparam number x
-- The x point to convert.
--
-- @tparam number y
-- The y point to convert.
--
-- @treturn number
-- The converted x, y points as two output parameters.
function aperture:pointFromScreen(x, y)
  return x - self.left - self.xoffset, y - self.top - self.yoffset
end

--- Apply transforms and clipping.
-- Call this to begin drawing inside the aperture. This ensures anything drawn
-- will be constrained to within the aperture size and position on screen.
-- Drawing positions are relative to the aperture.
--
-- @see release
function aperture:apply()

  -- clip anything drawn
  love.graphics.stencil(function()
    love.graphics.rectangle("fill",
      self.left, self.top,
      self.width, self.height)
  end, "replace", 1)

  -- Only allow rendering on pixels which have a stencil value greater than 0.
  love.graphics.setStencilTest("greater", 0)

  -- scroll all drawing
  love.graphics.push()

  love.graphics.translate( self.left + self.xoffset, self.top + self.yoffset )

end

--- Release transforms and clippings.
-- Call this when you are done drawing aperture contents.
--
-- @see apply
function aperture:release()
  love.graphics.pop()
  love.graphics.setStencilTest()
end

--- Scroll the aperture one page up.
function aperture:scrollUp()
  if self.complete and self.focused then
    self.complete = false
    self.page = math.max(1, self.page - self.factor)
    self:applytween()
  end
end

--- Scroll the aperture one page down.
function aperture:scrollDown()
  if self.complete and self.focused then
    self.complete = false
    self.page = math.min(self.pages, self.page + self.factor)
    self:applytween()
  end
end

--- Scroll the aperture one page left.
-- This function is a synonymn for @{scrollUp} and provided just for
-- readability. Useful for apertures that display in landscape mode.
--
-- @see args
function aperture:scrollLeft()
  self:scrollUp()
end

--- Scroll the aperture one page right.
-- This function is a synonymn for @{scrollDown} and provided just for
-- readability. Useful for apertures that display in landscape mode.
--
-- @see args
function aperture:scrollRight()
  self:scrollDown()
end

--- Scroll the aperture to the specified page.
-- The given page is clamped to the aperture's limits so it is safe to
-- give an out-of-bounds value.
--
-- @tparam number page
function aperture:scrollTo(page)

  -- clamp the desired page
  page = math.min(self.pages, math.max(1, page))

  if self.page ~= page then
    self.page = page
    self:applytween()
  end

end

--- Process mouse movement.
-- Call this from your game loop to let the aperture determine if
-- it is in focus via the "focused" property.
function aperture:mousemoved(x, y, dx, dy, istouch)

  self.focused = self:testFocus(x, y)

  -- touch any children hotspots with local coordinates
  x, y = self:pointFromScreen(x, y)

  for _, hotspot in ipairs(self.hotspots) do
    hotspot:mousemoved(x, y, dx, dy, istouch)
  end

end

--- Process mouse presses inside the aperture.
--
-- @see aperture:insert
function aperture:mousepressed(x, y, button, istouch)

  self.down = self.focused

  -- ignore clicks if this aperture is not active
  if not self.focused then return end

  for _, hotspot in ipairs(self.hotspots) do
    hotspot:mousepressed(x, y, button, istouch)
  end

end

--- Process mouse releases inside the aperture.
-- This is the function that triggers any callbacks on children controls.
--
-- @see aperture:insert
function aperture:mousereleased(x, y, button, istouch)

  self.down = false

  -- ignore clicks if this aperture is not active
  if not self.focused then return end

  for _, hotspot in ipairs(self.hotspots) do
    hotspot:mousereleased(x, y, button, istouch)
  end

end

-- Apply new animations.
-- This is an internal function used by the aperture to apply a new
-- tween animation when one of the scroll functions are called.
-- You should not need to call this.
function aperture:applytween()

  local xo = (self.page-1) * self.width * -1
  local yo = (self.page-1) * self.height * -1

  -- limit the tween direction depending on orientation
  if self.landscape then
    yo = 0
  else
    xo = 0
  end

  self.tween = tween.new(self.duration, self, { xoffset=xo, yoffset=yo }, self.easing)

end

function aperture:testFocus(x, y)

    return x > self.left and x < self.left + self.width
        and y > self.top and y < self.top + self.height

end

return module
