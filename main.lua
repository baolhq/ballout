local screenManager = require("src/managers/screen_manager")
local consts = require("src/consts/consts")

--#region Debugger setup

local love_errorhandler = love.errorhandler
-- Enables code debugger via launch.json
if arg[2] == "debug" then
    require("lldebugger").start()
end

-- Tell Love to throw an error instead of showing it on screen
function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end

--#endregion

-- Shared assets
local assets = {}

function love.load()
    love.window.setTitle(consts.GAME_TITLE)
    local gameIcon = love.image.newImageData("res/img/icon.png")
    love.window.setIcon(gameIcon)

    assets.bgSound = love.audio.newSource("res/audio/background.ogg", "stream")
    assets.blipSound = love.audio.newSource("res/audio/blip.wav", "static")
    assets.bgSound:setLooping(true)
    assets.blipSound:setVolume(0.5)

    screenManager:switch("title", assets)
end

function love.keypressed(key)
    screenManager:keypressed(key)
end

function love.mousepressed(x, y, btn)
    screenManager:mousepressed(x, y, btn)
end

function love.update(dt)
    screenManager:update(dt)
end

function love.draw()
    screenManager:draw()
end
