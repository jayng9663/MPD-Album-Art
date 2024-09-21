#!/bin/bash

ALBUM="/tmp/album_cover.png"
ALBUM_SIZE="350"
EMB_ALBUM="/tmp/album_cover_embedded.png"
MPC_CMD="mpc"
#BACKUP_ALBUM="$HOME/.ncmpcpp/backup_album.png"
MUSIC_DIR="$HOME/Music/"

#Download from MusicBrainz
DOWNLOAD_FROM_INTERNET=1
OPTIONS=1
ACOUSTID_API="DVTYRxcWDe"
ONLINE_ALBUM="/tmp/online_album.png"

file="$MUSIC_DIR$($MPC_CMD --format %file% current)"
album="${file%/*}"

urlencode() {
  echo -n "$1" | perl -MURI::Escape -ne 'print uri_escape($_)'
}

if ! { [ -z "$($MPC_CMD --format %file% current)" ] || [ ! -d "$album" ]; }; then
  if ! ffmpeg -loglevel error -y -i "$file" -an -vcodec copy "$EMB_ALBUM" 2>/dev/null; then
    art=$(find "$album" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) | grep -i -m 1 -E "front|cover")
  else
    art="$EMB_ALBUM"
  fi
fi

case_1() {
  IFS='$' read -r album_name artist_name release_date <<< "$($MPC_CMD --format '%album%$%artist%$%date%' current)"

  if [ "$found_cover_art" = false ] && [ -n "$album_name" ] && [ -n "$artist_name" ]; then
    album_name=$(urlencode "$album_name")
    artist_name=$(urlencode "$artist_name")
    elease_date=$(urlencode "$release_date")
    id=$(wget -qO- "https://musicbrainz.org/ws/2/release/?query=artist:${artist_name}%20release:${album_name}%20date:${release_date}&fmt=json" | jq -r '.releases[0].id // empty')
    if [ -n "$id" ]; then
      cover_art_url="http://coverartarchive.org/release/$id/front"
      mapfile -t status_codes < <(wget --spider -S "$cover_art_url" 2>&1 | grep "HTTP/" | awk '{print $2}')
      if [ ${#status_codes[@]} -eq 0 ]; then
        break
      else
        for code in "${status_codes[@]}"; do
          case "$code" in
            404 | 503)
                break
                ;;
            200)
                wget -q "$cover_art_url" -O "$ONLINE_ALBUM"
                art="$ONLINE_ALBUM"
                found_cover_art=true
                break
                ;;
          esac
        done
      fi
    fi
  fi
}

case_2() {
  fpcalc=$(fpcalc "$file")
  duration=$(echo "$fpcalc" | grep "DURATION" | cut -d'=' -f2 | xargs)
  fingerprint=$(echo "$fpcalc" | grep "FINGERPRINT" | cut -d'=' -f2 | xargs)

  if [ "$found_cover_art" = false ] && [ -n "$duration" ] && [ -n "$fingerprint" ] && [ -n "$ACOUSTID_API" ]; then
    duration=$(urlencode "$duration")
    fingerprint=$(urlencode "$fingerprint")
    response=$(wget -qO- "https://api.acoustid.org/v2/lookup?client=$ACOUSTID_API&meta=releaseids&duration=$duration&fingerprint=$fingerprint")
    ids=($(echo "$response" | jq -r '.results[0].releases? | .[].id // empty'))
    for id in "${ids[@]}"; do
      cover_art_url="http://coverartarchive.org/release/$id/front"
      wget -q --spider "$cover_art_url"
      if [ $? -eq 0 ]; then
        wget -q "$cover_art_url" -O "$ONLINE_ALBUM"
        found_cover_art=true
        art="$ONLINE_ALBUM"
        break
      fi
    done
  fi
}

if [ -z "$art" ] && [ "$DOWNLOAD_FROM_INTERNET" -eq 1 ]; then
found_cover_art=false
case $OPTIONS in
  1)
    case_1
    case_2
    ;;

  2)
    case_2
    case_1
    ;;

  3)
    case_1
    ;;

  *)
    break
    ;;
esac
fi

if [ -z "$art" ]; then
  art="$BACKUP_ALBUM"
fi

convert +debug "$art" -resize "${ALBUM_SIZE}x${ALBUM_SIZE}^" -gravity center -crop "${ALBUM_SIZE}x${ALBUM_SIZE}+0+0" +repage "$ALBUM"

exit 0
