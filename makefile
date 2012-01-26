#
# Main Makefile
#
# Jan 26, 2012 release b - Arduino / chipKIT switch
#
# © Rei VILO, 2012
# LGPL
# http://sites.google.com/site/vilorei/
#
# BOARD_TAG
# PIC32 boards   = uno_pic32 mega_pic32 ...
# Arduino boards = uno mega2560 pro5v ...

BOARD_TAG    = uno_pic32

TARGET       = blink

ARDUINO_MAKEFILE_HOME = $(CURDIR)

ARDUINO_DIR  = /Applications/Mpide.app/Contents/Resources/Java
ARDUINO_PORT = /dev/tty.usb*

# Search utility
nullstring  :=
spacestring := $(nullstring) # end of the line
equalstring := $(nullstring)=# end of the line
# result = $(call READ_BOARD_TXT, 'boardname', 'parameter')
PARSE_BOARD = $(lastword $(subst $(equalstring),$(spacestring),$(shell grep $(1).$(2) $(BOARDS_TXT))))

# look if BOARD_TAG is listed as a PIC32 board
FLAG = $(shell grep $(BOARD_TAG).name $(ARDUINO_DIR)/hardware/pic32/boards.txt)

# something = chipKIT board, empty = Arduino board
NEXT = $(if $(FLAG),chipKIT.mk,Arduino.mk)

# call Arduino of chipKIT makefile
include $(ARDUINO_MAKEFILE_HOME)/$(NEXT)

