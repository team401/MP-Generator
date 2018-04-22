import java.text.*;
class Field{
  //units in feet
  private static final int WIDTH = 27;
  private static final int HEIGHT = 32;
  private static final int SPACING = 25;
  private boolean mp = false;
  private double[][] smoothPath;
  private double[][] leftPath;
  private double[][] rightPath;
  
  private double[][] smoothPathVelocity;
  private double[][] leftPathVelocity;
  private double[][] rightPathVelocity;
  
  private ArrayList<float[]> waypoints;
  private float scale = Float.parseFloat(findValue("mapIncrements"));
  
  //private int angle;
  private boolean reverse;
  
  Field(){
    waypoints = new ArrayList<float[]>();
  }
  void display(){
    
    if(velocity){
      // width : 675 pxls
      // height : 800 pxls
      
      stroke(0);
      strokeWeight(0);
      textAlign(CENTER);
      textSize(12);
      
      float maxVelocity = 0;
      int heightSpacing = 880/11;
      double t = 0;
      int widthSpacing = 0;      
      DecimalFormat df = new DecimalFormat("#.##");

      switch(graph){
        case 0:
          t = (smoothPathVelocity.length * Double.parseDouble(findValue("timestep"))/1000);
          df = new DecimalFormat("#.##");
          widthSpacing = (int)(675/17);
          for(int i = 0;i<=16;i++){
            line(w+(i*widthSpacing), 80, w+(i*widthSpacing),880);
            String val = df.format((t/17)*i);
            text(val, w+(i*widthSpacing), 880 + 30);
          }        
          //find max velocity
          maxVelocity = 0;
          for(int i = 0;i<smoothPathVelocity.length;i++){
            if(smoothPathVelocity[i][1] > maxVelocity){
              maxVelocity = (float)smoothPathVelocity[i][1];
            }
          }
          //the velocity
          for(int i = 0;i<=10;i++){//11?
            line(w, 80+(i*heightSpacing), w+(16*widthSpacing), 80+(i*heightSpacing));
            text(maxVelocity/9 * (10-i), w-SPACING, 85+(i*heightSpacing));
          }
          
          noFill();
            beginShape();
            for(int i = 0;i<smoothPathVelocity.length;i++){
              float posX = i;
              float posY = (float)smoothPathVelocity[i][1];
              float x = (int)map(posX, 0, smoothPathVelocity.length, w, w+(16*widthSpacing));
              float y = (int)map(posY, 0, maxVelocity, 880, 80 + heightSpacing);
                
              strokeWeight(2);
              stroke(255, 0, 255);
              vertex(x, y);
            }
            endShape();
          break;
          
          case 1:
            t = (leftPathVelocity.length * Double.parseDouble(findValue("timestep"))/1000);
            df = new DecimalFormat("#.##");
            widthSpacing = (int)(675/17);
            for(int i = 0;i<=16;i++){
              line(w+(i*widthSpacing), 80, w+(i*widthSpacing),880);
              String val = df.format((t/17)*i);
              text(val, w+(i*widthSpacing), 880 + 30);
            } 
            //find max velocity
            maxVelocity = 0;
            for(int i = 0;i<leftPathVelocity.length;i++){
              if(leftPathVelocity[i][1] > maxVelocity){
                maxVelocity = (float)leftPathVelocity[i][1];
              }
            }
            //the velocity
            for(int i = 0;i<=10;i++){//11?
              line(w, 80+(i*heightSpacing), w+(16*widthSpacing), 80+(i*heightSpacing));
              text(maxVelocity/9 * (10-i), w-SPACING, 85+(i*heightSpacing));
            }
            
            noFill();
              beginShape();
              for(int i = 0;i<leftPathVelocity.length;i++){
                float posX = i;
                float posY = (float)leftPathVelocity[i][1];
                float x = (int)map(posX, 0, leftPathVelocity.length, w, w+(16*widthSpacing));
                float y = (int)map(posY, 0, maxVelocity, 880, 80 + heightSpacing);
                  
                strokeWeight(2);
                stroke(255, 0, 255);
                vertex(x, y);
              }
              endShape();
          break;
          
          case 2:
            t = (rightPathVelocity.length * Double.parseDouble(findValue("timestep"))/1000);
            df = new DecimalFormat("#.##");            
            widthSpacing = (int)(675/17);
            for(int i = 0;i<=16;i++){
              line(w+(i*widthSpacing), 80, w+(i*widthSpacing),880);
              String val = df.format((t/17)*i);
              text(val, w+(i*widthSpacing), 880 + 30);
            } 
            //find max velocity
            maxVelocity = 0;
            for(int i = 0;i<rightPathVelocity.length;i++){
              if(rightPathVelocity[i][1] > maxVelocity){
                maxVelocity = (float)rightPathVelocity[i][1];
              }
            }
            //the velocity
            for(int i = 0;i<=10;i++){//11?
              line(w, 80+(i*heightSpacing), w+(16*widthSpacing), 80+(i*heightSpacing));
              text(maxVelocity/9 * (10-i), w-SPACING, 85+(i*heightSpacing));
            }
            
            noFill();
              beginShape();
              for(int i = 0;i<rightPathVelocity.length;i++){
                float posX = i;
                float posY = (float)rightPathVelocity[i][1];
                float x = (int)map(posX, 0, rightPathVelocity.length, w, w+(16*widthSpacing));
                float y = (int)map(posY, 0, maxVelocity, 880, 80 + heightSpacing);
                  
                strokeWeight(2);
                stroke(255, 0, 255);
                vertex(x, y);
              }
              endShape();
          break;
          
          default:
            graph = 0;
          break;
          
      }
      
    }else{
      //vertical lines
      int w = width/2;
      
      textAlign(CENTER);
      textSize(12);
      strokeWeight(0);
      stroke(0);
      
      //grid
      int xAxis = (WIDTH);
      //xAxis = (int)map(xAxis, 0, WIDTH, 0, WIDTH*2);
      //println(xAxis);
      int yAxis = (HEIGHT);
      //int space = (SPACING)/2;
      for(int i = 0;i<=xAxis*(1/scale);i++){
        if(i%(1/scale)==0 && scale != 1.0){
          strokeWeight(1);
        }else{
          strokeWeight(0);
        }
        line(toCoordX(i*scale), toCoordY(0), toCoordX(i*scale),toCoordY(HEIGHT));
        if(i <= WIDTH){
          text(i, w+(i*SPACING), 80+SPACING+(HEIGHT*SPACING));
        }
      }
      for(int i = 0;i<=yAxis*(1/scale);i++){
        if(i%(1/scale)==0 && scale != 1.0){
          strokeWeight(1);
        }else{
          strokeWeight(0);
        }
        line(toCoordX(0), toCoordY(i*scale), toCoordX(WIDTH), toCoordY(i*scale));
        if(i <= HEIGHT){
          text(HEIGHT - i, w-SPACING, 85+(i*SPACING));
        }
      }
      
      //zones
      strokeWeight(3);
      fill(255);
      
      //Power Cube Zone
      rect(toCoordX(11.625), toCoordY(12), 3.75*SPACING, 3.5*SPACING);
      
      //Null territory
      rect(toCoordX(0), toCoordY(30), 8*SPACING, 6*SPACING);
      rect(toCoordX(27), toCoordY(30), -8*SPACING, 6*SPACING);
      
      textSize(26);
      fill(0);
      text("NULL", toCoordX(3), toCoordY(27.55));
      text("TERRITORY", toCoordX(3), toCoordY(25.65));
      
      text("NULL", toCoordX(24), toCoordY(27.55));
      text("TERRITORY", toCoordX(24), toCoordY(25.65));
      fill(255);
      
      //Exchange Zone
      rect(toCoordX(8.2), toCoordY(3), 4*SPACING, 3*SPACING);
      
      //auto line
      line(toCoordX(0), toCoordY(10), toCoordX(WIDTH), toCoordY(10));
      
      //halfway
      line(toCoordX(0), toCoordY(27), toCoordX(WIDTH), toCoordY(27));
      
      //switch
      noFill();
      stroke(0);
      strokeWeight(5);
      rect(toCoordX(7.5), toCoordY(16), 12*SPACING, 4*SPACING);
      
      fill(220,220,220);
      //plates
      rect(toCoordX(7.5), toCoordY(16), 3*SPACING, 4*SPACING);
      rect(toCoordX(16.5), toCoordY(16), 3*SPACING, 4*SPACING);
      //boom
      rect(toCoordX(10.5), toCoordY(14.6), 6*SPACING, 1.2*SPACING);
      
      noFill();
      //platform
      noStroke();
      if(blue){
        fill(255,0,0);
        rect(toCoordX(8.1), toCoordY(31.8)-5, 10.8*SPACING, 5*SPACING);
        fill(0,0,255);
        rect(toCoordX(8.1), toCoordY(26.8)-5, 10.8*SPACING, 5*SPACING);
      }else{
        fill(0,0,255);
        rect(toCoordX(8.1), toCoordY(31.8)-5, 10.8*SPACING, 5*SPACING);
        fill(255,0,0);
        rect(toCoordX(8.1), toCoordY(26.8)-5, 10.8*SPACING, 5*SPACING);
      }
      noFill();
      stroke(0);
      strokeWeight(5);
      
      //outer boundary
      rect(toCoordX(8.1), toCoordY(31.8)-5, 10.8*SPACING, 10*SPACING);
      
      //raised boundary
      rect(toCoordX(9.1), toCoordY(30.8)-5, 8.7*SPACING, 7.9*SPACING);
      
      //scale
      fill(220, 220,220);
      //boom
      rect(toCoordX(9.07), toCoordY(27.3)-5, 9*SPACING, 1.16*SPACING);
      //plates
      rect(toCoordX(6.07), toCoordY(28.7)-5, 3*SPACING, 4*SPACING);
      rect(toCoordX(17.83), toCoordY(28.7)-5, 3*SPACING, 4*SPACING);
      
      
      //Power cubes
      strokeWeight(3);
      fill(255,255,0);
      for(int i = 0;i<6;i++){
        rect(toCoordX(7.5 + i*2.225), toCoordY(17), 0.916*SPACING, 0.916*SPACING);
      }
      //rect(toCoordX(11.625), toCoordY(12), 3.75*SPACING, 3.5*SPACING);
      for(int i = 0;i<3;i++){
        rect(toCoordX(12.0961 + i*0.916), toCoordY(12), 0.916*SPACING, 0.916*SPACING);
      }
      rect(toCoordX(12.6), toCoordY(12-0.961), 0.916*SPACING, 0.916*SPACING);
      rect(toCoordX(12.6 + 0.916), toCoordY(12-0.961), 0.916*SPACING, 0.916*SPACING);
      rect(toCoordX(13.05), toCoordY(12-1.922), 0.916*SPACING, 0.916*SPACING);
      
      
      noFill();
      
      
      //display the coordinates
      if(mouseX >= w && mouseX <= w+(WIDTH*SPACING) && mouseY >= 80 && mouseY <= 80+(HEIGHT*SPACING)){
        fill(0);
        textSize(24);
        float mapX = toMapX(mouseX);
        float mapY = toMapY(mouseY);
        
        int x = toCoordX(mapX);
        int y = toCoordY(mapY);
        
        if(angle > 359){
          angle = 0;
        }
        if(angle < 0){
          angle = 360 - Integer.parseInt(findValue("angle"));
        }
              
        text("(" + mapX + "," + mapY + ","+angle + (char)176 + ")", x+45, y-30);
        
        strokeWeight(12*scale);
        line(x, y, x, y);
        
        //draws the arrow
        //using screen coordinates
        arrow(mapX, mapY, angle);
      }
      //can still add to wayPoints
      //TODO fix that
      if(mp){     
        //draws the smooth path
        noFill();
        beginShape();
        for(int i = 0;i<smoothPath.length;i++){
          float posX = (float)smoothPath[i][0];
          float posY = (float)smoothPath[i][1];
          float x = toCoordX(posX);
          float y = toCoordY(posY);
            
          strokeWeight(2);
          stroke(255, 0, 255);
          vertex(x, y);
        }
        endShape();
        //leftPath
        noFill();
        beginShape();
        for(int i = 0;i<leftPath.length;i++){
          float posX = (float)leftPath[i][0];
          float posY = (float)leftPath[i][1];
          float x = toCoordX(posX);
          float y = toCoordY(posY);
            
          strokeWeight(2);
          stroke(255, 0, 255);
          vertex(x, y);
        }
        endShape();
        //rightPath
        noFill();
        beginShape();
        for(int i = 0;i<rightPath.length;i++){
          float posX = (float)rightPath[i][0];
          float posY = (float)rightPath[i][1];
          float x = toCoordX(posX);
          float y = toCoordY(posY);
            
          strokeWeight(2);
          stroke(255, 0, 255);
          vertex(x, y);
        }
        endShape();
    
      }else{
      noFill();
      beginShape();
      for(int i = 0;i<waypoints.size();i++){
        float posX = waypoints.get(i)[0];
        float posY = waypoints.get(i)[1];
        int x = toCoordX(posX);
        int y = toCoordY(posY);
        
        strokeWeight(12);
        stroke(255,0,0);
        line(x, y, x, y);
  
        strokeWeight(2);
        vertex(x, y);
      }
      endShape();
      fill(255);
      }
    }//end velocity
  }
  void addWaypoint(int msX, int msY){
    //int angle = 0;//make this real later
    int w = width/2;
    float mapX = toMapX(msX);
    float mapY = toMapY(msY);
                    
    waypoints.add(new float[]{mapX,mapY,angle});
  }
  void removeWaypoint(){
    if(waypoints.size()>=1){
    waypoints.remove(waypoints.size()-1);
    }
  }
  void clearWaypoints(){
    int temp = waypoints.size();
    for(int i = 0;i<temp;i++){
      removeWaypoint();
    }
  }
  double[][] getWaypoints(){
    double[][] p = new double[waypoints.size()][2];
    for(int i = 0;i<waypoints.size();i++){
      p[i][0] = waypoints.get(i)[0];
      p[i][1] = waypoints.get(i)[1];
    }
    return p;
  }
  void printWaypoints(){
    if(waypoints.size()<=0){
      System.out.println("Waypoints is empty");
    }else{
      for(float[] u: waypoints){
        System.out.println("("+u[0]+","+u[1]+","+u[2]+")");
      }
    }
  }
  Waypoint[] toWaypointObj(){
    Waypoint[] points = new Waypoint[waypoints.size()];
    for(int i = 0;i<waypoints.size();i++){
      //x, y, angle
      //meters, hopefully
      points[i] = new Waypoint((double)waypoints.get(i)[0] * 0.3048, (double)waypoints.get(i)[1] * 0.3048, (double)Pathfinder.d2r(waypoints.get(i)[2]));
    }
    return points;
  }
  void loadWaypoints(String filePath){
    clearWaypoints();
    String[] points = loadStrings(filePath);
    
    reverse = filePath.contains("_REV");
    
    for(int i = 0;i<points.length;i++){
      String[] temp = split(points[i], ",");
      
      waypoints.add(new float[]{Float.parseFloat(temp[0]), Float.parseFloat(temp[1]), Float.parseFloat(temp[2])});
    }
  }
  void mirror(){
    for (int i = 0;i<waypoints.size();i++){
      waypoints.get(i)[0] = 27 - waypoints.get(i)[0];
      if(waypoints.get(i)[2] > 180){
        waypoints.get(i)[2] = 360 - (waypoints.get(i)[2] - 180);
      }else{
        waypoints.get(i)[2] = 180 - waypoints.get(i)[2];
      }
    }
  }
  
