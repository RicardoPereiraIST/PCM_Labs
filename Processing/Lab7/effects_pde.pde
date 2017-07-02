import ddf.minim.*;
import ddf.minim.effects.*;

Minim minim;

AudioSample song;
AudioSample echo;
int echoValue = 7500;

float initialGain;
float finalGain;
boolean fading = true;

boolean isPlaying = true;
boolean isEcho = false;

float a0 = 0.17654;
float a1 = 0.64693;

float initialInv = 0.05;
float ampl = 2;

void setup() {
  size(512, 200);
  minim = new Minim(this);
  song = minim.loadSample("01 PCM Rock Sample.mp3");
  echo = minim.loadSample("01 PCM Rock Sample.mp3");

  song.trigger();
  initialGain = song.getGain();
  finalGain = -80;

  startEcho();
  echo.trigger();
  echo.setGain(finalGain);
}

void draw() {
  background(0);
  stroke(100, 200, 255);

  for (int i = 0; i < song.bufferSize() - 1; i++) {
    text(song.getMetaData().author(),5,20);
    text(song.getMetaData().title(),5,40);
    line(i, 50 + song.left.get(i)*100, i+1, 50 + song.left.get(i+1)*100);
    line(i, 150 + song.right.get(i)*100, i+1, 150 + song.right.get(i+1)*100);
  }
  clampGain();
}

void stop() {
  song.close();
  minim.stop();
  super.stop();
}

void clampGain(){
  if(song.getGain() < finalGain)
    song.setGain(finalGain);
  if(song.getGain() > initialGain)
    song.setGain(initialGain);
}

void keyPressed() {
  
  if(key == 'f'){
   float currentVolume = song.getGain();
   if(!fading){
      song.shiftGain(currentVolume,initialGain,2000);
      if(isEcho)
        echo.shiftGain(echo.getGain(), initialGain-5, 2000);
      fading = true;
   }
   else{
     song.shiftGain(currentVolume,finalGain,2000);
     if(isEcho)
       echo.shiftGain(echo.getGain(), finalGain, 2000);
     fading = false;
   }
  }
  
  if(key == 'm' && song.isMuted()){
    song.unmute();
    echo.unmute();
  }else if(key == 'm' && !song.isMuted()){
    song.mute();
    echo.mute();
  }
  
  if(key == 'r'){
   revert(song);
   revert(echo);
  }
  
  if(key == 'l'){
    for(int i = 0; i<5; i++){
      passSecondOrder(1, song);
      passSecondOrder(1, echo);
    }
  }
  
  if(key == 'k'){
    for(int i = 0; i<10; i++){
      passFirstOrder(1, song);
      passFirstOrder(1, echo);
    }
  }
  
  if(key == 'h'){
    for(int i = 0; i<1; i++){
      passSecondOrder(-1, song);
      passSecondOrder(-1, echo);
    }
  }
  
  if(key == 'j'){
    for(int i = 0; i<2; i++){
      passFirstOrder(-1, song);
      passFirstOrder(-1, echo);
    }
  }
  
  if(key == 'e'){
   isEcho = !isEcho;
   if(isEcho && fading)
     echo.setGain(initialGain-5);
   else if(!isEcho)
     echo.setGain(finalGain);
  }
  
  if(key == 'i'){
    invert(song);
    invert(echo);
  }
  
  if(key == 'z'){
     randomEffect(song);
     randomEffect(echo);
  }
  
  if(key == 'a'){
    amplify(song, ampl);
    amplify(echo, ampl);
  }
  
  if(key == 'd'){
    amplify(song, 1/ampl);
    amplify(echo, 1/ampl);
  }
}
  
void revert(AudioSample audio) {
  float[] leftChannel = audio.getChannel(AudioSample.LEFT);
  float[] rightChannel = audio.getChannel(AudioSample.RIGHT);

  int size = leftChannel.length-1;

  /*inverts the array*/
  for(int i=0, j=size; i<j; i++, j--){
    float leftTemp = leftChannel[i];
    float rightTemp = rightChannel[i];
    leftChannel[i] = leftChannel[j];
    leftChannel[j] = leftTemp;
    rightChannel[i] = rightChannel[j];
    rightChannel[j] = rightTemp;
  }
}

void passFirstOrder(int filter, AudioSample audio){
  float[] leftChannel = audio.getChannel(AudioSample.LEFT);
  float[] rightChannel = audio.getChannel(AudioSample.RIGHT);
  
  int size = leftChannel.length-1;
    
  for(int i=1; i<=size; i++){
      leftChannel[i] = 0.5 * leftChannel[i] + 0.5*filter*leftChannel[i-1];
      rightChannel[i] = 0.5 * rightChannel[i] + 0.5*filter*rightChannel[i-1];
  }
}

void passSecondOrder(int filter, AudioSample audio){
  float[] leftChannel = audio.getChannel(AudioSample.LEFT);
  float[] rightChannel = audio.getChannel(AudioSample.RIGHT);
  
  int size = leftChannel.length-1;
    
  for(int i=2; i<=size; i++){
      leftChannel[i] = a0 * leftChannel[i] + a1*filter*leftChannel[i-1] + a0 * leftChannel[i-2];
      rightChannel[i] = a0 * rightChannel[i] + a1*filter*rightChannel[i-1] + a0 * leftChannel[i-2];
  }
}

void startEcho(){
  float[] leftChannel = echo.getChannel(AudioSample.LEFT);
  float[] rightChannel = echo.getChannel(AudioSample.RIGHT);
  int size = leftChannel.length-1;
  for(int i=size; i>echoValue; i--){
      leftChannel[i] = leftChannel[i-echoValue];
      rightChannel[i] = rightChannel[i-echoValue];
  }
}

void amplify(AudioSample audio, float ampl){
  float[] leftChannel = audio.getChannel(AudioSample.LEFT);
  float[] rightChannel = audio.getChannel(AudioSample.RIGHT);
  int size = leftChannel.length-1;
    
  for(int i=0; i<=size; i++){
    leftChannel[i]*=ampl;
    rightChannel[i]*=ampl;
  }
}

void invert(AudioSample audio){
  float[] leftChannel = audio.getChannel(AudioSample.LEFT);
  float[] rightChannel = audio.getChannel(AudioSample.RIGHT);
  int size = leftChannel.length-1;
    
  for(int i=0; i<=size; i++){
      leftChannel[i] = initialInv - (leftChannel[i] - initialInv);
      rightChannel[i] = initialInv - (rightChannel[i] - initialInv);
    }
}

void randomEffect(AudioSample audio){
  float[] leftChannel = audio.getChannel(AudioSample.LEFT);
  float[] rightChannel = audio.getChannel(AudioSample.RIGHT);
  int size = leftChannel.length-1;
  
  for(int j = 0; j<2; j++){
    for(int i=0; i<=size; i++){
        leftChannel[i] = cos(leftChannel[i]) * 1.5;
        rightChannel[i] = cos(rightChannel[i]) * 1.5;
    }
  }
}