// pinout paperprototyp
//int pad[] = {
//  38, 23, 24,
//  36, 37, 25, 26, 
//  33, 34, 35, 27, 28,
//  11, 31, 32, 29, 10,  9,
//  14, 13, 12,  8,  7,
//  17, 15,  6,  5,
//  18, 19,  2
//};

// pinout textile pad
/*int pad[] = {
  18,  2,  5,
  15, 17,  6,  7, 
  13, 14, 19,  8,  9,
  11, 31, 12, 10, 28, 29,
  32, 33, 38, 26, 27,
  34, 35, 24, 25,
  36, 37, 23
};*/
/*
int array[] = {
  18, 17, 16, 15, 14, 13, 12, 11,
  3, 4, 5, 6, 7, 8, 9, 10
};*/

//taped prototype
/*int array[] = {
  30, 2,3, 4, 5,6, 7, 8, 9, 10,
  70, 42, 43, 44, 45, 46, 47, 48, 49, 50  
};*/

//for newest prototype 10x10
/*int array[] = {
  71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
  31, 32, 33, 34, 35, 36, 37, 18 , 39, 40,
};*/

//for newest prototype 14x14
int array[] = {
  51, 52, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 59, 58,
  11, 12, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 18, 19
};

//prototype 20x20
/*int array[] = {
  2, 3, 4, 5, 6, 7, 8, 9, 10, 30, 40, 39, 18, 37, 36, 34, 33, 32, 31, 11,
  71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 42, 43, 44, 45, 46, 47, 48, 49, 50, 70  
};*/

// for msp430
/*int array[] = {
  7, 8, 9, 10,
  2, 4, 5, 6
};*/

char state;

void setup() {
  Serial.begin(9600);
  
  for(int i=0; i<28; i++){
    pinMode(array[i], OUTPUT);
    digitalWrite(array[i], LOW);
  }
}

void loop() {
  // for each pad test if connection to another pad exists
  for (int i=0; i<28; i++) {
    pinMode(array[i], INPUT_PULLUP);
    delay(2);
    state = digitalRead(array[i]) ? '0' : '1';
    pinMode(array[i], OUTPUT);
    digitalWrite(array[i], LOW);
    Serial.print(state);
    //if ((i+1)%5==0) Serial.print(" ");
  }
  Serial.println();
  delay(3);
}
