import g4p_controls.*;
import java.awt.Font;
import java.awt.Color;
GButton blueButton, redButton, fileButton, pathButton, testButton, newButton, saveButton;
GTextField name, timeStep, time, wheelBase, wheelRadius;
Field field;
boolean blue, pathfinder;
int w;

//TODO:
//add fields for the input values
//add Pathfinder
//extention of above - add angle input values (mouse wheel?)
//add velocity graphs

//git 


FalconPathPlanner path;
void setup(){
  size(1440, 960);
  field = new Field();
  frameRate(120);
  w = width/2;
  
  pathfinder = false;
  
  blueButton = new GButton(this, 800, 850, 100, 100, "Blue");
  blueButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  redButton = new GButton(this, 1000, 850, 100, 100, "Red");
  redButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  blueButton.setEnabled(false);
  blue = true;
  
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
  
  saveButton = new GButton(this, 170, 420, 100, 50, "Save");
  saveButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  //text
  name = new GTextField(this, 120, 80, 200, 32);
  name.setFont(new Font("Dialog", Font.PLAIN, 24));
  name.setPromptText("Profile Name");
  
  time = new GTextField(this, 120, 120, 200, 32);
  time.setFont(new Font("Dialog", Font.PLAIN, 24));
  time.setPromptText("Time (sec)");
  
  wheelBase = new GTextField(this, 120, 280, 200, 32);
  wheelBase.setFont(new Font("Dialog", Font.PLAIN, 24));
  wheelBase.setText(findValue("width"));
  wheelBase.setPromptText("Robot Width (feet)");
  
  wheelRadius = new GTextField(this, 120, 320, 200, 32);
  wheelRadius.setFont(new Font("Dialog", Font.PLAIN, 24));
  wheelRadius.setText(findValue("radius"));
  wheelRadius.setPromptText("Wheel Radius (in)");
  
  timeStep = new GTextField(this, 120, 360, 200, 32);
  timeStep.setFont(new Font("Dialog", Font.PLAIN, 24));
  timeStep.setText(findValue("timestep"));
  timeStep.setPromptText("Timestep (millisec)");
  
}
void draw(){
  background(200);
  field.display();
  
  fill(0);
  textSize(24);
  if(blue){
    text("Blue Alliance", width*0.75, 50);
  }else{
    text("Red Alliance", width*0.75, 50);
  }
  
  //text inputs
  textAlign(LEFT, BOTTOM);
  text("Input Variables", 120, 70);

  sets();
  
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
void handleButtonEvents(GButton button, GEvent event){
  if(button == blueButton){
    System.out.println("blue");
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
      exportCSV("profilecsv\\tank\\"+name.getText(),"");
      field.clearWaypoints();
      field.disableMP();
      name.setText("");
      time.setText("");
      newButton.setEnabled(false);
      pathButton.setEnabled(true);
      fileButton.setEnabled(false);
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
        
        field.printWaypoints();
        
        if(pathfinder){//pathFinder logic
          
        }else{//FalconPathPlanner logic
          path = new FalconPathPlanner(field.getWaypoints());
          //bogus values
          //(time, timestep, width)
          path.calculate(Double.parseDouble(time.getText()), Double.parseDouble(findValue("timestep"))/1000, Double.parseDouble(findValue("width")));
          
          field.setSmoothPath(path.smoothPath);
          field.setLeftPath(path.leftPath);
          field.setRightPath(path.rightPath);
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
  }
  if(button == newButton){
    newButton.setEnabled(false);
    pathButton.setEnabled(true);
    fileButton.setEnabled(false);
    field.clearWaypoints();
    field.disableMP();
    name.setText("");
    time.setText("");
  }
  if(button == testButton){
    //TEST functions
    System.out.println(name.getText());
  }
  if(button == saveButton){
    String[] sets = {"width:"+wheelBase.getText(), "radius:"+wheelRadius.getText(), "timestep:"+timeStep.getText()};
    saveStrings("settings.txt", sets);

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
void sets(){
  //settings are:
  //1. Robot width
  //2. Wheel Radius
  //3. Timestep
  
  //display settings
  textAlign(LEFT, BOTTOM);
  text("Settings", 120, 270);
  text("Width", 10, 312);
  text("Radius", 10, 352);
  text("Timestep", 10, 392);
    
}
//possible values 
//width (width of the robot)
//radius (Wheel radius)
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