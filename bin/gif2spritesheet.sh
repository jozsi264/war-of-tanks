#!/bin/bash
#Convert animated gif to sprite sheet
#pass in animated gif get out png sprite sheet
convert $1 $1.png
convert `ls *.png` +append $1.png.result
rm *.png
mv $1.png.result $1.png
