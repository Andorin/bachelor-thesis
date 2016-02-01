class Menu{
	int noOfMenuItems, scale = 0;

	//String[][] menuItems= {{"0", "00", "01", "02", "03"},
 //            		{"1", "10", "11", "12", "13"},
 //            		{"2", "20", "21", "22", "23"},
 //           		{"3", "30", "31", "32", "33"}};

  String[][] menuItems = {{"N","N","NE","NS","NW"},
                          {"E","EN","E","ES","EW"},
                          {"S","SN","SE","S","SW"},
                          {"W","WN","WE","WS","W"}};
	int xCoord, yCoord, firstDirection;
	float startAngle, endAngle, angle;

	public Menu(int xCoord, int yCoord, int scale, int noOfMenuItems) {
		this.noOfMenuItems = noOfMenuItems;
		this.xCoord = xCoord;
		this.yCoord = yCoord;
		this.scale = scale;
	}

	void drawMenu(float[] result, String direction){
    for (int i = 0; i < noOfMenuItems; i++) {
      startAngle = (270 - (360/noOfMenuItems)/2 + (360/noOfMenuItems * i)) ;
      endAngle   = (270 + (360/noOfMenuItems)/2 + (360/noOfMenuItems * i)) ;
      if(menuItems[i][0].equals(direction)){
        firstDirection = i;
        fill(125);
      }else{
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

	void triggerMenuItem(String direction1){
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