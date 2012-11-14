import processing.video.*;
import gifAnimation.*;
import fullscreen.*;

// change this url to where ever you uploaded the php files.
String url = "http://bellmonde.com/php/upload.php";


Capture video;
PImage prevFrame;
PGraphics record;

GifMaker gifExport;

float threshold = 60;
float sensitivity = 600;

int pixelsMoved = 0;
int motionTimerStarted = 0;
int numPhotos = 0;

int photoTimer = 0;
int photoPause = 15;
int numGifs;
boolean sessionStarted = false;
boolean sessionWait = false;
int sessionPause = 150;
int sessionTimer = 0;


boolean takingPhotos = false;
String motionTest;
PFont f;

color circleColor;
int opacityFrames = 5;
int opacityCurrent = 0;


// visuals
// Size of each cell in the grid
int videoScale = 50;
// Number of columns and rows in our system
int cols, rows;
// Variable for capture device
PImage cam_small;

FullScreen fs;

void setup() {
  size(960,540);
  //size(1920,1080);
  circleColor = color(255,255,255);
  //video = new Capture(this, width, height, 15);
  video = new Capture(this, 640, 480, 15);
  // Create an empty image the same size as the video
  
  f = loadFont("Monaco-48.vlw");
  prevFrame = createImage(video.width,video.height,RGB);
    
  record = createGraphics(100,100, P2D);
  
  
  
  String path = sketchPath+"/gifs";
  numGifs = 0;

  ArrayList allFiles = listFilesRecursive(path);
  
  for (int i = 0; i < allFiles.size(); i++) {
    File f = (File) allFiles.get(i);
    if ( !f.isDirectory() ){          
      if ( match(f.getName(), ".gif") != null ){ 
        println( f.getName() + " is a gif");
        numGifs++;     
      }
    }
  }  
/*  
  gifExport = new GifMaker(this, "gifs/export"+(numGifs+1)+".gif");
  gifExport.setRepeat(0);
*/  
  //createNewGif();
  
  
  cols = width/videoScale;
  rows = height/videoScale;  
  smooth();
  
  thread("sendImage");
  //video = new Capture(this,640,480,15);
  //fs = new FullScreen(this);
  //fs.enter();  
}

void draw() {
  
  // Capture video
  if (video.available()) {
    // Save previous frame for motion detection!!
    prevFrame.copy(video,0,0,video.width,video.height,0,0,video.width,video.height); // Before we read the new frame, we always save the previous frame for comparison!
    prevFrame.updatePixels();
    video.read();
  
  
    loadPixels();
    //video.loadPixels();
    //prevFrame.loadPixels();
    
    cam_small = video.get();
    cam_small.resize(cols,rows);    
    
    pixelsMoved = 0;
    for (int x = 0; x < video.width; x ++ ) {
      for (int y = 0; y < video.height; y ++ ) {      
        int loc = x + y*video.width;            // Step 1, what is the 1D pixel location
        color current = video.pixels[loc];      // Step 2, what is the current color
        color previous = prevFrame.pixels[loc]; // Step 3, what is the previous color
        float r1 = red(current); float g1 = green(current); float b1 = blue(current);
        float r2 = red(previous); float g2 = green(previous); float b2 = blue(previous);
        float diff = dist(r1,g1,b1,r2,g2,b2);      
        if (diff > threshold) { 
          //pixels[loc] = color(205,125,205);
          pixels[loc] = color(255,255,255);
          pixelsMoved++;
        } else {
          //pixels[loc] = color(215,125,255);
          pixels[loc] = color(0,0,0);
        }
      }
    }
  
  
    updatePixels();
  
    textFont(f,48);
    //fill(255,0,0);
   
   
   sendImage();
/*    
    if ( !takingPhotos ) {
      if ( pixelsMoved < sensitivity ){
        motionTimerStarted = 0;
        motionTest = " "; // no motion
      }else{
        motionTest = "motion";
        motionTimerStarted++;
        if ( motionTimerStarted > 45 ) {
          text("Start taking photos", 200,300); 
          takingPhotos = true;
          //circleColor = color(255,255,255);
        }
      }
    }else{
      // take photos
      if ( sessionWait == false){
        text(numPhotos + " pix taken", 300, 100);
        
        if (sessionStarted == false && numPhotos == 0){
          createNewGif();
          sessionStarted = true;
        }
        
        if ( numPhotos < 3 ){
          if (photoTimer > photoPause){
            //photoActive = true;
            takingPhotos = true;
            numPhotos++;
            //PImage pic = video.get(0,0,640,480);
            PImage pic = video.get(0,0,width,height);
            pic.save("temp/"+ numPhotos +".jpg");
            
            //JPGMakerUploader jpger = new JPGMakerUploader(pic,"temp"+numPhotos,url);
            //jpger.saveJPG();
            //jpger.upload();  
            
            photoTimer = 0;       
          }else{
            photoTimer++;
          }
        }else if ( numPhotos == 3 ){
            saveGif();
            numPhotos = 0;
            takingPhotos = false;
            sessionStarted = false;          
        }else{
          takingPhotos = false;
          numPhotos = 0;
          sessionStarted = false;
        }
      }else{
       if (sessionTimer > sessionPause){
          sessionWait = false;
        }else{
          sessionWait = true;
          sessionTimer++;
        }
      }
    }
      
*/   
    
    

    
    
    
  background(245,239,230);

  cam_small.loadPixels();


  if ( photoTimer > 0 && photoTimer < photoPause-15 && opacityCurrent < opacityFrames ){
    opacityCurrent++;
    // , 255-((255/5)*opacityCurrent)
    circleColor = color(255,255,255, 255-((255/5)*opacityCurrent)); 
  }else{
    opacityCurrent = 0;
    circleColor = color(255,255,255); 
  }

  // Begin loop for columns
  for (int i = 0; i < cols; i++) {
    // Begin loop for rows
    for (int j = 0; j < rows; j++) {

      int x = i*videoScale;
      int y = j*videoScale;

      int loc = (cam_small.width - i - 1) + j*cam_small.width;

      color c = cam_small.pixels[loc];

      float sz = (brightness(c)/255.0)*videoScale; 
      ellipseMode(CENTER);
      //fill(255,0,0);
      //opacity = 255;
      noStroke();
      rectMode(CENTER);
      fill(color(225,129,107));
      rect(x + videoScale/2,y + videoScale/2,sz*2,sz*2);

      fill(circleColor);
      ellipse(x + videoScale/2,y + videoScale/2,sz*.4,sz*.4);

    }
  }    
 

    
    
  /*  
    text(motionTest,10,100);
    fill(0,255,0);
    text(pixelsMoved,10,530);    
    */
    
  }
}

