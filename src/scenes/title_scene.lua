local colors = require("src/consts/colors")
local consts = require("src/consts/consts")
local drawer = require("src/utils/drawer")

local titleScene = {
    assets = {},
    actions = {},
}

local startBtn = {
    x = 0,
    y = 0,
    width = 200,
    height = 40,
    text = "START",
    focused = true,
    hovered = false,
}

local lboardBtn = {
    x = 0,
    y = 0,
    width = 200,
    height = 40,
    text = "LEADERBOARD",
    focused = false,
    hovered = false,
}

function titleScene:load(assets, actions)
    self.assets = assets
    self.actions = actions

    startBtn.x = (love.graphics.getWidth() - startBtn.width) / 2
    startBtn.y = (love.graphics.getHeight() - startBtn.height) / 2 + 28
    lboardBtn.x = startBtn.x
    lboardBtn.y = startBtn.y + 48
end

function titleScene:keypressed(key)
    if key == "escape" then love.event.quit() end

    if key == "return" then
        if startBtn.focused then
            self.actions.switchScene("main")
        else
            self.actions.switchScene("leaderboard")
        end
        return
    end

    if key == "tab" or key == "up" or key == "down" then
        startBtn.focused = not startBtn.focused
        lboardBtn.focused = not lboardBtn.focused
    end
end

function titleScene:mousepressed(x, y, btn)
    if btn == 1 and startBtn.hovered then
        startBtn.focused = true
        lboardBtn.focused = false
        self.actions.switchScene("main")
    elseif btn == 1 and lboardBtn.hovered then
        startBtn.focused = false
        lboardBtn.focused = true
        self.actions.switchScene("leaderboard")
    end
end

function titleScene:update(dt)
    local mx, my = love.mouse.getPosition()
    startBtn.hovered =
        mx > startBtn.x and mx < startBtn.x + startBtn.width and
        my > startBtn.y and my < startBtn.y + startBtn.height

    lboardBtn.hovered =
        mx > lboardBtn.x and mx < lboardBtn.x + lboardBtn.width and
        my > lboardBtn.y and my < lboardBtn.y + lboardBtn.height
end

function titleScene:draw()
    love.graphics.clear(colors.SLATE_100)

    local font = drawer:getFont(consts.MAIN_FONT, consts.FONT_TITLE_SIZE)
    drawer:drawCenteredText("BALLOUT", font, 0, -68)

    font = drawer:getFont(consts.MAIN_FONT, consts.FONT_SUB_SIZE)
    drawer:drawButton(startBtn, font)
    drawer:drawButton(lboardBtn, font)
end

return titleScene
