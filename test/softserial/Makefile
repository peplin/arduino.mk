TARGET  = softserialtest
# BOARD_TAG: do make show_boards to list all valid boards
BOARD_TAG    = attiny85-8
#BOARD_TAG    = nano328

# Define KEEPFUSES = 1 if you don't want to burn the buses
# KEEPFUSES = 1

# Sketchbook location needed to descriminate between ~/arduino/arduino-1.0/hardware/arduino/variants
# and varients within sketchbook per MIT's High-Low tech http://hlt.media.mit.edu/?p=1695
# https://github.com/damellis/attiny/tree/Arduino1
ARDUINO_DIR  = /home/ecomer/arduino/arduino-1.0
ARDUINO_SKETCHBOOK = /home/ecomer/arduino/arduino-1.0/sketchbook
ARDUINO_MAKEFILE_HOME = /home/ecomer/arduino
ARDUINO_LIBS = SoftwareSerial
ARDUINO_PORT = /dev/ttyUSB*

# .SECONDARY: will cause the intermediary files to be kept
# .SECONDARY:

include $(ARDUINO_MAKEFILE_HOME)/Arduino.mk

