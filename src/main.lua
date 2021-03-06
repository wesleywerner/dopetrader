-- Dope Trader
-- A turn-based commodity trading game.
-- Copyright 2021 Wesley Werner <wesley.werner@gmail.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program in the file named COPYING.
-- If not, see http://www.gnu.org/licenses/.

-- Window title
local TITLE = "Dope Trader"

-- Identify used by Löve for persistent storage
local IDENTITY = "dopetrader"

-- Game Version
local VERSION = "0.1 alpha"

-- Enable menu for testing (F1)
local DEBUG = false

-- Colour constants
local PRIMARY_10 = {0, .1, .1}
local PRIMARY_25 = {0, .25, .25}
local PRIMARY_30 = {0, .3, .3}
local PRIMARY_70 = {0, .7, .7}
local PRIMARY_100 = {0, 1, 1}
local WHITE = {1, 1, 1}
local YELLOW = {1, 1, 0}
local GOOD_INFO = {0, 1, .5}
local BAD_INFO = {1, 1, .5}
local ZERO_INFO = {.5, 1, 1}

-- Places we can jet to
local LOCATIONS = {"Bronx", "Ghetto", "Central Park",
                    "Manhattan", "Coney Island", "Brooklyn" }

-- Modular functions
local display = {}
local fonts = {}
local high_scores = {}
local layout = {}
local market = {}
local options = {}
local player = {}
local sound = {}
local test = {}
local trenchcoat = {}
local util = {}
local vibrate = {}

-- Game states
local state = {
    about = {},
    bank = {},
    debug = {},
    game_over = {},
    indemnity = {},
    jet = {},
    loanshark = {},
    menu = {},
    messages = {},
    options = {},
    play = {},
    shop = {},
    scores = {},
    thugs = {},
    tutorial = {}
}

