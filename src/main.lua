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

local DEBUG = 1
local TRADE_SIZE = 1
local PRIMARY_COLOR = {0, 1, 1}
local GOOD_COLOR = {0, 1, 0}
local BAD_COLOR = {1, 1, 0}
local LOCATIONS = {"Bronx", "Ghetto", "Central Park",
                    "Manhattan", "Coney Island", "Brooklyn" }

local display = {}
local layout = {}
local player = {}
local market = {}
local fonts = {}
local trenchcoat = {}
local util = {}
local message_panel = {}
local test = {}

local menu_state = {}
local play_state = {}
local jet_state = {}
local cops_state = {}
local scores_state = {}
local active_state = {}
local encounter_state = {}

function love.load()

    -- do not prevent device from sleeping
    love.window.setDisplaySleepEnabled(true)
    love.filesystem.setIdentity("dopetrader")

    fonts:load()
    display:load()
    layout:load()
    player:load()
    market:load()
    message_panel:load()

    menu_state:load()
    play_state:load()
    jet_state:load()
    encounter_state:load()

    menu_state:switch()
end

function love.keypressed(key, isrepeat)
    active_state:keypressed(key)
end

function love.keyreleased(key, scancode)
    active_state:keyreleased(key)
end

function love.mousepressed(x, y, button, istouch)
    active_state:mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
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

    --love.graphics.setBlendMode("replace")

    local osname = love.system.getOS()
    self.mobile = osname == "Android" or osname == "iOS"

end

