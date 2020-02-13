import processing.video.*;


PImage takePicture() {
  int numPixels;
  int[] previousFrame;
  Capture cam;
  
  cam = new Capture(this, 640, 480);
  cam.start();
    loadPixels();
  println("Started camera");
  int timeLeft = maxMilisecsToWaitForCamera;
  while(!cam.available()&&(timeLeft >= 0)){
     try {Thread.sleep(100);print("*");}
     catch(InterruptedException ex) {Thread.currentThread().interrupt();}
     timeLeft-=  100;}
  if (cam.available()) {
      println("cam available");
      cam.read(); // Read the new frame from the camera
      println("cam read ok");
      image(cam, 0, 0);
      cam.stop();
      return cam;
    }
          println("cam not available");
  cam.stop();
        println("stopped camera");
  return null;
}



///////////////////////////////

//    Date:       15-12-2016
   
//    Version:    1.2
   
//    Copyright:  2016, Henning Christiansen, henning@ruc.dk
 
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
 
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
 
//    Find a copy of the GNU General Public License at http://www.gnu.org/licenses/.