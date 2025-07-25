#include <Wire.h>
#include <RTClib.h>

RTC_DS3231 rtc;//Dios, me tire una hora porque me dijeron que disque era catodo comun, todo esta en anodo comun ahora

const uint8_t segPins[7]  = {2, 3, 4, 5, 6, 7, 8};   // a b c d e f g
const uint8_t digPins[4]  = {9, 10, 11, 12};         // catodos (digitos)

//Tabla con los numeros preestablecidos
const uint8_t segMap[10] = {
  0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110,
  0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111
};

uint8_t digits[4];          
unsigned long tSec = 0;    

void setSegments(uint8_t pattern) {
  for (uint8_t s = 0; s < 7; s++) {
    bool bit = (pattern >> s) & 0x01;          
    digitalWrite(segPins[s], bit ? LOW : HIGH);
  }
}

//Imprime en el display
void refreshDisplay() {
  for (uint8_t d = 0; d < 4; d++) {
    digitalWrite(digPins[d], HIGH);          
    setSegments(segMap[digits[d]]);         
    delayMicroseconds(2000);                
    digitalWrite(digPins[d], LOW);         
  }
}

//refresque digitos
void updateDigits() {
  DateTime now = rtc.now();
  digits[0] = now.hour()   / 10;  // h1
  digits[1] = now.hour()   % 10;  // h2
  digits[2] = now.minute() / 10;  // m1
  digits[3] = now.minute() % 10;  // m2
}

//Configuración de rtc
void setup() {
  Serial.begin(9600);  

  for (uint8_t p : segPins) pinMode(p, OUTPUT), digitalWrite(p, HIGH); 
  for (uint8_t p : digPins) pinMode(p, OUTPUT), digitalWrite(p, LOW); 
  Wire.begin();
  rtc.begin();

  rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
}

//bucle
void loop() {
  if (millis() - tSec >= 1000) {  
    updateDigits();
    tSec = millis();
  }
  refreshDisplay();    

  Serial.print(digits[0]);
  Serial.print(digits[1]);
  Serial.print (':'); 
  Serial.print(digits[2]);
  Serial.println(digits[3]);           
}