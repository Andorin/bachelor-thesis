import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class MarkingMenu extends PApplet {



Serial myPort;
final int sensorArraySize = 20;

final int xCoord = 500;
final int yCoord = 500;
final int scale = 200;
//only 4 or 8 are working atm
final int noOfMenuItems = 4;
Menu menu = new Menu(xCoord, yCoord, scale, noOfMenuItems);
LowPass lowPass = new LowPass(sensorArraySize, xCoord, yCoord);
int serialDataIndex = 0;
float[] sensorData  = new float[sensorArraySize];
public boolean currentTouch = false;
public boolean menuShown = false;
int strokeThreshhold = 500;
long menuTimer = 0;
int menuThreshhold = 3000;
long strokeTimer = 0;
TEvent touchEvent = new TEvent(noOfMenuItems);

public void setup(){
//iMAC
  //myPort = new Serial(this, "/dev/tty.usbmodem0F003961", 9600);
//Windows
  myPort = new Serial(this, "COM3", 9600);
  
  background(27, 50, 95);
}

public void draw(){
  if (!currentTouch){
    background(27, 50, 95);
  }
  getSerialData();

  //check if touch is longer than threshhold for showing menu
  if (menuTimer + menuThreshhold < millis() && currentTouch && !menuShown){
      menu.drawMenu(lowPass.result, touchEvent.getDirection(lowPass.resultAngle));
      menuShown = true;
  }
}

public void handleGesture(){
  touchEvent.coordBuffer = lowPass.markingBuffer;

  if(touchEvent.isTap()){
    println("Tap: true");
  }else if(touchEvent.isSwipe()){
    println("Tap: false, Swipe: " + touchEvent.direction1 + touchEvent.direction1);
    menu.triggerMenuItem(touchEvent.direction1 + touchEvent.direction1);
  }else if(touchEvent.isAngle()){
    println("Tap: false, Swipe: false, Angle: true  " + touchEvent.direction1 + touchEvent.direction2);
    menu.triggerMenuItem(touchEvent.direction1 + touchEvent.direction2);
  }else{
    println("Tap: false, Swipe: false, Angle: false");
  }
}

public void getSerialData() {
  while (myPort.available () > 0) {
    char readChar = myPort.readChar();

    if (readChar == '\n') {
      lowPass.filter();

      //new touch. set start coordinates for menu
      if (lowPass.buffer.contains(1.0f) && !currentTouch && !lowPass.buffer.contains(null) && !lowPass.markingBuffer.isEmpty()){
      	lowPass.initX = lowPass.markingBuffer.get(0)[0];
      	lowPass.initY = lowPass.markingBuffer.get(0)[1];
      	strokeTimer = millis();
      	menuTimer = millis();
      	currentTouch = true;
      }

      //clear buffer and reset first lines starting point
      if (!lowPass.buffer.contains(1.0f) && currentTouch && strokeTimer + strokeThreshhold < millis()){
      	currentTouch = false;
        menuShown = false;
        handleGesture();
      	lowPass.markingBuffer.clear();
      }

      serialDataIndex = 0;
      lowPass.buffer.clear();

    } else  if (readChar == '0') {
      sensorData[serialDataIndex] = 0.0f;
      lowPass.buffer.add(0.0f);
      serialDataIndex++;

    } else  if (readChar == '1') {
      sensorData[serialDataIndex] = 1.0f;
      lowPass.buffer.add(1.0f);
      serialDataIndex++;

    }
    if (serialDataIndex>(sensorArraySize-1)) serialDataIndex = 0;
  }
}
class LowPass{
  float[] result = new float[2];
  float tempX = 0;
  float tempY = 0;
  int counter = 0;
  ArrayList buffer;
  ArrayList<float[]> markingBuffer;
  PVector oldP = new PVector(500, 500, 0);
  float initX, initY = 0;
  int xCoord, yCoord;
  double resultAngle;
  
  LowPass(int length, int xCoord, int yCoord){
    buffer = new ArrayList(length);
    markingBuffer = new ArrayList<float[]>();
    this.xCoord = xCoord;
    this.yCoord = yCoord;
  }
  
  public void drawPath(float x, float y){
    if (markingBuffer.size() == 1){
      oldP.x = xCoord;
      oldP.y = yCoord;
    }else if(markingBuffer.size() >= 2){
      line((oldP.x - initX)  * 50 + xCoord, (oldP.y - initY)  * 50 + yCoord, (x - initX) * 50 + xCoord, (y - initY) * 50 + yCoord);
    }
    oldP.set(x, y);
  }
  
  public void filter(){
    for (int i=0; i < (sensorData.length/2); i++) {
      for (int j=(sensorData.length/2); j<sensorData.length; j++){
        if (sensorData[i] > 0 && sensorData[j] > 0){
          tempY += j-10;
          tempX += i;
          counter++;
        }
      }
    }

    if (counter > 0){
      markingBuffer.add(new float[]{tempX/counter, tempY/counter, millis()});
      drawPath(tempX/counter, tempY/counter);
      result[0] = tempX/counter - initX;
      result[1] = tempY/counter - initY;
      resultAngle = (double) Math.toDegrees(Math.atan2(result[1] , result[0]));
    }

    tempX = 0;
    tempY = 0;
    counter = 0;
  }
}
class Menu{
	int noOfMenuItems, scale = 0;

	String[][] menuItems = {{"0", "00", "01", "02", "03"},
             				{"1", "10", "11", "12", "13"},
             				{"2", "20", "21", "22", "23"},
            				{"3", "30", "31", "32", "33"}};

	int xCoord, yCoord, firstDirection;
	float startAngle, endAngle, angle;

	public Menu(int xCoord, int yCoord, int scale, int noOfMenuItems) {
		this.noOfMenuItems = noOfMenuItems;
		this.xCoord = xCoord;
		this.yCoord = yCoord;
		this.scale = scale;
	}

	public void drawMenu(float[] result, String direction){
		for (int i = 0; i < noOfMenuItems; ++i) {
			startAngle = (270 - (360/noOfMenuItems)/2 + (360/noOfMenuItems * i)) ;
			endAngle   = (270 + (360/noOfMenuItems)/2 + (360/noOfMenuItems * i)) ;

			if (direction.equals(Integer.toString(i))) {
				fill(123);
				firstDirection = i;
			}else {
				fill(255);
			}

			arc(xCoord, yCoord, scale, scale, radians(startAngle), radians(endAngle), PIE);
		}

		fill(0);
		if (noOfMenuItems == 4) {
			text(menuItems[0][0], xCoord, yCoord - scale/3);
			text(menuItems[1][0], xCoord + scale/3, yCoord);
			text(menuItems[2][0], xCoord, yCoord + scale/3);
			text(menuItems[3][0], xCoord - scale/3, yCoord);
		}

		fill(255);
		for (int i = 0; i < noOfMenuItems; ++i) {
			startAngle = (270 - (360/noOfMenuItems)/2 + (360/noOfMenuItems * i)) ;
			endAngle   = (270 + (360/noOfMenuItems)/2 + (360/noOfMenuItems * i)) ;

			arc(xCoord + result[0] * 50, yCoord + result[1] * 50, scale, scale, radians(startAngle), radians(endAngle), PIE);
		}

		fill(0);
		if (noOfMenuItems == 4) {
			text(menuItems[firstDirection][1], xCoord + result[0] * 50, yCoord + result[1] * 50 - scale/3);
			text(menuItems[firstDirection][2], xCoord + result[0] * 50 + scale/3, yCoord + result[1] * 50);
			text(menuItems[firstDirection][3], xCoord + result[0] * 50, yCoord + result[1] * 50 + scale/3);
			text(menuItems[firstDirection][4], xCoord + result[0] * 50 - scale/3, yCoord + result[1] * 50);
		}
	}

	public void triggerMenuItem(String direction1){
		// println("direction1: "+direction1);
		// if (noOfMenuItems == 4) {
		// 	switch (direction1) {
		// 		case "north" :
		// 			println("menuItem: 00");
		// 		break;	
		// 		case "east" :
		// 			println("menuItem: 11");
		// 		break;	
		// 		case "south" :
		// 			println("menuItem: 22");
		// 		break;	
		// 		case "west" :
		// 			println("menuItem: 33");
		// 		break;	
		// 	}
		// }else if (noOfMenuItems == 8) {
		// 	switch (direction1) {
		// 		case "north" :
		// 			println("menuItem: 00");
		// 		break;	
		// 		case "northeast" :
		// 			println("menuItem: 11");
		// 		break;	
		// 		case "east" :
		// 			println("menuItem: 22");
		// 		break;	
		// 		case "southeast" :
		// 			println("menuItem: 33");
		// 		break;
		// 		case "south" :
		// 			println("menuItem: 44");
		// 		break;
		// 		case "southwest" :
		// 			println("menuItem: 55");
		// 		break;
		// 		case "west" :
		// 			println("menuItem: 66");
		// 		break;	
		// 		case "northwest" :
		// 			println("menuItem: 77");
		// 		break;
		// 	}
		// }
	}
}
class TEvent{
  int index = 0;
  ArrayList<float[]> coordBuffer;
  float[] start = new float[2];
  float[] end = new float[2];
  float[] temp = new float[2];
  String direction1, direction2;
  double lineDistance, distance, angle, angle1, angle2, dotP, sLength, dotx1, doty1, dotx2, doty2;
  int noOfMenuItems = 0;
  
  TEvent(int noOfMenuItems){
    coordBuffer = new ArrayList<float[]>();
    this.noOfMenuItems = noOfMenuItems;
  }
  
  public boolean isTap(){
    distance = 0;
    if(coordBuffer.size() <= 1){
      coordBuffer.clear();
      return true;
    }
    
    for(int i=1; i < coordBuffer.size(); i++){
        distance = (distance + (Math.sqrt(
                              (coordBuffer.get(i)[0] - coordBuffer.get(i-1)[0]) * (coordBuffer.get(i)[0] - coordBuffer.get(i-1)[0]) +
                              (coordBuffer.get(i)[1] - coordBuffer.get(i-1)[1]) * (coordBuffer.get(i)[1] - coordBuffer.get(i-1)[1]))));
    }

    if((coordBuffer.get(coordBuffer.size()-1)[2]) - (coordBuffer.get(0)[2]) < 200 && distance <= 1){     
      coordBuffer.clear();
      return true;
    }
    return false;
  }
  
  public boolean isSwipe(){
    start[0] = coordBuffer.get(0)[0];
    start[1] = coordBuffer.get(0)[1];    
    end[0] = coordBuffer.get(coordBuffer.size()-1)[0];
    end[1] = coordBuffer.get(coordBuffer.size()-1)[1];
    
    distance = Math.sqrt((start[0] - end[0]) * (start[0] - end[0]) + (start[1] - end[1]) * (start[1] - end[1]));
    
    for(int i=0; i < coordBuffer.size(); i++){
      lineDistance = Math.abs((coordBuffer.get(i)[0] - start[0])*(end[1]-start[1])-(coordBuffer.get(i)[1]-start[1])*(end[0]-start[0]))/distance;
      if(lineDistance > 1 || distance < 3){
        return false;
      }
    }
    
    angle = (float) Math.toDegrees(Math.atan2(end[1] - start[1], end[0] - start[0]));
    direction1 = getDirection(angle);
    
    coordBuffer.clear();
    return true;
  }
  
  public boolean isAngle(){
    for(int i=coordBuffer.size(); i>0; i--){
      end[0] = coordBuffer.get(i-1)[0];
      end[1] = coordBuffer.get(i-1)[1];
      distance = Math.sqrt((start[0] - end[0]) * (start[0] - end[0]) + (start[1] - end[1]) * (start[1] - end[1]));
      lineDistance = Math.abs((coordBuffer.get(i-1)[0] - start[0])*(end[1]-start[1])-(coordBuffer.get(i-1)[1]-start[1])*(end[0]-start[0]))/distance;
      
      //change lineDistanec and distance to calibrate accuracy
      if(lineDistance < 1.5f && distance > 3){
        angle1 = (float) Math.toDegrees(Math.atan2(end[1] - start[1], end[0] - start[0]));
        direction2 = getDirection(angle1);
        
        for(int j=i; j<coordBuffer.size(); j++){
          start[0] = coordBuffer.get(j)[0];
          start[1] = coordBuffer.get(j)[1];
          end[0] = coordBuffer.get(coordBuffer.size()-1)[0];
          end[1] = coordBuffer.get(coordBuffer.size()-1)[1];
          distance = Math.sqrt((start[0] - end[0]) * (start[0] - end[0]) + (start[1] - end[1]) * (start[1] - end[1]));
          lineDistance = Math.abs((coordBuffer.get(i)[0] - start[0])*(end[1]-start[1])-(coordBuffer.get(i)[1]-start[1])*(end[0]-start[0]))/distance; 

          //change lineDistanec and distance to calibrate accuracy
          if(lineDistance < 1.5f && distance > 3 && end[0] == coordBuffer.get(coordBuffer.size()-1)[0]){
            angle2 = (float) Math.toDegrees(Math.atan2(end[1] - start[1], end[0] - start[0]));
            direction1 = getDirection(angle2);

            coordBuffer.clear();
            return true;
          }
        }
      }
    }
    coordBuffer.clear();
    return false;
  }

  public String getDirection(double angle){
    if(angle < 0){
      angle += 360;
    }
    if(angle > 365){
      angle -= 360;
    }
    
    if(noOfMenuItems == 8){
      if(angle >= 248 && angle < 293){
        return "0";
      }else if(angle >= 293 && angle < 338){
        return "1";
      }else if(angle >= 338  || angle < 22){
        return "2";
      }else if(angle >= 22 && angle < 67){
        return "3";
      }else if(angle >= 67 && angle < 112){
        return "4";
      }else if(angle >= 112 && angle < 158){
        return "5";
      }else if(angle >= 158 && angle < 203){
        return "6";
      }else if(angle >= 203 && angle < 248){
        return "7";
      }
    }

    if(noOfMenuItems == 4){
      if(angle >= 225 && angle < 315){
        return "0";
      }else if(angle >= 315  || angle < 45){
        return "1";
      }else if(angle >= 45 && angle < 135){
        return "2";
      }else if(angle >= 135 && angle < 225){
        return "3";
      }
    }

    return "invalid menu size";
  }
}
  public void settings() {  size(1000, 1000); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "MarkingMenu" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
