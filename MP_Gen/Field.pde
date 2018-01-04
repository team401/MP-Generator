class Field{
  //units in feet
  private static final int WIDTH = 27;
  private static final int HEIGHT = 27;
  private static final int SPACING = 25;//(height-100)/HEIGHT;
  private boolean mp = false;
  private double[][] smoothPath;
  private double[][] leftPath;
  private double[][] rightPath;
  
  private ArrayList<int[]> waypoints;
  
  Field(){
    waypoints = new ArrayList<int[]>();
  }
  void display(){
    //vertical lines
    int w = width/2;
    //int h = height/2;
    int originX = (int)(w+(13.5*SPACING)-85);
    int originY = 80 + (HEIGHT*SPACING) -238;//check
    
    textAlign(CENTER);
    textSize(12);
    strokeWeight(0);
    stroke(0);
    
    for(int i = 0;i<=WIDTH;i++){
      line(w+(i*SPACING), 80, w+(i*SPACING),80+(HEIGHT*SPACING));
      text(i, w+(i*SPACING), 80+SPACING+(HEIGHT*SPACING));
    }
    for(int i = 0;i<=HEIGHT;i++){
      line(w, 80+(i*SPACING), w+(WIDTH*SPACING), 80+(i*SPACING));
      text(HEIGHT - i, w-SPACING, 85+(i*SPACING));
    }
    
    //neutral zone
    noStroke();
    fill(0,255,0, 30);
    rect(w, 80, (WIDTH*SPACING), originY - 228);
    fill(255);
    
    //airship
    stroke(0);
    strokeWeight(4);
    beginShape();
    vertex(originX+42.5, originY);
    vertex(originX, originY-72.5);
    vertex(originX+42.5, originY-145);
    vertex(originX+127.5, originY-145);
    vertex(originX+170, originY-72.5);
    vertex(originX+127.5, originY);
    vertex(originX+42.5, originY);
    endShape();
    
    //neutral zone
    //386

    line(w, originY - 148, w+(WIDTH*SPACING), originY-148);
    
    //baseline
    //194
    line(w, originY + 44, w+(WIDTH*SPACING), originY+44);
    
    //labels
    textSize(48);
    fill(0);
    text("Neutral Zone", w+(width/4), 255);
    fill(255);
    
    //display the coordinates
    if(mouseX >= w && mouseX <= w+(WIDTH*SPACING) && mouseY >= 80 && mouseY <= 80+(HEIGHT*SPACING)){
      fill(0);
      textSize(24);
      float mapX = map(mouseX, w, w+(WIDTH*SPACING), 0, 27);
      float mapY = map(mouseY, 80, 80+(HEIGHT*SPACING), 27, 0);
      
      int posX = round(mapX);
      int posY = round(mapY);
          
      int x = (int)map(posX, 0, 27, w, w+(WIDTH*SPACING));
      int y = (int)map(posY, 0, 27, 80+(HEIGHT*SPACING), 80);
      
      text("(" + posX + "," + posY +")", x+30, y-15);
      
      strokeWeight(12);
      line(x, y, x, y);
      //fill(255);
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
        float x = map(posX, 0, 27, w, w+(Field.WIDTH*Field.SPACING));
        float y = map(posY, 0, 27, 80+(Field.HEIGHT*Field.SPACING), 80);
          
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
        float x = map(posX, 0, 27, w, w+(Field.WIDTH*Field.SPACING));
        float y = map(posY, 0, 27, 80+(Field.HEIGHT*Field.SPACING), 80);
          
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
        float x = map(posX, 0, 27, w, w+(Field.WIDTH*Field.SPACING));
        float y = map(posY, 0, 27, 80+(Field.HEIGHT*Field.SPACING), 80);
          
        strokeWeight(2);
        stroke(255, 0, 255);
        vertex(x, y);
      }
      endShape();
  
    }else{
    noFill();
    beginShape();
    for(int i = 0;i<waypoints.size();i++){
      int posX = waypoints.get(i)[0];
      int posY = waypoints.get(i)[1];
      int x = (int)map(posX, 0, 27, w, w+(WIDTH*SPACING));
      int y = (int)map(posY, 0, 27, 80+(HEIGHT*SPACING), 80);
      
      strokeWeight(12);
      stroke(255,0,0);
      line(x, y, x, y);

      strokeWeight(2);
      vertex(x, y);
    }
    endShape();
    fill(255);
    }
  }
  void addWaypoint(int msX, int msY){
    int angle = 0;//make this real later
    int w = width/2;
    float mapX = map(msX, w, w+(WIDTH*SPACING), 0, 27);
    float mapY = map(msY, 80, 80+(HEIGHT*SPACING), 27, 0);
      
    int posX = round(mapX);
    int posY = round(mapY);
              
    waypoints.add(new int[]{posX,posY,angle});
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
    //may not work
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
      for(int[] u: waypoints){
        System.out.println("("+u[0]+","+u[1]+","+u[2]+")");
      }
    }
  }
  Waypoint[] toWaypointObj(){
    Waypoint[] points = new Waypoint[waypoints.size()];
    for(int i = 0;i<waypoints.size();i++){
      //x, y, angle
      points[i] = new Waypoint((double)waypoints.get(i)[0], (double)waypoints.get(i)[1], (double)Pathfinder.d2r(waypoints.get(i)[2]));
    }
    return points;
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
}