//rendering as a new thread
void sendImage() {
    if ( !takingPhotos ) {
      if ( pixelsMoved < sensitivity ){
        motionTimerStarted = 0;
        motionTest = " "; // no motion
      }else{
        motionTest = "motion";
        motionTimerStarted++;
        if ( motionTimerStarted > 45 ) {
          text("Start taking photos", 200,300); 
          takingPhotos = true;
          //circleColor = color(255,255,255);
        }
      }
    }else{
      // take photos
      if ( sessionWait == false){
        text(numPhotos + " pix taken", 300, 100);
        
        if (sessionStarted == false && numPhotos == 0){
          createNewGif();
          sessionStarted = true;
        }
        
        if ( numPhotos < 3 ){
          if (photoTimer > photoPause){
            //photoActive = true;
            takingPhotos = true;
            numPhotos++;
            //PImage pic = video.get(0,0,640,480);
            PImage pic = video.get(0,0,width,height);
            pic.save("temp/"+ numPhotos +".jpg");
            
            JPGMakerUploader jpger = new JPGMakerUploader(pic,"temp"+numPhotos,url);
            jpger.saveJPG();
            jpger.upload();  
            
            photoTimer = 0;       
          }else{
            photoTimer++;
          }
        }else if ( numPhotos == 3 ){
            saveGif();
            numPhotos = 0;
            takingPhotos = false;
            sessionStarted = false;          
        }else{
          takingPhotos = false;
          numPhotos = 0;
          sessionStarted = false;
        }
      }else{
       if (sessionTimer > sessionPause){
          sessionWait = false;
        }else{
          sessionWait = true;
          sessionTimer++;
        }
      }
    } 

}
void saveGif(){
  text("Gif saved", 500,300);
  //gifExport.finish();
  /*
  JPGMakerUploader jpger = new JPGMakerUploader(img,filename,url);
  jpger.saveJPG();
  jpger.upload();  
 */ 
  //numGifs++;
  println(numGifs);
  sessionWait = true;
  sessionTimer = 0;
  //gifExport = new GifMaker(this, "gifs/export"+(numGifs+1)+".gif");  
}






String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    // If it's not a directory
    return null;
  }
}

ArrayList listFilesRecursive(String dir) {
   ArrayList fileList = new ArrayList(); 
   recurseDir(fileList,dir);
   return fileList;
}

void recurseDir(ArrayList a, String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    a.add(file);  
    File[] subfiles = file.listFiles();
    for (int i = 0; i < subfiles.length; i++) {
      recurseDir(a,subfiles[i].getAbsolutePath());
    }
  } else {
    a.add(file);
  }
}

void createNewGif(){
  numGifs++;
  /*
  for ( i = 0; i < 3; i++){
    JPGMakerUploader jpger = new JPGMakerUploader(img,"temp"+numPhotos,url);
    jpger.saveJPG();
    jpger.upload();    
  }
  */
  /*
  gifExport = new GifMaker(this, "gifs/export"+(numGifs)+".gif");
  gifExport.setRepeat(0); 
  */
}

