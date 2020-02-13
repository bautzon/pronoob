// DEFAULT values constants for learning

final int DefaultSubwindowSize = 16;
final int DefaultSubwindowsPerImage = 100;

final int DefaultSubwindowsPerImageForClassification = 100;

final int DefaultMinimumSamplesPerLeaf = 8; // called n_min in algorithm
final int DefaultNumberOfSplitsTested = 8;  // - - - K
final int DefaultNumberOfTrees = 100;        // -  -  - M  //used for learning only; does not affect the use of classifiers

final boolean Downscale = false;

final int ScaleTo = 500; // large images scaled down so width and hight <= ScaleTo

final int maxMilisecsToWaitForCamera = 20000; // Used by "What am I" command.


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