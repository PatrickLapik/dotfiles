hl.bind("SUPER + RETURN", hl.dsp.exec_cmd('~/dotfiles/.settings/terminal.sh'))
hl.bind("SUPER + B", hl.dsp.exec_cmd('~/dotfiles/.settings/browser.sh'))
hl.bind("SUPER + E", hl.dsp.exec_cmd('~/dotfiles/.settings/filemanager.sh'))

hl.bind("SUPER + C", hl.dsp.window.close("activewindow"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("vesktop"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("hyprshot -m region --freeze"))
hl.bind("SUPER + F", hl.dsp.window.fullscreen("activewindow"))

hl.bind("SUPER + T", hl.dsp.window.float('activewindow'))
hl.bind("SUPER + H", hl.dsp.focus({ direction = 'left' }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = 'right' }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = 'up' }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = 'down' }))

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })


hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind("SUPER + G", hl.dsp.group.toggle())

-- Actions
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("~/dotfiles/hypr/scripts/toggle-animations.sh"))
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd("~/dotfiles/hypr/scripts/screenshot.sh"))
hl.bind("SUPER + Q", hl.dsp.exec_cmd("~/dotfiles/scripts/wlogout.sh"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("~/dotfiles/hypr/scripts/wallpaper.sh"))
hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd("~/dotfiles/hypr/scripts/wallpaper.sh select"))
hl.bind("SUPER + CTRL + RETURN", hl.dsp.exec_cmd("rofi -show drun -replace -i"))
hl.bind("SUPER + CTRL + H", hl.dsp.exec_cmd("~/dotfiles/hypr/scripts/keybindings.sh"))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("~/dotfiles/waybar/launch.sh"))
hl.bind("SUPER + CTRL + B", hl.dsp.exec_cmd("~/dotfiles/waybar/toggle.sh"))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("~/dotfiles/hypr/scripts/loadconfig.sh"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("~/dotfiles/scripts/cliphist.sh"))
hl.bind("SUPER + CTRL + T", hl.dsp.exec_cmd("~/dotfiles/waybar/themeswitcher.sh"))
hl.bind("SUPER + CTRL + S", hl.dsp.exec_cmd("~/dotfiles/apps/ML4W_Dotfiles_Settings-x86_64.AppImage"))
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("~/dotfiles/hypr/scripts/hyprshade.sh"))
hl.bind("SUPER + ALT + G", hl.dsp.exec_cmd("~/dotfiles/hypr/scripts/gamemode.sh"))

-- Workspaces
for i = 1, 10 do
    local key = i % 10
    local ws = i

    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = ws }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
end

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + CTRL + down", hl.dsp.focus({ workspace = "empty" }))

-- Passthrough SUPER KEY to Virtual Machine
hl.bind("SUPER + P", hl.dsp.submap("passthru"))
hl.define_submap("passthru", function()
    hl.bind("SUPER + Escape", hl.dsp.submap("reset"))
end)

-- Fn keys
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -q s +10%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -q s 10%-"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("qalculate-gtk"))
hl.bind("XF86Tools",
    hl.dsp.exec_cmd("alacritty --class dotfiles-floating -e ~/dotfiles/apps/ML4W_Dotfiles_Settings-x86_64.AppImage"))