--      _ _           _
--   __| (_)___ _ __ | | __ _ _   _
--  / _` | / __| '_ \| |/ _` | | | |
-- | (_| | \__ \ |_) | | (_| | |_| |
--  \__,_|_|___/ .__/|_|\__,_|\__, |
--             |_|            |___/
--
function display.set_adaptive(self, toggle)
    self.is_adaptive = toggle
    if not toggle then
        self:request_fast_fps()
    end
end

function display.dont_idle(self)
    self.idle_timeout = 5
    self.is_idle = false
end

function display.load(self)

    self.idle_fps = 1/2
    self.normal_fps = 1/10
    self.fast_fps = 1/30
    self:use_normal_fps()

    self.idle_timeout = 0

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

function display.use_normal_fps(self)
    if not self.is_adaptive then
        return
    end
    if not self.is_idle then
        self.current_fps = self.normal_fps
    end
end

function display.use_idle_fps(self)
    if not self.is_adaptive then
        return
    end
    self.is_idle = true
    self.current_fps = self.idle_fps
end

function display.request_fast_fps(self)
    if not self.is_adaptive then
        return
    end
    if not self.is_idle then
        self.current_fps = self.fast_fps
    end
end

function display.update(self, dt)
    if not self.is_adaptive then
        return
    end
    if dt < self.current_fps then
        love.timer.sleep(self.current_fps - dt)
    end
    if self.idle_timeout < 1 then
        self:use_idle_fps()
    else
        self.idle_timeout = self.idle_timeout - dt
    end
end

--   __             _
--  / _| ___  _ __ | |_ ___
-- | |_ / _ \| '_ \| __/ __|
-- |  _| (_) | | | | |_\__ \
-- |_|  \___/|_| |_|\__|___/
--
function fonts.for_about_text(self)
    if display.mobile then
        return self.medium
    else
        return self.medium
    end
end

function fonts.for_bank_button(self)
    if display.mobile then
        return self.medium
    else
        return self.large
    end
end

function fonts.for_jet_button(self)
    if display.mobile then
        return self.medium
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

function fonts.for_menu_button(self)
    if display.mobile then
        return self.large
    else
        return self.large
    end
end

function fonts.for_option_text(self)
    return self.small
end

function fonts.for_option_title(self)
    if display.mobile then
        return self.medium
    else
        return self.medium
    end
end

function fonts.for_player_stats(self)
    if display.mobile then
        return self.small
    else
        return self.medium
    end
end

function fonts.for_score_listing(self)
    if display.mobile then
        return self.small
    else
        return self.medium
    end
end

function fonts.for_shop_question(self)
    if display.mobile then
        return self.medium
    else
        return self.large
    end
end

function fonts.for_title(self)
    if display.mobile then
        return self.large
    else
        return self.large
    end
end

function fonts.for_tutorial(self)
    if display.mobile then
        return self.medium
    else
        return self.medium
    end
end

function fonts.load(self)
    self.large = love.graphics.newFont("res/BodoniflfBold-MVZx.ttf", 40)
    self.medium = love.graphics.newFont("res/BodoniflfBold-MVZx.ttf", 24)
    self.small = love.graphics.newFont("res/BodoniflfBold-MVZx.ttf", 18)
end

function fonts.measure(self, font, sample, alignmode, width)
    local to = love.graphics.newText(font)
    to:addf(sample or "$", width or display.safe_w, alignmode or "left")
    return to:getDimensions()
end

function fonts.set_large(self)
    love.graphics.setFont(self.large)
end

function fonts.set_medium(self)
    love.graphics.setFont(self.medium)
end

function fonts.set_small(self)
    love.graphics.setFont(self.small)
end

--  _     _       _
-- | |__ (_) __ _| |__    ___  ___ ___  _ __ ___  ___
-- | '_ \| |/ _` | '_ \  / __|/ __/ _ \| '__/ _ \/ __|
-- | | | | | (_| | | | | \__ \ (_| (_) | | |  __/\__ \
-- |_| |_|_|\__, |_| |_| |___/\___\___/|_|  \___||___/
--          |___/
--
function high_scores.add(self, person, value, rip)
    if self:is_accepted(value) then
        local entry = { name=person, score=value, rip=rip, date=os.time() }
        table.insert(self.entries, entry)
        self:sort()
        self:cull()
        self:write_file()
        print(string.format("Added %s to the high scores list.", person))
        return self:rank_of(person, value)
    end
end

function high_scores.cull(self)
    while #self.entries > self.max_entries do
        local loser = table.remove(self.entries, #self.entries)
        print(string.format("Kicked %s off the high scores list.", loser.name))
    end
end

function high_scores.filename(self)
    if DEBUG then
        return "scores_debug"
    else
        return "scores"
    end
end

function high_scores.generate_default_scores(self)

    local scores_exist = love.filesystem.getInfo(self:filename(), "file") ~= nil
    if scores_exist then
        return false
    end

    local names = {
        "Trippie Tim", "Pepper Pusher", "Kitty Ketamine",
        "Sunshine Seller", "Lilly Lewd", "Johnny-E" }

    self.entries = {}

    for n, person in ipairs(names) do
        table.insert(self.entries, {
            name=person,
            date=os.time{year=1984, month=1, day=1},
            score=math.floor(n*500000)
            })
    end

    self:sort()
    self:write_file()
    return true

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

function high_scores.listing(self)
    local results = {}
    for rank, entrant in ipairs(self.entries) do
        table.insert(results, {
            name = entrant.name,
            date = os.date("%d-%b-%Y", entrant.date),
            score = util.comma_value(entrant.score),
            rip = entrant.rip,
            rank = rank
        })
    end
    return results
end

function high_scores.load(self)

    self.max_entries = 10

    if not self:generate_default_scores() then
        self:read_file()
    end

    print("The High Rollers are:")
    for _, v in ipairs(self:listing()) do
        print(v.rank, v.date, v.name, v.score)
    end

end

function high_scores.rank_of(self, person, value)
    for rank, entrant in ipairs(self.entries) do
        if entrant.name == person and entrant.score == value then
            return rank
        end
    end
end

function high_scores.read_file(self)
    self.entries = {}
    for line in util.read_file(self:filename()) do
        local record = {}
        for key, value in util.key_value_pairs(line, true) do
            record[key] = value
        end
        if self:valid_record(record) then
            table.insert(self.entries, record)
        end
    end
end

function high_scores.sort(self)
    table.sort(self.entries, function(a,b) return a.score > b.score end)
end

function high_scores.valid_record(self, record)
    local isvalid = type(record.name) == "string"
        and type(record.date) == "number"
        and type(record.score) == "number"
    if isvalid and record.crc ~= util.crc(record) then
        -- Burn!
        record[util.rot("anzr")] = util.rot("Purngre")
    end
    return isvalid
end

function high_scores.write_file(self)
    util.write_file(self:filename(), self.entries)
end

--  _                         _
-- | | __ _ _   _  ___  _   _| |_
-- | |/ _` | | | |/ _ \| | | | __|
-- | | (_| | |_| | (_) | |_| | |_
-- |_|\__,_|\__, |\___/ \__,_|\__|
--          |___/
--
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

function layout.button_collection(self, ...)

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
            text = name,
            options = options
        })
    end

    return collection

end

function layout.label_collection(self, ...)

    local names = {...}

    local collection = require("harness.widgetcollection"):new()

    for _, name in ipairs(names) do
        assert(self.box[name], string.format("%s not a valid layout name", name))
        local x, y, w, h = layout:box_at(name)
        collection:label(name, {
            left = x,
            top = y,
            width = w,
            height = h,
            text = name
        })
    end

    return collection

end

function layout.load(self)
    self.point = {}
    self.box = {}
    self.padded_box = {}
    self.padded_point = {}
    self:map(require("play_layout"))
    self:map(require("jet_layout"))
    self:map(require("prompt_layout"))
    self:map(require("menu_layout"))
    self:map(require("options_layout"))
    self:map(require("debug_layout"))
    self:map(require("about_layout"))
end

function layout.map(self, definition)
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

function layout.padded_point_at(self, key, index)
    return unpack(self.padded_point[string.format(key, index)])
end

function layout.point_at(self, key, index)
    return unpack(self.point[string.format(key, index)])
end

function layout.underline_at(self, key, index)
    local _x, _y, _w, _h = self:box_at(key, index)
    return _x, _y+_h, _x+_w, _y+_h
end

--  _
-- | | _____   _____
-- | |/ _ \ \ / / _ \
-- | | (_) \ V /  __/
-- |_|\___/ \_/ \___|
--
function love.draw()
    active_state:draw()
end

function love.keypressed(key, isrepeat)
    display:dont_idle()
    active_state:keypressed(key)
end

function love.keyreleased(key, scancode)
    active_state:keyreleased(key)
end

function love.load()

    print(string.format("Welcome to %s!", TITLE))

    -- do not prevent device from sleeping
    love.window.setDisplaySleepEnabled(true)

    -- set window title, identity for save/score files
    love.window.setTitle(TITLE)
    love.filesystem.setIdentity(IDENTITY)

    fonts:load()
    high_scores:load()
    display:load()
    layout:load()
    player:load()
    market:load()
    options:load()
    sound:load()

    display:set_adaptive(options.adaptive_fps)

    -- Load game states
    for k, v in pairs(state) do
        state[k]:load()
    end

    state.menu:switch()
    state.indemnity:switch()

end

function love.mousemoved(x, y, dx, dy, istouch)
    display:dont_idle()
    active_state:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch)
    display:dont_idle()
    active_state:mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    active_state:mousereleased(x, y, button, istouch)
end

function love.textinput(t)
    if active_state.textinput then
        active_state:textinput(t)
    end
end

function love.update(dt)
    display:use_normal_fps()
    active_state:update(dt)
    display:update(dt)
    vibrate:update(dt)
    sound:update()
    if state.tutorial.running then
        state.tutorial:update(dt)
    end
end

function love.wheelmoved(x, y)
    if active_state.wheelmoved then
        active_state:wheelmoved(x, y)
    end
end

--                       _        _
--  _ __ ___   __ _ _ __| | _____| |_
-- | '_ ` _ \ / _` | '__| |/ / _ \ __|
-- | | | | | | (_| | |  |   <  __/ |_
-- |_| |_| |_|\__,_|_|  |_|\_\___|\__|
--
function market.fluctuate(self, list_everything)

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

    -- Everything is on the market for sale
    if list_everything then
        count = #self.db
    end

    self.available = {}
    self.is_available = {}

    while #self.available < count do

        -- pick a random stock from the bag
        local drug = table.remove(drugbag, math.random(1, #drugbag))

        -- get the market cost
        local cost = math.random(drug.min, drug.max)

        -- a major market event
        if math.random() < .15 then
            if drug.inc then
                cost = math.random(drug.max * 2, drug.max * 4)
                local template = util.pick(unpack(self.increase_message))
                    or "%s increase template not found"
                state.messages:add(template, GOOD_INFO, drug.name)
            elseif drug.dec then
                cost = math.floor(cost / math.random(3, 6))
                local template = self.decrease_message[drug.name]
                    or "%s decrease template not found"
                state.messages:add(template, GOOD_INFO)
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

function market.cheapest_available(self)
    local pick = self.available[1]
    for _, drug in ipairs(self.available) do
        if drug.cost < pick.cost then
            pick = drug
        end
    end
    return pick
end

function market.initialize_predictions(self)

    -- roll the dice
    print(string.format("Predicting the market with seed %d", player.seed))
    math.randomseed(player.seed)

    -- predict market fluctuations for the next month
    self.predictions = {}
    for i=1, 31 do
        table.insert(self.predictions, math.random())
    end

end

function market.load(self)

    -- define the trading stock
    self.db = {
        {name="Ludes",   min=10,    max=50,    inc=false, dec=true , unit="pill"},
        {name="Speed",   min=70,    max=180,   inc=true,  dec=false, unit="pill"},
        {name="Peyote",  min=200,   max=500,   inc=false, dec=false, unit="baggie"},
        {name="Weed",    min=300,   max=600,   inc=false, dec=true , unit="baggie"},
        {name="Hashish", min=450,   max=900,   inc=false, dec=true , unit="baggie"},
        {name="Opium",   min=500,   max=800,   inc=true,  dec=false, unit="baggie"},
        {name="Shrooms", min=600,   max=750,   inc=false, dec=true , unit="baggie"},
        {name="PCP",     min=1000,  max=2500,  inc=false, dec=false, unit="baggie"},
        {name="Acid",    min=1000,  max=3500,  inc=false, dec=true , unit="tab"},
        {name="MDA",     min=1500,  max=3000,  inc=false, dec=true , unit="pill"},
        {name="Heroin",  min=5000,  max=9000,  inc=true,  dec=false, unit="baggie"},
        {name="Cocaine", min=15000, max=26000, inc=true,  dec=false, unit="baggie"}
    }

    -- define the special event messages
    self.increase_message = {
        "Cops made a %s bust, prices are outrageous!",
        "A big %s bust is causing a buying frenzy!",
        "Addicts are buying %s at premium prices!"
    }

    self.decrease_message = {
        Acid="The market has been flooded with cheap home-made acid.",
        Hashish="The Marrakesh Express has arrived.",
        Ludes="Rival drug dealers raided a pharmacy and are selling cheap ludes.",
        Weed="Columbian freighter dusted the Coast Guard - Weed prices have bottomed out.",
        Shrooms="A huge trance festival is in town, hippies are selling cheap Shrooms.",
        MDA="A huge trance festival is in town, hippies are selling cheap MDA."
    }

end

--              _   _
--   ___  _ __ | |_(_) ___  _ __  ___
--  / _ \| '_ \| __| |/ _ \| '_ \/ __|
-- | (_) | |_) | |_| | (_) | | | \__ \
--  \___/| .__/ \__|_|\___/|_| |_|___/
--       |_|
--
function options.load(self)

    -- default options
    self.vibrate = true
    self.adaptive_fps = display.mobile
    self.sound = true
    self.tutorial = true

    -- restore from file, if present
    self:restore()

end

function options.restore(self)
    for line in util.read_file("options") do
        for key, value in util.key_value_pairs(line, false) do
            self[key] = value
        end
    end
end

function options.save(self)
    util.write_file("options", {self})
end

--        _
--  _ __ | | __ _ _   _  ___ _ __
-- | '_ \| |/ _` | | | |/ _ \ '__|
-- | |_) | | (_| | |_| |  __/ |
-- | .__/|_|\__,_|\__, |\___|_|
-- |_|            |___/
--
function player.accrue_debt(self)
    if self.debt > 0 then
        self.debt = math.floor(self.debt * 1.1)
    end
    self.debt_amount = util.comma_value(self.debt)
end

function player.add_day(self, new_location)
    self.location = new_location
    self.day = self.day + 1
    print(string.format("Day %d: Jetting to %s ...", self.day, new_location))
    return self.day
end

function player.add_gun(self)
    self.guns = self.guns + 1
    print(string.format("Got a gun. You have %d.", self.guns))
end

function player.buy_drug(btn, amount)
    amount = amount or 1
    local drug = market.available[btn.number]
    -- clamp allowed to player cash
    local max_purchasable = math.floor(player.cash / drug.cost)
    ---- clamp to free space (MOVED TO adjust_stock())
    --max_purchasable = math.min(trenchcoat:free_space(), max_purchasable)
    -- clamp to trading size
    max_purchasable = math.min(amount, max_purchasable)
    if max_purchasable > 0 then
        local delta, current_stock = trenchcoat:adjust_stock(drug.name, max_purchasable)
        player:debit_account(delta * drug.cost)
        state.play:update_button_texts()
        sound:play("sale")
    end
end

function player.credit_account(self, amount)
    amount = math.floor(amount)
    if amount > 0 then
        self.cash = self.cash + amount
        self.cash_amount = util.comma_value(self.cash)
        print(string.format("Account credited %s.", util.comma_value(amount)))
    end
end

function player.debit_account(self, amount)
    local invalid_tran = "Attempt to debit %d from account, which only has %d"
    amount = math.floor(amount)
    assert(amount <= self.cash, string.format(invalid_tran, amount, self.cash))
    if amount > 0 then
        self.cash = self.cash - amount
        self.cash_amount = util.comma_value(self.cash)
        print(string.format("Account debited %s.", util.comma_value(amount)))
    end
end

function player.deposit_bank(self, amount)
    local transaction = math.min(self.cash, amount)
    if transaction > 0 then
        self:set_bank(self.bank + transaction)
        self:debit_account(transaction)
        print(string.format("Deposited %s into the bank.", util.comma_value(transaction)))
    end
end

function player.generate_events(self)

    -- load prediction
    math.randomseed(market.predictions[player.day])

    local brownies = math.random() < .1
    local buy_gun = math.random() < .15 -- 4.65 times a month (31*0.15)
    local buy_trenchcoat = math.random() < .1 -- 3.1 times a month (31*0.1)
    local smoke_paraquat = math.random() < .03 -- 0.93 times a month (31*0.03)
    local find_drugs = math.random() < .07
    local give_drugs = math.random() < .07
    local dropped_drugs = math.random() < .07
    local mugged = math.random() < .05
    local detour = math.random() < .1
    local subway_anecdote = math.random() < .15
    local hear_music = math.random() < .15
    local thug_encounter = math.random()

    if brownies then
        local brownie_text = "Your mama made brownies with some of your %s, "
            .. " they were great!"
        if trenchcoat:stock_of("Hashish") > 20 then
            trenchcoat:adjust_stock("Hashish", -math.random(1, 4))
            state.messages:add(brownie_text, BAD_INFO, "hash")
        elseif trenchcoat:stock_of("Weed") > 20 then
            trenchcoat:adjust_stock("Weed", -math.random(1, 4))
            state.messages:add(brownie_text, BAD_INFO, "weed")
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
                "you give them some %s.")
            state.messages:add("You meet a friend, "..flavor, BAD_INFO, name)
        end
    end

    if dropped_drugs then
        -- pick a drug where you have at least n units
        local name = trenchcoat:get_random(20)
        if name then
            -- lose it
            local delta = trenchcoat:adjust_stock(name, -math.random(10, 20))
            state.messages:add("Police chase you for 3 blocks, "
                .. "you dropped some drugs. That's a drag!", BAD_INFO)
        end
    end

    if find_drugs then
        local drug = util.pick(unpack(market.db))
        -- delta amount of drugs added to your coat
        local delta = trenchcoat:adjust_stock(drug.name, math.random(3, 10))
        if delta > 0 then
            local flavor = util.pick(
                "You find %d %s %ss on a dead dude in the subway.",
                "You meet a friend, they lay %d %s %ss on you.")
            state.messages:add(flavor, GOOD_INFO, delta, drug.name, drug.unit)
        end
    end

    if mugged then
        local amount = math.random(player.cash * .1, player.cash * .25)
        player:debit_account(amount)
        state.messages:add("You were mugged in the subway!", BAD_INFO)
    end

    if detour then
        local bad_thing = util.pick("have a beer.", "smoke a joint.",
            "smoke a cigar.", "smoke a Djarum.", "smoke a cigarette.")
        state.messages:add("You stopped to "..bad_thing, ZERO_INFO)
    end

    if subway_anecdote then
        local anecdote = util.pick(
        "Got any dope?",
        "Shrooms give me interesting dreams.",
        "I'm going to Amsterdam this year.",
        "It's wonderful what they're doing with incense these days.",
        "Does your mother know you're a dope dealer?",
        "Are you high?",
        "I used to be a hippie.",
        "There's nothing like money.",
        "You look like an aardvark!",
        "I believe in Aliens.",
        "Courage!",
        "Haven't I seen you on TV?",
        "I think pharmaceutical commercials are great.",
        "We're winning the war for drugs!",
        "A day without dope is like night.",
        "We only use 20% of our brains, so why not burn out the other 80%?",
        "Are you prepared for the Zombie Apocalypse?",
        "I'd like to sell you an edible poodle.",
        "Winners don't do drugs... unless they do.",
        "I am the walrus!",
        "I have an urge to dye my hair blue.",
        "Just say No... well, maybe... Ok, what the hell!",
        "Would you like a jelly baby?",
        "Drugs can be your friend.")
        local who = util.pick("The lady", "A bum", "A kid", "A lawyer", "A beggar")
        state.messages:add("%s on the subway said: %q", ZERO_INFO, who, anecdote)
    end

    if hear_music then
        local good_song = util.pick(
        "`Marijuana in your Brain` by Lords of Acid",
        "`Money` by Pink Floyd",
        "`The Perfect Drug` by Nine Inch Nails",
        "`I Don't Like The Drugs` by Marilyn Manson",
        "`Acid Test` by Sheep on Drugs",
        "`Drugs, Drugs` by Virtual Embrace",
        "`A Drug Against War` by KMFDM",
        "`Coming Down` by The Cult",
        "`Need You Like A Drug` by Zeromancer",
        "`Heroin` by The Doors",
        "`Stoned Immaculate` by The Doors",
        "`Stoned` by The Rolling Stones",
        "`Ten Feet High` by Sugardrive",
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
        "`Henry` by the New Riders of the Purple Sage",
        "`Kicks` by Paul Revere and The Raiders",
        "`Legalize It` by Mojo Nixon and Skid Roper")
        state.messages:add("You hear someone playing %s.", ZERO_INFO, good_song)
    end

    -- Determine thug encounter.
    -- % chance for every unit of drug carried
    local encounter_chance = trenchcoat:total_carried() * .002 -- 20% / 100 units

    -- additional risk when carrying these
    local charlie_risk = trenchcoat:stock_of("Cocaine") * 0.003 -- 30%
    local heroin_risk = trenchcoat:stock_of("Heroin") * 0.003
    local hash_risk = trenchcoat:stock_of("Hashish") * 0.002 -- 20%
    local hash_risk = trenchcoat:stock_of("Opium") * 0.002

    -- Combine all risks into a single factor, limited to maximum 100%
    local risk_factor = math.min(1, encounter_chance + charlie_risk + heroin_risk + hash_risk)

    -- Test if risk factor is above the random thug encounter value
    print(string.format("%d%% chance of a thug encounter.", risk_factor * 100))
    if thug_encounter < risk_factor then
        player.thug_encounter = risk_factor
    end

    if self.day > 5 then
        if buy_gun then
            player:queue_purchase("gun")
        end
        if buy_trenchcoat then
            player:queue_purchase("trench coat")
        end
        if smoke_paraquat then
            player:queue_purchase("paraquat")
        end
    end

end

function player.load(self)
    state.messages:clear()
end

function player.lose_health(self, value)
    self.health = self.health - value
    if self.health < 1 then
        print("** You DIE **")
    else
        print(string.format("\tHealth down to %d", self.health))
    end
end

function player.pay_debt(self, value)
    self.debt = self.debt - value
    self.debt_amount = util.comma_value(self.debt)
end

function player.reset(self)
    self.seed = os.time()
    self.day = 1
    self:set_cash(2000)
    self.health = 100
    self.guns = 0
    self:set_bank(0)
    self:set_debt(5500)
    self.location = LOCATIONS[1]
    self.thug_encounter = false
    self.in_progress = true
    self.purchase = {}
    trenchcoat:reset()
    state.messages:clear()
end

function player.restore_health(self)
    self.health = 100
    print("Your health is restored.")
end

function player.queue_purchase(self, item)
    for _, e in ipairs(self.purchase) do
        if e == item then
            return
        end
    end
    table.insert(self.purchase, item)
    local result = string.format("Queued purchase: %s", item)
    print(result)
    return result
end

function player.sell_drug(btn, amount)
    amount = amount or 1
    local drug = market.available[btn.number]
    local delta, current_stock = trenchcoat:adjust_stock(drug.name, -amount)
    if delta > 0 then
        player:credit_account(delta * drug.cost)
        state.play:update_button_texts()
        sound:play("sale")
    end
end

function player.set_bank(self, value)
    self.bank = value or self.bank
    self.bank_amount = util.comma_value(self.bank)
end

function player.set_cash(self, value)
    self.cash = value or self.cash
    self.cash_amount = util.comma_value(self.cash)
end

function player.set_debt(self, value)
    self.debt = value or self.debt
    self.debt_amount = util.comma_value(self.debt)
end

function player.withdraw_bank(self, amount)
    local transaction = math.min(self.bank, amount)
    if transaction > 0 then
        self:set_bank(self.bank - transaction)
        self:credit_account(transaction)
        print(string.format("Withdrawn %s from the bank.", util.comma_value(transaction)))
    end
end

--                            _
--  ___  ___  _   _ _ __   __| |
-- / __|/ _ \| | | | '_ \ / _` |
-- \__ \ (_) | |_| | | | | (_| |
-- |___/\___/ \__,_|_| |_|\__,_|
--
function sound.count(self, name)
    local n = 0
    for _, q in ipairs(self.queue) do
        if q == name then
            n = n + 1
        end
    end
    return n
end

function sound.next(self)
    if self.queue[1] then
        return self.queue[1], self.library[self.queue[1]]
    end
end

function sound.load(self)
    self.library = {
        gun = love.audio.newSource("res/pistol.ogg", "static"),
        sale = love.audio.newSource("res/sell_buy_item.ogg", "static"),
        pain = love.audio.newSource("res/gruntsound.ogg", "static"),
        purchase = love.audio.newSource("res/cashregister.ogg", "static"),
        run = love.audio.newSource("res/run.ogg", "static"),
        train = love.audio.newSource("res/train.ogg", "static"),
        applause = love.audio.newSource("res/applause.ogg", "static"),
    }
    self.queue = {}
end

function sound.play(self, name, limit)
    if options.sound then
        limit = limit or 1
        if self:count(name) >= limit then
            return
        end
        if self.library[name] then
            table.insert(self.queue, name)
        else
            print(string.format("Sound: no sfx named %q", name))
        end
    end
end

function sound.update(self)
    if self.current then
        if not self.current:isPlaying() then
            -- Done
            self.current = nil
            -- Dequeue
            table.remove(self.queue, 1)
        end
    else
        local name, next = self:next()
        if next then
            -- Remember and play
            self.current = next
            next:play()
        end
    end
end

--        _                 _
--   __ _| |__   ___  _   _| |_
--  / _` | '_ \ / _ \| | | | __|
-- | (_| | |_) | (_) | |_| | |_
--  \__,_|_.__/ \___/ \__,_|\__|
--
function state.about.draw(self)
    self.buttons:draw()

    -- content border
    love.graphics.setColor(PRIMARY_100)
    love.graphics.rectangle("line", layout:box_at("about content"))

    -- content (camera)
    self.camera:pose()
    love.graphics.setFont(fonts:for_about_text())
    love.graphics.setColor(WHITE)
    love.graphics.printf(self.text, 10, 10, self.content_width)
    love.graphics.printf(VERSION, 0, 10, self.content_width, "right")
    self.web_button:draw()
    self.camera:relax()

end

function state.about.exit_state(self)
    state.menu:switch()
end

function state.about.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        self:exit_state()
    end
end

function state.about.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function state.about.load(self)

    self.text = {
        WHITE, TITLE .. "\n\n",
        PRIMARY_100, "You play the role of a drug dealer in debt. "
            .. "You have one month to trade drugs and repay your debt. "
            .. "\n\n",
        PRIMARY_100, "One day passes when you travel to a new location. "
            .. "Each day prices fluctuate due to market demand. "
            .. "When a drug is not in demand it cannot be traded. "
            .. "\n\n",
        PRIMARY_100, "Carrying more merchandise increases the risk of "
            .. "rival gang encounters. "
            .. "You can fight back and take their cash if you have guns. "
            .. "Your chance to hit a thug increases with each gun you carry. "
            .. "\n\n",
        PRIMARY_100, "Purchasing a gun happen randomly when you go "
            .. "to a new location, and similarly, purchasing a new trench coat "
            .. "that has more pockets. "
            .. "\n\n",

        WHITE, "Inspiration\n\n",
        PRIMARY_100, TITLE .. " is inspired by the 1984 classic by John Dell, "
            .. " Drug Wars. Mr Dell created his game as a project for his "
            .. " high school computer class. He got an A. He never uploaded his "
            .. " creation to a BBS, but he did give copies to friends. "
            .. " It not only survived but became a hit, so to speak, in a "
            .. " small corner of the computer gaming world. "
            .. "\n\n",

        PRIMARY_100, "This program is free software: you can redistribute it and/or modify "
            .. "it under the terms of the GNU General Public License as published by "
            .. "the Free Software Foundation, either version 3 of the License, or "
            .. "any later version."
            .. "\n\n"
            .. "Please visit the game site for full source, licensing "
            .. "and acknowledgements for font, sounds and images used."
    }

    self.buttons = layout:button_collection("about close")

    self.buttons:set_values{
        name = "about close",
        text = "Close",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.exit_state
    }

    -- place camera
    local content_box = layout.box["about content"]
    self.camera = require("harness.camera")
    self.camera:worldSize(content_box[3], content_box[4] * 3)
    self.camera:frame(content_box[1], content_box[2],
        content_box[3], content_box[4])
    self.content_width = self.camera.worldWidth - 10

    -- place website button
    local _, text_height = fonts:measure(
        fonts:for_about_text(), self.text, "left", self.content_width)
    self.buttons:button("website", {
        left = display.safe_x + math.floor(display.safe_w * 0.1),
        top = text_height + 40,
        width = math.floor(display.safe_w * 0.7),
        height = 60,
        font = fonts:for_menu_button(),
        text = "Visit Website",
        callback = state.about.visit_website
    })
    self.web_button = self.buttons:get("website")

end

function state.about.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)

    -- scroll the camera while mouse/touch is pressed
    if self.pressed_y then
        self.pressed_y = y
        self.camera:moveBy(0, dy)
    end

    -- focus button inside camera frame
    local _x, _y = self.camera:pointToFrame(x, y)
    if _x and _y then
        self.web_button:mousemoved(_x, _y)
    end

end

function state.about.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)

    -- capture mouse/touch press position for camera scroll
    if self.camera:pointToFrame(x, y) then
        self.pressed_y = y
    else
        self.pressed_y = nil
    end

    -- press button inside camera frame
    local _x, _y = self.camera:pointToFrame(x, y)
    if _x and _y then
        self.web_button:mousepressed(_x, _y, button, istouch)
    end

end

function state.about.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
    self.pressed_y = nil
end

function state.about.scroll_down(self)
    self.camera:moveBy(0, -math.floor(display.safe_h))
end

function state.about.scroll_up(self)
    self.camera:moveBy(0, math.floor(display.safe_h))
end

function state.about.switch(self)
    active_state = self
end

function state.about.update(self, dt)
    self.camera:update(dt)
    if not self.camera.complete then
        display:request_fast_fps()
    end
end

function state.about.visit_website()
    love.system.openURL("https://engrams.dev/dopetrader")
end

function state.about.wheelmoved(self, x, y)
    if self.camera.complete then
        self.camera:moveBy(0, y * 100)
    end
end

--  _                 _
-- | |__   __ _ _ __ | | __
-- | '_ \ / _` | '_ \| |/ /
-- | |_) | (_| | | | |   <
-- |_.__/ \__,_|_| |_|_|\_\
--
function state.bank.do_deposit(self)
    self.is_depositing = true
    self.is_withdrawing = false
    self:toggle_transact(true)
    self.buttons:get("slider"):set_maximum(player.cash)
end

function state.bank.do_transact(self)
    local slider = self.buttons:get("slider")
    if self.is_depositing then
        player:deposit_bank(slider.value)
    else
        player:withdraw_bank(slider.value)
    end
    sound:play("purchase")
    state.play:switch()
end

function state.bank.do_withdraw(self)
    self.is_depositing = false
    self.is_withdrawing = true
    self:toggle_transact(true)
    self.buttons:get("slider"):set_maximum(player.bank)
end

function state.bank.draw(self)

    fonts:set_large()
    love.graphics.setColor(PRIMARY_100)

    love.graphics.print("Cash", layout:padded_point_at("title"))
    love.graphics.printf(player.cash_amount, layout:align_point_at("title",nil,"right"))
    love.graphics.rectangle("line", layout:box_at("title"))

    if self.message then
        love.graphics.printf(self.message, layout:align_point_at("prompt", nil, "center"))
    end

    self.buttons:draw()

end

function state.bank.exit_state(self)
    state.play:switch()
end

function state.bank.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        state.play:switch()
    end
end

function state.bank.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function state.bank.load(self)

    self.buttons = layout:button_collection(
        "answer 1", "answer 2", "close button 1", "close button 2")

    self.buttons:set_values{
        name = "answer 1",
        text = "Deposit",
        font = fonts:for_bank_button(),
        context = self,
        callback = self.do_deposit
    }

    self.buttons:set_values{
        name = "answer 2",
        text = "Withdraw",
        font = fonts:for_bank_button(),
        context = self,
        callback = self.do_withdraw
    }

    self.buttons:set_values{
        name = "close button 2",
        text = "Leave",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.exit_state
    }

    self.buttons:set_values{
        name = "close button 1",
        text = "Transact",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.do_transact
    }

    -- Cash amount slider control
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

function state.bank.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.bank.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function state.bank.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function state.bank.switch(self)

    -- No Deposit without enough cash
    self.buttons:get("answer 1").disabled = player.cash < 1000

    -- No Withdrawal without funds in bank
    self.buttons:get("answer 2").disabled = player.bank == 0

    self:toggle_transact(false)

    active_state = self

end

function state.bank.toggle_transact(self, value)

    -- Deposit
    self.buttons:get("answer 1").hidden = value

    -- Withdraw
    self.buttons:get("answer 2").hidden = value

    -- Transact
    self.buttons:get("close button 1").hidden = not value

    -- Cash slider
    self.buttons:get("slider").hidden = not value

end

function state.bank.update(self, dt)

end

--      _      _
--   __| | ___| |__  _   _  __ _
--  / _` |/ _ \ '_ \| | | |/ _` |
-- | (_| |  __/ |_) | |_| | (_| |
--  \__,_|\___|_.__/ \__,_|\__, |
--                         |___/
--
function state.debug.draw(self)
    self.labels:draw()
    self.buttons:draw()
end

function state.debug.frombulate(action)
    if action == "money bags" then
        player:credit_account(50000)
        state.debug:show_message("Account credited $50,000")
    elseif action == "lock and load" then
        state.debug:show_message(player:queue_purchase("gun"))
    elseif action == "paraquat" then
        state.debug:show_message(player:queue_purchase("paraquat"))
    elseif action == "pocket it" then
        state.debug:show_message(player:queue_purchase("trench coat"))
    elseif action == "scuffle" then
        player.thug_encounter = .4
        state.debug:show_message("A few thugs are waiting for you")
    elseif action == "fight club" then
        player.thug_encounter = 1
        state.debug:show_message("Many thugs are waiting for you!")
    elseif action == "simulate scuffle" then
        state.debug:simulate_fighting(0.5)
    elseif action == "simulate fight club" then
        state.debug:simulate_fighting(1)
    elseif action == "simulate easy run" then
        state.debug:simulate_running(0.5)
    elseif action == "simulate hard run" then
        state.debug:simulate_running(1)
    end
end

function state.debug.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        self.previous_state:switch()
    end
end

function state.debug.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function state.debug.load(self)

    self.labels = layout:label_collection("debug message")
    self:show_message("")

    self.buttons = layout:button_collection(
        "debug 1", "debug 2", "debug 3", "debug 4", "debug 5", "debug 6",
        "debug 7", "debug 8", "debug 9", "debug 10")

    self.buttons:set_values{
        name = "debug 1",
        text = "$$$",
        context = "money bags",
        callback = self.frombulate
    }

    self.buttons:set_values{
        name = "debug 2",
        text = "Gun",
        context = "lock and load",
        callback = self.frombulate
    }

    self.buttons:set_values{
        name = "debug 3",
        text = "Coat",
        context = "pocket it",
        callback = self.frombulate
    }

    self.buttons:set_values{
        name = "debug 4",
        text = "Paraquat",
        context = "paraquat",
        callback = self.frombulate
    }

    self.buttons:set_values{
        name = "debug 5",
        text = "Thugs (hard)",
        context = "fight club",
        callback = self.frombulate
    }

    self.buttons:set_values{
        name = "debug 6",
        text = "Thugs (easy)",
        context = "scuffle",
        callback = self.frombulate
    }

    self.buttons:set_values{
        name = "debug 7",
        text = "easy fight simula",
        context = "simulate scuffle",
        callback = self.frombulate
    }

    self.buttons:set_values{
        name = "debug 8",
        text = "hard fight simula",
        context = "simulate fight club",
        callback = self.frombulate
    }

    self.buttons:set_values{
        name = "debug 9",
        text = "easy run simula",
        context = "simulate easy run",
        callback = self.frombulate
    }

    self.buttons:set_values{
        name = "debug 10",
        text = "hard run simula",
        context = "simulate hard run",
        callback = self.frombulate
    }

end

function state.debug.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.debug.mousepressed(self, x, y, button, istouch)
    self:show_message("")
    self.buttons:mousepressed(x, y, button, istouch)
end

function state.debug.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function state.debug.show_message(self, text)
    self.labels:set_values{
        name = "debug message",
        text = text
    }
end

function state.debug.simulate_fighting(self, risk_factor)
    -- remember current state
    local _seed = player.seed
    local _day = player.day
    local _sound = options.sound
    local _vibe = options.vibrate
    -- turn off sound, vibes
    options.sound = false
    options.vibrate = false
    -- reseed
    player.seed = os.time()
    market:initialize_predictions()
    -- run simulation
    local _wins, _losses = 0, 0
    for n = 1, #market.predictions do
        player.health = 100
        player.day = n
        state.thugs:switch(risk_factor)
        local _attempts = 0
        while player.health > 0 and state.thugs.thugs > 0 do
            state.thugs:attempt_fight()
        end
        if player.health < 1 then
            _losses = _losses + 1
        elseif state.thugs.thugs == 0 then
            _wins = _wins + 1
        end
    end
    -- restore state
    options.sound = _sound
    options.vibrate = _vibe
    player.day = _day
    player.seed = _seed
    player.health = 100
    player.thug_encounter = false
    active_state = state.debug
    -- report
    local _winrate = math.floor((_wins / #market.predictions) * 100)
    local _report = string.format("wins: %d (%d%%) losses: %d", _wins, _winrate, _losses)
    print("Simulation report - ".._report)
    self:show_message(_report)
end

function state.debug.simulate_running(self, risk_factor)
    -- remember current state
    local _seed = player.seed
    local _day = player.day
    local _sound = options.sound
    local _vibe = options.vibrate
    -- turn off sound, vibes
    options.sound = false
    options.vibrate = false
    -- reseed
    player.seed = os.time()
    market:initialize_predictions()
    -- run simulation
    local _wins, _losses = 0, 0
    for n = 1, #market.predictions do
        player.health = 100
        player.day = n
        state.thugs:switch(risk_factor)
        local _attempts = 0
        while player.health > 0 and not state.thugs.escaped do
            state.thugs:attempt_run()
        end
        if player.health < 1 then
            _losses = _losses + 1
        else
            _wins = _wins + 1
        end
    end
    -- restore state
    options.sound = _sound
    options.vibrate = _vibe
    player.day = _day
    player.seed = _seed
    player.health = 100
    player.thug_encounter = false
    active_state = state.debug
    -- report
    local _winrate = math.floor((_wins / #market.predictions) * 100)
    local _report = string.format("wins: %d (%d%%) losses: %d", _wins, _winrate, _losses)
    print("Simulation report - ".._report)
    self:show_message(_report)
end

function state.debug.switch(self)

    self.previous_state = active_state
    active_state = self

end

function state.debug.update(self, dt)

end

--   __ _  __ _ _ __ ___   ___    _____   _____ _ __
--  / _` |/ _` | '_ ` _ \ / _ \  / _ \ \ / / _ \ '__|
-- | (_| | (_| | | | | | |  __/ | (_) \ V /  __/ |
--  \__, |\__,_|_| |_| |_|\___|  \___/ \_/ \___|_|
--  |___/
--
function state.game_over.draw(self)

    love.graphics.setColor(PRIMARY_100)

    -- title
    fonts:set_large()
    love.graphics.printf(self.score_amount, layout:align_point_at("title",nil,"right"))
    love.graphics.rectangle("line", layout:box_at("title"))

    -- message
    love.graphics.printf(self.message, layout:align_point_at("prompt", nil, "center"))

    -- name
    if self.enter_name then
        love.graphics.print("Your name: "..self.name, layout:point_at("answer 1"))
    end

    self.buttons:draw()
end

function state.game_over.exit_state(self)
    local ranked = nil
    if self.enter_name then
        -- prevent exit without a name
        if self.uft8.len(self.name) == 0 then
            return
        end
        ranked = high_scores:add(self.name, self.score, self.rip)
    end
    -- remove the save game
    state.play:remove_save()
    -- show high scores, highlighting current entry
    state.scores:switch(ranked, self.score)
end

function state.game_over.hide_mobile_keyboard(self)
    love.keyboard.setTextInput(false)
end

function state.game_over.keypressed(self, key)

    self.buttons:keypressed(key)

    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = self.uft8.offset(self.name, -1)
        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            self.name = string.sub(self.name, 1, byteoffset - 1)
        end
    elseif key == "return" then
        if display.mobile then
            self:hide_mobile_keyboard()
        end
        self:exit_state()
    elseif key == "escape" then
        if not self.buttons:get("close button 2").hidden then
            self:exit_state()
        end
    end

end

function state.game_over.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function state.game_over.load(self)

    self.uft8 = require("utf8")
    self.buttons = layout:button_collection("close button 1", "close button 2")

    self.buttons:set_values{
        name = "close button 2",
        font = fonts.large,
        context = self,
        callback = self.exit_state
    }

    self.buttons:set_values{
        name = "close button 1",
        font = fonts.large,
        context = self,
        callback = self.show_mobile_keyboard,
        text = "Keyboard"
    }

end

function state.game_over.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.game_over.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function state.game_over.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function state.game_over.show_mobile_keyboard(self)
    love.keyboard.setTextInput(true)
end

function state.game_over.switch(self, rip)

    -- flag game no longer in progress
    player.in_progress = false

    -- calculate score
    self.score = player.bank + player.cash - player.debt
    self.score_amount = util.comma_value(self.score)

    local placement_outcome = "Sadly, you did not make it as a hustler."

    if high_scores:is_accepted(self.score) then
        sound:play("applause")
        placement_outcome = "Well done, you are a hustler!"
        self.enter_name = true
        self.buttons:set_values{ name = "close button 2", text = "Record My Name" }
        self.buttons:set_values{ name = "close button 1", hidden = not display.mobile }
    else
        self.enter_name = false
        self.buttons:set_values{ name = "close button 2", text = "View Hustlers" }
        self.buttons:set_values{ name = "close button 1", hidden = true }
    end

    -- set end game message
    self.rip = rip or false
    if rip then
        self.message = "You died!\n" .. placement_outcome
    else
        self.message = "You survived!\n" .. placement_outcome
    end

    self.name = ""
    active_state = self

end

function state.game_over.textinput(self, t)
    if self.uft8.len(self.name) < 20 then
        self.name = self.name .. t
    end
end

function state.game_over.update(self, dt)

end

--  _           _                      _ _
-- (_)_ __   __| | ___ _ __ ___  _ __ (_) |_ _   _
-- | | '_ \ / _` |/ _ \ '_ ` _ \| '_ \| | __| | | |
-- | | | | | (_| |  __/ | | | | | | | | | |_| |_| |
-- |_|_| |_|\__,_|\___|_| |_| |_|_| |_|_|\__|\__, |
--                                           |___/
function state.indemnity.draw(self)
    self.buttons:draw()
    self.labels:draw()
end

function state.indemnity.exit_state()
    options.acknowledged_indemnity = true
    options:save()
    state.menu:switch()
end

function state.indemnity.keypressed(self, key)
    self.buttons:keypressed(key)
end

function state.indemnity.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function state.indemnity.load(self)

    local serious_text = string.format("%s is a game. "
        .. "It is not intended to trivialize or glamorize the drug trade, "
        .. "and it certainly does not endorse consuming drugs "
        .. "or getting high. "
        .. "\n\n"
        .. "Whether you like to experiment in a simulated free trade market, "
        .. "or play to become the highest hustler, "
        .. "I hope you have fun either way!", TITLE)

    self.buttons = layout:button_collection("close button 2")

    self.buttons:set_values{
        name = "close button 2",
        text = "Acknowledged",
        font = fonts:for_menu_button(),
        callback = self.exit_state
    }

    self.labels = layout:label_collection("prompt", "title")

    self.labels:set_values{
        name = "title",
        font = fonts:for_title(),
        text = "Indemnity"
    }

    self.labels:set_values{
        name = "prompt",
        font = fonts:for_tutorial(),
        valign = "top",
        border = false,
        text = serious_text
    }

end

function state.indemnity.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.indemnity.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function state.indemnity.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function state.indemnity.switch(self)
    if not options.acknowledged_indemnity then
        active_state = self
    end
end

function state.indemnity.update(self, dt)

end


--    _      _
--   (_) ___| |_
--   | |/ _ \ __|
--   | |  __/ |_
--  _/ |\___|\__|
-- |__/
--
function state.jet.draw(self)
    self.labels:draw()
    self.buttons:draw()
    love.graphics.setColor(PRIMARY_100)
    love.graphics.draw(self.subway_image,
        self.image_x, self.subway_y,
        0, self.image_scale, self.image_scale)
end

function state.jet.go(location)
    state.jet:show_buttons(false)
    state.jet.labels:set_values{
        name = "jet title",
        text = "Subway to " .. location
    }
    sound:play("train")
    state.jet.destination = location
    state.jet.animate = true
end

function state.jet.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        state.play:switch()
    end
end

function state.jet.keyreleased(self, key)
    self.buttons:keyreleased(key)
end

function state.jet.load(self)

    self.labels = layout:label_collection("jet title")

    self.labels:set_values{
        name = "jet title",
        font = fonts:for_jet_button()
    }

    self.buttons = layout:button_collection(
        "jet cancel", "loc 1", "loc 2", "loc 3", "loc 4", "loc 5", "loc 6")

    self.buttons:set_values{
        name = "jet cancel",
        text = "I changed my mind",
        font = fonts:for_jet_button(),
        context = state.play,
        callback = state.play.switch
    }

    for i, title in ipairs(LOCATIONS) do
        self.buttons:set_values{
            name = string.format("loc %d", i),
            text = title,
            font = fonts:for_jet_button(),
            context = title,
            callback = state.jet.go
        }
    end

    -- scale the subway image
    self.image_scale = 3
    -- preserve crisp pixels on scale
    self.subway_image = love.graphics.newImage("res/subway.png")
    self.subway_image:setFilter("nearest", "nearest", 1)
    -- position of subway image
    _, self.subway_y = layout:point_at("subway train")
    -- speed of animation - % of display width per second
    self.animate_speed = display.safe_w * 1
    -- exit screen after image is off-screen
    self.exit_position = self.subway_image:getWidth() * self.image_scale * -1

end

function state.jet.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.jet.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function state.jet.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function state.jet.show_buttons(self, visible)
    for _, butt in pairs(self.buttons.controls) do
        butt.hidden = not visible
    end
end

function state.jet.switch(self)

    -- game ends when reached end of days
    if player.day == #market.predictions then
        state.game_over:switch(false)
        return
    end

    -- disable current location's button
    for _, butt in pairs(self.buttons.controls) do
        butt.disabled = butt.text == player.location
    end

    -- reset title, show buttons
    self:show_buttons(true)
    self.labels:set_values{
        name = "jet title",
        text = "Where to?"
    }

    active_state = self
    self.image_x = display.safe_w + 40
    self.animate = false
end

function state.jet.update(self, dt)
    self.buttons:update(dt)
    if self.animate then
        display:request_fast_fps()
        self.image_x = math.floor(self.image_x - dt * self.animate_speed)
        if self.image_x < self.exit_position then
            self.animate = false
            state.play:next_day(self.destination)
        end
    end
end

--  _                         _                _
-- | | ___   __ _ _ __    ___| |__   __ _ _ __| | __
-- | |/ _ \ / _` | '_ \  / __| '_ \ / _` | '__| |/ /
-- | | (_) | (_| | | | | \__ \ | | | (_| | |  |   <
-- |_|\___/ \__,_|_| |_| |___/_| |_|\__,_|_|  |_|\_\
--
function state.loanshark.draw(self)
    self.buttons:draw()
    love.graphics.setColor(PRIMARY_100)
    love.graphics.print("Debt", layout:padded_point_at("title"))
    love.graphics.printf(self.debt_amount, layout:align_point_at("title",nil,"right"))
    love.graphics.rectangle("line", layout:box_at("title"))
    love.graphics.printf(self.message, layout:align_point_at("prompt", nil, "center"))
end

function state.loanshark.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        state.play:switch()
    end
end

function state.loanshark.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function state.loanshark.load(self)

    self.buttons = layout:button_collection("close button 1", "close button 2")

    self.buttons:set_values{
        name = "close button 2",
        text = "I'm outta here",
        font = fonts:for_menu_button(),
        context = state.play,
        callback = state.play.switch
    }

    self.buttons:set_values{
        name = "close button 1",
        text = "Pay",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.pay_debt
    }

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

function state.loanshark.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.loanshark.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function state.loanshark.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function state.loanshark.pay_debt(self)
    player:debit_account(self.slider.value)
    player:pay_debt(self.slider.value)
    sound:play("purchase")
    state.play:switch()
end

function state.loanshark.switch(self)

    -- load prediction
    math.randomseed(market.predictions[player.day])

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

function state.loanshark.update(self, dt)

end

--  _ __ ___   ___ _ __  _   _
-- | '_ ` _ \ / _ \ '_ \| | | |
-- | | | | | |  __/ | | | |_| |
-- |_| |_| |_|\___|_| |_|\__,_|
--
function state.menu.draw(self)
    love.graphics.setColor(PRIMARY_100)
    love.graphics.draw(self.image, 0, self.image_top, 0, self.image_ratio, self.image_ratio)
    self.buttons:draw()
end

function state.menu.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function state.menu.keyreleased(self, key)
    self.buttons:keyreleased(key)
end

function state.menu.load(self)

    -- title image
    -- linear scaling interpolation, fit to display width.
    self.image = love.graphics.newImage("res/title.png")
    self.image:setFilter("nearest", "nearest", 1)
    self.image_ratio = display.safe_w / self.image:getWidth()
    _, self.image_top = layout:point_at("menu logo")

    self.buttons = layout:button_collection(
        "menu new game", "menu resume game", "menu high scores",
        "menu options", "menu about", "menu debug")

    self.buttons:set_values{
        name = "menu new game",
        text = "New Game",
        options = options,
        font = fonts:for_menu_button(),
        context = self,
        callback = self.new_game
    }

    self.buttons:set_values{
        name = "menu resume game",
        text = "Resume Game",
        options = options,
        font = fonts:for_menu_button(),
        context = self,
        callback = self.resume_game,
        disabled = true
    }

    self.buttons:set_values{
        name = "menu high scores",
        text = "Hustlers",
        options = options,
        font = fonts:for_menu_button(),
        context = state.scores,
        callback = state.scores.switch
    }

    self.buttons:set_values{
        name = "menu options",
        text = "Options",
        options = options,
        font = fonts:for_menu_button(),
        context = state.options,
        callback = state.options.switch,
    }

    self.buttons:set_values{
        name = "menu about",
        text = "About",
        options = options,
        font = fonts:for_menu_button(),
        context = state.about,
        callback = state.about.switch
    }

    if DEBUG then
        self.buttons:set_values{
            name = "menu debug",
            text = "Debug",
            options = options,
            font = fonts:for_menu_button(),
            context = state.debug,
            callback = state.debug.switch
        }
    else
        self.buttons:set_values{
            name = "menu debug",
            hidden = true
        }
    end

end

function state.menu.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.menu.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function state.menu.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function state.menu.new_game(self)
    -- abort running tutorial.
    if state.tutorial.running then
        state.tutorial.running = false
    end
    state.play:new_game()
    state.play:switch()
end

function state.menu.resume_game(self)
    -- load from disk if no day, otherwise resumes game in-progress
    if not player.in_progress then
        player:reset()
        state.messages:clear()
        state.play:restore_game()
    end
    state.play:switch()
end

function state.menu.switch(self)

    -- Enable resume game button
    local savegame_exists = love.filesystem.getInfo("savegame", "file") ~= nil
    self.buttons:get("menu resume game").disabled = not (savegame_exists or player.in_progress)

    -- Enable debug button
    if DEBUG then
        self.buttons:get("menu debug").disabled = not player.in_progress
    end

    active_state = self
end

function state.menu.update(self, dt)
    self.buttons:update(dt)
end


--  _ __ ___   ___  ___ ___  __ _  __ _  ___  ___
-- | '_ ` _ \ / _ \/ __/ __|/ _` |/ _` |/ _ \/ __|
-- | | | | | |  __/\__ \__ \ (_| | (_| |  __/\__ \
-- |_| |_| |_|\___||___/___/\__,_|\__, |\___||___/
--                                |___/
--
function state.messages.add(self, text, color, ...)
    local msg = string.format(text, ...)
    table.insert(self.messages, color)
    table.insert(self.messages, msg.."\n\n")
    print("Message: "..msg)
end

function state.messages.clear(self)
    self.messages = {}
    self.has_displayed = false
    self.y = self.rest_y
end

function state.messages.draw(self)
    -- fill
    love.graphics.setColor(PRIMARY_30)
    love.graphics.rectangle("fill", 0, self.y, display.safe_w, display.safe_h)
    -- shadowed border
    love.graphics.setColor(PRIMARY_70)
    love.graphics.line(display.safe_x, self.y, display.safe_w, self.y)
    love.graphics.setColor(PRIMARY_10)
    love.graphics.line(display.safe_x, self.y+1, display.safe_w, self.y+1)
    -- message indicator
    if #self.messages == 0 then
        love.graphics.setColor(PRIMARY_70)
    else
        love.graphics.setColor(PRIMARY_100)
    end
    love.graphics.draw(self.icon, self.led_x, self.y - self.icon_offset)
    --  embossed leaf
    love.graphics.setColor(PRIMARY_25)
    love.graphics.draw(self.icon,
        self.embossed_x, self.y + self.embossed_y,
        0, self.embossed_s, self.embossed_s)
    -- print messages
    if self.y ~= self.rest_y then
        if #self.messages > 0 then
            love.graphics.setColor(WHITE)
            love.graphics.printf(self.messages, fonts.medium, 4, self.y + self.text_y, display.safe_w - 10, "center")
        else
            love.graphics.setColor(ZERO_INFO)
            love.graphics.printf("no messages", fonts.medium, 4, self.y + self.text_y, display.safe_w - 10, "center")
        end
    end
end

function state.messages.hide(self)
    self.y = self.rest_y
    self:unlock()
end

function state.messages.is_dragging(self)
    return self.dragging
end

function state.messages.is_hidden(self)
    return self.y == self.rest_y
end

function state.messages.is_locked(self)
    return self.locked
end

function state.messages.keypressed(self, key)
    if key == "escape" then
        if state.messages:is_locked() then
            state.messages:unlock()
        end
    elseif key == "return" then
        if state.messages:is_locked() then
            state.messages:unlock()
        end
    elseif key == "space" then
        if state.messages:is_locked() then
            state.messages:unlock()
        else
            state.messages:show_and_lock(true)
        end
    end
end

function state.messages.load(self)

    -- indicator icon
    self.icon = love.graphics.newImage("res/leaf.png")
    self.icon_offset = math.floor(self.icon:getWidth() / 2)

    -- embossed leaf scale, position
    self.icon:setFilter("nearest", "nearest")
    self.embossed_s = 10
    self.embossed_x = math.floor((display.safe_w / 2)
                                - (self.icon:getWidth() * self.embossed_s / 2))
    self.embossed_y = math.floor(display.safe_h
                                - (self.icon:getHeight() * self.embossed_s))

    -- message box layout
    _, self.rest_y = layout:point_at("messages")

    -- dont drag messages above this point
    local _, cash_y, _, cash_h = layout:box_at("cash")
    self.min_y = cash_y + cash_h

    -- panel position
    self.y = self.rest_y

    -- text position
    self.text_y = display.height - self.y

    -- indicator position
    self.led_radius = 10
    self.led_x = (display.safe_w / 2) - self.icon_offset

end

function state.messages.mousemoved(self, x, y, dx, dy, istouch)
    if self.dragging then
        self.y = math.max(self.min_y, math.min(self.rest_y, y))
    end
end

function state.messages.mousepressed(self, x, y, button, istouch)
    -- begin dragging the panel
    if not self.dragging and y > self.y then
        self.dragging = y
    end
end

function state.messages.mousereleased(self, x, y, button, istouch)
    -- unlock when shown
    if self:is_locked() then
        self:unlock()
    elseif y > self.rest_y then
        -- Show and lock when released below the resting position
        self:show_and_lock(true)
    end
    -- Stop dragging
    if self.dragging then
        self.dragging = nil
    end
end

function state.messages.show_and_lock(self, always)
    if (always or not self.has_displayed) and (#self.messages > 0) then
        self.y = self.min_y
        self.locked = true
        self.has_displayed = true
    end
end

function state.messages.unlock(self)
    self.locked = false
end

function state.messages.update(self, dt)
    if not self.locked and not self.dragging and self.y < self.rest_y then
        self.y = math.min(self.rest_y, self.y + (display.safe_h * dt * 1.5))
        display:request_fast_fps()
    end
    if self.dragging then
        display:request_fast_fps()
    end
end

--              _   _
--   ___  _ __ | |_(_) ___  _ __  ___
--  / _ \| '_ \| __| |/ _ \| '_ \/ __|
-- | (_) | |_) | |_| | (_) | | | \__ \
--  \___/| .__/ \__|_|\___/|_| |_|___/
--       |_|
--
function state.options.draw(self)

    self.labels:draw()
    self.buttons:draw()

    fonts:set_small()
    love.graphics.setColor(WHITE)
    love.graphics.print(love.timer.getFPS().." FPS", layout:padded_point_at("option 3 title"))

end

function state.options.exit_state(self)
    options:save()
    state.menu:switch()
end

function state.options.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        self:exit_state()
    end
end

function state.options.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function state.options.load(self)

    self.labels = layout:label_collection(
        "option heading", "option 1 title", "option 2 title", "option 3 title",
        "option 4 title", "option 4 text",
        "option 1 text", "option 2 text", "option 3 text")

    self.buttons = layout:button_collection(
        "option 1 btn", "option 2 btn", "option 3 btn", "option 4 btn", "option close")

    -- title
    self.labels:set_values{
        name = "option heading",
        font = fonts:for_title(),
        text = "Game Options"
    }

    -- close button
    self.buttons:set_values{
        name = "option close",
        font = fonts:for_title(),
        text = "Done",
        context = self,
        callback = self.exit_state
    }

    -- Vibration
    self.labels:set_values{
        name = "option 1 title",
        font = fonts:for_option_title(),
        text = "Vibes"
    }
    self.labels:set_values{
        name = "option 1 text",
        font = fonts:for_option_text(),
        text = "Vibrates your phone on game events",
        valign = "top"
    }
    self.buttons:set_values{
        name = "option 1 btn",
        setting = "vibrate",
        font = fonts:for_title(),
        text = options.vibrate and "On" or "Off",
        callback = self.set_option
    }

    -- Sounds
    self.labels:set_values{
        name = "option 2 title",
        font = fonts:for_option_title(),
        text = "Sounds"
    }
    self.labels:set_values{
        name = "option 2 text",
        font = fonts:for_option_text(),
        text = "Play sounds on game events",
        valign = "top"
    }
    self.buttons:set_values{
        name = "option 2 btn",
        setting = "sound",
        font = fonts:for_title(),
        text = options.sound and "On" or "Off",
        callback = self.set_option,
        disabled = false
    }

    -- Frame rate limiter
    self.labels:set_values{
        name = "option 3 title",
        font = fonts:for_option_title(),
        text = "Battery"
    }
    self.labels:set_values{
        name = "option 3 text",
        font = fonts:for_option_text(),
        text = "Enables adaptive performance, saving battery on mobile devices",
        valign = "top"
    }
    self.buttons:set_values{
        name = "option 3 btn",
        setting = "adaptive_fps",
        font = fonts:for_title(),
        text = options.adaptive_fps and "On" or "Off",
        callback = self.set_option,
        disabled = false
    }

    -- Tutorial
    self.labels:set_values{
        name = "option 4 title",
        font = fonts:for_option_title(),
        text = "Tutorial"
    }
    self.labels:set_values{
        name = "option 4 text",
        font = fonts:for_option_text(),
        text = "Plays a quick-start tutorial on the next new game",
        valign = "top"
    }
    self.buttons:set_values{
        name = "option 4 btn",
        setting = "tutorial",
        font = fonts:for_title(),
        text = options.tutorial and "On" or "Off",
        callback = self.set_option,
        disabled = false
    }


end

function state.options.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.options.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function state.options.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function state.options.set_option(btn)
    btn.text = (btn.text == "On") and "Off" or "On"
    options[btn.setting] = btn.text == "On"
    if btn.setting == "adaptive_fps" then
        display:set_adaptive(options.adaptive_fps)
    end
    if btn.setting == "sound" then
        sound:play("sale")
    end
    print(string.format("Toggled %s %s", btn.setting, tostring(options[btn.setting])))
end

function state.options.switch(self)

    active_state = self

    -- refresh tutorial option (it may have changed by the tutorial itself)
    self.buttons:set_values{
        name = "option 4 btn",
        text = options.tutorial and "On" or "Off"
    }

end

function state.options.update(self, dt)

end

--        _
--  _ __ | | __ _ _   _
-- | '_ \| |/ _` | | | |
-- | |_) | | (_| | |_| |
-- | .__/|_|\__,_|\__, |
-- |_|            |___/
--
function state.play.draw(self)

    self.labels:draw()
    self.buttons:draw()
    state.messages:draw()

end

function state.play.keypressed(self, key)
    if DEBUG then
        if key == "f1" then
            state.debug:switch()
        end
    end
    if key == "escape" then
        if not state.messages:is_locked() then
            state.menu:switch()
        end
    end
    state.messages:keypressed(key)
    -- stop processing further when dragging or locked message panel
    if (state.messages:is_dragging() or state.messages:is_locked()) then
        return
    end
    self.buttons:keypressed(key)
end

function state.play.keyreleased(self, key)
    self.buttons:keyreleased(key)
end

function state.play.load(self)

    -- Labels
    self.labels = layout:label_collection(
        "cash", "bank", "debt", "guns", "coat", "health", "day")

    self.labels:set_values{
        name = "cash",
        font = fonts:for_player_stats(),
        title = "Cash",
        text = "0",
        alignment = "right"
    }

    self.labels:set_values{
        name = "bank",
        font = fonts:for_player_stats(),
        title = "Bank",
        text = "0",
        alignment = "right"
    }

    self.labels:set_values{
        name = "debt",
        font = fonts:for_player_stats(),
        title = "Debt",
        text = "0",
        alignment = "right"
    }

    self.labels:set_values{
        name = "guns",
        font = fonts:for_player_stats(),
        title = "Guns",
        text = "0",
        alignment = "right"
    }

    self.labels:set_values{
        name = "coat",
        font = fonts:for_player_stats(),
        title = "Coat",
        text = "0",
        alignment = "right"
    }

    self.labels:set_values{
        name = "health",
        font = fonts:for_player_stats(),
        title = "Health",
        text = "0",
        alignment = "right"
    }

    self.labels:set_values{
        name = "day",
        font = fonts:for_player_stats(),
        title = "Day",
        text = "0",
        alignment = "right"
    }

    -- Buttons
    self.buttons = layout:button_collection("jet", "debt", "bank")

    self.buttons:set_values{
        name = "jet",
        text = "Jet",
        alignment = "right",
        font = fonts:for_jet_button(),
        context = state.jet,
        callback = state.jet.switch
    }

    self.buttons:set_values{
        name = "debt",
        title = "Debt",
        text = "0",
        alignment = "right",
        font = fonts:for_player_stats(),
        context = state.loanshark,
        callback = state.loanshark.switch
    }

    self.buttons:set_values{
        name = "bank",
        title = "Bank",
        text = "0",
        alignment = "right",
        font = fonts:for_player_stats(),
        context = state.bank,
        callback = state.bank.switch
    }

    -- Create market name labels, buy & sell buttons
    for i=1, #market.db do
        local label_id = string.format("name %d", i)
        local sell_id = string.format("sell %d", i)
        local buy_id = string.format("buy %d", i)
        local _x, _y, _w, _h = layout:box_at("name %d", i)
        self.labels:label(label_id, {
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
            font = fonts:for_market_button(),
            options = options
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
            font = fonts:for_market_button(),
            options = options
        })
    end

end

function state.play.mousemoved(self, x, y, dx, dy, istouch)
    state.messages:mousemoved(x, y, dx, dy, istouch)
    -- stop processing further when dragging or locked message panel
    if (state.messages:is_dragging() or state.messages:is_locked()) then
        return
    end
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.play.mousepressed(self, x, y, button, istouch)
    state.messages:mousepressed(x, y, button, istouch)
    -- stop processing further when dragging or locked message panel
    if (state.messages:is_dragging() or state.messages:is_locked()) then
        return
    end
    self.buttons:mousepressed(x, y, button, istouch)
end

function state.play.mousereleased(self, x, y, button, istouch)
    state.messages:mousereleased(x, y, button, istouch)
    -- stop processing further when dragging or locked message panel
    if (state.messages:is_dragging() or state.messages:is_locked()) then
        return
    end
    self.buttons:mousereleased(x, y, button, istouch)
end

function state.play.new_game(self)
    print("Starting a new game ...")
    player:reset()
    market:initialize_predictions()
    market:fluctuate(state.tutorial.running)
    player:generate_events()
end

function state.play.next_day(self, new_location)
    if player:add_day(new_location) <= #market.predictions then
        state.messages:clear()
        player:accrue_debt()
        -- open all merchandise for trading on the last day or in tutorial mode
        local list_everything = player.day == #market.predictions
            or state.tutorial.running
        market:fluctuate(list_everything)
        self:save_game()
        player:generate_events()
        state.play:switch()
    else
        state.game_over:switch(false)
    end
end

function state.play.remove_save(self)
    love.filesystem.remove("savegame")
end

function state.play.restore_game(self)

    print("Restoring a saved game ...")

    for line in util.read_file("savegame") do

        -- read record
        local record = {}
        for key, value in util.key_value_pairs(line, true) do
            record[key] = value
        end

        -- Put on the correct trench coat
        trenchcoat:reset(record.coat)

        for key, value in pairs(record) do

            -- apply player values
            if player[key] ~= nil then
                player[key] = value
            end

            -- apply trench coat values
            for _, item in ipairs(market.db) do
                if key == item.name then
                    trenchcoat:adjust_stock(key, value)
                end
            end

        end

        -- format player cash, bank, debt amounts
        player:set_cash()
        player:set_bank()
        player:set_debt()

        -- recreate the market from player.seed, fluctuate the market
        market:initialize_predictions()
        market:fluctuate(player.day == #market.predictions)

        -- regenerate predicted events
        player:generate_events()

        -- sanity check
        local check = util.crc(record)
        if check ~= record.crc then
            print("CRC fail")
            player:set_debt(player.debt + player.cash + player.bank)
            state.messages:add("The loan shark caught wind that you are trying "
                .. "to stiff him. He just raised your debt.", BAD_INFO)
        end

    end

end

function state.play.save_game(self)

    -- skip during tutorial
    if state.tutorial.running then
        return
    end

    -- build save state
    local savestate = {
        seed = player.seed,
        cash = player.cash,
        bank = player.bank,
        debt = player.debt,
        guns = player.guns,
        health = player.health,
        coat = trenchcoat.size,
        day = player.day,
        location = player.location
    }

    -- include stock
    for _, item in ipairs(market.db) do
        savestate[item.name] = trenchcoat:stock_of(item.name)
    end

    util.write_file("savegame", {savestate})

end

function state.play.switch(self)

    active_state = self

    -- update label values when entering this state.
    -- (these dont change while on the play state)
    self.labels:get("bank").text = player.bank_amount
    self.labels:get("debt").text = player.debt_amount
    self.labels:get("guns").text = player.guns
    self.labels:get("health").text = string.format("%d %%", player.health)
    self.labels:get("day").text = player.day

    -- show debt button if player has debt, hide if not in home location
    local debt_button = self.buttons:get("debt")
    debt_button.text = player.debt_amount
    debt_button.hidden = (player.debt == 0) or (player.location ~= LOCATIONS[1])

    -- show bank button if player is in home location
    local bank_button = self.buttons:get("bank")
    bank_button.text = player.bank_amount
    bank_button.hidden = (player.location ~= LOCATIONS[1])

    state.messages:show_and_lock()

    -- update market button prices, stock levels
    state.play:update_button_texts()

    -- animate player cash value
    if not self.cash_counter then
        local dr = require("harness.digitroller")
        self.cash_counter = dr:new({
            duration = 0.5,
            subject = player,
            target = "cash"
        })
    end

    -- Enable tutorial mode
    state.tutorial:watch()

end

function state.play.update(self, dt)

    if #player.purchase > 0 then
        state.shop:switch(table.remove(player.purchase, 1))
        return
    end

    if player.thug_encounter then
        state.thugs:switch(player.thug_encounter)
        player.thug_encounter = false
        return
    end

    -- Update player stats labels
    self.cash_counter:update(dt)
    if not self.cash_counter.complete then
        display:request_fast_fps()
        self.labels:get("cash").text = util.comma_value(math.floor(self.cash_counter.value))
    end
    self.labels:get("coat").text = trenchcoat:free_space()

    self.buttons:update(dt)
    state.messages:update(dt)

end

function state.play.update_button_texts(self)

    local not_for_sale = {}

    for i=1, #market.db do

        local label_id = string.format("name %d", i)
        local sell_id = string.format("sell %d", i)
        local buy_id = string.format("buy %d", i)
        local market_item = market.available[i]
        local sell_btn = self.buttons:get(sell_id)
        local buy_btn = self.buttons:get(buy_id)
        local label = self.labels:get(label_id)

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
    if player.day == #market.predictions then
        self.buttons:get("jet").text = "End Game"
    else
        self.buttons:get("jet").text = player.location
    end

    -- list stock not on the market
    local label_id = #market.available
    for _, item in ipairs(not_for_sale) do
        label_id = label_id + 1
        local label = self.labels:get(string.format("name %d", label_id))
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

--  ___  ___ ___  _ __ ___  ___
-- / __|/ __/ _ \| '__/ _ \/ __|
-- \__ \ (_| (_) | | |  __/\__ \
-- |___/\___\___/|_|  \___||___/
--
function state.scores.draw(self)

    love.graphics.setColor(PRIMARY_100)
    fonts:set_large()
    love.graphics.printf("High Hustlers", layout:align_point_at("title", nil, "center"))
    love.graphics.rectangle("line", layout:box_at("title"))

    love.graphics.setFont(fonts:for_score_listing())

    for rank = 1, self.display_rank do

        local entry = self.listing[rank]
        local y = self.listing_y + self.font_height * rank * 2

        if rank == self.highlight_rank then
            -- Highlight this entry
            love.graphics.setColor(PRIMARY_100)
            love.graphics.rectangle("fill", 0, y, display.safe_w, self.font_height * 2)
            love.graphics.setColor(0, 0, 0)
        else
            love.graphics.setColor(PRIMARY_100)
        end

        -- line delimiter
        love.graphics.line(0, y, display.safe_w, y)

        -- rank, name
        love.graphics.print(string.format("%d   %s", rank, entry.name),
            self.name_x, y)

        -- score
        love.graphics.printf(entry.score, self.score_x, y + self.half_height,
            self.score_width, "right")

        -- date
        love.graphics.print(entry.date, self.date_x, y + self.font_height)

        -- RIP
        if entry.rip then
            love.graphics.print("RIP", self.rip_x, y + self.font_height)
        end

    end

    -- show most recent game score
    if self.game_score then
        love.graphics.printf(
            string.format("Your Net Profit: %s", self.game_score),
            display.safe_x,
            display.safe_h - self.font_height,
            display.safe_w,
            "center")
    end

end

function state.scores.keypressed(self, key)
    if key == "escape" then
        state.menu:switch()
    end
end

function state.scores.keyreleased(self, key, scancode)

end

function state.scores.load(self)
    self.font_width, self.font_height = fonts:measure(fonts:for_score_listing())
    self.half_height = math.floor(self.font_height / 2)
    -- start listing below the title
    _, self.listing_y = layout:point_at("title")
    -- pad listing pos by font height
    self.listing_y = self.listing_y + self.font_height
    -- position rank, name, date and RIP status
    self.rank_x = 6
    self.name_x = 6
    self.date_x = math.floor(self.font_width * 3)
    self.rip_x = self.font_width * 14 --math.floor(display.safe_x + display.safe_w / 2)
    -- score prints at 50% display width (but is right aligned)
    self.score_x = math.floor(display.safe_w * 0.5)
    -- width of alignment is remainder of display width, less some padding
    self.score_width = display.safe_w - self.score_x - self.font_width * 2
end

function state.scores.mousemoved(self, x, y, dx, dy, istouch)

end

function state.scores.mousepressed(self, x, y, button, istouch)
    -- prevent exiting until scores are listed
    if self.display_rank == #self.listing then
        state.menu:switch()
    end
end

function state.scores.mousereleased(self, x, y, button, istouch)

end

function state.scores.switch(self, highlight_rank, game_score)

    -- highlight the score at this rank
    self.highlight_rank = highlight_rank

    -- print the completed game score (regardless if making it as a high hustler)
    if game_score then
        self.game_score = util.comma_value(game_score)
    end

    -- print each rank via a timer
    self.display_rank = 0
    self.timer = 0.5

    -- get the scores listing
    self.listing = high_scores:listing()
    active_state = self
end

function state.scores.update(self, dt)
    self.timer = self.timer - dt
    if self.timer <= 0 then
        self.timer = 0.25
        self.display_rank = math.min(self.display_rank + 1, #self.listing)
    end
end

--      _
--  ___| |__   ___  _ __
-- / __| '_ \ / _ \| '_ \
-- \__ \ | | | (_) | |_) |
-- |___/_| |_|\___/| .__/
--                 |_|
--
function state.shop.draw(self)
    fonts:set_large()
    love.graphics.setColor(PRIMARY_100)
    love.graphics.print(self.title, layout:padded_point_at("title"))
    love.graphics.rectangle("line", layout:box_at("title"))
    love.graphics.setFont(fonts:for_shop_question())
    love.graphics.printf(self.message, layout:align_point_at("prompt", nil, "center"))
    self.buttons:draw()
end

function state.shop.early_death(self)
    state.game_over:switch(true)
end

function state.shop.enable_answer_buttons(self, visible)
    self.buttons:get("answer 1").disabled = not visible
    self.buttons:get("answer 2").disabled = not visible
end

function state.shop.keypressed(self, key)
    if key == "escape" then
        if not self.buttons:get("answer 2").disabled then
            state.play:switch()
        end
    end
    self.buttons:keypressed(key)
end

function state.shop.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function state.shop.load(self)

    self.buttons = layout:button_collection(
        "answer 1", "answer 2", "close button 1")

    self.buttons:set_values{
        name = "answer 1",
        text = "Yes",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.purchase
    }

    self.buttons:set_values{
        name = "answer 2",
        text = "No",
        font = fonts:for_menu_button(),
        context = state.play,
        callback = state.play.switch
    }

    self.buttons:set_values{
        name = "close button 1",
        text = "Farewell",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.early_death
    }

end

function state.shop.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.shop.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function state.shop.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function state.shop.purchase(self)
    if self.what == "gun" then
        player:debit_account(self.cost)
        player:add_gun()
        trenchcoat:adjust_pockets(-self.space_used)
        state.messages:add("You purchased a gun.", GOOD_INFO)
        sound:play("purchase")
        state.play:switch()
    elseif self.what == "trench coat" then
        player:debit_account(self.cost)
        trenchcoat:adjust_pockets(self.new_pockets)
        state.messages:add("You purchased a new trench coat.", GOOD_INFO)
        sound:play("purchase")
        state.play:switch()
    elseif self.what == "paraquat" then
        self:show_answer_buttons(false)
        self:show_farewell_button(true)
        self.message = "You hallucinated for three days on the wildest trip you ever imagined! Then you died because your brain disintegrated!"
    end
end

function state.shop.switch(self, what)

    -- load prediction
    math.randomseed(market.predictions[player.day])

    self.what = what
    self.disable_timeout = 1
    self.title = "Purchase"

    self:show_answer_buttons(true)
    self:enable_answer_buttons(false)
    self:show_farewell_button(false)

    if what == "gun" then

        self.cost = math.random(250, 850)
        self.space_used = math.random(4, 8)
        local name = util.pick(".38 Special", "Ruger", "Saturday Night Special")
        local fancy_cost = util.comma_value(self.cost)
        self.message = string.format("Would you like to buy a %s for %s?", name, fancy_cost)

        -- not enough free space for this purchase
        if trenchcoat:free_space() < self.space_used then
            self.cost = nil
            print("Not enough free coat space to buy a gun.")
        end

        -- have enough guns already
        if player.guns == 2 then
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

function state.shop.show_answer_buttons(self, visible)
    self.buttons:get("answer 1").hidden = not visible
    self.buttons:get("answer 2").hidden = not visible
end

function state.shop.show_farewell_button(self, visible)
    self.buttons:get("close button 1").hidden = not visible
end

function state.shop.update(self, dt)
    -- Disable the buttons briefly to prevent impulsive purchases
    if self.disable_timeout > 0 then
        self.disable_timeout = math.max(0, self.disable_timeout - dt)
        if self.disable_timeout == 0 then
            self:enable_answer_buttons(true)
        end
    end
    self.buttons:update(dt)
end

--  _   _
-- | |_| |__  _   _  __ _ ___
-- | __| '_ \| | | |/ _` / __|
-- | |_| | | | |_| | (_| \__ \
--  \__|_| |_|\__,_|\__, |___/
--                  |___/
--
function state.thugs.allow_exit(self)

    self:show_action_buttons(false)
    self:show_exit_buttons(false, true)

    -- Offer to visit the doctor, if all thugs are eliminated
    if self.thugs == 0 and player.health < 100 then
        -- player damage expressed as 0.1 .. 0.9
        local damage = 1 - (player.health / 100)
        -- function of maximum cost
        local base_fee = 6000 * damage
        -- admin fee
        local admin_fee = math.random() * 250
        self.doctors_fees = math.floor(base_fee + admin_fee)
        -- player can afford it
        if self.doctors_fees <= player.cash then
            self:show_exit_buttons(true, true)
            self.outcome = {ZERO_INFO, "Visit a clinic to patch you up for ",
                            BAD_INFO, util.comma_value(self.doctors_fees),
                            ZERO_INFO, "?"}
        else
            print(string.format(
                "You cannot afford %s doctors fees.",
                util.comma_value(self.doctors_fees)))
        end
    end
end

function state.thugs.attempt_fight(self)
    sound:play("gun")
    -- chance of hit is proportional to number of guns carried.
    local hit_chance = math.min(0.75, player.guns * 0.25)
    if math.random() < hit_chance then
        print(string.format("You hit one (hit chance %d%%)", hit_chance * 100))
        self.thugs = self.thugs - 1
        self:set_message()
        self.outcome = {ZERO_INFO, "You ",
                        GOOD_INFO, "hit",
                        ZERO_INFO, " one of them!\n"}
        util.append_tables(self.outcome, self:get_shot_at())
        if self.thugs == 0 then
            player:credit_account(self.cash_prize)
            self.outcome = {}
            self:allow_exit()
        end
    else
        print(string.format("You missed (hit chance %d%%)", hit_chance * 100))
        self.outcome = {ZERO_INFO, "You miss!\n"}
        util.append_tables(self.outcome, self:get_shot_at())
    end
    self:test_death()
end

function state.thugs.attempt_run(self)
    -- Escape chance is inversely proportional to the number of thugs.
    -- The minimum ensures there is always a chance to escape.
    -- Chance is nearest to maximum at one thug, decreasing n percent per thug.
    local min_chance = 0.05
    local max_chance = 0.5
    local percent_per_thug = 0.1
    local escape_chance = math.max(min_chance, max_chance - self.thugs * percent_per_thug)

    if math.random() < escape_chance then
        print(string.format("You escaped (chance %d%%)", escape_chance * 100))
        self:allow_exit()
        self.outcome = {GOOD_INFO, "You lost them in the alleys"}
        self.escaped = true
        sound:play("run")
    else
        print(string.format("Failed to escape (chance %d%%)", escape_chance * 100))
        self.outcome = {ZERO_INFO, "You can't lose them! "}
        util.append_tables(self.outcome, self:get_shot_at())
        self:test_death()
    end
end

function state.thugs.draw(self)

    fonts:set_large()
    love.graphics.setColor(PRIMARY_100)

    love.graphics.print("Health", layout:padded_point_at("title"))
    love.graphics.printf(string.format("%d %%", math.floor(self.health_counter.value)), layout:align_point_at("title",nil,"right"))
    love.graphics.rectangle("line", layout:box_at("title"))

    love.graphics.setColor(WHITE)
    love.graphics.printf(self.message, fonts.large,
        layout:align_point_at("prompt", nil, "center"))
    love.graphics.printf(self.outcome, fonts.large,
        layout:align_point_at("response", nil, "center"))

    self.buttons:draw()

end

function state.thugs.exit_state()
    if player.health < 1 then
        state.game_over:switch(true)
    else
        state.play:switch()
    end
end

function state.thugs.get_shot_at(self)
    if self.thugs == 0 then
        return {}
    end
    sound:play("gun", 2)
    -- chance is constant, as more thugs yield more attacks.
    local hit_chance = 0.4
    if math.random() < hit_chance then
        print(string.format("Thugs hit you (chance %d%%)", hit_chance * 100))
        player:lose_health(math.random(5, 15))
        vibrate:pattern(" ..-")
        sound:play("pain")
        return {ZERO_INFO, "They fire at you! You are ", BAD_INFO, "hit!"}
    else
        print(string.format("Thugs miss (chance %d%%)", hit_chance * 100))
        return {ZERO_INFO, "They fire at you, and miss!"}
    end
end

function state.thugs.keypressed(self, key)
    self.buttons:keypressed(key)
    if key == "escape" then
        if not self.buttons:get("close button 2").hidden then
            self:exit_state()
        end
    end
end

function state.thugs.keyreleased(self, key, scancode)
    self.buttons:keyreleased(key)
end

function state.thugs.load(self)

    self.buttons = layout:button_collection(
        "answer 1", "answer 2", "close button 1", "close button 2")

    self.buttons:set_values{
        name = "answer 1",
        text = "Run",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.attempt_run
    }

    self.buttons:set_values{
        name = "answer 2",
        text = "Fight",
        font = fonts:for_menu_button(),
        context = self,
        callback = self.attempt_fight
    }

    self.buttons:set_values{
        name = "close button 2",
        text = "I'm outta here",
        font = fonts:for_menu_button(),
        hidden = true,
        callback = self.exit_state
    }

    self.buttons:set_values{
        name = "close button 1",
        text = "Patch me up, doc!",
        font = fonts:for_menu_button(),
        hidden = true,
        context = self,
        callback = self.visit_doctor
    }

end

function state.thugs.mousemoved(self, x, y, dx, dy, istouch)
    self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.thugs.mousepressed(self, x, y, button, istouch)
    self.buttons:mousepressed(x, y, button, istouch)
end

function state.thugs.mousereleased(self, x, y, button, istouch)
    self.buttons:mousereleased(x, y, button, istouch)
end

function state.thugs.set_message(self)
    if self.thugs == 0 then
        self.message = {ZERO_INFO, "You fought them off!\nYou found ",
                        GOOD_INFO, util.comma_value(self.cash_prize),
                        ZERO_INFO, " on the body."}
    elseif self.thugs == 1 then
        self.message = {ZERO_INFO, "A ",
                        BAD_INFO, "gang leader",
                        ZERO_INFO, " is chasing you!"}
    elseif self.thugs == 2 then
        self.message = {ZERO_INFO, "A gang leader and ",
                        BAD_INFO, "one",
                        ZERO_INFO, " of his thugs are chasing you!"}
    else
        self.message = {ZERO_INFO, "A gang leader and ",
                        BAD_INFO, tostring(self.thugs - 1),
                        ZERO_INFO, " of his thugs are chasing you!"}
    end
end

function state.thugs.switch(self, risk_factor)

    -- load prediction
    math.randomseed(market.predictions[player.day])

    -- maximum thugs proportional to risk factor (which ranges 0% - 100%)
    local upper_thugs = 10 * risk_factor

    -- minimum thus as 1/2 of upper
    local lower_thugs = math.max(1, upper_thugs / 2)

    -- randomize lower/upper
    self.thugs = math.floor(math.random(lower_thugs, upper_thugs))

    -- prize proportional to number of thugs
    self.cash_prize = math.floor((math.random() * 1000) + self.thugs * 1000)

    -- calculated in exit_state against player's remaining health
    self.doctors_fees = 0

    self:set_message()
    self.outcome = {}
    self.escaped = false

    self:show_action_buttons(true)
    self:show_exit_buttons(false)

    -- Fight if have guns
    self.buttons:get("answer 2").disabled = player.guns == 0

    -- watch player health as a spinning number
    local dr = require("harness.digitroller")
    self.health_counter = dr:new({
        duration = 1,
        subject = player,
        target = "health"
    })

    active_state = self

    print(string.format(
        "Picked %d thugs, from a range of %.1f..%.1f given risk factor.",
        self.thugs, lower_thugs, upper_thugs))

    print(string.format(
        "You can earn $%d if you win this fight.", self.cash_prize))

end


function state.thugs.show_action_buttons(self, visible)
    self.buttons:get("answer 1").hidden = not visible
    self.buttons:get("answer 2").hidden = not visible
end

function state.thugs.show_exit_buttons(self, visible1, visible2)
    self.buttons:get("close button 1").hidden = not visible1
    self.buttons:get("close button 2").hidden = not visible2
end

function state.thugs.test_death(self)
    if player.health < 1 then
        self:allow_exit()
        self.outcome = {BAD_INFO, "They wasted you, man! What a drag!"}
        vibrate:pattern(" ... ... ...")
    end
end

function state.thugs.update(self, dt)
    self.health_counter:update(dt)
    if not self.health_counter.complete then
        display:request_fast_fps()
    end
end

function state.thugs.visit_doctor(self)
    player:restore_health()
    player:debit_account(self.doctors_fees)
    self:exit_state()
end

--  _         _             _       _
-- | |_ _   _| |_ ___  _ __(_) __ _| |
-- | __| | | | __/ _ \| '__| |/ _` | |
-- | |_| |_| | || (_) | |  | | (_| | |
--  \__|\__,_|\__\___/|_|  |_|\__,_|_|
--
function state.tutorial.draw_box(self, lines)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, self.texty, display.safe_w, self.texth*lines)
    love.graphics.setColor(PRIMARY_100)
    love.graphics.rectangle("line", 0, self.texty, display.safe_w, self.texth*lines)
end

function state.tutorial.draw(self)

    --self.buttons:draw()

    state.play.labels:draw()
    state.play.buttons:draw()
    state.messages:draw()

    -- dark overlay
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, display.safe_w, display.safe_h)

    -- draw highlighted controls
    if self.controls then
        for _, ctl in ipairs(self.controls) do
            ctl:draw()
        end
    end

    if self.text then

        -- box
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, self.texty, display.safe_w, self.texth)
        love.graphics.setColor(YELLOW)
        love.graphics.rectangle("line", 0, self.texty, display.safe_w, self.texth)

        -- text
        love.graphics.setFont(fonts:for_tutorial())
        love.graphics.printf(self.text, 0, self.texty, display.safe_w, "center")

    end

    -- debug: print current slide name
    if DEBUG then
        love.graphics.setColor(1, 0, 1)
        love.graphics.setFont(fonts.small)
        love.graphics.print(self.current, 0, 0)
    end

end

function state.tutorial.exit_state(self)
    print("Tutorial exiting")
    -- flag tutorial not running
    self.running = false
    -- flag game no longer in progress
    player.in_progress = false
    state.menu:switch()
end

function state.tutorial.keypressed(self, key)

    if key == "escape" then
        if self.current == "exit" then
            self:exit_state()
            return
        end
        self:set_slide("exit")
        self:set_text("You can restart the tutorial from the options menu")
        return
    end

    self:next_slide()

end

function state.tutorial.keyreleased(self, key, scancode)
    --self.buttons:keyreleased(key)
end

function state.tutorial.load(self)
    self.texty = 0
    self.running = false
    self.delay = 0

    -- list of tutorial slides
    self.slides = {
        "hello",
        "cash intro",
        "debt intro",
        "health intro",
        "bank intro",
        "guns intro",
        "coat intro",
        "day intro",
        "location intro",
        "market intro",
        "buy 3 of",
        "wait for 3 buys",
        "buy more of",
        "wait for more buys",
        "jet",
        "wait for new location",
        "sell",
        "wait for sale",
        "go home",
        "wait for home location",
        "visit loan shark",
        "wait for no debt",
        "messages intro",
        "wait for messages open",
        "wait for messages close",
        "exit",
    }

end

function state.tutorial.mousemoved(self, x, y, dx, dy, istouch)
    --self.buttons:mousemoved(x, y, dx, dy, istouch)
end

function state.tutorial.mousepressed(self, x, y, button, istouch)
    self:next_slide()
end

function state.tutorial.mousereleased(self, x, y, button, istouch)
    --self.buttons:mousereleased(x, y, button, istouch)
end

function state.tutorial.next_slide(self)

    -- delay user input briefly
    if self.delay > 0 then
        return
    end

    if self.current == "exit" then
        self:exit_state()
        return
    end

    -- advance next slide
    if self.index < #self.slides then
        self.index = self.index + 1
        self:set_slide(self.slides[self.index])
    end

    -- localize actions
    local click = "click"
    local clicking = "clicking"
    if display.mobile then
        click = "tap"
        clicking = "tapping"
    end

    if self.current == "hello" then
       if display.mobile then
            self:set_text(string.format([[Welcome to %s!
                This is a quick tutorial on how to play.
                Tap your back button to exit the tutorial,
                or tap the screen to continue.]], TITLE))
        else
            self:set_text(string.format([[Welcome to %s!
                This is a quick tutorial on how to play.
                Press escape to exit the tutorial,
                or any other key to continue.]], TITLE))
        end

    elseif self.current == "cash intro" then
        self.controls = {state.play.labels:get("cash")}
        self:set_text([[This is the CASH you carry.
            Use it to buy goods and pay for other expenses.]])

    elseif self.current == "debt intro" then
        self.controls = {state.play.labels:get("debt")}
        self:set_text([[You start in DEBT with the loan shark.
            Your debt increases with each passing day.
            You will have to pay it off, eventually.]])

    elseif self.current == "health intro" then
        self.controls = {state.play.labels:get("health")}
        self:set_text([[You lose HEALTH when shot in a gun fight.
            If your health drops to zero, the game ends.]])

    elseif self.current == "bank intro" then
        self.controls = {state.play.labels:get("bank")}
        self:set_text([[Safely store large amounts of cash in the BANK.
            This is wise because travelling on the subway,
            which is rife with muggers, is risky business.]])

    elseif self.current == "guns intro" then
        self.controls = {state.play.labels:get("guns")}
        self:set_text([[GUNS allow you to fight back against gangs of thugs.
            Without a gun you will only be able to run away.
            Purchasing happens randomly when moving to a new place.]])

    elseif self.current == "coat intro" then
        self.controls = {state.play.labels:get("coat")}
        self:set_text([[You use pockets in your TRENCH COAT to stash contraband.
            Purchasing a new trench coat gives you more pockets.
            Purchasing happens randomly when moving to a new place.]])

    elseif self.current == "day intro" then
        self.controls = {state.play.labels:get("day")}
        self:set_text(string.format([[This is the DAY you are currently on.
            When you reach day %d the game ends.
            Try to earn as much cash before this day.]], #market.predictions))

    elseif self.current == "location intro" then
        self.controls = {state.play.buttons:get("jet")}
        self:set_text([[You start in your home LOCATION.
            The Loan Shark and Bank are both available when you are here.
            One DAY passes when you travel to another location.]])

    elseif self.current == "market intro" then
        self.controls = {}
        for i=1, #market.db do
            table.insert(self.controls,
                state.play.labels:get(string.format("name %d", i)))
            table.insert(self.controls,
                state.play.buttons:get(string.format("buy %d", i)))
        end
        self:set_text([[The market lists all items available for trade.
            Each day prices fluctuate, and availability changes.]], 0)

    elseif self.current == "buy 3 of" then
        -- get cheapest drug on the market
        self.expected_drug = market:cheapest_available()
        self.controls = {}
        -- highlight its controls
        for i=1, #market.available do
            local label = state.play.labels:get(string.format("name %d", i))
            if label.title == self.expected_drug.name then
                self.controls = {
                    label,
                    state.play.buttons:get(string.format("buy %d", i))
                    }
            end
        end
        self:set_text(string.format(
            "Buy 3 units of %s by %s the BUY button three times.",
            self.expected_drug.name, clicking))
        -- position text below the controls
        self.texty = self.controls[1].top - self.texth

    elseif self.current == "wait for 3 buys" then
        -- return control to play state until 3 units are bought
        active_state = state.play

    elseif self.current == "buy more of" then
        -- give the player enough cash
        local expected_cost = self.expected_drug.cost * trenchcoat:free_space()
        local extra_cash = ""
        if expected_cost > player.cash then
            player.cash = expected_cost
            extra_cash = "We gave you some extra cash to help you out."
        end
        self:set_text(string.format(
            [[Great! Now buy more %s.
            Hold the BUY button until your pockets are full. %s]],
            self.expected_drug.name, extra_cash))
        self.texty = self.controls[1].top - self.texth

    elseif self.current == "wait for more buys" then
        -- return control to play state until more are bought
        active_state = state.play


    elseif self.current == "jet" then
        self.last_place = player.location
        self.controls = {state.play.buttons:get("jet")}
        self:set_text([[Use the location button to move to a new place.
            This moves to the next day, and drug prices fluctuate.
            You can pick any place you like.]])

    elseif self.current == "wait for new location" then
        -- return control to play state until more are bought
        active_state = state.play

    elseif self.current == "sell" then
        -- highlight the expected drug controls
        for i=1, #market.available do
            local label = state.play.labels:get(string.format("name %d", i))
            if label.title == self.expected_drug.name then
                self.controls = {
                    label,
                    state.play.buttons:get(string.format("sell %d", i))
                    }
            end
        end
        self:set_text([[Now SELL all your stock by
            holding the SELL button until everything is sold.]])
        self.texty = self.controls[1].top - self.texth

    elseif self.current == "wait for sale" then
        -- return control to play state until more are bought
        active_state = state.play

    elseif self.current == "go home" then
        self.controls = {state.play.buttons:get("jet")}
        self:set_text(string.format(
            [[Now that you have some cash, let's pay the loan shark.
            You need to travel back to your home location, %s]],
            LOCATIONS[1]))

    elseif self.current == "wait for home location" then
        -- return control to play state until more are bought
        active_state = state.play

    elseif self.current == "visit loan shark" then
        self.controls = {state.play.buttons:get("debt")}
        self:set_text([[Visit the loan shark, and pay off your debt.
            We gave you the difference so that you can clear your debt.]])
        player.cash = player.debt + 2500

    elseif self.current == "wait for no debt" then
        -- return control to play state until more are bought
        active_state = state.play

    elseif self.current == "messages intro" then
        state.messages:add("You are playing the tutorial")
        self.controls = {state.messages}
        if display.mobile then
            self:set_text([[You can see a log of the events that happened
                in the message panel below.
                It shows automatically if there are new messages on the day.
                Open your messages now by tapping it.]])
        else
            self:set_text([[You can see a log of the events that happened
                in the message panel below.
                It shows automatically if there are new messages on the day.
                Open your messages now by clicking it, or press the Space Bar.]])
        end

    elseif self.current == "wait for messages close"
        or self.current == "wait for messages open" then
        active_state = state.play

    elseif self.current == "exit" then
        self.controls = nil
        self:set_text([[This concludes the tutorial.
            Good luck and have fun trading!
            (The tutorial can be restarted from the options menu)]])

    end

end

function state.tutorial.set_slide(self, name)
    self.current = name
    self.delay = 1
    print(string.format("Set tutorial slide: %s", name))
end

function state.tutorial.set_text(self, text, position)
    -- remove superfluous spaces (from bracketed string literals)
    self.text = util.oneline(util.shrink(text))
    _, self.texth = fonts:measure(fonts:for_tutorial(), self.text)
    self.texty = display.safe_y + math.floor(display.safe_h * (position or 0.5))
    -- clamp to bottom of display, if overflown
    if self.texty + self.texth > display.safe_h then
        self.texty = display.safe_h - self.texth
    end
end

function state.tutorial.update(self, dt)

    -- delay user input briefly
    self.delay = math.max(0, self.delay - dt)

    if self.current == "boot" then
        -- wait for cash counter to tally, then begin tutorial
        if state.play.cash_counter.complete then
            -- switch to tutorial state
            active_state = self
            self:next_slide()
        end

    elseif self.current == "wait for 3 buys" then
        if state.play.cash_counter.complete then
            if trenchcoat:stock_of(self.expected_drug.name) == 3 then
                active_state = self
                self:next_slide()
            end
        end

    elseif self.current == "wait for more buys" then
        if state.play.cash_counter.complete then
            local coat_full = trenchcoat:free_space() == 0
            local has_drugs = trenchcoat:stock_of(self.expected_drug.name) > 30
            if has_drugs and coat_full then
                active_state = self
                self:next_slide()
            end
        end

    elseif self.current == "wait for new location" then
        if self.last_place ~= player.location then
            active_state = self
            self:next_slide()
        end

    elseif self.current == "wait for sale" then
        if state.play.cash_counter.complete then
            local sold_drugs = trenchcoat:stock_of(self.expected_drug.name) == 0
            if sold_drugs then
                active_state = self
                self:next_slide()
            end
        end

    elseif self.current == "wait for home location" then
        if player.location == LOCATIONS[1] then
            active_state = self
            self:next_slide()
        end

    elseif self.current == "wait for no debt" then
        -- prevent player from going to other places
        if not (active_state == state.play
                or active_state == state.loanshark
                or active_state == state.menu) then
            active_state = state.play
            print("(Tutorial forced play state)")
        end
        -- test for cleared debt
        if state.play.cash_counter.complete then
            if player.debt == 0 then
                active_state = self
                self:next_slide()
            end
        end

    elseif self.current == "wait for messages open" then
        if state.messages:is_locked() then
            active_state = self
            self:next_slide()
        end

    elseif self.current == "wait for messages close" then
        if not state.messages:is_locked() and state.messages:is_hidden() then
            active_state = self
            self:next_slide()
        end
    end

    -- prevent thug encounters, except for the thugs slide.
    -- edge case: player was given drugs on day 1 which
    -- triggers a thug encounter.
    -- seed 1626172738 does this.
    if self.current ~= "thugs" and active_state == state.thugs then
        active_state = state.play
        print("(Tutorial skipped game thug encounter)")
    end

    if state.messages.locked then
        if self.current ~= "wait for messages close" then
            -- hide any auto-shown messages for tutorial
            state.messages:hide()
            print("(Tutorial hides messages)")
        end
    end

end

function state.tutorial.watch(self)

    if (player.day == 1) and (not self.running) and options.tutorial then
        -- flag option off until user enables it again
        options.tutorial = false
        -- save options after setting tutorial
        options:save()
        -- reset tutorial slide
        self.index = 0
        -- set initial state: boot
        -- which waits in self.update until the cash counter has completed counting.
        self.current = "boot"
        -- flag as running to receive update() calls
        self.running = true
        -- clear highlighted controls
        self.controls = {}
        -- active state is set in update()
    end

end

--  _                       _                     _
-- | |_ _ __ ___ _ __   ___| |__   ___ ___   __ _| |_
-- | __| '__/ _ \ '_ \ / __| '_ \ / __/ _ \ / _` | __|
-- | |_| | |  __/ | | | (__| | | | (_| (_) | (_| | |_
--  \__|_|  \___|_| |_|\___|_| |_|\___\___/ \__,_|\__|
--
function trenchcoat.adjust_pockets(self, amount)
    amount = amount or 20
    self.size = self.size + amount
    self.free = self.free + amount
    print(string.format("Adjusted trench coat. You now have %d pockets.", self.size))
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
    if delta > 0 then
        print(string.format("Added %d %s to trench coat.", delta, name))
    elseif delta < 0 then
        print(string.format("Removed %d %s from trench coat.", -1*delta, name))
    end
    return math.abs(delta), new_stock
end

function trenchcoat.free_space(self)
    return self.free
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

function trenchcoat.has(self, name)
    return self[name]
end

function trenchcoat.reset(self, size)
    for k, v in pairs(self) do
        if type(v) == "number" then
            self[k] = nil
        end
    end
    self.size = size or 100
    self.free = self.size
    print(string.format("Reset trench coat to %d pockets", self.size))
end

function trenchcoat.stock_of(self, name)
    if self:has(name) then
        return self[name]
    else
        return 0
    end
end

function trenchcoat.total_carried(self)
    return self.size - self.free
end

--        _   _ _
--  _   _| |_(_) |
-- | | | | __| | |
-- | |_| | |_| | |
--  \__,_|\__|_|_|
--
function util.append_tables(first, second)
    table.foreach(second, function(i, v)
        table.insert(first, v)
    end)
end

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

function util.crc(t1, t2)
    local crc = 0
    for _, tbl in ipairs({t1, t2}) do
        for k, v in pairs(tbl) do
            if k ~= "crc" and type(v) == "number" then
                crc = crc + v
            end
        end
    end
    return crc % 242
end

-- Returns an iterator over the key=value pairs in a line
function util.key_value_pairs(line, replace_underscore)
    -- match key-value pairs as groups of alphanumeric + punctuation.
    -- (key+)=(value+) is expressed as the character set [%w%p]
    -- where %w matches alphanumeric, %p punctuation (including dash, underscore)
    -- and + matches one or more repetitions.
    -- https://www.lua.org/pil/20.2.html
    local key_value_matcher = string.gfind(line, "([%w%p]+)=([%w%p]+)")
    return function()
        local key, value = key_value_matcher()
        if key ~= nil then
            -- attempt conversion from hex number
            local number_from_hex = tonumber(value, 16)
            -- convert to boolean
            if value == "true" then
                value = true
            elseif value == "false" then
                value = false
            end
            -- replace underscore
            if replace_underscore and type(value) == "string" then
                value = string.gsub(value, "_", " ")
            end
            return key, number_from_hex or value
        end
    end
end

function util.oneline(text)
    -- remove line breaks
    return string.gsub(text, "\n", "")
end

function util.pick(...)
    return select(math.random(1, select("#",...)), ...)
end

-- Returns an iterator over the lines in a file
function util.read_file(filename)
    local file = love.filesystem.newFile(filename)
    local ok, err = file:open("r")
    local content = {}
    local seek = 0
    if ok then
        for line in file:lines() do
            if line then
                table.insert(content, line)
            end
        end
        file:close()
    end
    return function()
        seek = seek + 1
        if seek <= #content then
            return content[seek]
        end
    end
end

function util.rot(input)
    return input:gsub("%a",
        function(c)
            c=c:byte()
            return string.char(c+(c%32<14 and 13 or -13))
        end)
end

function util.shrink(text)
    -- remove superfluous spaces (from bracketed string literals)
    return string.gsub(text, "[ ]+", " ")
end

function util.write_file(filename, entries)
    local file = love.filesystem.newFile(filename)
    local ok, err = file:open("w")
    if ok then
        for _, entry in ipairs(entries) do
            -- embed crc
            entry.crc = util.crc(entry)
            -- add each key value pair
            local data = ""
            for key, v in pairs(entry) do
                if type(v) == "string" then
                    -- replace space with underscore
                    data = data .. string.format("%s=%s ", key, string.gsub(v, " ", "_"))
                elseif type(v) == "number" then
                    -- encode as hex
                    data = data .. string.format("%s=%x ", key, v)
                elseif type(v) == "boolean" then
                    data = data .. string.format("%s=%s ", key, tostring(v))
                end
            end
            -- write with new line
            file:write(data.." \n")
        end
        file:close()
    end
end

--        _ _               _
-- __   _(_) |__  _ __ __ _| |_ ___
-- \ \ / / | '_ \| '__/ _` | __/ _ \
--  \ V /| | |_) | | | (_| | ||  __/
--   \_/ |_|_.__/|_|  \__,_|\__\___|
function vibrate.pattern(self, pattern)

    if options.vibrate then
        self.delay = 0
        self.next = string.gfind(pattern, ".")
    end

end

function vibrate.update(self, dt)

    if options.vibrate and self.next then

        -- delay further processing
        self.delay = self.delay - dt
        if self.delay > 0 then
            return
        end

        -- process next symbol
        local symbol = self.next()

        if symbol == "." then
            love.system.vibrate(0.05)
            self.delay = 0.1
        elseif symbol == "-" then
            love.system.vibrate(0.1)
            self.delay = 0.3
        elseif symbol == " " then
            self.delay = .3
        else
            self.next = nil
            return
        end

    end

end
