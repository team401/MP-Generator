/*
//import java.util.LinkedList<E>;
  //controls how far the X- and Y- axis lines are away from the window edge
  private final int xPAD = 70, yPAD = 60;
  
  //Link List to hold all different plots on one graph.
  //private LinkedList<xyNode> link;
  
  private void plot(double[][] path) {
    
    //linked list is an list of an x array and a y array
    //I think
    
    
    //int w = super.getWidth(), h = super.getHeight();

    //Color tempC = g2.getColor();

    //loop through list and plot each
    //for(int i = 0; i < link.size(); i++){
    for (int i = 0; i < path.length; i++) {
      // Draw lines.
      //double xScale = (double) (w - 2 * xPAD) / (upperXtic - lowerXtic);
      //double yScale = (double) (h - 2 * yPAD) / (upperYtic - lowerYtic);
      double xScale = 25;
      double yScale = 25;
      //for (int j = 0; j < link.get(i).y.length - 1; j++) {
      for (int j = 0; j < path.length-1; j++) {
        double x1;
        double x2;
        double x = path[i][0];
        double y = path[i][1];

        //if (path[i][0] == null) {
        //  x1 = xPAD + j * xScale;
        //  x2 = xPAD + (j + 1) * xScale;
        //} else {
          //x1 = xPAD + xScale * link.get(i).x[j] + lowerXtic * xScale;
          //x2 = xPAD + xScale * link.get(i).x[j + 1] + lowerXtic * xScale;
        //}
        
        x1 = x*xScale;
        x2 = path[i+1][0]*xScale;

        //height - yOffset - yScale*y + lowerBound*yScale
        //Ytic is the maps bounds
        //double y1 = h - yPAD - yScale * link.get(i).y[j] + lowerYtic * yScale;

        //double y2 = h - yPAD - yScale * link.get(i).y[j + 1] + lowerYtic * yScale;
        //g2.setPaint(link.get(i).lineColor);
        //g2.draw(new Line2D.Double(x1, y1, x2, y2));
        
        
        
        //test case y1 = y*scale
        //test case y2 = y[+1]*scale
        
        double y1 = y*yScale;
        
        double y2 = path[i+1][1]*yScale;
        
        line((int)x1, (int)y1, (int)x2, (int)y2);
        

        if (link.get(i).lineMarker) {
          //g2.setPaint(link.get(i).markerColor);
          //g2.fill(new Ellipse2D.Double(x1 - 2, y1 - 2, 4, 4));
          //g2.fill(new Ellipse2D.Double(x2 - 2, y2 - 2, 4, 4));
          //ellipse((float)x1 - 2, (float)y1 - 2, 4.0f, 4.0f);
          
          
          line(10, 10, 10, 10);
        }
      }
    }
  }
  */