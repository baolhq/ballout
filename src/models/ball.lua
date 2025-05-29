local colors = require("src/consts/colors")
local vector = require("src/utils/vector")

local ball = {
    width = 24,
    height = 24,
    radius = 12,
    speed = 400,
    body = {},
    shape = {},
    fixture = {},
}

function ball:init(world)
    local screenW, screenH = love.graphics.getDimensions()
    local x = (screenW - self.width) / 2 + self.width / 2
    local y = screenH / 2 - self.height / 2

    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData({ type = "ball", obj = self })

    -- Setup initial fall angle
    local angle = math.rad(love.math.random(45, 135))
    local vx = math.cos(angle)
    local vy = math.sin(angle)
    self:setVelocity(vx, vy)
end

function ball:setVelocity(vx, vy)
    local nx, ny = vector.normalize(vx, vy)
    self.body:setLinearVelocity(nx * self.speed, ny * self.speed)
end

function ball:draw()
    love.graphics.setColor(colors.BALL)
    local x, y = self.body:getPosition()
    love.graphics.circle("fill", x, y, self.radius)
end

return ball
