#!/bin/bash

ALBUM="/tmp/album_cover.png"
ALBUM_SIZE="350"
EMB_ALBUM="/tmp/album_cover_embedded.png"
#BACKUP_ALBUM="$HOME/.ncmpcpp/backup_album.png"
MUSIC_DIR="$HOME/Music/"

file="$MUSIC_DIR$(mpc --format %file% current)"
album="${file%/*}"

if [ ! -d "$album" ]; then
  exit 1
fi

if ! ffmpeg -loglevel error -y -i "${file}" -an -vcodec copy "$EMB_ALBUM" 2>/dev/null; then
  art=$(find "$album" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) | grep -i -m 1 -E "front|cover")
else
  art="$EMB_ALBUM"
fi

[ -z "$art" ] && art="$BACKUP_ALBUM"
[ -z "$art" ] && exit 1

dimensions=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of default=noprint_wrappers=1:nokey=1 "$art")
width=$(echo "$dimensions" | head -n1)
height=$(echo "$dimensions" | tail -n1)

max_size_x=$(( width < ALBUM_SIZE ? width : ALBUM_SIZE ))
max_size_y=$(( height < ALBUM_SIZE ? height : ALBUM_SIZE ))

convert "$art" -resize "${max_size_x}x-1" -crop "${ALBUM_SIZE}x${ALBUM_SIZE}+0+0" -gravity center -background none -extent "${ALBUM_SIZE}x${ALBUM_SIZE}" "$ALBUM"
