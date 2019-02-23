import kotlin.collections.*;
import kotlin.jvm.internal.*;
import kotlin.coroutines.*;
import kotlin.coroutines.intrinsics.*;
import kotlin.coroutines.jvm.internal.*;
import kotlin.*;
import kotlin.io.*;
import kotlin.internal.*;
import kotlin.random.*;
import kotlin.js.*;
import kotlin.reflect.*;
import kotlin.jvm.*;
import kotlin.jvm.internal.markers.*;
import kotlin.jvm.internal.unsafe.*;
import kotlin.jvm.functions.*;
import kotlin.system.*;
import kotlin.contracts.*;
import kotlin.sequences.*;
import kotlin.comparisons.*;
import kotlin.text.*;
import kotlin.experimental.*;
import kotlin.concurrent.*;
import kotlin.properties.*;
import kotlin.annotation.*;
import kotlin.ranges.*;
import kotlin.math.*;
import kotlin.coroutines.experimental.*;
import kotlin.coroutines.experimental.intrinsics.*;
import kotlin.coroutines.experimental.migration.*;
import kotlin.coroutines.experimental.jvm.internal.*;

import g4p_controls.*;
import java.awt.Font;
import java.awt.Color;
GButton fileButton, testButton, newButton, settingsButton, saveSettingsButton,
saveButton, mirrorButton, centerButton, leftButton, rightButton, loadButton;
GTextField name, timeStep, wheelBase, maxVel, maxAccel, maxVolts, directory;//,wheelRadius;
GLabel error;
GSlider reverse;
Field field;
Trajectory traj;
boolean blue, velocity, settingsOpen;
int w, graph;
final int X_TEXT = 130;
int angle;
double METERS_TO_INCHES;
File massExport;
double timestep, pos, vel, accel, jerk, robotWidth;

