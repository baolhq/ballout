local consts = require("src/consts/consts")
local res = require("src/consts/res")
local file = require("src/utils/file")
local sceneManager = require("src/managers/scene_manager")

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

-- Game configurations
local configs = {}

function love.load()
    local gameIcon = love.image.newImageData(res.GAME_ICON)
    love.window.setIcon(gameIcon)
    love.window.setTitle(consts.GAME_TITLE)
    love.graphics.setDefaultFilter("nearest", "nearest")

    assets.bgSound = love.audio.newSource(res.BG_SOUND, "stream")
    assets.bgSound:setLooping(true)
    assets.blipSound = love.audio.newSource(res.BLIP_SOUND, "static")
    assets.blipSound:setVolume(0.5)
    assets.clickSound = love.audio.newSource(res.CLICK_SOUND, "static")
    assets.clickSound:setVolume(0.5)

    configs = file.loadConfigs()

    sceneManager:switch("title", assets, configs)
end

function love.keypressed(key)
    sceneManager:keypressed(key)
end

function love.mousepressed(x, y, btn)
    sceneManager:mousepressed(x, y, btn)
end

function love.update(dt)
    sceneManager:update(dt)
end

function love.draw()
    sceneManager:draw()
end
