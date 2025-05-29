local colors     = require("src/consts/colors")
local consts     = require("src/consts/consts")
local paddle     = require("src/models/paddle")
local ball       = require("src/models/ball")
local brick      = require("src/models/brick")
local collider   = require("src/utils/collider")
local drawer     = require("src/utils/drawer")

local mainScreen = {
    assets = {},
    actions = {},
    world = {},
    bricks = {},
    score = 0,
}

local function initBoundaries(world)
    local topBound = {}
    topBound.body = love.physics.newBody(world, consts.WINDOW_WIDTH / 2, 5, "static")
    topBound.shape = love.physics.newRectangleShape(consts.WINDOW_WIDTH, 1)
    topBound.fixture = love.physics.newFixture(topBound.body, topBound.shape)

    local leftBound = {}
    leftBound.body = love.physics.newBody(world, 5, consts.WINDOW_HEIGHT / 2, "static")
    leftBound.shape = love.physics.newRectangleShape(1, consts.WINDOW_HEIGHT)
    leftBound.fixture = love.physics.newFixture(leftBound.body, leftBound.shape)

    local rightBound = {}
    rightBound.body = love.physics.newBody(world, consts.WINDOW_WIDTH - 5, consts.WINDOW_HEIGHT / 2, "static")
    rightBound.shape = love.physics.newRectangleShape(1, consts.WINDOW_HEIGHT)
    rightBound.fixture = love.physics.newFixture(rightBound.body, rightBound.shape)
end

function mainScreen:load(assets, actions)
    self.assets = assets
    self.actions = actions
    self.world = love.physics.newWorld(0, 0, true)

    -- Set collision handlers and reference
    collider:setScreen(self)
    self.world:setCallbacks(function(a, b)
        collider:beginContact(a, b)
    end, function() end)

    initBoundaries(self.world)
    paddle:init(self.world)
    ball:init(self.world)

    -- Create a pool of bricks
    local spacingX, spacingY = 10, 10
    local rows, cols = 5, 10
    local totalGridW = cols * brick.width + (cols - 1) * spacingX

    local xOffset = (love.graphics.getWidth() - totalGridW) / 2
    local yOsset = 36

    for row = 1, rows do
        for col = 1, cols do
            local x = xOffset + (col - 1) * (brick.width + spacingX) + brick.width / 2
            local y = yOsset + (row - 1) * (brick.height + spacingY) + brick.height / 2
            local b = brick.new(self.world, x, y)
            table.insert(self.bricks, b)
        end
    end
end

function mainScreen:unload()
    -- Destroy paddle and ball
    if paddle.destroy then paddle:destroy() end
    if ball.destroy then ball:destroy() end

    -- Destroy bricks
    for _, b in ipairs(self.bricks) do
        if b.body and b.body:destroy() then
            b.body:destroy()
        end
    end
    self.bricks = {}

    -- Destroy world
    if self.world and self.world:destroy() then
        self.world:destroy()
    end
    self.world = nil
end

function mainScreen:keypressed(key)
    if key == "escape" then
        self:unload()
        self.actions.switchScreen("title")
        return
    end
end

function mainScreen:mousepressed(x, y, btn)

end

local function gameOver()
    print("Game Over")
end

function mainScreen:update(dt)
    self.world:update(dt)

    local direction = 0
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        direction = direction - 1
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        direction = direction + 1
    end

    paddle:move(direction)
    ball:update(dt)

    -- Game over if the ball fall off screen
    local _, by = ball.body:getPosition()
    if by > consts.WINDOW_HEIGHT then
        gameOver()
    end

    -- Flush pending brick events
    collider:flush()
    -- Remove pending destroy bricks
    for i = #self.bricks, 1, -1 do
        if self.bricks[i].shouldRemove then
            table.remove(self.bricks, i)
        end
    end
end

function mainScreen:draw()
    love.graphics.clear(colors.BG)

    -- Draw score in the background
    love.graphics.setColor(colors.TEXT_GRAY)
    local font = drawer:getFont(consts.MAIN_FONT, consts.FONT_TITLE_SIZE)
    local textW = font:getWidth(self.score)
    local textH = font:getHeight(self.score)
    local x = (love.graphics.getWidth() - textW) / 2
    local y = (love.graphics.getHeight() - textH) / 2
    love.graphics.print(self.score, x, y)

    -- Draw ball and paddle
    paddle:draw()
    ball:draw()

    -- Draw bricks grid
    for _, v in ipairs(self.bricks) do
        brick.draw(v)
    end
end

return mainScreen
