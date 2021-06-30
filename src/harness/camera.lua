--[[
   camera.lua

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

--- Provides a camera to limit drawing to arbitrary positions.
-- @module camera

local module = {

    -- a value 0..1 indicating progress of the camera start..end position
    frames = 0,

    -- the time in seconds the movement should take
    time = 1,

    -- camera goal on screen
    targetX = 0,
    targetY = 0,

    -- camera actual on screen
    x = 0,
    y = 0,

    -- camera frame size and position
    frameWidth = love.graphics.getWidth( ),
    frameHeight = love.graphics.getHeight( ),
    frameTop = 0,
    frameLeft = 0,

    worldWidth = love.graphics.getWidth( ),
    worldHeight = love.graphics.getHeight( ),

}

local function clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

local function lerp(a, b, amount)
  return a + (b - a) * clamp(amount, 0, 1)
end

local function distance(x1, y1, x2, y2, squared)
  local dx = x1 - x2
  local dy = y1 - y2
  local s = dx * dx + dy * dy
  return squared and s or math.sqrt(s)
end

--- Updates camera motion
--
-- @tparam number dt
function module:update(dt)

    if (self.x ~= self.targetX) or (self.y ~= self.targetY) then
        self.frames = self.frames + (dt / self.time)

        -- move the camera
        self.x = lerp(self.fromX, self.targetX, self.frames)
        self.y = lerp(self.fromY, self.targetY, self.frames)

    end

end

--- Set the world size that the camera can scroll within.
-- Camera movement is constrained within this size.
--
-- @tparam number width
-- @tparam number height
function module:worldSize(width, height)

    self.worldWidth = width
    self.worldHeight = height

end

--- Set the size of the frame visible through the camera.
--
-- @tparam number left
-- @tparam number top
-- @tparam number width
-- @tparam number height
function module:frame(left, top, width, height)

    self.frameLeft = left
    self.frameTop = top
    self.frameWidth = width
    self.frameHeight = height

end

--- Scroll the camera to a position in it's world.
--
-- @tparam number x
-- @tparam number y
function module:lookAt(x, y)

    -- we only update the movement if the target is new
    if self.targetX ~= x or self.targetY ~= y then
        self.frames = 0
        self.fromX = self.x
        self.fromY = self.y

        -- clamp to the world
        self.targetX = clamp(x, - self.worldWidth + self.frameWidth, 0 )
        self.targetY = clamp(y, - self.worldHeight + self.frameHeight, 0 )

        -- the time taken to move the camera is a function of distance over the smallest world side.
        -- this means smaller movements happen slower.
        local dist = distance(self.x, self.y, x, y, false) / math.min( self.worldHeight, self.worldWidth )
        dist = math.exp(dist)
        -- limit the time to sane values
        self.time = clamp(dist, 0.5, 6)
    end

end

--- Point the camera to a position with instant results.
--
-- @tparam number x
-- @tparam number y
function module:instant(x, y)

    self.frames = 0
    self.x = x
    self.y = y
    self.fromX = x
    self.fromY = y

    -- clamp to the world
    self.targetX = clamp(x, - self.worldWidth + self.frameWidth, 0 )
    self.targetY = clamp(y, - self.worldHeight + self.frameHeight, 0 )

    self.time = 1

end

--- Move the camera position relative to it's current position.
--
-- @tparam number dx
-- @tparam number dy
function module:moveBy(dx, dy)

   self:lookAt(self.targetX + dx, self.targetY + dy)

end

--- Center the camera frame on a position.
--
-- @tparam number x
-- @tparam number y
function module:center(x, y)

    local dx = - x + (self.frameWidth / 2)
    local dy = - y + (self.frameHeight / 2)
    self:lookAt(dx, dy)

end

--- Prepare for drawing the contents of the camera world
-- This applies transforms and clipping.
function module:pose()

    love.graphics.push()
    love.graphics.translate(self.x + self.frameLeft, self.y + self.frameTop)
    love.graphics.setScissor( self.frameLeft, self.frameTop, self.frameWidth, self.frameHeight )

end

--- Relax the camera when done drawing world contents.
-- This releases transform and clipping, restoring normal drawing state.
function module:relax()

    love.graphics.setScissor()
    love.graphics.pop()

end

--- Convert a screen point to a point relative to the camera's frame.
--
-- @tparam number x
-- @tparam number y
--
-- @treturn number
-- x, y or nil if the given point is outside the frame.
function module:pointToFrame(x, y)

    if x < self.frameLeft or x > self.frameLeft + self.frameWidth then
        return nil
    end

    if y < self.frameTop or y > self.frameTop + self.frameHeight then
        return nil
    end

    return clamp(x - self.x - self.frameLeft, 0, self.worldWidth),
        clamp(y - self.y - self.frameTop, 0, self.worldHeight)

end

return module
