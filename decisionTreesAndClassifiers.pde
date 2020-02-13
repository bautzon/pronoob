// the array classificationNames should be identified before the following classes and methods are used
class Tree {
  int classify(Subwindow sw) { // "declare" virtual method
    println("Method 'classify' should not be called for non-specialized tree");
    return -1; } 
  JSONObject toJSON() { // "declare" virtual method
    println("Method 'toJSON' should not be called for non-specialized tree");
    return null; } 
    
}

class ChoiceTree extends Tree {
  int testPixel; // 0 .. subwindowSize^2-1
  int testHSV; // 0,1,2; 0: H, 1: S, 2: V
  float splitValue;
  Tree leftTree; Tree rightTree;

  ChoiceTree(int tp, int thsv, float sv) {testPixel=tp;testHSV=thsv;splitValue=sv;}
  ChoiceTree(int tp, int thsv, float sv, Tree left, Tree right)
      {testPixel=tp;testHSV=thsv;splitValue=sv;leftTree=left;rightTree=right;}

  int classify(Subwindow sw) {
    return (sw.selectAttribute(testPixel,testHSV)<splitValue)
           ? leftTree.classify(sw)
           :  rightTree.classify(sw);    
  }

  JSONObject toJSON() {
    JSONObject result = new JSONObject();
    result.setString("type", "choice");
    result.setInt("testPixel", testPixel);
    result.setInt("testHSV", testHSV);
    result.setFloat("splitValue", splitValue);
    JSONObject leftTreeJSON = leftTree.toJSON();
    result.setJSONObject("left", leftTreeJSON);
    JSONObject rightTreeJSON = rightTree.toJSON();
    result.setJSONObject("right", rightTreeJSON);
    
    return result; } 

}

class LeafTree extends Tree {
  int classification;
  LeafTree(int c) {classification=c;}

  int classify(Subwindow sw) {
    return classification; }
  
  JSONObject toJSON() {
    JSONObject result = new JSONObject();
    result.setString("type", "leaf");
    result.setInt("class", classification);
    return result; } 
    

}

class TreeEnsemble {
  Tree [] trees;
  TreeEnsemble(Subwindow [] sws,
                            int minimumSamplesPerLeaf, int numberOfSplitsTested, int numberOfTrees, String [] classificationNames) {
     trees = learnExtraTreeSet(sws,
                            minimumSamplesPerLeaf, numberOfSplitsTested, numberOfTrees, classificationNames);}
  
  TreeEnsemble(int n) {trees = new Tree[n];} // constructor used when classifier read in from file NOT GOOD NOW

  int [] classify(Subwindow sw, int subwindowSize, int subwindowsPerImage, String [] classificationNames) {
    if(classificationNames.length==0) return new int[0];
    int [] votes =  new int [classificationNames.length];
    for(int i=0;i<classificationNames.length;i++)votes[i]=0; //redundant
//    println("trees.length="+trees.length + " votes.length="+votes.length);
    for(int j=0;j<trees.length;j++) votes[trees[j].classify(sw)]++;
    return votes; }
    
  int [] classify(PImage img, int subwindowSize, int subwindowsPerImage, String [] classificationNames) {
    Subwindow [] sws = randomSubwindows(img, subwindowSize, subwindowsPerImage);
    int [] totalVotes  =  new int [classificationNames.length];
    for(int i=0;i<classificationNames.length;i++)totalVotes[i]=0; //redundant
    for(int i=0; i<sws.length; i++) {
      int [] votes = classify(sws[i], subwindowSize, subwindowsPerImage, classificationNames);
      for(int j=0;j<classificationNames.length;j++) totalVotes[j]=+ votes[j]; }
    return totalVotes; }
  
  JSONArray toJSON() {
    JSONArray result = new JSONArray();
    result = new JSONArray();
    for(int i=0;i<trees.length;i++) result.setJSONObject(i, trees[i].toJSON());
    return result;
  }
}

