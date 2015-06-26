#!/bin/sh
if [ $# -ne 3 ]; then
	echo "Usage: $0 <date> <persons> <title>"
	exit 1
fi

OUTSVG="$1.svg"
OUTPNG="$1.png"

sed -e s/\$id/"$1"/ -e s/\$personnames/"$2"/ -e s/\$title/"$3"/ preroll.svg > "$OUTSVG" \
&& inkscape -e "$OUTPNG" "$OUTSVG"
rm -f "$OUTSVG"

if [ ! -f postroll.png ]; then
	inkscape -e "postroll.png" "postroll.svg"
fi
