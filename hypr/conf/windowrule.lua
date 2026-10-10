hl.window_rule({
    name = "Center Volume control applet",
    match = {
        class = "org.pulseaudio.pavucontrol"
    },
    float = true,
    center = true,
    size = {"(monitor_w*0.5)", "(monitor_h*0.5)"}
})

hl.layer_rule({
    name = "quickshell-surface-animations",
    match = { namespace = "^quickshell$" },
    no_anim = true,
})
