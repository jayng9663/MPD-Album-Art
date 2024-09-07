#!/bin/bash

ALBUM="/tmp/album_cover.png"
BACKUP_ALBUM="$HOME/.ncmpcpp/backup_album.png"

function change_album {
  clear
  img2sixel "$ALBUM"
}

if [ ! -f "$ALBUM" ]; then
  cp "$BACKUP_ALBUM" "$ALBUM"
fi
while inotifywait -q -q -e close_write "$ALBUM"; do
  change_album
done
