#!/bin/bash

ALBUM="/tmp/album_cover.png"
PID_FILE="/tmp/album_viewer.pid"

# Append our PID to the global PID file
echo $$ >> "$PID_FILE"

# Cleanup PID in $PID_FILE
cleanup() {
	if [ -f "$PID_FILE" ]; then
		sed -i "\|^$$\$|d" "$PID_FILE"
	fi
	exit
}

trap cleanup EXIT INT TERM

# Ensure album file exists
[ ! -f "$ALBUM" ] && touch "$ALBUM"

if command -v kitty &>/dev/null && [ -n "$TMUX" ]; then
	DISPLAY_CMD="kitty +kitten icat --passthrough=tmux --align center"
elif command -v kitty &>/dev/null; then
	DISPLAY_CMD="kitty +kitten icat --align center"
elif command -v img2sixel &>/dev/null; then
	DISPLAY_CMD="img2sixel"
else
	echo "Error: neither kitty nor img2sixel is available."
	exit 1
fi

echo "Using display command: $DISPLAY_CMD"

change_album() {
	$DISPLAY_CMD "$ALBUM"
	if [ $? -ne 0 ]; then
		echo "Failed to update album display"
	fi
}

trap 'change_album' USR1

change_album

while true; do
	sleep infinity &
	wait $!
done


