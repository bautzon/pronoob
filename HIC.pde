// HIC : Henning's image classifier

// To start the program, click the triangle to the upper left
// Be aware that some commands, especially, the Learning command may take some time
// - the window show no activity during that, but you you can see some messages
//   in the lower part of THIS WINDOW.

static final String HIC_version ="1.2, December 15, 2016";

// © 2016 by Henning Christiansen, henning@ruc.dk,

// SEE IMPORTANT LICENCE INFORMATION AT THE END OF THIS FIÆE







void setup() {
  loadFonts();
   size(1200,700);
   // Top line:
   new textField(0, "HIC: A generic image classifier", 10, 55, color(0,0,255),textFieldFontSizeBig);

   // menues
   new Button(1, new Square(10,75,100,40), "Learn", color(0,255,0));
   new Button(2, new Square(120,75,100,40), "Save", color(0,255,0));
   new Button(3, new Square(230,75,100,40), "Load", color(0,255,0));
   new Button(4, new Square(340,75,130,40), "Classify", color(0,255,0));
   new Button(41, new Square(480,75,190,40), "What am I?", color(0,255,0));
   new Button(5, new Square(680,75,140,40), "Validate", color(0,255,0));
   new Button(6, new Square(width-10-110,75,110,40), "About", color(0,255,0));
   
   // initial setting of which buttons that gives sense to call first
   switchButtonOff(2); switchButtonOff(4);  switchButtonOff(41);  switchButtonOff(5);

   new textField(7, null, 10, 140, color(255,255,255),textFieldFontSizeSmall);
   setCurrentClassifierTextField(); // here results in dummy text telling there is no classifier
   
   new imageField(8,10,160-10, width/2-15, height-160);
   new histogram(9, width/2+5, 160-10, width/2-15, height-160);
   new validationResult(10, 10, 160-10, width-20, height-160);
   new aboutField(11, 10, 160-10, width-20, height-160);
   
   // for error messages
   new textField(12, null, 20, 200, color(255,255,0), textFieldFontSizeSmall);
   switchTextFieldOff(12);
}

boolean needToUpdateDisplay = true; // to avoid getting processor to boil updating an anyhow static display

void draw() {
   if(needToUpdateDisplay) {
        background(color(128,128,128));
        // drawAllInactiveElements();
        drawallScreenElements();
   }
   needToUpdateDisplay=false;
}

void mouseClicked() {
  if (mouseOverButton()==1 && buttonIsOn(1)) {
    // Learn
    println("Learn was clicked");
    executeLearning();}
    
  else if (mouseOverButton()==2 && buttonIsOn(2)) {
    // Save
    println("Save was clicked");
    executeSave(); }
    
  else if (mouseOverButton()==3 && buttonIsOn(3)) {
    // Load
    println("Load was clicked");
    executeLoad(); }

  else if (mouseOverButton()==4 && buttonIsOn(4)) {
    // Classify
    println("Classify was clicked");
    executeClassify(); }

  else if (mouseOverButton()==41 && buttonIsOn(41)) {
    // Classify
    println("What am I? was clicked");
    executeWhatAmI(); }

  else if (mouseOverButton()==5 && buttonIsOn(5)) {
    // Validate
    println("Validate was clicked");
    executeValidate(); }

  else if (mouseOverButton()==6 && buttonIsOn(6)) {
    // About
    println("About was clicked");
    executeAbout(); }
}

Classifier currentClassifier=null;

