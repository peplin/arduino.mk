########################################################################
# Version 2012/02/20
# Arduino command line tools Makefile
# System part (i.e. project independent)
#
# Derived from on work by Martin Oldfield <m@mjo.tc>(C) 2010, which was
# based on work by Copyrighted Nicholas Zambetti, David Mellis & 
# Hernando Barragan.
#
# This file is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of the
# License, or (at your option) any later version.
#
# Adapted from Arduino 0011 Makefile by M J Oldfield
# Original Arduino adaptation by mellis, eighthave, oli.keller
# Modified by Christopher Peplin for chipKIT.
# Further modified by Edward Comer for more automation
########################################################################
# STANDARD ARDUINO WORKFLOW
#
# Given a normal sketch directory, where the program filename is the same
# as the directory name, plus a suffix of .ino or .pde, all you need to 
# do is to create a small Makefile like the example below and place it onto
# the sketch directory of the target program. However, if your sketch
# program filename differs from the basename of the directory that it 
# resides in, you must define TARGET, for example:
# TARGET = BaseNameOfSketchFile
#
# For example:
#----------Sample Makefile placed within Arduino sketchbook-----------
## BOARD_TAG: do make show_boards to list all valid boards
#BOARD_TAG    = nano328
#ARDUINO_DIR  = /home/user/arduino/arduino-1.0
#ARDUINO_SKETCHBOOK = /home/user/arduino/arduino-1.0/sketchbook
#ARDUINO_MAKEFILE_HOME = /home/user/arduino
#ARDUINO_LIBS = SoftwareSerial
#ARDUINO_PORT = /dev/ttyUSB*
#
## .SECONDARY: will cause the intermediary files to be kept
##.SECONDARY:
#
#include $(ARDUINO_MAKEFILE_HOME)/Arduino.mk
#----------------------------------------------------------------------
#
# Hopefully these will be self-explanatory but in case they're not:
#
#    ARDUINO_DIR  - Where the Arduino software has been unpacked
#    TARGET       - The basename used for the final files. Canonically
#                   this would match the .pde file, but it's not needed
#                   here: you could always set it to xx if you wanted!
#    ARDUINO_LIBS - A list of any libraries used by the sketch (we assume
#                   these are in $(ARDUINO_DIR)/hardware/libraries
#    ARDUINO_PORT - The port where the Arduino can be found. Only needed
#                   if overriding avrdude.conf
#    BOARD_TAG    - The tag for the board e.g. uno or mega
#                   'make showboards' shows a list. Note: If using an ATtiny
#					chip, set BOARD_TAG = tiny before make showboards
#
# You can also specify these, but normally they'll be read from the
# boards.txt file i.e. implied by BOARD_TAG
#
#    MCU,F_CPU    - The target processor description
#
# Once this file has been created the typical workflow is just
#
#   $ make upload
#	or
#	$ make ispload
#
# All of the object files are created in the build-cli subdirectory
# All sources should be in the current directory and can include:
#  - at most one .pde file which will be treated as C++ after the standard
#    Arduino header and footer have been affixed.
#  - any number of .c, .cpp, .s and .h files
#
# Included libraries are built in the build-cli/libs subdirectory.
#
# Besides make upload you can also
#   make             - no upload
#   make clean       - remove all our dependencies
#   make depends     - update dependencies
#   make reset       - reset the Arduino by tickling DTR on the serial port
#   make raw_upload  - upload without first resetting
#   make showboards - list all the boards defined in boards.txt
#   make ispload     - upload via external programmer
#
########################################################################
# ARDUINO WITH OTHER TOOLS
#
# If the tools aren't in the Arduino distribution, AND are not in your
# computor's normal execution path, then you need to
# specify their location:
#    AVR_TOOLS_PATH = /usr/bin
#    AVRDUDE_CONF   = /etc/avrdude/avrdude.conf
########################################################################
# ARDUINO WITH ISP
#
# Values similar to the following SHOULD be automatically retrieved 
# from avrdude.conf. However, you can manually set them to override 
# avrdude.conf.
#
# For example only (values for illustration only):
#     ARDUINO_PORT = /dev/ttyUSB*
#     ISP_PROG	   = -c stk500v2
#     ISP_PORT     = /dev/ttyACM0
#     ISP_LOCK_FUSE_PRE  = 0x3f
#     ISP_LOCK_FUSE_POST = 0xcf
#     ISP_HIGH_FUSE      = 0xdf
#     ISP_LOW_FUSE       = 0xff
#     ISP_EXT_FUSE       = 0x01
#
# To actually do an upload use the ispload target:
#
#    make ispload
########################################################################
# Some paths
#
#WARNING: This makefile is bash shell dependant!
SHELL=/bin/bash

