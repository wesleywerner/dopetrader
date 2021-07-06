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
local GOOD_INFO = {0, 1, .5}
local BAD_INFO = {1, 1, .5}
local ZERO_INFO = {.5, 1, 1}
local LOCATIONS = {"Bronx", "Ghetto", "Central Park",
                    "Manhattan", "Coney Island", "Brooklyn" }

local display = {}
local high_scores = {}
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
local loan_shark_state = {}
local purchase_state = {}
local bank_state = {}

function love.load()

    -- do not prevent device from sleeping
    love.window.setDisplaySleepEnabled(true)
    love.filesystem.setIdentity("dopetrader")

    fonts:load()
    high_scores:load()
    display:load()
    layout:load()
    player:load()
    market:load()
    message_panel:load()

    menu_state:load()
    play_state:load()
    jet_state:load()
    encounter_state:load()
    loan_shark_state:load()
    purchase_state:load()
    bank_state:load()

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
    display:request_default_fps()
    active_state:update(dt)
    display:update(dt)
end

function love.draw()
    active_state:draw()
    if DEBUG then
        love.graphics.setColor(1, 1, 1)
        fonts:set_small()
        love.graphics.print(love.timer.getFPS(), 1, display.safe_h - 20)
    end
end

--  _                 _          _        _
-- | |__   __ _ _ __ | | __  ___| |_ __ _| |_ ___
-- | '_ \ / _` | '_ \| |/ / / __| __/ _` | __/ _ \
-- | |_) | (_| | | | |   <  \__ \ || (_| | ||  __/
-- |_.__/ \__,_|_| |_|_|\_\ |___/\__\__,_|\__\___|
--
function bank_state.load(self)

    local wc = require("harness.widgetcollection")
    self.buttons = wc:new()

    local x, y, w, h = layout:box_at("answer 1")
    self.buttons:button("deposit", {
        left = x,
        top = y,
        width = w,
        height = h,
        text = "Deposit",
        font = fonts:for_bank_button(),
        context = self,
        callback = self.do_deposit
    })

    local x, y, w, h = layout:box_at("answer 2")
    self.buttons:button("withdraw", {
        left = x,
        top = y,
        width = w,
        height = h,
        text = "Withdraw",
        font = fonts:for_bank_button(),
        context = self,
        callback = self.do_withdraw
    })

    local x, y, w, h = layout:box_at("close prompt")
    self.buttons:button("close", {
        left = x,
        top = y,
        width = w,
        height = h,
        text = "I'm outta here",
        font = fonts:for_menu_button(),
        callback = self.exit_state
    })

    local x, y, w, h = layout:box_at("alt close prompt")
    self.buttons:button("transact", {
        left = x,
        top = y,
        width = w,
        height = h,
        text = "Transact",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.do_transact
    })

    local display_part = math.floor(display.safe_w  * 0.1)
    self.buttons:slider("slider", {
        left = display_part,
        top = math.floor(display.safe_h * 0.6),
        width = display.safe_w - display_part * 2,
        height = 120,
        font = fonts.large,
        format_function = util.comma_value,
        hidden = true
    })

end

function bank_state.switch(self)

    self.buttons:get("deposit").hidden = false
    self.buttons:get("withdraw").hidden = false
    self.buttons:get("deposit").disabled = player.cash < 1000
    self.buttons:get("withdraw").disabled = player.bank == 0
    self.buttons:get("transact").hidden = true
    self.buttons:get("slider").hidden = true
    active_state = self

end

function bank_state.update(self, dt)

end

function bank_state.draw(self)

    fonts:set_large()
    love.graphics.setColor(PRIMARY_COLOR)

    love.graphics.print("Cash", layout:padded_point_at("title"))
    love.graphics.printf(player.cash_amount, layout:align_point_at("title",nil,"right"))
    love.graphics.rectangle("line", layout:box_at("title"))

    if self.message then
        love.graphics.printf(self.message, layout:align_point_at("prompt", nil, "center"))
    end

    self.buttons:draw()

end

function bank_state.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        play_state:switch()
    end
end

function bank_state.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function bank_state.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function bank_state.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function bank_state.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function bank_state.exit_state(self)
    play_state:switch()
end

function bank_state.do_deposit(self)
    self.is_depositing = true
    self.is_withdrawing = false
    self.buttons:get("deposit").hidden = true
    self.buttons:get("withdraw").hidden = true
    self.buttons:get("transact").hidden = false
    self.buttons:get("slider").hidden = false
    self.buttons:get("slider"):set_maximum(player.cash)
end

function bank_state.do_withdraw(self)
    self.is_depositing = false
    self.is_withdrawing = true
    self.buttons:get("deposit").hidden = true
    self.buttons:get("withdraw").hidden = true
    self.buttons:get("transact").hidden = false
    self.buttons:get("slider").hidden = false
    self.buttons:get("slider"):set_maximum(player.bank)
end

function bank_state.do_transact(self)
    local slider = self.buttons:get("slider")
    if self.is_depositing then
        player:deposit_bank(slider.value)
    else
        player:withdraw_bank(slider.value)
    end
    play_state:switch()
end

--      _ _           _
--   __| (_)___ _ __ | | __ _ _   _
--  / _` | / __| '_ \| |/ _` | | | |
-- | (_| | \__ \ |_) | | (_| | |_| |
--  \__,_|_|___/ .__/|_|\__,_|\__, |
--             |_|            |___/
--

function display.load(self)

    self.default_fps = 1/10
    self.fast_fps = false

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

function display.update(self, dt)
    if not display.fast_fps and dt < display.default_fps then
        love.timer.sleep(display.default_fps - dt)
    end
end

function display.request_default_fps(self)
    self.fast_fps = false
end

function display.request_fast_fps(self)
    self.fast_fps = true
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
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "Run",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.attempt_run
    })

    local run_box = layout.box["answer 2"]
    self.buttons:button("fight", {
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "Fight",
        font = fonts:for_menu_button(),
        context = self,
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

    local upper_thugs = 20 * risk_factor
    self.thugs = math.random(1, upper_thugs)
    print(string.format("Encounter picked %d out of %d thugs, from risk factor %d%%.", self.thugs, upper_thugs, risk_factor * 100))

    self.cash_prize = (math.random() * 1000) + self.thugs * 1000
    print(string.format("You can earn $%d if you win this fight.", self.cash_prize))

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
end

function encounter_state.exit_state()
    play_state:switch()
end

function encounter_state.update(self, dt)
    if self.health_counter_refresh ~= self.health_counter.value then
        self.health_counter_refresh = self.health_counter.value
        display:request_fast_fps()
    end
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
    self:exit_state()
end

function encounter_state.get_shot_at(self)
    if self.thugs == 0 then
        return ""
    end
    -- chance of being hit is proportional to number of thugs
    local hit_chance = math.min(0.6, self.thugs * 0.2)
    print(string.format("Thugs fire with a hit chance of %d%%.", hit_chance * 100))
    if math.random() < hit_chance then
        print("You got hit!")
        player:lose_health(math.random(5, 15))
        love.system.vibrate(.2)
        return "They fire at you! You are hit!"
    else
        print("They miss!")
        return "They fire at you, and miss!"
    end
end

function encounter_state.attempt_run(self)
    -- chance of escape is inversely proportional to number of thugs.
    -- clamp upper limit so there is always a small chance of escape.
    local escape_chance = math.max(0.1, 0.7 - self.thugs * 0.075)

    if math.random() < escape_chance then
        print(string.format("Escaped with chance of %d%%.", escape_chance * 100))
        self:allow_exit()
        self.outcome = "You lost them in the alleys"
    else
        print(string.format("Failed to escape with chance of %d%%.", escape_chance * 100))
        self.outcome = "You can't lose them! " .. self:get_shot_at()
        self:test_death()
    end
end

function encounter_state.attempt_fight(self)
    -- chance of hit is proportional to number of guns carried.
    local hit_chance = math.min(0.75, player.guns * 0.25)
    print(string.format("Firing with a hit chance of %d%%.", hit_chance * 100))
    if math.random() < hit_chance then
        print("Hit!")
        self.thugs = self.thugs - 1
        self:set_message()
        self.outcome = "You hit one of them! " .. self:get_shot_at()
        if self.thugs == 0 then
            player:credit_account(encounter_state.cash_prize)
            self.outcome = ""
            self:allow_exit()
        end
    else
        print("Miss!")
        self.outcome = "You miss! " .. self:get_shot_at()
    end
    self:test_death()
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

function fonts.for_bank_button(self)
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

function jet_state.switch(self)
    for _, butt in pairs(self.buttons.controls) do
        butt.disabled = butt.text == player.location
    end
    active_state = self
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

function jet_state.cancel(self)
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
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "New Game",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.new_game
    })

    local run_box = layout.box["resume game"]
    self.buttons:button("resume", {
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "Resume Game",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.resume_game,
        disabled = true
    })

    local run_box = layout.box["high scores"]
    self.buttons:button("scores", {
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "High Rollers",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.view_scores,
        disabled = true
    })

    local run_box = layout.box["options"]
    self.buttons:button("options", {
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "Options",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.view_options,
        disabled = true
    })

    local run_box = layout.box["about"]
    self.buttons:button("about", {
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "About",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.view_about,
        disabled = true
    })

    if DEBUG then
        local z_box = layout.box["debug 1"]
        self.buttons:button("debug cash", {
            left = z_box[1],
            top = z_box[2],
            width = z_box[3],
            height = z_box[4],
            text = "$",
            font = fonts:for_player_stats(),
            context = self,
            callback = test.add_cash
        })
        local z_box = layout.box["debug 2"]
        self.buttons:button("debug guns", {
            left = z_box[1],
            top = z_box[2],
            width = z_box[3],
            height = z_box[4],
            text = "Guns",
            font = fonts:for_player_stats(),
            context = self,
            callback = test.add_guns
        })
        local z_box = layout.box["debug 3"]
        self.buttons:button("debug pockets", {
            left = z_box[1],
            top = z_box[2],
            width = z_box[3],
            height = z_box[4],
            text = "Pockets",
            font = fonts:for_player_stats(),
            context = self,
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

function menu_state.new_game(self)
    play_state:new_game()
    play_state:switch()
end

function menu_state.resume_game(self)
    -- load from disk if no day, otherwise resumes game in-progress
    if player.game_over then
        play_state:new_game()
        play_state:load_from_file()
    end
    play_state:switch()
end

--  _                 _       _                _
-- | | ___   __ _  __| |  ___| |__   __ _ _ __| | __
-- | |/ _ \ / _` |/ _` | / __| '_ \ / _` | '__| |/ /
-- | | (_) | (_| | (_| | \__ \ | | | (_| | |  |   <
-- |_|\___/ \__,_|\__,_| |___/_| |_|\__,_|_|  |_|\_\
--
function loan_shark_state.load(self)

    local wc = require("harness.widgetcollection")
    self.buttons = wc:new()

    local box = layout.box["close prompt"]
    self.buttons:button("close", {
        left = box[1],
        top = box[2],
        width = box[3],
        height = box[4],
        text = "I'm outta here",
        font = fonts:for_menu_button(),
        callback = self.exit_state
    })

    local box = layout.box["alt close prompt"]
    self.buttons:button("pay", {
        left = box[1],
        top = box[2],
        width = box[3],
        height = box[4],
        text = "Pay",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.pay_debt
    })

    local display_part = math.floor(display.safe_w  * 0.1)
    self.slider = self.buttons:slider("slider", {
        left = display_part,
        top = math.floor(display.safe_h * 0.6),
        width = display.safe_w - display_part * 2,
        height = 120,
        font = fonts.large,
        format_function = util.comma_value
    })

end

function loan_shark_state.switch(self)

    self.message = util.pick(
        "The loan shark eyes you suspiciously",
        "The loan shark counts bills while waiting for you",
        "\"Are you going to pay up, or should I call Tyre-Iron Tyrone?\"",
        "\"I hope you have my cash, chum.\"")

    local maximum_value = math.min(player.debt, player.cash)
    self.slider:set_maximum(maximum_value)
    self.debt_amount = util.comma_value(player.debt)
    active_state = self

end

function loan_shark_state.update(self, dt)

end

function loan_shark_state.draw(self)

    self.buttons:draw()

    love.graphics.setColor(PRIMARY_COLOR)
    love.graphics.print("Debt", layout:padded_point_at("title"))
    love.graphics.printf(self.debt_amount, layout:align_point_at("title",nil,"right"))
    love.graphics.rectangle("line", layout:box_at("title"))
    love.graphics.printf(self.message, layout:align_point_at("prompt", nil, "center"))

end

function loan_shark_state.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        play_state:switch()
    end
end

function loan_shark_state.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function loan_shark_state.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function loan_shark_state.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function loan_shark_state.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function loan_shark_state.exit_state()
    play_state:switch()
end

function loan_shark_state.pay_debt(self)
    player:debit_account(self.slider.value)
    player:pay_debt(self.slider.value)
    play_state:switch()
end

--  _     _       _
-- | |__ (_) __ _| |__    ___  ___ ___  _ __ ___  ___
-- | '_ \| |/ _` | '_ \  / __|/ __/ _ \| '__/ _ \/ __|
-- | | | | | (_| | | | | \__ \ (_| (_) | | |  __/\__ \
-- |_| |_|_|\__, |_| |_| |___/\___\___/|_|  \___||___/
--          |___/
--
function high_scores.load(self)

    self.max_entries = 10
    self.entries = {}

    -- TODO: read from file
    local names = {"Bob", "Alice", "Kitty", "Sunshine", "Lilly", "Pepper" }

    for n, person in ipairs(names) do
        table.insert(self.entries, {
            name=person,
            score=math.floor(math.random(100, 1000)*math.random(1000, 10000))
            })
    end

    self:sort()

    for _, v in ipairs(self:listing()) do
        print(v.rank, v.name, v.score)
    end

end

function high_scores.save(self)
    -- TODO
end

function high_scores.sort(self)
    table.sort(self.entries, function(a,b) return a.score > b.score end)
end

function high_scores.cull(self)
    while #self.entries > self.max_entries do
        local loser = table.remove(self.entries, #self.entries)
        print(string.format("Kicked %s off the high scores list.", loser.name))
    end
end

function high_scores.add(self, person, value)
    if self:is_accepted(value) then
        table.insert(self.entries, { name=person, score=value })
        self:sort()
        self:cull()
        print(string.format("Added %s to the high scores list.", person))
        return self:rank_of(person, value)
    end
end

function high_scores.rank_of(self, person, value)
    for rank, entrant in ipairs(self.entries) do
        if entrant.name == person and entrant.score == value then
            return rank
        end
    end
end

function high_scores.listing(self)
    local results = {}
    for rank, entrant in ipairs(self.entries) do
        table.insert(results, {
            name = entrant.name,
            score = util.comma_value(entrant.score),
            rank = rank
        })
    end
    return results
end

function high_scores.is_accepted(self, value)

    -- room for another, regardless of value
    if #self.entries < self.max_entries then
        return true
    end

    -- value beats the lowest on the list
    local lowest = self.entries[#self.entries]
    if lowest and lowest.score < value then
        return true
    end

    -- no luck chum
    return false

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

function layout.create_collection(self, ...)

    local names = {...}

    local collection = require("harness.widgetcollection"):new()

    for _, name in ipairs(names) do
        assert(self.box[name], string.format("%s not a valid layout name", name))
        local x, y, w, h = layout:box_at(name)
        collection:button(name, {
            left = x,
            top = y,
            width = w,
            height = h,
            text = name
        })
    end

    return collection

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
                local template = util.pick(unpack(self.increase_message))
                    or "%s increase template not found"
                message_panel:add_message(template, GOOD_INFO, drug.name)
            elseif drug.decrease then
                cost = math.floor(cost / math.random(3, 6))
                local template = self.decrease_message[drug.name]
                    or "%s decrease template not found"
                message_panel:add_message(template, GOOD_INFO)
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
    self.min_y = display.safe_h/4

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
    if self.y ~= self.rest_y then
        fonts:set_medium()
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(self.messages, fonts.medium, 4, self.y + self.text_y, display.safe_w - 10, "center")
    end
end

function message_panel.update(self, dt)
    if not self.locked and not self.dragging and self.y < self.rest_y then
        self.y = math.min(self.rest_y, self.y + (display.safe_h * dt))
        display:request_fast_fps()
    end
    if self.dragging then
        display:request_fast_fps()
    end
end

function message_panel.mousepressed(self, x, y, button, istouch)
    if self:is_locked() then
        self:unlock()
    end
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
end

function message_panel.add_message(self, text, color, ...)
    local msg = string.format(text, ...)
    table.insert(self.messages, color)
    table.insert(self.messages, msg.."\n\n")
    print("Message: "..msg)
end

function message_panel.is_dragging(self)
    return self.dragging
end

function message_panel.show_and_lock(self)
    if #self.messages > 0 then
        self.y = self.min_y
        self.locked = true
    end
end

function message_panel.is_locked(self)
    return self.locked
end

function message_panel.unlock(self)
    self.locked = false
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
        context = jet_state,
        callback = jet_state.switch
    })

    local debt_box = layout.box["debt"]
    self.buttons:button("debt button", {
        left = debt_box[1],
        top = debt_box[2],
        width = debt_box[3],
        height = debt_box[4],
        title = "Debt",
        text = "0",
        alignment = "right",
        font = fonts:for_player_stats(),
        callback = self.visit_loanshark
    })

    local bank_box = layout.box["bank"]
    self.buttons:button("bank button", {
        left = bank_box[1],
        top = bank_box[2],
        width = bank_box[3],
        height = bank_box[4],
        title = "Bank",
        text = "0",
        alignment = "right",
        font = fonts:for_player_stats(),
        callback = self.visit_bank
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

    -- update label values when entering this state.
    -- (these dont change while on the play state)
    self.buttons:get("bank label").text = player.bank_amount
    self.buttons:get("debt label").text = player.debt_amount
    self.buttons:get("guns label").text = player.guns
    self.buttons:get("health label").text = player.health
    self.buttons:get("day label").text = player.day

    -- show debt button if player has debt, hide if not in home location
    local debt_button = self.buttons:get("debt button")
    debt_button.text = player.debt_amount
    debt_button.hidden = (player.debt == 0) or (player.location ~= LOCATIONS[1])

    -- show bank button if player is in home location
    local bank_button = self.buttons:get("bank button")
    bank_button.text = player.bank_amount
    bank_button.hidden = (player.location ~= LOCATIONS[1])

    message_panel:show_and_lock()

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

    if #player.purchase > 0 then
        purchase_state:switch(table.remove(player.purchase, 1))
        return
    end

    if player.gang_encounter then
        encounter_state:switch(player.gang_encounter)
        player.gang_encounter = false
        return
    end

    -- Update player stats labels
    self.cash_counter:update(dt)
    if self.cash_counter_refresh ~= self.cash_counter.value then
        display:request_fast_fps()
        self.cash_counter_refresh = self.cash_counter.value
        self.buttons:get("cash label").text = util.comma_value(math.floor(self.cash_counter.value))
    end
    self.buttons:get("coat label").text = trenchcoat:free_space()

    self.buttons:update(dt)
    message_panel:update(dt)

    -- TODO: end game state
    if player.health < 1 then
        --active_state = end_game_state
    end

end

function play_state.keypressed(self, key)
    if key == "escape" then
        if message_panel:is_locked() then
            message_panel:unlock()
        else
            menu_state:switch()
        end
    elseif key == "return" then
        if message_panel:is_locked() then
            message_panel:unlock()
        end
    elseif key == "space" then
        if message_panel:is_locked() then
            message_panel:unlock()
        else
            message_panel:show_and_lock()
        end
    end
    -- stop processing further when dragging or locked message panel
    if (message_panel:is_dragging() or message_panel:is_locked()) then
        return
    end
    self.buttons:keypressed(key)
end

function play_state.keyreleased(self, key)
    self.buttons:keyreleased(key)
end

function play_state.mousepressed(self, x, y, button, istouch)
    message_panel:mousepressed(x, y, button, istouch)
    -- stop processing further when dragging or locked message panel
    if (message_panel:is_dragging() or message_panel:is_locked()) then
        return
    end
    self.buttons:mousepressed(x, y, button, istouch)
end

function play_state.mousereleased(self, x, y, button, istouch)
    message_panel:mousereleased(x, y, button, istouch)
    -- stop processing further when dragging or locked message panel
    if (message_panel:is_dragging() or message_panel:is_locked()) then
        return
    end
    self.buttons:mousereleased(x, y, button, istouch)
end

function play_state.mousemoved(self, x, y, dx, dy, istouch)
    message_panel:mousemoved(x, y, dx, dy, istouch)
    -- stop processing further when dragging or locked message panel
    if (message_panel:is_dragging() or message_panel:is_locked()) then
        return
    end
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function play_state.load_from_file(self)
    message_panel:clear_messages()
    print("Loading state from file.")
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
                print(string.format("crc mismatch! %d <> %d.", other.check, crc))
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

function play_state.visit_loanshark(self)
    loan_shark_state:switch()
end

function play_state.visit_bank(self)
    bank_state:switch()
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
    self.purchase = {}
    trenchcoat:reset()
end

function player.lose_health(self, value)
    self.health = self.health - value
end

function player.restore_health(self)
    self.health = 100
    print("Your health is restored.")
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

function player.pay_debt(self, value)
    self.debt = self.debt - value
    self.debt_amount = util.comma_value(self.debt)
end

function player.add_day(self, new_location)
    self.location = new_location
    self.day = self.day + 1
    return self.day
end

function player.generate_events(self)

    -- load prediction
    math.randomseed(market.predictions[player.day])

    local brownies = math.random() < .1
    local buy_gun = math.random() < .08
    local buy_trenchcoat = math.random() < .07
    local smoke_paraquat = math.random() < .03
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
            message_panel:add_message(brownie_text, BAD_INFO, "hash")
        elseif trenchcoat:stock_of("Weed") > 20 then
            trenchcoat:adjust_stock("Weed", -math.random(1, 4))
            message_panel:add_message(brownie_text, BAD_INFO, "weed")
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
            message_panel:add_message("You meet a friend, "..flavor, BAD_INFO, name)
        end
    end

    if dropped_drugs then
        -- pick a drug where you have at least n units
        local name = trenchcoat:get_random(20)
        if name then
            -- lose it
            local delta = trenchcoat:adjust_stock(name, -math.random(10, 20))
            print(string.format("Event: lost %d %s.", delta, name))
            message_panel:add_message("Police dogs chase you for 3 blocks! You dropped some drugs! That's a drag, man!", BAD_INFO)
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
            message_panel:add_message(flavor, GOOD_INFO, delta, drug.name)
        end
    end

    if mugged then
        local amount = math.random(player.cash * .1, player.cash * .25)
        player:debit_account(amount)
        message_panel:add_message("You were mugged in the subway!", BAD_INFO)
        print(string.format("Event: lost $%d.", amount))
    end

    if detour then
        local bad_thing = util.pick("have a beer.", "smoke a joint.",
            "smoke a cigar.", "smoke a Djarum.", "smoke a cigarette.")
        message_panel:add_message("You stopped to "..bad_thing, ZERO_INFO)
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
        local thought = ""
        if math.random() < .3 then
            thought = " (at least, you -think- that's what she said)"
        end
        message_panel:add_message("The lady next to you on the subway said, `%s` %s", ZERO_INFO, anecdote, thought)
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
        message_panel:add_message("You hear someone playing %s.", ZERO_INFO, good_song)
    end

    -- % chance of encounter for every unit of drug carried
    local encounter_chance = (trenchcoat.size - trenchcoat.free) * .001 -- 10% / 100 units
    -- additional risk when carrying these
    local charlie_risk = trenchcoat:stock_of("Cocaine") * 0.003 -- +30%
    local heroin_risk = trenchcoat:stock_of("Heroin") * 0.003
    local hash_risk = trenchcoat:stock_of("Hashish") * 0.002 -- +20%
    local hash_risk = trenchcoat:stock_of("Opium") * 0.002
    local risk_factor = math.min(0.6, encounter_chance + charlie_risk + heroin_risk + hash_risk)
    print(string.format("Test for thug encounter at %d%%.", risk_factor * 100))
    if fight_encounter < risk_factor then
        player.gang_encounter = risk_factor
    end

    if self.day > 5 then
        if buy_gun then
            table.insert(self.purchase, "gun")
        end
        if buy_trenchcoat then
            table.insert(self.purchase, "trench coat")
        end
        if smoke_paraquat then
            table.insert(self.purchase, "paraquat")
        end
    end

    play_state:update_button_texts()

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
        print(string.format("Bought %d %s.", delta, drug.name))
    end
end

function player.sell_drug(btn)
    local drug = market.available[btn.number]
    local delta, current_stock = trenchcoat:adjust_stock(drug.name, -TRADE_SIZE)
    if delta > 0 then
        player:credit_account(delta * drug.cost)
        play_state:update_button_texts()
        print(string.format("Sold %d %s.", delta, drug.name))
    end
end

function player.debit_account(self, amount)
    local invalid_tran = "Attempt to debit %d from account, which only has %d"
    amount = math.floor(amount)
    assert(amount <= self.cash, string.format(invalid_tran, amount, self.cash))
    if amount > 0 then
        self.cash = self.cash - amount
        self.cash_amount = util.comma_value(self.cash)
        print(string.format("Account debited $%d.", amount))
    end
end

function player.credit_account(self, amount)
    amount = math.floor(amount)
    if amount > 0 then
        self.cash = self.cash + amount
        self.cash_amount = util.comma_value(self.cash)
        print(string.format("Account credited $%d.", amount))
    end
end

function player.accrue_debt(self)
    if self.debt > 0 then
        -- TODO: find out the correct loan interest rate
        self.debt = math.floor(self.debt * 1.05)
    end
    self.debt_amount = util.comma_value(self.debt)
end

function player.deposit_bank(self, amount)
    local transaction = math.min(self.cash, amount)
    if transaction > 0 then
        self:set_bank(self.bank + transaction)
        self:debit_account(transaction)
        print(string.format("Deposited %d into the bank.", transaction))
    end
end

function player.withdraw_bank(self, amount)
    local transaction = math.min(self.bank, amount)
    if transaction > 0 then
        self:set_bank(self.bank - transaction)
        self:credit_account(transaction)
        print(string.format("Withdrawn %d from the bank.", transaction))
    end
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
    print(string.format("Got a gun. You have %d.", self.guns))
end

--                       _
--  _ __  _   _ _ __ ___| |__   __ _ ___  ___
-- | '_ \| | | | '__/ __| '_ \ / _` / __|/ _ \
-- | |_) | |_| | | | (__| | | | (_| \__ \  __/
-- | .__/ \__,_|_|  \___|_| |_|\__,_|___/\___|
-- |_|
--
function purchase_state.load(self)

    local wc = require("harness.widgetcollection")
    self.buttons = wc:new()

    local run_box = layout.box["answer 1"]
    self.buttons:button("yes", {
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "Yes",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.confirm_purchase,
        disabled = true
    })

    local run_box = layout.box["answer 2"]
    self.buttons:button("no", {
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "No",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.reject_purchase,
        disabled = true
    })

    local run_box = layout.box["close prompt"]
    self.buttons:button("end game", {
        left = run_box[1],
        top = run_box[2],
        width = run_box[3],
        height = run_box[4],
        text = "Farewell",
        font = fonts:for_menu_button(),
        -- TODO: jmp to game end state
        context = self,
        callback = self.reject_purchase,
        hidden = true
    })

end

function purchase_state.switch(self, what)

    -- load prediction
    math.randomseed(market.predictions[player.day])

    self.what = what
    self.disable_timeout = 1
    self.title = "Purchase"

    self.buttons:get("yes").hidden = false
    self.buttons:get("no").hidden = false
    self.buttons:get("end game").hidden = true

    if what == "gun" then

        self.cost = math.random(250, 850)
        self.space_used = math.random(4, 8)
        local name = util.pick(".38 Special", "Ruger", "Saturday Night Special")
        local fancy_cost = util.comma_value(self.cost)
        self.message = string.format("Would you like to buy a %s for %s?", name, fancy_cost)

        -- not enough free space for this purchase
        print(string.format("X %d %d", trenchcoat:free_space(), self.space_used))
        if trenchcoat:free_space() < self.space_used then
            self.cost = nil
            print("Not enough free coat space to buy a gun.")
        end

        -- have enough guns already
        if player.guns >= 3 then
            self.cost = nil
            print("Player has enough guns. Not buying another.")
        end

    elseif what == "trench coat" then
        self.new_pockets = 20
        self.cost = math.random(450, 1250)
        local fancy_cost = util.comma_value(self.cost)
        self.message = string.format("Would you like to buy a trench coat with more pockets for %s?", fancy_cost)

    elseif what == "paraquat" then
        self.cost = 0
        self.title = "Offer"
        self.message = "You are offered weed that smells like paraquat. It looks good! Will you smoke it?"

    else
        print(string.format("No purchase logic for %s.", what))
        self.cost = nil
    end

    if self.cost and (player.cash < self.cost) then
        -- not enough cash for this purchase
        self.cost = nil
        print(string.format("Not enough cash to buy a %s.", what))
    end

    if self.cost then
        -- enter the purchase state
        active_state = self
    end

end

function purchase_state.update(self, dt)
    if self.disable_timeout > 0 then
        self.disable_timeout = math.max(0, self.disable_timeout - dt)
        self.buttons:get("yes").disabled = self.disable_timeout > 0
        self.buttons:get("no").disabled = self.disable_timeout > 0
    end
    self.buttons:update(dt)
end

function purchase_state.draw(self)
    fonts:set_large()
    love.graphics.setColor(PRIMARY_COLOR)
    love.graphics.print(self.title, layout:padded_point_at("title"))
    love.graphics.rectangle("line", layout:box_at("title"))
    fonts:set_medium()
    love.graphics.printf(self.message, layout:align_point_at("prompt", nil, "center"))
    self.buttons:draw()
end

function purchase_state.keypressed(self, key)
    self.buttons:keypressed(key)
end

function purchase_state.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function purchase_state.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function purchase_state.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function purchase_state.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function purchase_state.reject_purchase(self)
    play_state:switch()
end

function purchase_state.confirm_purchase(self)
    if self.what == "gun" then
        player:debit_account(self.cost)
        player:add_gun()
        trenchcoat:adjust_pockets(-self.space_used)
        message_panel:add_message("You purchased a gun.", GOOD_INFO)
        play_state:update_button_texts()
        play_state:switch()
    elseif self.what == "trench coat" then
        player:debit_account(self.cost)
        trenchcoat:adjust_pockets(self.new_pockets)
        message_panel:add_message("You purchased a new trench coat.", GOOD_INFO)
        play_state:update_button_texts()
        play_state:switch()
    elseif self.what == "paraquat" then
        self.buttons:get("yes").hidden = true
        self.buttons:get("no").hidden = true
        self.buttons:get("end game").hidden = false
        self.message = "You hallucinated for three days on the wildest trip you ever imagined! Then you died because your brain disintegrated!"
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

function trenchcoat.adjust_pockets(self, amount)
    amount = amount or 20
    self.size = self.size + amount
    self.free = self.free + amount
    print(string.format("Adjusted trench coat. You now have %d pockets.", self.size))
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
    trenchcoat:adjust_pockets()
end

function test.add_guns(self)
    player:add_gun()
end

function test.add_cash(self)
    player:credit_account(25000)
end
