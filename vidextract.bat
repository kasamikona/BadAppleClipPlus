@echo off
del /Q vidframes\*
del vid.mp3
ffmpeg -i vidsrc.mp4 -s 132x66 -sws_flags neighbor vidframes/frame%%04d.png
ffmpeg -i vidsrc.mp4 -q:a 0 -map a vid.mp3
pause