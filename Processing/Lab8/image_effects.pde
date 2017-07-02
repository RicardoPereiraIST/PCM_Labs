PImage imagePCM;
PImage tmp;
int width;
int height;
int size;
int contrastValue = 2;
float sharpValue = 1.09;
int brightnessValue = 50;
int[] hist = new int[256];
boolean drawHist = false;
boolean saved = false;
float threshold = 127;
float maskThreshold = 1.1;

int[] originalPixels;
int[] tempPixels;

boolean firstTime = true;

float v = 1.0 / 16.0;
float[][] blurM = { {v,   2*v,  v }, 
                    {2*v, 4*v,2*v }, 
                    {v,   2*v,  v }};
                    
float v2 = 1.0 / 9.0;
float[][] blurM2 = { {v2, v2, v2 }, 
                    {v2, v2, v2 }, 
                    {v2, v2, v2 }};
                    
float v3 = 1.0 / 3.0;
float[][] blurM3 = { {v3, 0, 0 },
                    {0, v3, 0 }, 
                    {0, 0, v3}};
                    
float[][] sharpM = { { -1, -1, -1 },
                   { -1,  9, -1 },
                   { -1, -1, -1 } }; 

float[][] sharpM2 = { { 0, -1, 0 },
                   { -1,  5, -1 },
                   { 0, -1, 0 } }; 
                   
float[][] laplacianM = { { -1, -1, -1 },
                     { -1,  8, -1 },
                     { -1, -1, -1 } };
                     
float[][] laplacianM2 = { { 0, -1, 0 },
                         { -1,  4, -1 },
                         { 0, -1, 0 } }; 

float[][] sobelM =     { { -1, 0, 1 },
                         { -2,  0, 2 },
                         { -1, 0, 1 } };
                         
float[][] sobelM2 =     { { -1, -2, -1 },
                         { 0,  0, 0 },
                         { 1, 2, 1 } };
                         
float[][] embossM =     { { 2, 0, 0 },
                         { 0,  -1, 0 },
                         { 0, 0, -1 } };

void setup(){
 imagePCM = loadImage("PCMLab8.png");
 tmp = loadImage("PCMLab8.png");
 width = imagePCM.width;
 height = imagePCM.height;
 size = width*height;
 noLoop();
 surface.setSize(width, height);
 originalPixels = new int[size];
 tempPixels = new int[size];
}

void draw(){
  if(firstTime){
    firstTime = false;
    image(imagePCM, 0, 0);
    saveOriginal(tempPixels);
  }
  else{
    tmp.loadPixels();
    for (int i = 0; i < size; i++) {
      tmp.pixels[i] = tempPixels[i]; 
    }
    tmp.updatePixels();
    image(tmp, 0, 0);
  }
  
  if(!saved){
    saveOriginal(originalPixels);
    saved = true;
  }
  
  if(drawHist){
    int histMax = max(hist);

    stroke(255);
    // Draw half of the histogram (skip every second value)
    for (int i = 0; i < width; i += 2) {
      // Map i (from 0..img.width) to a location in the histogram (0..255)
      int which = int(map(i, 0, width, 0, 255));
      // Convert the histogram value to a location between 
      // the bottom and the top of the picture
      int y = int(map(hist[which], 0, histMax, height, 0));
      line(i, height, i, y);
    } 
  }
}

void keyPressed() {
 if(key=='g'){
   prepareForEffect();
   grayScale();
   saveOriginal(tempPixels);
 }
 if(key=='s'){
   prepareForEffect();
   sepia();
   saveOriginal(tempPixels);
 }
 if(key == 'c'){
   prepareForEffect();
   contrast(contrastValue);
   saveOriginal(tempPixels);
 }
 if(key == 'b'){
   prepareForEffect();
   bright(brightnessValue);
   saveOriginal(tempPixels);
 }
 if(key == 'd'){
   prepareForEffect();
   bright(-brightnessValue);
   saveOriginal(tempPixels);
 }
 if(key == 'i'){
   prepareForEffect();
   invert();
   saveOriginal(tempPixels);
 }
 if(key == 'h'){
   drawHist = !drawHist;
   if(drawHist)
     histogram();
   redraw();
 }
 if(key == 'r'){
   clearPixels(tempPixels);
   drawHist = false;
   restart();
 }
 if(key == 'z'){
   prepareForEffect();
   applyFilter(blurM, 3);
   saveOriginal(tempPixels);
 }
 if(key == 'j'){
   prepareForEffect();
   applyFilter(blurM2, 3);
   saveOriginal(tempPixels);
 }
 if(key == 'k'){
   prepareForEffect();
   applyFilter(blurM3, 3);
   saveOriginal(tempPixels);
 }
 if(key == 'x'){
   prepareForEffect();
   applyFilter(sharpM, 3);
   saveOriginal(tempPixels);
 }
 if(key == 'a'){
   prepareForEffect();
   applyFilter(sharpM2, 3);
   saveOriginal(tempPixels);
 }
 if(key == 'l'){
   prepareForEffect();
   applyFilter(laplacianM, 3);
   saveOriginal(tempPixels);
 }
 if(key == 'e'){
   prepareForEffect();
   applyFilter(laplacianM2, 3);
   saveOriginal(tempPixels);
 }
 if(key == 'q'){
   prepareForEffect();
   applyFilter(sobelM, 3);
   saveOriginal(tempPixels);
 }
 if(key == 'w'){
   prepareForEffect();
   applyFilter(sobelM2, 3);
   saveOriginal(tempPixels);
 }
 if(key == 'm'){
   prepareForEffect();
   applyFilter(embossM, 3);
   saveOriginal(tempPixels);
 }
 if(key == 't'){
   prepareForEffect();
   segmentate();
   saveOriginal(tempPixels);
 }
 if(key == 'u'){
   prepareForEffect();
   unsharpMask();
   saveOriginal(tempPixels);
 }
}

