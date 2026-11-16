#!/bin/bash
# Toggle region recording.
# First run: select a region and record. Second run: stop, convert to GIF, copy GIF to clipboard.

# If a recording is running, stop it; the first instance continues below and does the conversion.
if pkill -INT -x wf-recorder; then
    exit 0
fi

geom=$(slurp) || exit 0 # Escape in slurp cancels

dir=~/Videos
mkdir -p "$dir"
name="$dir/rec-$(date +%F_%H-%M-%S)"

notify-send -t 1500 "Recording" "Press Super+Shift+R to stop"
wf-recorder -g "$geom" -f "$name.mp4" || {
    notify-send "Recording failed"
    exit 1
}

notify-send -t 1500 "Converting to GIF…"
ffmpeg -loglevel error -y -i "$name.mp4" \
    -vf "fps=12,scale='min(720,iw)':-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
    "$name.gif" || {
    notify-send "GIF conversion failed" "$name.mp4"
    exit 1
}

# Extra lossy compression if gifsicle is installed (pacman -S gifsicle)
if command -v gifsicle >/dev/null; then
    gifsicle -O3 --lossy=80 -b "$name.gif"
fi

# Copy as a file reference: apps (Discord, browsers, file managers) paste it as an
# animated GIF upload, whereas raw image/gif clipboard data is ignored by most of them.
printf 'file://%s\n' "$name.gif" | wl-copy --type text/uri-list
notify-send "GIF copied to clipboard" "$name.gif"
