local colors = require("src/consts/colors")

local brick = {
    width = 60,           -- Default width
    height = 20,          -- Default height
    shouldRemove = false, -- Boolean flag for pending removal
    sprite = {},
}

-- Initialize brick position and body
function brick.new(world, x, y, sprite)
    local b = {}

    b.width = brick.width
    b.height = brick.height
    b.body = love.physics.newBody(world, x, y, "static")
    b.shape = love.physics.newRectangleShape(b.width, b.height)
    b.fixture = love.physics.newFixture(b.body, b.shape)
    b.fixture:setUserData({ type = "brick", obj = b })

    b.sprite = sprite
    return b
end

-- Draw brick to screen
function brick.draw(b)
    love.graphics.setColor(colors.BRICK)

    local x, y = b.body:getPosition()
    local originX = b.width / 2
    local originY = b.height / 2

    love.graphics.draw(b.sprite, x, y, 0, 1, 1, originX, originY)
end

return brick
