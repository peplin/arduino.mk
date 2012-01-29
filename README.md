# Read Me Rei Vilo fork
 

## Environmment

Mac OS X 10.7.2

Xcode 4.2.1

MPIDE 0023


## History

0- Fork from peplin-arduino.mk-d7bbeea

1- Added files

	ReadMe_ReiVilo.md

	References.txt

	Blink.pde


2- Added Xcode project

	Xcode project

	main makefile with switch to Arduino.mk or chipKIT.mk


3- Fixed `_BOARD_MEGA_` hard-coded in chipKIT.mk

* makefile: 

	`PARSE_BOARD` copied from Arduino.mk 

	`/dev/tty.usbmodem*` changed to `/dev/tty.usb*` 

* chipKIT.mk

	`BOARD = $(call PARSE_BOARD,$(BOARD_TAG),board)`


4- Serial port management

* Arduino.mk
    
	error-prone `stty` replaced by `screen`


5- Debug comments on makefiles

	cleaner commit
	`@echo " ---- debug comment ---- "`
	see issue #7    
    
    
6- Added LDSCRIPT value search    
    
	LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),ldscript)
	but unused afterwards
	seems to be required for link
    

7- Added EXTRA_LDFLAGS for linker

	EXTRA_LDFLAGS  = -T$(ARDUINO_CORE_PATH)/$(LDSCRIPT)
    
    
8- Library issue solved

	`ARDUINO_LIB_PATH` fixed

	was `= $(ARDUINO_SKETCHBOOK)/libraries`

	now `= $(ARDUINO_DIR)/hardware/pic32/libraries`

	more powerful clean

	info section added for debugging
      
                                  
## Results

Tested on both Xcode and Terminal, with local library foo and Wire

* Arduino Uno: ok
* chipKIT UNO32: ok



--------------------------

## 

© Rei VILO, 2010-2012
CC = BY NC SA
http://sites.google.com/site/vilorei/



## Boards

	BOARD_TAG.name

** pic32/boards.txt **

uno_pic32.name=chipKIT UNO32
mega_pic32.name=chipKIT MAX32
mega_usb_pic32.name=chipKIT MAX32-USB for Serial
cerebot_mx3ck.name=Cerebot MX3cK
cerebot_mx4ck.name=Cerebot MX4cK
cerebot_mx7ck.name=Cerebot MX7cK
cerebot32mx4.name=Cerebot 32MX4
cerebot32mx7.name=Cerebot 32MX7
mc_pic32_starterkit.name=Microchip PIC32 Starter kit
mc_pic32_ethernet_starterkit.name=Microchip PIC32 Ethernet Starter kit
mc_pic32_usb_starterkit.name=Microchip PIC32 USB Starter kit II
mc_pic32_explorer16.name=Microchip PIC32 Explorer 16
mikroe_multimedia.name=MirkoElektronika PIC32 Multimedia Board
mikroe_mikromedia.name=MirkoElektronika PIC32 mikroMedia Board
ubw32_mx460.name=Pic32 UBW32-MX460
ubw32_mx795.name=Pic32 UBW32-MX795
cui32.name=Pic32 CUI32-Development Stick

** Arduino **

uno.name=Arduino Uno
atmega328.name=Arduino Duemilanove or Nano w/ ATmega328
diecimila.name=Arduino Diecimila, Duemilanove, or Nano w/ ATmega168
mega2560.name=Arduino Mega 2560
mega.name=Arduino Mega (ATmega1280)
mini.name=Arduino Mini
fio.name=Arduino Fio
bt328.name=Arduino BT w/ ATmega328
bt.name=Arduino BT w/ ATmega168
lilypad328.name=LilyPad Arduino w/ ATmega328
lilypad.name=LilyPad Arduino w/ ATmega168
pro5v328.name=Arduino Pro or Pro Mini (5V, 16 MHz) w/ ATmega328
pro5v.name=Arduino Pro or Pro Mini (5V, 16 MHz) w/ ATmega168
pro328.name=Arduino Pro or Pro Mini (3.3V, 8 MHz) w/ ATmega328
pro.name=Arduino Pro or Pro Mini (3.3V, 8 MHz) w/ ATmega168
atmega168.name=Arduino NG or older w/ ATmega168
atmega8.name=Arduino NG or older w/ ATmega8