#!/bin/bash
# Created by jayng9663 (https://github.com/jayng9663)
# Project link: https://github.com/jayng9663/MPD-Album-Art

ip=localhost
port=6600
password=
wait_time=0.25
album_bg="./mpd-album-art-bg.sh"
pid_file="/tmp/mpd-album-art-bg.pid"
last_song=""
CMD="currentsong"

if [ -n "$password" ]; then
    CMD="password ${password}\n${CMD}"
fi

if [[ -f $pid_file ]]; then
    old_pid=$(cat $pid_file)
    if ps -p $old_pid > /dev/null; then
        echo "Killing previous instance with PID $old_pid"
        kill $old_pid
        sleep 1
    fi
fi

echo $$ > $pid_file

while true; do
    nc_output=$(echo -e "$CMD" | nc -N "$ip" "$port")
    playing_song=$(echo "$nc_output" | grep '^file:' | cut -d' ' -f2-)
    echo "$nc_output"
    if [[ "$last_song" != "$playing_song" && -n "$playing_song" ]]; then
        echo "Song changed: [$playing_song]"
        last_song="$playing_song"
        $album_bg
    fi

    sleep $wait_time
done
