import g4p_controls.*;
import java.awt.Font;
import java.awt.Color;
GButton blueButton, redButton, fileButton, pathButton, testButton, newButton, saveButton,
velocityButton, centerButton, leftButton, rightButton, loadButton, directoryButton;
GTextField name, timeStep, wheelBase, wheelRadius, maxVel, maxAccel, maxJerk, directory;
GLabel error;
GSlider reverse;
Field field;
Trajectory traj;
boolean blue, velocity;
int w, graph;
final int X_TEXT = 130;
int angle;
double METERS_TO_REV, METERS_TO_INCHES;
File massExport;
double timestep, pos, vel, accel, jerk, robotWidth;

void setup(){
  size(1440, 960);
  field = new Field();
  frameRate(120);
  w = width/2;
  angle = 90;
  graph = 0;
  
  velocity = false;

  METERS_TO_REV = (1/ 0.3048) * 12 * (1 / (2 * Double.parseDouble(findValue("radius"))*Math.PI));
  METERS_TO_INCHES = (1/0.3048) * 12;
  
  timestep = Double.parseDouble(findValue("timestep"))/1000;
  vel = Double.parseDouble(findValue("maxVelocity"));
  accel = Double.parseDouble(findValue("maxAccel"));
  jerk = Double.parseDouble(findValue("maxJerk"));
  robotWidth = Double.parseDouble(findValue("width"))*0.3048;//in meters
  
  //misc
  blueButton = new GButton(this, width/2-250, 550, 100, 100, "Blue");
  blueButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  redButton = new GButton(this, width/2-250, 660, 100, 100, "Red");
  redButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  velocityButton = new GButton(this, width/2-250, 770, 100, 100, "Velocity");
  velocityButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  centerButton = new GButton(this, width/2-250 + 110, 550, 100, 100, "Center");
  centerButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  leftButton = new GButton(this, width/2-250 + 110, 660, 100, 100, "Left");
  leftButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  rightButton = new GButton(this, width/2-250 + 110, 770, 100, 100, "Right");
  rightButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  centerButton.setEnabled(false);
  centerButton.setVisible(false);
  leftButton.setEnabled(false);
  leftButton.setVisible(false);
  rightButton.setEnabled(false);
  rightButton.setVisible(false);
  
  blueButton.setEnabled(true);
  redButton.setEnabled(false);
  velocityButton.setEnabled(false);
  blue = false;
  
  fileButton = new GButton(this, width/2-250, 320, 200, 100, "Export");
  fileButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  fileButton.setEnabled(false);
  
  //path stuff
  pathButton = new GButton(this, width/2-250, 80, 200, 100, "Generate Path");
  pathButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  newButton = new GButton(this, width/2-250, 200, 200, 100, "New path");
  newButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  testButton = new GButton(this, 300, 800, 100, 100, "TEST");
  testButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  saveButton = new GButton(this, X_TEXT + 50, 520, 100, 50, "Save");
  saveButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  loadButton = new GButton(this, width/2-250, 440, 200, 100, "Load Path");
  loadButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  directoryButton = new GButton(this, X_TEXT + 25, 620, 150, 50, "File Path");
  directoryButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  //Use for debugging
  testButton.setEnabled(false);
  testButton.setVisible(false);
  
  //text
  name = new GTextField(this, X_TEXT, 80, 200, 32);
  name.setFont(new Font("Dialog", Font.PLAIN, 24));
  name.setPromptText("Profile Name");
    
  wheelBase = new GTextField(this, X_TEXT, 280, 200, 32);
  wheelBase.setFont(new Font("Dialog", Font.PLAIN, 24));
  wheelBase.setText(findValue("width"));
  wheelBase.setPromptText("Robot Width (feet)");
  
  wheelRadius = new GTextField(this, X_TEXT, 320, 200, 32);
  wheelRadius.setFont(new Font("Dialog", Font.PLAIN, 24));
  wheelRadius.setText(findValue("radius"));
  wheelRadius.setPromptText("Wheel Radius (in)");
  
  timeStep = new GTextField(this, X_TEXT, 360, 200, 32);
  timeStep.setFont(new Font("Dialog", Font.PLAIN, 24));
  timeStep.setText(findValue("timestep"));
  timeStep.setPromptText("Timestep (millisec)");
  
  maxVel = new GTextField(this, X_TEXT, 400, 200, 32);
  maxVel.setFont(new Font("Dialog", Font.PLAIN, 24));
  maxVel.setText(findValue("maxVelocity"));
  maxVel.setPromptText("Max Vel (meters)");
  
  maxAccel = new GTextField(this, X_TEXT, 440, 200, 32);
  maxAccel.setFont(new Font("Dialog", Font.PLAIN, 24));
  maxAccel.setText(findValue("maxAccel"));
  maxAccel.setPromptText("Max Accel (meters)");
  
  maxJerk = new GTextField(this, X_TEXT, 480, 200, 32);
  maxJerk.setFont(new Font("Dialog", Font.PLAIN, 24));
  maxJerk.setText(findValue("maxJerk"));
  maxJerk.setPromptText("Max Jerk (meters)");
  
  error = new GLabel(this, 75, 800, 400, 100);
  error.setFont(new Font("Dialog", Font.PLAIN, 24));
  error.setLocalColorScheme(GConstants.RED_SCHEME);
  error.resizeToFit(false, false);
        
  directory = new GTextField(this, X_TEXT, 580, 200, 32);
  directory.setFont(new Font("Dialog", Font.PLAIN, 24));
  directory.setText("profilecsv\\tank\\");
  directory.setPromptText("Directory");
  
  //sliders
  reverse = new GSlider(this, X_TEXT, 780, 50, 50,25);
  reverse.setNbrTicks(2);
  reverse.setStickToTicks(true);
  reverse.setShowTicks(false);
  reverse.setEnabled(true);
  reverse.setValue(0);
  
}
void draw(){
  background(200);
  field.display();
  
  fill(0);
  textSize(24);
  
  if(velocity){
    switch(graph){
      case 0:
        text("Center Path Velocity", width*0.75, 50);
      break;
      
      case 1:
        text("Left Path Velocity", width*0.75, 50);
      break;
      
      case 2:
        text("Right Path Velocity", width*0.75, 50);
      break;
    }
  }else{
    if(blue){
      text("Blue Alliance", width*0.75, 50);
    }else{
      text("Red Alliance", width*0.75, 50);
    }
  }
  
  //text inputs
  textAlign(LEFT, BOTTOM);
  text("Input Variables", X_TEXT, 70);

  //settings are:
  //1. Robot width
  //2. Wheel Radius
  //3. Timestep
  //4. Max Velocity
  //5. Max Acceleration
  //6. Max Jerk
  
  //display settings
  textAlign(LEFT, BOTTOM);
  text("Settings", 120, 270);
  text("Width", 10, 312);
  text("Radius", 10, 352);
  text("Timestep", 10, 392);
  text("Max Vel", 10, 432);
  text("Max Accel", 10, 472);
  text("Max Jerk", 10, 512);
  
  text("Direction", 105, 780);
  text("Forward", 30, 820);
  text("Reverse", 190, 820);
}
void mouseClicked(){
  int w = width/2;
  if(mouseX >= w && mouseX <= w+(Field.WIDTH*Field.SPACING) && mouseY >= 80 && mouseY <= 80+(Field.HEIGHT*Field.SPACING) 
  && !field.getMP()){
    if(mouseButton == LEFT){
      field.addWaypoint(mouseX, mouseY);
      pathButton.setText("Generate Path");
    }
    if(mouseButton == RIGHT){
      field.removeWaypoint();
    }
  }
}
void mouseWheel(MouseEvent event){
  float e = event.getAmount();
  int da = Integer.parseInt(findValue("angle"));
  if(e>0){
    angle+=da;
  }
  if(e<0){
    angle-=da;
  }
}
void handleButtonEvents(GButton button, GEvent event){
  
  error.setText("");
  
  if(button == blueButton){
    blueButton.setEnabled(false);
    redButton.setEnabled(true);
    blue = true;
  }
  if(button == redButton){
    blueButton.setEnabled(true);
    redButton.setEnabled(false);
    blue = false;
  }
  if(button == fileButton){
    if(name.getText().length() > 0 && !name.getText().equals(" ")){//there is some text
      boolean exportSuccess = false;
      if(field.getReverse()){
        exportSuccess = exportToCSVReverse(field, name.getText(), true);
      }else{
        exportSuccess = exportToCSV(field, name.getText(), true); 
      }
      field.exportWaypoints();
      
      if(exportSuccess){
        field.clearWaypoints();
        field.disableMP();
        pathButton.setEnabled(true);
        fileButton.setEnabled(false);
        loadButton.setEnabled(true);
        name.setText("");
      }
      
    }else{
      name.setLocalColorScheme(GConstants.RED_SCHEME);
      fileButton.setEnabled(false);
      fileButton.setText("Please enter a name");
    }
  }
  if(button == pathButton){
    boolean success = generatePaths(field, name.getText());
    if(success && field.getWaypoints().length > 0){
      pathsGenerated();
    }else{
      if(field.getWaypoints() == null){
        pathButton.setText("Please enter a path");
      }
    }
  }
  if(button == newButton){
    pathButton.setEnabled(true);
    fileButton.setEnabled(false);
    velocityButton.setEnabled(false);
    loadButton.setEnabled(true);
    field.clearWaypoints();
    field.disableMP();
    name.setText("");
  }
  if(button == testButton){
    //TEST functions
    error.setText("TEST");
    println("TESTING");
  }
  if(button == saveButton){
    String[] sets = {"width:"+wheelBase.getText(), "radius:"+wheelRadius.getText(), "timestep:"+timeStep.getText(), "maxVelocity:"+maxVel.getText(),
  "maxAccel:"+maxAccel.getText(), "maxJerk:"+maxJerk.getText(), "angle:"+findValue("angle"),"mapIncrements:"+findValue("mapIncrements")};
    saveStrings("settings.txt", sets);
    
    METERS_TO_REV = (1/ 0.3048) * 12 * (1 / (2 * Double.parseDouble(findValue("radius"))*Math.PI));
    timestep = Double.parseDouble(findValue("timestep"))/1000;
    vel = Double.parseDouble(findValue("maxVelocity"));
    accel = Double.parseDouble(findValue("maxAccel"));
    jerk = Double.parseDouble(findValue("maxJerk"));
    robotWidth = Double.parseDouble(findValue("width"))*0.3048;//in meters
  }
  if(button == velocityButton){
    if(velocity){//currently displaying velocity graphs
      velocity = false;
      velocityButton.setText("Velocity");
      
      centerButton.setEnabled(false);
      centerButton.setVisible(false);
      leftButton.setEnabled(false);
      leftButton.setVisible(false);
      rightButton.setEnabled(false);
      rightButton.setVisible(false);
      
      if(blue){
        blueButton.setEnabled(false);
        redButton.setEnabled(true);
      }else{
        blueButton.setEnabled(true);
        redButton.setEnabled(false);
      }
      pathButton.setEnabled(true);
      newButton.setEnabled(true);
      fileButton.setEnabled(true);
      testButton.setEnabled(true);
      loadButton.setEnabled(true);
    }else{
      velocity = true;
      velocityButton.setText("Paths");
      
      centerButton.setEnabled(true);
      centerButton.setVisible(true);
      leftButton.setEnabled(true);
      leftButton.setVisible(true);
      rightButton.setEnabled(true);
      rightButton.setVisible(true);
      
      blueButton.setEnabled(false);
      redButton.setEnabled(false);
      pathButton.setEnabled(false);
      newButton.setEnabled(false);
      fileButton.setEnabled(false);
      testButton.setEnabled(false);
      loadButton.setEnabled(false);
    }
  }
  if(button == centerButton){
    graph = 0;
  }
  if(button == leftButton){
    graph = 1;
  }
  if(button == rightButton){
    graph = 2;
  }
  if(button == loadButton){
    if(keyCode == SHIFT){
      selectFolder("Choose folder to export", "massFileSelector");
    }else{
      selectInput("Choose File to load", "fileSelector");
      
    }
  }
  if(button == directoryButton){
    selectFolder("Choose export path", "pathSelector");
  }
}
void pathSelector(File selection){
  if(selection == null){
    //no nothing
  }else{
    directory.setText(selection.getAbsolutePath());
  }
}
void fileSelector(File selection){
  if(selection == null){
  }else{
    field.loadWaypoints(selection.getAbsolutePath());
    String[] folders = selection.getAbsolutePath().split("\\\\");
    String n = folders[folders.length-1];
    if(n.contains("_REV")){
      name.setText(n.substring(0, n.length()-8));
    }else{
      name.setText(n.substring(0, n.length()-4));
    }
    if(field.getReverse()){
      reverse.setValue(1); 
    }else{
      reverse.setValue(0); 
    }
  }  
}
void massFileSelector(File selection){
  if(selection == null){
  }else{
    massExport = selection;
    
    thread("autoGenerate");
  }
}

