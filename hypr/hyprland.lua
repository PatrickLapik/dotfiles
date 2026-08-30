require("conf.keyboard")

require("conf.keybinding")

require("conf.decoration")

require("conf.environment")

require("conf.autostart")

hl.monitor({
    output = "DP-2",
    mode = "2560x1440@144",
})

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 0,
        layout = "dwindle",
    },
})

hl.curve("zap", { type = "spring", mass = 1, stiffness = 2000, dampening = 100 })
hl.curve("calm-zap", { type = "spring", mass = 1, stiffness = 1500, dampening = 100 })

hl.animation({ leaf = "workspaces", enabled = true, speed = 1, spring = "zap" })
hl.animation({ leaf = "windows", enabled = true, speed = 1, spring = "calm-zap" })
