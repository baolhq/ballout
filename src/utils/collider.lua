local ball = require("src/models/ball")

local collider = {
    queued = {},  -- Queued callback events
    screen = nil, -- Reference to main screen
}

function collider:setScreen(screen)
    self.screen = screen
end

function collider:handleBallBrick(ball, brick)
    table.insert(self.queued, function()
        brick.fixture:destroy()
        brick.body:destroy()
        brick.shouldRemove = true

        if self.screen then
            ball.speed = ball.speed + 20
            self.screen.score = self.screen.score + 1
        end
    end)
end

function collider:beginContact(a, b)
    local ua, ub = a:getUserData(), b:getUserData()
    if not ua or not ub then return end

    local pair = ua.type .. "-" .. ub.type
    if pair == "ball-brick" or pair == "brick-ball" then
        self:handleBallBrick(
            ua.type == "ball" and ua.obj or ub.obj,
            ua.type == "brick" and ua.obj or ub.obj
        )
    end
end

function collider:flush()
    for _, fn in ipairs(self.queued) do fn() end
    self.queued = {}
end

return collider
