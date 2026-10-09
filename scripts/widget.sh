#!/bin/sh
# Common entry point: widget.sh NAME [open|toggle|close], or widget.sh list
set -eu
widget_name=${1:-}
widget_action=${2:-toggle}
case "$widget_name" in ''|*[!a-z0-9-]*) echo "Usage: widget.sh NAME [open|toggle|close]" >&2; exit 2 ;; esac
case "$widget_action" in open|toggle|close) ;; *) echo "Unknown widget action: $widget_action" >&2; exit 2 ;; esac
script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
checkout_directory=$(dirname -- "$script_directory")
screen_name=$(hyprctl -j monitors 2>/dev/null | python3 -c 'import json,sys; print(next((m["name"] for m in json.load(sys.stdin) if m.get("focused")), ""))' 2>/dev/null) || screen_name=""
if [ "$widget_name" = list ]; then
    set -- call widgets list
else
    set -- call widgets "$widget_action" "$widget_name" "$screen_name"
fi
config_path="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
if quickshell ipc -p "$config_path" "$@"; then
    exit 0
fi
exec quickshell ipc -p "$checkout_directory/quickshell" "$@"
