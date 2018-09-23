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
  
  private ArrayList<Crate> crates;
  
  //private int angle;
  private boolean reverse;
  
  Field(){
    waypoints = new ArrayList<float[]>();
    crates = new ArrayList<Crate>();
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
      int yAxis = (HEIGHT);
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
      
      //CenterLine
      strokeWeight(5);
      line(toCoordX(0), toCoordY(27), toCoordX(27), toCoordY(27));
      strokeWeight(2); 
    }
  }
  
  void displayInfo(){
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
        
      for(Crate crate : crates){
        if(crate.mouseOverCrate()){
          strokeWeight(3);
        }
        crate.display();
        strokeWeight(1.5);
      }
 
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
      }
      stroke(0);
      fill(0);
   //display the coordinates
      if(withinField()){
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
              
        
        if(!addingCrate && !mouseOverCrate()){
          text("(" + mapX + "," + mapY + ","+angle + (char)176 + ")", x+45, y-30);
        
          strokeWeight(12*scale);
          line(x, y, x, y);
        
          //draws the arrow
          //using screen coordinates
          arrow(mapX, mapY, angle);
        }
      }
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
  void addCrate(Crate crate){
    crates.add(crate);
  }
  boolean mouseOverCrate(){
    boolean over = false;
    for(int i = 0;i<crates.size();i++){
      if(crates.get(i).mouseOverCrate()){
        over = true;
      }
    }
    return over;
  }
  void removeCrateUnderMouse(){
    for(int i = 0;i<crates.size();i++){
      if(crates.get(i).mouseOverCrate()){
        crates.remove(i);
        return;
      }
    }
  }
  void exportCrateLayout(String filepath){
    PrintWriter layout = createWriter(filepath + ".csv");
    for(Crate crate : crates){
      layout.println(crate.getPoint());
    }
    
    layout.flush();
    layout.close();
  }
  void loadCrateLayout(String filepath){
    //clear the arraylist
    int temp = crates.size();
    for(int i = 0;i<temp;i++){
      crates.remove(i);
    }
    
    String[] cratePoints = loadStrings(filepath);
    for(int i = 0;i<cratePoints.length;i++){
      //Should be in "x,y"
      //So point[0] = x point[1] = y
      String[] point = split(cratePoints[i], ",");
      
      crates.add(new Crate(toMapX(Float.parseFloat(point[0])), toMapY(Float.parseFloat(point[1]))));
    }
  }
  int getCrateLayoutLength(){
    return crates.size();
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
  boolean withinField(){
    return mouseX >= w && mouseX <= w+(Field.WIDTH*Field.SPACING) 
    && mouseY >= 80 && mouseY <= 80+(Field.HEIGHT*Field.SPACING);
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