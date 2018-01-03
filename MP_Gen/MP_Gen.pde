import g4p_controls.*;
import java.awt.Font;
import java.awt.Color;
GButton blueButton, redButton, fileButton, pathButton, clearButton, newButton, saveButton;
GTextField name, timeStep, time, wheelBase, wheelRadius;
Field field;
boolean blue;
int w;

//TODO:
//add fields for the input values
//add Pathfinder
//extention of above - add angle input values (mouse wheel?)
//add velocity graphs


FalconPathPlanner path;
void setup(){
  size(1440, 980);
  field = new Field();
  frameRate(120);
  w = width/2;
  
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
  
  newButton = new GButton(this, width/2-250, 200, 200, 100, "Generate new path");
  newButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  newButton.setEnabled(false);
  
  clearButton = new GButton(this, width/2-250, 440, 200, 100, "Clear path");
  clearButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  saveButton = new GButton(this, 150, 380, 100, 50, "Save");
  saveButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  //text
  name = new GTextField(this, 100, 80, 200, 32);
  name.setFont(new Font("Dialog", Font.PLAIN, 24));
  name.setPromptText("Profile Name");
  
  timeStep = new GTextField(this, 100, 120, 200, 32);
  timeStep.setFont(new Font("Dialog", Font.PLAIN, 24));
  timeStep.setPromptText("Timestep (millisec)");
  
  time = new GTextField(this, 100, 160, 200, 32);
  time.setFont(new Font("Dialog", Font.PLAIN, 24));
  time.setPromptText("Time (sec)");
  
  wheelBase = new GTextField(this, 100, 280, 200, 32);
  wheelBase.setFont(new Font("Dialog", Font.PLAIN, 24));
  wheelBase.setText(findValue("width"));
  wheelBase.setPromptText("Robot Width (feet)");
  
  wheelRadius = new GTextField(this, 100, 320, 200, 32);
  wheelRadius.setFont(new Font("Dialog", Font.PLAIN, 24));
  wheelRadius.setText(findValue("radius"));
  wheelRadius.setPromptText("Wheel Radius (in)");
  
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
  text("Input Variables", 100, 70);

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
    newButton.setEnabled(true);
    
    //rename "TEST" to input name
    if(name.getText().length() > 0){//there is some text
      exportCSV("profilecsv\\tank\\"+name.getText(),"");
    }else{
      fileButton.setEnabled(false);
      fileButton.setText("Please enter a name");
    }
  }
  if(button == pathButton){
    if(field.getWaypoints().length > 1){
      if(!timeStep.getText().equals("") && !findValue("width").equals("") && !findValue("radius").equals("") && !time.getText().equals("")){
        field.printWaypoints();
        path = new FalconPathPlanner(field.getWaypoints());
        //bogus values
        //(time, timestep, width)
        path.calculate(Double.parseDouble(time.getText()), Double.parseDouble(timeStep.getText())/1000, Double.parseDouble(findValue("width")));
        
        field.setSmoothPath(path.smoothPath);
        field.setLeftPath(path.leftPath);
        field.setRightPath(path.rightPath);
        field.enableMP();
        
        System.out.println("Smoothpath:");
        for(int i = 0;i<path.smoothPath.length;i++){
          System.out.println("{"+path.smoothPath[i][0]+","+path.smoothPath[i][1]+"},");
        }
              
        pathButton.setEnabled(false);
        fileButton.setEnabled(true);
      }else{//if no settings
        System.out.println("Something went wrong");
        if(timeStep.getText().equals("")){
          timeStep.setLocalColorScheme(GConstants.RED_SCHEME);
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
  }
  if(button == clearButton){
    field.clearWaypoints();
    field.disableMP();
    //TEST functions
    System.out.println(name.getText());
  }
  if(button == saveButton){
    String[] sets = {"width:"+wheelBase.getText(), "radius:"+wheelRadius.getText()};
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
  timeStep.setLocalColorScheme(GConstants.BLUE_SCHEME);
  fileButton.setText("Export");
  fileButton.setEnabled(true);
  System.out.println(event);
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
  //3. ??
  
  //display settings
  textAlign(LEFT, BOTTOM);
  text("Settings", 100, 270);
  text("Width", 10, 312);
  text("Radius", 10, 352);
  
  
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