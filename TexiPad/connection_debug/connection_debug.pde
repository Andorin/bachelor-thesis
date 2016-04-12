import processing.serial.*;

final int sensorArraySize = 40;
final int screensize = 800;

Serial myPort;
int portNumber;
boolean[] sensorData  = new boolean[sensorArraySize];
int serialDataIndex = 0;
int squarsize = screensize/ (sensorData.length/2);

void setup() {
  //myPort = new Serial(this, "/dev/tty.usbmodem0F0009F1", 9600);
  myPort = new Serial(this, "/dev/tty.usbmodem0F003961", 9600);
  //myPort = new Serial(this, "/dev/cu.HC-06-DevB", 9600);
  size(1200, 1200);
}

void draw() {
  background(27, 50, 95);
  getSerialData();
  drawSensorData();
}


void getSerialData() {
  while (myPort.available () > 0) {
    char readChar = myPort.readChar();
    if (readChar == '\n') {
      serialDataIndex = 0;
      println();
    } else  if (readChar == '0') {
      sensorData[serialDataIndex] = false;
      serialDataIndex++;
      print("0");
    } else  if (readChar == '1') {
      sensorData[serialDataIndex] = true;
      serialDataIndex++;
      print("1");
    }
    if (serialDataIndex>(sensorArraySize-1)) serialDataIndex = 0;
  }
}

void drawSensorData(){
  for (int i=0; i < (sensorData.length/2); i++) {
    for (int j=(sensorData.length/2); j<sensorData.length; j++) {
      if(sensorData[i] && sensorData[j]){
        fill(0);
      } else {
        fill(255);
      }
      rect(i*squarsize, (j-(sensorData.length/2))*squarsize, squarsize, squarsize);
    }
  }
}