--                                   _
--   ___ _ __   ___ ___  _   _ _ __ | |_ ___ _ __
--  / _ \ '_ \ / __/ _ \| | | | '_ \| __/ _ \ '__|
-- |  __/ | | | (_| (_) | |_| | | | | ||  __/ |
--  \___|_| |_|\___\___/ \__,_|_| |_|\__\___|_|
--
function encounter_state.load(self)

    local wc = require("harness.widgetcollection")
    self.buttons = wc:new()

    local run_box = layout.box["answer 1"]
    self.buttons:button("run", {
        context = self,
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "Run",
        font = fonts:for_menu_button(),
        callback = self.attempt_run
    })

    local run_box = layout.box["answer 2"]
    self.buttons:button("fight", {
        context = self,
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "Fight",
        font = fonts:for_menu_button(),
        callback = self.attempt_fight
    })

    local run_box = layout.box["close prompt"]
    self.buttons:button("close", {
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "I'm outta here",
        font = fonts:for_menu_button(),
        hidden = true,
        callback = self.exit_state
    })

    local run_box = layout.box["alt close prompt"]
    self.buttons:button("doctor", {
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "Patch me up, doc!",
        font = fonts:for_menu_button(),
        hidden = true,
        callback = self.visit_doctor
    })

end

function encounter_state.switch(self, risk_factor)

    -- load prediction
    math.randomseed(market.predictions[player.day])

    self.thugs = math.random(1, 10 * risk_factor)
    self.cash_prize = (math.random() * 1000) + self.thugs * 1000
    self.doctors_fees = 1000
    self:set_message()
    self.outcome = ""

    self.buttons:get("fight").hidden = false
    self.buttons:get("fight").disabled = player.guns == 0
    self.buttons:get("close").hidden = true
    self.buttons:get("run").hidden = false
    self.buttons:get("doctor").hidden = true

    -- watch player health as a spinning number
    local dr = require("harness.digitroller")
    self.health_counter = dr:new({
        subject = player,
        target = "health"
    })

    active_state = self
    print(string.format("chased by %d thugs. you can earn a $%d prize.", self.thugs, self.cash_prize))
end

function encounter_state.exit_state()
    play_state:switch()
end

function encounter_state.update(self, dt)
    self.health_counter:update(dt)
end

function encounter_state.draw(self)

    fonts:set_large()
    love.graphics.setColor(PRIMARY_COLOR)

    love.graphics.print("Health", layout:padded_point_at("title"))
    love.graphics.printf(math.floor(self.health_counter.value), layout:align_point_at("title",nil,"right"))
    love.graphics.rectangle("line", layout:box_at("title"))

    love.graphics.printf(self.message, layout:align_point_at("prompt", nil, "center"))

    if self.outcome then
        love.graphics.printf(self.outcome, layout:align_point_at("response", nil, "center"))
    end

    self.buttons:draw()

end

function encounter_state.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        menu_state:switch()
    end
end

function encounter_state.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function encounter_state.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function encounter_state.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function encounter_state.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function encounter_state.set_message(self)
    if self.thugs == 0 then
        self.message = string.format("You fought them off!\nYou found $%d on the body.", self.cash_prize)
    elseif self.thugs == 1 then
        self.message = string.format("A gang leader is chasing you!")
    elseif self.thugs == 2 then
        self.message = string.format("A gang leader and one of his thugs are chasing you!")
    else
        self.message = string.format("A gang leader and %d of his thugs are chasing you!", self.thugs - 1)
    end
end

function encounter_state.visit_doctor()
    player:restore_health()
    player:debit_account(encounter_state.doctors_fees)
    encounter_state:exit_state()
end

function encounter_state.get_shot_at(self)
    -- chance of being hit is proportional to number of thugs
    local hit_chance = math.min(0.6, self.thugs * 0.2)
    print(string.format("they fire with hit chance of %d%%", hit_chance * 100))
    if math.random() < hit_chance then
        print("you are hit")
        player:lose_health(math.random(5, 15))
        self:test_death()
        return "They fire at you! You are hit!"
    else
        print("they miss")
        return "They fire at you, and miss!"
    end
end

function encounter_state.attempt_run(btn)
    -- chance of escape is inversely proportional to number of thugs.
    -- clamp upper limit so there is always a small chance of escape.
    local escape_chance = math.max(0.1, 0.7 - btn.context.thugs * 0.075)

    if math.random() < escape_chance then
        print(string.format("you escaped with chance of %d%%", escape_chance * 100))
        btn.context:allow_exit()
        btn.context.outcome = "You lost them in the alleys"
    else
        print(string.format("failed to escape with chance of %d%%", escape_chance * 100))
        btn.context.outcome = "You can't lose them! " .. btn.context:get_shot_at()
    end
end

function encounter_state.attempt_fight(btn)
    -- chance of hit is proportional to number of guns carried.
    local hit_chance = math.min(0.75, player.guns * 0.25)
    print(string.format("you fire with a hit chance of %d%%", hit_chance * 100))
    if math.random() < hit_chance then
        print("you hit them")
        btn.context.thugs = btn.context.thugs - 1
        btn.context:set_message()
        btn.context.outcome = "You hit one of them! " .. btn.context:get_shot_at()
        if btn.context.thugs == 0 then
            player:credit_account(encounter_state.cash_prize)
            btn.context.outcome = ""
            btn.context:allow_exit()
        end
    else
        print("you miss")
        btn.context.outcome = "You miss! " .. btn.context:get_shot_at()
    end
end

function encounter_state.allow_exit(self)
    self.buttons:get("close").hidden = false
    self.buttons:get("run").hidden = true
    self.buttons:get("fight").hidden = true

    if self.thugs == 0 and player.health < 100 then
        self.doctors_fees = (math.random() * 1000) + 1500
        if self.doctors_fees <= player.cash then
            self.buttons:get("doctor").hidden = false
            self.outcome = string.format("Visit a clinic to patch you up for $%d?", self.doctors_fees)
        end
    end
end

function encounter_state.test_death(self)
    if player.health < 1 then
        self:allow_exit()
        self.outcome = "They wasted you, man! What a drag!"
        love.system.vibrate(.25)
    else
        love.system.vibrate(.2)
    end
end

--   __             _
--  / _| ___  _ __ | |_ ___
-- | |_ / _ \| '_ \| __/ __|
-- |  _| (_) | | | | |_\__ \
-- |_|  \___/|_| |_|\__|___/
--
function fonts.load(self)
    self.large = love.graphics.newFont("res/BodoniflfBold-MVZx.ttf", 40)
    self.medium = love.graphics.newFont("res/BodoniflfBold-MVZx.ttf", 24)
    self.small = love.graphics.newFont("res/BodoniflfBold-MVZx.ttf", 18)
end

function fonts.set_small(self)
    love.graphics.setFont(self.small)
end

function fonts.set_medium(self)
    love.graphics.setFont(self.medium)
end

function fonts.set_large(self)
    love.graphics.setFont(self.large)
end

function fonts.for_title(self)
    if display.mobile then
        return self.large
    else
        return self.large
    end
end

function fonts.for_menu_button(self)
    if display.mobile then
        return self.large
    else
        return self.large
    end
end

function fonts.for_market_button(self)
    if display.mobile then
        return self.small
    else
        return self.medium
    end
end

function fonts.for_jet_button(self)
    if display.mobile then
        return self.medium
    else
        return self.large
    end
end

function fonts.for_player_stats(self)
    if display.mobile then
        return self.small
    else
        return self.medium
    end
end



--    _      _         _        _
--   (_) ___| |_   ___| |_ __ _| |_ ___
--   | |/ _ \ __| / __| __/ _` | __/ _ \
--   | |  __/ |_  \__ \ || (_| | ||  __/
--  _/ |\___|\__| |___/\__\__,_|\__\___|
-- |__/
--
function jet_state.load(self)

    local wc = require("harness.widgetcollection")
    self.buttons = wc:new()

    for i, title in ipairs(LOCATIONS) do
        local _x, _y, _w, _h = layout:box_at("loc %d", i)
        self.buttons:button(title, {
            left = _x,
            top = _y,
            width = _w,
            height = _h,
            text = title,
            callback = jet_state.go,
            font = fonts:for_jet_button()
        })
    end

    local _x, _y, _w, _h = layout:box_at("jet cancel")
    self.buttons:button("back", {
        left = _x,
        top = _y,
        width = _w,
        height = _h,
        text = "I changed my mind",
        callback = jet_state.cancel,
        font = fonts:for_jet_button()
    })

end

function jet_state.update(self, dt)
    self.buttons:update(dt)
end

function jet_state.switch(btn)
    for _, butt in pairs(jet_state.buttons.controls) do
        butt.disabled = butt.text == player.location
    end
    active_state = jet_state
    btn.focused = false
end

function jet_state.draw(self)
    love.graphics.setColor(PRIMARY_COLOR)
    love.graphics.setFont(fonts:for_title())
    love.graphics.printf("Where to?", 0, display.safe_h/3, display.safe_w, "center")
    self.buttons:draw()
end

function jet_state.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        play_state:switch()
    end
end

function jet_state.keyreleased(self, key)
    self.buttons:keyreleased(key)
end

function jet_state.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function jet_state.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function jet_state.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function jet_state.go(btn)
    -- TODO: flashing "subway" text with animated train across the screen
    play_state:next_day(btn.text)
end

function jet_state.cancel(btn)
    play_state:switch()
end

--                                   _        _
--  _ __ ___   ___ _ __  _   _   ___| |_ __ _| |_ ___
-- | '_ ` _ \ / _ \ '_ \| | | | / __| __/ _` | __/ _ \
-- | | | | | |  __/ | | | |_| | \__ \ || (_| | ||  __/
-- |_| |_| |_|\___|_| |_|\__,_| |___/\__\__,_|\__\___|
--
function menu_state.load(self)

    local wc = require("harness.widgetcollection")
    self.buttons = wc:new()

    local run_box = layout.box["new game"]
    self.buttons:button("new", {
        context = self,
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "New Game",
        font = fonts:for_menu_button(),
        callback = self.new_game
    })

    local run_box = layout.box["resume game"]
    self.buttons:button("resume", {
        context = self,
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "Resume Game",
        font = fonts:for_menu_button(),
        callback = self.resume_game,
        disabled = true
    })

    local run_box = layout.box["high scores"]
    self.buttons:button("scores", {
        context = self,
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "High Rollers",
        font = fonts:for_menu_button(),
        callback = self.view_scores,
        disabled = true
    })

    local run_box = layout.box["options"]
    self.buttons:button("options", {
        context = self,
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "Options",
        font = fonts:for_menu_button(),
        callback = self.view_about,
        disabled = true
    })

    local run_box = layout.box["about"]
    self.buttons:button("about", {
        context = self,
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "About",
        font = fonts:for_menu_button(),
        callback = self.view_about,
        disabled = true
    })

    if DEBUG then
        local z_box = layout.box["debug 1"]
        self.buttons:button("debug cash", {
            context = self,
            left = z_box[1],
            top = z_box[2],
            width = z_box[3],
            height = z_box[4],
            text = "$",
            font = fonts:for_player_stats(),
            callback = test.add_cash
        })
        local z_box = layout.box["debug 2"]
        self.buttons:button("debug guns", {
            context = self,
            left = z_box[1],
            top = z_box[2],
            width = z_box[3],
            height = z_box[4],
            text = "Guns",
            font = fonts:for_player_stats(),
            callback = test.add_guns
        })
        local z_box = layout.box["debug 3"]
        self.buttons:button("debug pockets", {
            context = self,
            left = z_box[1],
            top = z_box[2],
            width = z_box[3],
            height = z_box[4],
            text = "Pockets",
            font = fonts:for_player_stats(),
            callback = test.add_pockets
        })
    end

end

function menu_state.update(self, dt)
    self.buttons:update(dt)
end

function menu_state.switch(self)
    local savegame_exists = love.filesystem.getInfo("savegame", "file") ~= nil
    self.buttons:get("resume").disabled = not savegame_exists
    active_state = menu_state
end

function menu_state.draw(self)
    fonts:set_large()
    love.graphics.setColor(PRIMARY_COLOR)
    love.graphics.printf("DoPe TrAder", layout:align_point_at("menu logo", nil, "center"))
    self.buttons:draw()
end

function menu_state.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function menu_state.keyreleased(self, key)
    self.buttons:keyreleased(key)
end

function menu_state.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function menu_state.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function menu_state.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function menu_state.new_game(btn)
    play_state:new_game()
    play_state:switch()
end

function menu_state.resume_game(btn)
    -- load from disk if no day, otherwise resumes game in-progress
    if player.game_over then
        play_state:new_game()
        play_state:load_from_file()
    end
    play_state:switch()
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
            local _x = display.safe_x + (o.x * display.safe_w)
            local _y = display.safe_y + (o.y * display.safe_h)
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
    map_layout_to_screen(require("prompt_layout"))
    map_layout_to_screen(require("menu_layout"))
end

function layout.point_at(self, key, index)
    return unpack(self.point[string.format(key, index)])
end

function layout.align_point_at(self, key, index, alignment)
    local _x, _y, _w = unpack(self.padded_box[string.format(key, index)])
    return _x, _y, _w, alignment
end

function layout.box_at(self, key, index)
    return unpack(self.box[string.format(key, index)])
end

function layout.box_between(self, first, second)
    local box1 = self.box[first]
    local box2 = self.box[second]
    return box1[1], box1[2], (box1[3]+box2[3])+(box2[1]-(box1[1]+box1[3])), box2[4]
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

end

function market.initialize_predictions(self)

    -- roll the dice
    math.randomseed(player.seed)

    -- predict market fluctuations for the next month
    self.predictions = {}
    for i=1, 31 do
        table.insert(self.predictions, math.random())
    end

end

function market.fluctuate(self)

    -- load prediction
    math.randomseed(self.predictions[player.day])

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
    self.is_available = {}

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
                message_panel:add_message(string.format(template, drug.name))
            elseif drug.decrease then
                cost = math.floor(cost / math.random(3, 6))
                local template = self.decrease_message[drug.name]
                    or "%s decrease template not found"
                message_panel:add_message(template)
            end
        end

        table.insert(self.available, {
            name = drug.name,
            cost = cost,
            cost_amount = util.comma_value(cost),
            stock = trenchcoat:stock_of(drug.name)
        })

        self.is_available[drug.name] = true

    end

end


--                                                                    _
--  _ __ ___   ___  ___ ___  __ _  __ _  ___   _ __   __ _ _ __   ___| |
-- | '_ ` _ \ / _ \/ __/ __|/ _` |/ _` |/ _ \ | '_ \ / _` | '_ \ / _ \ |
-- | | | | | |  __/\__ \__ \ (_| | (_| |  __/ | |_) | (_| | | | |  __/ |
-- |_| |_| |_|\___||___/___/\__,_|\__, |\___| | .__/ \__,_|_| |_|\___|_|
--                                |___/       |_|
--
function message_panel.load(self)

    -- message box layout
    _, self.rest_y = layout:point_at("messages")

    -- dont drag messages above this point
    self.min_y = display.safe_h/2

    -- panel position
    self.y = self.rest_y

    -- text position
    self.text_y = display.height - self.y

    -- indicator position
    self.led_radius = 10
    self.led_x = display.safe_w / 2
    self.led_y = self.led_radius * 2

end

function message_panel.draw(self)
    -- fill
    love.graphics.setColor(0, .3, .3)
    love.graphics.rectangle("fill", 0, self.y, display.safe_w, display.safe_h)
    -- message indicator
    if #self.messages == 0 then
        love.graphics.setColor(0, 0, 0)
    else
        love.graphics.setColor(0, 1, 1)
    end
    love.graphics.circle("fill", self.led_x, self.y + self.led_y, self.led_radius)
    -- text
    -- TODO: color text by message priority
    if self.y ~= self.rest_y then
        fonts:set_medium()
        --love.graphics.setColor(0, 0, 0)
        --love.graphics.printf(player.joined_messages, 3, self.y + self.text_y + 1, display.safe_w)
        love.graphics.setColor(0, 1, 1)
        love.graphics.printf(self.joined_messages, 4, self.y + self.text_y, display.safe_w)
    end
end

function message_panel.update(self, dt)
    if not self.dragging and self.y < self.rest_y then
        self.y = math.min(self.rest_y, self.y + (self.y * dt))
    end
end

function message_panel.mousepressed(self, x, y, button, istouch)
    if not self.dragging and y > self.y then
        self.dragging = y
    end
end

function message_panel.mousereleased(self, x, y, button, istouch)
    if self.dragging then
        self.dragging = nil
    end
end

function message_panel.mousemoved(self, x, y, dx, dy, istouch)
    if self.dragging then
        self.y = math.max(self.min_y, math.min(self.rest_y, y))
    end
end

function message_panel.clear_messages(self)
    self.messages = {}
    self.joined_messages = ""
end

function message_panel.add_message(self, text, ...)
    local msg = string.format(text, ...)
    table.insert(self.messages, msg)
    self.joined_messages = self.joined_messages .. msg .. "\n"
    print("message: "..msg)
end


--        _                   _        _
--  _ __ | | __ _ _   _   ___| |_ __ _| |_ ___
-- | '_ \| |/ _` | | | | / __| __/ _` | __/ _ \
-- | |_) | | (_| | |_| | \__ \ || (_| | ||  __/
-- | .__/|_|\__,_|\__, | |___/\__\__,_|\__\___|
-- |_|            |___/
--
function play_state.load(self)

    local wc = require("harness.widgetcollection")
    self.buttons = wc:new()

    -- Create player stat labels
    local cash_box = layout.box["cash"]
    self.buttons:label("cash label", {
        left = cash_box[1],
        top = cash_box[2],
        width = cash_box[3],
        height = cash_box[4],
        title = "Cash",
        text = "0",
        alignment = "right",
        font = fonts:for_player_stats()
    })
    local bank_box = layout.box["bank"]
    self.buttons:label("bank label", {
        left = bank_box[1],
        top = bank_box[2],
        width = bank_box[3],
        height = bank_box[4],
        title = "Bank",
        text = "0",
        alignment = "right",
        font = fonts:for_player_stats()
    })
    local debt_box = layout.box["debt"]
    self.buttons:label("debt label", {
        left = debt_box[1],
        top = debt_box[2],
        width = debt_box[3],
        height = debt_box[4],
        title = "Debt",
        text = "0",
        alignment = "right",
        font = fonts:for_player_stats()
    })
    local guns_box = layout.box["guns"]
    self.buttons:label("guns label", {
        left = guns_box[1],
        top = guns_box[2],
        width = guns_box[3],
        height = guns_box[4],
        title = "Guns",
        text = "0",
        alignment = "right",
        font = fonts:for_player_stats()
    })
    local coat_box = layout.box["free"]
    self.buttons:label("coat label", {
        left = coat_box[1],
        top = coat_box[2],
        width = coat_box[3],
        height = coat_box[4],
        title = "Coat",
        text = "0",
        alignment = "right",
        font = fonts:for_player_stats()
    })
    local health_box = layout.box["health"]
    self.buttons:label("health label", {
        left = health_box[1],
        top = health_box[2],
        width = health_box[3],
        height = health_box[4],
        title = "Health",
        text = "0",
        alignment = "right",
        font = fonts:for_player_stats()
    })
    local day_box = layout.box["day"]
    self.buttons:label("day label", {
        left = day_box[1],
        top = day_box[2],
        width = day_box[3],
        height = day_box[4],
        title = "Day",
        text = "0",
        alignment = "right",
        font = fonts:for_player_stats()
    })

    -- create jet & debt buttons
    local jet_box = layout.box["jet"]
    self.buttons:button("jet", {
        left = jet_box[1],
        top = jet_box[2],
        width = jet_box[3],
        height = jet_box[4],
        text = "Jet",
        alignment = "right",
        font = fonts:for_jet_button(),
        callback = jet_state.switch
    })

    local debt_box = layout.box["debt"]
    self.buttons:button("debt", {
        left = debt_box[1],
        top = debt_box[2],
        width = debt_box[3],
        height = debt_box[4],
        text = "Debt",
        alignment = "right",
        hidden = true
        --callback = TODO
    })

    -- Create market name labels, buy & sell buttons
    for i=1, #market.db do
        local label_id = string.format("name %d", i)
        local sell_id = string.format("sell %d", i)
        local buy_id = string.format("buy %d", i)
        local _x, _y, _w, _h = layout:box_at("name %d", i)
        self.buttons:label(label_id, {
            left = _x,
            top = _y,
            width = _w,
            height = _h,
            text = "",
            title = "-",
            alignment = "left",
            font = fonts:for_market_button()
        })
        local _x, _y, _w, _h = layout:box_at("sell %d", i)
        self.buttons:button(sell_id, {
            repeating = 10,
            left = _x,
            top = _y,
            width = _w,
            height = _h,
            text = "",
            title = "Sell",
            number = i,
            id = sell_id,
            alignment = "right",
            callback = player.sell_drug,
            font = fonts:for_market_button()
        })
        local _x, _y, _w, _h = layout:box_at("buy %d", i)
        self.buttons:button(buy_id, {
            repeating = 10,
            left = _x,
            top = _y,
            width = _w,
            height = _h,
            text = "",
            title = "Buy",
            number = i,
            id = buy_id,
            alignment = "right",
            callback = player.buy_drug,
            font = fonts:for_market_button()
        })
    end

    -- animate player cash value
    local dr = require("harness.digitroller")
    self.cash_counter_refresh = 0
    self.cash_counter = dr:new({
        duration = 2,
        subject = player,
        target = "cash"
    })

end

function play_state.switch(self)
    active_state = self
end

function play_state.update_button_texts(self)

    local not_for_sale = {}

    for i=1, #market.db do

        local label_id = string.format("name %d", i)
        local sell_id = string.format("sell %d", i)
        local buy_id = string.format("buy %d", i)
        local market_item = market.available[i]
        local sell_btn = self.buttons:get(sell_id)
        local buy_btn = self.buttons:get(buy_id)
        local label = self.buttons:get(label_id)

        -- reset button state
        sell_btn.hidden = false
        sell_btn.disabled = false
        buy_btn.hidden = false
        buy_btn.disabled = false

        -- item is on the market
        if market_item then
            local stock_amt = trenchcoat:stock_of(market_item.name)
            -- set player stock as sell text
            label.title = market_item.name
            label.hidden = false
            sell_btn.text = stock_amt
            sell_btn.title = "Sell"
            buy_btn.text = market_item.cost_amount
            buy_btn.title = "Buy"
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
            label.hidden = true
        end

        -- list this drug in the not-for-sale list
        local drug = market.db[i]
        if not market.is_available[drug.name] and trenchcoat:has(drug.name) then
            table.insert(not_for_sale, {
                name = drug.name,
                stock = trenchcoat:stock_of(drug.name)
            })
        end

    end

    -- set jet button text to current location
    self.buttons:get("jet").text = player.location

    -- list stock not on the market
    local label_id = #market.available
    for _, item in ipairs(not_for_sale) do
        label_id = label_id + 1
        local label = self.buttons:get(string.format("name %d", label_id))
        label.title = item.name
        label.hidden = false
        local buy_btn = self.buttons:get(string.format("buy %d", label_id))
        buy_btn.title = ""
        buy_btn.text = ""
        buy_btn.disabled = true
        buy_btn.hidden = false
        local sell_btn = self.buttons:get(string.format("sell %d", label_id))
        sell_btn.title = "no sale"
        sell_btn.text = item.stock
        sell_btn.disabled = true
        sell_btn.hidden = false
    end

end

function play_state.new_game(self)
    message_panel:clear_messages()
    player:reset_game()
    market:initialize_predictions()
    market:fluctuate()
    self:update_button_texts()
    player:generate_events()
end

function play_state.next_day(self, new_location)
    if player:add_day(new_location) <= #market.predictions then
        message_panel:clear_messages()
        player:accrue_debt()
        market:fluctuate()
        self:update_button_texts()
        self:save_to_file()
        player:generate_events()
        play_state:switch()
    else
        self:remove_save()
        -- TODO: switch to end game state
        -- clear day flag
        player.game_over = true
        menu_state:switch()
    end
end

function play_state.draw(self)

    self.buttons:draw()
    message_panel:draw()

end

function play_state.update(self, dt)

    -- Update player stats labels
    self.cash_counter:update(dt)
    if self.cash_counter_refresh ~= self.cash_counter.value then
        self.cash_counter_refresh = self.cash_counter.value
        self.buttons:get("cash label").text = util.comma_value(math.floor(self.cash_counter.value))
    end
    self.buttons:get("bank label").text = player.bank_amount
    self.buttons:get("debt label").text = player.debt_amount
    self.buttons:get("guns label").text = player.guns
    self.buttons:get("health label").text = player.health
    self.buttons:get("coat label").text = trenchcoat:free_space()
    self.buttons:get("day label").text = player.day

    self.buttons:update(dt)
    message_panel:update(dt)

    if player.gang_encounter then
        encounter_state:switch(player.gang_encounter)
        player.gang_encounter = false
        return
    end

    -- TODO: end game state
    if player.health < 1 then
        --active_state = end_game_state
    end

end

function play_state.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        menu_state:switch()
    end
end

function play_state.keyreleased(self, key)
    self.buttons:keyreleased(key)
end

function play_state.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
    message_panel:mousepressed(x, y, button, istouch)
end

function play_state.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
    message_panel:mousereleased(x, y, button, istouch)
end

function play_state.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
    message_panel:mousemoved(x, y, dx, dy, istouch)
end

function play_state.load_from_file(self)
    message_panel:clear_messages()
    print("LOADING state from file")
    local file = love.filesystem.newFile("savegame")
    local ok, err = file:open("r")
    local other = {}
    if ok then
        local contents, size = file:read()
        file:close()
        if size > 0 then
            local ite = string.gfind(contents, "(%a+)=([%w_]+)")
            while true do
                local key, value = ite()
                if key == nil then break end
                local dec = tonumber(value,16)
                if player[key] ~= nil then
                    player[key] = dec or value
                else
                    other[key] = dec
                end
            end
            trenchcoat:reset()
            trenchcoat.size = other.coat
            trenchcoat.free = trenchcoat.size
            for _, item in ipairs(market.db) do
                for k, v in pairs(other) do
                    if k == item.name then
                        trenchcoat:adjust_stock(k, v)
                    end
                end
            end
            local crc = player:crc()
            if crc ~= other.check then
                print(string.format("crc mismatch! %d <> %d", other.check, crc))
            end
            player.location = string.gsub(player.location, "_", " ")
            player:set_cash()
            player:set_bank()
            player:set_debt()
            market:initialize_predictions()
            market:fluctuate()
            player:generate_events()
        end
    end
end

function play_state.save_to_file(self)
    local file = love.filesystem.newFile("savegame")
    local ok, err = file:open("w")
    if ok then
        local data = string.format([[
            seed=%x cash=%x bank=%x debt=%x
            guns=%x health=%x coat=%x day=%x
            location=%s check=%x]],
            player.seed, player.cash, player.bank, player.debt,
            player.guns, player.health, trenchcoat.size, player.day,
            string.gsub(player.location, " ", "_"), player:crc())
        for _, item in ipairs(market.db) do
            data = data .. string.format(" %s=%x", item.name, trenchcoat:stock_of(item.name))
        end
        local contents, err = file:write(data)
        file:close()
    end
end

function play_state.remove_save(self)
    love.filesystem.remove("savegame")
end

--        _
--  _ __ | | __ _ _   _  ___ _ __
-- | '_ \| |/ _` | | | |/ _ \ '__|
-- | |_) | | (_| | |_| |  __/ |
-- | .__/|_|\__,_|\__, |\___|_|
-- |_|            |___/
--
function player.load(self)
    self.cash = 0
    self.game_over = true
    message_panel:clear_messages()
end

function player.reset_game(self)
    self.seed = os.time()
    self.day = 1
    self:set_cash(2000)
    self.health = 100
    self.guns = 0
    self:set_bank(0)
    self:set_debt(5500)
    self.location = LOCATIONS[1]
    self.gang_encounter = false
    self.game_over = false
    trenchcoat:reset()
end

function player.lose_health(self, value)
    self.health = self.health - value
end

function player.restore_health(self)
    self.health = 100
end

function player.set_cash(self, value)
    self.cash = value or self.cash
    self.cash_amount = util.comma_value(self.cash)
end

function player.set_bank(self, value)
    self.bank = value or self.bank
    self.bank_amount = util.comma_value(self.bank)
end

function player.set_debt(self, value)
    self.debt = value or self.debt
    self.debt_amount = util.comma_value(self.debt)
end

function player.add_popup(self, text)
    print("popup: "..text)
end

function player.add_day(self, new_location)
    self.location = new_location
    self.day = self.day + 1
    return self.day
end

function player.accrue_debt(self)
    if self.debt > 0 then
        -- TODO: find out the correct loan interest rate
        self.debt = math.floor(self.debt * 1.05)
    end
    self.debt_amount = util.comma_value(self.debt)
end

function player.generate_events(self)

    -- load prediction
    math.randomseed(market.predictions[player.day])

    local brownies = math.random() < .1
    local buy_gun = math.random() < .07
    local buy_trenchcoat = math.random() < .07
    local smoke_paraquat = math.random() < .05
    local find_drugs = math.random() < .07
    local give_drugs = math.random() < .07
    local dropped_drugs = math.random() < .07
    local mugged = math.random() < .05
    local detour = math.random() < .1
    local subway_anecdote = math.random() < .3
    local hear_music = math.random() < .15
    local fight_encounter = math.random()

    if brownies then
        local brownie_text = "Your mama made brownies with some of your %s! They were great!"
        if trenchcoat:stock_of("Hashish") > 20 then
            trenchcoat:adjust_stock("Hashish", -math.random(1, 4))
            message_panel:add_message(brownie_text, "hash")
        elseif trenchcoat:stock_of("Weed") > 20 then
            trenchcoat:adjust_stock("Weed", -math.random(1, 4))
            message_panel:add_message(brownie_text, "weed")
        end
    end

    if give_drugs then
        -- pick a drug where you have at least n units
        local name = trenchcoat:get_random(20)
        if name then
            -- give it away
            trenchcoat:adjust_stock(name, -math.random(2, 6))
            local flavor = util.pick(
                "they borrow some %s from you.",
                "you give some %s to them.")
            message_panel:add_message("You meet a friend, "..flavor, name)
        end
    end

    if dropped_drugs then
        -- pick a drug where you have at least n units
        local name = trenchcoat:get_random(20)
        if name then
            -- lose it
            local delta = trenchcoat:adjust_stock(name, -math.random(10, 20))
            print(string.format("event: lost %d %s", delta, name))
            message_panel:add_message("Police dogs chase you for 3 blocks! You dropped some drugs! That's a drag, man!")
        end
    end

    if find_drugs then
        local drug = util.pick(unpack(market.db))
        -- delta amount of drugs added to your coat
        local delta = trenchcoat:adjust_stock(drug.name, math.random(3, 10))
        if delta > 0 then
            local flavor = util.pick(
                "You find %d units of %s on a dead dude in the subway!",
                "You meet a friend, they lay %d units of %s on you.")
            message_panel:add_message(flavor, delta, drug.name)
        end
    end

    if mugged then
        local amount = math.random(player.cash * .1, player.cash * .25)
        player:debit_account(amount)
        message_panel:add_message("You were mugged in the subway!")
        print(string.format("event: lost $%d", amount))
    end

    if detour then
        local bad_thing = util.pick("have a beer.", "smoke a joint.",
            "smoke a cigar.", "smoke a Djarum.", "smoke a cigarette.")
        message_panel:add_message("You stopped to "..bad_thing)
    end

    if subway_anecdote then
        local anecdote = util.pick(
        "Wouldn't it be funny if everyone suddenly quacked at once?",
        "The Pope was once Jewish, you know",
        "I'll bet you have some really interesting dreams",
        "So I think I'm going to Amsterdam this year",
        "Son, you need a yellow haircut",
        "I think it's wonderful what they're doing with incense these days",
        "Does your mother know you're a dope dealer?",
        "Are you high on something?",
        "Oh, you must be from California",
        "I used to be a hippie, myself",
        "There's nothing like having lots of money",
        "You look like an aardvark!",
        "I don't believe in Ronald Reagan",
        "Courage!",
        "Bush is a noodle!",
        "Haven't I seen you on TV?",
        "I think hemorrhoid commercials are really neat!",
        "We're winning the war for drugs!",
        "A day without dope is like night",
        "We only use 20% of our brains, so why not burn out the other 80%",
        "I'm soliciting contributions for Zombies for Christ",
        "I'd like to sell you an edible poodle",
        "Winners don't do drugs... unless they do",
        "I am the walrus!",
        "I feel an unaccountable urge to dye my hair blue",
        "Wasn't Jane Fonda wonderful in Barbarella?",
        "Just say No... well, maybe... Ok, what the hell!",
        "Would you like a jelly baby?",
        "Drugs can be your friend!")
        message_panel:add_message("The lady next to you on the subway said, `%s`",anecdote)
        if math.random() < .3 then
            message_panel:add_message("(at least, you -think- that's what she said)")
        end
    end

    if hear_music then
        local good_song = util.pick(
        "`Are you Experienced` by Jimi Hendrix",
        "`Cheeba Cheeba` by Tone Loc",
        "`Comin' in to Los Angeles` by Arlo Guthrie",
        "`Commercial` by Spanky and Our Gang",
        "`Late in the Evening` by Paul Simon",
        "`Light Up` by Styx",
        "`Mexico` by Jefferson Airplane",
        "`One toke over the line` by Brewer & Shipley",
        "`The Smokeout` by Shel Silverstein",
        "`White Rabbit` by Jefferson Airplane",
        "`Itchycoo Park` by Small Faces",
        "`White Punks on Dope` by the Tubes",
        "`Legend of a Mind` by the Moody Blues",
        "`Eight Miles High` by the Byrds",
        "`Acapulco Gold` by Riders of the Purple Sage",
        "`Kicks` by Paul Revere & the Raiders",
        "the Nixon tapes",
        "`Legalize It` by Mojo Nixon & Skid Roper")
        message_panel:add_message("You hear someone playing %s.",good_song)
    end

    -- % chance of encounter for every unit of drug carried
    local encounter_chance = (trenchcoat.size - trenchcoat.free) * .001 -- 10% / 100 units
    -- additional risk when carrying these
    local charlie_risk = trenchcoat:stock_of("Cocaine") * 0.003
    local heroin_risk = trenchcoat:stock_of("Heroin") * 0.003
    local hash_risk = trenchcoat:stock_of("Hashish") * 0.002
    local hash_risk = trenchcoat:stock_of("Opium") * 0.002
    local risk_factor = math.min(0.6, encounter_chance + charlie_risk + heroin_risk + hash_risk)
    print(string.format("test thug encounter against %d%%", risk_factor * 100))
    if fight_encounter < risk_factor then
        player.gang_encounter = risk_factor
    end

    play_state:update_button_texts()

 --Would you like to buy a .38 Special/Ruger/Saturday Night Special for $0?
 --Will you buy a new trenchcoat with more pockets for $0?
 --There is some weed that smells like paraquat here! It looks good! Will you smoke it?
 --You hallucinated for three days on the wildest trip you ever imagined! Then you died because your brain disintegrated!

end

function player.buy_drug(btn)
    local drug = market.available[btn.number]
    -- clamp allowed to player cash
    local max_purchasable = math.floor(player.cash / drug.cost)
    ---- clamp to free space (MOVED TO adjust_stock())
    --max_purchasable = math.min(trenchcoat:free_space(), max_purchasable)
    -- clamp to trading size
    max_purchasable = math.min(TRADE_SIZE, max_purchasable)
    if max_purchasable > 0 then
        local delta, current_stock = trenchcoat:adjust_stock(drug.name, max_purchasable)
        player:debit_account(delta * drug.cost)
        play_state:update_button_texts()
        print("bought "..delta.." "..drug.name)
    end
end

function player.sell_drug(btn)
    local drug = market.available[btn.number]
    local delta, current_stock = trenchcoat:adjust_stock(drug.name, -TRADE_SIZE)
    if delta > 0 then
        player:credit_account(delta * drug.cost)
        play_state:update_button_texts()
        print("sold "..delta.." "..drug.name)
    end
end

function player.debit_account(self, amount)
    amount = math.floor(amount)
    print(string.format("account debited with $%d", amount))
    self.cash = self.cash - amount
    self.cash_amount = util.comma_value(self.cash)
end

function player.credit_account(self, amount)
    amount = math.floor(amount)
    print(string.format("account credited with $%d", amount))
    self.cash = self.cash + amount
    self.cash_amount = util.comma_value(self.cash)
end

function player.crc(self)
    local crc = 0
    for k, v in pairs(self) do
        if type(v) == "number" then
            crc = crc + v
        end
    end
    --return crc % 255
    return (trenchcoat:crc() + crc) % 255
end

function player.add_gun(self)
    self.guns = self.guns + 1
    print(string.format("You got a gun, you now have %d", self.guns))
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
    -- clamp to free space
    if amount > 0 then
        amount = math.min(trenchcoat.free, amount)
    end
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

function trenchcoat.get_random(self, minimum_amount)
    minimum_amount = minimum_amount or 0
    for i=1, #market.db do
        local pick = market.db[math.random(1, #market.db)]
        local amount = self:stock_of(pick.name)
        if amount > minimum_amount then
            print("check "..pick.name.." with amount "..amount)
            return pick.name, amount
        end
    end
end

function trenchcoat.crc(self)
    local crc = 0
    for k, v in pairs(self) do
        if k ~= "free" and type(v) == "number" then
            crc = crc + v
        end
    end
    return crc % 255
end

function trenchcoat.add_pockets(self)
    local amt = 20
    self.size = self.size + amt
    self.free = self.free + amt
    print(string.format("You expanded your trenchcoat to %d pockets", self.size))
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

function util.pick(...)
    return select(math.random(1, select("#",...)), ...)
end

--  _            _
-- | |_ ___  ___| |_
-- | __/ _ \/ __| __|
-- | ||  __/\__ \ |_
--  \__\___||___/\__|

function test.add_pockets(self)
    trenchcoat:add_pockets()
end

function test.add_guns(self)
    player:add_gun()
end

function test.add_cash(self)
    player:credit_account(25000)
end
