#!/bin/sh
# Compatibility entry point: clipboard actions now live in the shell widget.
exec "$(dirname "$0")/widget.sh" clipboard open
