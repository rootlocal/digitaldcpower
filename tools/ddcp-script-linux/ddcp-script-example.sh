#!/bin/sh
# Example showing how to control the tuxgraphics digital power supply
# by scripts.
if [ -z "$1" ]; then
	echo "USAGE: ddcp-script-example.sh /dev/ttyUSB0"
	echo "or     ddcp-script-example.sh /dev/ttyUSB1"
	exit 0;
fi
dev="$1"
# included the current directory to have access to the command
# ddcp-script-getval to make testing easier. Normally you would
# install ddcp-script-getval  in /usr/bin and then delete the
# line that sets the PATH
PATH="${PATH}:."
ddcp-script-ttyinit "$dev"
echo "current settings are:"
ddcp-script-getval "$dev"
echo "setting voltage to 3.3 V"
ddcp-script-setval "u=33" "$dev"
echo "new settings are:"
ddcp-script-getval "$dev"
echo "wait one sec, it takes a moment for the display values to adjust as they are polled in the avr software"
sleep 1
echo "print settings again:"
ddcp-script-getval "$dev"
