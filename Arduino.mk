########################################################################
#
# Arduino command line tools Makefile
# System part (i.e. project independent)
#
# Copyright (C) 2010 Martin Oldfield <m@mjo.tc>, based on work that is
# Copyright Nicholas Zambetti, David A. Mellis & Hernando Barragan
#
# This file is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of the
# License, or (at your option) any later version.
#
# Adapted from Arduino 0011 Makefile by M J Oldfield
#
# Original Arduino adaptation by mellis, eighthave, oli.keller
#
# Modified by Christopher Peplin for chipKIT.
#
# Modified by John Wallbank for Visual Studio
#
# Version 0.1  17.ii.2009  M J Oldfield
#
#         0.2  22.ii.2009  M J Oldfield
#                          - fixes so that the Makefile actually works!
#                          - support for uploading via ISP
#                          - orthogonal choices of using the Arduino for
#                            tools, libraries and uploading
#
#         0.3  21.v.2010   M J Oldfield
#                          - added proper license statement
#                          - added code from Philip Hands to reset
#                            Arduino prior to upload
#
#         0.4  25.v.2010   M J Oldfield
#                          - tweaked reset target on Philip Hands' advice
#
#         0.5  23.iii.2011 Stefan Tomanek
#                          - added ad-hoc library building
#              17.v.2011   M J Oldfield
#                          - grabbed said version from Ubuntu
#
#         0.6  22.vi.2011  M J Oldfield
#                          - added ard-parse-boards supports
#                          - added -lc to linker opts,
#                            on Fabien Le Lez's advice
#
#              Development changes, Chris Peplin,
#
#              			   - converted ard-parse-boards to a Makefile function
#              			   so Perl/YAML aren't required (thanks to avenue33 on
#              			   the chipKIT forums)
#              			   - added support for multiple library paths
#              Development changes, John Wallbank,
#
#              			   - made inclusion of WProgram.h optional so that
#              			   including it in the source doesn't mess up compile error line numbers
#              			   - tidied up the presentation of progress comments
#						   - parameterised the routine used to reset the serial port
#
########################################################################
#
# STANDARD ARDUINO WORKFLOW
#
# Given a normal sketch directory, all you need to do is to create
# a small Makefile which defines a few things, and then includes this one.
#
# For example:
#
#       ARDUINO_DIR  = /Applications/arduino-0013
#
#       TARGET       = CLItest
#       ARDUINO_LIBS = LiquidCrystal
#
#       BOARD_TAG    = uno
#       SERIAL_PORT = /dev/cu.usb*
#
#       include $(ARDUINO_MAKEFILE_HOME)/Arduino.mk
#
# Hopefully these will be self-explanatory but in case they're not:
#
#    ARDUINO_DIR  - Where the Arduino software has been unpacked
#    TARGET       - The basename used for the final files. Canonically
#                   this would match the .pde file, but it's not needed
#                   here: you could always set it to xx if you wanted!
#    ARDUINO_LIBS - A list of any libraries used by the sketch (we assume
#                   these are in $(ARDUINO_DIR)/hardware/libraries
#    SERIAL_PORT - The port where the Arduino can be found. Only needed
#                   when uploading.
#    BOARD_TAG    - The tag for the board e.g. uno or mega
#                   'make show_boards' shows a list
#
# You might also want to specify these, but normally they'll be read from the
# boards.txt file i.e. implied by BOARD_TAG
#
#    MCU,F_CPU    - The target processor description
#
# Once this file has been created the typical workflow is just
#
#   $ make upload
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
#   make reset       - reset the Arduino by tickling DTR on the serial port
#   make raw_upload  - upload without first resetting
#   make show_boards - list all the boards defined in boards.txt
#   make ispload     - upload via an external programmer
#
########################################################################
#
# ARDUINO WITH OTHER TOOLS
#
# If the tools aren't in the Arduino distribution, then you need to
# specify their location:
#
#    AVR_TOOLS_PATH = /usr/bin
#    AVRDUDE_CONF   = /etc/avrdude/avrdude.conf
#
########################################################################
#
# ARDUINO WITH ISP
#
# Values similar to the following SHOULD be automatically retrieved
# from avrdude.conf. However, you can manually set them to override
# avrdude.conf.
#
# For example only (values for illustration only):
#
#     ISP_PROG	   = -c stk500v2
#     ISP_PORT     = /dev/ttyACM0
#
# You might also need to set the fuse bits, but typically they'll be
# read from boards.txt, based on the BOARD_TAG variable:
#
#     ISP_LOCK_FUSE_PRE  = 0x3f
#     ISP_LOCK_FUSE_POST = 0xcf
#     ISP_HIGH_FUSE      = 0xdf
#     ISP_LOW_FUSE       = 0xff
#     ISP_EXT_FUSE       = 0x01
#
# I think the fuses here are fine for uploading to the ATmega168
# without bootloader.
#
# To actually do this upload use the ispload target:
#
#    make ispload
#
#
########################################################################
# Some paths
#
#
#
OSTYPE := $(shell uname)

