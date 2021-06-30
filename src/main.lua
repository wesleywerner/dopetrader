--[[
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:

   * Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above
     copyright notice, this list of conditions and the following disclaimer
     in the documentation and/or other materials provided with the
     distribution.
   * Neither the name of the  nor the names of its
     contributors may be used to endorse or promote products derived from
     this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

]]--

local TRADE_SIZE = 15
local LOCATIONS = {"Bronx", "Ghetto", "Central Park",
                    "Manhattan", "Coney Island", "Brooklyn" }

local display = {}
local layout = {}
local player = {}
local market = {}
local view = {}
local trenchcoat = {}
local util = {}

-- TODO
-- NOTES:
-- + the play screen drawing should not be tied to a state
--   so it can be called from multiple states.
--   in fact any drawing routines should be housed separate from state.
local intro_state = {}
local play_state = {}
local jet_state = {}
local cops_state = {}
local scores_state = {}
local active_state = {}

function love.load()

    display:load()
    layout:load()
    player:load()
    market:load()
    view:load()

    play_state:load()

    touchpos = {x=0, y=0}
    touchrel = {x=0, y=0}

    active_state = play_state
end

function love.keypressed(key, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button, istouch)
    touchpos = {x=x, y=y}
    active_state:mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    touchrel = {x=x, y=y}
    active_state:mousereleased(x, y, button, istouch)
end

function love.mousemoved(x, y, dx, dy, istouch)
    active_state:mousemoved(x, y, dx, dy, istouch)
end

function love.update(dt)
    if dt < 1/15 then
        love.timer.sleep(1/15 - dt)
    end
    active_state:update(dt)
end

function love.draw()

    ---- white border
    --love.graphics.setColor({1, 1, 1, .2})
    --love.graphics.rectangle("line",
        --display.safe_x + 10,
        --display.safe_y + 10,
        --display.safe_w - 20,
        --display.safe_h - 20)

    ---- system info
    --love.graphics.setColor({1, 1, 1, .2})

    --local template = [[
    --Love for Android NFO
    --Screen Size: %d x %d
    --DPI Scale: %d
    --Scaled Screen: %d x %d
    --FPS: %d
    --Touched XY: %d, %d
    --Released XY: %d, %d
    --OS: %s
    --]]

    --local details = string.format(template,
        --display.width, display.height,
        --display.dpi,
        --display.width * display.dpi, display.height * display.dpi,
        --love.timer.getFPS(),
        --touchpos.x, touchpos.y,
        --touchrel.x, touchrel.y,
        --love.system.getOS()
        --)

    --love.graphics.printf(details, 0, display.height/2, display.width, 'center')

    active_state:draw()

end


