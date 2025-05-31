local colors = require("src/consts/colors")
local res = require("src/consts/res")
local vector = require("src/utils/vector")

local ball = {
    width = 24,
    height = 24,
    radius = 12,
    speed = 0,
    sprite = {},
    body = {},
    shape = {},
    fixture = {},
}

-- Initialize ball position, body and angle
function ball:init(world)
    self.speed = 400
    local screenW, screenH = love.graphics.getDimensions()
    local x = (screenW - self.width) / 2 + self.width / 2
    local y = screenH / 2 - self.height / 2

    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.body:setBullet(true)
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData({ type = "ball", obj = self })
    self.fixture:setRestitution(1.0)
    self.fixture:setFriction(0)

    -- Load ball sprite
    self.sprite = love.graphics.newImage(res.BALL_SPR)
    self.sprite:setFilter("linear", "linear", 64)

    -- Setup initial angle
    local angle = math.rad(love.math.random(45, 135))
    local vx = math.cos(angle)
    local vy = math.sin(angle)
    self:setVelocity(vx, vy)
end

---Change game difficulty by increase or decrease ball speed
---@param diff number Can be 1, 2 or 3 for "Easy", "Normal" and "Hard"
function ball:changeDifficulty(diff)
    if diff == 1 then
        self.speed = 200
    elseif diff == 3 then
        self.speed = 600
    else
        self.speed = 400
    end
end

-- Set ball velocity to be normalized at constant speed
function ball:setVelocity(vx, vy)
    local nx, ny = vector.normalize(vx, vy)
    self.body:setLinearVelocity(nx * self.speed, ny * self.speed)
end

-- Update ball velocity and position
function ball:update(dt)
    local vx, vy = self.body:getLinearVelocity()
    local currentSpeed = math.sqrt(vx * vx + vy * vy)
    local minVy = 200

    -- Prevent infinite horizontal bouncing
    if math.abs(vy) < minVy then
        vy = vy < 0 and -minVy or minVy
    end

    -- Always force ball to be constant speed
    if currentSpeed ~= 0 then
        local scale = self.speed / currentSpeed
        self:setVelocity(vx * scale, vy * scale)
    end
end

-- Draw ball to scene
function ball:draw()
    love.graphics.setColor(colors.SLATE_800)

    local x, y = self.body:getPosition()
    local originX = self.width / 2  -- half of sprite width
    local originY = self.height / 2 -- half of sprite height

    love.graphics.draw(self.sprite, x, y, 0, 1, 1, originX, originY)
end

return ball
