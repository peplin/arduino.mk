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
#
# Modified by John Wallbank for Visual Studio
#
#    Development changes, John Wallbank,
#
#   - made inclusion of WProgram.h optional so that
#    including it in the source doesn't mess up compile error line numbers
#   - parameterised the routine used to reset the serial port
#
OSTYPE := $(shell uname)

ifeq ($(wildcard $(MPIDE_DIR)),)
$(error "Error: the MPIDE_DIR variable must point to your MPIDE installation")
endif

ARDUINO_DIR = $(MPIDE_DIR)

AVR_TOOLS_PATH = $(ARDUINO_DIR)/hardware/pic32/compiler/pic32-tools/bin/

ifneq ($(OSTYPE),Linux)
AVRDUDE_TOOLS_PATH = $(ARDUINO_DIR)/hardware/tools/avr/bin
else
AVRDUDE_TOOLS_PATH = $(ARDUINO_DIR)/hardware/tools
endif

ifneq ($(OSTYPE),Linux)
AVRDUDE_ETC_PATH = $(ARDUINO_DIR)/hardware/tools/avr/etc
else
AVRDUDE_ETC_PATH = $(AVRDUDE_TOOLS_PATH)
endif

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

ifndef $(CORE_INCLUDE_NAME)
  CORE_INCLUDE_NAME="WProgram.h"
endif

LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),ldscript)
LDSCRIPT_FILE = $(ARDUINO_CORE_PATH)/$(LDSCRIPT)

MCU_FLAG_NAME=mprocessor
EXTRA_LDFLAGS  += -T$(ARDUINO_CORE_PATH)/$(LDSCRIPT)
EXTRA_CPPFLAGS += -mno-smart-io -fno-short-double

CHIPKIT_MK_PATH := $(dir $(lastword $(MAKEFILE_LIST)))

include $(CHIPKIT_MK_PATH)Arduino.mk
