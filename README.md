# MPD-album-art
A simple bash shell script to show mpd album art in terminal

## Required
- `mpc`
- `ncmpcpp`
- `inotify-tools`
- `ffmpeg`
- `imagemagick`
- `img2sixel`

## Install
Simply put the album.sh and album_bg.sh to the `.ncmpcpp` directory.

Then add to the ncmpcpp `config` to make it execute the script each time the song changes.
```
execute_on_song_change = "~/.ncmpcpp/album_bg.sh"
```

## Use
Simply run the `album.sh` in any terminal which supports img2sixel.

## Config
To use a backup album, set $BACKUP_ALBUM variable in `album.sh` to the backup image full path.

## Screenshot
![alt text](https://wiki.hkvfs.com/images/1/1b/Ncmcpp_with_album_art_example_1.png)
![alt text](https://wiki.hkvfs.com/images/9/99/Ncmcpp_album_art_example_2.png)