ifeq ($(wildcard $(ARDUINO_DIR)),)
$(error "Error: the ARDUINO_DIR variable must point to your Arduino IDE installation")
endif

ifndef TOOLS_PATH
TOOLS_PATH = $(ARDUINO_DIR)/hardware/tools/
endif

ifndef AVR_TOOLS_PATH
AVR_TOOLS_PATH    = $(TOOLS_PATH)/avr/bin/
endif

ifndef AVRDUDE_TOOLS_PATH
ifeq ($(OSTYPE),Linux)
AVRDUDE_TOOLS_PATH = $(TOOLS_PATH)
else
AVRDUDE_TOOLS_PATH = $(TOOLS_PATH)/avr/bin
endif
endif

ifndef AVRDUDE_ETC_PATH
ifeq ($(OSTYPE),Linux)
AVRDUDE_ETC_PATH = $(TOOLS_PATH)
else
AVRDUDE_ETC_PATH = $(TOOLS_PATH)/avr/etc
endif
endif

ifndef AVRDUDE_CONF
AVRDUDE_CONF     = $(AVRDUDE_ETC_PATH)/avrdude.conf
endif

ifndef ARDUINO_LIB_PATH
ARDUINO_LIB_PATH  = $(ARDUINO_DIR)/libraries
endif

ifndef USER_LIB_PATH

ifndef ARDUINO_SKETCHBOOK

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

ARDUINO_SKETCHBOOK = $(shell grep sketchbook.path $(wildcard $(ARDUINO_PREFERENCES_PATH)) | cut -d = -f 2)
endif

USER_LIB_PATH = $(ARDUINO_SKETCHBOOK)/libraries
endif

ifndef ARDUINO_CORE_PATH
ARDUINO_CORE_PATH = $(ARDUINO_DIR)/hardware/arduino/cores/arduino
endif

ifndef VARIANTS_PATH
VARIANTS_PATH = $(ARDUINO_DIR)/hardware/arduino/variants
endif

ifndef ARDUINO_VERSION
ARDUINO_VERSION = 100
endif

ifndef RESET_SERIAL
RESET_SERIAL=reset.sh
endif

ARDUINO_MK_PATH := $(dir $(lastword $(MAKEFILE_LIST)))

# Default TARGET to cwd (ex Daniele Vergini)
ifndef TARGET
TARGET  = $(notdir $(CURDIR))
endif

########################################################################
# boards.txt parsing
#
ifndef BOARD_TAG
BOARD_TAG   = uno
endif

ifndef BOARDS_TXT
BOARDS_TXT  = $(ARDUINO_DIR)/hardware/arduino/boards.txt
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
MCU   = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
endif

ifndef F_CPU
F_CPU = $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)
endif

# normal programming info
ifndef AVRDUDE_ARD_PROGRAMMER
AVRDUDE_ARD_PROGRAMMER = $(call PARSE_BOARD,$(BOARD_TAG),upload.protocol)
endif