void setup(){
  size(1440, 960);
  field = new Field();
  field.setUpField();
  frameRate(120);
  w = width/2;
  angle = 0;
  graph = 0;
    
  velocity = false;
  settingsOpen = false;
  
  METERS_TO_INCHES = (1/0.3048) * 12;
  
  //misc  
  saveButton = new GButton(this, width/2-270, 440, 100, 100, "Save");
  saveButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  mirrorButton = new GButton(this, width/2-150, 440, 100, 100, "Mirror");
  mirrorButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  centerButton = new GButton(this, width/2-270, 670, 100, 100, "Center");
  centerButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  leftButton = new GButton(this, width/2-270 + 120, 670, 100, 100, "Left");
  leftButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  rightButton = new GButton(this, width/2-270, 780, 100, 100, "Right");
  rightButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  centerButton.setEnabled(false);
  centerButton.setVisible(false);
  leftButton.setEnabled(false);
  leftButton.setVisible(false);
  rightButton.setEnabled(false);
  rightButton.setVisible(false);
  
  saveButton.setEnabled(false);
  blue = false;
  
  newButton = new GButton(this, width/2-270, 80, 220, 100, "New path");
  newButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  fileButton = new GButton(this, width/2-270, 200, 220, 100, "Export");
  fileButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  loadButton = new GButton(this, width/2-270, 320, 220, 100, "Load Path");
  loadButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  testButton = new GButton(this, 300, 800, 100, 100, "TEST");
  testButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  settingsButton = new GButton(this, 130, 120, 200, 50, "Open Settings");
  settingsButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  saveSettingsButton = new GButton(this, 130, 170, 200, 50, "Save Settings");
  saveSettingsButton.setFont(new Font("Dialog", Font.PLAIN, 24));
  
  saveSettingsButton.setEnabled(false);
  saveSettingsButton.setVisible(false);
  
  //Use for debugging
  testButton.setEnabled(false);
  testButton.setVisible(false);
  
  //text
  name = new GTextField(this, X_TEXT, 80, 200, 32);
  name.setFont(new Font("Dialog", Font.PLAIN, 24));
  name.setPromptText("Profile Name");
  
  maxVel = new GTextField(this, X_TEXT, 200 + 30, 200, 32);
  maxVel.setFont(new Font("Dialog", Font.PLAIN, 24));
  maxVel.setPromptText("Max Velocity");
  
  maxAccel = new GTextField(this, X_TEXT, 240 + 30, 200, 32);
  maxAccel.setFont(new Font("Dialog", Font.PLAIN, 24));
  maxAccel.setPromptText("Max Acceleration");
  
  maxVolts = new GTextField(this, X_TEXT, 280 + 30, 200, 32);
  maxVolts.setFont(new Font("Dialog", Font.PLAIN, 24));
  maxVolts.setPromptText("Max Voltage");
  
  maxVel.setEnabled(false);
  maxVel.setVisible(false);
  maxAccel.setEnabled(false);
  maxAccel.setVisible(false);
  maxVolts.setEnabled(false);
  maxVolts.setVisible(false);
  
  JSONObject values = loadJSONObject("config.cfg");
  maxVel.setText(String.valueOf(values.getDouble("defaultMaxVelocity")));
  maxAccel.setText(String.valueOf(values.getDouble("defaultMaxAcceleration")));
  maxVolts.setText(String.valueOf(values.getDouble("defaultMaxVoltage")));  
  
  error = new GLabel(this, 75, 800, 400, 100);
  error.setFont(new Font("Dialog", Font.PLAIN, 24));
  error.setLocalColorScheme(GConstants.RED_SCHEME);
  error.resizeToFit(false, false);
  
  //sliders
  reverse = new GSlider(this, width/2-185, 580, 50, 50, 25);
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
  
  text("Field", width*0.75-25, 50);
  
  //text inputs
  textAlign(LEFT, BOTTOM);
  text("Input Variables", X_TEXT, 70);
  
  //display settings
  textAlign(CENTER, CENTER);
  text("Direction", width/2-150, 560);
  textAlign(LEFT, CENTER);
  text("Frd", width/2-230, 600);
  textAlign(LEFT, CENTER);
  text("Rev", width/2-125, 600);
  
  // Elapsed time
  textAlign(CENTER, CENTER);
  text("Total Elapsed Time", width/2-150, 660);
  DecimalFormat df = new DecimalFormat("##.###");
  text(String.valueOf(df.format(field.getElapsedTime())) + " seconds", width/2-150, 700);
  

  
  if(settingsOpen){
    textAlign(RIGHT, TOP);
    text("Max Vel", X_TEXT - 5, 234);
    text("Max Accel", X_TEXT - 5, 274);
    text("Max Volts", X_TEXT - 5, 314);
    
    textAlign(LEFT, TOP);
    text("in/s", X_TEXT + 205, 234);
    text("in/s/s", X_TEXT + 205, 274);
    text("V", X_TEXT + 205, 314);
  }
  
}
void mouseClicked(){
  int w = width/2;
  if(mouseX >= w && mouseX <= w+(Field.WIDTH*Field.SPACING) && mouseY >= 80 && mouseY <= 80+(Field.HEIGHT*Field.SPACING) 
  && !field.displayingVelocityGraph()){
    if(!field.mouseOverWaypoint()){
      if(mouseButton == LEFT){
        field.addWaypoint(mouseX, mouseY);
        field.generateProfile();
        field.enableMP();
        
        if(field.getWaypoints().size() > 1){
          saveButton.setEnabled(true);
        }
      }
      if(mouseButton == RIGHT){
        field.removeWaypoint();
        field.generateProfile();
        if(field.getWaypoints().size() <= 1){
          saveButton.setEnabled(false);
        }
      }
    }else{
      if(mouseButton == LEFT){
        field.changeWaypointAngle();
      }
    }
  }
}
void mouseDragged(){
  int w = width/2;
  if(mouseX >= w && mouseX <= w+(Field.WIDTH*Field.SPACING) && mouseY >= 80 && mouseY <= 80+(Field.HEIGHT*Field.SPACING) 
  && !field.displayingVelocityGraph()){
    if(mouseButton == LEFT && field.mouseOverWaypoint()){
      if(field.getWaypoints().size() > 1){
          saveButton.setEnabled(true);
      }
      field.moveWaypoint();
    }
  }
}
void mouseWheel(MouseEvent event){
  float e = event.getAmount();
  int da = 15;
  if(e>0){
    angle+=da;
  }
  if(e<0){
    angle-=da;
  }
}
void handleButtonEvents(GButton button, GEvent event){
  
  error.setText("");
  saveButton.setEnabled(true);
  
  if(button == fileButton){
    // TODO add waypoint copyable prompt
    if(name.getText().length() > 0 && !name.getText().equals(" ")){//there is some text
      thread("exportWaypoints");
    }
  }
  if(button == newButton){
    fileButton.setText("Export");
    fileButton.setEnabled(false);
    saveButton.setEnabled(false);
    loadButton.setEnabled(true);
    reverse.setValue(0);

    field.reset();
    name.setText("");
    name.setLocalColorScheme(GConstants.BLUE_SCHEME);
    
    maxVel.setText(String.valueOf(field.getMaxVelocity()));
    maxAccel.setText(String.valueOf(field.getMaxAcceleration()));
    maxVolts.setText(String.valueOf(field.getMaxVoltage()));
  }
  if(button == testButton){
    //TEST functions
    error.setText("TEST");
    println("TESTING");
  }
  if(button == saveButton){
     if(name.getText().length() > 0 && !name.getText().equals(" ")){//there is some text
      thread("saveFieldConfig");
    }else{
      name.setLocalColorScheme(GConstants.RED_SCHEME);
      fileButton.setEnabled(false);
      fileButton.setText("Please enter a name");
    }
  }
  if(button == mirrorButton){
    field.mirror();
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
  if(button == settingsButton){
    if(settingsOpen){
      settingsOpen = false;
      settingsButton.setText("Open Settings");
      
      saveSettingsButton.setEnabled(false);
      saveSettingsButton.setVisible(false);
      
      maxVel.setEnabled(false);
      maxVel.setVisible(false);
      maxAccel.setEnabled(false);
      maxAccel.setVisible(false);
      maxVolts.setEnabled(false);
      maxVolts.setVisible(false);
      
    }else{
      settingsOpen = true;
      settingsButton.setText("Close Settings");
      
      saveSettingsButton.setEnabled(true);
      saveSettingsButton.setVisible(true);
      
      maxVel.setEnabled(true);
      maxVel.setVisible(true);
      maxAccel.setEnabled(true);
      maxAccel.setVisible(true);
      maxVolts.setEnabled(true);
      maxVolts.setVisible(true);
    }
  }
  if(button == saveSettingsButton){
    try{
      double maxVelocity = Double.parseDouble(maxVel.getText());
      double maxAcceleration = Double.parseDouble(maxAccel.getText());
      double maxVoltage = Double.parseDouble(maxVolts.getText());
      
      if(maxVelocity < 0.0){
        maxVelocity = field.getMaxVelocity();
        maxVel.setText(String.valueOf(field.getMaxVelocity()));
      }
      if(maxAcceleration < 0.0){
        maxAcceleration = field.getMaxAcceleration();
        maxAccel.setText(String.valueOf(field.getMaxAcceleration()));
      }
      if(maxVoltage < 0.0){
        maxVoltage = field.getMaxVoltage();
        maxVolts.setText(String.valueOf(field.getMaxVoltage()));
      }
      
      field.setProfileSettings(maxVelocity, maxAcceleration, maxVoltage, field.getReverse());
      
      saveButton.setEnabled(true);
    }catch(Exception e){
      maxVel.setText(String.valueOf(field.getMaxVelocity()));
      maxAccel.setText(String.valueOf(field.getMaxAcceleration()));
      maxVolts.setText(String.valueOf(field.getMaxVoltage()));
      
      println("Only use numbers!");
      //e.printStackTrace();
    }
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
    //field.loadWaypoints(selection.getAbsolutePath());
    String[] folders = selection.getAbsolutePath().split("\\\\");
    String n = folders[folders.length-1];
    //println(n);
    name.setText(n);
    
    JSONArray values = loadJSONArray(selection.getAbsolutePath());
    
    ArrayList<float[]> waypoints = new ArrayList<float[]>();
    for(int i = 0;i<values.size() - 1;i++){
      JSONObject waypoint = values.getJSONObject(i);
      
      waypoints.add(new float[]{waypoint.getFloat("x"), waypoint.getFloat("y"), waypoint.getFloat("angle")});
      //println(waypoints.get(i)[0] + ", " + waypoints.get(i)[1]);
    }
    field = new Field(waypoints);
    field.setUpField();
    
    JSONObject waypointSettings = values.getJSONObject(values.size() - 1);
    field.setProfileSettings(
    waypointSettings.getDouble("maxVelocity"),
    waypointSettings.getDouble("maxAcceleration"),
    waypointSettings.getDouble("maxVoltage"),
    waypointSettings.getBoolean("reverse")
    );
    
    
    maxVel.setText(String.valueOf(field.getMaxVelocity()));
    maxAccel.setText(String.valueOf(field.getMaxAcceleration()));
    maxVolts.setText(String.valueOf(field.getMaxVoltage()));
    if(field.getReverse()){
      reverse.setValue(1);
    }else{
      reverse.setValue(0);
    }
    
    //String[] lines = loadStrings(selection.getAbsolutePath());
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
void setReverse(Field field, boolean reverse){
  field.setReverse(reverse);
  field.generateProfile();
}
void saveFieldConfig(){
  JSONArray json = new JSONArray();
  
  ArrayList<float[]> waypoints = field.getWaypoints();
  for(int i = 0;i<waypoints.size();i++){
    JSONObject waypoint = new JSONObject();
    waypoint.setFloat("x", waypoints.get(i)[0]);
    waypoint.setFloat("y", waypoints.get(i)[1]);
    waypoint.setFloat("angle", waypoints.get(i)[2]);
    
    json.setJSONObject(i, waypoint);
  }
  
  JSONObject waypointSettings = new JSONObject();
  waypointSettings.setBoolean("reverse", field.getReverse());
  waypointSettings.setDouble("maxVelocity", field.getMaxVelocity());
  waypointSettings.setDouble("maxAcceleration", field.getMaxAcceleration());
  waypointSettings.setDouble("maxVoltage", field.getMaxVoltage());
  json.setJSONObject(json.size(), waypointSettings);
  
  saveJSONArray(json, "field_layouts/" + name.getText());
  println("Field saved");
  error.setText("Field config saved!");
}
void exportWaypoints(){
  JSONArray json = new JSONArray();
  
  ArrayList<float[]> waypoints = field.getWaypoints();
  for(int i = 0;i<waypoints.size();i++){
    JSONObject waypoint = new JSONObject();
    waypoint.setFloat("x", waypoints.get(i)[0]);
    waypoint.setFloat("y", waypoints.get(i)[1]);
    waypoint.setFloat("angle", waypoints.get(i)[2]);
    
    json.setJSONObject(i, waypoint);
  }
  
  JSONObject waypointSettings = new JSONObject();
  waypointSettings.setBoolean("reverse", field.getReverse());
  waypointSettings.setDouble("maxVelocity", field.getMaxVelocity());
  waypointSettings.setDouble("maxAcceleration", field.getMaxAcceleration());
  waypointSettings.setDouble("maxVoltage", field.getMaxVoltage());
  json.setJSONObject(json.size(), waypointSettings);
  
  saveJSONArray(json, "waypoints/" + name.getText());
  println("export complete");
  error.setText("Export complete");
}