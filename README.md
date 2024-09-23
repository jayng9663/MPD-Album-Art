# MPD-album-art
A simple bash shell script to show MPD album art in the terminal.<br />
In Ver 2.0+, it will now download the album from musicbrainz using wget automatically.

## Update log
- V1.0 First commit
- V2.0 Added `Download From Internet` from musicbrainz using `wget`.
- V2.1 Optimize the code
- V2.2 Optimize the code, Added search by fingerprint and search method priorit.
- V3.0 Optimize the code, Added new search method priorit (OPTIONS=4) and **Searching score**.

## Cover Art Priority Order (Highest to Lowest):
- Embedded Album Art in Music File
- Cover Art in Album Directory
- Online Album Art (if `DOWNLOAD_FROM_INTERNET` enable)
- Backup Album Art (Optional)
- Exit if No Cover Art Available

## Required
- `mpc`
- `ncmpcpp`
- `inotify-tools`
- `ffmpeg`
- `imagemagick`
- `img2sixel`
- `wget` (If using download from internet option)
- `fpcalc` (If using fingerprint method search for download from internet option)

## Install
Simply put the mpd-album-art.sh and mpd-album-art-bg.sh to the `.ncmpcpp` directory.

Then add to the ncmpcpp `config` to make it execute the script each time the song changes.
```
execute_on_song_change = "~/.ncmpcpp/mpd-album-art-bg.sh > /dev/null 2>&1 &"
```

## Use
Simply run the `album.sh` in any terminal which supports img2sixel.

## Config
- Backup album: To use a backup album, set the BACKUP_ALBUM variable in `mpd-album-art-bg.sh` to the backup image full path.
- Album size: To change the album display size, change the ALBUM_SIZE variable in `mpd-album-art-bg.sh` to the px you want. It will automatically centers the album art and fills any remaining space with transparency (alpha channel) when the album art is smaller than the target display (ALBUM_SIZE) size.
- Download from internet: By default it's enabled, to disable change DOWNLOAD_FROM_INTERNET variable in `mpd-album-art-bg.sh` to another number.
- Download from internet search method priority (Default is 1) 1-4: <br />
1| Search via album name, artist name and the release date  <br />
2| Search via fingerprint (AcoustID)  <br />
Recommend to use mode 1 or 3 (Only run method for those didn't instlled `fpcalc`)
- Download from internet Searching score (Default is 90) 0-100, only entries with a score equal to or higher than the selected value will be considered. The "searching score" represents a numerical value indicating how closely an entry matches the search query.

## Screenshot
![alt text](https://wiki.hkvfs.com/images/1/1b/Ncmcpp_with_album_art_example_1.png)
![alt text](https://wiki.hkvfs.com/images/9/99/Ncmcpp_album_art_example_2.png)
