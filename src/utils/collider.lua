local vector = require("src/utils/vector")

local collider = {
    queued = {}, -- Queued callback events
}

function collider:handleBallPaddle(ball, paddle)
    table.insert(self.queued, function()
        local bx = ball.body:getX()
        local px = paddle.body:getX()
        local newVx = (bx - px) / (paddle.width / 2)
        ball:setVelocity(newVx, -1)
    end)
end

function collider:handleBallBrick(ball, brick, contact)
    table.insert(self.queued, function()
        local vx, vy = ball.body:getLinearVelocity()

        -- Get normal from contact (points from brick to ball)
        local nx, ny = contact:getNormal()

        -- Reflect velocity using normal
        local rx, ry = vector.reflect(vx, vy, nx, ny)

        -- Set velocity with normalized direction * ball speed
        local nx2, ny2 = vector.normalize(rx, ry)
        ball.body:setLinearVelocity(nx2 * ball.speed, ny2 * ball.speed)

        brick.fixture:destroy()
        brick.body:destroy()
        brick.shouldRemove = true
    end)
end

function collider:handleBallBoundary(ball, name)
    table.insert(self.queued, function()
        local vx, vy = ball.body:getLinearVelocity()
        local x, y = ball.body:getPosition()
        local fudge = 2 -- Position correction factor
        local minVelocity = 50

        if name == "top" then
            ball.body:setPosition(x, y + fudge)
            vy = -vy
        elseif name == "left" then
            ball.body:setPosition(x + fudge, y)
            vx = -vx
        elseif name == "right" then
            ball.body:setPosition(x - fudge, y)
            vx = -vx
        end

        -- Clamp velocities so they never go near zero
        if math.abs(vx) < minVelocity then
            vx = (vx < 0) and -minVelocity or minVelocity
        end
        if math.abs(vy) < minVelocity then
            vy = (vy < 0) and -minVelocity or minVelocity
        end

        ball:setVelocity(vx, vy)
    end)
end

function collider:beginContact(a, b, coll)
    local ua, ub = a:getUserData(), b:getUserData()
    if not ua or not ub then return end

    local pair = ua.type .. "-" .. ub.type
    if pair == "ball-paddle" or pair == "paddle-ball" then
        self:handleBallPaddle(
            ua.type == "ball" and ua.obj or ub.obj,
            ua.type == "paddle" and ua.obj or ub.obj
        )
    elseif pair == "ball-brick" or pair == "brick-ball" then
        self:handleBallBrick(
            ua.type == "ball" and ua.obj or ub.obj,
            ua.type == "brick" and ua.obj or ub.obj,
            coll
        )
    elseif pair == "ball-boundary" or pair == "boundary-ball" then
        self:handleBallBoundary(
            ua.type == "ball" and ua.obj or ub.obj
        )

        local ball = ua.type == "ball" and ua.obj or ub.obj
        local boundary = ua.type == "boundary" and ua or ub
        self:handleBallBoundary(ball, boundary.name)
    end
end

function collider:flush()
    for _, fn in ipairs(self.queued) do fn() end
    self.queued = {}
end

return collider
