#include <Servo.h>
int numberOfServos = 5;
int offset = 2;

Servo servos[5];  // create servo object to control a servo

byte values[] = {63,63,63,63,63};

void setup() {
  Serial.begin(9600); // initialize serial:
  for(int i = 0; i<numberOfServos; i++){
    servos[i].attach(i+offset);
  }
}

void loop() {
  // if there's any serial available, read it:
  while (Serial.available() > 0){
    Serial.readBytes(values,numberOfServos);
    for(int i = 0; i<numberOfServos; i++){
      Serial.write(values[i]);
      int val = map((int)values[i], 0, 127, 0, 180);
      servos[i].write(val);
    }
  }
  delay(15); // waits for servos to get there
}
