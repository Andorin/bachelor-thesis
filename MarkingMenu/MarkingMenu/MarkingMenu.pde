import processing.serial.*;
import de.voidplus.dollar.*;

OneDollar one;
String name;

Serial myPort;
final int sensorArraySize = 28;

final int xCoord = 500;
final int yCoord = 500;
final int scale = 200;
final int userID = 1;
final int maxTrials = 25;
final String studyCondition = "table_jeans_yellow";
                              
final String[] gestureString = {"up", "up right", "up left", "up down", "right", "right up", "right down", "right left", "down", "down left", "down right", "down up", "left", "left up", "left down", "left right"};
final String[] directionString = {"N", "NE", "NW", "NS", "E", "EN", "ES", "EW", "S", "SW", "SE", "SN", "W", "WN", "WS", "WE"};
final String[] freeFormString = {"swipe", "x", "z", "w", "hat", "bowl", "pigtail", "zigzag", "spiral", "c", "slope", "dart", "doubleSlope", "rightAngle", "leftAngle", "tab"};

//only 4 or 8 are working atm
final int noOfMenuItems = 4;
final boolean freeFormGestures = true;
final String gestureType = "freeForm"; /*markBased*/ /*letters*/
Menu menu = new Menu(xCoord, yCoord, scale, noOfMenuItems);
LowPass lowPass = new LowPass(sensorArraySize, xCoord, yCoord);
int serialDataIndex = 0;
float[] sensorData  = new float[sensorArraySize];
public boolean currentTouch = false;
public boolean menuShown = false;
int strokeThreshhold = 2000;
long menuTimer = 0;
int menuThreshhold = 3000;
long strokeTimer = 0;
TEvent touchEvent = new TEvent(noOfMenuItems);
PrintWriter logfile_filtered, logfile_raw;
int logCounter = -1;
float startTime = 0;
float errorrate = 0;
int errorCount = 0;
int gesturenIndex = 0;

