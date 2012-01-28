# 
# chipKIT extensions for Arduino Makefile
# System part (i.e. project independent)
#
# Copyright (C) 2011 Christopher Peplin <chris.peplin@rhubarbtech.com>,
# based on work that is Copyright Martin Oldfield
#
# This file is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of the
# License, or (at your option) any later version.
#

AVR_TOOLS_PATH     = $(ARDUINO_DIR)/hardware/pic32/compiler/pic32-tools/bin
AVRDUDE_TOOLS_PATH = $(ARDUINO_DIR)/hardware/tools
ARDUINO_CORE_PATH  = $(ARDUINO_DIR)/hardware/pic32/cores/pic32
ARDUINO_LIB_PATH   = $(ARDUINO_SKETCHBOOK)/libraries
BOARDS_TXT         = $(ARDUINO_DIR)/hardware/pic32/boards.txt

CC_NAME      = pic32-gcc
CXX_NAME     = pic32-g++
AR_NAME      = pic32-ar
OBJDUMP_NAME = pic32-objdump
OBJCOPY_NAME = pic32-objcopy

OSTYPE := $(shell uname)

ifndef AVRDUDE
	ifeq ($(OSTYPE),Darwin)
		# a different path is used in OS X
		AVRDUDE = $(AVRDUDE_TOOLS_PATH)/avr/bin/avrdude
	else
		AVRDUDE = $(AVRDUDE_TOOLS_PATH)/avrdude
	endif
endif

ifndef AVRDUDE_CONF
	ifeq ($(OSTYPE),Darwin)
		# a different path is used in OS X
		AVRDUDE_CONF = $(AVRDUDE_TOOLS_PATH)/avr/etc/avrdude.conf
	else
		AVRDUDE_CONF = $(AVRDUDE_TOOLS_PATH)/avrdude.conf
	endif
endif

BOARD    = $(call PARSE_BOARD,$(BOARD_TAG),board)
LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),ldscript)

MCU_FLAG_NAME=mprocessor
EXTRA_CPPFLAGS = -O2 -mno-smart-io -DARDUINO=23 -D$(BOARD)=  \
		-I$(ARDUINO_DIR)/hardware/pic32/variants/$(VARIANT)

CHIPKIT_MK_PATH := $(dir $(lastword $(MAKEFILE_LIST)))

include $(CHIPKIT_MK_PATH)/Arduino.mk
