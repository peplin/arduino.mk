TARGET       = blink
ifdef DEBUG
BOARD_TAG    = mega_pic32_dbg
else
BOARD_TAG    = mega_pic32
endif
ARDUINO_LIBS = Wire Wire/utility

SERIAL_PORT = /dev/ttyUSB*

include $(ARDUINO_MAKEFILE_HOME)/chipKIT.mk
