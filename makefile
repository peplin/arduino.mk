TARGET       = blink

BOARD_TAG    = uno
#BOARD_TAG    =uno_pic32



ARDUINO_MAKEFILE_HOME = $(CURDIR)

ARDUINO_DIR  = /Applications/Mpide.app/Contents/Resources/Java
ARDUINO_PORT = /dev/tty.usbmodem*

# look if BOARD_TAG is listed as a PIC32 board
FLAG = $(shell grep $(BOARD_TAG).name $(ARDUINO_DIR)/hardware/pic32/boards.txt)

# something = chipKIT board, empty = Arduino board
NEXT = $(if $(FLAG),chipKIT.mk,Arduino.mk)

# switch to appropriate mk
include $(ARDUINO_MAKEFILE_HOME)/$(NEXT)