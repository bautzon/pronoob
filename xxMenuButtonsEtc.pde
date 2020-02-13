/// THE FOLLOWING CODE COPY-PASTED, MODIFIED FROM THE AUTHOR'S MINIVISKBOOK

class Shape {color c;
             void draw(boolean active) {};
             boolean mouseWithin() {return false;}
             int centerX() {return -1;} int centerY(){return -1;}}

class Square extends Shape {
  int x; int y; int w; int h;
  Square(int xx, int yy, int ww, int hh, color cc) {c=cc; x=xx; y=yy; w=ww; h=hh;}
  Square(int xx, int yy, int ww, int hh) {c=buttonColor; x=xx; y=yy; w=ww; h=hh;}
  void draw(boolean active) {fill(active ? c : grayOut(c));
                             noStroke(); rect(x, y, w , h);}
  boolean mouseWithin() {
    if (mouseX < x) return false;
    if (mouseX > x+w) return false;
    if (mouseY < y) return false;
    if (mouseY > y+h) return false;
    return true;}
  int centerX() {return x+w/2;} int centerY() {return y+h/2;} // these two used for centering text

}

class Circle extends Shape {
  int x; int y; int r; // x,y is center; r radius
  Circle(int xx, int yy, int rr, color cc) {c=cc; x=xx; y=yy; r=rr;}
  Circle(int xx, int yy, int rr) {c=buttonColor; x=xx; y=yy; r=rr;}
  boolean mouseWithin() {return (mouseX-x)*(mouseX-x)+(mouseY-y)*(mouseY-y) < r*r;}
  int centerX() {return x;} int centerY() {return y;}
  void draw(boolean active) {fill(active ? c : grayOut(c)); noStroke(); ellipse(x,y,2*r,2*r);}
}


class ScreenElement{
    int id; // make sure to call with different ids
    boolean active; // for buttons whether it is clickable (or greyed out or similar); other elements how they are shownbut depends on te kind of element
    String text; // perhaps null;
    color textCol;
    void draw() {;} // virtual procedure
    boolean mouseWithin() {return false;} // semi-virtual procedure redefined for those where it gives sense to test this
    void switchOn(){active=true;} void switchOff(){active=false;}
}

class Button extends ScreenElement{
//  int id; // make sure to call with different ids
//  boolean active; // = true; // whether it is shown and is clickable
  Shape shape;
//  String text; // perhaps null;
//  color textCol;
  Button(int idd, Shape ss, String tt, color cc) {id=idd;shape=ss;text=tt;textCol=cc;active=true;allScreenElements[noOfScreenElements]=this;noOfScreenElements++;}
  Button(int idd, Shape ss) {id=idd;shape=ss;text=null;textCol=buttonFontColor;active=true;allScreenElements[noOfScreenElements]=this;noOfScreenElements++;}
  void draw() {shape.draw(active);
                if(text!=null) {
                   textFont(buttonFont); textSize(buttonFontSize);
                   fill(active ? textCol : grayOut(textCol));
                   text(text, this.centerX()-textWidth(text)/2, this.centerY()+buttonFontSize/4);} }
  int centerX() {return shape.centerX();} int centerY() {return shape.centerY();}
  boolean mouseWithin() {return shape.mouseWithin();}
}

// examples  new Button(1, new Circle(100,100,20), ">>", color(128));

class textField extends ScreenElement{
     color textCol;
    int fontSize;
    int x; int y;  // lower left corner of text box
    textField(int idd, String tt, int xx, int yy, color cc, int fs) {
             id=idd; text=tt; x=xx; y=yy; textCol=cc; active=true;fontSize=fs;
             allScreenElements[noOfScreenElements]=this;noOfScreenElements++;}
        
    void draw() {  if(fontSize==textFieldFontSizeSmall)textFont(defaultTextFieldFontSmall); //a nice little hac to optimize text appearance 
                   else textFont(defaultTextFieldFont);
    
                   textSize(fontSize);
                   fill(textCol);
                   if(active && text!=null) text(text, x, y); }
}



