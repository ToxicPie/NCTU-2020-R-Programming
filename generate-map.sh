#!/bin/sh

if [ "$1" == "" ]; then
    echo "Usage: $0 <path_to_pngs> [FPS]" >&2
    exit 1
fi

if ! command -v ffmpeg &> /dev/null ; then
    echo "This script requires ffmpeg" >&2
    exit 2
fi

FPS=25
if [ "$2" != "" ]; then
    FPS="$2"
fi

# use a pixel format that most video players support
ffmpeg -framerate $FPS -i "$1/%3d.png" -c:v libx264 -pix_fmt yuv420p "$1-output.mp4" -y
ffmpeg -i "$1-output.mp4" -vf "fps=$FPS,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -framerate $FPS -loop -1 "$1-output.gif" -y
