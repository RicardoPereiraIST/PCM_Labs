import processing.video.*;

Movie pcmMovie;
PImage frame;
PImage prevFrame;
PImage auxFrame;
int width = 320;
int height = 240;
int size;

int contrastValue = 2;
int brightnessValue = 50;
int convolutionValue = 1;
float sharpValue = 1.09;
float threshold = 127;
float maskThreshold = 1.1;

int fadeValue = 255;

boolean grayscale = false;
boolean sepia = false;
boolean contrast = false;
boolean bright = false;
boolean invert = false;
boolean segmentate = false;

//LOW PASS
boolean blur1 = false;
boolean blur2 = false;
boolean blur3 = false;

//HIGH PASS
boolean sharp1 = false;
boolean sharp2 = false;

//EDGE DETECTION
boolean laplacian1 = false;
boolean laplacian2 = false;


boolean sobel1 = false;
boolean sobel2 = false;
boolean emboss = false;
boolean unsharp = false;

boolean imageDiff = false;

boolean mirrorH = false;
boolean mirrorV = false;

boolean fadeBool = false;

float transitionPercent = 0;
float transitionIncrement = 0.009;
int transitionIn = 0;

float v = 1.0 / 16.0;
float[][] blurM = { {v, 2*v, v }, 
  {2*v, 4*v, 2*v }, 
  {v, 2*v, v }};

float v2 = 1.0 / 9.0;
float[][] blurM2 = { {v2, v2, v2 }, 
  {v2, v2, v2 }, 
  {v2, v2, v2 }};

float v3 = 1.0 / 3.0;
float[][] blurM3 = { {v3, 0, 0 }, 
  {0, v3, 0 }, 
  {0, 0, v3}};

float[][] sharpM = { { -1, -1, -1 }, 
  { -1, 9, -1 }, 
  { -1, -1, -1 } }; 

float[][] sharpM2 = { { 0, -1, 0 }, 
  { -1, 5, -1 }, 
  { 0, -1, 0 } }; 

float[][] laplacianM = { { -1, -1, -1 }, 
  { -1, 8, -1 }, 
  { -1, -1, -1 } };

float[][] laplacianM2 = { { 0, -1, 0 }, 
  { -1, 4, -1 }, 
  { 0, -1, 0 } }; 

float[][] sobelM =     { { -1, 0, 1 }, 
  { -2, 0, 2 }, 
  { -1, 0, 1 } };

float[][] sobelM2 =     { { -1, -2, -1 }, 
  { 0, 0, 0 }, 
  { 1, 2, 1 } };

float[][] embossM =     { { 2, 0, 0 }, 
  { 0, -1, 0 }, 
  { 0, 0, -1 } };

void setup() {
  surface.setSize(width, height);
  pcmMovie = new Movie(this, "PCMLab9.mov");
  frame = createImage(pcmMovie.width, pcmMovie.height, RGB);
  prevFrame = createImage(pcmMovie.width, pcmMovie.height, RGB);
  auxFrame = createImage(width, height, RGB);
  size = width * height;
  pcmMovie.loop();
}

void draw() {
  frame = pcmMovie.get();

  if (grayscale)
    grayScale();

  if (sepia)
    sepia();

  if (contrast)
    contrast(contrastValue);

  if (bright)
    bright(brightnessValue);

  if (invert)
    invert();
    
  if (segmentate)
    segmentate();

  if (blur1)
    applyFilter(blurM, 3);

  if (blur2)
    applyFilter(blurM2, 3);

  if (blur3)
    applyFilter(blurM3, 3);

  if (sharp1)
    applyFilter(sharpM, 3);

  if (sharp2)
    applyFilter(sharpM2, 3);

  if (laplacian1)
    applyFilter(laplacianM, 3);

  if (laplacian2)
    applyFilter(laplacianM2, 3);

  if (sobel1)
    applyFilter(sobelM, 3);

  if (sobel2)
    applyFilter(sobelM2, 3);

  if (emboss)
    applyFilter(embossM, 3);
    
  if (unsharp)
    unsharpMask();

  if (imageDiff)
    imageDiff();
    
  if (mirrorH)
    mirror(0);
    
  if(mirrorV)
    mirror(1);
    
  if(fadeBool){
    background(0);
    
    if (fadeValue != 1)
      fadeValue--;
     
    fade(fadeValue);
  }else if (fadeBool == false){
    background(0);
    
    if (fadeValue != 255){
      fadeValue++;
      fade(fadeValue);
    }

  }
   
  if(transitionIn == -1)
    transition(1,-1);
  else if(transitionIn == 1)
    transition(1,1);
  else if(transitionIn == -2)
    transition(2,-1);
  else if(transitionIn == 2)
    transition(2,1);
  else if(transitionIn == -3)
    transition(3,-1);
  else if(transitionIn == 3)
    transition(3,1);
  else if(transitionIn == -4)
    transition(4,-1);
  else if(transitionIn == 4)
    transition(4,1);
    
  prevFrame = frame;

  if(imageDiff)
    image(auxFrame, 0, 0);
  else
    image(frame,0,0);
    
    
}