class imageField extends ScreenElement{
  PImage img;
  int x; int y; // upper (!!!) left corner of image box
  int imgWidth; int imgHeight;
  imageField(int idd, int xx, int yy, int iw, int ih) {
    id=idd;x=xx;y=yy;imgWidth=iw;imgHeight=ih;active=false;
    allScreenElements[noOfScreenElements]=this;noOfScreenElements++;}

    void draw() { if(!active || img==null) return;
        PImage img1 = downScaleToFit(img, imgWidth, imgHeight);
        image(img1,x+(imgWidth-img1.width)/2,y+(imgHeight-img1.height)/2); }
}

class histogram extends ScreenElement{
  String [] labels;
  int [] votes;
  int x; int y; // upper (!!!) left corner of histogram box
  int histWidth; int histHeight;
  
  histogram(int idd, int xx, int yy, int hw, int hh) {
             id=idd; x=xx; y=yy; histWidth=hw; histHeight=hh; active=false;
             allScreenElements[noOfScreenElements]=this;noOfScreenElements++;}
        
    void draw() {  if(!active || votes==null || labels==null) return;
                   //total number of votes
                   int totalVotes=0;
                   for(int i=0;i<votes.length;i++)totalVotes+=votes[i];
                   int columnSpace = 10;
                   int columnWidth;
                   if(votes.length==0)columnWidth=1; //aritrary
                   else columnWidth = (histWidth - columnSpace*(votes.length+1))/votes.length;
                   int [] columnX = new int [votes.length];
                   for(int j=0;j<votes.length;j++) columnX[j] = x + columnSpace + j*(columnSpace+columnWidth);
                   int [] columnHeight  = new int [votes.length];
                   for(int k=0;k<columnHeight.length;k++) columnHeight[k] = (histHeight - 50) * votes[k] / totalVotes;
                   
                   // paint background
                   fill(color(255,255,255)); rect(x,y,histWidth,histHeight);
                   // print labels as text
                   
                   for(int m=0;m<labels.length;m++) {
                      color colColor = m>=histColors.length ? color(0,0,0) : histColors[m];
                      fill(colColor);
                      rect(columnX[m], y+histHeight-30-columnHeight[m], columnWidth, columnHeight[m]);
                      textFont(defaultTextFieldFontSmall); textSize(textFieldFontSizeSmall); fill(color(0,0,0));
                      text(labels[m], columnX[m] + columnWidth/2-textWidth(labels[m])/2,y+histHeight-10);
                   }
                   
                  }
}
 
color [] histColors = {color(255,0,0), color(0,255,0), color(0,0,255),
                       color(0,255,255), color(255,0,255), color(255,255,0),                      
                       color(0,128,255), color(128,0,255), color(128,255,0),
                       color(0,255,128), color(255,0,128), color(255,128,0)};

class validationResult extends ScreenElement{
  String [] labels;
  //int [] votes;
  
  int [][] resultMatrix; //resultMatrix[i][j] = how many img of class_i that are classified as class_j
  float [] precision; //precision[i] = the precision for class_i
  float [] recall; //recall[i] = the recall for class_i
  float [] f_measure; //f_measure[i] = the f_measure for class_i
  
  int x; int y; // upper (!!!) left corner of histogram box
  int valWidth; int valHeight;
  
  validationResult(int idd, int xx, int yy, int vw, int vh) {
             id=idd; x=xx; y=yy; valWidth=vw; valHeight=vh; active=false;
             allScreenElements[noOfScreenElements]=this;noOfScreenElements++;}

  void draw() {
      //println(resultMatrix);
      if(!active || labels==null || labels.length==0) return;

      textFont(defaultTextFieldFontSmall); textSize(textFieldFontSizeSmall); fill(color(0,0,0));
// JUST BEGINNING OF CALCULATING dimensions for fine matrix
      int labelwidth=0; for(int i=0;i<labels.length;i++)labelwidth=max(labelwidth,int(textWidth(labels[i])));
      // int(textWidth(nf(9.999)))


      // QUICK AND DIRTY
      int start = 200;
      String headlineToPrint ="class \\ predicted  ";
         for(int k=0;k<labels.length;k++)headlineToPrint+=labels[k]+" ";
      headlineToPrint+=  "| precision | recall | f measure";
      println(headlineToPrint);
      text(headlineToPrint, 20, start);
      for(int i=0; i<labels.length;i++) {start+=20;
        String toPrint = labels[i]+"               ";
        for(int j=0;j<labels.length;j++) toPrint+=resultMatrix[i][j]+"       ";
        toPrint+= nf(precision[i],1,3)+"     "+nf(recall[i],1,3)+"      "+nf(f_measure[i],1,3);
        text(toPrint,20,start);
        println(toPrint); }

  }
}

