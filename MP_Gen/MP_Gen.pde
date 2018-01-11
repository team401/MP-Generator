import g4p_controls.*;
import java.awt.Font;
import java.awt.Color;
GButton blueButton, redButton, fileButton, pathButton, testButton, newButton, saveButton,
velocityButton, centerButton, leftButton, rightButton, loadButton;
GTextField name, timeStep, time, wheelBase, wheelRadius, maxVel, maxAccel, maxJerk;
GSlider pathSelector;
Field field;
FalconPathPlanner path;
Trajectory traj;
boolean blue, pathfinder, velocity;
int w, graph;
final int X_TEXT = 130;
int angle;
//TODO:
//add exporting csv for Pathfinder and check that these fit the new format
//add custom file for loading paths

void setup(){
  size(1440, 960);
  field = new Field();
  frameRate(120);
  w = width/2;
  angle = 0;
  graph = 0;
  
  pathfinder = false;
  velocity = false;
  
  pathSelector = new GSlider(this, 175, 700, 50, 50, 25);
  pathSelector.setNbrTicks(2);
  pathSelector.setStickToTicks(true);
  pathSelector.setShowTicks(false);
  pathSelector.setEnabled(true);
  pathSelector.setValue(0.0);
  
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
  newButton.setEnabled(false);
  
  testButton = new GButton(this, width/2-250, 440, 200, 100, "TEST");
  testButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  saveButton = new GButton(this, X_TEXT + 50, 520, 100, 50, "Save");
  saveButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  loadButton = new GButton(this, width/2-250, 440, 200, 100, "Load from CSV");
  loadButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  //Use for debugging
  testButton.setEnabled(false);
  testButton.setVisible(false);
  
  //text
  name = new GTextField(this, X_TEXT, 80, 200, 32);
  name.setFont(new Font("Dialog", Font.PLAIN, 24));
  name.setPromptText("Profile Name");
  
  time = new GTextField(this, X_TEXT, 120, 200, 32);
  time.setFont(new Font("Dialog", Font.PLAIN, 24));
  time.setPromptText("Time (sec)");
  
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
  maxVel.setPromptText("Max Velocity");
  
  maxAccel = new GTextField(this, X_TEXT, 440, 200, 32);
  maxAccel.setFont(new Font("Dialog", Font.PLAIN, 24));
  maxAccel.setText(findValue("maxAccel"));
  maxAccel.setPromptText("Max Acceleration");
  
  maxJerk = new GTextField(this, X_TEXT, 480, 200, 32);
  maxJerk.setFont(new Font("Dialog", Font.PLAIN, 24));
  maxJerk.setText(findValue("maxJerk"));
  maxJerk.setPromptText("Max Jerk");
  
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
    
  
  //pathSelector
  text("FalconPathPlanner", 235, 738);
  text("Pathfinder", 50, 738);
  
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

  if(e>0){
    angle+=2;
  }
  if(e<0){
    angle-=2;
  }
}
void handleButtonEvents(GButton button, GEvent event){
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
    //selectOutput("Choose a where to export to", "fileSelector");
    
    //rename "TEST" to input name
    if(name.getText().length() > 0){//there is some text
      if(pathfinder){
        println("Pathfinder gen ran");
        //Caused a complete program crash, not idea why
        //File newFile = new File("profilecsv\\tank\\"+name.getText()+".csv");
        //Pathfinder.writeToCSV(newFile, traj);
      }else{
        println("Falcon gen ran");
        exportCSV("profilecsv\\tank\\"+name.getText(),"");
        field.exportWaypoints();
      }
      field.clearWaypoints();
      field.disableMP();
      name.setText("");
      time.setText("");
      newButton.setEnabled(false);
      pathButton.setEnabled(true);
      fileButton.setEnabled(false);
      velocityButton.setEnabled(false);
      loadButton.setEnabled(true);
    }else{
      fileButton.setEnabled(false);
      fileButton.setText("Please enter a name");
    }
  }
  if(button == pathButton){
    if(field.getWaypoints().length > 1){
      if(!findValue("timestep").equals("") && !findValue("width").equals("") && !findValue("radius").equals("") && !time.getText().equals("")){
        
        newButton.setEnabled(true);
        pathButton.setEnabled(false);
        fileButton.setEnabled(true);
        loadButton.setEnabled(false);
        velocityButton.setEnabled(true);
        
        //field.printWaypoints();
        
        if(pathfinder){//pathFinder logic
        //confing(Fitmethod, sampleRate, timestep, max velocity, max acceleration, max jerk)
        double timestep = Double.parseDouble(findValue("timestep"))/1000;
        double vel = Double.parseDouble(findValue("maxVelocity"));
        double accel = Double.parseDouble(findValue("maxAccel"));
        double jerk = Double.parseDouble(findValue("maxJerk"));
        double robotWidth = Double.parseDouble(findValue("width"));//in meters
        
        Trajectory.Config config = new Trajectory.Config(Trajectory.FitMethod.HERMITE_CUBIC, Trajectory.Config.SAMPLES_HIGH, timestep, vel, accel, jerk);
        
        Waypoint[] points = field.toWaypointObj(); // somthing is probably wrong here
        
        System.out.println("Waypoints 1 x : "+points[0].x);
        System.out.println("Waypoints 1 x : "+points[0].y);
        System.out.println("Waypoints 1 x : "+points[0].angle);
        
        //calculates the profile
        traj = Pathfinder.generate(points, config);//error on this line
        System.out.println("generate ran");
        
        //Tank drive
        TankModifier modifier = new TankModifier(traj);
        modifier.modify(robotWidth);
        System.out.println("modifier ran");
        
        Trajectory left = modifier.getLeftTrajectory();
        Trajectory right = modifier.getRightTrajectory();
        System.out.println("left/right ran");
        
        //add to smoothpath, rightpath, and leftpath to display?
        double[][] centerPath = new double[traj.length()][3];
        double[][] rightPath = new double[left.length()][3];
        double[][] leftPath = new double[right.length()][3];
        double[][] centerPathVelocity = new double[traj.length()][2];
        double[][] rightPathVelocity = new double[left.length()][2];
        double[][] leftPathVelocity = new double[right.length()][2];
        System.out.println("paths created");
        
        for(int i = 0;i<traj.length();i++){
          Trajectory.Segment seg = traj.get(i);
          
          centerPath[i][0] = seg.x;
          centerPath[i][1] = seg.y;
          
          centerPathVelocity[i][0] = seg.position;
          centerPathVelocity[i][1] = seg.velocity;
        }
        for(int i = 0;i<left.length();i++){
          Trajectory.Segment seg = left.get(i);
          
          leftPath[i][0] = seg.x;
          leftPath[i][1] = seg.y;
          
          leftPathVelocity[i][0] = seg.position;
          leftPathVelocity[i][1] = seg.velocity;
        }
        for(int i = 0;i<right.length();i++){
          Trajectory.Segment seg = right.get(i);
          
          rightPath[i][0] = seg.x;
          rightPath[i][1] = seg.y;
          
          rightPathVelocity[i][0] = seg.position;
          rightPathVelocity[i][1] = seg.velocity;
        }
        
        field.setSmoothPath(centerPath);
        field.setLeftPath(leftPath);
        field.setRightPath(rightPath);
        
        field.setSmoothPathVelocity(centerPathVelocity);
        field.setLeftPathVelocity(leftPathVelocity);
        field.setRightPathVelocity(rightPathVelocity);
        
        field.enableMP();
        
        
        }else{//FalconPathPlanner logic
          path = new FalconPathPlanner(field.getWaypoints());
          //(time, timestep, width)
          path.calculate(Double.parseDouble(time.getText()), Double.parseDouble(findValue("timestep"))/1000, Double.parseDouble(findValue("width")));
          
          field.setSmoothPath(path.smoothPath);
          field.setLeftPath(path.leftPath);
          field.setRightPath(path.rightPath);
          
          field.setSmoothPathVelocity(path.smoothCenterVelocity);
          field.setLeftPathVelocity(path.smoothLeftVelocity);
          field.setRightPathVelocity(path.smoothRightVelocity);
          
          //field.printPath(path.smoothCenterVelocity);
          
          field.enableMP();
        }    

      }else{//if no settings
        System.out.println("Something went wrong");
        if(time.getText().equals("")){
          time.setLocalColorScheme(GConstants.RED_SCHEME);
        }
        if(name.getText().equals("")){
          name.setLocalColorScheme(GConstants.RED_SCHEME);
        }
      }
    }else{//if no waypoints
      field.printWaypoints();
      
      pathButton.setText("Please enter a path");
    }
    
    //field.printPath(field.getSmoothPath());
  }
  if(button == newButton){
    newButton.setEnabled(false);
    pathButton.setEnabled(true);
    fileButton.setEnabled(false);
    velocityButton.setEnabled(false);
    loadButton.setEnabled(true);
    field.clearWaypoints();
    field.disableMP();
    name.setText("");
    time.setText("");
  }
  if(button == testButton){
    //TEST functions
    centerButton.setEnabled(true);
    centerButton.setVisible(true);
    leftButton.setEnabled(true);
    leftButton.setVisible(true);
    rightButton.setEnabled(true);
    rightButton.setVisible(true);
  }
  if(button == saveButton){
    String[] sets = {"width:"+wheelBase.getText(), "radius:"+wheelRadius.getText(), "timestep:"+timeStep.getText(), "maxVelocity:"+maxVel.getText(),
  "maxAccel:"+maxAccel.getText(), "maxJerk:"+maxJerk.getText()};
    saveStrings("settings.txt", sets);
    
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
    
  }
}
void fileSelector(File selection){
  if(selection == null){
    System.out.println("Error");
  }else{
    System.out.println(selection.getAbsolutePath());
  }
}
public void handleTextEvents(GEditableTextControl textcontrol, GEvent event){
  time.setLocalColorScheme(GConstants.BLUE_SCHEME);
  name.setLocalColorScheme(GConstants.BLUE_SCHEME);
  fileButton.setText("Export");
  fileButton.setEnabled(true);
}
public void handleSliderEvents(GValueControl slider, GEvent event) { 
  println(slider.getValueI());
  if(slider == pathSelector && slider.getValueI() == 1){
    pathfinder = false;
  }
  if(slider == pathSelector && slider.getValueI() == 0){
    pathfinder = true;
  }
  
}

void exportCSV(String prefix, String suffix){
  PrintWriter outputL = createWriter(prefix+" L"+suffix+".csv");
    for(double[] u: path.tankProfile(true)){
      for(double val: u){
        outputL.print(val+",");
      }
      outputL.println();
    }   
    outputL.flush();
    outputL.close();
    
    PrintWriter outputR = createWriter(prefix+" R"+suffix+".csv");
    for(double[] u: path.tankProfile(false)){
      for(double val: u){
        outputR.print(val+",");
      }
      outputR.println();
    }   
    outputR.flush();
    outputR.close();
}
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