void executeLearning() {
  cursor(WAIT);
  switchTextFieldOff(12);
  clearAllImageFields(); clearAllHistograms(); clearAllValidationResults();clearAllAboutFields();
  switchAllButtonsOff(); // not shown in display as draw() is not called (and calling it explicitly does not work)
 // start a "running process" device
  Classifier newClassifier = new Classifier(DefaultSubwindowSize, DefaultSubwindowsPerImage,
                            DefaultMinimumSamplesPerLeaf, DefaultNumberOfSplitsTested, DefaultNumberOfTrees);
  // in case of exception, provide help and currentClassifier = null;

  if(newClassifier.consistent==0) {;} // consistent=0 means user cancelled command, so keep old if any
  else if(newClassifier.consistent==1) {currentClassifier=newClassifier;currentClassifierSaveable = true;}
  else /* -1, i.e. an error in attemt to learn from files */ {
       currentClassifier=null;
       setTextField(12, "Could not learn from directory: "+newClassifier.fileName);
       switchTextFieldOn(12);
       currentClassifierSaveable=false;}
  // stop "running process" device
  switchButtonOn(1);
  if(currentClassifier!=null && currentClassifier.consistent==1)
        {switchButtonOn(2);
         switchButtonOn(4); 
         switchButtonOn(41); 
         switchButtonOn(5);}
  switchButtonOn(3);
  switchButtonOn(6);
  // indicate that a classifier is loaded  
  setCurrentClassifierTextField();
  needToUpdateDisplay=true;
  cursor(ARROW);
}

void executeSave() {
  // KEEP THOSE if any: clearAllImageFields();clearAllHistograms(); clearAllValidationResults();
  switchTextFieldOff(12);
  clearAllAboutFields();
  switchAllButtonsOff(); // not shown in display as draw() is not called (and calling it explicitly does not work)
 // start a "running process" device
  if(currentClassifier==null || currentClassifier.consistent!=1) {println("BUG in SAVE"); exit();}
  String fileName = makeFreshClassifierFileName(currentClassifier.directoryName);
  saveClassifier(currentClassifier, fileName);
  // stop "running process" device
  switchButtonOn(1);
  //switchButtonOn(2); //no reason to save a file already saved
  currentClassifierSaveable = false;
  switchButtonOn(3);
  switchButtonOn(4); switchButtonOn(41); switchButtonOn(5); switchButtonOn(6);
  needToUpdateDisplay=true;
}

void executeLoad() {
  switchTextFieldOff(12);
  clearAllImageFields(); clearAllHistograms(); clearAllValidationResults(); clearAllAboutFields();
  switchAllButtonsOff(); // not shown in display as draw() is not called (and calling it explicitly does not work)
 // start a "running process" device
  Classifier newClassifier = new Classifier(FROM_FILE); // this constructor gets file name from user and reads in a JSON file
  println("Loaded classifier has consistent = "+newClassifier.consistent);
  if(newClassifier.consistent==0) {;} // consistent=0 means user cancelled command, so keep old if any
  else if(newClassifier.consistent==1)currentClassifier=newClassifier;
  else /* -1, i.e. an error in attemt to learn from files */
     { currentClassifier=null;
       setTextField(12, "Corrupt classifier file: "+newClassifier.fileName);
       switchTextFieldOn(12); currentClassifier=null;}
  currentClassifierSaveable = false;
  switchButtonOn(1);
  if(fileExtensionError) { // error message
       setTextField(12, "Wrong file extension for Load: "+attemptedFileNameFromUser);
       switchTextFieldOn(12); currentClassifier=null; }
  else if(currentClassifier!=null && currentClassifier.consistent==1)
        {switchButtonOn(4);switchButtonOn(41); switchButtonOn(5);}

  switchButtonOn(3);
  switchButtonOn(6);
  // indicate that a classifier is loaded  
  setCurrentClassifierTextField();
  needToUpdateDisplay=true;
}

