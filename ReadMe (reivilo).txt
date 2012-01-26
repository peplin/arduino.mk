
    MPIDE 0023 on Xcode 4.2
    ----------------------------------
    MPIDE 0023 Arduino and chipKIT sketches on Xcode 4.2


	© Rei VILO, 2012
	CC = BY NC SA

    http://sites.google.com/site/vilorei/
    http://sites.google.com/site/vilorei/arduino/20--arduino-makefile-for-xcode


Bugs and To Dos
----------------------------------
Uploaded sketch from chipKIT.mk doesn't run on UNO32
 
I suspect missing files not taken into account by the makefile but used by MPIDE:

cpp-startup.S
crti.S
crtn.S

chipKIT-application-32MX360F512L.ld
chipKIT-application-32MX440F512H.ld
chipKIT-application-32MX460F512L.ld
chipKIT-MAX32-application-32MX795F512L.ld
chipKIT-UNO32-application-32MX320F128L.ld

from /Applications/Mpide.app/Contents/Resources/Java/hardware/pic32/cores/pic32/


Revision history
----------------------------------
Jan 26, 2012 release b - makefile: Arduino / chipKIT switch


Based on
----------------------------------
see References file


List of boards
----------------------------------
* PIC32 boards

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


* Arduino boards

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