OSTYPE := $(shell uname)

ifeq ($(wildcard *.ino),)
	SUFFIX:= pde
else
	SUFFIX:= ino
endif

ifndef TARGET
	TARGET := $(notdir $(CURDIR))
endif

ifndef ARDUINO_PREFERENCES_PATH
	ifeq ($(OSTYPE),Linux)
		ARDUINO_PREFERENCES_PATH = $(HOME)/.arduino/preferences.txt
	else
		ARDUINO_PREFERENCES_PATH = $(HOME)/Library/Arduino/preferences.txt
	endif
endif

ifeq ($(wildcard $(ARDUINO_PREFERENCES_PATH)),)
	$(error "Error: run the IDE once to initialize preferences sketchbook path")
endif

ifndef ARDUINO_SKETCHBOOK
	ARDUINO_SKETCHBOOK = $(shell grep sketchbook.path $(wildcard $(ARDUINO_PREFERENCES_PATH)) | cut -d = -f 2)
endif

ifndef AVR_TOOLS_PATH
	AVR_TOOLS_PATH := $(shell dirname "`find $(ARDUINO_DIR) -type f -name 'avr-gcc'`")
endif

ifndef AVRDUDE_CONF
	AVRDUDE_CONF := $(shell find $(ARDUINO_DIR) -type f -name 'avrdude.conf')
endif

# Having gotten got tired of setting up a make process and discovering that 
# ARDUINO_LIBS was wrong, the makefile section below searches the source file 
# for includes, sees if they are resident in the libraries folder and if they 
# are, creates a ARDUINO_LIBS variable populated with the libraries imported 
# by the source file. The '$$' is because make eats each first '$' that it 
# encounters and the backslash before the '#' is because make considers any '#'
# encountered to be the beginning of a comment. (E. Comer)
ifndef ARDUINO_LIBS
	ARDUINO_LIBS := $(shell for f in $$(grep "\#include" $(TARGET).$(SUFFIX)); \
	do if [ "$$f" = "\#include" ]; \
	then continue; \
	fi; \
	ff=$$(echo "$$f"|sed "s:.\#include.*<::"|tr -d "<\">"); \
	echo -n "$$(basename "$$(find "/home/ecomer/arduino/arduino-1.0/libraries" -name "$${ff}")" .h) "; \
	done )
endif

ifndef ARDUINO_LIB_PATH
	ARDUINO_LIB_PATH  := $(ARDUINO_DIR)/libraries
endif

ifndef USER_LIB_PATH
	USER_LIB_PATH := $(ARDUINO_SKETCHBOOK)/libraries
endif

ARDUINO_CORE_PATH := $(shell find $(ARDUINO_DIR) -type d -name 'arduino' | sort -u|grep cores)

# Sketchbook location needed to descriminate between ~/arduino/arduino-1.0/hardware/arduino/variants
# and varients within sketchbook per MIT's High-Low tech http://hlt.media.mit.edu/?p=1695
# https://github.com/damellis/attiny/tree/Arduino1
ifndef ARDUINO_SKETCHBOOK
	ARDUINO_SKETCHBOOK := $(ARDUINO_DIR)/sketchbook
endif

