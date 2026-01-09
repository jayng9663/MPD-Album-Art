#!/bin/bash
# Created by jayng9663 (https://github.com/jayng9663)
# Project link: https://github.com/jayng9663/MPD-Album-Art
# Version V5.0
# Dependencies: mpc, ncmpcpp, ffmpeg, imagemagick, img2sixel/kitty, wget (If using download from internet option), fpcalc (If using fingerprint method search for download from internet option)

##Config##
ip=localhost
port=6600
password=
[ -n "$password" ] && password="$password@"

ALBUM="/tmp/album_cover.png"
ALBUM_SIZE="350"
EMB_ALBUM="/tmp/album_cover_embedded.png"
MPC_CMD="mpc -h $password$ip -p $port"
#BACKUP_ALBUM="$HOME/.ncmpcpp/backup_album.png"
MUSIC_DIR="$HOME/Music/"

#Download from MusicBrainz
DOWNLOAD_FROM_INTERNET=1
OPTIONS=2
ACOUSTID_API="DVTYRxcWDe"
SCORE=90
ONLINE_ALBUM="/tmp/online_album.png"

##Config END##

current_file=$($MPC_CMD --format %file% current)

PID_FILE="/tmp/album_viewer.pid"

if [ -z "$current_file" ]; then
	exit 1
fi

file="$MUSIC_DIR$current_file"
album="${file%/*}"

urlencode() {
	printf '%s' "$1" | jq -sRr @uri
}

json_get_release_ids_case1() {
	local artist="$1" album="$2" date="$3"
	local url="https://musicbrainz.org/ws/2/release/?query=artist:${artist}%20release:${album}%20date:${date}&fmt=json"
	wget -qO- "$url" | jq -r --arg score "$SCORE" '.releases? | .[] | select(.score >= ($score | tonumber)) | "\(.id)\n\(.score)"'
}

json_get_release_ids_case2() {
	local duration="$1" fingerprint="$2"
	local url="https://api.acoustid.org/v2/lookup?client=$ACOUSTID_API&meta=releaseids&duration=$duration&fingerprint=$fingerprint"
	wget -qO- "$url" | jq -r '.results[0].releases? | .[].id // empty'
}

download_cover_art() {
	local id="$1"
	local url="https://coverartarchive.org/release/$id/front"
	if wget -q --spider "$url"; then
		wget -q "$url" -O "$ONLINE_ALBUM"
		echo "$url"
		return 0
	else
		return 1
	fi
}

get_mpd_metadata() {
	$MPC_CMD --format '%album%$%artist%$%date%' current
}

extract_fpcalc_data() {
	local file="$1"
	fpcalc "$file"
}

parse_duration() {
	grep "DURATION" | cut -d'=' -f2 | xargs
}

parse_fingerprint() {
	grep "FINGERPRINT" | cut -d'=' -f2 | xargs
}

extract_embedded_album() {
	# Old way: check for embedded album via ffmpeg
	if ffmpeg -loglevel error -y -i "$file" -an -map 0:v:0 -vcodec copy "$EMB_ALBUM" 2>/dev/null; then
		if [ -s "$EMB_ALBUM" ]; then
			echo "$EMB_ALBUM"
			return 0
		fi
	fi
	return 1

	# Using mpc readpicture (SLOW IDK WHY)
	# $MPC_CMD readpicture "$current_file" > $EMB_ALBUM

	# mpc returns $current_file if no embedded album
	# read -r first_line < "$EMB_ALBUM"
	# if [[ "$first_line" != "$($MPC_CMD current)" ]]; then
	#     echo "$EMB_ALBUM"
	# fi
}

find_album_images() {
	find "$album" -maxdepth 1 -type f \
		\( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) 2>/dev/null
	}

choose_best_image() {
	local images=("$@")

	# Prefer front/cover/folder
	local art
	art=$(printf '%s\n' "${images[@]}" | grep -i -m 1 -E "front|cover|folder")

	if [ -n "$art" ]; then
		echo "$art"
	else
		# Otherwise pick first in sorted list
		printf '%s\n' "${images[@]}" | sort | head -n 1
	fi
}

if [ -n "$($MPC_CMD --format %file% current)" ] || [ ! -d "$album" ]; then
	if art=$(extract_embedded_album); then
		found_cover_art=true
	fi

		# Fallback: folder images if no embedded art
		if [ "$found_cover_art" = false ]; then
			mapfile -t images < <(find_album_images)
			if [ ${#images[@]} -gt 0 ]; then
				art=$(choose_best_image "${images[@]}")
				found_cover_art=true
			fi
		fi
fi

case_1() {
	IFS='$' read -r album artist date <<< "$(get_mpd_metadata)"

	if [ "$found_cover_art" = false ] && [ -n "$album" ] && [ -n "$artist" ]; then
		album=$(urlencode "$album")
		artist=$(urlencode "$artist")
		date=$(urlencode "$date")

		mapfile -t ids < <(json_get_release_ids_case1 "$artist" "$album" "$date")

		for ((i = 0; i < ${#ids[@]}; i+=2)); do
			id=${ids[i]}
			if url=$(download_cover_art "$id"); then
				using_url="$url"
				art="$ONLINE_ALBUM"
				found_cover_art=true
				break
			fi
		done
	fi
}

case_2() {
	if [ "$found_cover_art" = false ]; then
		fpcalc_data=$(extract_fpcalc_data "$file")
		duration=$(echo "$fpcalc_data" | parse_duration)
		fingerprint=$(echo "$fpcalc_data" | parse_fingerprint)

		if [ -n "$duration" ] && [ -n "$fingerprint" ] && [ -n "$ACOUSTID_API" ]; then
			duration=$(urlencode "$duration")
			fingerprint=$(urlencode "$fingerprint")

			mapfile -t ids < <(json_get_release_ids_case2 "$duration" "$fingerprint")

			for id in "${ids[@]}"; do
				if url=$(download_cover_art "$id"); then
					using_url="$url"
					art="$ONLINE_ALBUM"
					found_cover_art=true
					break
				fi
			done
		fi
	fi
}

if [ "$found_cover_art" = false ] && [ "$DOWNLOAD_FROM_INTERNET" -eq 1 ]; then
	case $OPTIONS in
		1) case_1; case_2 ;;
		2) case_2; case_1 ;;
		3) case_1 ;;
		4) case_2 ;;
	esac
fi

if [ "$found_cover_art" = false ]; then
	art="$BACKUP_ALBUM"
fi

if [ -z "$art" ]; then
	exit 1
fi

convert +debug "$art" -resize "${ALBUM_SIZE}x${ALBUM_SIZE}^" -gravity center -crop "${ALBUM_SIZE}x${ALBUM_SIZE}+0+0" +repage "$ALBUM"

valid_pids=()

while read -r PID; do
	[ -z "$PID" ] && continue

	if kill -0 "$PID" 2>/dev/null; then
		kill -USR1 "$PID"
		valid_pids+=("$PID")
	fi
done < "$PID_FILE"

printf "%s\n" "${valid_pids[@]}" > "$PID_FILE"
