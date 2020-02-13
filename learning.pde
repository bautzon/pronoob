
Tree learnExtraTree(Subwindow [] sws,
                           int minimumSamplesPerLeaf, int numberOfSplitsTested, String [] classificationNames) { 
  // anomaly length = 0 can occure in very very rare cases

  if(sws.length==0) return new LeafTree(0);
  if(sws.length < minimumSamplesPerLeaf || allSameCategory(sws)) return new LeafTree(majorityCategory(sws, classificationNames));
  
  // test a number of random splits and take the one with least penalty
  int bestSplitPix = 1;
  int bestsplitRSV = 1;
  float bestSplitVal = 0.5;
  int smallestPenalty = 2147483647 ;
  for(int i=0; i<numberOfSplitsTested; i++) {
      int splitPix = int(random(0,sws[0].content.length));
      int splitRSV = int(random(0,3));
      float splitVal = random(minAttributeVal(sws,splitPix,bestsplitRSV), maxAttributeVal(sws,splitPix,splitRSV));
      int thisPenalty = splitPenalty(sws, splitPix, splitRSV /*0,1,2*/, splitVal, classificationNames);
     //////// println("Candidate splitPix="+splitPix+" splitRSV="+splitRSV+" splitVal="+splitVal);
     //////// println("penalty = "+thisPenalty);
      if(thisPenalty<smallestPenalty) {
        bestSplitPix=splitPix; bestsplitRSV=splitRSV; bestSplitVal=splitVal;
        smallestPenalty = thisPenalty;} }

   SplittedIntoTwoSubwindowsArrays sws12 = new SplittedIntoTwoSubwindowsArrays(sws, bestSplitPix, bestsplitRSV, bestSplitVal);
   
   // the unlikely case that the best split sends all subwindows into same half; will be the case if all images have identical colour!
   if(sws12.left.length==0 || sws12.right.length==0) return new LeafTree(majorityCategory(sws, classificationNames));
   
   return new ChoiceTree(bestSplitPix, bestsplitRSV, bestSplitVal,
                         learnExtraTree(sws12.left,
                                        minimumSamplesPerLeaf, numberOfSplitsTested, classificationNames),
                         learnExtraTree(sws12.right,
                                        minimumSamplesPerLeaf, numberOfSplitsTested, classificationNames));
}


//tree learnExtraTree(subwindow [] sws) {
//  return mkTestTree();}

Tree [] learnExtraTreeSet(Subwindow [] sws,
                            int minimumSamplesPerLeaf, int numberOfSplitsTested, int numberOfTrees, String [] classificationNames) {

  Tree [] result = new Tree [numberOfTrees];
  for(int i=0; i<numberOfTrees; i++) {
     result[i] = learnExtraTree(sws, minimumSamplesPerLeaf, numberOfSplitsTested, classificationNames);
     print("."); }
  println();
  return result;
}

Tree mkTestTree() {
 // classificationNames = new String [3];
 // classificationNames[0]="white";
 // classificationNames[1]="black";
 // classificationNames[2]="red";
  ChoiceTree result = new ChoiceTree(/*pixel*/ 1, /*hsv=s*/ 1, 0.5);
  ChoiceTree treeleft = new ChoiceTree(/*pixel*/ 1, /*hsv=v*/ 2, 0.5);
  result.leftTree = treeleft;
  treeleft.leftTree = new LeafTree(/*classification=black*/ 1);
  treeleft.rightTree = new LeafTree(/*classification=white*/ 0);
  result.rightTree = new LeafTree(/*classification=red*/ 2);
  return result;
} 


float minAttributeVal(Subwindow[] subs, int splitPix, int splitRSV) {
  float result = 2;
  for(int i=0;i<subs.length;i++) result = min(result, subs[i].selectAttribute(splitPix,splitRSV) );
  return result; } 

float maxAttributeVal(Subwindow[] subs, int splitPix, int splitRSV) {
  float result = 0;
  for(int i=0;i<subs.length;i++) result = max(result, subs[i].selectAttribute(splitPix,splitRSV) );
  return result; } 

// Testing quality of a split:
// an adhoc construction to replace the the score function from Geurts et al, Extremely Randomized Trees

// The ideal split is 0 penalty, and each step away from that gives a penalty

// ideal: a given category is entirely on one side of the splitVal
// penalty for each category: min( falls-to-the-left, falls-to-the-right)
// -- however, if all data are either to left of either to right, we give very high penalty
// ----- NOT INCLUDED: is not a problem: wasting some space an computation, but not a problem in accuracy 


int splitPenalty(Subwindow[] subs, int splitPix, int splitRSV /*0,1,2*/, float splitVal, String [] classificationNames) {
  int [] fallsToTheLeft = new int [classificationNames.length];
  int [] fallsToTheRight = new int [classificationNames.length];
    for(int n=0;n<classificationNames.length;n++) {fallsToTheLeft[n]=0; fallsToTheRight[n]=0;}
  int totalLeft=0; int totalRight=0;
  for(int i=0; i<subs.length; i++)
    if(subs[i].selectAttribute(splitPix,splitRSV)<splitVal)
       {fallsToTheLeft[subs[i].classNumber]++;totalLeft++;} else {fallsToTheRight[subs[i].classNumber]++; totalRight++;}
  int result = 0;
  // penalty for classes not completely categorized
  for(int j=0; j<classificationNames.length; j++)
    result=+ min(fallsToTheLeft[j], fallsToTheRight[j]);
  // totalLeft and totalRight not used in clever way
  if(totalLeft==0 || totalRight==0)  return 2147483647;
  ////////println("splitPenalty = "+result);
  return result;
}

int majorityCategory(Subwindow[] subs, String [] classificationNames) {
    int [] counts = new int [classificationNames.length];
    for(int n=0;n<classificationNames.length;n++) counts[n]=0;
    for(int i=0; i<subs.length; i++) counts[subs[i].classNumber]++;
    int result = 0; int max=0;
    for(int k=0;k<classificationNames.length;k++)
      if(counts[k]>max){max=counts[k];result=k;}
    return result; }
   
// to return result of splitting

class SplittedIntoTwoSubwindowsArrays {Subwindow[] left; Subwindow[] right;
 SplittedIntoTwoSubwindowsArrays(Subwindow[] subs, int splitPix, int splitRSV /*0,1,2*/, float splitVal)
   {// println("splittedIntoTwoSubwindowsArrays( <"+subs.length+">, "+splitPix+", "+splitRSV+", "+splitVal+")");

    Subwindow[] subsLeftPreliminary = new Subwindow[subs.length]; int nleft=0;
    Subwindow[] subsRightPreliminary = new Subwindow[subs.length]; int nright=0;
    for(int i=0; i < subs.length; i++)
      if(subs[i].selectAttribute(splitPix,splitRSV)<splitVal)
        {subsLeftPreliminary[nleft]=subs[i];nleft++;}
      else
        {subsRightPreliminary[nright]=subs[i];nright++;}
    left = new Subwindow[nleft];
    for(int j=0; j<nleft; j++) left[j]=subsLeftPreliminary[j];
    right = new Subwindow[nright];
    for(int k=0; k<nright; k++) right[k]=subsRightPreliminary[k];
    // println("split into " + nleft + " + " + nright + " subwindows");
   }
}

boolean allSameCategory(Subwindow[] subs) {
  ////////println("allSameCategory( <"+subs.length+"> )");
  int cat = subs[0].classNumber;
  for(int i=0;i<subs.length;i++) if(subs[i].classNumber!=cat) return false;
  return true; }
  
  
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