void movieEvent(Movie m) { 
  m.read();
}

void keyPressed() {

  if (key=='g') {
    grayscale = !grayscale;
  }

  if (key == 's') {
    sepia = !sepia;
  }

  if (key == 'c') {
    contrast = !contrast;
  }

  if (key == 'b') {
    bright = !bright;
  }

  if (key == 'i') {
    invert = !invert;
  }
  
  if(key == 't'){
   segmentate = !segmentate;
 }

  if (key == 'z') {
    blur1 = !blur1;
  }

  if (key == 'j') {
    blur2 = !blur2;
  }

  if (key == 'k') {
    blur3 = !blur3;
  }

  if (key == 'x') {
    sharp1 = !sharp1;
  }

  if (key == 'a') {
    sharp2 = !sharp2;
  }

  if (key == 'l') {
    laplacian1 = !laplacian1;
  }

  if (key == 'e') {
    laplacian2 = !laplacian2;
  }

  if (key == 'q') {
    sobel1 = !sobel1;
  }

  if (key == 'w') {
    sobel2 = !sobel2;
  }

  if (key == 'm') {
    emboss = !emboss;
  }
  
  if(key == 'u'){
    unsharp = !unsharp;  
  }

  if (key == '1') {
    imageDiff = !imageDiff;
  }
  
  if(key == 'r'){
    mirrorH = !mirrorH;  
  }
  
  if(key == 'y'){
    mirrorV = !mirrorV;  
  }
  
  if(keyCode == 112){
    if(transitionIn == 1)
      transitionIn = -1;
    else
      transitionIn = 1;
  }
  
  if(keyCode == 113){
    if(transitionIn == 2)
      transitionIn = -2;
    else
      transitionIn = 2;
  }
  
  if(keyCode == 114){
    if(transitionIn == 3)
      transitionIn = -3;
    else
      transitionIn = 3;
  }
  
  if(keyCode == 115){
    if(transitionIn == 4)
      transitionIn = -4;
    else
      transitionIn = 4;
  }
  
  if(key == '2'){
    contrastValue--;  
  }
  
  if(key == '3'){
    contrastValue++;  
  }
  
  if(key == '5'){
    brightnessValue--;  
  }
  
  if(key == '6'){
    brightnessValue++;  
  }
  
  if(key == '8'){
    convolutionValue--;  
  }
  
   if(key == '9'){
    convolutionValue++;  
  }
  
  if(keyCode == DOWN){
    sharpValue -= 0.1;  
  }
  
  if(keyCode == UP){
    sharpValue += 0.1;  
  } 
  
  if(key == 'f'){
    fadeBool = !fadeBool;
  }
}

void saveOriginal(int[] array) {
  frame.loadPixels();
  for (int i = 0; i<size; i++) {
    array[i] =  frame.pixels[i];
  }
}

void switchOriginal(int[] from, PImage to){
  to.loadPixels();
  for(int i = 0; i < size; i++){
    to.pixels[i] = from[i];  
  }
  to.updatePixels();
}

void fade(int fadeValue){
  frame.loadPixels();
  for (int i = 0; i<size; i++) {
    color col = color(frame.pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);
    
    frame.pixels[i] = color(red, green, blue, fadeValue);
  }
  frame.updatePixels();
}

void grayScale() {
  frame.loadPixels();
  for (int i = 0; i<size; i++) {
    color col = color(frame.pixels[i]);
    float gray = red(col) * 0.3 + green(col) * 0.59 + blue(col) * 0.118;
    frame.pixels[i] = color(gray, gray, gray);
  }
  frame.updatePixels();
}

void sepia() {
  frame.loadPixels();
  for (int i = 0; i<size; i++) {
    color col = color(frame.pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);

    float newR = red * 0.393 + green * 0.769 + blue * 0.189;
    float newG = red * 0.349 + green * 0.686 + blue * 0.168;
    float newB = red * 0.272 + green * 0.534 + blue * 0.131;

    frame.pixels[i] = color(newR, newG, newB);
  }
  frame.updatePixels();
}

void contrast(int contrastValue) {
  frame.loadPixels();
  for (int i = 0; i<size; i++) {
    color col = color(frame.pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);

    float newR = contrastValue * (red - 127) + 127;
    float newG = contrastValue * (green - 127) + 127;
    float newB = contrastValue * (blue - 127) + 127;
    frame.pixels[i] = color(newR, newG, newB);
  }
  frame.updatePixels();
}

void bright(int brightnessValue) {
  frame.loadPixels();
  for (int i = 0; i<size; i++) {
    color col = color(frame.pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);

    float newR = red + brightnessValue;
    float newG = green + brightnessValue;
    float newB = blue + brightnessValue;
    frame.pixels[i] = color(newR, newG, newB);
  }
  frame.updatePixels();
}

void invert() {
  frame.loadPixels();
  for (int i = 0; i<size; i++) {
    color col = color(frame.pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);

    float newR = 255 - red;
    float newG = 255 - green;
    float newB = 255 - blue;
    frame.pixels[i] = color(newR, newG, newB);
  }
  frame.updatePixels();
}

