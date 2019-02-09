static class Generator{
  static FullStateDiffDriveModel driveModel = new FullStateDiffDriveModel(new Geometry(), new Dynamics());// Physics model
  static DrivetrainPathManager trajectoryGenerator = new DrivetrainPathManager(driveModel, new FeedforwardOnlyPathController(), 2.0, 0.25, Math.toRadians(5.0));
  static Pose2d negativeHalfWheelBase = Pose2d.fromTranslation(new Translation2d(0.0, -25.625/2));// change to actual wheelbase
  static Pose2d positiveHalfWheelBase = Pose2d.fromTranslation(new Translation2d(0.0, 25.625/2));// change to actual wheelbase
  public static double[][][] generateTraj(ArrayList<float[]> waypointsRaw, double maxVelocity, double maxAccel, double maxVoltage){
    ArrayList<Pose2d> waypoints = new ArrayList<Pose2d>();
    
    for (float[] a : waypointsRaw){ // Convert waypoints to inches
      waypoints.add(new Pose2d(a[0] * 12, a[1] * 12, Rotation2d.fromDegrees(a[2])));
    }
    
    //waypoints.add(new Pose2d(0.0, 0.0, Rotation2d.fromDegrees(0.0)));
    //waypoints.add(new Pose2d(1.0, 0.0, Rotation2d.fromDegrees(0.0)));
    try{
    Trajectory<TimedState<Pose2dWithCurvature>> trajectory = trajectoryGenerator.generateTrajectory(
    false,
    waypoints,
    new ArrayList<TimingConstraint<Pose2dWithCurvature>>(),
    maxVelocity,
    maxAccel,
    maxVoltage
    );
    
    double halfWheelbase = 25.625/2;
    
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
  
 private static class Geometry implements TankDrivetrainGeometryTemplate{
   public LinearDistanceMeasure getWheelRadius(){return new LinearDistanceMeasureInches(3.062954);}
   public LinearDistanceMeasure getWheelbase(){return new LinearDistanceMeasureInches(25.625);}
 }
 private static class Dynamics implements DriveDynamicsTemplate{
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
 }
 
  
}