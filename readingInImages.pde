
// global variable for transfering data (!) 
String selectedTrainingDirectory;

String getPathToOrganizedImageFolders(String text) {
  getPathToTrainingDataFinished = false;
  selectFolder(text,"getSelectedTrainingDirectory");
  // busy waiting for answer:
  waitUntilGetTrainingDataFinished();
  return selectedTrainingDirectory;
}

boolean getPathToTrainingDataFinished = false;

void waitUntilGetTrainingDataFinished() {
  while(!getPathToTrainingDataFinished) 
     try {Thread.sleep(100);} // miliseconds
     catch(InterruptedException ex) {Thread.currentThread().interrupt();}
}

void getSelectedTrainingDirectory (File selection) {
  selectedTrainingDirectory = (selection == null) ? null : selection.getAbsolutePath();
  getPathToTrainingDataFinished = true;
}
 

// the following code for getting a file name fom sue is placed here since it is copy-paste-modify of the above

// global variable for transfering data (!) 
String FileNameFromUser;

// even worse, yet another global variable for tranaferring almost the same data
String attemptedFileNameFromUser;
boolean fileExtensionError=false;
String getFileNameFromUser(String title, int type) {
  fileExtensionError=false;
  getFileNameFromUserFinished = false;
  selectInput(title,"getFileNameFromUser");
  // busy waiting for answer:
  waitUntilGetFileNameFromUserFinished();
  if(type==ImageFile && FileNameFromUser!=null && !hasAllowedImageFileSuffix(FileNameFromUser))
     {println("Cannot recognize "+FileNameFromUser+" as image file ");
      attemptedFileNameFromUser = FileNameFromUser;
      fileExtensionError = true;
      FileNameFromUser=null;
      }
  else if(type==ClassifierFile && FileNameFromUser!=null && !hasAllowedClassifierSuffix(FileNameFromUser))
     {println("Cannot recognize "+FileNameFromUser+" as classifier file ");
      attemptedFileNameFromUser = FileNameFromUser;
      fileExtensionError = true;
      FileNameFromUser=null;}   
  return FileNameFromUser;
}

boolean getFileNameFromUserFinished = false;

void waitUntilGetFileNameFromUserFinished() {
  while(!getFileNameFromUserFinished) 
     try {Thread.sleep(100);} // miliseconds
     catch(InterruptedException ex) {Thread.currentThread().interrupt();}
}

void getFileNameFromUser (File selection) {
  FileNameFromUser = (selection == null) ? null : selection.getAbsolutePath();
  getFileNameFromUserFinished = true;
}





// Now, reading in image files and making subwindows
// WARNING: global variable for transferring side result of getSubwindowsForTraining below
String [] transferClassificationNames;
 

Subwindow [] getSubwindowsForTraining(String pathToTrainingData, int subwindowSize, int subwindowsPerImage) {
try{  
  Subwindow [] result = new Subwindow[0];
  String [] classificationNamesBuffer = new String [10000]; int noOfClassifications = 0;

//  if(selectedTrainingDirectory==null){println("No training data selected"); return null;}
  
  File trainingDataFolder = new File(selectedTrainingDirectory);
  File[] listOfCategoryFolders = trainingDataFolder.listFiles();
  if(listOfCategoryFolders==null || listOfCategoryFolders.length==0)
    {println("No category sub-folders in selected folder "+pathToTrainingData);return null;}
  println("Extracting subwindows...");
  for (int i = 0; i < listOfCategoryFolders.length; i++) {
      if (listOfCategoryFolders[i].isDirectory()) { // assume a category folder; otherwise it is ignored
         String CategoryName = listOfCategoryFolders[i].getName();
         println("  Class "+CategoryName);
         classificationNamesBuffer[noOfClassifications] = CategoryName; noOfClassifications++;
         File categoryFolder = new File(listOfCategoryFolders[i].getPath());
         File[] listOfImageFiles = categoryFolder.listFiles();
         for (int j=0; j<listOfImageFiles.length; j++) {
           if(listOfImageFiles[j].isFile() && !listOfImageFiles[j].isHidden()
              && hasAllowedImageFileSuffix(listOfImageFiles[j].getName() ) )  {
             println("    "+listOfImageFiles[j].getName());
             // add exception handling in the following
             String path = listOfImageFiles[j].getPath();
          //   println("**** **** "+path);
             PImage p = downScaleInputImageIfNecessary(loadImage(path));
             result = concatSubwindowArrays(result, randomSubwindows(p,noOfClassifications-1, subwindowSize, subwindowsPerImage ) ); 
             }
         } // for each possible image
      } 
    }// end for each category folder
  
 if(noOfClassifications==0)
    {println("No category sub-folders in selected folder "+pathToTrainingData);return null;}

  transferClassificationNames = new String [noOfClassifications];
  for(int k=0;k<noOfClassifications;k++)transferClassificationNames[k]=classificationNamesBuffer[k];
  return result;
}catch(Exception e){println("Training directory not of required format"); return null;}
}



