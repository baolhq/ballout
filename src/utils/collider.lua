local collider = {
    queued = {}, -- Queued callback events
    scene = nil, -- Reference to main screen
    blipSound = nil,
    shouldPlaySound = true,
}

function collider:setScene(scene)
    self.scene = scene
end

function collider:setBlipSound(sound)
    self.blipSound = sound
end

function collider:setMuted(muted)
    self.muted = muted
end

-- Handling ball colliding with brick, destroy brick and
-- increase score by 1
function collider:handleBallBrick(ball, brick)
    table.insert(self.queued, function()
        brick.fixture:destroy()
        brick.body:destroy()
        brick.shouldRemove = true

        if self.scene then
            ball.speed = math.min(ball.speed + ball.accel, ball.maxSpeed)
            self.scene.score = self.scene.score + 1
        end

        if self.shouldPlaySound then self.blipSound:play() end
    end)
end

-- Handling ball colliding with paddle, slightly adjust its
-- velocity whether it hits the left or right side of the paddle.
function collider:handleBallPaddle(ball, paddle, coll)
    table.insert(self.queued, function()
        local bvx, bvy = ball.body:getLinearVelocity()
        local px, py = paddle.body:getPosition()
        local x1, _ = coll:getPositions()
        local adjust = 200

        if x1 < px then
            bvx = bvx - adjust
        else
            bvx = bvx + adjust
        end

        ball:setVelocity(bvx, bvy)

        if self.shouldPlaySound then self.blipSound:play() end
    end)
end

function collider:beginContact(a, b, coll)
    local ua, ub = a:getUserData(), b:getUserData()
    if not ua or not ub then return end

    local pair = ua.type .. "-" .. ub.type
    local ball = ua.type == "ball" and ua.obj or ub.obj
    local brick = ua.type == "brick" and ua.obj or ub.obj
    local paddle = ua.type == "paddle" and ua.obj or ub.obj

    if pair == "ball-brick" or pair == "brick-ball" then
        self:handleBallBrick(ball, brick)
    elseif pair == "ball-paddle" or pair == "paddle-ball" then
        self:handleBallPaddle(ball, paddle, coll)
    end
end

function collider:flush()
    for _, fn in ipairs(self.queued) do fn() end
    self.queued = {}
end

return collider
