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

--- Provides a chart display.
-- This module returns a constructor function that should be called
-- to create a new chart.
--
-- @author Wesley Werner
-- @license GPL v3
-- @module chart


--- A table of data points that represent the chart.
-- @table pointdefinition
--
-- @tfield number a
-- The value on the horizontal axiz.
--
-- @tfield number b
-- The value on the vertical axiz.


--- Defines label data for you to draw.
-- @table labeldefinition
--
-- @tfield string text
-- The label text.
--
-- @tfield number x
-- The x position of the label.
--
-- @tfield number y
-- The y position of the label.


--- Defines a point in a line.
--
-- @table chartnode
--
-- @tfield number x
-- The x screen position of the point.
--
-- @tfield number y
-- The y screen position of the point.
--
-- @tfield number a
-- The horizontal axiz value of the point.
--
-- @tfield number b
-- The vertical axiz value of the point.
--
-- @tfield bool focus
-- If the point is under the mouse cursor.


local chart = { }
local thispath = select('1', ...):match(".+%.") or ""
local tween = require(thispath.."tween")

--- Clears all data points from the chart.
function chart:clear()

    self.datapoints = { }

end

--- Add data points to the chart.
-- Calling this multiple times adds new datasets to the chart.
--
-- @tparam pointdefinition points
-- The list of points in the dataset.
--
-- @tparam string name
-- The dataset name.
function chart:data(points, name)

    local xmin, ymin, xmax, ymax = math.huge, math.huge, 0, 0

    -- get the min and max values
    for _, p in ipairs(points) do
        if p.a < xmin then xmin = p.a end
        if p.b < ymin then ymin = p.b end
        if p.a > xmax then xmax = p.a end
        if p.b > ymax then ymax = p.b end
    end

    --print(string.format("min/max = %d/%d", ymin, ymax))

    -- scale of the chart
    self.scaleX = self.width / (xmax - xmin)
    self.scaleY = self.height / math.max(1, ymax - ymin)

    -- normalize values to the chart size
    local processed = { }

    for _, p in ipairs(points) do

        local sx = self.scaleX * (p.a - xmin)
        local sy = self.height - (self.scaleY * (p.b - ymin))

        local newpoint = {
            a=p.a,
            b=p.b,
            x=sx,
            y=self.height,
            focus=false
        }
        table.insert(processed, newpoint)

        newpoint.tween = tween.new(1, newpoint, { y=sy }, "outCubic")

        --print(string.format("point %d/%d == %d/%d", p.a, p.b, sx, sy))

    end

    table.insert(self.datapoints, { name=name, points=processed } )

    --print(string.format("scales: %.2f/%.2f", self.scaleX, self.scaleY))

    -- create labels
    self.labels = { }

    -- y axiz
    if ymax > ymin then
        local segments = 6
        local step = (ymax - ymin) / segments
        for n=1, segments do
            local value = (n * step) + ymin
            local sx = 0
            local sy = math.floor(self.height - (self.height * (n / segments)))
            table.insert(self.labels, { x=sx, y=sy, text=value, axiz="y" })
        end
    end

    -- x axiz
    if xmax > xmin then
        local segments = 6
        local step = (xmax - xmin) / segments
        for n=1, segments do
            local value = (n * step) + xmin
            local sx = math.floor(self.width * (n / segments) )
            local sy = self.height
            table.insert(self.labels, { x=sx, y=sy, text=value, axiz="x" })
        end
    end

    -- clear the focused node
    self.focusedNode = nil

end

--- Process mouse movement to allow focus on data points.
function chart:mousemoved(x, y, dx, dy, istouch)

    -- the focus radius around a node
    local radius = 10

    -- clear the focused node
    self.focusedNode = nil

    for _, data in ipairs(self.datapoints) do

        for _, p in ipairs(data.points) do

            -- reset focus
            p.focus = false

            -- stop if we already have one focused
            if self.focusedNode == nil then

                local inX = x > (p.x - radius) and x < (p.x + radius)
                local inY = y > (p.y - radius) and y < (p.y + radius)
                p.focus = inX and inY

                -- track the focused item
                if p.focus then self.focusedNode = { name=data.name, point=p } end

            end

        end

    end

end

--- Process chart animations.
--
-- @tparam number dt
-- delta time as given by Love
function chart:update(dt)

    for _, data in ipairs(self.datapoints) do
        for _, point in ipairs(data.points) do
            point.tween:update(dt)
        end
    end

end

