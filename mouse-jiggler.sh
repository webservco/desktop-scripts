#!/bin/bash
#
# mouse-jiggler.sh: move the mouse pointer by one pixel at an interval, so that the session does not go idle
#
# Usage: mouse-jiggler.sh [seconds]   (default: 60); stop with Ctrl+C

DELAY=${1:-60}
while : ; do
    sleep $DELAY
    #X11
    # xdotool mousemove_relative 1 0
    # wayland
    ydotool mousemove -x -1 -y 0
done
