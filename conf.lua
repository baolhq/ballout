local consts = require("src/consts/consts")
local file = require("src/utils/file")

-- Setup initial stuff
function love.conf(t)
    local configs = file.loadConfigs()
    print(configs)

    t.window.width = consts.WINDOW_WIDTH
    t.window.height = consts.WINDOW_HEIGHT
    t.window.msaa = 4
end