--- Draw the chart.
-- This calls the chart drawing functions that you should overwrite.
--
-- @see drawBorder
-- @see drawFill
-- @see drawGrid
-- @see drawNode
-- @see drawLabels
-- @see drawLine
function chart:draw()

    -- save state
    love.graphics.push()

    self:drawGrid(self.width, self.height)
    self:drawBorder(self.width, self.height)
    self:drawLabels(self.labels)

    -- process data points
    for _, data in ipairs(self.datapoints) do

        -- fill area
        if #data.points > 0 then
            local fillpoints = { 0, self.height }
            for _, p in ipairs(data.points) do
                table.insert(fillpoints, p.x)
                table.insert(fillpoints, p.y)
            end
            table.insert(fillpoints, self.width)
            table.insert(fillpoints, self.height)
            -- triangulate the points to avoid concave polygons
            local triangles = love.math.triangulate(fillpoints)
            self:drawFill(data.name, triangles)
        end

        -- draw the chart lines.
        -- skip first point as they come in pairs.
        for n=2, #data.points do

            self:drawLine(data.name,
                {
                    a=data.points[n-1].a,
                    b=data.points[n-1].b,
                    x=data.points[n-1].x,
                    y=data.points[n-1].y,
                    focus=data.points[n-1].focus
                },
                {
                    a=data.points[n].a,
                    b=data.points[n].b,
                    x=data.points[n].x,
                    y=data.points[n].y,
                    focus=data.points[n].focus
                }
            )

        end

    end

    -- draw joint nodes
    for _, data in ipairs(self.datapoints) do
        for n, point in ipairs(data.points) do
            self:drawNode(data.name, point)
        end
    end

    -- draw the focused node last so it sits on top of other drawings
    if self.focusedNode then
        self:drawNode(self.focusedNode.name, self.focusedNode.point)
    end

    -- restore state
    love.graphics.pop()

end

--- Callback to draw the grid.
-- You must overwrite this function to draw your own.
--
-- @tparam table chart
-- The chart instance.
--
-- @tparam number width
-- The width of the chart.
--
-- @tparam number height
-- The height of the chart.
function chart.drawGrid(chart, width, height)

    love.graphics.setColor(32, 32, 32)

    for x=0, width, 20 do
        love.graphics.line(x, 0, x, height)
    end
    for y=0, height, 20 do
        love.graphics.line(0, y, width, y)
    end

end

--- Callback to draw the axiz label.s
-- You must overwrite this function to draw your own.
--
-- @tparam table chart
-- The chart instance.
--
-- @tparam labeldefinition labels
-- A list of @{labeldefinition} items that you must draw.
function chart.drawLabels(chart, labels)

    love.graphics.setColor(255, 255, 255)

    for _, label in ipairs(labels) do

        -- draw label point
        love.graphics.circle("line", label.x, label.y, 3)

        -- print label text
        if label.axiz == "x" then
            love.graphics.print(label.text, label.x, label.y + 12)
        else
            love.graphics.print(label.text, label.x - 24, label.y - 6)
        end

    end

end

--- Callback to draw the border.
-- You must overwrite this function to draw your own.
--
-- @tparam table chart
-- The chart instance.
--
-- @tparam number width
-- The width of the chart.
--
-- @tparam number height
-- The height of the chart.
function chart.drawBorder(chart, width, height)

    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", 0, 0, width, height)

end

--- Callback to draw the lines.
-- You must overwrite this function to draw your own.
--
-- @tparam table chart
-- The chart instance.
--
-- @tparam string dataset
-- The name of the dataset currently drawn.
--
-- @tparam chartnode node1
-- The first node in the line segment to draw.
--
-- @tparam chartnode node2
-- The second node in the line segment to draw.
function chart.drawLine(chart, dataset, node1, node2)

    love.graphics.setColor(255, 255, 255)
    --love.graphics.setLineWidth(4)
    love.graphics.line(node1.x, node1.y, node2.x, node2.y)
    --love.graphics.setLineWidth(1)

end

--- Callback to draw the joins between lines.
-- You must overwrite this function to draw your own.
--
-- @tparam table chart
-- The chart instance.
--
-- @tparam string dataset
-- The name of the dataset currently drawn.
--
-- @tparam chartnode node
-- The node on a join between line segments.
function chart.drawNode(chart, dataset, node)

    love.graphics.setColor(255, 255, 255)

    if node.focus then
        love.graphics.circle("fill", node.x, node.y, 6)
        -- tooltip
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", node.x + 20, node.y - 4, 90, 40)
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("line", node.x + 20, node.y - 4, 90, 40)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(string.format("point: %.2f\nvalue: %.2f", node.a, node.b),
            math.floor(node.x + 24), math.floor(node.y))
    else
        love.graphics.circle("line", node.x, node.y, 6)
    end

end

--- Callback to fill the area under the lines.
-- You must overwrite this function to draw your own.
--
-- @tparam table chart
-- The chart instance.
--
-- @tparam string dataset
-- The name of the dataset currently drawn.
--
-- @tparam table triangles
-- The collection of points to fill.
-- To avoid concave polygons, the chart points are triangulated into
-- this set of points that must be iterated over.
function chart.drawFill(chart, dataset, triangles)

    love.graphics.setColor(255, 255, 255, 128)

    for _, triangle in ipairs(triangles) do
        love.graphics.polygon("fill", triangle)
    end

end

return function (width, height)

    local instance = { }
    setmetatable(instance, {__index = chart } )
    instance.datapoints = { }
    instance.labels = { }
    instance.width = width
    instance.height = height
    return instance

end