class aboutField extends ScreenElement{
  int x; int y; // upper (!!!) left corner of histogram box
  int aboutWidth; int aboutHeight;
    
  aboutField(int idd, int xx, int yy, int hw, int hh) {
             id=idd; x=xx; y=yy; aboutWidth=hw; aboutHeight=hh; active=false;
             allScreenElements[noOfScreenElements]=this;noOfScreenElements++;}

  void draw() {
      if(!active)return;
      // paint background
      fill(color(255,255,255)); rect(x,y,aboutWidth,aboutHeight);
      // print text      
      textFont(defaultTextFieldFontSmall);
      textSize(textFieldFontSizeSmall);
      fill(color(0,0,0));
      text("HIC stands for Henning's Image Classifier and is a program written by "
           + "Henning Christiansen, henning@ruc.dk. © 2016", x+10,y+textFieldFontSizeSmall+10);
      text("It is made specifically to be used in the course 'Artificial Intelligence in Interactive Systems' "
           + "given at Roskilde University,", x+10,y+2*(textFieldFontSizeSmall+10));
      text("HUMTEK bachelor, 2nd semester.", x+10,y+3*(textFieldFontSizeSmall+10));
      text("Contact the author for documentation.", x+10,y+4*(textFieldFontSizeSmall+10));
      
      text("The program implements supervised learning for image classification, based "
           + "loosely on the following articles:", x+10,y+5.5*(textFieldFontSizeSmall+10));
      text(" 1. Pierre Geurts, Damien Ernst, and Louis Wehenkel. Extremely randomized trees. "
           + "Machine Learning, 63(1):3–42, 2006.", x+10,y+6.5*(textFieldFontSizeSmall+10));
      text(" 2. Raphaël Marée, Pierre Geurts, Justus H. Piater, and Louis Wehenkel. "
           + "Random subwindows for robust image classification. ", x+10,y+7.5*(textFieldFontSizeSmall+10));
      text("     In CVPR (1), pages 34–40. IEEE Computer Society, 2005."
           , x+10,y+8.5*(textFieldFontSizeSmall+10));
      text(" 3. Raphaël Marée, Pierre Geurts, and Louis Wehenkel. "
           + "Content-based image retrieval by indexing random subwindows with randomized trees.", x+10,y+9.5*(textFieldFontSizeSmall+10));
     text("     In Yasushi Yagi, Sing Bing Kang, In-So Kweon, and Hongbin Zha, editors, ACCV (2), "
           , x+10,y+10.5*(textFieldFontSizeSmall+10));
     text("     volume 4844 of Lecture Notes in Computer Science, pages 611–620. Springer, 2007."
           , x+10,y+11.5*(textFieldFontSizeSmall+10));
      
     text("There exists a program named PiXiT, produced by the Belgian company PEPITe S.A. "
          + "that implements the same algorithms in a more general form."
           , x+10,y+13*(textFieldFontSizeSmall+10));

     text("PiXiT is not maintained any longer, and therefore we decided to write our own, independent quick-and-dirty program."
           , x+10,y+14*(textFieldFontSizeSmall+10));
 
     text("HIC contains no source code of PiXiT and the only direct similarity is in the way that training and validation data are organized."
           , x+10,y+15*(textFieldFontSizeSmall+10));
      
     text("HIC version " +HIC_version,
           x+10,y+17.5*(textFieldFontSizeSmall+10));
      

    }
}
                  
ScreenElement [] allScreenElements = new ScreenElement[1000];

int noOfScreenElements = 0;

void drawallScreenElements(){for(int i=0;i<noOfScreenElements;i++) allScreenElements[i].draw();}

static final int NOBUTTON = -1;

int mouseOverButton() {for(int i=0;i<noOfScreenElements;i++){
    if(allScreenElements[i].active && (allScreenElements[i] instanceof Button) && allScreenElements[i].mouseWithin())return allScreenElements[i].id;} return NOBUTTON;}

