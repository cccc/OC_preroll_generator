#!/bin/sh
if [ $# -ne 5 ]; then
	echo "Usage: $0 <date> <persons> <title> <subtitle> <eventid>"
	exit 1
fi

OUTSVG="$5.svg"
OUTPNG="$5.png"
OUTTS="$5.ts"

sed -e s/\$id/"$1"/ -e s/\$personnames/"$2"/ -e s/\$title/"$3"/ -e s/\$subtitle/"$4"/ preroll.svg > "$OUTSVG" \
&& inkscape --export-filename "$OUTPNG" "$OUTSVG"
rm -f "$OUTSVG"

ffmpeg -loop 1 -i "$OUTPNG" -ar 48000 -ac 1 -f s16le -i /dev/zero -ar 48000 -ac 1 -f s16le -i /dev/zero -map 0:0 -c:v mpeg2video -q:v 0 -aspect 16:9 -map 1:0 -map 2:0 -t 5 -f mpegts "$OUTTS"
rm -f "$OUTPNG"

if [ ! -f outro.ts ]; then
	inkscape --export-filename "postroll.png" "postroll.svg"
	ffmpeg -loop 1 -i "postroll.png" -ar 48000 -ac 1 -f s16le -i /dev/zero -ar 48000 -ac 1 -f s16le -i /dev/zero -map 0:0 -c:v mpeg2video -q:v 0 -aspect 16:9 -map 1:0 -map 2:0 -t 5 -f mpegts "outro.ts"
	rm -f postroll.png
fi
