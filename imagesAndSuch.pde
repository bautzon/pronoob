class HsvPixel {
  float [] hsv; // 0: H, 1: S, 2: V  //each value represented
                                     //between 0 and 1
  HsvPixel(int rr, int gg, int bb) {
    hsv = new float [3];
    float r=((float)rr)/255; float g=((float)gg)/255; float b = ((float)bb)/255;
    float minRGB = min(r,g,b);
    float maxRGB = max(r,g,b);
    
    if (minRGB==maxRGB) {hsv[0]=0;hsv[1]=0;hsv[2]=minRGB; return;}  //greyish; h=0 is arbitrary

    // Colors other than black-gray-white:
    float d = (r==minRGB) ? g-b : ((b==minRGB) ? r-g : b-r);
    float hh = (r==minRGB) ? 3 : ((b==minRGB) ? 1 : 5);
    hsv[0] = (60*(hh - d/(maxRGB - minRGB)))/360;
    hsv[1] = (maxRGB - minRGB)/maxRGB;
    hsv[2] = maxRGB;
  }
}  

class Subwindow {
  int classNumber; // -1 means: no relevant class
  HsvPixel [] content; // [subwindowSize*subwindowSize]
  Subwindow(PImage img, int classNo, int subwindowSize) {
    classNumber = classNo;
    content = new HsvPixel [subwindowSize*subwindowSize];
//    println("img.height: "+img.height + " img.width: "+img.width);
    int n=0;
    for (int i=0;i<subwindowSize;i++) for (int j=0;j<subwindowSize;j++) {
      //calculate average rgb of one or more pixels
      int r=0;int g=0;int b=0;
      for (int ii=0; ii< int(img.width/float(subwindowSize)); ii++) for (int jj=0; jj< int(img.height/float(subwindowSize)); jj++) {
        r+= red(img.get(ii,jj)); g+= green(img.get(ii,jj)); b+= blue(img.get(ii,jj));
      //println("r: "+ red(img.get(ii,jj)) +  " g: "+ green(img.get(ii,jj)) +  " b: " + blue(img.get(ii,jj)));
        }
      int divider = int( (img.width/float(subwindowSize))) *  int((img.height/float(subwindowSize)) );
      if(divider==0) divider=1;
      content[n]= new HsvPixel( r/divider, g/divider, b/divider);
  //    println("<"+r/divider + ", " + g
  //               + ", " + b + ">  /"+divider);
      n++;
    }
  }
  float selectAttribute(int pixNo, int hsvIndex) {return content[pixNo].hsv[hsvIndex];}
  
  void printSubwindow() {
    for (int i=0;i<content.length;i++) {
        print("<"+content[i].hsv[0] + ", " + content[i].hsv[1]
                 + ", " + content[i].hsv[2] + ">  ");
      println();}}
    
} 

// now functions for taking random subwindow of a PImage

Subwindow randomSubwindow(PImage img, int classNo, int subwindowSize) {
  int subwEdge = int(random(subwindowSize, min(img.width,img.height)));
  PImage subwRGB;  subwRGB = img.get( int( random(0, img.width-subwEdge)),  int( random(0, img.height-subwEdge)),
                            subwEdge, subwEdge);
  subwRGB.resize(subwindowSize,subwindowSize);
  return new Subwindow(subwRGB, classNo, subwindowSize); }

Subwindow [] randomSubwindows(PImage img, int classNo, int subwindowSize, int subwindowsPerImage) {
  Subwindow [] res = new Subwindow [subwindowsPerImage];
  for(int i=0; i<subwindowsPerImage; i++) res[i] = randomSubwindow(img, classNo, subwindowSize);
  return res;
}

Subwindow [] randomSubwindows(PImage img, int subwindowSize, int subwindowsPerImage) {  // To be used when no class is relevant
  return randomSubwindows(img, -1, subwindowSize, subwindowsPerImage);
}

// PROBLEM: loadImage(imageFileName) returns an image object even when file is sick!
// The following function uses UNDOCUMENTED FEATURES to identify such sick image object!

boolean imageOK(PImage img) {
    if(img==null) return false;
    return img.width!=-1; // UNDOCUMENTED - FOUND BY TEST
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