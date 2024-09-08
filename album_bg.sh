#!/bin/bash

ALBUM="/tmp/album_cover.png"
ALBUM_SIZE="350"
EMB_ALBUM="/tmp/album_cover_embedded.png"
#BACKUP_ALBUM="$HOME/.ncmpcpp/backup_album.png"
MUSIC_DIR="$HOME/Music/"

file="$MUSIC_DIR$(mpc --format %file% current)"
album="${file%/*}"

err=$(ffmpeg -loglevel 16 -y -i "${file}" -an -vcodec copy $EMB_ALBUM 2>&1)
if [ "$err" != "" ]; then
art=$(find "$album" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) | grep -i -m 1 -E "front|cover")
else
  art="$EMB_ALBUM"
fi

[ -z "$art" ] && art="$BACKUP_ALBUM"
[ -z "$art" ] && exit 1

width=$(ffmpeg -i "$art" 2>&1 | grep 'Stream' | grep -oP '\d{2,}x\d{2,}' | head -n1 | cut -d'x' -f1)
height=$(ffmpeg -i "$art" 2>&1 | grep 'Stream' | grep -oP '\d{2,}x\d{2,}' | head -n1 | cut -d'x' -f2)

max_size_x=$(( width < ALBUM_SIZE ? width : ALBUM_SIZE ))
max_size_y=$(( height < ALBUM_SIZE ? height : ALBUM_SIZE ))

convert "$art" -resize "${max_size_x}x-1" -crop "${ALBUM_SIZE}x${ALBUM_SIZE}+0+0" -gravity center -background none -extent "${ALBUM_SIZE}x${ALBUM_SIZE}" "$ALBUM"