// Warning: if the following fun's are called with non-existing id, nothing happens
void switchButtonOn(int idd) {for(int i=0;i<noOfScreenElements;i++){if(allScreenElements[i].id==idd && allScreenElements[i] instanceof Button){allScreenElements[i].active=true;return;}}}

void switchButtonOff(int idd) {for(int i=0;i<noOfScreenElements;i++){if(allScreenElements[i].id==idd && allScreenElements[i] instanceof Button){allScreenElements[i].active=false;return;}}}

boolean buttonIsOn(int idd) {for(int i=0;i<noOfScreenElements;i++){if(allScreenElements[i].id==idd && allScreenElements[i] instanceof Button)return allScreenElements[i].active;}return true;}

boolean buttonIsOff(int idd) {for(int i=0;i<noOfScreenElements;i++){if(allScreenElements[i].id==idd && allScreenElements[i] instanceof Button)return !allScreenElements[i].active;}return true;}

void switchAllButtonsOff() {for(int i=0;i<noOfScreenElements;i++)
                            if(allScreenElements[i] instanceof Button)allScreenElements[i].active=false;}

void setTextField(int idd, String s){for(int i=0;i<noOfScreenElements;i++)
                            if(allScreenElements[i].id==idd && allScreenElements[i] instanceof textField)
                              {allScreenElements[i].text=s; return;} }

void switchTextFieldOn(int idd){for(int i=0;i<noOfScreenElements;i++)
                            if(allScreenElements[i].id==idd && allScreenElements[i] instanceof textField)
                              {allScreenElements[i].active=true; return;} }
        
void switchTextFieldOff(int idd){for(int i=0;i<noOfScreenElements;i++)
                            if(allScreenElements[i].id==idd && allScreenElements[i] instanceof textField)
                              {allScreenElements[i].active=false; return;} }
        

void setValidationResult(int idd, int[][]r, String [] llabels){
         for(int i=0;i<noOfScreenElements;i++) {
                            if(allScreenElements[i].id==idd && allScreenElements[i] instanceof validationResult)
                              { allScreenElements[i].active=true;
                                ((validationResult)allScreenElements[i]).resultMatrix=r;
                                ((validationResult)allScreenElements[i]).labels = llabels;
                                ((validationResult)allScreenElements[i]).precision = new float [r.length];
                                ((validationResult)allScreenElements[i]).recall = new float [r.length];
                                ((validationResult)allScreenElements[i]).f_measure = new float [r.length];
                                for(int j=0;j<r.length;j++) {
                                    int sumCatGivenClass=0; int sumCatPredictedClass=0;
                                    for(int k=0;k<r[j].length;k++) {sumCatGivenClass+=r[j][k];sumCatPredictedClass+=r[k][j];}
                                    if(sumCatGivenClass==0){((validationResult)allScreenElements[i]).recall[j]=0;}
                                      else{((validationResult)allScreenElements[i]).recall[j]=float(r[j][j])/sumCatGivenClass;}
                                    if(sumCatPredictedClass==0){((validationResult)allScreenElements[i]).precision[j]=0;}
                                      else ((validationResult)allScreenElements[i]).precision[j]=float(r[j][j])/sumCatPredictedClass;
                                    if(r[j][j]==0 || sumCatGivenClass+sumCatPredictedClass==0) ((validationResult)allScreenElements[i]).f_measure[j]=0;
                                    else ((validationResult)allScreenElements[i]).f_measure[j]=
                                             2*((validationResult)allScreenElements[i]).recall[j]
                                              *((validationResult)allScreenElements[i]).precision[j]
                                              /(((validationResult)allScreenElements[i]).recall[j]+((validationResult)allScreenElements[i]).precision[j]);
                                    }
                                 return; } } }


void setHistogram(int idd, String [] llabels, int [] mmarks) {
  for(int i=0;i<noOfScreenElements;i++){
        if(allScreenElements[i].id==idd && allScreenElements[i] instanceof histogram)
          { 
           allScreenElements[i].active=true;
           ((histogram)allScreenElements[i]).labels=llabels;
           ((histogram)allScreenElements[i]).votes=mmarks;
           return;}
  }}

