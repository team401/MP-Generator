# MP-Generator - GUI for creating Motion Profiles

![](img/Title)

## Buttons:

* Generate Path :
	This will generate a motion profile based on the waypoints displayed on the map
	Please note that, although this generates the profiles, it doesn't export them to csv
* New Path : 
	This clears the currently generated path and resets the waypoints.
* Export : 
	This exports a left and right side .csv file, representing the generated motion profile
	These will be saved in current_directory\profilecsv\tank
	This will also clear the generated profile and reset the waypoints.
* Load Path : 
	This will load a .csv file of waypoints. One is automatically generated with each export.
	These can be found in current_directory\profilecsv\Waypoints
* Blue : 
	This will switch the field to the prospective of the blue alliance.
* Red : 
	This will switch the field to the prospective of the red alliance.
	Red is the default
* Velocity : 
	This will display a graph of the velocities that are  in the generated motion profile.
	This can only be clicked if a profile has been generated.
	Clicking this will reveal the Center, Left, and Right buttons.
* Center : 
	This displays the velocity of the center of the robot in m/s.
	The x-axis is time in seconds, the y-axis is m/s.
* Left : 
	This displays the velocity of the left side of the robot in m/s. This is to match what is exported in the .csv file.
	The x-axis is time in seconds, the y-axis is revolutions.
* Right : 
	This displays the velocity of the right side of the robot in m/s. This is to match what is exported in the .csv file.
	The x-axis is time in seconds, the y-axis is revolutions.
* Save : 
	This saves the values currently in the Settings parameters.
	Please note that simply typing in a value in the settings and NOT clicking save will NOT update those values.
	Please make sure to click save after changing any of the settings.

## Data fields :
## Input Variables : 
* Profile Name :
	This is the name that each profile will be saved under.
	Please do not use duplicate names, as these will be overwritten.
	This is a required field to generate a profile.
## Settings :
* Width : 
	This is the width between the wheels of your robot in ft.
* Radius : 
	This is the radius of the wheels on your robot's drive train in inches.
* Timestep :
	This is the time each point of the profile will take to execute in milliseconds.
* Max Vel :
	This is the maximum velocity that your robot is capable or comfortable moving at.
	Adjust this value to increase or decrease the speed of your profiles.
	Don't overestimate this value. If you do you may get profiles you cannot possibly follow,
	and run the risk of damaging your robot.
* Max Accel : 
	This is the maximum acceleration that your robot is capable or comfortable moving at.		
	Don't overestimate this value. If you do you may get profiles you cannot possibly follow,
	and run the risk of damaging your robot.
* Max Jerk : 
	This is the maximum speed at which your robot can change acceleration. 
	Don't overestimate this value. If you do you may get profiles you cannot possibly follow,
	and run the risk of damaging your robot.
## Field : 
	This is a graphical representation of the 2018 FRC field. 
	All dimensions are in feet.
	The unmarked objects are as follows :	
		Switch - This is the barbell shaped object in the middle of the field.
		Scale - This is the barbell shaped object at the far (top) end of the field. 
		
