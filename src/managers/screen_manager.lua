local screenManager = {
    current = "title",
}

local screens = {
    title = require("src/screens/title_screen"),
    main = require("src/screens/main_screen"),
    leaderboard = require("src/screens/lboard_screen"),
}

function screenManager:switch(name, assets)
    if screens[name] then
        self.current = name
        if screens[self.current].load then
            -- Callback actions from child scene
            local actions = {
                switchScreen = function(newScreen)
                    self:switch(newScreen, assets)
                end,
                quit = function()
                    love.event.quit()
                end
            }

            screens[self.current]:load(assets, actions)
        end
    else
        error("Scene " .. name .. " not found.")
    end
end

function screenManager:keypressed(key)
    local screen = screens[self.current]
    if screen.keypressed then
        screen:keypressed(key)
    end
end

function screenManager:mousepressed(x, y, btn)
    local screen = screens[self.current]
    if screen.mousepressed then
        screen:mousepressed(x, y, btn)
    end
end

function screenManager:update(dt)
    local screen = screens[self.current]
    if screen.update then
        screen:update(dt)
    end
end

function screenManager:draw()
    local screen = screens[self.current]
    if screen.draw then
        screen:draw()
    end
end

return screenManager
