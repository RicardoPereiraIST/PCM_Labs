import processing.video.*;

Movie pcmMovie;
PImage frame;
PImage candidateFrame;
int width = 960;
int height = 540;
int size;

int diffSegment = 1;
int diffSquareSegment = 1;
int twinSegment = 1;

int frameCnt = 0;

int modValue = 50;

int diffSum = 1000;
float adaptiveThreshold1 = 0;
float adaptiveThreshold2 = 1000;

float candidateTime = 0;
float thresholdUsed = 0;

boolean stroboscopic = false;
boolean diff = false;
boolean diffSquare = false;
boolean twin = false;

String stroboscopicSegments = "";
String[] stroboscopicSegmentList;

String diffSegments = "";
String[] diffSegmentsList;

String histogramDifferences = "Frame\t\t\tHistogram_Diff\t\tThreshold1\t\tThreshold2\n";
String[] histogramDifferencesList;

String diffSquareSegments = "";
String[] diffSquareSegmentsList;

String histogramSquareDifferences = "Frame\t\t\tHistogram_Diff\t\tThreshold1\t\tThreshold2\n";
String[] histogramSquareDifferencesList;

String twinSegments = "";
String[] twinSegmentsList;

String twinDifferences = "Frame\t\t\tHistogram_Diff\t\tThreshold1\t\tThreshold2\n";
String[] twinDifferencesList;

boolean haveCandidate = false;
int cumulativeDiff = 0;

int histogramAvg = 0;
int threshold1 = 160000;
int threshold2 = 50000;

int[] histogram = new int[256];
int[] histogramPrev = new int[256];
int[] histogramDiff = new int[256];
int[] histogramCandidate = new int[256];

void setup() {
  surface.setSize(width, height);
  pcmMovie = new Movie(this, "PCMLab10.mov");
  frame = createImage(pcmMovie.width, pcmMovie.height, RGB);
  size = width * height;
  pcmMovie.loop();
  
  for(int i=0; i<256;i++){
    histogram[i]=0; 
    histogramPrev[i]=0;
  }
}

void draw() {
  frame = pcmMovie.get();
  
  if(stroboscopic){
    updateHistogram();
    stroboscopicComp();
  }
  
  if(diff){
    updateHistogram();
    calculateDiff(1);
    if(thresholdUsed == 0)
      histogramDifferences += frameCnt + "\t\t\t" + histogramAvg + "\t\t\t" + threshold1 + "\t\t\t0\n";
    else if(thresholdUsed == 1)
      histogramDifferences += frameCnt + "\t\t\t" + histogramAvg + "\t\t\t" + adaptiveThreshold1 + "\t\t\t0\n";
    else if (thresholdUsed == 2)
      histogramDifferences += frameCnt + "\t\t\t" + histogramAvg + "\t\t\t" + adaptiveThreshold2 + "\t\t\t0\n";
    diffComp(1);
  }
  
  if(diffSquare){
    updateHistogram();
    calculateDiff(2);
    if(thresholdUsed == 0)
      histogramSquareDifferences += frameCnt + "\t\t\t" + histogramAvg + "\t\t\t" + threshold1 + "\t\t\t0\n";
    else if(thresholdUsed == 1)
      histogramSquareDifferences += frameCnt + "\t\t\t" + histogramAvg + "\t\t\t" + adaptiveThreshold1 + "\t\t\t0\n";
    else if(thresholdUsed == 2)
      histogramSquareDifferences += frameCnt + "\t\t\t" + histogramAvg + "\t\t\t" + adaptiveThreshold2 + "\t\t\t0\n";
    diffComp(2);
  }
  
  if(twin){
    updateHistogram();
    calculateDiff(1);
    if(thresholdUsed == 0)
      twinDifferences += frameCnt + "\t\t\t" + histogramAvg + "\t\t\t" + threshold1 + "\t\t\t" + threshold2 + "\n";
    else if(thresholdUsed == 1)
      twinDifferences += frameCnt + "\t\t\t" + histogramAvg + "\t\t\t" + adaptiveThreshold1 + "\t\t\t" + threshold2 + "\n";
    else if(thresholdUsed == 2)
      twinDifferences += frameCnt + "\t\t\t" + histogramAvg + "\t\t\t" + adaptiveThreshold2 + "\t\t\t" + threshold2 + "\n";
    twinComp();
  }
  
  frameCnt++;
  image(frame,0,0);
}

void movieEvent(Movie m) { 
  m.read();
}

void keyPressed() {
  if(key=='1'){
    stroboscopic = !stroboscopic;
    diff = false;
    diffSquare = false;
    twin = false;
  }
  
  if(key=='2'){
    stroboscopic = false;
    diff = !diff;
    diffSquare = false;
    twin = false;
  }
  
  if(key == '3'){
    stroboscopic = false;
    diff = false;
    diffSquare = !diffSquare;
    twin = false;
  }
  
  if(key == '4'){
    stroboscopic = false;
    diff = false;
    diffSquare = false;
    twin = !twin;
  }
  
  if(key == 'q'){
    thresholdUsed = 0;
  }
  
  if(key == 'w'){
    thresholdUsed = 1;
  }
  
  if(key == 'e'){
    thresholdUsed = 2;
  }
}

