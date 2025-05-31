local colors = require("src/consts/colors")
local consts = require("src/consts/consts")
local res = require("src/consts/res")
local drawer = require("src/utils/drawer")
local file = require("src/utils/file")

local settingsScreen = {
    assets = {},
    actions = {},
    configs = {},
}

local buttons = {
    music = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "MUSIC: ON",
        focused = true,
        hovered = false,
        toggle = true,
        state = true, -- true = ON, false = OFF
    },
    difficulty = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "DIFFICULTY: NORMAL",
        options = { "EASY", "NORMAL", "HARD" },
        index = 2, -- points to "NORMAL"
        focused = false,
        hovered = false,
    },
    back = {
        x = 0,
        y = 0,
        width = 200,
        height = 40,
        text = "BACK",
        focused = false,
        hovered = false,
    }
}

function settingsScreen:load(actions, assets, configs)
    self.actions = actions
    self.assets = assets
    self.configs = configs

    local spacingY = 48
    buttons.music.x = (love.graphics.getWidth() - buttons.music.width) / 2
    buttons.music.y = (love.graphics.getHeight() - buttons.music.height) / 2 + 28
    buttons.difficulty.x = buttons.music.x
    buttons.difficulty.y = buttons.music.y + spacingY
    buttons.back.x = buttons.difficulty.x
    buttons.back.y = buttons.difficulty.y + spacingY

    if configs.music then
        local state = configs.music == "true"
        buttons.music.state = state
        buttons.music.text = state and "MUSIC: ON" or "MUSIC: OFF"
    end

    if configs.diff then
        local id = tonumber(configs.diff)
        buttons.difficulty.index = id
        buttons.difficulty.text = "DIFFICULTY: " .. buttons.difficulty.options[id]
    end
end

function settingsScreen:keypressed(key)
    if key == "escape" then
        self.actions.switchScene("title")
    end
end

function settingsScreen:mousepressed(x, y, btn)
    self.assets.clickSound:play()
    if btn ~= 1 then return end -- left click only

    for name, b in pairs(buttons) do
        if b.hovered then
            if name == "music" and b.toggle then
                b.state = not b.state
                b.text = "Music: " .. (b.state and "ON" or "OFF")

                self.configs.music = b.state
                file.saveConfigs(self.configs)
            elseif name == "difficulty" and b.options then
                b.index = b.index % #b.options + 1
                b.text = "Difficulty: " .. b.options[b.index]

                self.configs.diff = b.index
                file.saveConfigs(self.configs)
            elseif name == "back" then
                self.actions.switchScene("title")
            end
        end
    end
end

function settingsScreen:update()
    local mx, my = love.mouse:getPosition()

    for _, btn in pairs(buttons) do
        btn.hovered =
            mx > btn.x and mx < btn.x + btn.width and
            my > btn.y and my < btn.y + btn.height
    end
end

function settingsScreen:draw()
    love.graphics.clear(colors.SLATE_100)

    local font = drawer:getFont(res.MAIN_FONT, consts.FONT_TITLE_SIZE)
    drawer:drawCenteredText("SETTINGS", font, 0, -68)

    font = drawer:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    for _, btn in pairs(buttons) do
        drawer:drawButton(btn, font)
    end
end

return settingsScreen