void setup(){
//iMAC
   //myPort = new Serial(this, "/dev/tty.usbmodem0F003961", 28800);
   //myPort = new Serial(this, "/dev/tty.usbmodem0F0009F1", 9600);
   //BLUETOOTH
   myPort = new Serial(this, "/dev/cu.HC-06-DevB", 9600);
//Windows
  //myPort = new Serial(this, "COM3", 9600);
  size(1000, 1000);
  logfile_filtered = createWriter("logfile_" + userID + studyCondition + "filtered.txt");
  logfile_filtered.println("UserID: " + userID);
  logfile_raw = createWriter("logfile_" + userID + studyCondition + "raw.txt");
  logfile_raw.println("UserID: " + userID);
  background(255);
  fill(0);
  textSize(24);
  gesturenIndex = int(random(gestureString.length));
  text("next gesture: " + gestureString[gesturenIndex],100,100);
  
  //initialize OneDollar and create instance
  one = new OneDollar(this);
  //some settings for OneDollar
  one.setMinSimilarity(60);
  one.setMinDistance(1).enableMinDistance();
  println(one);
  one.setVerbose(true);
  
  
  if(gestureType == "freeForm"){
    //add gesture templates for freeform gestures Bragdon et al.
    //one.learn("swipe",       new int[] {0,0 , 1,0 , 2,0, 3,0 , 4,0 , 5,0, 6,0});
    //one.learn("rightAngle",  new int[] {0,0 , 1,0 , 2,0, 3,0 , 3,0 , 4,0 , 5,0 , 5,1 , 5,2 , 5,3 , 5,4 , 5,5});
    //one.learn("leftAngle",  new int[] {0,0 , 1,0 , 2,0, 3,0 , 3,0 , 4,0 , 5,0 , 5,-1 , 5,-2 , 5,-3 , 5,-4 , 5,-5});
    //one.learn("x",           new int[] {0,0 , 1,1 , 2,2, 3,3 , 3,2 , 3,1 , 3,0, 2,1, 1,2, 0,3});
    one.learn("z",           new int[] {0,0 , 1,0, 2,0, 1,1 , 0,2 , 1,2 , 2,2});
    one.learn("w",           new int[] {0,0, 0,1, 1,2, 1,3, 2,3, 3,2 , 3,1 , 3,2 , 4,3 , 5,3 , 6,2 , 6,1, 7,0});
    one.learn("hat",         new int[] {0,0 , 1,-1 , 2,-2 , 3,-3 , 4,-4 , 5,-3 , 6,-2 , 7,-1 , 8,0});
    one.learn("bowl",        new int[] {0,0 , 1,1 , 2,2 , 3,3 , 4,4 , 5,3 , 6,2 , 7,1 , 8,0});
    one.learn("pigtail",     new int[] {0,0 , 1,-1 , 2,-2 , 2,-3 , 1,-4 , 0,-3 , 0,-2 , 1,-1 , 2,-1 , 3,-2 , 4,-2});
    //one.learn("zigzag",      new int[] {0,0 , 1,1 , 2,2 , 3,1 , 4,0 , 5,-1 , 6,-2 , 7,-1 , 8,0});
    one.learn("spiral",      new int[] {0,0 , 1,-1 , 2,-1, 3,0 , 4,1, 4,2, 4,3, 3,4, 2,4 , 1,3 , 1,2, 2,2});
    //one.learn("c",           new int[] {0,0 , 1,-1 , 2,-1, 3,0 , 4,1, 4,2, 4,3, 3,4, 2,4 , 1,3});
    one.learn("slope",       new int[] {0,0 , 1,1 , 2,2 , 3,3 , 3,4 , 2,5 , 1,5 , 0,4 , 1,3 , 2,2 , 3,1 , 4,0});
    //one.learn("dart",        new int[] {0,0 , 1,0 , 2,0 , 3,1 , 4,1 , 5,1 , 4,1 , 3,1 , 2,2 , 1,2 , 0,2});
    one.learn("doubleSlope", new int[] {0,0 , 1,-1 , 2,-2 , 2,-3 , 1,-4 , 0,-3 , 0,-2 , 1,-1 , 1,0 , 2,1 , 2,2 , 2,3 , 1,4 , 0,3 , 1,2 , 2,1 , 3,0});
    //one.learn("tab",         new int[] {0,0});
    
    //bind templates to methods
    one.bind("swipe x z w hat bowl pigtail zigzag spiral c slope dart doubleSlope rightAngle leftAngle", "detected"); 
  }
  
  if(gestureType == "letter"){
    one.learn("a", new int[] {0,0 , -1,-1 , -2,-1 , -3,-1 , -4,0 , -4,});
  }
  
} //<>//

//implement callbacks
void detected(String gesture, float percent, int startX, int startY, int centroidX, int centroidY, int endX, int endY){
  println("Gesture: "+gesture+", "+startX+"/"+startY+", "+centroidX+"/"+centroidY+", "+endX+"/"+endY);    
  name = gesture;
  fill(255);
  stroke(255);
  rect(80, 80, 400, 50);
  fill(0);
  text("gesture detected:    " + name,100,100);
  stroke(0);
} //<>//

void draw(){
  if (!currentTouch){
    //background(27, 50, 95);
  }
  getSerialData();  

  //check if touch is longer than threshhold for showing menu
  if (menuTimer + menuThreshhold < millis() && currentTouch && !menuShown){
      //menu.drawMenu(lowPass.result, touchEvent.getDirection(lowPass.resultAngle));
      menuShown = true;
  }
}

void handleGesture(){
  touchEvent.coordBuffer = lowPass.markingBuffer;
  if(gestureType == "markBased"){ //<>//
    if(touchEvent.isTap()){
      println("Tap: true");
    }else if(touchEvent.isSwipe()){
      println("Tap: false, Swipe: " + touchEvent.direction1);
      menu.triggerMenuItem(touchEvent.direction1 + touchEvent.direction1);
    }else if(touchEvent.isAngle()){ //<>//
      println("Tap: false, Swipe: false, Angle: true  " + touchEvent.direction1 + touchEvent.direction2);
      menu.triggerMenuItem(touchEvent.direction1 + touchEvent.direction2);
    }else{
      println("Tap: false, Swipe: false, Angle: false");
    }
  }
  
  if(gestureType == "freeForm"){
    sendToDollar();
  }
  
  if(gestureType == "letters"){
    sendToDollar();
  }
}

