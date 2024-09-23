#!/bin/bash

ALBUM="/tmp/album_cover.png"

function change_album {
  clear
  img2sixel "$ALBUM"
}

while inotifywait -q -q -e close_write "$ALBUM"; do
  change_album
done
