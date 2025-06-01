local res = require("src/consts/res")

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
    love.filesystem.write(res.SAVE_PATH, content)
end

-- Load scores from save file
function file.loadScores()
    local scores = {}

    if love.filesystem.getInfo(res.SAVE_PATH) then
        for line in love.filesystem.lines(res.SAVE_PATH) do
            table.insert(scores, tonumber(line))
        end
    end

    return scores
end

-- Save game configurations
function file.saveConfigs(configs)
    local lines = {}
    for k, v in pairs(configs) do
        table.insert(lines, k .. "=" .. tostring(v))
    end

    local content = table.concat(lines, "\n")
    love.filesystem.write(res.CONFIG_PATH, content)
end

-- Load game configurations
function file.loadConfigs()
    local configs = {}

    if love.filesystem.getInfo(res.CONFIG_PATH) then
        for line in love.filesystem.lines(res.CONFIG_PATH) do
            -- Split each config by the `=` sign
            local k, v = line:match("([^=]+)=([^=]+)")
            configs[k] = v
        end
    end

    return configs
end

return file
