import java.text.*;
public class Field{
  //units in feet
  private static final int WIDTH = 27;
  private static final int HEIGHT = 32;
  private static final int SPACING = 25;
  private boolean mp = false;
  private boolean changingWaypointAngle = false;
  private int movingWaypointIndex = -1;
  private double[][] smoothPath;
  private double[][] leftPath;
  private double[][] rightPath;
  private double totalElapsedTime;
  private double maxVelocity;
  private double maxAcceleration;
  private double maxVoltage;
  private double maxCentripAccel;
  protected boolean memesEnabled;
  private boolean centripetalAccelConstraintEnabled;
    
  private ArrayList<float[]> waypoints;
  private float fieldResolution;
  private float fieldUnitsMultiplier;
  
  //private int angle;
  private boolean reverse;
  
  private Generator generator;
  
  private Rocket rocket1;
  private Rocket rocket2;
  private CargoShip cargoShip;
  private HABPlateform hab;
  private LoadingStation leftLoadingStation;
  private LoadingStation rightLoadingStation;
    
  Field(){
    generator = new Generator();
    waypoints = new ArrayList<float[]>();
    reset();
    JSONObject values = loadJSONObject("config.cfg");
    fieldResolution = values.getFloat("fieldResolution");
    
    String unit = values.getString("fieldDisplayUnits");
    if (unit.equals("INCHES")) {
      fieldUnitsMultiplier = 12.0;
    }else {
      fieldUnitsMultiplier = 1.0;
    }
    
    centripetalAccelConstraintEnabled = false;
  }
  Field(ArrayList<float[]> waypoints){    
    this.waypoints = waypoints;
    generator = new Generator();
    
    JSONObject values = loadJSONObject("config.cfg");
    maxVelocity = values.getDouble("defaultMaxVelocity");
    maxAcceleration = values.getDouble("defaultMaxAcceleration");
    maxVoltage = values.getDouble("defaultMaxVoltage");
    maxCentripAccel = values.getDouble("defaultMaxCentripetalAcceleration");
    memesEnabled = values.getBoolean("enableMemes");
    fieldResolution = values.getFloat("fieldResolution");
    
    String unit = values.getString("fieldDisplayUnits");
    if (unit.equals("INCHES")) {
      fieldUnitsMultiplier = 12.0;
    }else {
      fieldUnitsMultiplier = 1.0;
    }
    
    centripetalAccelConstraintEnabled = false;
        
    generateProfile();
    if(waypoints.size() > 1){
      mp = true;
    }
  }
  