void writeLogFile(){
  if(logCounter == maxTrials){
    logfile_filtered.close();
  }
  
    startTime = lowPass.markingBuffer.get(0)[2];
    if(gestureType == "markBased"){
      //input expected
      logfile_filtered.println(directionString[gesturenIndex]+";");
      //input recognised
      logfile_filtered.println(touchEvent.direction1 + touchEvent.direction2+";");
    }else if( gestureType == "freeForm"){
      //input expected
      logfile_filtered.println(freeFormString[gesturenIndex]+";");
      //input recognised
      logfile_filtered.println(name+";");
    }
    if(directionString[gesturenIndex].equals(touchEvent.direction1 + touchEvent.direction2) && gestureType == "markBased"){
      //correct gesture
      logfile_filtered.println("yes;");
    }else if(freeFormString[gesturenIndex].equals(name) && gestureType == "freeForm"){
      //correct gesture
      logfile_filtered.println("yes;");
    }else{
      //wrong gesture
      logfile_filtered.println("no;");
      errorCount++;
    }
    
    float temp = lowPass.markingBuffer.get(0)[2];
    for(int i = 0; i < lowPass.markingBuffer.size(); i++){
      float modTime = lowPass.markingBuffer.get(i)[2] - temp;
      logfile_filtered.println(lowPass.markingBuffer.get(i)[0] + ";" + lowPass.markingBuffer.get(i)[1] + ";" + modTime+";");
    }
    //print ;; at the end of a gesture
    logfile_filtered.println(";");
    logfile_filtered.flush();
  
  logCounter++;
}

void sendToDollar(){
  for(int i = 0; i < lowPass.markingBuffer.size(); i++){
    one.track(lowPass.markingBuffer.get(i)[0] - lowPass.initX, lowPass.markingBuffer.get(i)[1] - lowPass.initY);
  }
  println("Detected gesture: " + name);
}

void getSerialData() {
  while (myPort.available () > 0) {
    char readChar = myPort.readChar();

    if (readChar == '\n') {
      lowPass.filter();
      if(currentTouch){
        logfile_raw.println(";"+millis());
      }
      logfile_raw.flush();

      //new touch. set start coordinates for menu
      if (lowPass.buffer.contains(1.0) && !currentTouch && !lowPass.buffer.contains(null) && !lowPass.markingBuffer.isEmpty()){
      	lowPass.initX = lowPass.markingBuffer.get(0)[0];
      	lowPass.initY = lowPass.markingBuffer.get(0)[1];
      	strokeTimer = millis();
      	menuTimer = millis();
          background(255);
      	currentTouch = true;
      }

      //clear buffer and reset first lines starting point
      //we are uing timeout because some points are not detected during a gesture
      if (!lowPass.buffer.contains(1.0) && currentTouch && strokeTimer + strokeThreshhold < millis()){
        currentTouch = false;
        lowPass.plot(strokeTimer);
        menuShown = false;
        handleGesture();
        logfile_raw.println(";");
        writeLogFile();
        gesturenIndex = int(random(gestureString.length));
        lowPass.markingBuffer.clear();
      }

      serialDataIndex = 0;
      lowPass.buffer.clear();

    } else  if (readChar == '0') {
      sensorData[serialDataIndex] = 0.0;
      lowPass.buffer.add(0.0);
      serialDataIndex++;
      if(currentTouch){
        logfile_raw.print(0);
      }

    } else  if (readChar == '1') {
      sensorData[serialDataIndex] = 1.0;
      lowPass.buffer.add(1.0);
      serialDataIndex++;
      if(currentTouch){
        logfile_raw.print(1);
      }
    }
    if (serialDataIndex>(sensorArraySize-1)) serialDataIndex = 0;
  }
}