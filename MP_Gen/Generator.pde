class Generator{
  //FullStateDiffDriveModel driveModel = new FullStateDiffDriveModel(new Geometry(), new Dynamics());// Physics model
  //DrivetrainPathManager trajectoryGenerator = new DrivetrainPathManager(driveModel, new FeedforwardOnlyPathController(), 2.0, 0.25, Math.toRadians(5.0));
  //Pose2d negativeHalfWheelBase = Pose2d.fromTranslation(new Translation2d(0.0, -25.625/2));// change to actual wheelbase
  //Pose2d positiveHalfWheelBase = Pose2d.fromTranslation(new Translation2d(0.0, 25.625/2));// change to actual wheelbase
  
  Geometry geometryModel;
  Dynamics dynamicsModel;
  FullStateDiffDriveModel driveModel;
  DrivetrainPathManager trajectoryGenerator;
  Pose2d negativeHalfWheelBase;
  Pose2d positiveHalfWheelBase;
  
  Generator(){
    println("Generator is made!");
    geometryModel = new Geometry();
    dynamicsModel = new Dynamics();
    driveModel = new FullStateDiffDriveModel(geometryModel, dynamicsModel);// Physics model
    trajectoryGenerator = new DrivetrainPathManager(driveModel, new FeedforwardOnlyPathController(), 2.0, 0.25, Math.toRadians(5.0));
    negativeHalfWheelBase = Pose2d.fromTranslation(new Translation2d(0.0, -25.625/2));// change to actual wheelbase
    positiveHalfWheelBase = Pose2d.fromTranslation(new Translation2d(0.0, 25.625/2));// change to actual wheelbase
  }
  
  double[][][] generateTraj(ArrayList<float[]> waypointsRaw, double maxVelocity, double maxAccel, double maxVoltage, boolean reverse){
    ArrayList<Pose2d> waypoints = new ArrayList<Pose2d>();
    
    for (float[] a : waypointsRaw){ // Convert waypoints to inches
      waypoints.add(new Pose2d(a[0] * 12.0, a[1] * 12.0, Rotation2d.fromDegrees(a[2])));
    }
    
    try{
    Trajectory<TimedState<Pose2dWithCurvature>> trajectory = trajectoryGenerator.generateTrajectory(
    reverse,
    waypoints,
    new ArrayList<TimingConstraint<Pose2dWithCurvature>>(),
    maxVelocity,
    maxAccel,
    maxVoltage
    );
    
    double halfWheelbase = geometryModel.getWheelBaseValue()/2;
    
    TrajectoryIterator<TimedState<Pose2dWithCurvature>> iterator = new TrajectoryIterator<TimedState<Pose2dWithCurvature>>(new TimedView<Pose2dWithCurvature>(trajectory));
    ArrayList<double[]> centerPath = new ArrayList<double[]>();
    ArrayList<double[]> leftPath = new ArrayList<double[]>();
    ArrayList<double[]> rightPath = new ArrayList<double[]>();
    while(!iterator.isDone()){
      Pose2dWithCurvature state = iterator.advance(0.01).state().state();
      double[] center = new double[2];
      double[] left = new double[2];
      double[] right = new double[2];
      center[0] = state.getTranslation().x();
      center[1] = state.getTranslation().y();
      double angle = state.getRotation().getRadians() + PI/2;
      left[0] = center[0] - halfWheelbase * Math.cos(angle);
      left[1] = center[1] - halfWheelbase * Math.sin(angle);
      right[0] = center[0] + halfWheelbase * Math.cos(angle);
      right[1] = center[1] + halfWheelbase * Math.sin(angle);
      
      center[0] = center[0] / 12;
      center[1] = center[1] / 12;
      left[0] = left[0] / 12;
      left[1] = left[1] / 12;
      right[0] = right[0] / 12;
      right[1] = right[1] / 12;
      
      centerPath.add(center);
      leftPath.add(left);
      rightPath.add(right);
    }
    double[][] outputCenter = new double[centerPath.size()][2];
    double[][] outputLeft = new double[leftPath.size()][2];
    double[][] outputRight = new double[rightPath.size()][2];
    for (int i = 0; i<outputCenter.length;i++){
      outputCenter[i] = centerPath.get(i);
    }
    for (int i = 0; i<outputLeft.length;i++){
      outputLeft[i] = leftPath.get(i);
    }
    for (int i = 0; i<outputRight.length;i++){
      outputRight[i] = rightPath.get(i);
    }
    double[][][] output = new double[3][outputCenter.length][2];
    output[0] = outputCenter;
    output[1] = outputLeft;
    output[2] = outputRight;
    return output;
    }catch (Exception e){
      e.printStackTrace();
    }
    return null;
  }
  
 private class Geometry implements TankDrivetrainGeometryTemplate{
   private double wheelRadius;
   private double wheelBase;
   
   Geometry(){
     JSONObject settings = loadJSONObject("config.cfg");
     wheelRadius = settings.getDouble("wheelRadius");
     wheelBase = settings.getDouble("wheelBase");
     println(wheelBase);
   }
   public double getWheelRadiusValue(){return wheelRadius;}
   public double getWheelBaseValue(){return wheelBase;}
   public LinearDistanceMeasure getWheelRadius(){return new LinearDistanceMeasureInches(wheelRadius);}
   public LinearDistanceMeasure getWheelbase(){return new LinearDistanceMeasureInches(wheelBase);}
   
   /*
   public LinearDistanceMeasure getWheelRadius(){return new LinearDistanceMeasureInches(3.062954);}
   public LinearDistanceMeasure getWheelbase(){return new LinearDistanceMeasureInches(25.625);}
   */
 }
 private class Dynamics implements DriveDynamicsTemplate{
   private double leftKs;
   private double leftKv;
   private double leftKa;
   private double rightKs;
   private double rightKv;
   private double rightKa;
   private double inertialMass;
   private double momentOfInertia;
   private double angularDrag;
   private double trackScrubFactor;
   
   Dynamics(){
     JSONObject settings = loadJSONObject("config.cfg");
     leftKs = settings.getDouble("leftKs");
     leftKv = settings.getDouble("leftKv");
     leftKa = settings.getDouble("leftKa");
     rightKs = settings.getDouble("rightKs");
     rightKv = settings.getDouble("rightKv");
     rightKa = settings.getDouble("rightKa");
     inertialMass = settings.getDouble("inertialMass");
     momentOfInertia = settings.getDouble("momentOfInertia");
     angularDrag = settings.getDouble("angularDrag");
     trackScrubFactor = settings.getDouble("trackScrubFactor");
   }
   
   public double getLeftKs(){return leftKs;}
   public double getLeftKv(){return leftKv;}
   public double getLeftKa(){return leftKa;}
   public double getRightKs(){return rightKs;}
   public double getRightKv(){return rightKv;}
   public double getRightKa(){return rightKa;}
   public double getInertialMass(){return inertialMass;}
   public double getMomentOfInertia(){return momentOfInertia;}
   public double getAngularDrag(){return angularDrag;}
   public double getTrackScrubFactor(){return trackScrubFactor;}
   /*
   public double getLeftKs(){return 0.5;}
   public double getLeftKv(){return 0.165;}
   public double getLeftKa(){return 0.0173;}
   public double getRightKs(){return 0.35;}
   public double getRightKv(){return 0.175;}
   public double getRightKa(){return 0.0237;}
   public double getInertialMass(){return 24.948;}
   public double getMomentOfInertia(){return 2.0;}
   public double getAngularDrag(){return 1.0;}
   public double getTrackScrubFactor(){return 1.1288;}
   */
 }
 
  
}