class Classifier {
  // History data:
  String directoryName; // with which this classifier was trained
  String timeStamp; 
  // parameters with which this classifier was trained
  int subwindowSize;
  int subwindowsPerImage;
  int minimumSamplesPerLeaf; // called n_min in algorithm
  int numberOfSplitsTested;  // - - - K
  int numberOfTrees;       // -  -  - M  //used for learning only; does not affect the use of classifiers
//  boolean consistent; // false if reading in or learning does not lead to anything;
          // perhaps make it into an int or string to hole error message.
  int consistent; // 1: ok, 0: user cancelled from-file, -1 a selection that went wrong
  String [] classificationNames;  // integers used for classes; this array holds names
  String fileName = null;
  TreeEnsemble te;
  
  // constructors
  //  0. create an empty one
  Classifier() {;}
  //  1. for reading from file
  Classifier(int fromFile) {  // UGLY CODE: THE ARGUMENT IS IGNORED BUT INCLUDED to distinguish from the above :/ 
    fileName = getFileNameFromUser("Select classifier file",ClassifierFile); println("Got filename: "+fileName);
    if(fileName==null)  {consistent=0;return;}
    Classifier newClassifier = loadClassifier(fileName); // WE SHOULD CHECK VALIDITY OF RESULT!!
    println("Read in: "+fileName+", consistent="+newClassifier.consistent);
    if(newClassifier==null || newClassifier.consistent!=1) consistent=-1;
    else {
      directoryName = newClassifier.directoryName;
      timeStamp = newClassifier.timeStamp;
      directoryName = newClassifier.directoryName;
      subwindowSize = newClassifier.subwindowSize;
      subwindowsPerImage = newClassifier.subwindowsPerImage;
      minimumSamplesPerLeaf = newClassifier.minimumSamplesPerLeaf;
      numberOfSplitsTested = newClassifier.numberOfSplitsTested;
      numberOfTrees = newClassifier.numberOfTrees;
      te = newClassifier.te;
      consistent = 1; // 
      classificationNames = newClassifier.classificationNames; }
  }
  //  2. for learning from directory which will be given by user
  Classifier(int subwindowSizeIn, int subwindowsPerImageIn,
             int minimumSamplesPerLeafIn, int numberOfSplitsTestedIn, int numberOfTreesIn) {
      subwindowSize = subwindowSizeIn;
      subwindowsPerImage = subwindowsPerImageIn;
      minimumSamplesPerLeaf = minimumSamplesPerLeafIn;
      numberOfSplitsTested = numberOfSplitsTestedIn;
      numberOfTrees = numberOfTreesIn;
      directoryName = getPathToOrganizedImageFolders("Select folder with training images");
      fileName=directoryName; // --- ugly code
      if(directoryName==null){consistent=0;return;} // i.e. user pressed cancel
      Subwindow [] subwindowsForTraining = getSubwindowsForTraining(directoryName, subwindowSize,  subwindowsPerImage);
      if(subwindowsForTraining==null || subwindowsForTraining.length==0) {consistent=-1;return;}
      classificationNames = transferClassificationNames; // WARNING: side result of above function transferred throug global variable transferClassificationNames
      te = new TreeEnsemble(subwindowsForTraining,
                            minimumSamplesPerLeaf, numberOfSplitsTested, numberOfTrees, classificationNames);
      consistent=1;
      timeStamp = day()+"-"+monthAsString()+"-"+year()+" "+(hour()<10 ? "0": "")+hour()+":"+ (minute()<10 ? "0": "") +minute()+":"+ (second()<10 ? "0": "")+second();
   }

 int [] classify(PImage img) { //returns an array of votes
    return te.classify(img, subwindowSize,  DefaultSubwindowsPerImageForClassification, classificationNames); }
}

static final int FROM_FILE = 117; // see "ugly code above!
static final String[] monthsAbbrev = {"jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"};

String monthAsString() {int m = month(); return monthsAbbrev[m-1];}



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