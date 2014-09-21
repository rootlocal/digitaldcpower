# makefile for digitial dc power supply, written by guido socher
MCU=atmega8
DUDECPUTYPE=m8
# === Edit this and enter the correct device/com-port:
# linux (plug in the avrusb500 and type dmesg to see which device it is):
LOADCMD=avrdude -P /dev/ttyUSB0

# mac (plug in the programer and use ls /dev/tty.usbserial* to get the name):
#LOADCMD=avrdude -P /dev/tty.usbserial-A9006MOb

# windows (check which com-port you get when you plugin the avrusb500):
#LOADCMD=avrdude -P COM4

# All operating systems: if you have set the default_serial paramter 
# in your avrdude.conf file correctly then you can just use this
# and you don't need the above -P option:
#LOADCMD=avrdude
# === end edit this
#
LOADARG=-p $(DUDECPUTYPE) -c stk500v2 -e -U flash:w:


CC=avr-gcc
OBJCOPY=avr-objcopy
# optimize for size:
CFLAGS=-g -mmcu=$(MCU) -Wall -W -Os -mcall-prologues
# #-------------------
.PHONY: test_lcd test_dac all main ddcp-script
#
all: main.hex test_lcd.hex test_dac.hex
#
#ddcp-script: ddcp-script-setval ddcp-script-getval ddcp-script-ttyinit
#
main: main.hex 
#
test_lcd: test_lcd.hex
	echo "OK"
#
test_dac: test_dac.hex
	echo "OK"
#
#ddcp-script-setval: ddcp-script-setval.c
#	gcc -Wall -o ddcp-script-setval ddcp-script-setval.c
#ddcp-script-getval: ddcp-script-getval.c
#	gcc -Wall -o ddcp-script-getval ddcp-script-getval.c
#ddcp-script-ttyinit: ddcp-script-ttyinit.c
#	gcc -Wall -o ddcp-script-ttyinit ddcp-script-ttyinit.c
#-------------------
size:
	avr-size *.elf
help: 
	@echo "Usage: make help"
	@echo "       Print this help"
	@echo " "
	@echo "Usage: make all|load|rdfuses|fuses"
	@echo "       program using the avrdude programmer"
	@echo " "
	@echo "Usage: make clean"
	@echo "       delete all generated files"
	@echo "Test programs:"
	@echo "Usage: make test_lcd|load_test_lcd|test_dac|load_test_dac"
	@echo "       compile and load test programs"
	@echo "Usage: make ddcp-script-ttyinit"
	@echo "       compile unix program to set serial line speed such that one can use scripts to change settings"
#-------------------
main.hex: main.elf 
	$(OBJCOPY) -R .eeprom -O ihex main.elf main.hex 
	avr-size main.elf
	@echo " "
	@echo "Expl.: data=initialized data, bss=uninitialized data, text=code"
	@echo " "
main.elf: main.o dac.o lcd.o analog.o kbd.o uart.o
	$(CC) $(CFLAGS) -o main.elf -Wl,-Map,main.map main.o dac.o lcd.o analog.o kbd.o uart.o
main.o: main.c dac.h kbd.h lcd.h lcd_hw.h analog.h hardware_settings.h uart.h
	$(CC) $(CFLAGS) -Os -c main.c 
#-------------------
test_lcd.hex: test_lcd.elf 
	$(OBJCOPY) -R .eeprom -O ihex test_lcd.elf test_lcd.hex 
test_lcd.elf: test_lcd.o lcd.o kbd.o
	$(CC) $(CFLAGS) -o test_lcd.elf -Wl,-Map,test_lcd.map test_lcd.o lcd.o kbd.o
test_lcd.o: test_lcd.c lcd.h lcd_hw.h kbd.h
	$(CC) $(CFLAGS) -Os -c test_lcd.c
#-------------------
test_dac.hex: test_dac.elf 
	$(OBJCOPY) -R .eeprom -O ihex test_dac.elf test_dac.hex 
test_dac.elf: test_dac.o lcd.o kbd.o dac.o
	$(CC) $(CFLAGS) -o test_dac.elf -Wl,-Map,test_dac.map test_dac.o lcd.o kbd.o dac.o
test_dac.o: test_dac.c lcd.h lcd_hw.h kbd.h dac.h
	$(CC) $(CFLAGS) -Os -c test_dac.c
#-------------------
lcd.o : lcd.c lcd.h lcd_hw.h
	$(CC) $(CFLAGS) -Os -c lcd.c
#-------------------
analog.o : analog.c analog.h hardware_settings.h
	$(CC) $(CFLAGS) -Os -c analog.c
#-------------------
dac.o : dac.c dac.h 
	$(CC) $(CFLAGS) -Os -c dac.c
#-------------------
kbd.o : kbd.c kbd.h 
	$(CC) $(CFLAGS) -Os -c kbd.c
#-------------------
uart.o : uart.c uart.h 
	$(CC) $(CFLAGS) -Os -c uart.c
#-------------------
load: main.hex
	$(LOADCMD) $(LOADARG)main.hex
#
load_test_lcd: test_lcd.hex
	$(LOADCMD) $(LOADARG)test_lcd.hex
#
load_test_dac: test_dac.hex
	$(LOADCMD) $(LOADARG)test_dac.hex
#
#-------------------
# fuse byte settings:
#  Atmel AVR ATmega8 
#  Fuse Low Byte      = 0xe1 (1MHz internal), 0xe4 (8MHz internal)
#  Fuse Low Byte with BOD  = 0xa1 (1MHz internal), 0xa4 (8MHz internal)
#  Fuse High Byte     = 0xd9 
#  Factory default is 0xe1 for low byte and 0xd9 for high byte
# Check this with make rdfuses
rdfuses:
	$(LOADCMD) -p $(DUDECPUTYPE) -c stk500v2 -v -q
# use internal RC oscillator 8 Mhz (lf=0xe4 hf=0xd9)
fuses:
	$(LOADCMD) -p  $(DUDECPUTYPE) -c stk500v2 -u -v -U lfuse:w:0xa4:m
	$(LOADCMD) -p  $(DUDECPUTYPE) -c stk500v2 -u -v -U hfuse:w:0xd9:m
fuse:
	$(LOADCMD) -p  $(DUDECPUTYPE) -c stk500v2 -u -v -U lfuse:w:0xa4:m
	$(LOADCMD) -p  $(DUDECPUTYPE) -c stk500v2 -u -v -U hfuse:w:0xd9:m
#-------------------
clean:
	rm -f *.o *.map *.elf test*.hex main.hex ddcp-script-ttyinit ddcp-script-getval ddcp-script-setval
#-------------------
