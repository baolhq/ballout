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

function collider:handleBallBrick(ball, brick)
    table.insert(self.queued, function()
        local vx, vy = ball.body:getLinearVelocity()
        ball:setVelocity(-vx, -vy)
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

        if name == "top" then
            vy = -vy
            ball.body:setPosition(x, y + fudge)
        elseif name == "left" then
            vx = -vx
            ball.body:setPosition(x + 2, y)
        elseif name == "right" then
            vx = -vx
            ball.body:setPosition(x - 2, y)
        end

        ball:setVelocity(vx, vy)
    end)
end

function collider:beginContact(a, b)
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
            ua.type == "brick" and ua.obj or ub.obj
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