ifndef VARIANTS_PATH
	ifneq (,$(findstring tiny,$(BOARD_TAG)))
		VARIANTS_PATH := $(shell find $(ARDUINO_SKETCHBOOK) -type d -name 'variants')
	else
		VARIANTS_PATH := $(ARDUINO_DIR)/hardware/arduino/variants
	endif
endif

ifndef ARDUINO_VERSION
	ARDUINO_VERSION = 100
endif

ARDUINO_MK_PATH := $(dir $(lastword $(MAKEFILE_LIST)))

########################################################################
# boards.txt parsing
#
ifndef BOARD_TAG
	BOARD_TAG   = uno
endif

# CHANGED
ifndef BOARDS_TXT
	ifneq (,$(findstring tiny,$(BOARD_TAG)))
		BOARDS_TXT := $(shell find $(ARDUINO_DIR) -type f -name 'boards.txt' |sort -u |grep tiny)
	else
		BOARDS_TXT := $(shell find $(ARDUINO_DIR) -type f -name 'boards.txt' |sort -u |grep -v tiny)
	endif
endif

# To support both MPIDE (which uses WProgram.h) and Arduino 1.0 (Arduino.h)
ifndef CORE_INCLUDE_NAME
	CORE_INCLUDE_NAME = "Arduino.h"
endif

ifndef PARSE_BOARD
	# result = $(call READ_BOARD_TXT, 'boardname', 'parameter')
	PARSE_BOARD = $(shell grep $(1).$(2) $(BOARDS_TXT) | cut -d = -f 2 )
endif

# processor stuff
ifndef MCU
	MCU   := $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
endif

ifndef F_CPU
	F_CPU := $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)
endif

# normal programming info
ifndef AVRDUDE_PROTOCOL
	AVRDUDE_PROTOCOL := $(call PARSE_BOARD,$(BOARD_TAG),upload.protocol)
endif

# FIX ME - May not be present
ifndef AVRDUDE_PORT_BAUDRATE
	AVRDUDE_PORT_BAUDRATE := $(call PARSE_BOARD,$(BOARD_TAG),upload.speed)
endif

# FIX ME - May not be present
ifndef ISP_LOCK_FUSE_PRE
	ISP_LOCK_FUSE_PRE := $(call PARSE_BOARD,$(BOARD_TAG),bootloader.unlock_bits)
endif

# FIX ME - May not be present
ifndef ISP_LOCK_FUSE_POST
	ISP_LOCK_FUSE_POST := $(call PARSE_BOARD,$(BOARD_TAG),bootloader.lock_bits)
endif

ifndef ISP_HIGH_FUSE
	ISP_HIGH_FUSE := $(call PARSE_BOARD,$(BOARD_TAG),bootloader.high_fuses)
endif

ifndef ISP_LOW_FUSE
	ISP_LOW_FUSE := $(call PARSE_BOARD,$(BOARD_TAG),bootloader.low_fuses)
endif

ifndef ISP_EXT_FUSE
	ISP_EXT_FUSE := $(call PARSE_BOARD,$(BOARD_TAG),bootloader.extended_fuses)
endif

ifdef KEEPFUSES
	FUSE_OPTS = 
else
	FUSE_OPTS = -U lfuse:w:$(ISP_LOW_FUSE):m \
	-U hfuse:w:$(ISP_HIGH_FUSE):m \
	-U efuse:w:$(ISP_EXT_FUSE):m
endif

ifndef VARIANT
	VARIANT := $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
endif

########################################################################
#
# Avrdude parameter preparation
#

ifndef AVRDUDE
	ifeq ($(AVR_TOOLS_PATH),.)
		AVRDUDE := $(shell find $(ARDUINO_DIR) -type f -name 'avrdude')
	else
		AVRDUDE := $(shell find $(AVR_TOOLS_PATH) -type f -name 'avrdude')
	endif
endif

AVRDUDE_COM_OPTS := -p $(MCU)

ifneq ($(ISP_PORT),)
	AVRDUDE_ISP_OPTS := -P $(ISP_PORT) $(ISP_PROG)
endif