  void enableMP(){
    mp = true;
  }
  void disableMP(){
    mp = false;
  }
  boolean getMP(){
    return mp;
  }
  void setSmoothPath(double[][] path){
    smoothPath = path;
  }
  void setLeftPath(double[][] path){
    leftPath = path;
  }
  void setRightPath(double[][] path){
    rightPath = path;
  }
  double[][] getSmoothPath(){
    return smoothPath;
  }
  double[][] getLeftPath(){
    return leftPath;
  }
  double[][] getRightPath(){
    return rightPath;
  }
  boolean getReverse(){
    return reverse;
  }
  void setReverse(boolean r){
    reverse = r;
  }
  void setSmoothPathVelocity(double[][] path){
    smoothPathVelocity = path;
  }
  void setLeftPathVelocity(double[][] path){
    leftPathVelocity = path;
  }
  void setRightPathVelocity(double[][] path){
    rightPathVelocity = path;
  }
  void clearGeneratedPaths(){
    smoothPathVelocity = null;
    leftPathVelocity = null;
    rightPathVelocity = null;
  }
  void printPath(double[][] path){
    for(int i = 0;i<path.length;i++){
      println("("+path[i][0]+","+path[i][1]+")");
    }
  }
  //angle in degrees
  private void arrow(float x1, float y1, int angle){
    double radians = Math.toRadians(angle);
        
    float posX = (float)(x1+Math.cos(radians));
    float posY = (float)(y1+Math.sin(radians));
    
    x1 = toCoordX(x1);
    y1 = toCoordY(y1);    
    
    int x2 = toCoordX(posX);
    int y2 = toCoordY(posY);
        
    strokeWeight(2);
    line(x1, y1, x2, y2);
    
    //top    
    int angX = (int)(toMapX(x2) - Math.cos(Math.PI/2 - radians));
    int angY = (int)(toMapY(y2) - Math.sin(Math.PI/2 - radians));
        
  }
  //
  DecimalFormat df = new DecimalFormat("#.##");
  float toMapX(float x){
    float value = Float.parseFloat(df.format(map(x, w, w+(WIDTH*SPACING), 0, WIDTH)));
    return value - value % Float.parseFloat(findValue("mapIncrements"));
  }
  float toMapY(float y){
    float value = Float.parseFloat(df.format(map(y, 80, 80+(HEIGHT*SPACING), HEIGHT, 0)));
    return value - value % Float.parseFloat(findValue("mapIncrements"));
  }
  //
  int toCoordX(float x){
    return (int)map(x, 0, WIDTH, w, w+(WIDTH*SPACING));
  }
  int toCoordY(float y){
    return (int)map(y, 0, HEIGHT, 80+(HEIGHT*SPACING), 80);
  }
  void exportWaypoints(){
    PrintWriter output;
    if(reverse && !name.getText().contains("_REV")){
      //output = createWriter("\\profilecsv\\tank\\Waypoints\\"+name.getText()+"_REV.csv");
      output = createWriter(directory.getText() + "/waypoints/" + name.getText()+"_REV.csv");
    }else{
      output = createWriter(directory.getText() + "/waypoints/" + name.getText()+".csv");
    }
    
    for(float[] u: waypoints){
      output.println(u[0]+","+u[1]+","+u[2]);
    }      
      output.flush();
      output.close();
    }
}