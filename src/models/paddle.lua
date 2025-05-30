local consts = require("src/consts/consts")
local colors = require("src/consts/colors")

local paddle = {
    width = 200,
    height = 20,
    speed = 600,
    body = {},
    shape = {},
    fixture = {},
    sprite = {},
}

-- Initialize the paddle, setup its physics body
function paddle:init(world)
    local screenW, screenH = love.graphics.getDimensions()
    local x = (screenW - self.width) / 2 + self.width / 2
    local y = screenH - self.height / 2 - 48

    self.body = love.physics.newBody(world, x, y, "kinematic")
    self.shape = love.physics.newRectangleShape(self.width, self.height)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData({ type = "paddle", obj = self })

    -- Load paddle sprite
    self.sprite = love.graphics.newImage("res/img/paddle.png")
end

-- Move the paddle with provided horizontal direction from `-1` to `1` <br/>
-- Clamp it position into scene boundaries
function paddle:move(direction)
    local vx = 0

    if direction ~= 0 then
        vx = direction * self.speed
    end

    self.body:setLinearVelocity(vx, 0)

    -- Clamp to scene boundaries
    local x, y = self.body:getPosition()
    local halfWidth = self.width / 2

    if x - halfWidth < 0 then
        self.body:setPosition(halfWidth, y)
        self.body:setLinearVelocity(0, 0)
    end

    if x + halfWidth > consts.WINDOW_WIDTH then
        self.body:setPosition(consts.WINDOW_WIDTH - halfWidth, y)
        self.body:setLinearVelocity(0, 0)
    end
end

-- Draw the paddle
function paddle:draw()
    love.graphics.setColor(colors.SLATE_600)

    local x, y = self.body:getPosition()
    local originX = self.width / 2
    local originY = self.height / 2

    love.graphics.draw(self.sprite, x, y, 0, 1, 1, originX, originY)
end

return paddle
