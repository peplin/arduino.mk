#include "WProgram.h"
#include "Wire.h"
//#include "I2C_Serial.h"
#include "foo.h"

/*
 Blink
 Turns on an LED on for one second, then off for one second, repeatedly.
 
 This example code is in the public domain.
 */

//I2C_Serial myI2C;

void setup() {                
    // initialize the digital pin as an output.
    // Pin 13 has an LED connected on most Arduino boards:
    pinMode(13, OUTPUT);     
    
    Serial.begin(9600);
    Serial.print("\n\n\n***\n");
    Serial.print(foovalue, DEC);
    
    
    Wire.begin();
//    myI2C.begin();
}

void loop() {
    digitalWrite(13, HIGH);    // set the LED on
    delay(100);              // wait for a second
    digitalWrite(13, LOW);    // set the LED off
    Serial.print(".");
    
    delay(1000);              // wait for a second
}