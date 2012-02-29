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

OSTYPE := $(shell uname)

AVR_TOOLS_PATH = $(ARDUINO_DIR)/hardware/pic32/compiler/pic32-tools/bin
AVRDUDE_TOOLS_PATH = $(AVR_TOOLS_PATH)/../../../../tools
ARDUINO_CORE_PATH = $(ARDUINO_DIR)/hardware/pic32/cores/pic32
ARDUINO_LIB_PATH = $(ARDUINO_DIR)/hardware/pic32/libraries
BOARDS_TXT  = $(ARDUINO_DIR)/hardware/pic32/boards.txt
VARIANTS_PATH = $(ARDUINO_DIR)/hardware/pic32/variants
ARDUINO_VERSION = 23

ifndef ARDUINO_PREFERENCES_PATH

ifeq ($(OSTYPE),Linux)
ARDUINO_PREFERENCES_PATH = $(HOME)/.mpide/preferences.txt
else
ARDUINO_PREFERENCES_PATH = $(HOME)/Library/Mpide/preferences.txt
endif

endif

CC_NAME = pic32-gcc
CXX_NAME = pic32-g++
AR_NAME = pic32-ar
OBJDUMP_NAME = pic32-objdump
OBJCOPY_NAME = pic32-objcopy

CORE_INCLUDE_NAME = "WProgram.h"
LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),ldscript)

MCU_FLAG_NAME=mprocessor
EXTRA_LDFLAGS  = -T$(ARDUINO_CORE_PATH)/$(LDSCRIPT)
EXTRA_CPPFLAGS = -O2  -mno-smart-io -D$(BOARD)

CHIPKIT_MK_PATH := $(dir $(lastword $(MAKEFILE_LIST)))

include $(CHIPKIT_MK_PATH)/Arduino.mk

# MPIDE still comes with the compilers on Linux, unlike Arduino
CC      = $(AVR_TOOLS_PATH)/$(CC_NAME)
CXX     = $(AVR_TOOLS_PATH)/$(CXX_NAME)
OBJCOPY = $(AVR_TOOLS_PATH)/$(OBJCOPY_NAME)
