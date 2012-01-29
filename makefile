 
# board specifics defined in .xconfig file
# BOARD_TAG and ARDUINO_PORT 
#
ifndef BOARD_TAG
BOARD_TAG      = uno
endif

ifndef ARDUINO_PORT
ARDUINO_PORT      = /dev/tty.usbmodem*
endif


# Declare Arduino/chipKIT libraries used 
#
ARDUINO_LIBS = Wire Wire/utility 
# ARDUINO_LIBS += EEPROM Ethernet Ethernet/utility SPI Firmata LiquidCrystal Matrix Sprite SD SD/utility Servo SoftwareSerial Stepper


# Mpide.app path
#
ARDUINO_MAKEFILE_HOME = $(CURDIR)
ARDUINO_DIR  = /Applications/Mpide.app/Contents/Resources/Java
TARGET       = main


# PARSE_BOARD function
# result = $(call READ_BOARD_TXT,'boardname','parameter')
#
nullstring  :=
spacestring := $(nullstring) # end of the line
equalstring := $(nullstring)=# end of the line
PARSE_BOARD = $(lastword $(subst $(equalstring),$(spacestring),$(shell grep $(1).$(2) $(BOARDS_TXT))))


# Look if BOARD_TAG is listed as a PIC32 board
#
FLAG = $(shell grep $(BOARD_TAG).name $(ARDUINO_DIR)/hardware/pic32/boards.txt)


# Something = chipKIT board, empty = Arduino board
#
NEXT = $(if $(FLAG),chipKIT.mk,Arduino.mk)


# Switch to appropriate mk
#
include $(ARDUINO_MAKEFILE_HOME)/$(NEXT)

