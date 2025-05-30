local colors = require("src/consts/colors")
local consts = require("src/consts/consts")
local res = require("src/consts/res")
local drawer = require("src/utils/drawer")

local lboardScene = {
    assets = {},
    actions = {},
    highScores = {}
}

local backBtn = {
    x = 0,
    y = 0,
    width = 200,
    height = 40,
    text = "BACK",
    focused = true,
    hovered = false,
}

function lboardScene:load(assets, actions)
    self.assets = assets
    self.actions = actions
    -- self.highScores = file.loadScore()

    backBtn.x = (love.graphics.getWidth() - backBtn.width) / 2
    backBtn.y = (love.graphics.getHeight() - backBtn.height) / 2 + 168
end

function lboardScene:keypressed(key)
    if key == "return" or key == "escape" then
        self.actions.switchScene("title")
    end
end

function lboardScene:mousepressed(x, y, btn)
    if btn == 1 and backBtn.hovered then
        self.actions.switchScene("title")
    end
end

function lboardScene:update(dt)
    local mx, my = love.mouse.getPosition()
    backBtn.hovered =
        mx > backBtn.x and mx < backBtn.x + backBtn.width and
        my > backBtn.y and my < backBtn.y + backBtn.height
end

function lboardScene:draw()
    love.graphics.clear(colors.SLATE_100)

    local font = drawer:getFont(res.MAIN_FONT, consts.FONT_TITLE_SIZE)
    drawer:drawCenteredText("LEADERBOARD", font, 0, -68)

    font = drawer:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    for i = 1, 5 do
        local score = self.highScores[i] or 0
        local text =
            "???????? " .. string.rep(".", 80) ..
            " " .. string.format("%08d", score)
        drawer:drawCenteredText(text, font, 0, i * 28 - 28)
    end

    drawer:drawButton(backBtn, font)
end

return lboardScene