ifndef AVRDUDE_ARD_BAUDRATE
AVRDUDE_ARD_BAUDRATE = $(call PARSE_BOARD,$(BOARD_TAG),upload.speed)
endif

# fuses if you're using e.g. ISP
ifndef ISP_LOCK_FUSE_PRE
ISP_LOCK_FUSE_PRE = $(call PARSE_BOARD,$(BOARD_TAG),bootloader.unlock_bits)
endif

ifndef ISP_LOCK_FUSE_POST
ISP_LOCK_FUSE_POST = $(call PARSE_BOARD,$(BOARD_TAG),bootloader.lock_bits)
endif

ifndef ISP_HIGH_FUSE
ISP_HIGH_FUSE = $(call PARSE_BOARD,$(BOARD_TAG),bootloader.high_fuses)
endif

ifndef ISP_LOW_FUSE
ISP_LOW_FUSE = $(call PARSE_BOARD,$(BOARD_TAG),bootloader.low_fuses)
endif

ifndef ISP_EXT_FUSE
ISP_EXT_FUSE = $(call PARSE_BOARD,$(BOARD_TAG),bootloader.extended_fuses)
endif

ifndef VARIANT
VARIANT = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
endif

ifndef OBJDIR
OBJDIR  	  = build-cli
endif

ifeq ($(wildcard *.ino),)
SUFFIX := pde
else
SUFFIX := ino
endif


# Sketch unicity test — rei-vilo
# ----------------------------------
#
ifndef SKIP_SUFFIX_CHECK
ifeq ($(words $(wildcard *.pde) $(wildcard *.ino)), 0)
$(error No pde or ino sketch)
endif

ifneq ($(words $(wildcard *.pde) $(wildcard *.ino)), 1)
$(error More than 1 pde or ino sketch)
endif
endif

# end of edit

########################################################################
# Local sources
#
LOCAL_C_SRCS    += $(wildcard *.c)
LOCAL_CPP_SRCS  += $(wildcard *.cpp)
LOCAL_CC_SRCS   += $(wildcard *.cc)
LOCAL_PDE_SRCS  += $(wildcard *.$(SUFFIX))
LOCAL_AS_SRCS   += $(wildcard *.S)
LOCAL_OBJ_FILES = $(LOCAL_C_SRCS:.c=.o) $(LOCAL_CPP_SRCS:.cpp=.o) \
		$(LOCAL_CC_SRCS:.cc=.o) $(LOCAL_PDE_SRCS:.$(SUFFIX)=.o) \
		$(LOCAL_AS_SRCS:.S=.o)
LOCAL_OBJS      = $(patsubst %,$(OBJDIR)/%,$(LOCAL_OBJ_FILES))

