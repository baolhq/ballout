local colors    = require("src/consts/colors")
local consts    = require("src/consts/consts")
local res       = require("src/consts/res")
local collider  = require("src/utils/collider")
local drawer    = require("src/utils/drawer")
local file      = require("src/utils/file")

local ball      = require("src/models/ball")
local brick     = require("src/models/brick")
local paddle    = require("src/models/paddle")

local mainScene = {
    assets = {},
    actions = {},
    configs = {},
    world = {},
    bricks = {},
    boundaries = {},
    highScores = {},
    score = 0,
    scoreSaved = false, -- Prevent saving multiple times
    isPaused = false,
    isGameOver = false,
}

-- Initialize scene boundaries that cause the ball to bounces back
function mainScene:initBoundaries()
    local function createBoundary(x, y, width, height)
        local body = love.physics.newBody(self.world, x, y, "static")
        local shape = love.physics.newRectangleShape(width, height)
        local fixture = love.physics.newFixture(body, shape)
        return { body = body, shape = shape, fixture = fixture }
    end

    local w, h = consts.WINDOW_WIDTH, consts.WINDOW_HEIGHT

    self.boundaries.top = createBoundary(w / 2, 5, w, 1)
    self.boundaries.left = createBoundary(5, h / 2, 1, h)
    self.boundaries.right = createBoundary(w - 5, h / 2, 1, h)
end

-- Initialize main scene, load resources and setup physics
function mainScene:load(actions, assets, configs)
    self.actions = actions
    self.assets = assets
    self.configs = configs

    self.score = 0
    self.highScores = file.loadScores()
    self.scoreSaved = false
    self.isGameOver = false
    self.world = love.physics.newWorld(0, 0, true)

    -- Set collision handlers and references
    collider:setBlipSound(self.assets.blipSound)
    if self.configs.music ~= nil then
        collider.shouldPlaySound = self.configs.music
    end

    collider:setScene(self)
    self.world:setCallbacks(function(a, b, coll)
        collider:beginContact(a, b, coll)
    end, function() end)

    -- Initialize game objects
    self:initBoundaries()
    paddle:init(self.world)
    ball:init(self.world)

    if self.configs.diff then
        ball:changeDifficulty(self.configs.diff)
    end

    -- Load brick sprites here to reduce loads
    local brickSprite = love.graphics.newImage(res.BRICK_SPR)

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
            local b = brick.new(self.world, x, y, brickSprite)
            table.insert(self.bricks, b)
        end
    end

    if configs.music ~= false then
        self.assets.bgSound:play()
    end
end

-- Unload game resources
function mainScene:unload()
    self.assets.bgSound:stop()

    if paddle.destroy then paddle:destroy() end
    if ball.destroy then ball:destroy() end

    for _, b in ipairs(self.bricks) do
        if b.body and b.body.destroy then
            b.body:destroy()
        end
    end
    self.bricks = {}

    for _, b in ipairs(self.boundaries) do
        if b.body and b.body.destroy then
            b.body.destroy()
        end
    end
    self.boundaries = {}

    if self.world and self.world:destroy() then
        self.world:destroy()
    end
    self.world = nil
end

-- Listen to single keypress events
function mainScene:keypressed(key)
    if key == "escape" then
        self:unload()
        self.actions.switchScene("title")
    elseif key == "space" then
        self.isPaused = not self.isPaused
    elseif key == "return" and self.isGameOver then
        self:unload()
        self:load(self.actions, self.assets, self.configs)
    end
end

-- Handling game over logics
function mainScene:gameOver()
    self.assets.bgSound:stop()
    self.isPaused = false
    self.isGameOver = true

    -- Save new highscore
    if not self.scoreSaved then
        table.insert(self.highScores, self.score)
        table.sort(self.highScores, function(a, b)
            return a > b
        end)

        while #self.highScores > 5 do
            table.remove(self.highScores)
        end
        file.saveScores(self.highScores)
        self.scoreSaved = true
    end
end

-- Update scene states, ball velocity and paddle movements
function mainScene:update(dt)
    -- Stop physics update on game over or paused
    if not (self.isGameOver or self.isPaused) then self.world:update(dt) end

    -- Moves with arrow keys being held
    local direction = 0
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        direction = direction - 1
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        direction = direction + 1
    end

    paddle:move(direction)
    ball:update(dt)

    -- Game over if the ball fall off scene
    local _, by = ball.body:getPosition()
    if by > consts.WINDOW_HEIGHT then
        self:gameOver()
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

---Draw main scene overlays
---@param bgHeight number
---@param headerText string
---@param subTexts table
local function drawOverlay(bgHeight, headerText, subTexts)
    love.graphics.setColor(colors.SLATE_800)
    local bgY = (love.graphics.getHeight() - bgHeight) / 2
    love.graphics.rectangle("fill", 0, bgY, consts.WINDOW_WIDTH, bgHeight)

    local headerFont = drawer:getFont(res.MAIN_FONT, consts.FONT_HEADER_SIZE)
    love.graphics.setColor(colors.SLATE_100)
    drawer:drawCenteredText(headerText, headerFont, 0, subTexts[1].y - 30)

    local subFont = drawer:getFont(res.MAIN_FONT, consts.FONT_SUB_SIZE)
    love.graphics.setColor(colors.SLATE_300)
    for _, textInfo in ipairs(subTexts) do
        drawer:drawCenteredText(textInfo.text, subFont, 0, textInfo.y)
    end
end

-- Draw main scene with inlay score in the background
function mainScene:draw()
    love.graphics.clear(colors.SLATE_100)

    -- Draw score
    love.graphics.setColor(colors.SLATE_300)
    local scoreFont = drawer:getFont(res.MAIN_FONT, consts.FONT_HEADER_SIZE)
    drawer:drawCenteredText(self.score, scoreFont, 0, 0)

    -- Draw ball and paddle
    paddle:draw()
    ball:draw()

    -- Draw bricks grid
    for _, v in ipairs(self.bricks) do
        brick.draw(v)
    end

    -- Draw paused indicator
    if self.isPaused then
        drawOverlay(140, "PAUSED", {
            { text = "PRESS <SPACE> TO RESUME", y = 28 },
        })
    end

    -- Draw game over text and score
    if self.isGameOver then
        drawOverlay(140, "GAME OVER", {
            { text = "YOUR SCORE: " .. self.score, y = 24 },
            { text = "PRESS <ENTER> TO RESTART",   y = 48 },
        })
    end
end

return mainScene
