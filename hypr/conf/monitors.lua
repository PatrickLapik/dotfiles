-- Register rules at config load so HDMI starts mirrored and keeps its rule
-- across reloads. Changing it from monitor.added can remove a wl_output
-- while clients are binding to it, causing fatal Wayland protocol errors.
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

hl.monitor({
    output = "DP-2",
    mode = "2560x1440@144",
    position = "auto",
    scale = 1,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "preferred",
    position = "auto",
    scale = 1,
    mirror = "eDP-1",
})