# core sources
ifeq ($(strip $(NO_CORE)),)
ifdef ARDUINO_CORE_PATH
CORE_C_SRCS     = $(wildcard $(ARDUINO_CORE_PATH)/*.c)
CORE_CPP_SRCS   = $(wildcard $(ARDUINO_CORE_PATH)/*.cpp)

ifneq ($(strip $(NO_CORE_MAIN_FUNCTION)),)
CORE_CPP_SRCS := $(filter-out %main.cpp, $(CORE_CPP_SRCS))
endif

CORE_OBJ_FILES  = $(CORE_C_SRCS:.c=.o) $(CORE_CPP_SRCS:.cpp=.o)
CORE_OBJS       = $(patsubst $(ARDUINO_CORE_PATH)/%,  \
			$(OBJDIR)/%,$(CORE_OBJ_FILES))
endif
endif

########################################################################
# Rules for making stuff
#

# The name of the main targets
TARGET_HEX = $(OBJDIR)/$(TARGET).hex
TARGET_ELF = $(OBJDIR)/$(TARGET).elf
TARGETS    = $(OBJDIR)/$(TARGET).*
CORE_LIB   = $(OBJDIR)/libcore.a

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

ifndef AR_NAME
AR_NAME      = avr-ar
endif

ifndef SIZE_NAME
SIZE_NAME    = avr-size
endif

ifndef NM_NAME
NM_NAME      = avr-nm
endif

# Names of executables
CC      = $(CC_NAME)
CXX     = $(CXX_NAME)
OBJCOPY = $(OBJCOPY_NAME)
OBJDUMP = $(OBJDUMP_NAME)
AR      = $(AR_NAME)
SIZE    = $(SIZE_NAME)
NM      = $(NM_NAME)

CC      := $(addprefix $(AVR_TOOLS_PATH),$(CC))
CXX     := $(addprefix $(AVR_TOOLS_PATH),$(CXX))
OBJCOPY := $(addprefix $(AVR_TOOLS_PATH),$(OBJCOPY))
OBJDUMP := $(addprefix $(AVR_TOOLS_PATH),$(OBJDUMP))
AR      := $(addprefix $(AVR_TOOLS_PATH),$(AR))
SIZE    := $(addprefix $(AVR_TOOLS_PATH),$(SIZE))
NM      := $(addprefix $(AVR_TOOLS_PATH),$(NM))

REMOVE  = rm -f
ECHO    = echo

# General arguments
SYS_LIBS      = $(patsubst %,$(ARDUINO_LIB_PATH)/%,$(ARDUINO_LIBS))
USER_LIBS     = $(patsubst %,$(USER_LIB_PATH)/%,$(ARDUINO_LIBS))
SYS_INCLUDES  = $(patsubst %,-I%,$(SYS_LIBS))
USER_INCLUDES = $(patsubst %,-I%,$(USER_LIBS))
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

CPPFLAGS_WITHOUT_USER_LIBS = -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU) \
			-DARDUINO=$(ARDUINO_VERSION) \
			-I. -I$(ARDUINO_CORE_PATH) \
			-I$(VARIANTS_PATH)/$(VARIANT) \
			$(SYS_INCLUDES) -w -Wall -fno-exceptions\
			-ffunction-sections -fdata-sections $(EXTRA_CPPFLAGS)
CPPFLAGS = $(CPPFLAGS_WITHOUT_USER_LIBS) $(USER_INCLUDES)

ifdef DEBUG
CPPFLAGS += -O0 -g -mdebugger
else
CPPFLAGS += -O2
endif

ifdef USE_GNU99
CFLAGS        = -std=gnu99
endif

CPPFLAGS += -fno-exceptions
ASFLAGS = -$(MCU_FLAG_NAME)=$(MCU) -I. -x assembler-with-cpp
LDFLAGS = -$(MCU_FLAG_NAME)=$(MCU) -lm -Wl,--gc-sections -Os $(EXTRA_LDFLAGS)

# Rules for making a CPP file from the main sketch (.cpe)
PDEHEADER     = \\\#include \"$(CORE_INCLUDE_NAME)\"

# Expand and pick the first port
ifneq (,$(findstring com,$(SERIAL_PORT)))
    ARD_PORT      = $(SERIAL_PORT)
else
    ARD_PORT      = $(firstword $(wildcard $(SERIAL_PORT)))
endif
# Implicit rules for building everything (needed to get everything in
# the right directory)
#
# Rather than mess around with VPATH there are quasi-duplicate rules
# here for building e.g. a system C++ file and a local C++
# file. Besides making things simpler now, this would also make it
# easy to change the build options in future

# library sources
$(OBJDIR)/libs/%.o: $(ARDUINO_LIB_PATH)/%.cpp
	@mkdir -p $(dir $@)
	@echo "21 Compiling $@"
	@$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@
$(OBJDIR)/libs/%.o: $(ARDUINO_LIB_PATH)/%.c
	@mkdir -p $(dir $@)
	@echo "20 Compiling $@"
	@$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@
$(OBJDIR)/libs/%.o: $(USER_LIB_PATH)/%.cpp
	@mkdir -p Compiling $(dir $@)
	@echo "19 $@"
	@$(CC) -c $(CPPFLAGS_WITHOUT_USER_LIBS) -I$(dir $<) -I$(dir $<)/utility -I$(dir $<)/.. $(CFLAGS) $< -o $@
$(OBJDIR)/libs/%.o: $(USER_LIB_PATH)/%.c
	@mkdir -p Compiling $(dir $@)
	@echo "18 $@"
	@$(CC) -c $(CPPFLAGS_WITHOUT_USER_LIBS) -I$(dir $<) -I$(dir $<)/utility -I$(dir $<)/.. $(CFLAGS) $< -o $@

# normal local sources
# .o rules are for objects, .d for dependency tracking
# there seems to be an awful lot of duplication here!!!
$(OBJDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "17 Compiling $@"
	@$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: %.cc
	@mkdir -p $(dir $@)
	@echo "16 Compiling $@"
	@$(CXX) -c $(CPPFLAGS) $< -o $@

$(OBJDIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	@echo "15 Compiling $@"
	@$(CXX) -c $(CPPFLAGS) $< -o $@

$(OBJDIR)/%.o: %.S
	@mkdir -p $(dir $@)
	@echo "14 Compiling $@"
	@$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/%.o: %.s
	@mkdir -p $(dir $@)
	@echo "13 Compiling $@"
	@$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/%.d: %.c
	@mkdir -p $(dir $@)
	@echo "12 Compiling $@"
	@$(CC) -MM $(CPPFLAGS) $(CFLAGS) $< -MF $@ -MT $(@:.d=.o)

$(OBJDIR)/%.d: %.cc
	@mkdir -p $(dir $@)
	@echo "11 Compiling $@"
	@$(CXX) -MM $(CPPFLAGS) $< -MF $@ -MT $(@:.d=.o)

$(OBJDIR)/%.d: %.cpp
	@mkdir -p $(dir $@)
	@echo "10 Compiling $@"
	@$(CXX) -MM $(CPPFLAGS) $< -MF $@ -MT $(@:.d=.o)

$(OBJDIR)/%.d: %.S
	@mkdir -p $(dir $@)
	@echo "9 Compiling $@"
	@$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.o)

$(OBJDIR)/%.d: %.s
	@mkdir -p $(dir $@)
	@echo "8 Compiling $@"
	@$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.o)

# the pde -> cpp -> o file
$(OBJDIR)/%.cpp: %.$(SUFFIX)
	@echo "Producing $a"
	@if [ $(CORE_INCLUDE_NAME) ] ; then $(ECHO) $(PDEHEADER) > $@ ; echo Including $(CORE_INCLUDE_NAME) ; fi
	@cat  $< >> $@

$(OBJDIR)/%.o: $(OBJDIR)/%.cpp
	@mkdir -p $(dir $@)
	@echo "7 Compiling $@"
	@$(CXX) -c $(CPPFLAGS) $< -o $@

$(OBJDIR)/%.d: $(OBJDIR)/%.cpp
	@mkdir -p $(dir $@)
	@echo "6 Compiling $@"
	@$(CXX) -MM $(CPPFLAGS) $< -MF $@ -MT $(@:.d=.o)

# core files
$(OBJDIR)/%.o: $(ARDUINO_CORE_PATH)/%.c
	@mkdir -p $(dir $@)
	@echo "5 Compiling $@"
	@$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(ARDUINO_CORE_PATH)/%.cpp
	@mkdir -p $(dir $@)
	@echo "4 Compiling $@"
	@$(CXX) -c $(CPPFLAGS) $< -o $@

# various object conversions
$(OBJDIR)/%.hex: $(OBJDIR)/%.elf
	@echo "Producing $@"
	@$(OBJCOPY) -O ihex -R .eeprom $< $@

$(OBJDIR)/%.eep: $(OBJDIR)/%.elf
	@echo "Producing $@"
	@-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom="alloc,load" \
		--change-section-lma .eeprom=0 -O ihex $< $@

$(OBJDIR)/%.lss: $(OBJDIR)/%.elf
	@echo "Producing $@"
	@$(OBJDUMP) -h -S $< > $@

$(OBJDIR)/%.sym: $(OBJDIR)/%.elf
	@echo "Producing $@"
	@$(NM) -n $< > $@

########################################################################
#
# Avrdude
#
ifndef AVRDUDE
AVRDUDE          = $(AVRDUDE_TOOLS_PATH)/avrdude
endif

AVRDUDE_COM_OPTS = -q -V -p $(MCU)
ifdef AVRDUDE_CONF
AVRDUDE_COM_OPTS += -C $(AVRDUDE_CONF)
endif

AVRDUDE_ARD_OPTS = -c $(AVRDUDE_ARD_PROGRAMMER) -b $(AVRDUDE_ARD_BAUDRATE) -P $(ARD_PORT)

ifndef ISP_PROG
ISP_PROG	   = -c stk500v2
endif

AVRDUDE_ISP_OPTS = -P $(ISP_PORT) $(ISP_PROG)

#######################################################################
#
# Serial monitoring
#

ifndef SERIAL_BAUDRATE
SERIAL_BAUDRATE = 9600
endif

ifndef SERIAL_COMMAND
SERIAL_COMMAND   = picocom
endif

ifndef SERIAL_PORT_FLAG
SERIAL_PORT_FLAG = -D
endif

ifndef SERIAL_BAUDRATE_FLAG
SERIAL_BAUDRATE_FLAG = -b
endif

ifndef SERIAL_ARGS
SERIAL_ARGS = $(SERIAL_PORT_FLAG) $(SERIAL_PORT) \
			  $(SERIAL_BAUDRATE_FLAG) $(SERIAL_BAUDRATE)
endif

########################################################################
#
# Explicit targets start here
#

all: 		$(OBJDIR) $(TARGET_HEX)

$(OBJDIR):
		@mkdir -p $(OBJDIR)

$(TARGET_ELF): 	$(LOCAL_OBJS) $(CORE_LIB) $(OTHER_OBJS)
		@echo "Producing $(TARGET_ELF)"
		@$(CC) $(LDFLAGS) -o $@ $(LOCAL_OBJS) $(CORE_LIB) $(OTHER_OBJS) -lc -lm

$(CORE_LIB):	$(CORE_OBJS) $(LIB_OBJS) $(USER_LIB_OBJS)
		@echo "Producing $(CORE_LIB)"
		@$(AR) rcs $@ $(CORE_OBJS) $(LIB_OBJS) $(USER_LIB_OBJS)

upload:		$(OBJDIR) reset raw_upload

raw_upload:	$(TARGET_HEX)
		@echo "Uploading $(TARGET_HEX) to device"
		@$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ARD_OPTS) -U flash:w:$(TARGET_HEX):i

# stty on MacOS likes -F, but on Debian it likes -f redirecting
# stdin/out appears to work but generates a spurious error on MacOS at
# least. Perhaps it would be better to just do it in perl ?
reset:
	@$(ARDUINO_MK_PATH)$(RESET_SERIAL) $(ARD_PORT)

ispload:	$(TARGET_HEX)
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -e \
			-U lock:w:$(ISP_LOCK_FUSE_PRE):m \
			-U hfuse:w:$(ISP_HIGH_FUSE):m \
			-U lfuse:w:$(ISP_LOW_FUSE):m \
			-U efuse:w:$(ISP_EXT_FUSE):m
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -D \
			-U flash:w:$(TARGET_HEX):i
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) \
			-U lock:w:$(ISP_LOCK_FUSE_POST):m

serial:
	$(SERIAL_COMMAND) $(SERIAL_ARGS)

clean::
	rm -rf $(OBJDIR)/*

size:		$(OBJDIR) $(TARGET_HEX)
		$(SIZE) $(TARGET_HEX)

show_boards:
	@cat $(BOARDS_TXT) | grep -E "^[[:alnum:]]" | cut -d . -f 1 | uniq

.PHONY:	all clean upload raw_upload reset show_boards