--      _ _           _
--   __| (_)___ _ __ | | __ _ _   _
--  / _` | / __| '_ \| |/ _` | | | |
-- | (_| | \__ \ |_) | | (_| | |_| |
--  \__,_|_|___/ .__/|_|\__,_|\__, |
--             |_|            |___/
--

function display.load(self)

    display.dpi = love.graphics.getDPIScale()

    -- flip wh for portrait orientation
    display.height, display.width = love.graphics.getDimensions()

    -- flip xy, wh for portrait orientation
    display.safe_y, display.safe_x, display.safe_h, display.safe_w = love.window.getSafeArea()

    -- keep the notification and navigation bars
    love.window.setMode(display.width, display.height)

    love.graphics.setBlendMode("replace")

end

--    _      _         _        _
--   (_) ___| |_   ___| |_ __ _| |_ ___
--   | |/ _ \ __| / __| __/ _` | __/ _ \
--   | |  __/ |_  \__ \ || (_| | ||  __/
--  _/ |\___|\__| |___/\__\__,_|\__\___|
-- |__/
--
function jet_state.load(self)

end

function jet_state.update(self, dt)

end

function jet_state.switch(self)
    for _, butt in ipairs(view.jet_buttons) do
        butt.disabled = butt.text == player.location
    end
    active_state = jet_state
end

function jet_state.draw(self)
    --view:draw_player_stats()
    --view:draw_market()
    view:set_large_font()
    love.graphics.printf("Where to?", 0, display.height/3, display.width, "center")
    view:set_medium_font()
    for _, butt in ipairs(view.jet_buttons) do
        butt:draw()
    end
end

function jet_state.mousepressed(self, x, y, button, istouch)
    for _, butt in ipairs(view.jet_buttons) do
        butt:mousepressed(x, y, button, istouch)
    end
end

function jet_state.mousereleased(self, x, y, button, istouch)
    for _, butt in ipairs(view.jet_buttons) do
        butt:mousereleased(x, y, button, istouch)
    end
end

function jet_state.mousemoved(self, x, y, dx, dy, istouch)
    for _, butt in ipairs(view.jet_buttons) do
        butt:mousemoved(x, y, dx, dy, istouch)
    end
end

function jet_state.go(btn)
    play_state:next_day(btn.text)
    active_state = play_state
end

function jet_state.cancel(btn)
    active_state = play_state
end

--  _                         _
-- | | __ _ _   _  ___  _   _| |_
-- | |/ _` | | | |/ _ \| | | | __|
-- | | (_| | |_| | (_) | |_| | |_
-- |_|\__,_|\__, |\___/ \__,_|\__|
--          |___/
--
function layout.load(self)
    self.point = {}
    self.box = {}
    self.padded_box = {}
    self.padded_point = {}

    local map_layout_to_screen = function(definition)
        for _, o in ipairs(definition) do
            local _x = o.x * display.safe_w
            local _y = o.y * display.safe_h
            local _w = o.width * display.safe_w
            local _h = o.height * display.safe_h
            self.point[o.name] = {_x, _y}
            self.padded_point[o.name] = {_x + 4, _y + 4}
            self.box[o.name] = {_x, _y, _w, _h}
            self.padded_box[o.name] = {_x + 4, _y + 4, _w - 8, _h - 8}
        end
    end

    map_layout_to_screen(require("play_layout"))
    map_layout_to_screen(require("jet_layout"))
end

function layout.point_at(self, key, index)
    return unpack(self.point[string.format(key, index)])
end

function layout.box_at(self, key, index)
    return unpack(self.box[string.format(key, index)])
end

function layout.padded_point_at(self, key, index)
    return unpack(self.padded_point[string.format(key, index)])
end

function layout.underline_at(self, key, index)
    local _x, _y, _w, _h = self:box_at(key, index)
    return _x, _y+_h, _x+_w, _y+_h
end


--                       _        _
--  _ __ ___   __ _ _ __| | _____| |_
-- | '_ ` _ \ / _` | '__| |/ / _ \ __|
-- | | | | | | (_| | |  |   <  __/ |_
-- |_| |_| |_|\__,_|_|  |_|\_\___|\__|
--
function market.load(self)

    -- define the trading stock
    self.db = {
        {name="Ludes",   min=10,    max=50,    increase=false, decrease=true },
        {name="Speed",   min=70,    max=180,   increase=true,  decrease=false},
        {name="Peyote",  min=200,   max=500,   increase=false, decrease=false},
        {name="Weed",    min=300,   max=600,   increase=false, decrease=true },
        {name="Hashish", min=450,   max=900,   increase=false, decrease=true },
        {name="Opium",   min=500,   max=800,   increase=true,  decrease=false},
        {name="Shrooms", min=600,   max=750,   increase=false, decrease=false},
        {name="PCP",     min=1000,  max=2500,  increase=false, decrease=false},
        {name="Acid",    min=1000,  max=3500,  increase=false, decrease=true },
        {name="MDA",     min=1500,  max=3000,  increase=false, decrease=false},
        {name="Heroin",  min=5000,  max=9000,  increase=true,  decrease=false},
        {name="Cocaine", min=15000, max=26000, increase=true,  decrease=false}
    }

    -- define the special event messages
    self.increase_message = {
        "Cops made a big %s bust! Prices are outrageous!",
        "Addicts are buying %s at outrageous prices!"
    }

    self.decrease_message = {
        Acid="The market has been flooded with cheap home-made acid!",
        Hashish="The Marrakesh Express has arrived!",
        Ludes="Rival drug dealers raided a pharmacy and are selling cheap ludes!",
        Weed="Columbian freighter dusted the Coast Guard! Weed prices have bottomed out!"
    }

    -- roll the dice
    math.randomseed(42)

    -- predict market fluctuations for the next month
    self.predictions = {}
    for i=1, 31 do
        table.insert(self.predictions, math.random())
    end

end

function market.fluctuate(self)

    -- load prediction
    local prediction = self.predictions[player.day]
    math.randomseed(prediction)

    -- clone the database into a holding bag
    local drugbag = {}
    for _, template in ipairs(self.db) do
        local entry = {}
        for key, value in pairs(template) do
            entry[key] = value
        end
        table.insert(drugbag, entry)
    end

    -- number of stock items on the market this turn
    local count = math.random(math.floor(#self.db/2), #self.db)

    self.available = {}

    while #self.available < count do

        -- pick a random stock from the bag
        local drug = table.remove(drugbag, math.random(1, #drugbag))

        -- get the market cost
        local cost = math.random(drug.min, drug.max)

        -- a major market event
        if math.random() < .15 then
            if drug.increase then
                cost = cost * math.random(3, 6)
                local template = self.increase_message[math.random(1, #self.increase_message)]
                    or "%s increase template not found"
                player:add_message(string.format(template, drug.name))
            elseif drug.decrease then
                cost = math.floor(cost / math.random(3, 6))
                local template = self.decrease_message[drug.name]
                    or "%s decrease template not found"
                player:add_message(template)
            end
        end

        table.insert(self.available, {
            name = drug.name,
            cost = cost,
            cost_amount = util.comma_value(cost),
            stock = trenchcoat:stock_of(drug.name)
        })

    end

    -- remember player stock not on the market
    self.not_for_sale = {}
    for _, drug in ipairs(drugbag) do
        if trenchcoat:has(drug.name) then
            table.insert(self.not_for_sale, {
                name = drug.name,
                stock = trenchcoat:stock_of(drug.name)
            })
        end
    end

end

--        _
--  _ __ | | __ _ _   _  ___ _ __
-- | '_ \| |/ _` | | | |/ _ \ '__|
-- | |_) | | (_| | |_| |  __/ |
-- | .__/|_|\__,_|\__, |\___|_|
-- |_|            |___/
--
function player.load(self)
    --self:reset_game()
    self:clear_messages()
end

function player.reset_game(self)
    self.day = 1
    self.cash = 2000
    self.cash_amount = util.comma_value(self.cash)
    self.health = 100
    self.guns = 0
    self.bank = 0
    self.bank_amount = util.comma_value(self.bank)
    self.debt = 5500
    self.debt_amount = util.comma_value(self.debt)
    self.location = LOCATIONS[1]
    self.ishomelocation = true
    self.ischased = false
    self.messages = {}
    trenchcoat:reset()
end

function player.clear_messages(self)
    self.messages = {}
    self.joined_messages = ""
end

function player.add_message(self, text)
    table.insert(self.messages, text)
    self.joined_messages = self.joined_messages .. text .. "\n"
    print("message: "..text)
end

function player.add_day(self, new_location)
    self:clear_messages()
    self.location = new_location
    self.day = self.day + 1
end

function player.accrue_debt(self)
    if self.debt > 0 then
        -- TODO: find out the correct loan interest rate
        self.debt = math.floor(self.debt * 1.05)
    end
    self.debt_amount = util.comma_value(self.debt)
end

function player.generate_events(self)
    -- TODO: random events adds messages or sets ischased
end

function player.buy_drug(btn)
    local drug = market.available[btn.number]
    -- clamp allowed to player cash
    local max_purchasable = math.floor(player.cash / drug.cost)
    -- clamp to free space
    max_purchasable = math.min(trenchcoat:free_space(), max_purchasable)
    -- clamp to trading size
    max_purchasable = math.min(TRADE_SIZE, max_purchasable)
    local delta, current_stock = trenchcoat:adjust_stock(drug.name, max_purchasable)
    player:debit_account(delta * drug.cost)
    view:update_market_buttons()
    print("bought "..delta.." "..drug.name)
end

function player.sell_drug(btn)
    local drug = market.available[btn.number]
    local delta, current_stock = trenchcoat:adjust_stock(drug.name, -TRADE_SIZE)
    player:credit_account(delta * drug.cost)
    view:update_market_buttons()
    print("sold "..delta.." "..drug.name)
end

function player.debit_account(self, amount)
    self.cash = self.cash - amount
    self.cash_amount = util.comma_value(self.cash)
end

function player.credit_account(self, amount)
    self.cash = self.cash + amount
    self.cash_amount = util.comma_value(self.cash)
end

--        _
-- __   _(_) _____      __
-- \ \ / / |/ _ \ \ /\ / /
--  \ V /| |  __/\ V  V /
--   \_/ |_|\___| \_/\_/
--
function view.load(self)

    -- load font resources
    self.defaultfont = love.graphics.getFont()
    self.largefont = love.graphics.newFont("res/BodoniflfBold-MVZx.ttf", 40)
    self.mediumfont = love.graphics.newFont("res/BodoniflfBold-MVZx.ttf", 24)

    -- create jet & debt buttons
    local button = require("harness.button")
    local jet_x, jet_y, jet_w, jet_h = layout:box_at("jet")
    local debt_x, debt_y, debt_w, debt_h = layout:box_at("debt")

    local jetbutton = button:new{
        left = jet_x,
        top = jet_y,
        width = jet_w,
        height = jet_h,
        text = "Jet",
        callback = jet_state.switch
    }

    local debtbutton = button:new{
        left = debt_x,
        top = debt_y,
        width = debt_w,
        height = debt_h,
        text = "Debt",
        callback = function(btn)
            print("clicked "..os.date("%c", os.time()))
            end
    }

    self.play_buttons = {
        ["jet"] = jetbutton,
        ["debt"] = debtbutton
    }

    -- Create market buy & sell buttons
    for i=1, #market.db do
        local sell_id = string.format("sell %d", i)
        local buy_id = string.format("buy %d", i)
        local _x, _y, _w, _h = layout:box_at("sell %d", i)
        self.play_buttons[sell_id] = button:new{
            left = _x,
            top = _y,
            width = _w,
            height = _h,
            text = "Sell",
            number = i,
            id = sell_id,
            callback = player.sell_drug
        }
        local _x, _y, _w, _h = layout:box_at("buy %d", i)
        self.play_buttons[buy_id] = button:new{
            left = _x,
            top = _y,
            width = _w,
            height = _h,
            text = "Buy",
            number = i,
            id = buy_id,
            callback = player.buy_drug
        }
    end

    -- create jet buttons
    self.jet_buttons = {}
    for i, title in ipairs(LOCATIONS) do
        local _x, _y, _w, _h = layout:box_at("loc %d", i)
        table.insert(self.jet_buttons, button:new{
            left = _x,
            top = _y,
            width = _w,
            height = _h,
            text = title,
            callback = jet_state.go
        })
    end
    local _x, _y, _w, _h = layout:box_at("jet cancel")
    table.insert(self.jet_buttons, button:new{
        left = _x,
        top = _y,
        width = _w,
        height = _h,
        text = "I changed my mind",
        callback = jet_state.cancel
    })

end

function view.update_market_buttons(self)

    for i=1, #market.db do
        local sell_id = string.format("sell %d", i)
        local buy_id = string.format("buy %d", i)
        local market_item = market.available[i]
        local sell_btn = self.play_buttons[sell_id]
        local buy_btn = self.play_buttons[buy_id]

        -- reset button state
        sell_btn.hidden = false
        sell_btn.disabled = false
        buy_btn.hidden = false
        buy_btn.disabled = false

        -- item is on the market
        if market_item then
            local stock_amt = trenchcoat:stock_of(market_item.name)
            -- set player stock as sell text
            sell_btn.text = stock_amt
            -- player has no stock to sell, hide the button
            if stock_amt == 0 then
                sell_btn.hidden = true
            end
            -- player cannot afford 1 unit, disable the button
            if market_item.cost > player.cash then
                buy_btn.disabled = true
            end
            -- no space left to carry, disable the button
            if trenchcoat:free_space() == 0 then
                buy_btn.disabled = true
            end
        else
            -- not on the market, hide the buy and sell buttons
            buy_btn.hidden = true
            sell_btn.hidden = true
        end
    end

end

function view.set_medium_font(self)
    love.graphics.setFont(self.mediumfont)
end

function view.set_large_font(self)
    love.graphics.setFont(self.largefont)
end

function view.draw_logo(self)

end

function view.draw_player_stats(self)

    -- TODO: background cyan, black text
    view:set_medium_font()
    love.graphics.setColor(0, 1, 1)

    love.graphics.print("CASH", layout:padded_point_at("cash"))
    love.graphics.print(player.cash_amount, layout:padded_point_at("cash amount"))
    love.graphics.line(layout:underline_at("cash"))
    love.graphics.line(layout:underline_at("cash amount"))

    love.graphics.print("BANK", layout:padded_point_at("bank"))
    love.graphics.print(player.bank_amount, layout:padded_point_at("bank amount"))
    love.graphics.line(layout:underline_at("bank"))
    love.graphics.line(layout:underline_at("bank amount"))

    if player.debt == 0 then
        love.graphics.print("Debt", layout:padded_point_at("debt"))
        love.graphics.line(layout:underline_at("debt"))
    end
    love.graphics.print(player.debt_amount, layout:padded_point_at("debt amount"))
    love.graphics.line(layout:underline_at("debt amount"))

    love.graphics.print("Guns", layout:padded_point_at("guns"))
    love.graphics.print(player.guns, layout:padded_point_at("guns amount"))
    love.graphics.line(layout:underline_at("guns"))
    love.graphics.line(layout:underline_at("guns amount"))

    love.graphics.print("Health", layout:padded_point_at("health"))
    love.graphics.print(player.health, layout:padded_point_at("health amount"))
    love.graphics.line(layout:underline_at("health"))
    love.graphics.line(layout:underline_at("health amount"))

    love.graphics.print("Free", layout:padded_point_at("free"))
    love.graphics.print(trenchcoat:free_space(), layout:padded_point_at("free amount"))

    love.graphics.print(string.format("Day %d", player.day), layout:padded_point_at("day"))
    love.graphics.print(player.location, layout:padded_point_at("location"))
    love.graphics.line(layout:underline_at("day"))
    love.graphics.line(layout:underline_at("location"))

    local msg_x, msg_y, msg_w, msg_h = layout:box_at("messages")
    love.graphics.rectangle("line", msg_x, msg_y, msg_w, msg_h)
    love.graphics.printf(player.joined_messages, msg_x+4, msg_y+4, msg_w-8)

end

function view.draw_market(self)

    view:set_medium_font()
    local last_available_i = 0

    -- list stock on the market today
    for i, item in ipairs(market.available) do
        love.graphics.print(item.name, layout:point_at("name %d", i))
        love.graphics.print(item.cost_amount, layout:point_at("cost %d", i))
        love.graphics.line(layout:underline_at("name %d", i))
        last_available_i = i
    end

    -- list stock not on the market
    love.graphics.setColor(.7, .7, .7)
    for _, item in ipairs(market.not_for_sale) do
        last_available_i = last_available_i + 1
        love.graphics.print(item.stock, layout:point_at("sell %d", last_available_i))
        love.graphics.print(item.name, layout:point_at("name %d", last_available_i))
        love.graphics.print("no sale", layout:point_at("cost %d", last_available_i))
        love.graphics.line(layout:underline_at("name %d", last_available_i))
    end

    for _, butt in pairs(self.play_buttons) do
        butt:draw()
    end
end

function view.draw_messages(self)

end

--        _                   _        _
--  _ __ | | __ _ _   _   ___| |_ __ _| |_ ___
-- | '_ \| |/ _` | | | | / __| __/ _` | __/ _ \
-- | |_) | | (_| | |_| | \__ \ || (_| | ||  __/
-- | .__/|_|\__,_|\__, | |___/\__\__,_|\__\___|
-- |_|            |___/
--
function play_state.load(self)
    -- TODO: move this call to the intro state
    self:new_game()
end

function play_state.new_game(self)
    player:reset_game()
    player:generate_events()
    market:fluctuate()
    view:update_market_buttons()
end

function play_state.next_day(self, new_location)
    player:add_day(new_location)
    player:accrue_debt()
    player:generate_events()
    market:fluctuate()
    view:update_market_buttons()
end

function play_state.draw(self)
    view:draw_player_stats()
    view:draw_market()
end

function play_state.update(self, dt)
    -- TODO: if player.ischased then switch to chase state
    --for _, butt in pairs(view.market_buttons) do
        --butt:update(dt)
    --end
end

function play_state.mousepressed(self, x, y, button, istouch)
    for _, butt in pairs(view.play_buttons) do
        butt:mousepressed(x, y, button, istouch)
    end
end

function play_state.mousereleased(self, x, y, button, istouch)
    for _, butt in pairs(view.play_buttons) do
        butt:mousereleased(x, y, button, istouch)
    end
end

function play_state.mousemoved(self, x, y, dx, dy, istouch)
    for _, butt in pairs(view.play_buttons) do
        butt:mousemoved(x, y, dx, dy, istouch)
    end
end

--  _                       _                     _
-- | |_ _ __ ___ _ __   ___| |__   ___ ___   __ _| |_
-- | __| '__/ _ \ '_ \ / __| '_ \ / __/ _ \ / _` | __|
-- | |_| | |  __/ | | | (__| | | | (_| (_) | (_| | |_
--  \__|_|  \___|_| |_|\___|_| |_|\___\___/ \__,_|\__|
--
function trenchcoat.reset(self)
    for k, v in pairs(self) do
        if type(v) == "number" then
            self[k] = nil
        end
    end
    self.size = 100
    self.free = self.size
end

function trenchcoat.adjust_stock(self, name, amount)
    local current_stock = (self[name] or 0)
    local new_stock = math.max(0, current_stock + amount)
    if new_stock == 0 then
        self[name] = nil
    else
        self[name] = new_stock
    end
    -- stock amount difference
    local delta = new_stock - current_stock
    -- account delta into free space
    self.free = self.free - delta
    return math.abs(delta), new_stock
end

function trenchcoat.free_space(self)
    return self.free
end

function trenchcoat.has(self, name)
    return self[name]
end

function trenchcoat.stock_of(self, name)
    if self:has(name) then
        return self[name]
    else
        return 0
    end
end

--        _   _ _
--  _   _| |_(_) |
-- | | | | __| | |
-- | |_| | |_| | |
--  \__,_|\__|_|_|
--
function util.comma_value(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return "$"..formatted
end