#######################################################################
#
# Serial monitoring
#

ifndef SERIAL_BAUDRATE
	SERIAL_BAUDRATE = 9600
endif

ifndef SERIAL_COMMAND
	SERIAL_COMMAND   = screen
endif


# Everything gets built in here
OBJDIR  	  := build-cli

########################################################################
# Local sourcesifeq ($(strip $(NO_CORE)),)
#
LOCAL_C_SRCS    = $(wildcard *.c)
LOCAL_CPP_SRCS  = $(wildcard *.cpp)
LOCAL_CC_SRCS   = $(wildcard *.cc)
LOCAL_PDE_SRCS  = $(wildcard *.$(SUFFIX))
LOCAL_AS_SRCS   = $(wildcard *.S)
LOCAL_OBJ_FILES = $(LOCAL_C_SRCS:.c=.o) $(LOCAL_CPP_SRCS:.cpp=.o) \
		$(LOCAL_CC_SRCS:.cc=.o) $(LOCAL_PDE_SRCS:.$(SUFFIX)=.o) \
		$(LOCAL_AS_SRCS:.S=.o)
LOCAL_OBJS      = $(patsubst %,$(OBJDIR)/%,$(LOCAL_OBJ_FILES))

# Dependency files
DEPS            = $(LOCAL_OBJS:.o=.d)

