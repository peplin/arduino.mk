// include the SoftwareSerial library so you can use its functions:
#include <SoftwareSerial.h>

#define rxPin 0	//ATtiny physical pin 5
#define txPin 1	//ATtiny physical pin 6

SoftwareSerial softSerial =  SoftwareSerial(rxPin, txPin);

int c;

void setup()  {
  // set the data rate for the SoftwareSerial port
  softSerial.begin(9600);
  softSerial.println("Software Serial rx: ");
}

void loop()                     // run over and over again
{
  if (softSerial.available()) {
      c = softSerial.read();
      softSerial.write(c);
  }
}

/*
SoftwareSerial softSerial =  SoftwareSerial(rxPin, txPin);

void setup()  {
  pinMode(LEDPIN, OUTPUT);
  Serial.begin(9600);
  Serial.println("Sent to regular serial");

  // set the data rate for the SoftwareSerial port
  softSerial.begin(9600);
  softSerial.println("Sent to Software Serial");
}

void loop()                     // run over and over again
{
  if (softSerial.available()) {
      Serial.print((char)softSerial.read());
  }
  if (Serial.available()) {
      softSerial.print((char)Serial.read());
  }
}
*/
