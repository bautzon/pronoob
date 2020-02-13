
PImage downScaleToFit(PImage pic, int boundaryWidth, int boundaryHeight) {
  //WARNING MUST BE CALLED AFTER IMAGE IS PROCESSED
  //AS THE copy() FUNCTION MENTIONED IN REFERENCE DOES NOT WORK
  // - THUS ARGUMENT IS DESTROYED!!
  PImage picCopy = pic.get();
  if(picCopy.width<=boundaryWidth && picCopy.height<= boundaryHeight)
     return picCopy;
  if(picCopy.width>boundaryWidth)picCopy.resize(boundaryWidth,
                  picCopy.height*boundaryWidth/picCopy.width );
  if(picCopy.height>boundaryHeight)picCopy.resize(
                  picCopy.width*boundaryHeight/picCopy.height, boundaryHeight );
  return picCopy;
}

PImage downScaleInputImageIfNecessary(PImage pic) {
  if(!imageOK(pic)) return pic;
  if(!Downscale) return pic;
  return downScaleToFit(pic,ScaleTo,ScaleTo); }
  
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