void clearAllHistograms() {
  for(int i=0;i<noOfScreenElements;i++){
        if(allScreenElements[i] instanceof histogram)
           allScreenElements[i].active=false;
  }}
  

void clearAllValidationResults() {
  for(int i=0;i<noOfScreenElements;i++){
        if(allScreenElements[i] instanceof validationResult)
           allScreenElements[i].active=false;
  }}
  
void  clearAllAboutFields() {
  for(int i=0;i<noOfScreenElements;i++){
        if(allScreenElements[i] instanceof aboutField)
           allScreenElements[i].active=false;
  }}

void setImageField(int idd, PImage iimg) {
  for(int i=0;i<noOfScreenElements;i++){
        if(allScreenElements[i].id==idd && allScreenElements[i] instanceof imageField)
          {allScreenElements[i].active=true;
           ((imageField)allScreenElements[i]).img=iimg;
           return;}
  }}

void setAboutField(int idd) {
  for(int i=0;i<noOfScreenElements;i++){
        if(allScreenElements[i].id==idd && allScreenElements[i] instanceof aboutField)
          {allScreenElements[i].active=true;
           return;}
  }}

void clearAllImageFields() {for(int i=0;i<noOfScreenElements;i++)
                            if(allScreenElements[i] instanceof imageField)allScreenElements[i].active=false;}


///////////////// VARIOUS PARAMETERS

color defaultBackgroundColor = color(20);  // SET SOME GRAY COLOUR - SMALL INT NUMBER ..adjust according to actual monitor!
//color defaultBackgroundColor = color(255,0,0);

color backgroundColor = defaultBackgroundColor;

color paperColor = color(208,203,196); // sampled from the first page of the book
color defaultButtonColor = color(0, 0, 0, 0); // invisible
color buttonColor=defaultButtonColor;

color defaultButtonFontColor = color(0); // black
color buttonFontColor = defaultButtonFontColor;
// AGaramondPro-Bold AGaramondPro-BoldItalic AGaramondPro-Italic AGaramondPro-Regular


PFont defaultRomanFont;// = loadFont("AGaramondPro-Regular-64.vlw"); // we use these two and scale...
//PFont defaultItalicFont;// = loadFont("AGaramondPro-Italic-64.vlw"); 
PFont defaultButtonFont;// = defaultRomanFont;
PFont buttonFont;//=defaultButtonFont;
int defaultButtonFontSize = 40;
int buttonFontSize=defaultButtonFontSize;
PFont defaultTextFieldFont;// = defaultRomanFont;
int textFieldFontSizeBig = int(1.5*defaultButtonFontSize);
int textFieldFontSizeSmall = int(0.5*defaultButtonFontSize);

// we experienced downscaling the big font is nor pretty, so separate font
PFont defaultRomanFontSmall; // = loadFont("AGaramondPro-Regular-20.vlw");
PFont defaultTextFieldFontSmall; // = defaultRomanFontSmall;
PFont defaultBoldFontSmall; // loadFont("AGaramondPro-Bold-20.vlw");

void loadFonts() {
  defaultRomanFont = loadFont("AGaramondPro-Regular-64.vlw"); // we use these two and scale...
//  defaultItalicFont = loadFont("AGaramondPro-Italic-64.vlw");
  defaultRomanFontSmall = loadFont("AGaramondPro-Regular-20.vlw");
  defaultBoldFontSmall = loadFont("AGaramondPro-Bold-20.vlw");
  defaultButtonFont = defaultRomanFont;
  buttonFont=defaultButtonFont;
  defaultTextFieldFont = defaultRomanFont;
  defaultTextFieldFontSmall = defaultRomanFontSmall;
}
// The following concerns the infotexts

//color infoTextColor = color(208*0.7,203*0.7,196*0.7); // paper color sampled from images and made a tiny bit darker

//int defaultInfoTextSize = 32; // in pixels 

int minimumInfoTextSize = 10; // if running out of space; we reduce gradually until text fits in

int infoTextLeadingPct = 120;

int infoTextWidth = 550; int infoTextHeight = 400;

color grayOut(color c) {
   return color( int(red(c)*0.5), int(green(c)*0.5), int(blue(c)*0.5));
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