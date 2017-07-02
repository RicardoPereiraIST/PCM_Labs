import processing.video.*;
import java.util.*;

Movie pcmMovie1;
Movie pcmMovie2;
PImage frame1;
PImage frame2;
PImage currentFrame;
PImage afterFrame;

int width = 600;
int height = 400;
int size1;
int size2;
int currentSize = 0;
int afterSize = 0;

int mode = 0;

boolean fade = false;
boolean fadeIn = false;
boolean fadeOut = true;
int fadeValue = 255;

boolean chroma = false;

boolean dissolve = false;
int dissolveValue = 255;

boolean wipe = false;
int wipevalue = 320;

boolean random = false;
List<Integer> list;
int randomwipe = 320;

boolean wipeDouble = false;

void setup() {
  surface.setSize(width, height);
  pcmMovie1 = new Movie(this, "PCMLab11-1.mov");
  pcmMovie2 = new Movie(this, "PCMLab11-2.mov");
  frame1 = createImage(pcmMovie1.width, pcmMovie1.height, RGB);
  frame2 = createImage(pcmMovie2.width, pcmMovie2.height, RGB);
  currentFrame = createImage(width, height, RGB);
  size1 = pcmMovie1.width * pcmMovie1.height;
  size2 = pcmMovie2.width * pcmMovie2.height;
  currentSize = size1;
  afterSize = size2;
  pcmMovie1.loop();
  pcmMovie2.loop();
}

void draw() {
  frame1 = pcmMovie1.get();
  frame2 = pcmMovie2.get();
  size1 = pcmMovie1.width * pcmMovie1.height;
  size2 = pcmMovie2.width * pcmMovie2.height;
  
  if(mode == 0){
    currentFrame = frame1;
    currentSize = size1;
    afterFrame = frame2;
    afterSize = size2;
  }
  else if(mode == 1){
    currentFrame = frame2;
    currentSize = size2;
    afterFrame = frame1;
    afterSize = size1;
  }
  
  if(wipe){
    image(afterFrame, 0, 0, width, height);
    if (wipevalue <= currentSize){
      wipe(wipevalue);
      if (mode == 0){
         wipevalue += 640;
      }else{
         wipevalue += 1920;
      }
    }
    if (wipevalue > currentSize){
      wipe = false;
      mode = (mode+1)%2;
      if (mode == 0){
         wipevalue = 320;
      }else{
         wipevalue = 960;
      }
    }
  }
  
  if(wipeDouble){
    image(afterFrame, 0, 0, width, height);
    if (wipevalue <= currentSize){
      wipeDouble(wipevalue);
      if (mode == 0){
         wipevalue += 640;
      }else{
         wipevalue += 1920;
      }
    }
    if (wipevalue > currentSize){
      wipeDouble = false;
      mode = (mode+1)%2;
      if (mode == 0){
         wipevalue = 320;
      }else{
         wipevalue = 960;
      }
    }
  }
  
  if(fade){
    background(0);
    if(fadeOut){
      if(fadeValue > 4){
        fadeValue-=4;
      }
      else{
        fadeIn = true;
        fadeOut = false;
        mode = (mode+1)%2;
      }
    }
    else if(fadeIn){
      if(fadeValue < 255){
        fadeValue+=4;
      }
      else{
        fade = false;
        fadeOut = true;
        fadeIn = false;
      }
    }
    fade(fadeValue);
  }
  
  if(chroma){
    image(afterFrame, 0, 0, width, height);
    chroma();
  }
  
  if(dissolve){
    image(afterFrame, 0, 0, width, height);
    dissolve();
    if(dissolveValue > 1){
      dissolveValue-=4;
    }
    if(dissolveValue < 1){
      dissolve = false;
      dissolveValue = 255;
      mode = (mode+1)%2;
    }
  }
  
  if(random){
    image(afterFrame, 0, 0, width, height);
    
    if (randomwipe <= currentSize){
      wipeRandom(list, randomwipe);
      if (mode == 0){
         randomwipe += 1200;
      }else{
         randomwipe += 8000;
      }
    }

    if (randomwipe > currentSize){
      random = false;
      mode = (mode+1)%2;
      wipevalue = 300;
    }
  }
  
  image(currentFrame, 0, 0, width, height);
}

void keyPressed(){
  if(key == '1'){
    mode = 0;
  }
  if(key == '2'){
    mode = 1;
  }
  
  if(key == 'w'){
    wipe = true;
  }
  
  if(key == 'q'){
    wipeDouble = true;
  }
  
  if(key == 'f'){
    fade = true;
  }
  
  if(key == 'c'){
    if (chroma == false){
      chroma = true;
    }else{
      chroma = false;
      image(currentFrame, 0, 0, width, height);
    }
  }
  
  if(key == 'd'){
    dissolve = true;
    dissolveValue = 255;
  }
  
  if(key == 'r'){
    list = new ArrayList<Integer>();
  
    // Initialize array 
    for (int i = 0; i < currentSize; i++){
      list.add(i);
    }
    Collections.shuffle(list);
    random = true;
  }
}

void movieEvent(Movie m) {
  m.read();
}

void fade(int fadeValue){
  currentFrame.loadPixels();
  for(int i = 0; i < currentSize; i++){
    color col = color(currentFrame.pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);
    currentFrame.pixels[i] = color(red, green, blue, fadeValue);
  }
  currentFrame.updatePixels();
}

void wipe(int wipevalue){
  currentFrame.loadPixels();
  for(int i = 0; i < wipevalue; i++){
    color col = color(currentFrame.pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);
    currentFrame.pixels[i] = color(red, green, blue, 1);
  }
  currentFrame.updatePixels();
}

void wipeRandom(List<Integer> randomPixels, int threshold){
  currentFrame.loadPixels();

  for (int i = 0; i < threshold; i++){
    color col = color(currentFrame.pixels[randomPixels.get(i)]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);
    currentFrame.pixels[randomPixels.get(i)] = color(red, green, blue, 1);
  }
  currentFrame.updatePixels();
}

void wipeDouble(int wipevalue){
  currentFrame.loadPixels();
  for(int i = 0; i < wipevalue; i++){
    color col = color(currentFrame.pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);
    currentFrame.pixels[i] = color(red, green, blue, 1);
  }
  
  for(int i = currentSize-1; i > currentSize - wipevalue; i--){
    color col = color(currentFrame.pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);
    currentFrame.pixels[i] = color(red, green, blue, 1);
  }
  currentFrame.updatePixels();
}

void chroma(){
  currentFrame.loadPixels();
  for(int i = 0; i < currentSize; i++){
    float alpha = 255;
    color col = color(currentFrame.pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);

    if(green == 255 && blue < 200 && red < 200){
        alpha = 1;
     } 
     currentFrame.pixels[i] = color(red,green, blue, alpha);
  }
  currentFrame.updatePixels();
}

void dissolve(){
  currentFrame.loadPixels();
  for(int i = 0; i < currentSize; i++){
    color col = color(currentFrame.pixels[i]);
    float red = red(col);
    float green = green(col);
    float blue = blue(col);
    currentFrame.pixels[i] = color(red, green, blue, dissolveValue);
  }
  currentFrame.updatePixels(); 
}