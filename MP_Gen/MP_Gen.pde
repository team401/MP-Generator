import g4p_controls.*;
import java.awt.Font;
import java.awt.Color;
GButton blueButton, redButton, fileButton, pathButton, clearButton, newButton;
GTextField name;
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
  
  name = new GTextField(this, 0, 0, 200, 32);
  name.setFont(new Font("Dialog", Font.PLAIN, 24));
  
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
    exportCSV("profilecsv\\tank\\TESTL","");
  }
  if(button == pathButton){
    if(field.getWaypoints().length > 1){
      field.printWaypoints();
      path = new FalconPathPlanner(field.getWaypoints());
      //bogus values
      path.calculate(15, 0.02, 2);
      
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
    }else{
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
  }
  if(button == clearButton){
    field.clearWaypoints();
    field.disableMP();
  }
}
void fileSelector(File selection){
  if(selection == null){
    System.out.println("Error");
  }else{
    System.out.println(selection.getAbsolutePath());
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