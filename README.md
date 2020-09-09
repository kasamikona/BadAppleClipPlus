# Bad Apple!! for Sansa Clip+ (Rockbox Lua)

Bad Apple!! video player implemented in Lua for Rockbox, designed to run on the Sansa Clip+ MP3 player.

Video data assumes a 128x64 display with a 2px gap between visible regions.

## Files for playing:
- badapple.lua: main script, copy to player storage or SD card
- vid.mp3 (download in Releases): audio data, MP3 format, copy to main script location
- vid.bin (download in Releases): video data, display native format, copy to main script location

## Additional files:
- vidsrc.mp4 (not provided): 30fps video source, 2:1 aspect ratio
- vidextract.bat: extracts vidsrc.mp4 to frame images and vid.mp3, requires ffmpeg
- writedata.py: converts frame images to display native format, vid.bin
- vidframes: frame image target for vidextract/writedata

## Theory of operation:
Audio is played natively by the Rockbox MP3 codec.

Video data is stored at pre-dithered 1-bit-per-pixel, in native display order. It is dithered at 100fps.
The data is read from the file and blitted directly to the display.
Each frame is delayed approximately 1/100th of a second, which achieves rough speed sync, then frames are skipped to maintain time sync.
As the source data is only 30fps before dithering, these skips are not noticeable.
I wanted to do some kind of compression, but both ends of the process use strings to store the binary data, and Lua's string manipulation is too slow for this.

The Lua script also performs some extra functions like setting the display to maximum brightness, and clearing some settings to ensure the audio plays at the right speed/pitch.
