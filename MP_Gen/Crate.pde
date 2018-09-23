class Crate{
  private float x,y, mapX, mapY;
  private static final int WIDTH = (int)(13.0/12.0 * Field.SPACING), HEIGHT = WIDTH;
  
  Crate(float x, float y){
    //x and y are window coordinates
    this.x = x;
    this.y = y;
    mapX = toMapX(x);
    mapY = toMapY(y);
  }
  
  private void display(){
    fill(255);
    rect(x, y, WIDTH, HEIGHT);
    fill(0);
  }
  boolean mouseOverCrate(){
    return (mouseX > x && mouseX < x + WIDTH && mouseY > y && mouseY < y + HEIGHT);
  }
  String getPoint(){
    return mapX + "," + mapY;
  }
  
  DecimalFormat df = new DecimalFormat("#.##");
  float toMapX(float x){
    float value = Float.parseFloat(df.format(map(x, w, w+(Field.WIDTH*Field.SPACING), 0, Field.WIDTH)));
    return value - value % Float.parseFloat(findValue("mapIncrements"));
  }
  float toMapY(float y){
    float value = Float.parseFloat(df.format(map(y, 80, 80+(Field.HEIGHT*Field.SPACING), Field.HEIGHT, 0)));
    return value - value % Float.parseFloat(findValue("mapIncrements"));
  }
}