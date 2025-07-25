#include <Wire.h>
#include <RTClib.h>

RTC_DS3231 rtc;

//Para convertir los valores a binarios, tiene que ser 4 bits, 1 al 9-

void printBin(uint8_t value, uint8_t bits = 4) {
  //Se pregunta cual es el valor y se recorren los i bits del valor (Siempre de 3 a 0 ya esta preeestablecido)
  //Luego con la funcion bitRead se recorre del valor sus bits en longitud desde MSB a LSB y se imprime
  for (int8_t i = bits - 1; i >= 0; --i) Serial.print(bitRead(value, i));
}

//Se inicia el RTC serial para cpmunicacion con el pc, eso quiere deci que enviará una cadena de bits cada vez
void setup() {
  Serial.begin(9600);
  while (!Serial);        
  Wire.begin();
  rtc.begin();
}

//Aqui se imprime lo que se quiera con la función de convertir a binario, se separa la hora que se da en cada digito (por 7 segmentos)
void loop() {
  DateTime now = rtc.now();

  uint8_t h1 = now.hour()   / 10;  
  uint8_t h2 = now.hour()   % 10;   
  uint8_t m1 = now.minute() / 10;   
  uint8_t m2 = now.minute() % 10;   

  printBin(h1); Serial.print(' ');
  printBin(h2); Serial.print(' ');
  printBin(m1); Serial.print(' ');
  printBin(m2); Serial.println();

  delay(1000);
}