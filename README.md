# Arduino.mk

This is a versioned history of the work done by Martin Oldfield on an Arduino
Makefile. He releases tarballs on his website, so this version might be a bit
easier if you want to track your modifications.

The various released versions (0.3, 0.4, etc) are tagged in this repository.

The original blog post: http://mjo.tc/atelier/2009/02/arduino-cli.html

A blog post on the addition of chipKIT support:
http://christopherpeplin.com/2011/12/chipkit-arduino-makefile/

This Makefile current requires either Arduino 1.0 or MPIDE 0023.

## chipKIT Support

This version adds support for the Digilent chipKIT Uno32 and Max32, both
Arduino-compatible microcontrollers. To use this Makefile with one of those,
include `chipKIT.mk` instead of `Arduino.mk` at the bottom of your Makefile.

    include /path/to/chipKIT.mk

You can adjust the same variables as described by Martin for `Arduino.mk`, but
point to an MPIDE installation (which includes the chipKIT toolchain) instead of
the Arduino IDE.

## Libraries

The Makefile will look for libraries in two places:

* In the Arduino/MPIDE installation directory under the `libraries` directory
* In the `libraries` directory in your Arduino sketchbook. This location is the
  preferred location for user libraries when using the IDE.

## Example

To compile the basic blink example sketch, set the `ARDUINO_MAKEFILE_HOME`
variable to point to where you clone this repository and use this for your
Makefile:

    TARGET       = blink
    BOARD_TAG    = mega_pic32

    SERIAL_PORT = /dev/ttyUSB*

    include $(ARDUINO_MAKEFILE_HOME)/chipKIT.mk

## Options

If you are defining your own `main()` function, you can stop the Ardunio's
built-in `main()` from being compiled with your code by defining the
`NO_CORE_MAIN_FUNCTION` variable:

    NO_CORE_MAIN_FUNCTION = 1

## Contributors

* Martin Oldfield (initial version)
* Chris Peplin (chipKIT)
* rei_vilo / Olivier
* Edward Comer