void executeClassify() {
  cursor(WAIT);
  switchTextFieldOff(12);
  clearAllImageFields(); clearAllHistograms(); clearAllValidationResults(); clearAllAboutFields();
  switchAllButtonsOff(); // not shown in display as draw() is not called (and calling it explicitly does not work)
  String imageFileName = getFileNameFromUser("select an image",ImageFile);
  if(fileExtensionError)  { // error message
       setTextField(12, "Wrong file extension for Classify: "+attemptedFileNameFromUser);
       switchTextFieldOn(12); }
  else if(imageFileName!=null) {
    PImage pic = loadImage(imageFileName);
    if(currentClassifier==null || currentClassifier.consistent!=1) {
      println("PROGRAM BUG IN METHOD executeClassify"); exit();}
    if(imageOK(pic)) {
       int [] votes = currentClassifier.classify(pic);
       setHistogram(9,currentClassifier.classificationNames, votes);
       setImageField(8, pic); }
    else { // error message
       setTextField(12, "Corrupt image file: "+imageFileName);
       switchTextFieldOn(12); }
   }
  switchButtonOn(1);  switchButtonOn(3);switchButtonOn(6);
  if(currentClassifierSaveable)switchButtonOn(2);
  switchButtonOn(4);switchButtonOn(41); switchButtonOn(5);

  needToUpdateDisplay=true;
  cursor(ARROW);
}


void executeWhatAmI() {
  cursor(WAIT);
  switchTextFieldOff(12);
  clearAllImageFields(); clearAllHistograms(); clearAllValidationResults(); clearAllAboutFields();
  switchAllButtonsOff(); // not shown in display as draw() is not called (and calling it explicitly does not work)
  
  // ERSTAT NEDENSTAAENDE MED KALD SOM TAGER BILLEDE MED WEBCAM
    PImage pic = takePicture();
    if(currentClassifier==null || currentClassifier.consistent!=1) {
      println("PROGRAM BUG IN METHOD executeWhatAmI"); exit();}
     if(imageOK(pic)) {
       int [] votes = currentClassifier.classify(pic);
       setHistogram(9,currentClassifier.classificationNames, votes);
       setImageField(8, pic); }
     else { // error messageE
       setTextField(12, "Camera did not work");
       switchTextFieldOn(12); }

  switchButtonOn(1);  switchButtonOn(3);switchButtonOn(6);
  if(currentClassifierSaveable)switchButtonOn(2);
  switchButtonOn(4);switchButtonOn(41); switchButtonOn(5);

  needToUpdateDisplay=true;
  cursor(ARROW);
}
void executeValidate() {
  cursor(WAIT);
  switchTextFieldOff(12);
  clearAllImageFields(); clearAllHistograms(); clearAllValidationResults(); clearAllAboutFields();
  switchAllButtonsOff(); // not shown in display as draw() is not called (and calling it explicitly does not work)
  String path = getPathToOrganizedImageFolders("Select folder with validation images");
  if(path!=null) {
    int [][] resultMatrix = classifyAllImagesInStructuredFolder(path,currentClassifier);
    setValidationResult(10, resultMatrix,currentClassifier.classificationNames);
    }

  switchButtonOn(1);  switchButtonOn(3);switchButtonOn(6);
  if(currentClassifierSaveable)switchButtonOn(2);
  switchButtonOn(4); switchButtonOn(41); switchButtonOn(5);

  needToUpdateDisplay=true;
  cursor(ARROW);
}

void executeAbout() {
    switchTextFieldOff(12);
    clearAllImageFields(); clearAllHistograms(); clearAllValidationResults();
    // status of all buttons stay the same
    //switchAllButtonsOff();
    setAboutField(11);
    //switchButtonOn(1);  switchButtonOn(3);
    switchButtonOff(6);
    //if(currentClassifierSaveable)switchButtonOn(2);
    //switchButtonOn(4); switchButtonOn(41); switchButtonOn(5);

    needToUpdateDisplay=true;

}



// A global flag that keeps track of whether there is a current classifier which the user can save
// - any newly learned classifier can be saved unless already saved
// - a classifier loaded from a file cannot be saved again (due to file name conventions).

boolean currentClassifierSaveable = false;

// A few helpers
void setCurrentClassifierTextField() {
  if(currentClassifier==null || currentClassifier.consistent!=1) setTextField(7,"<no current classifier>");
  else setTextField(7, currentClassifier.directoryName + "     ("+currentClassifier.timeStamp+")");}

void setCurrentClassifierErrorTextField(String s)
   {currentClassifier=null; currentClassifierSaveable = false; setTextField(7,s);}
   
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