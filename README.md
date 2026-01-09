# MPD-album-art
A simple bash shell script to show MPD album art in the terminal.<br />
In Ver 2.0+, it will now download the album from musicbrainz using wget automatically.

## Update log
- V1.0 First commit
- V2.0 Added `Download From Internet` from musicbrainz using `wget`.
- V2.1 Optimize the code
- V2.2 Optimize the code, Added search by fingerprint and search method priorit.
- V3.0 Optimize the code, Added new search method priorit (OPTIONS=4) and **Searching score**.
- V4.0 Added password support for `mpc`, added support for systemd (no more relied on `ncmpcpp`).
- V5.0 Refactored core logic into modular functions, improved embedded album art extraction with ffmpeg, enhanced fallback mechanisms, streamlined API calls for MusicBrainz and AcoustID, and fixed PID handling for album viewer updates.

## Cover Art Priority Order (Highest to Lowest):
- Embedded Album Art in Music File
- Cover Art in Album Directory
- Online Album Art (if `DOWNLOAD_FROM_INTERNET` enable)
- Backup Album Art (Optional)
- Exit if No Cover Art Available

## Required
- `mpc`
- `ncmpcpp` (If not using Systemd)
- `ffmpeg`
- `imagemagick`
- `img2sixel/kitty`
- `wget` (If using download from internet option)
- `fpcalc` (If using fingerprint method search for download from internet option)

## Install
Simply put the mpd-album-art.sh and mpd-album-art-bg.sh to the `.mpd` directory.

Choose one for the trigger point (Trigger mpd-album-art-bg.sh when song has changed)
1. **(Recommend)** If using systemd for trigger point, put the mpd-album-art.service into `/home/USER/.config/systemd/user/` and run `systemctl --user start mpd-album-art.service`, `systemctl --user enable mpd-album-art.service` if want it to autostart eveytime you login.
2. If using ncmcpp for trigger point, add the code below to the ncmpcpp `config` to make it execute the script each time the song changes.
```
execute_on_song_change = "~/.ncmpcpp/mpd-album-art-bg.sh > /dev/null 2>&1 &"
```

## Use
Simply run the `album.sh` in any terminal which supports img2sixel.

## Config
- Backup album: To use a backup album, set the BACKUP_ALBUM variable in `mpd-album-art-bg.sh` to the backup image full path.
- Album size: To change the album display size, change the ALBUM_SIZE variable in `mpd-album-art-bg.sh` to the px you want. It will automatically centers the album art and fills any remaining space with transparency (alpha channel) when the album art is smaller than the target display (ALBUM_SIZE) size.
- Download from internet: By default it's enabled, to disable change DOWNLOAD_FROM_INTERNET variable in `mpd-album-art-bg.sh` to another number.
- Download from internet search method priority , 1 = use Case 1 if not found use Case 2; 2 = use Case 2 if not found use Case 1. 3 = only use Case 1; 4 = only use Case 2 (Default is 2) 1-4: <br />
1| Case 1: Search via album name, artist name and the release date  <br />
2| Case 2: Search via fingerprint (AcoustID)  <br />
Recommend to use mode 2 or 4 if instlled `fpcalc`, since fingerprint usually get a more precise result.
- Download from internet Searching score (Default is 90) 0-100, only entries with a score equal to or higher than the selected value will be considered. The "searching score" represents a numerical value indicating how closely an entry matches the search query. (this is only for Case 1)

## Screenshot
![alt text](https://i.imgur.com/9Xl59k1.png)
![alt text](https://i.imgur.com/tHgHVVR.png)