void updateHistogram(){
  for(int i = 0; i<256; i++){
    histogramPrev[i]=(int)histogram[i];
    histogram[i]=0;
  }
  
  for(int i = 0; i < size; i++){
    color c = frame.pixels[i];
    float r = red(c);
    float g = green(c);
    float b = blue(c);
    
    float y = (0.3*r)+(0.59*g)+(0.11*b);
    histogram[(int)brightness(c)]++;
  }
}

void calculateDiff(int power){
  diffSum = histogramAvg;
  histogramAvg = 0;
  for(int i = 0; i<256; i++){
    if(power==1)
      histogramAvg += abs(histogram[i]-histogramPrev[i]);
      
    if(power==2 && histogramPrev[i]!=0)
      histogramAvg += pow(abs(histogram[i]-histogramPrev[i]),power)/histogramPrev[i];
  }
  //histogramAvg/=256;
  
  if(power == 1){
    if(histogramAvg > adaptiveThreshold1/2)
      adaptiveThreshold1 = histogramAvg - 1;
  }
  else if(power == 2){
    if(histogramAvg > adaptiveThreshold1)
        adaptiveThreshold1 = histogramAvg - 1;
    else if(histogramAvg < adaptiveThreshold1-50){
      adaptiveThreshold1-=50;
    }
  }
  
  if(diffSum != 0)
    adaptiveThreshold2 = diffSum * 38;
}

void stroboscopicComp(){
  if(frameCnt%modValue==0){
      frame.save("stroboscopic/stroboscopic_frame0"+frameCnt+".png");
      float currentTime = pcmMovie.time();
      
      stroboscopicSegments += "Stroboscopic Frame " + frameCnt + ": at: " + currentTime + " seconds.\n";
      stroboscopicSegmentList = split(stroboscopicSegments, '\n');
      saveStrings("stroboscopic/stroboscopic_time.txt", stroboscopicSegmentList);
  }
}

void diffComp(int mode){
  float thresh = 0;
  if(thresholdUsed == 0)
    thresh = threshold1;
  else if(thresholdUsed == 1)
    thresh = adaptiveThreshold1;
  else if(thresholdUsed == 2)
    thresh = adaptiveThreshold2;
  
  if(histogramAvg > thresh){
    
    if(mode==1){
      frame.save("diff/diff_segment0"+diffSegment+".png");
      float currentTime = pcmMovie.time();
      diffSegments += "Diff Segment " + diffSegment + ": at: " + currentTime + " seconds.\n";
      diffSegmentsList = split(diffSegments, '\n');
      saveStrings("diff/diff_time.txt", diffSegmentsList);
      histogramDifferencesList = split(histogramDifferences, '\n');
      saveStrings("diff/diff.txt", histogramDifferencesList);
      diffSegment++;
    }
    
    else if(mode == 2){
      frame.save("diffSquare/diffSquare_segment0"+diffSquareSegment+".png");
      float currentTime = pcmMovie.time();
      diffSquareSegments += "Diff Square Segment " + diffSquareSegment + ": at: " + currentTime + " seconds.\n";
      diffSquareSegmentsList = split(diffSquareSegments, '\n');
      saveStrings("diffSquare/diffSquare_time.txt", diffSquareSegmentsList);
      histogramSquareDifferencesList = split(histogramSquareDifferences, '\n');
      saveStrings("diffSquare/diffSquare.txt", histogramSquareDifferencesList);
      diffSquareSegment++;
    }
  }
}

void twinComp(){
  float thresh = 0;
  if(thresholdUsed == 0)
    thresh = threshold1;
  else if(thresholdUsed == 1)
    thresh = adaptiveThreshold1;
  else if(thresholdUsed == 2)
    thresh = adaptiveThreshold2;
    
  if(histogramAvg > thresh){
      frame.save("twin/twin_segment0"+twinSegment+".png");
      float currentTime = pcmMovie.time();
      twinSegments += "Twin Segment " + twinSegment + ": at: " + currentTime + " seconds.\n";
      twinSegmentsList = split(twinSegments, '\n');
      saveStrings("twin/twin_time.txt", twinSegmentsList);
      twinDifferencesList = split(twinDifferences, '\n');
      saveStrings("twin/twin.txt", twinDifferencesList);
      haveCandidate = false;
      twinSegment++;
      return;
    }
    
    if(histogramAvg > threshold2){
      if(haveCandidate){
        int candidateAvg = 0;
        for(int i = 0; i < 256; i++){
          candidateAvg += abs(histogramCandidate[i] - histogram[i]);
        }
        cumulativeDiff+=candidateAvg;
      }
      else{
        for(int i = 0; i < 256; i++){
          histogramCandidate[i] = histogram[i];
        }
        candidateTime = pcmMovie.time();
        candidateFrame =  pcmMovie.get();
        haveCandidate = true;
        cumulativeDiff = histogramAvg;
      }
    }
    else 
    {
      if(cumulativeDiff > thresh){
        candidateFrame.save("twin/twin_candidate_segment0"+twinSegment+".png");
        twinSegments += "Twin Candidate Segment " + twinSegment + ": at: " + candidateTime + " seconds.\n";
        twinSegmentsList = split(twinSegments, '\n');
        saveStrings("twin/twin_time.txt", twinSegmentsList);
        twinDifferencesList = split(twinDifferences, '\n');
        saveStrings("twin/twin.txt", twinDifferencesList);
        haveCandidate = false;
        cumulativeDiff = 0;
        twinSegment++;
      }   
      haveCandidate=false;
      cumulativeDiff=0;
    }
    

}