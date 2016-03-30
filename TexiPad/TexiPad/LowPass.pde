class LowPass{
  float[] result = new float[2];
  float[] tempResult = new float[2];
  float[] tempResult2 = new float[2];
  float tempX = 0;
  float tempY = 0;
  int counter = 0;
  ArrayList buffer;
  ArrayList t2_Buffer1;
  ArrayList t1_Buffer2;
  ArrayList t0_Buffer;
  ArrayList<float[]> markingBuffer;
  PVector oldP = new PVector(500, 500, 0);
  float initX, initY = 0;
  int xCoord, yCoord;
  double resultAngle, distance;
  long currentTime = 0;
  float timeColor;
  
  LowPass(int length, int xCoord, int yCoord){
    buffer = new ArrayList<float[]>();
    markingBuffer = new ArrayList<float[]>();
    t2_Buffer1 = new ArrayList<float[]>();
    t1_Buffer2 = new ArrayList<float[]>();
    t0_Buffer = new ArrayList<float[]>();
    this.xCoord = xCoord;
    this.yCoord = yCoord;
  }
  
  void drawPath(float x, float y){
    if (markingBuffer.size() == 1){
      oldP.x = xCoord;
      oldP.y = yCoord;
    }else if(markingBuffer.size() >= 2){
      line((oldP.x - initX)  * 50 + xCoord, (oldP.y - initY)  * 50 + yCoord, (x - initX) * 50 + xCoord, (y - initY) * 50 + yCoord);
    }
    oldP.set(x, y);
  }
  
  void plot(long time){
    currentTime = millis();
    
    for(int i = 0; i < markingBuffer.size(); i++){
      timeColor = map((float)(markingBuffer.get(i)[2] ),(float) time, (float)currentTime, 0, 255);
      fill(timeColor);
      ellipse((markingBuffer.get(i)[0] - initX) * 50 + xCoord,(markingBuffer.get(i)[1] - initY)* 50 + yCoord,20,20);
    }
  }
  
  void filter(){
    
    
    
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
      result[0] = tempX/counter;
      result[1] = tempY/counter;
      if(markingBuffer.size() == 0){
        markingBuffer.add(new float[]{tempX/counter, tempY/counter, millis()});
        drawPath(tempX/counter, tempY/counter);
        tempResult[0] = result[0];
        tempResult[1] = result[1];
        resultAngle = (double) Math.toDegrees(Math.atan2(result[1] , result[0]));
      }else if (markingBuffer.size() == 1){
        tempResult2[0] = result[0];
        tempResult2[1] = result[1];
        distance = Math.sqrt((result[0] - tempResult[0]) * (result[0] - tempResult[0]) + (result[1] - tempResult[1]) * (result[1] - tempResult[1]));
        if(distance > 1){
          markingBuffer.add(new float[]{result[0], result[1], millis()});
          resultAngle = (double) Math.toDegrees(Math.atan2(result[1] , result[0]));
          drawPath(result[0], result[1]);
        }
      }else{
        tempResult2[0] = result[0];
        tempResult2[1] = result[1];
        distance = Math.sqrt((tempResult2[0] - tempResult[0]) * (tempResult2[0] - tempResult[0]) + (tempResult2[1] - tempResult[1]) * (tempResult2[1] - tempResult[1]));
        if(distance > 1.5){
          markingBuffer.add(new float[]{result[0], result[1], millis()});
          drawPath(result[0], result[1]);
          resultAngle = (float) Math.toDegrees(Math.atan2(result[1] - initY, result[0] - initX));
          tempResult[0] = tempResult2[0];
          tempResult[1] = tempResult2[1];
          tempResult2[0] = result[0];
          tempResult2[1] = result[1];
        }
      }
    }
    result[0] -= initX;
    result[1] -= initY;
    tempX = 0;
    tempY = 0;
    counter = 0;
  }
}