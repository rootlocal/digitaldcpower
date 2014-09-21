# makefile for windows
all: ddcp-script-ttyinit-win.exe ddcp-script-getval-win.exe ddcp-script-setval-win.exe
#-------------------
ddcp-script-setval-win.exe: ddcp-script-setval-win.c
	gcc -Wall -o ddcp-script-setval-win ddcp-script-setval-win.c
#
ddcp-script-getval-win.exe: ddcp-script-getval-win.c
	gcc -Wall -o ddcp-script-getval-win ddcp-script-getval-win.c
#
ddcp-script-ttyinit-win.exe: ddcp-script-ttyinit-win.c
	gcc -Wall -o ddcp-script-ttyinit-win ddcp-script-ttyinit-win.c
#-------------------
clean:
	rm -f *.o ddcp-script-ttyinit-win.exe ddcp-script-getval-win.exe ddcp-script-setval-win.exe
#-------------------
