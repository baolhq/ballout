local colors = require("src/consts/colors")

local brick = {
    width = 60,
    height = 20,
    shouldRemove = false,
}

function brick.init(world, x, y)
    local b = {}

    b.width = brick.width
    b.height = brick.height
    b.body = love.physics.newBody(world, x, y, "static")
    b.shape = love.physics.newRectangleShape(b.width, b.height)
    b.fixture = love.physics.newFixture(b.body, b.shape)
    b.fixture:setUserData({ type = "brick", obj = b })

    return b
end

function brick.draw(b)
    love.graphics.setColor(colors.BRICK)
    local x, y = b.body:getPosition()
    love.graphics.rectangle(
        "fill",
        x - b.width / 2,
        y - b.height / 2,
        b.width,
        b.height,
        2, 2
    )
end

return brick