public void handleTextEvents(GEditableTextControl textcontrol, GEvent event){
  name.setLocalColorScheme(GConstants.BLUE_SCHEME);
  fileButton.setText("Export");
  fileButton.setEnabled(true);
}
public void handleSliderEvents(GValueControl slider, GEvent event) { 
  if(slider == reverse){
    if(reverse.getValueI() == 0){// Forward
      setReverse(field, false);
    }else{//Reverse
      setReverse(field, true);
    }
    // 1 is reverse, 0 is forward
  }
}
boolean exportToCSVReverse(Field field, String name, boolean revs){
  boolean exportSuccessL = false;
  boolean exportSuccessR = false;
  PrintWriter outputL = null;
  PrintWriter outputR = null;
  try{
      outputL = createWriter(directory.getText() + "/profiles/" + name+"_R.csv");
    for(int i = 0;i<field.leftPathVelocity.length;i++){
      if(revs){
        //rev's per second
        //meters to feet to inches to revolutions
        double position = field.leftPathVelocity[i][0] * METERS_TO_INCHES * -1;
        double velocity = field.leftPathVelocity[i][1] * METERS_TO_INCHES * 60.0 * -1;
        double acceleration = field.leftPathVelocity[i][2] * METERS_TO_INCHES * 60.0;
        double heading = (field.smoothPathVelocity[i][3] * (180/Math.PI) - 180) % 360;
        outputL.println(position + "," + velocity + "," + findValue("timestep") + "," + acceleration + "," + heading);
      }/*
      else{//Possible error...
        outputL.println(field.leftPathVelocity[i][0]*-1 + "," + field.leftPathVelocity[i][1]*-1 + "," + 
        findValue("timestep") + "," + field.smoothPathVelocity[i][3]*-1);
      }
      */
    }     
    exportSuccessL = true;
  }catch(RuntimeException e){
    error.setText("File " + name + "_L.csv is open! Close the file and try again.");
    println(e);
    exportSuccessL = false;
  }
  outputL.flush();
  outputL.close();
  
  try{
    outputR = createWriter(directory.getText() + "/profiles/" + name+"_L.csv");
    for(int i = 0;i<field.rightPathVelocity.length;i++){
      if(revs){
        //revs per second
        double position = field.rightPathVelocity[i][0] * METERS_TO_INCHES * -1;
        double velocity = field.rightPathVelocity[i][1] * METERS_TO_INCHES * 60.0 * -1;
        double acceleration = field.rightPathVelocity[i][2] * METERS_TO_INCHES * 60.0;
        double heading = (field.smoothPathVelocity[i][3] * (180/Math.PI) - 180) % 360;
        outputR.println(position + "," + velocity + "," + findValue("timestep") + "," + acceleration + "," + heading);
      }
      /*else{
        outputR.println(field.rightPathVelocity[i][0]*-1 + "," + field.rightPathVelocity[i][1]*-1 + "," + 
        findValue("timestep") + "," + field.smoothPathVelocity[i][3]);
      }
      */
    }   
   
    exportSuccessR = true;
   
  }catch(RuntimeException e){
    error.setText("File " + name + "_R.csv is open! Close the file and try again.");
    println(e);
    exportSuccessR = false;
  }
  outputR.flush();
  outputR.close();
  
  return exportSuccessL && exportSuccessR;
}

