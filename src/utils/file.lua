local consts = require("src/consts/consts")

local file = {}

-- Save only five highest scores
function file.saveScores(scores)
    -- Sort to keep the top five
    table.sort(scores, function(a, b)
        return a > b
    end)

    -- Build the list to save
    local lines = {}
    for i = 1, math.min(5, #scores) do
        table.insert(lines, scores[i])
    end

    local content = table.concat(lines, "\n")
    love.filesystem.write(consts.SAVE_PATH, content)
end

-- Load scores from save file
function file.loadScores()
    local res = {}

    if love.filesystem.getInfo(consts.SAVE_PATH) then
        for line in love.filesystem.lines(consts.SAVE_PATH) do
            table.insert(res, line)
        end
    end

    return res
end

return file
