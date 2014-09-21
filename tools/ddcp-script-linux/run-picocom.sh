#!/bin/sh -x
echo "End picocom with C-A C-X"
ftdidev=`grep FTDI /proc/bus/usb/devices | wc -l`
if [ "$ftdidev" = "2" ]; then
	picocom -l -b 9600 /dev/ttyUSB1
else
	picocom -l -b 9600 /dev/ttyUSB0
fi
