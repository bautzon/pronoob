
void saveClassifier(Classifier c, String fileName) {
  JSONArray teJa = c.te.toJSON();
  JSONArray classNamesJa = new JSONArray(); //warning docu of this fun. is unclear
  for(int i=0; i<c.classificationNames.length; i++) classNamesJa.setString(i,c.classificationNames[i]);
  
  JSONObject classifierJo = new JSONObject();
  classifierJo.setJSONArray("Trees",teJa);
  classifierJo.setString("Training directory",c.directoryName);
  classifierJo.setString("Timestamp",c.timeStamp);
  classifierJo.setInt("Subwindow size", c.subwindowSize);
  classifierJo.setInt("Subwindows per image", c.subwindowsPerImage);
  classifierJo.setInt("Minimum samples per leaf", c.minimumSamplesPerLeaf);
  classifierJo.setInt("Number of splits tested", c.numberOfSplitsTested);
  classifierJo.setInt("Number of trees", c.numberOfTrees);
  classifierJo.setJSONArray("Class names",classNamesJa);
  
  saveJSONObject(classifierJo,fileName);
  
  // A SMALL COMPLAINT:
  // It is not possible to control the textual order in which the fields appear
  // - it ends up placing all the paramaters in the END OF THE FILE which is not so fun, because them
  //   the user has to scroll all the way down to the bottom to inspect the parameters (after the extremely long "Trees"
}


Classifier loadClassifier(String fileName) {
  File f = new File(fileName);
  if(!f.exists() || f.isDirectory() || !fileName.endsWith(".classif"))
     {setCurrentClassifierErrorTextField("Attemt to read classifier with wrong file extension: "+fileName); return null;}

  JSONObject classifierJo;
  try{classifierJo = loadJSONObject(fileName);}
  catch(Exception e){println("Invalid classifier file "+fileName);
        setCurrentClassifierErrorTextField("Corrupt classifier file: "+fileName);
        Classifier error = new Classifier(); error.consistent=-1;
        return error;}

  // assume created as above... error checking to be added

  Classifier result = new Classifier();
  result.directoryName = classifierJo.getString("Training directory");
  result.timeStamp = classifierJo.getString("Timestamp");
  result.subwindowsPerImage = classifierJo.getInt("Subwindows per image");
  result.subwindowSize = classifierJo.getInt("Subwindow size");
  result.minimumSamplesPerLeaf = classifierJo.getInt("Minimum samples per leaf");
  result.numberOfSplitsTested = classifierJo.getInt("Number of splits tested");
  result.numberOfTrees = classifierJo.getInt("Number of trees");
  result.consistent=1;
  JSONArray classNamesJa = classifierJo.getJSONArray("Class names");
  result.classificationNames = classNamesJa.getStringArray();

  JSONArray teJa = classifierJo.getJSONArray("Trees");
  int noOfSubtrees = teJa.size(); // should be identical to numberOfTrees
  result.te = new TreeEnsemble(noOfSubtrees);
  for(int i=0; i<noOfSubtrees; i++) result.te.trees[i] = toTree(teJa.getJSONObject(i));
  return result;
}
  
  
Tree toTree(JSONObject tJo) {
  String type = tJo.getString("type");
  Tree result;
  if(type.equals("leaf")) result = new LeafTree(tJo.getInt("class"));
  else // type.equals("choice")
    result = new ChoiceTree(tJo.getInt("testPixel"), tJo.getInt("testHSV"), tJo.getFloat("splitValue"),
                            toTree(tJo.getJSONObject("left")), toTree(tJo.getJSONObject("right")));

  return result;
}

String makeFreshClassifierFileName(String intialPath) {
  intialPath = removePossibleDotClassifFileExtension(intialPath);
  String name = intialPath + ".classif";
  File f = new File(name); if(!f.exists()) return name;
  int i=1; name = intialPath + "_"+i+ ".classif"; f = new File(name);
  while(f.exists()) {i++; name = intialPath + "_"+i+ ".classif"; f = new File(name);}
  return name;}
  
String removePossibleDotClassifFileExtension(String s) {
  if(s.endsWith(".classif")) return s.substring(0,s.length()-8);
  return s;
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