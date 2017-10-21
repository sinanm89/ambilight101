//int ledPin=13;
//int sensorPin=7;
//boolean val =0;
//
//void setup(){
//  pinMode(ledPin, OUTPUT);
//  pinMode(sensorPin, INPUT);
//  Serial.begin (9600);
//}
//  
//void loop (){
//  val =digitalRead(sensorPin);
//  Serial.println (val);
//  // when the sensor detects a signal above the threshold value, LED flashes
//  if (val==HIGH) {
//    digitalWrite(ledPin, HIGH);
//  }
//  else {
//    digitalWrite(ledPin, LOW);
//  }
//}
int val=0;
void setup ()
{
  pinMode (13, OUTPUT) ;// define LED as output interface
  pinMode (3, INPUT) ;// output interface D0 is defined sensor
}
 
void loop () {
  val = digitalRead(3);// digital interface will be assigned a value of pin 3 to read val
  if (val == HIGH) // When the sound detection module detects a signal, LED flashes
  {
    digitalWrite (13, HIGH);
  }
  else
  {
    digitalWrite (13, LOW);
  }                 // wait for a second
}