  void setUpField(){
    
    rocket1 = new Rocket(215.0/12, 0 + 7.875/12, false); // Rocket center is 96 in from the center line
    rocket2 = new Rocket(215.0/12, WIDTH - 7.875/12, true); // Rocket is 39.375 wide
    cargoShip = new CargoShip(27 - 104.75/12, WIDTH/2.0 - 45.0/24); // Cargo ship 
    hab = new HABPlateform(0, WIDTH/2.0 - 173.25/24.0);
    leftLoadingStation = new LoadingStation(WIDTH - 22.75/6);
    rightLoadingStation = new LoadingStation(0);
  }
  void display(){    
    if(velocity){
      // width : 675 pxls
      // height : 800 pxls
      
      stroke(0);
      strokeWeight(0);
      textAlign(CENTER);
      textSize(12*scale);
            
    }else{
      //vertical lines
      int w = width/2;
      
      textAlign(CENTER);
      textSize(12*scale);
      strokeWeight(0);
      stroke(0);
      
      //grid
      int xAxis = (WIDTH);
      int yAxis = (HEIGHT);
      for(int i = 0;i<=xAxis;i++){
        line(toCoordY(i), toCoordX(0), toCoordY(i), toCoordX(HEIGHT));
        if(i <= WIDTH){
          //text(xAxis - i, w+(i*SPACING), 80+SPACING+(HEIGHT*SPACING));
        }
      }
      for(int i = 0;i<=yAxis;i++){
        line(toCoordY(0), toCoordX(i), toCoordY(WIDTH), toCoordX(i));
        if(i <= HEIGHT){
          //text(HEIGHT - i, w-SPACING, 85+(i*SPACING));
        }
      }
      // Adds axis labels
      arrow(0, 0, 0, "x");//x axis
      arrow(0, 0, 90, "y");
      
      for(int i = 0; i< 27;i+=2){
        line(toCoordY(i), toCoordX(27), toCoordY(i + 1), toCoordX(27)); // Midline
      }
      line(toCoordY(0), toCoordX(27 - 9.0/12), toCoordY(27), toCoordX(27 - 9.0/12)); // Cargo Ship line
      line(toCoordY(0), toCoordX(7 + 11.25/12), toCoordY(27), toCoordX(7 + 11.25/12));// HAB line
            
      rocket1.display();
      rocket2.display();
      cargoShip.display();
      hab.display();
      leftLoadingStation.display();
      rightLoadingStation.display();
      
      if(memesEnabled){
        textSize(48);
        text("The Ocean", toCoordY(13.5), toCoordX(28));
      }else{
        
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
          float x = toCoordY(posY);
          float y = toCoordX(posX);
            
          strokeWeight(2*scale);
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
          float x = toCoordY(posY);
          float y = toCoordX(posX);
            
          strokeWeight(2*scale);
          stroke(255, 0, 0);
          vertex(x, y);
        }
        endShape();
        
        //rightPath
        noFill();
        beginShape();
        for(int i = 0;i<rightPath.length;i++){
          float posX = (float)rightPath[i][0];
          float posY = (float)rightPath[i][1];
          float x = toCoordY(posY);
          float y = toCoordX(posX);
            
          strokeWeight(2*scale);
          stroke(0, 0, 255);
          vertex(x, y);
        }
        endShape();
        
        if(mouseOverWaypoint()){
          noFill();
          for(int i = 0;i<waypoints.size();i++){
            float posX = waypoints.get(i)[0];
            float posY = waypoints.get(i)[1];
            int waypointAngle = (int)waypoints.get(i)[2];
            int y = toCoordX(posX);
            int x = toCoordY(posY);
            
            if(movingWaypointIndex == i){
              strokeWeight(20*scale);
              stroke(0);
              line(x, y, x, y);
              strokeWeight(16*scale);
            }else{
              strokeWeight(12*scale);
            }
            stroke(0,255,0);
            line(x, y, x, y);
            arrow(posY, posX, waypointAngle);
          }
          stroke(0);
          fill(255);
        }else{
          noFill();
          for(int i = 0;i<waypoints.size();i++){
            float posX = waypoints.get(i)[0];
            float posY = waypoints.get(i)[1];
            int waypointAngle = (int)waypoints.get(i)[2];
            int y = toCoordX(posX);
            int x = toCoordY(posY);
            
            strokeWeight(12*scale);
            stroke(0,255,0);
            line(x, y, x, y);
            arrow(posY, posX, waypointAngle);
          }
          stroke(0);
          fill(255);
        }
        
        noFill();
        for(int i = 0;i<waypoints.size();i++){
          float posX = waypoints.get(i)[0];
          float posY = waypoints.get(i)[1];
          int y = toCoordX(posX);
          int x = toCoordY(posY);
          
          strokeWeight(12*scale);
          stroke(0,255,0);
          line(x, y, x, y);
        }
        stroke(0);
        fill(255);   
      }else{
        /*
      noFill();
      beginShape();
      for(int i = 0;i<waypoints.size();i++){
        float posX = waypoints.get(i)[0];
        float posY = waypoints.get(i)[1];
        int y = toCoordX(posX);
        int x = toCoordY(posY);
        
        strokeWeight(12);
        stroke(255,0,0);
        line(x, y, x, y);
  
        strokeWeight(2);
        vertex(x, y);
      }
      endShape();
      stroke(0);
      fill(255);
      */
      }
      //display the coordinates
      if(mouseX >= w && mouseX <= w+(WIDTH*SPACING*widthScale) && mouseY >= 80*heightScale && mouseY <= (80*heightScale)+(HEIGHT*SPACING*heightScale)){
        fill(0);
        textSize(24*scale);
        float mapX = toMapX(mouseY);
        float mapY = toMapY(mouseX);
        
        int y = toCoordX(mapX);
        int x = toCoordY(mapY);
        
        if(angle > 359){
          angle = 0;
        }
        if(angle < 0){
          angle = 360 - 15;
        }
        
        if(!mouseOverWaypoint()){
          changingWaypointAngle = false;
          text("(" + mapX * fieldUnitsMultiplier + "," + mapY * fieldUnitsMultiplier + ","+angle + (char)176 + ")", x+45, y-30);
          
          strokeWeight(12*scale);
          line(x, y, x, y);
          
          //draws the arrow
          //using screen coordinates
          arrow(mapY, mapX, angle);
        }else{// VERY BAD FORM
          if(changingWaypointAngle){
            waypoints.get(movingWaypointIndex)[2] = angle;
            text(angle + "" +(char)176, x+45, y-30);
                    
            //draws the arrow
            //using screen coordinates
            arrow(waypoints.get(movingWaypointIndex)[1], waypoints.get(movingWaypointIndex)[0], angle);
            
            generateProfile();
          }else{
            text("(" + mapX + "," + mapY + ","+angle + (char)176 + ")", x+45, y-30);
          }
        }
        
      }
    }//end velocity
  }
  void reset(){
    clearWaypoints();
    disableMP();
    smoothPath = new double[0][0];
    leftPath = new double[0][0];
    rightPath = new double[0][0];
    totalElapsedTime = 0.0;
    
    JSONObject values = loadJSONObject("config.cfg");
    maxVelocity = values.getDouble("defaultMaxVelocity");
    maxAcceleration = values.getDouble("defaultMaxAcceleration");
    maxVoltage = values.getDouble("defaultMaxVoltage");
    memesEnabled = values.getBoolean("enableMemes");
  }
  void addWaypoint(int msX, int msY){
    int w = width/2;
    float mapX = toMapX(msY);
    float mapY = toMapY(msX);
             
    waypoints.add(new float[]{mapX,mapY,angle});
  }
  void removeWaypoint(){
    removeWaypoint(waypoints.size() - 1);
  }
  void removeWaypoint(int index){
    if(waypoints.size() > 0){
      waypoints.remove(index);
    }
  }
  void clearWaypoints(){
    int temp = waypoints.size();
    for(int i = 0;i<temp;i++){
      removeWaypoint();
    }
  }
  /*
  double[][] getWaypoints(){
    double[][] p = new double[waypoints.size()][2];
    for(int i = 0;i<waypoints.size();i++){
      p[i][0] = waypoints.get(i)[0];
      p[i][1] = waypoints.get(i)[1];
    }
    return p;
  }
  */
  ArrayList<float[]> getWaypoints(){
    return waypoints; 
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
  void loadWaypoints(String filePath){
    clearWaypoints();
    String[] points = loadStrings(filePath);
    
    reverse = filePath.contains("_REV");
    
    for(int i = 0;i<points.length;i++){
      String[] temp = split(points[i], ",");
      
      waypoints.add(new float[]{Float.parseFloat(temp[0]), Float.parseFloat(temp[1]), Float.parseFloat(temp[2])});
    }
  }
  boolean mouseOverWaypoint(){
    boolean mouseOver = false;
    float tolerance = 1f;
    for(int i = 0;i<waypoints.size();i++){
      if(toCoordX(waypoints.get(i)[0] + tolerance) < mouseY && toCoordX(waypoints.get(i)[0] - tolerance) > mouseY && toCoordY(waypoints.get(i)[1] + tolerance) < mouseX && toCoordY(waypoints.get(i)[1] - tolerance) > mouseX){
        mouseOver = true;
        movingWaypointIndex = i;
      }
    }
    if(!mouseOver){
      movingWaypointIndex = -1;
    }
    return mouseOver;
  }
  void moveWaypoint(){
    waypoints.get(movingWaypointIndex)[0] = toMapX(mouseY);
    waypoints.get(movingWaypointIndex)[1] = toMapY(mouseX);
    generateProfile();
  }
  void changeWaypointAngle(){
    changingWaypointAngle = !changingWaypointAngle;
    angle = (int)waypoints.get(movingWaypointIndex)[2];
  }
  void mirror(){
    for (int i = 0;i<waypoints.size();i++){
      waypoints.get(i)[1] = 27 - waypoints.get(i)[1];
      
      waypoints.get(i)[2] = 360 - waypoints.get(i)[2];
      
    }
    generateProfile();
  }
  
  public void setProfileSettings(double maxVelocity, double maxAcceleration, double maxVoltage, double maxCentripAccel, boolean reverse){
    this.maxVelocity = maxVelocity;
    this.maxAcceleration = maxAcceleration;
    this.maxVoltage = maxVoltage;
    this.maxCentripAccel = maxCentripAccel;
    this.reverse = reverse;
    
    generateProfile();
  }
  public double getMaxVelocity(){
    return maxVelocity;
  }
  public double getMaxAcceleration(){
    return maxAcceleration;
  }
  public double getMaxVoltage(){
    return maxVoltage;
  }
  public double getMaxCentripAccel(){
    return maxCentripAccel;
  }
  void setCentripAccelConstraint(boolean enableConstraint){
    centripetalAccelConstraintEnabled = enableConstraint;
    generateProfile();
  }
  public void generateProfile(){
    // call generateTrajectory(boolean reversed, List<Pose2d> waypoints, List<TimingConstraint<Pose2dWithCurvature>> constraints,
    //double start_vel, double end_vel, double max_vel, double max_accel, double max_voltage)
    if(waypoints.size() > 1){
      Profile profile = generator.generateTraj(
      this.waypoints, 
      maxVelocity, 
      maxAcceleration, 
      maxVoltage, 
      reverse, 
      maxCentripAccel, 
      centripetalAccelConstraintEnabled
      );
      double[][][] paths = profile.getProfile();
      smoothPath = paths[0];
      leftPath = paths[1];
      rightPath = paths[2];
      totalElapsedTime = profile.getTotalTime();
    }else{
      smoothPath = new double[0][0];
      leftPath = new double[0][0];
      rightPath = new double[0][0];
      totalElapsedTime = 0.0;
    }
  }
  int getChangingIndex(){
    return movingWaypointIndex;
  }
  double getElapsedTime(){
    return totalElapsedTime;
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
  
  void printPath(double[][] path){
    for(int i = 0;i<path.length;i++){
      println("("+path[i][0]+","+path[i][1]+")");
    }
  }
  boolean displayingVelocityGraph(){
    return velocity;
  }
  //angle in degrees
  private void arrow(float x1, float y1, int angle){arrow(x1, y1, angle, "");}
  private void arrow(float x1, float y1, int angle, String text){arrow(x1, y1, angle, text, 1f);}
  private void arrow(float x1, float y1, int angle, String text, float len){
    double radians = Math.toRadians(angle - 90);
        
    float posX = (float)(x1 + len * Math.cos(-radians));
    float posY = (float)(y1 + len * Math.sin(-radians));
    
    x1 = toCoordY(x1);
    y1 = toCoordX(y1);    
    
    int x2 = toCoordY(posX);
    int y2 = toCoordX(posY);
        
    strokeWeight(2*scale);
    //println(x1 + " " + y1 + " " + x2 + " " + y2);
    line((int)x1, (int)y1, x2, y2);
    
    text(text, (int)(x2-10*Math.cos(-radians)), (int)(y2-10*Math.sin(-radians)));
    
    //arrowhead
    int angX = (int)(toMapY(x2) - Math.cos(Math.PI/2 - radians));
    int angY = (int)(toMapX(y2) - Math.sin(Math.PI/2 - radians));
        
  }
  //THESE ARE BACKWARDS. X AND Y ARE IN TERMS OF THE FIELD NOT THE WINDOW
  DecimalFormat df = new DecimalFormat("#.##");
  float toMapY(float x){ 
    //float value = Float.parseFloat(df.format(map(x, w, w+(WIDTH*SPACING), 0, WIDTH)));
    //println("widthScale: " + widthScale);
    float value = Float.parseFloat(df.format(map(x, w+(WIDTH*SPACING*widthScale), w, 0, WIDTH)));
    return value - value % fieldResolution;
  }
  float toMapX(float y){
    float value = Float.parseFloat(df.format(map(y, 80.0*heightScale, (80.0*heightScale)+(HEIGHT*SPACING*heightScale), HEIGHT, 0)));
    //float value = Float.parseFloat(df.format(map(y, 80, 80+(HEIGHT*SPACING), 0, HEIGHT)));
    return value - value % fieldResolution;
  }
  //
  int toCoordY(float x){
    //int value = (int)map(x, 0, WIDTH, w, w+(WIDTH*SPACING));
    int value = (int)map(x, 0, WIDTH, w+(WIDTH*SPACING*widthScale), w);
    return value;
  }
  int toCoordX(float y){
    return (int)map(y, 0, HEIGHT, (80.0*heightScale)+(HEIGHT*SPACING*heightScale), 80.0*heightScale);
    //return (int)map(y, 0, HEIGHT, 80, 80+(HEIGHT*SPACING));
  }
}
private class Rocket extends Field{
  private float x;
  private float y;
  private boolean reverse;
  
  Rocket(float x, float y, boolean reverse){
    this.x = x;
    this.y = y;
    this.reverse = reverse;
  }
  public void display(){
    fill(220, 220, 220);
    beginShape();
    //back and side struts
    if (!reverse){
      
      vertex(toCoordY(y), toCoordX(x));
      vertex(toCoordY(y + 19.6/12), toCoordX(x+ 10.44/12)); //39.375 long front face is 18.5
      vertex(toCoordY(y + 19.6/12), toCoordX(x + 10.44/12 + 18.5/12)); // 19.567
      vertex(toCoordY(y), toCoordX(x + 10.44/12 + 18.5/12 + 10.44/12)); // 21 in diagonal
      vertex(toCoordY(y), toCoordX(x));// 7.875 inches from the wall
      
      // angle 61 degrees 
      stroke(255);
      line(toCoordY(y + 19.6/24), toCoordX(x + 10.44/24), toCoordY(y + 19.6/24 + 1.5 * (float)Math.cos(61*PI/180)), toCoordX(x + 10.44/24 - 1.5 * (float)Math.sin(61*PI/180)));
      line(toCoordY(y + 19.6/24), toCoordX(x + 34.155/12), toCoordY(y + 19.6/24 + 1.5 * (float)Math.cos(61*PI/180)), toCoordX(x + 34.155/12 + 1.5 * (float)Math.sin(61*PI/180)));
      line(toCoordY(y + 19.567/12), toCoordX(x + 39.375/24), toCoordY(y + 19.567/12 + 1.5), toCoordX(x + 39.375/24));
      stroke(0);
    }else{
      /*
      vertex(toCoordY(y), toCoordX(x));
      vertex(toCoordY(y), toCoordX(x + 8 + (5/6.0)));
      vertex(toCoordY(y), toCoordX(x + 2 + 5/12.0));
      vertex(toCoordY(y - 24.8/12), toCoordX(x + 2 + 5/12.0 + 13.8/12));
      vertex(toCoordY(y - 24.8/12), toCoordX(x + 2 + 5/12.0 + 13.8/12 + 20.5/12));
      vertex(toCoordY(y), toCoordX(x + 2 + 5/12.0 + 13.8/12 + 20.5/12 + 13.8/12));
      */
      vertex(toCoordY(y), toCoordX(x));
      vertex(toCoordY(y - 19.6/12), toCoordX(x + 10.44/12));
      vertex(toCoordY(y - 19.6/12), toCoordX(x + 10.44/12 + 18.5/12));
      vertex(toCoordY(y), toCoordX(x + 10.44/12 + 18.5/12 + 10.44/12));
      vertex(toCoordY(y), toCoordX(x));
      
      // Alignment lines
      stroke(255);
      line(toCoordY(y - 19.6/24), toCoordX(x + 10.44/24), toCoordY(y - 19.6/24 - 1.5 * (float)Math.cos(61*PI/180)), toCoordX(x + 10.44/24 - 1.5 * (float)Math.sin(61*PI/180)));
      line(toCoordY(y - 19.6/24), toCoordX(x + 34.155/12), toCoordY(y - 19.6/24 - 1.5 * (float)Math.cos(61*PI/180)), toCoordX(x + 34.155/12 + 1.5 * (float)Math.sin(61*PI/180)));
      line(toCoordY(y - 19.567/12), toCoordX(x + 39.375/24), toCoordY(y - 19.567/12 - 1.5), toCoordX(x + 39.375/24));
      stroke(0);
    }
    endShape();
    noFill();
    
    /*
    fill(0);
    textSize(16*scale);
    if(!reverse){
      if(memesEnabled){
        text("Seal", toCoordY(y + 1), toCoordX(x + 1.8));
      }else{
        textSize(12*scale);
        text("Rocket", toCoordY(y + 1), toCoordX(x + 1.8));
      }
    }else{
      if(memesEnabled){
        text("Seal", toCoordY(y - 1), toCoordX(x + 1.8)); 
      }else{
        textSize(12*scale);
        text("Rocket", toCoordY(y - 1), toCoordX(x + 1.8)); 
      }
    }
    */
  }
}
private class CargoShip extends Field{
  private float x;
  private float y;
  CargoShip(float x, float y){
    this.x = x;
    this.y = y;
  }
  public void display(){
    // Main body
    fill(220, 220, 220);
    beginShape();
    vertex(toCoordY(y), toCoordX(x));
    vertex(toCoordY(y + 3 + 9/12.0), toCoordX(x));
    vertex(toCoordY(y + 3 + 9/12.0 + 10.75/24), toCoordX(x + 20.62/12));
    vertex(toCoordY(y + 3 + 9/12.0 + 10.75/24), toCoordX(x + 20.62/12 + 75.13/12));
    vertex(toCoordY(y - 10.75/24), toCoordX(x + 20.62/12 + 75.13/12));
    vertex(toCoordY(y - 10.75/24), toCoordX(x + 20.62/12));
    vertex(toCoordY(y), toCoordX(x));
    endShape();
    
    
    // Hatch lines
    stroke(255);
    line(toCoordY(y + 3 + 9/12.0 + 10.75/24 + 1.5), toCoordX(x + 20.62/12 + (78.55 - (45 + 66.5)/2.0)/12.0), 
    toCoordY(y + 3 + 9/12.0 + 10.75/24), toCoordX(x + 20.62/12 + (78.55 - (45 + 66.5)/2.0)/12.0));
    line(toCoordY(y + 3 + 9/12.0 + 10.75/24 + 1.5), toCoordX(x + 20.62/12 + (78.55 - (23 + 44.5)/2.0)/12.0), 
    toCoordY(y + 3 + 9/12.0 + 10.75/24), toCoordX(x + 20.62/12 + (78.55 - (23 + 44.5)/2.0)/12.0));
    line(toCoordY(y + 3 + 9/12.0 + 10.75/24 + 1.5), toCoordX(x + 20.62/12 + (78.55 - 23.5/2.0)/12.0), 
    toCoordY(y + 3 + 9/12.0 + 10.75/24), toCoordX(x + 20.62/12 + (78.55 - 23.5/2.0)/12.0));
    
    line(toCoordY(y - 10.75/24 - 1.5), toCoordX(x + 20.62/12 + (78.55 - (45 + 66.5)/2.0)/12.0), 
    toCoordY(y - 10.75/24), toCoordX(x + 20.62/12 + (78.55 - (45 + 66.5)/2.0)/12.0));
    line(toCoordY(y - 10.75/24 - 1.5), toCoordX(x + 20.62/12 + (78.55 - (23 + 44.5)/2.0)/12.0), 
    toCoordY(y - 10.75/24), toCoordX(x + 20.62/12 + (78.55 - (23 + 44.5)/2.0)/12.0));
    line(toCoordY(y - 10.75/24 - 1.5), toCoordX(x + 20.62/12 + (78.55 - 23.5/2.0)/12.0), 
    toCoordY(y - 10.75/24), toCoordX(x + 20.62/12 + (78.55 - 23.5/2.0)/12.0));
    
    line(toCoordY(y + 21.5/24.0), toCoordX(x), toCoordY(y + 21.5/24.0), toCoordX(x - 1.5));
    line(toCoordY(y + (23 + 44)/24.0), toCoordX(x), toCoordY(y + (23 + 44)/24.0), toCoordX(x - 1.5));
    
    stroke(0);
    noFill();
    
    fill(0);
    textSize(16*scale);
    if(memesEnabled){
      text("The Walrus", toCoordY(y + 2), toCoordX(x + 4));
    }else{
      text("Cargo Ship", toCoordY(y + 2), toCoordX(x + 4));
    }
  }
}
private class HABPlateform extends Field{
  private float x;
  private float y;
  HABPlateform(float x, float y){
    this.x = x;
    this.y = y;
  }
  public void display(){
    fill(220, 220, 220);
    rectMode(CORNERS);
    rect(toCoordY(y), toCoordX(x), toCoordY(y + 1 + 10.625/12), toCoordX(x + 4));// Right most cargo
    rect(toCoordY(y + 1 + 10.625/12 + 10 + 8.0/12), toCoordX(x), toCoordY(y + 1 + 10.625/12 + 10 + 8.0/12 + 1 + 10.625/12), toCoordX(x + 4));// Left most cargo
    
    rect(toCoordY(y + 1 + 10.625/12), toCoordX(x), toCoordY(y + 1 + 10.625/12 + 3 + 4.0/12), toCoordX(x + 4));// Right level 1
    rect(toCoordY(y + 1 + 10.625/12 + 3 + 4.0/12), toCoordX(x), toCoordY(y + 1 + 10.625/12 + 3 + 4.0/12 + 4), toCoordX(x + 4));//Center
    rect(toCoordY(y + 1 + 10.625/12 + 3 + 4.0/12 + 4), toCoordX(x), toCoordY(y + 1 + 10.625/12 + 3 + 4.0/12 + 4 + 3 + 4.0/12), toCoordX(x + 4));//Left
    
    rect(toCoordY(y + 11.375/12), toCoordX(x + 4), toCoordY(y + 11.375/12 + 12 + 6.5/12), toCoordX(x + 7 + 11.25/12));
    
    noFill();
    
    fill(0);
    textSize(16*scale);
    if(memesEnabled){
      text("The Iceberg", toCoordY(y + 7.4), toCoordX(x + 6));
    }else{
      text("HAB Platform", toCoordY(y + 7.4), toCoordX(x + 6));
    }
  }
}

private class LoadingStation extends Field{
  private float y;
  LoadingStation(float y){
    this.y = y;
  }
  public void display(){
    fill(0);
    stroke(255);
    line(toCoordY(y + (22.75/12)), toCoordX(0), toCoordY(y + (22.75/12)), toCoordX(1.5));
    noFill();
    stroke(0);
    line(toCoordY(y), toCoordX(0), toCoordY(y + 3.7917), toCoordX(0));
  }
  
}