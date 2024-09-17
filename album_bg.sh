#!/bin/bash

ALBUM="/tmp/album_cover.png"
ALBUM_SIZE="350"
EMB_ALBUM="/tmp/album_cover_embedded.png"
#BACKUP_ALBUM="$HOME/.ncmpcpp/backup_album.png"
MPC_CMD="mpc"
MUSIC_DIR="$HOME/Music/"
ONLINE_ALBUM="/tmp/online_album.png"

file="$MUSIC_DIR$($MPC_CMD --format %file% current)"
album="${file%/*}"

<<<<<<< HEAD
album_name=$($MPC_CMD --format '%album%' current)
artist_name=$($MPC_CMD --format '%artist%' current)
release_date=$($MPC_CMD --format '%date%' current)

urlencode() {
  echo -n "$1" | perl -MURI::Escape -ne 'print uri_escape($_)'
}

album_name=$(urlencode "$album_name")
artist_name=$(urlencode "$artist_name")
release_date=$(urlencode "$release_date")

if [ ! -d "$album" ]; then
  exit 1
fi

if ! ffmpeg -loglevel error -y -i "$file" -an -vcodec copy "$EMB_ALBUM" 2>/dev/null; then
  art=$(find "$album" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) | grep -i -m 1 -E "front|cover")
=======
err=$(ffmpeg -loglevel 16 -y -i "${file}" -an -vcodec copy $EMB_ALBUM 2>&1)
if [ "$err" != "" ]; then
art=$(find "$album" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) | grep -i -m 1 -E "front|cover")
>>>>>>> parent of c6a7888 (Fixed crash and improved the code)
else
  art="$EMB_ALBUM"
fi

if [ -z "$art" ]; then
  art="$BACKUP_ALBUM"

<<<<<<< HEAD
  id=$(wget -qO- "https://musicbrainz.org/ws/2/release/?query=artist:${album_name}%20release:${artist_name}%20date:${release_date}&fmt=json" | jq -r '.releases[0].id')
=======
width=$(ffmpeg -i "$art" 2>&1 | grep 'Stream' | grep -oP '\d{2,}x\d{2,}' | head -n1 | cut -d'x' -f1)
height=$(ffmpeg -i "$art" 2>&1 | grep 'Stream' | grep -oP '\d{2,}x\d{2,}' | head -n1 | cut -d'x' -f2)
>>>>>>> parent of c6a7888 (Fixed crash and improved the code)

  if [ "$id" != "null" ]; then
    cover_art_url="http://coverartarchive.org/release/$id/front"
    wget -q "$cover_art_url" -O "$ONLINE_ALBUM"
    art="$ONLINE_ALBUM"
  else
    exit 1
  fi
fi

convert "$art" -resize "${ALBUM_SIZE}x${ALBUM_SIZE}^" -gravity center -crop "${ALBUM_SIZE}x${ALBUM_SIZE}+0+0" +repage "$ALBUM"
