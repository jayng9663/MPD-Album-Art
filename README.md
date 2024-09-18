# MPD-album-art
A simple bash shell script to show MPD album art in the terminal.<br />
In Ver 2.0+, it will now download the album from musicbrainz using wget automatically.

## Update log
- V1.0 First commit
- V2.0 Added `Download From Internet` from musicbrainz using `wget`.
- V2.1 Optimize the code

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

## Install
Simply put the album.sh and album_bg.sh to the `.ncmpcpp` directory.

Then add to the ncmpcpp `config` to make it execute the script each time the song changes.
```
execute_on_song_change = "~/.ncmpcpp/album_bg.sh &"
```

## Use
Simply run the `album.sh` in any terminal which supports img2sixel.

## Config
- Backup album: To use a backup album, set the BACKUP_ALBUM variable in `album_bg.sh` to the backup image full path.
- Album size: To change the album display size, change the ALBUM_SIZE variable in `album_bg.sh` to the px you want. It will automatically centers the album art and fills any remaining space with transparency (alpha channel) when the album art is smaller than the target display (ALBUM_SIZE) size.
- Download from interent: By default it's enabled, to disable change DOWNLOAD_FROM_INTERNET variable in `album_bg.sh` to another number.

## Screenshot
![alt text](https://wiki.hkvfs.com/images/1/1b/Ncmcpp_with_album_art_example_1.png)
![alt text](https://wiki.hkvfs.com/images/9/99/Ncmcpp_album_art_example_2.png)