void prepareForEffect(){
  clearHistogram();
  drawHist = false;
  switchPixels(tempPixels);
}

void clearPixels(int[] tempPixels){
  for(int i = 0; i<size; i++){
    tempPixels[i] = originalPixels[i]; 
  }
}

void switchPixels(int [] tempPixels){
  loadPixels();
  for(int i = 0; i<size; i++){
    pixels[i] = tempPixels[i]; 
  }
  updatePixels();
}

void grayScale(){
  loadPixels();
  for(int i = 0; i<size; i++){
    color col = color(pixels[i]);
    float gray = red(col) * 0.3 + green(col) * 0.59 + blue(col) * 0.118;
    pixels[i] = color(gray, gray, gray);
  }
  updatePixels();
}

void sepia(){
  loadPixels();
  for(int i = 0; i<size; i++){
    color col = color(pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);

    float newR = red * 0.393 + green * 0.769 + blue * 0.189;
    float newG = red * 0.349 + green * 0.686 + blue * 0.168;
    float newB = red * 0.272 + green * 0.534 + blue * 0.131;

    pixels[i] = color(newR,newG,newB);
  }
  updatePixels();
}

void contrast(int contrastValue){
  loadPixels();
  for(int i = 0; i<size; i++){
    color col = color(pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);
    
    float newR = contrastValue * (red - 127) + 127;
    float newG = contrastValue * (green - 127) + 127;
    float newB = contrastValue * (blue - 127) + 127;
    pixels[i] = color(newR,newG,newB);
  }
  updatePixels();
}

void bright(int brightnessValue){
  loadPixels();
  for(int i = 0; i<size; i++){
    color col = color(pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);
    
    float newR = red + brightnessValue;
    float newG = green + brightnessValue;
    float newB = blue + brightnessValue;
    pixels[i] = color(newR,newG,newB);
  }
  updatePixels();
}

void invert(){
  loadPixels();
  for(int i = 0; i<size; i++){
    color col = color(pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);
    
    float newR = 255 - red;
    float newG = 255 - green;
    float newB = 255 - blue;
    pixels[i] = color(newR,newG,newB);
  }
  updatePixels();
}

void clearHistogram(){
  loadPixels();
  for(int i = 0; i<255; i++){
    hist[i] = 0;  
  }
}

void histogram(){
  clearHistogram();
  // Calculate the histogram
  loadPixels();
  for(int i = 0; i<size; i++){
    color col = color(pixels[i]);
    int bright = int(brightness(col));
    hist[bright]++; 
  }
}

void saveOriginal(int[] array){
  loadPixels();
  for(int i = 0; i<size; i++){
    array[i] =  pixels[i];
  }
}

void restart(){
  loadPixels();
  for(int i = 0; i<size; i++){
    pixels[i] =  originalPixels[i];
  }
  updatePixels();
}

void applyFilter(float[][] convul, int matrixsize){
  loadPixels();
  
  int[] pix = new int[size];
  saveOriginal(pix);
  
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++ ) {
      // Each pixel location (x,y) gets passed into a function called convolution() 
      // which returns a new color value to be displayed.
      color c = convolution(x,y,convul,matrixsize,pix);
      int loc = x + y*width;
      pixels[loc] = c;
    }
  }
  updatePixels();
}

void segmentate(){
  loadPixels();
  for(int i = 0; i<size; i++){
    if(brightness(pixels[i]) > threshold)
      pixels[i] = color(255);
    else
      pixels[i] = color(0);
  }
  updatePixels();
}

color convolution(int x, int y, float[][] matrix, int matrixsize, int[] pix) {
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  int offset = matrixsize / 2;
  // Loop through convolution matrix
  for (int i = 0; i < matrixsize; i++){
    for (int j= 0; j < matrixsize; j++){
      // What pixel are we testing
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc + width*yloc;
      // Make sure we have not walked off the edge of the pixel array
      loc = constrain(loc,0,pixels.length-1);
      // Calculate the convolution
      // We sum all the neighboring pixels multiplied by the values in the convolution matrix.
      rtotal += (red(pix[loc]) * matrix[i][j]);
      gtotal += (green(pix[loc]) * matrix[i][j]);
      btotal += (blue(pix[loc]) * matrix[i][j]);
    }
  }
  // Make sure RGB is within range
  rtotal = constrain(rtotal,0,255);
  gtotal = constrain(gtotal,0,255);
  btotal = constrain(btotal,0,255);
  // Return the resulting color
  return color(rtotal,gtotal,btotal);
}

void unsharpMask(){  
  int[] blurred = new int[size];
  int[] temp = new int[size];
  saveOriginal(blurred);
  saveOriginal(temp);
  loadPixels();

  applyFilter(blurM, 3);
  
  for(int i = 0; i<size; i++){
    blurred[i] = pixels[i];
    pixels[i] = temp[i];  
  }
  
  for(int i = 0; i<size; i++){
    if(abs(brightness(blurred[i]) - brightness(pixels[i])) > maskThreshold){
      blurred[i] = blurred[i]-pixels[i];
    }
  }
  for(int i = 0; i<size; i++){
    if(brightness(blurred[i]) != 0){
      color rcol = color(pixels[i]);
      float rred = red(rcol);
      float rgreen = green(rcol);
      float rblue = blue(rcol);
      float newR = sharpValue * (rred - 127) + 127;
      float newG = sharpValue * (rgreen - 127) + 127;
      float newB = sharpValue * (rblue - 127) + 127;
      pixels[i] = color(newR,newG,newB);
    }
  }
  updatePixels();
  
}