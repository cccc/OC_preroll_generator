#!/bin/sh
if [ $# -ne 4 ]; then
	echo "Usage: $0 <date> <persons> <title> <eventid>"
	exit 1
fi

OUTSVG="$4.svg"
OUTPNG="$4.png"
OUTTS="$4.ts"

sed -e s/\$id/"$1"/ -e s/\$personnames/"$2"/ -e s/\$title/"$3"/ preroll.svg > "$OUTSVG" \
&& inkscape -e "$OUTPNG" "$OUTSVG"
rm -f "$OUTSVG"

ffmpeg -loop 1 -i "$OUTPNG" -ar 48000 -ac 1 -f s16le -i /dev/zero -ar 48000 -ac 1 -f s16le -i /dev/zero -map 0:0 -c:v mpeg2video -q:v 0 -aspect 16:9 -map 1:0 -map 2:0 -t 5 -f mpegts "$OUTTS"
rm -f "$OUTPNG"

if [ ! -f outro.ts ]; then
	inkscape -e "postroll.png" "postroll.svg"
	ffmpeg -loop 1 -i "postroll.png" -ar 48000 -ac 1 -f s16le -i /dev/zero -ar 48000 -ac 1 -f s16le -i /dev/zero -map 0:0 -c:v mpeg2video -q:v 0 -aspect 16:9 -map 1:0 -map 2:0 -t 5 -f mpegts "outro.ts"
	rm -f postroll.png
fi