# If you want to develop code which isn't linked against the Wiring 
# library, in the primary Makefile set NO_CORE=1
# core sources
ifeq ($(strip $(NO_CORE)),)
	ifdef ARDUINO_CORE_PATH
		CORE_C_SRCS     = $(wildcard $(ARDUINO_CORE_PATH)/*.c)
		CORE_CPP_SRCS   = $(wildcard $(ARDUINO_CORE_PATH)/*.cpp)
		ifneq ($(strip $(NO_CORE_MAIN_FUNCTION)),)
			CORE_CPP_SRCS := $(filter-out %main.cpp, $(CORE_CPP_SRCS))
		endif
	endif

	CORE_OBJ_FILES  = $(CORE_C_SRCS:.c=.o) $(CORE_CPP_SRCS:.cpp=.o)
	CORE_OBJS       = $(patsubst $(ARDUINO_CORE_PATH)/%,$(OBJDIR)/%,$(CORE_OBJ_FILES))
endif

# all the objects!
OBJS            = $(LOCAL_OBJS) $(CORE_OBJS) $(LIB_OBJS)

########################################################################
# Rules for making stuff
#

# The name of the main targets
TARGET_HEX = $(OBJDIR)/$(TARGET).hex
TARGET_ELF = $(OBJDIR)/$(TARGET).elf
TARGETS    = $(OBJDIR)/$(TARGET).*

# A list of dependencies
DEP_FILE   = $(OBJDIR)/depends.mk

ifndef CC_NAME
	CC_NAME      = avr-gcc
endif

ifndef CXX_NAME
	CXX_NAME     = avr-g++
endif

ifndef OBJCOPY_NAME
	OBJCOPY_NAME = avr-objcopy
endif

ifndef OBJDUMP_NAME
	OBJDUMP_NAME = avr-objdump
endif

ifndef NM_NAME
	NM_NAME      = avr-nm
endif

# Names of executables
ifeq ($(OSTYPE),Linux)
	# Compilers are not distributed in IDE on Linux - use system versions
	CXX     = $(CXX_NAME)
	CC      = $(CC_NAME)
	OBJCOPY = $(OBJCOPY_NAME)
else
	CC      = $(AVR_TOOLS_PATH)/$(CC_NAME)
	CXX     = $(AVR_TOOLS_PATH)/$(CXX_NAME)
	OBJCOPY = $(AVR_TOOLS_PATH)/$(OBJCOPY_NAME)
endif

OBJDUMP = $(AVR_TOOLS_PATH)/$(OBJDUMP_NAME)
NM      = $(AVR_TOOLS_PATH)/$(NM_NAME)
REMOVE  = @rm -f
ECHO    = @echo

# General arguments
SYS_LIBS      = $(patsubst %,$(ARDUINO_LIB_PATH)/%,$(ARDUINO_LIBS))
USER_LIBS     = $(patsubst %,$(USER_LIB_PATH)/%,$(ARDUINO_LIBS))
SYS_INCLUDES  = $(patsubst %,-I%,$(SYS_LIBS))
SYS_INCLUDES  += $(patsubst %,-I%,$(USER_LIBS))
SYS_OBJS      = $(wildcard $(patsubst %,%/*.o,$(SYS_LIBS)))
SYS_OBJS      += $(wildcard $(patsubst %,%/*.o,$(USER_LIBS)))
LIB_CPP_SRC   = $(wildcard $(patsubst %,%/*.cpp,$(SYS_LIBS)))
LIB_C_SRC     = $(wildcard $(patsubst %,%/*.c,$(SYS_LIBS)))
USER_LIB_CPP_SRC   = $(wildcard $(patsubst %,%/*.cpp,$(USER_LIBS)))
USER_LIB_C_SRC     = $(wildcard $(patsubst %,%/*.c,$(USER_LIBS)))
LIB_OBJS      = $(patsubst $(ARDUINO_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.o,$(LIB_CPP_SRC))
LIB_OBJS      += $(patsubst $(ARDUINO_LIB_PATH)/%.c,$(OBJDIR)/libs/%.o,$(LIB_C_SRC))
LIB_OBJS      += $(patsubst $(USER_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.o,$(USER_LIB_CPP_SRC))
LIB_OBJS      += $(patsubst $(USER_LIB_PATH)/%.c,$(OBJDIR)/libs/%.o,$(USER_LIB_C_SRC))

ifndef MCU_FLAG_NAME
	MCU_FLAG_NAME = mmcu
endif

CPPFLAGS    = -g -Os -w -Wall \
			-ffunction-sections -fdata-sections \
			-$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU) \
			-DARDUINO=$(ARDUINO_VERSION) \
			-I. -I$(ARDUINO_CORE_PATH) \
			-I$(VARIANTS_PATH)/$(VARIANT) \
			$(SYS_INCLUDES) $(EXTRA_CPPFLAGS)

ifdef USE_GNU99
	CFLAGS        = -std=gnu99
endif

CXXFLAGS      = -fno-exceptions
ASFLAGS       = -mmcu=$(MCU) -I. -x assembler-with-cpp
LDFLAGS       = -$(MCU_FLAG_NAME)=$(MCU) -lm -Wl,--gc-sections -Os $(EXTRA_LDFLAGS)

# Rules for making a CPP file from the main sketch (.cpe)
PDEHEADER     = \\\#include \"$(CORE_INCLUDE_NAME)\"

# Expand and pick the first port
AVRDUDE_PORT      := $(firstword $(wildcard $(ARDUINO_PORT)))

# Implicit rules for building everything (needed to get everything in
# the right directory)
#
# Rather than mess around with VPATH there are quasi-duplicate rules
# here for building e.g. a system C++ file and a local C++
# file. Besides making things simpler now, this would also make it
# easy to change the build options in future

# library sources
$(OBJDIR)/libs/%.o: $(ARDUINO_LIB_PATH)/%.cpp
	mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@
$(OBJDIR)/libs/%.o: $(ARDUINO_LIB_PATH)/%.c
	mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@
$(OBJDIR)/libs/%.o: $(USER_LIB_PATH)/%.cpp
	mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@
$(OBJDIR)/libs/%.o: $(USER_LIB_PATH)/%.c
	mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

# normal local sources
# .o rules are for objects, .d for dependency tracking
# there seems to be an awful lot of duplication here!!!
$(OBJDIR)/%.o: %.c
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: %.cc
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.o: %.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.o: %.S
	$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/%.o: %.s
	$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/%.d: %.c
	$(CC) -MM $(CPPFLAGS) $(CFLAGS) $< -MF $@ -MT $(@:.d=.o)

$(OBJDIR)/%.d: %.cc
	$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< -MF $@ -MT $(@:.d=.o)

$(OBJDIR)/%.d: %.cpp
	$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< -MF $@ -MT $(@:.d=.o)

$(OBJDIR)/%.d: %.S
	$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.o)

$(OBJDIR)/%.d: %.s
	$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.o)

# the pde -> cpp -> o file
$(OBJDIR)/%.cpp: %.$(SUFFIX)
	$(ECHO) $(PDEHEADER) > $@
	@cat  $< >> $@

$(OBJDIR)/%.o: $(OBJDIR)/%.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.d: $(OBJDIR)/%.cpp
	$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< -MF $@ -MT $(@:.d=.o)

# core files
$(OBJDIR)/%.o: $(ARDUINO_CORE_PATH)/%.c
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(ARDUINO_CORE_PATH)/%.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# various object conversions
$(OBJDIR)/%.hex: $(OBJDIR)/%.elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

$(OBJDIR)/%.eep: $(OBJDIR)/%.elf
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom="alloc,load" \
		--change-section-lma .eeprom=0 -O ihex $< $@

$(OBJDIR)/%.lss: $(OBJDIR)/%.elf
	$(OBJDUMP) -h -S $< > $@

$(OBJDIR)/%.sym: $(OBJDIR)/%.elf
	$(NM) -n $< > $@

########################################################################
#
# Explicit targets start here
#

all: 		$(OBJDIR) $(TARGET_HEX)

$(OBJDIR):
		@mkdir $(OBJDIR)

$(TARGET_ELF): 	$(OBJS)
		$(CC) $(LDFLAGS) -o $@ $(OBJS) $(SYS_OBJS) -lc

$(DEP_FILE):	$(OBJDIR) $(DEPS)
		@cat $(DEPS) > $(DEP_FILE)

# reset the Arduino by tickling DTR on the serial port
# then upload the hex file via avrdude
upload:		reset raw_upload

raw_upload:	$(TARGET_HEX)
		$(AVRDUDE) -C$(AVRDUDE_CONF) -v -v -v  -p $(MCU) \
		-c $(AVRDUDE_PROTOCOL) -P $(AVRDUDE_PORT) -b $(AVRDUDE_PORT_BAUDRATE) \
			-D -U flash:w:$(TARGET_HEX):i

# Toggle the DTR to reset the Arduino board and start bootloader
reset:
		@if [ -z "$(AVRDUDE_PORT)" ]; then \
			echo "No Arduino-compatible TTY device found -- exiting"; exit 2; \
			fi
		for STTYF in 'stty --file' 'stty -f' 'stty <' ; \
		  do $$STTYF /dev/tty >/dev/null 2>/dev/null && break ; \
		done ;\
		$$STTYF $(AVRDUDE_PORT)  hupcl ;\
		(sleep 0.1 || sleep 1)     ;\
		$$STTYF $(AVRDUDE_PORT) -hupcl

ispload:	$(TARGET_HEX)
		$(AVRDUDE) -p $(MCU) $(AVRDUDE_ISP_OPTS) -v -v -v \
			-C $(AVRDUDE_CONF) \
			-c $(AVRDUDE_PROTOCOL) $(FUSE_OPTS) \
			-U flash:w:$(TARGET_HEX):i

serial:
	$(SERIAL_COMMAND) $(ARDUINO_PORT) $(SERIAL_BAUDRATE)

clean:
	@rm -r $(OBJDIR)/*

depends:	$(DEPS)
		@cat $(DEPS) > $(DEP_FILE)

showboards:
	@cat $(BOARDS_TXT) | grep -E "^[[:alnum:]]" | cut -d . -f 1 | uniq

# Next target is for debugging. For example, Entering make print-AVRDUDE_CONF
# yields: AVRDUDE_CONF = [/yourpath/hardware/tools/avrdude.conf]
print-%:
	@echo $* = [$($*)]

.PHONY:	all clean depends upload raw_upload reset showboards

include $(DEP_FILE)
