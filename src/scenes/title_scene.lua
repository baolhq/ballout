local colors = require("src/consts/colors")
local consts = require("src/consts/consts")
local res = require("src/consts/res")
local drawer = require("src/utils/drawer")

local titleScene = {
    assets = {},
    actions = {},
}

local focusedIndex = 1
local buttonOrder = { "start", "lboard", "settings" }
local buttons = {
    start = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "START",
        focused = true,
        hovered = false,
    },
    lboard = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "LEADERBOARD",
        focused = false,
        hovered = false,
    },
    settings = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "SETTINGS",
        focused = false,
        hovered = false,
    }
}

function titleScene:load(assets, actions)
    self.assets = assets
    self.actions = actions

    local spacingY = 48
    buttons.start.x = (love.graphics.getWidth() - buttons.start.width) / 2
    buttons.start.y = (love.graphics.getHeight() - buttons.start.height) / 2 + 28
    buttons.lboard.x = buttons.start.x
    buttons.lboard.y = buttons.start.y + spacingY
    buttons.settings.x = buttons.lboard.x
    buttons.settings.y = buttons.lboard.y + spacingY
end

function titleScene:keypressed(key)
    if key == "escape" then love.event.quit() end

    if key == "return" then
        if buttons.start.focused then
            self.actions.switchScene("main")
        elseif buttons.lboard.focused then
            self.actions.switchScene("leaderboard")
        else
            self.actions.switchScene("settings")
        end
        return
    end

    -- Cycling button focuses
    if key == "tab" or key == "up" or key == "down" then
        -- Remove old focuses
        for _, btn in pairs(buttons) do
            btn.focused = false
        end

        if key == "up" then
            -- Movind upwards
            focusedIndex = (focusedIndex - 2) % #buttonOrder + 1
        else
            -- Moving downwards
            focusedIndex = focusedIndex % #buttonOrder + 1
        end

        buttons[buttonOrder[focusedIndex]].focused = true
    end
end

function titleScene:mousepressed(x, y, btn)
    if btn == 1 and buttons.start.hovered then
        buttons.start.focused = true
        buttons.lboard.focused = false
        buttons.settings.focused = false
        self.actions.switchScene("main")
    elseif btn == 1 and buttons.lboard.hovered then
        buttons.start.focused = false
        buttons.lboard.focused = true
        buttons.settings.focused = false
        self.actions.switchScene("leaderboard")
    elseif btn == 1 and buttons.settings.hovered then
        buttons.start.focused = false
        buttons.lboard.focused = false
        buttons.settings.focused = true
        self.actions.switchScene("settings")
    end
end

-- Update title scene, listen for mouse and keyboard event
function titleScene:update(dt)
    local mx, my = love.mouse.getPosition()

    for _, name in ipairs(buttonOrder) do
        local btn = buttons[name]
        btn.hovered =
            mx > btn.x and mx < btn.x + btn.width and
            my > btn.y and my < btn.y + btn.height
    end
end

function titleScene:draw()
    love.graphics.clear(colors.SLATE_100)

    local font = drawer:getFont(res.MAIN_FONT, consts.FONT_TITLE_SIZE)
    drawer:drawCenteredText("BALLOUT", font, 0, -68)

    font = drawer:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    drawer:drawButton(buttons.start, font)
    drawer:drawButton(buttons.lboard, font)
    drawer:drawButton(buttons.settings, font)
end

return titleScene
