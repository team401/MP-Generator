static class Generator{
  static FullStateDiffDriveModel driveModel = new FullStateDiffDriveModel(new Geometry(), new Dynamics());// Physics model
  static DrivetrainPathManager trajectoryGenerator = new DrivetrainPathManager(driveModel, new FeedforwardOnlyPathController(), 2.0, 0.25, Math.toRadians(5.0));
  
  public static double[][] generateTraj(ArrayList<float[]> waypointsRaw, double maxVelocity, double maxAccel, double maxVoltage){
    ArrayList<Pose2d> waypoints = new ArrayList<Pose2d>();
    
    for (float[] a : waypointsRaw){
      waypoints.add(new Pose2d(a[0], a[1], Rotation2d.fromDegrees(a[2])));
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
    
    
    TrajectoryIterator<TimedState<Pose2dWithCurvature>> iterator = new TrajectoryIterator<TimedState<Pose2dWithCurvature>>(new TimedView<Pose2dWithCurvature>(trajectory));
    ArrayList<double[]> paths = new ArrayList<double[]>();
    while(!iterator.isDone()){
      Pose2dWithCurvature state = iterator.advance(0.01).state().state();
      double[] center = new double[2];
      center[0] = state.getTranslation().x();
      center[1] = state.getTranslation().y();
      paths.add(center);
    }
    double[][] output = new double[paths.size()][2];
    for (int i = 0; i<output.length;i++){
      output[i] = paths.get(i);
    }
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