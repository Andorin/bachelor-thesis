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
  
  boolean isTap(){
    direction1 = "";
    direction2 = "";
    distance = 0;
    if(coordBuffer.size() <= 1){
      //coordBuffer.clear();
      return true;
    }
    
    for(int i=1; i < coordBuffer.size(); i++){
        distance = (distance + (Math.sqrt(
                              (coordBuffer.get(i)[0] - coordBuffer.get(i-1)[0]) * (coordBuffer.get(i)[0] - coordBuffer.get(i-1)[0]) +
                              (coordBuffer.get(i)[1] - coordBuffer.get(i-1)[1]) * (coordBuffer.get(i)[1] - coordBuffer.get(i-1)[1]))));
    }

    if((coordBuffer.get(coordBuffer.size()-1)[2]) - (coordBuffer.get(0)[2]) < 200 && distance <= 1){     
      //coordBuffer.clear();
      return true;
    }
    return false;
  }
  
  boolean isSwipe(){
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
    
    //coordBuffer.clear();
    return true;
  }
  
  boolean isAngle(){
    //distance = Math.sqrt((start[0] - end[0]) * (start[0] - end[0]) + (start[1] - end[1]) * (start[1] - end[1]));
    //angle = (float) Math.toDegrees(Math.atan2(end[1] - start[1], end[0] - start[0]));
    //direction1 = getDirection(angle);
    //dirty workaround to avoid other inputs than swipe and angle
    if(coordBuffer.size() > 8){
      return false;
    }
    
    int n = coordBuffer.size()-1;
    while(!isLine(0,n)){
      n--;
      if(n < 1){
        return false;
      }
    }
    
    int j = n;  
   // if(isLine(j, coordBuffer.size()-1)){
      angle1 = (float) Math.toDegrees(Math.atan2(coordBuffer.get(n)[1] - start[1], coordBuffer.get(n)[0] - start[0]));
      angle2 = (float) Math.toDegrees(Math.atan2(end[1] - coordBuffer.get(j)[1], end[0] - coordBuffer.get(j)[0]));
      direction1 = getDirection(angle1);
      direction2 = getDirection(angle2);
      //coordBuffer.clear();
      return true;
   // }else{
   //   coordBuffer.clear();
   //   return false;
   // }   
  }

  Boolean isLine(int startIndex, int endIndex){
    
    distance = Math.sqrt((coordBuffer.get(startIndex)[0] - coordBuffer.get(endIndex)[0]) * (coordBuffer.get(startIndex)[0] - coordBuffer.get(endIndex)[0]) + 
                         (coordBuffer.get(startIndex)[1] - coordBuffer.get(endIndex)[1]) * (coordBuffer.get(startIndex)[1] - coordBuffer.get(endIndex)[1]));
                         
    for(int i = 1; i < endIndex-1;i++){
      lineDistance = Math.abs((coordBuffer.get(i)[0] - coordBuffer.get(startIndex)[0]) * (coordBuffer.get(endIndex)[1] - coordBuffer.get(startIndex)[1]) -
                              (coordBuffer.get(i)[1] - coordBuffer.get(startIndex)[1]) * (coordBuffer.get(endIndex)[0] - coordBuffer.get(startIndex)[0])) / distance;                       
      if(lineDistance > 1 || distance < 3){
        return false;
      }
    }
    return true;
  }

  String getDirection(double angle){
    
    if(angle < 0){
      angle += 360;
    }
    if(angle > 360){
      angle -= 360;
    }
    
    if(noOfMenuItems == 8){
      if(angle >= 248 && angle < 293){
        return "N";
      }else if(angle >= 293 && angle < 338){
        return "NE";
      }else if(angle >= 338  || angle < 22){
        return "E";
      }else if(angle >= 22 && angle < 67){
        return "SE";
      }else if(angle >= 67 && angle < 112){
        return "S";
      }else if(angle >= 112 && angle < 158){
        return "SW";
      }else if(angle >= 158 && angle < 203){
        return "W";
      }else if(angle >= 203 && angle < 248){
        return "NW";
      }
    }

    if(noOfMenuItems == 4){
      if(angle >= 225 && angle < 315){
        return "N";
      }else if(angle >= 315  || angle < 45){
        return "E";
      }else if(angle >= 45 && angle < 135){
        return "S";
      }else if(angle >= 135 && angle < 225){
        return "W";
      }
    }

    return "invalid menu size";
  }
}