// Doesn't work if the file is open
boolean exportToCSV(Field field, String name, boolean revs){
  boolean exportSuccessL = false;
  boolean exportSuccessR = false;
  PrintWriter outputL = null;
  PrintWriter outputR = null;
  try{
      outputL = createWriter(directory.getText() + "/profiles/" + name+"_L.csv");
    for(int i = 0;i<field.leftPathVelocity.length;i++){
      if(revs){
        //rev's per second
        //meters to feet to inches to revolutions
        double position = field.leftPathVelocity[i][0] * METERS_TO_INCHES;
        double velocity = field.leftPathVelocity[i][1] * METERS_TO_INCHES * 60.0;
        double acceleration = field.leftPathVelocity[i][2] * METERS_TO_INCHES * 60.0;
        double heading = field.smoothPathVelocity[i][3] * (180/Math.PI);
        outputL.println(position + "," + velocity + "," + findValue("timestep") + "," + acceleration + "," + heading);
      }else{
        outputL.println(field.leftPathVelocity[i][0] + "," + field.leftPathVelocity[i][1] + "," + 
        findValue("timestep") + "," + field.smoothPathVelocity[i][3]);
      }
    }     
    exportSuccessL = true;
  }catch(RuntimeException e){
    error.setText("File " + name + "_L.csv is open! Close the file and try again.");
    println(e);
    exportSuccessL = false;
  }
  outputL.flush();
  outputL.close();
  try{
    outputR = createWriter(directory.getText() + "/profiles/" + name+"_R.csv");
    for(int i = 0;i<field.rightPathVelocity.length;i++){
      if(revs){
        //revs per second
        double position = field.rightPathVelocity[i][0] * METERS_TO_INCHES;
        double velocity = field.rightPathVelocity[i][1] * METERS_TO_INCHES * 60.0;
        double acceleration = field.rightPathVelocity[i][2] * METERS_TO_INCHES * 60.0;
        double heading = field.smoothPathVelocity[i][3] * (180/Math.PI);
        outputR.println(position + "," + velocity + "," + findValue("timestep") + "," + acceleration + "," + heading);
      }else{
        outputR.println(field.rightPathVelocity[i][0] + "," + field.rightPathVelocity[i][1] + "," + 
        findValue("timestep") + "," + field.smoothPathVelocity[i][3]);
      }
    }   
   
    exportSuccessR = true;
   
  }catch(RuntimeException e){
    error.setText("File " + name + "_R.csv is open! Close the file and try again.");
    println(e);
    exportSuccessR = false;
  }
  outputR.flush();
  outputR.close();
  
  return exportSuccessL && exportSuccessR;
}
//needs better
String findValue(String keyword){
  String[] data = loadStrings("settings.txt");
  int index = 0;
  for(int i = 0;i<data.length;i++){
    if(data[i].startsWith(keyword)){
      index = i;
    }
  }
  return data[index].substring(keyword.length() + 1);
}
//quick and dirty
void placePaths(){
  pathButton.setEnabled(true);
  fileButton.setEnabled(false);
  loadButton.setEnabled(true);
}
void pathsGenerated(){
  newButton.setEnabled(true);
  pathButton.setEnabled(false);
  fileButton.setEnabled(true);
  loadButton.setEnabled(false);
  velocityButton.setEnabled(true);
}

