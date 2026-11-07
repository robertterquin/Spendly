#!/bin/sh
# Renders screens.html to ridetrack-screens.png (1800x1240) with headless Chrome.
cd "$(dirname "$0")"
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu --hide-scrollbars \
  --window-size=1800,1240 --screenshot="$PWD/ridetrack-screens.png" "file://$PWD/screens.html"
