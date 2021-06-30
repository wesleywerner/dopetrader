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

--- Provides a rolling number display.
-- The digit roller simply watches a value on a table for changes.
-- The roller then interpolates the displayed
-- value via a tween, so it appears to count up or down.
--
-- @author Wesley Werner
-- @license GPL v3
-- @module digitroller

local thispath = select('1', ...):match(".+%.") or ""
local tween = require(thispath.."tween")
local module = {}
local digitroller = {}

--- A table of arguments for new digit rollers.
-- @table args
--
-- @tfield table subject
-- The table to watch.
--
-- @tfield string target
-- The key on the table to watch.
--
-- @tfield[opt] number duration
-- The time in seconds the rolling animation will last.
-- The default is 1 second.
--
-- @tfield string easing
-- The name of easing function to use for the rolling animation.
--
-- List of easing functions: https://github.com/kikito/tween.lua#easing-functions


--- Lists properties available on the instance.
-- @table instance
--
-- @tfield number value
-- Represents the current display value of the digit roller.


--- Create a digit roller.
--
-- @tparam args args
--
-- @treturn instance
-- A digit roller instance.
function module:new(args)

  if not args.subject then
    error("A digit roller must have a subject, a table to watch")
  end

  if not args.target then
    error("A digit roller must have a target, the property on the subject to watch")
  end

  if type(args.subject[args.target]) ~= "number" then
    error("A digit roller target must be a number value")
  end

  local instance = {}

  -- copy arguments to the instance
  for k, v in pairs(args) do
    instance[k] = v
  end

  -- set defaults
  instance.top = instance.top or 0
  instance.left = instance.left or 0
  instance.duration = instance.duration or 1
  instance.easing = instance.easing or "outCubic"
  instance.value = instance.subject[instance.target]
  instance.targetvalue = instance.subject[instance.target]

  -- apply instance functions
  setmetatable(instance, { __index = digitroller })

  -- apply first time tweening
  instance:applytween()

  return instance

end

--- Process animations.
-- Call this in you main game loop.
--
-- @tparam number dt
-- Time delta as given by the Love callback
function digitroller:update(dt)
  self.tween:update(dt)
  if self.targetvalue ~= self.subject[self.target] then
    self.targetvalue = self.subject[self.target]
    self:applytween()
  end
end

function digitroller:applytween()
  self.tween = tween.new(self.duration, self, { value=self.targetvalue }, self.easing)
end

return module