void autoGenerate(){  
  File[] files = massExport.listFiles();
  Field field = this.field;
    
  for(File file : files){
    
    field.loadWaypoints(file.getAbsolutePath()); 
        
    String n = file.getName();//.substring(0, file.getName().length()-4);
    if(n.contains("_REV")){
      n = n.substring(0, n.length()-8);
    }else{
      n = n.substring(0, n.length()-4);
    }
    this.name.setText(n);
    
    println("Working on file " + n);
    
    boolean temp = generatePaths(field, n);
    
    if(temp && n.length() > 0){
      if(field.getReverse()){
        exportToCSVReverse(field, n, true);
      }else{
        exportToCSV(field, n, true);
      }
      field.exportWaypoints();
    }
    
    field.disableMP();
    field.clearWaypoints();
  }
  name.setText("");
  error.setText("Mass export complete");
   
}//end method

boolean generatePaths(Field field, String name){  
  boolean noIssues = true;
  Trajectory trajectory;
    
  //pathFinder logic
  //config(Fitmethod, sampleRate, timestep, max velocity, max acceleration, max jerk)
        
    if(field.getWaypoints().length > 1){
      if(timestep != 0 && robotWidth != 0 && vel != 0 && accel != 0 && jerk != 0){
       
        Trajectory.Config config = new Trajectory.Config(Trajectory.FitMethod.HERMITE_QUINTIC, Trajectory.Config.SAMPLES_HIGH, timestep, vel, accel, jerk);
        
        Waypoint[] points = field.toWaypointObj();

        //calculates the profile
        try{
          trajectory = Pathfinder.generate(points, config);//error on this line
                    
          //Tank drive
          TankModifier modifier = new TankModifier(trajectory);
          modifier.modify(robotWidth);
                    
          Trajectory left = modifier.getLeftTrajectory();
          Trajectory right = modifier.getRightTrajectory();
                    
          //add to smoothpath, rightpath, and leftpath to display?
          double[][] centerPath = new double[trajectory.length()][3];
          double[][] rightPath = new double[left.length()][3];
          double[][] leftPath = new double[right.length()][3];
          double[][] centerPathVelocity = new double[trajectory.length()][4];
          double[][] rightPathVelocity = new double[left.length()][4];
          double[][] leftPathVelocity = new double[right.length()][4];
                    
          for(int i = 0;i<trajectory.length();i++){
            Trajectory.Segment seg = trajectory.get(i);
            
            centerPath[i][0] = seg.x/0.3048;
            centerPath[i][1] = seg.y/0.3048;
            
            centerPathVelocity[i][0] = seg.position;
            centerPathVelocity[i][1] = seg.velocity;
            centerPathVelocity[i][2] = seg.acceleration;
            centerPathVelocity[i][3] = seg.heading;

          }
          for(int i = 0;i<left.length();i++){
            Trajectory.Segment seg = left.get(i);
            
            leftPath[i][0] = seg.x/0.3048;
            leftPath[i][1] = seg.y/0.3048;
            
            leftPathVelocity[i][0] = seg.position;
            leftPathVelocity[i][1] = seg.velocity;
            leftPathVelocity[i][2] = seg.acceleration;
          }
          for(int i = 0;i<right.length();i++){
            Trajectory.Segment seg = right.get(i);
            
            rightPath[i][0] = seg.x/0.3048;
            rightPath[i][1] = seg.y/0.3048;
            
            rightPathVelocity[i][0] = seg.position;
            rightPathVelocity[i][1] = seg.velocity;
            rightPathVelocity[i][2] = seg.acceleration;
          }
                    
          field.setSmoothPath(centerPath);
          field.setLeftPath(leftPath);
          field.setRightPath(rightPath);
          
          field.setSmoothPathVelocity(centerPathVelocity);
          field.setLeftPathVelocity(leftPathVelocity);
          field.setRightPathVelocity(rightPathVelocity);
          
          field.enableMP();
        }catch(Exception e){
          error.setText("This profile cannot be generated! Please revise your waypoints and try again.");
          noIssues = false;
        }
        
      }else{//if no settings
        noIssues = false;
      }
    }//end general if statment
    return noIssues;
}//end generatePaths()

void clearPaths(Field field){
    pathButton.setEnabled(true);
    fileButton.setEnabled(false);
    velocityButton.setEnabled(false);
    loadButton.setEnabled(true);
    field.clearWaypoints();
    field.disableMP();
    name.setText("");
}
void setReverse(Field field, boolean reverse){
  field.setReverse(reverse);
}