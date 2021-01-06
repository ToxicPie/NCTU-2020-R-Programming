#!/bin/sh

if [[ "$1" == "" || "$2" == "" ]]; then
    echo "Usage: $0 <path_to_left_plot> <path_to_left_plot> [FPS]" >&2
    exit 1
fi

if ! command -v ffmpeg &> /dev/null ; then
    echo "This script requires ffmpeg" >&2
    exit 2
fi

FPS=50
if [ "$3" != "" ]; then
    FPS="$3"
fi

ffmpeg -framerate $FPS -i "$1/plot%4d.png" "$1/out.mp4" -y
ffmpeg -framerate $FPS -i $"2/plot%4d.png" "$2/out.mp4" -y
ffmpeg -i "$1/out.mp4" -i "$2/out.mp4" -filter_complex hstack -c:v libx264 -pix_fmt yuv420p output.mp4 -y
ffmpeg -i output.mp4 -vf "fps=$FPS,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -framerate $FPS -loop -1 output.gif -y
