import g4p_controls.*;
import java.awt.Font;
import java.awt.Color;
GButton blueButton, redButton, fileButton, pathButton, clearButton, newButton;
Field field;
boolean blue;
int w;

//TODO
//Make a generate new path button
//make it so you have to export before you can generate a new path
//make a clear path button


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
    selectOutput("Choose a where to export to", "fileSelector");
    newButton.setEnabled(true);
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
    //values are made up
    
    
  }
  if(button == newButton){
    newButton.setEnabled(false);
    pathButton.setEnabled(true);
    fileButton.setEnabled(false);
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