require("conf.keyboard")

require("conf.keybinding")

require("conf.decoration")

require("conf.environment")

require("conf.autostart")

require('conf.windowrule')

require('conf.cursors')

require("conf.monitors")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 0,
        layout = "dwindle",
    },
    input = {
        touchpad = {
            natural_scroll = true
        }
    },
})

hl.curve("zap", { type = "spring", mass = 1, stiffness = 2000, dampening = 100 })
hl.curve("calm-zap", { type = "spring", mass = 1, stiffness = 1500, dampening = 100 })

hl.animation({ leaf = "workspaces", enabled = true, speed = 1, spring = "zap" })
hl.animation({ leaf = "windows", enabled = true, speed = 1, spring = "calm-zap" })

hl.curve("panel-out-cubic", {
    type = "bezier",
    points = { { 1 / 3, 1 }, { 2 / 3, 1 } },
})
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1.6, bezier = "panel-out-cubic", style = "popin 0%" })

hl.curve("window-close", {
    type = "bezier",
    points = { { 0.65, 0 }, { 0.35, 1 } },
})
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "window-close", style = "popin 0%" })

hl.animation({ leaf = "fadeIn", enabled = false })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1, bezier = "window-close" })
