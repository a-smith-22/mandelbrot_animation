final int max_iterations = 10000; //limit for computing set

int hue; //hue of a single pixel, set as the color

void setup() {
  println("Initializing...");
  size(867,800); //(867,800)
  
  colorMode(HSB, 360, 100, 100) ;//hue, saturation, birghtness used for coloring mandelbrot
  
  background(224,69,36); //navy blue
  println("Computing...");
}

//Variables for generating Mandelbrot set (static)

PVector c = new PVector(0,0); //initial c value

int num; //number of iterations for c to diverge (div)
float div = 1000; //distance squared from (0,0) for c to 'diverge'
float con = .00001; //distance squared from (0,0) for c to 'converge'

float x,y; //convert pixel to coordinates around mandelbrot set range from x (re) -2 to 0.75, y (im) -1.5 to 1.5

//------------------------------------------------

//Variables for zooming into a point in the set

final PVector x_lim = new PVector(-2.5, 0.75);
final PVector y_lim = new PVector(-1.5, 1.5); //initial bounds of the graph
PVector x_bounds = x_lim.copy();
PVector y_bounds = y_lim.copy(); //changing bounds of the graph, used for zooming

float zoom = 0; //constant for zooming graph -- 0 is no zoom, 1 is full zoom
final int num_zooms = 190; //max number of frames to save

final PVector c_zoom = new PVector(-0.60894,-0.6094); //point to zoom into

String file_name; //name of file to save each frame to 

float tk = 0; //zoom constant parameter for time
final float tk_step = 0.1; //parameter to step each zoom (smaller=more gradually zoom)

int frame_num = 0; //frame count

void draw() {
  zoom = 1-pow(2,-1*tk); //each zoom covers half distance of last to gradually approach 1 (0, 0.5, 0.75, ... 1)
  
  PVector [] new_bounds = zoom_fcn(x_lim, y_lim, c_zoom, zoom); //find new bounds for window
  x_bounds.set(new_bounds[0].x,new_bounds[0].y);
  y_bounds.set(new_bounds[1].x,new_bounds[1].y); //set new x and y bounds
  
  for( int i=0; i<=width; i++){ //loop over x values
    for( int j=0; j<=height; j++){ //loop over y values
      
      x = map(i,0,width,x_bounds.x,x_bounds.y); //map i from 0->width to -2->0.75; 
      y = map(j,0,height,y_bounds.y,y_bounds.x); //map j from 0->height to 1.5->-1.5;
      
      c.set(x,y); //update complex number
      num = mandelbrot(c); //find number of iterations to go past threshold (num [0,max_iter]
      
      int div_hue = int(map(num, 0, 100, 0, 100)); //hue of diverging points
      if (num == -1) { 
        hue = color(0,0,0); 
      } 
      else if (num == max_iterations) {
        hue = color(0,0,0); //handles case where inside has color, fix bug???
      }
      else {  
        hue = color(53, div_hue, div_hue); //yellow color scale
      } //black if converge, color if not
     
      set(i,j,hue); //set pixel color
   
    }
  }
    
  tk += tk_step; 
  file_name = "frame"+frame_num+".png"; 
  frame_num+=1;
  println("Frame "+frame_num+" of "+round(num_zooms)+", "+100*frame_num/num_zooms+"% complete.");
  saveFrame(file_name); //saves frame of animation before processing next zoom
  
  //debug(); //debugging code, comment off if not needed
  
  if(tk>=num_zooms*tk_step) {
    println("All frames processed.");
    exit(); //quit processing after finishing
  } //if num_zooms is reached, quit
  
}

//------------------------------------------------

float div_sq = div*div; //divergence bound squared
float con_sq = con*con; //convergence bound, squared

int mandelbrot(PVector c){
  /*
  Takes a value c and performs f(z) = z^2 + c.
  Finds number of iterations for c to be 'div' away from 0 (diverge)
  Input: initial value z; Output: number of iterations
  
  (a+bi)^2 = a^2 + 2abi - b^2 = (a^2-b^2)+(2ab)i = (a+b)(a-b) + (2ab)i = z^2
  */
    
  //float zd_sq; //distance of current complex number from origin
  
  PVector z = c.copy();
  float zd;
  
  for(int i=0; i<max_iterations; i++) {
    
    //zd_sq = z.x*z.x + z.y*z.y; //find distance from origin of complex number
    
    zd = dist(0,0,z.x,z.y); //distance from 0, magnitude of z
    
    //if(zd_sq < con_sq) {
    if(zd < con) {
      return -1; //exit function
    } //converges, return 0 (read as black)
        
    //else if( zd_sq >= div_sq) { // diverges
    if(zd > div) {
      return i; //exit function
    }
    
    //else if(zd_sq < div_sq) { //if still converging, do another iteration
    if( zd < div ) {
      //z.set( (z.x+z.y)*(z.x-z.y) + c.x, 2*z.x*z.y + c.y); //new z value = z^2 + c
      z.set( z.x*z.x - z.y*z.y  , 2*z.x*z.y );
      z.add(c);
      zd = dist(0,0,z.x,z.y); //distance from 0, magnitude of z
    }
       
  }

  return max_iterations; //if max iterations is reached
}

//------------------------------------------------

PVector [] zoom_fcn(PVector x, PVector y, PVector c, float zoom){
  /*
  Input: (1,2) x and y bounds, (3) point c and (4) zoom constant/percent zoom.
  (1,2) Bounds in x and y directions as vectors, given as (low lim, upper lim)
  (3) Point to zoom into, written as vector (x,y)
  (4) Zoom = 0 is no zoom, zoom = 1 is at point (100% zoom)
  
  Output: (1,2) new x and y bounds as array. bounds[0] = x bounds, bounds[1] = y bounds
  */
  
  PVector xn = x.copy();
  PVector yn = y.copy(); //copy limit vectors

  PVector [] bounds = new PVector[2]; //x and y bounds as vectors 

  xn.set( zoom*(c.x-x.x)+x.x, zoom*(c.x-x.y)+x.y);
  yn.set( zoom*(c.y-y.x)+y.x, zoom*(c.y-y.y)+y.y);
  
  bounds[0] = xn;
  bounds[1] = yn; //set values of array to new limit vectors
  
  return bounds;
}


//------------------------------------------------

void debug(){
  int xm = int(mouseX);
  int ym = int(mouseY);
  float xman = map(xm,0,width,-2.5,0.75);
  float yman = map(ym,0,height,1.5,-1.5);
  color color_m = get(xm,ym); //color of pixel at cursor
  print("Point ("+xman+", "+yman+")");
  print("...Color H:"+hue(color_m)+", S:"+saturation(color_m)+", B"+brightness(color_m)); //print hue of pixel at cursor
  PVector mouse_pos = new PVector(xman,yman);
  print("...Num: "+mandelbrot(mouse_pos));
  int dhue = int(map(mandelbrot(mouse_pos), 0, 50, 0, 360));
  print("...Div Hue:"+dhue%360);
  println("");
}
