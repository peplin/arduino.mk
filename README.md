# Arduino.mk

This is a versioned history of the work done by Martin Oldfield on an Arduino
Makefile. He releases tarballs on his website, so this version might be a bit
easier if you want to track your modifications.

The various released versions (0.3, 0.4, etc) are tagged in this repository.

The original blog post: http://mjo.tc/atelier/2009/02/arduino-cli.html

A blog post on the addition of chipKIT support:
http://christopherpeplin.com/2011/12/chipkit-arduino-makefile/

## chipKIT Support

This version adds support for the Digilent chipKIT Uno32 and Max32, both
Arduino-compatible microcontrollers. To use this Makefile with one of those,
include `chipKIT.mk` instead of `Arduino.mk` at the bottom of your Makefile.

    include /path/to/chipKIT.mk

You can adjust the same variables as described by Martin for `Arduino.mk`, but
point to an MPIDE installation (which includes the chipKIT toolchain) instead of
the Arduino IDE.
