#!/usr/bin/env zsh

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use
polybar-msg cmd quit
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
#this shows the bar on every monitor instead of just one
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload example &
  done
else
  polybar --reload example &
fi

echo "Bars launched..."
