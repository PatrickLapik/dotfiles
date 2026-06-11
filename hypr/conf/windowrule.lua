hl.window_rule({
    name = "\"Center Volume control applet\"",
    match = {
        title = "Volume Control",
    },
    float = true,
    min_size = "800 500",
})

hl.window_rule({
    name = "\"Open vesktop in workspace\"",
    match = {
        class = "vesktop",
    },
    workspace = "4 silent",
})

hl.window_rule({
    name = "\"Open Keepass in workspace\"",
    match = {
        class = "org.keepassxc.KeePassXC",
    },
    workspace = "9 silent",
})