// the following used for busy waiting - necessary due to insane use of threads in Processing

final int ImageFile = 1;

boolean hasAllowedImageFileSuffix(String fn) {
  // list of suffixes for files that loadImage() can understand
  if(fn.endsWith(".gif")) return true;
  if(fn.endsWith(".jpg")) return true;
  if(fn.endsWith(".tga")) return true;
  if(fn.endsWith(".png")) return true;
  if(fn.endsWith(".GIF")) return true;
  if(fn.endsWith(".JPG")) return true;
  if(fn.endsWith(".TGA")) return true;
  if(fn.endsWith(".PNG")) return true;
  return false; }  

final int ClassifierFile = 2;

boolean hasAllowedClassifierSuffix(String fn) {
  // list of suffixes for files that loadImage() can understand
  if(fn.endsWith(".classif")) return true;
  return false; }  


Subwindow [] concatSubwindowArrays(Subwindow [] a, Subwindow [] b){
   int aLen = a.length;
   int bLen = b.length;
   Subwindow[] c= new Subwindow[aLen+bLen];
   System.arraycopy(a, 0, c, 0, aLen);
   System.arraycopy(b, 0, c, aLen, bLen);
   return c; 
} 



int [][] classifyAllImagesInStructuredFolder(String path,Classifier c) {
  int nc=c.classificationNames.length;
  int [][] result = new int[nc][nc];
  //perhaps redundant, but prefer it anyhow
  for(int n=0;n<nc;n++)for(int m=0;m<nc;m++)result[n][m]=0;
  
  //start try-stuff here:
        File validationDataFolder = new File(path);
        File[] listOfCategoryFolders = validationDataFolder.listFiles();
        if(listOfCategoryFolders==null || listOfCategoryFolders.length==0)
          {println("No category sub-folders in selected folder "+validationDataFolder);return null;}
         println("classifying images...");
         for (int i = 0; i < listOfCategoryFolders.length; i++) {
             if (listOfCategoryFolders[i].isDirectory()) { // assume a category folder; otherwise it is ignored
                String CategoryName = listOfCategoryFolders[i].getName();
                println("  Class "+CategoryName);
                int classForSubdir=-1;
                for(int a=0;a<nc;a++)if(CategoryName.equals(c.classificationNames[a]))classForSubdir=a;
                //HER TESTE AT CLASS FINDES classificationNamesBuffer[noOfClassifications] = CategoryName; noOfClassifications++;
                File categoryFolder = new File(listOfCategoryFolders[i].getPath());
                File[] listOfImageFiles = categoryFolder.listFiles();
                for (int j=0; j<listOfImageFiles.length; j++) {
                  if(listOfImageFiles[j].isFile() && !listOfImageFiles[j].isHidden()
                     && hasAllowedImageFileSuffix(listOfImageFiles[j].getName() ) )  {
                    println("    "+listOfImageFiles[j].getName());
                    String imgPath = listOfImageFiles[j].getPath();
                  //   println("**** **** "+imgPath);
                    PImage img = downScaleInputImageIfNecessary(loadImage(imgPath));
                    if(imageOK(img)) {
                      int [] votes = c.classify(img);
                      //which class scored highest votes?
                      int maxVotes = 0; int predictedClass=-1;
                      for(int k=0;k<votes.length;k++)if(votes[k]>maxVotes){maxVotes=votes[k];predictedClass=k;}
                      result[classForSubdir][predictedClass]++; }
                    else {println("Corrupt image file ignored: "+imgPath);}
                  }
                 }
                }  // for each possible image 
           }// end for each category folder
  return result;
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