void segmentate(){
  frame.loadPixels();
  for(int i = 0; i<size; i++){
    if(brightness(frame.pixels[i]) > threshold)
      frame.pixels[i] = color(255);
    else
      frame.pixels[i] = color(0);
  }
  frame.updatePixels();
}

void applyFilter(float[][] convul, int matrixsize) {
  frame.loadPixels();

  int[] pix = new int[size];
  saveOriginal(pix);

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++ ) {
      // Each pixel location (x,y) gets passed into a function called convolution() 
      // which returns a new color value to be displayed.
      color c = convolution(x, y, convul, matrixsize, pix) * convolutionValue;
      int loc = x + y*width;
      frame.pixels[loc] = c;
    }
  }
  frame.updatePixels();
}

color convolution(int x, int y, float[][] matrix, int matrixsize, int[] pix) {
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  int offset = matrixsize / 2;
  // Loop through convolution matrix
  for (int i = 0; i < matrixsize; i++) {
    for (int j= 0; j < matrixsize; j++) {
      // What pixel are we testing
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc + width*yloc;
      // Make sure we have not walked off the edge of the pixel array
      loc = constrain(loc, 0, frame.pixels.length-1);
      // Calculate the convolution
      // We sum all the neighboring pixels multiplied by the values in the convolution matrix.
      rtotal += (red(pix[loc]) * matrix[i][j]);
      gtotal += (green(pix[loc]) * matrix[i][j]);
      btotal += (blue(pix[loc]) * matrix[i][j]);
    }
  }
  // Make sure RGB is within range
  rtotal = constrain(rtotal, 0, 255);
  gtotal = constrain(gtotal, 0, 255);
  btotal = constrain(btotal, 0, 255);
  // Return the resulting color
  return color(rtotal, gtotal, btotal);
}

void unsharpMask(){  
  int[] blurred = new int[size];
  int[] temp = new int[size];
  saveOriginal(blurred);
  saveOriginal(temp);

  applyFilter(blurM, 3);
  
  for(int i = 0; i<size; i++){
    blurred[i] = frame.pixels[i];
    frame.pixels[i] = temp[i];  
  }
  
  for(int i = 0; i<size; i++){
    if(abs(brightness(blurred[i]) - brightness(frame.pixels[i])) > maskThreshold){
      blurred[i] = blurred[i]-frame.pixels[i];
    }
  }
  for(int i = 0; i<size; i++){
    if(brightness(blurred[i]) != 0){
      color rcol = color(frame.pixels[i]);
      float rred = red(rcol);
      float rgreen = green(rcol);
      float rblue = blue(rcol);
      float newR = sharpValue * (rred - 127) + 127;
      float newG = sharpValue * (rgreen - 127) + 127;
      float newB = sharpValue * (rblue - 127) + 127;
      frame.pixels[i] = color(newR,newG,newB);
    }
  }
  frame.updatePixels();
  
}

void imageDiff() {
  int[] pix = new int[size];
  saveOriginal(pix);
  
  for(int i = 0; i < size; i++){
    color frameColor = frame.pixels[i];
    color prevFrameColor = prevFrame.pixels[i];
    
    float newR = abs(red(frameColor)-red(prevFrameColor));
    float newG = abs(green(frameColor)-green(prevFrameColor));
    float newB = abs(blue(frameColor)-blue(prevFrameColor));
    
    pix[i] = color(newR,newG,newB);
  }
  
  switchOriginal(pix, auxFrame);
}

void mirror(int mode) {
  frame.loadPixels();
  for(int i = 0; i < width; i++){
    for(int j = 0; j < height; j++){
      int loc = i + j*width;
      int lastLoc = 0;
      if(mode == 0)
        lastLoc = width-1-i + j*width;
      else if(mode == 1)
        lastLoc = i + (height-1-j)*width;
        
      frame.pixels[lastLoc] = frame.pixels[loc]; 
    }
  }
  frame.updatePixels();
}

void transition(int mode,int sign){
  frame.loadPixels();
  
  float xPercent=0, yPercent=0;
  
  if(mode==1 || mode == 3){
    xPercent = 1;
    yPercent = transitionPercent;
  }
  else if(mode==2 || mode ==4){
    xPercent = transitionPercent;
    yPercent = 1;
  }

  for(int i = 0; i < width * xPercent; i++){
    for(int j = 0; j < height * yPercent; j++){
      int loc = i + j*width;
      frame.pixels[loc] = color(0,0,0);
      
      if(mode==3){
        int lastLoc = i + (height-1-j)*width;
        frame.pixels[lastLoc] = color(0,0,0);
      }
      if(mode==4){
        int lastLoc = width-1-i + j*width;
        frame.pixels[lastLoc] = color(0,0,0);
      }
    }
  }
  
  transitionPercent+=transitionIncrement*sign;
  if(transitionPercent > 1)
    transitionPercent = 1;
  if(transitionPercent < 0)
    transitionPercent = 0;
    
}