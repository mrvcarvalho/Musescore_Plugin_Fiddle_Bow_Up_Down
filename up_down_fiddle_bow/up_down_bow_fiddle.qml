//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  ADD UP/DOWN BOW FOR FIDDLE
//
//  Copyright (C) 2023 Marvel Carvalho
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================
//stringsDownBow
//stringsUpBow 
//var markUP = newElement(SymId.stringsUpBow );
//var markDOWN = newElement(SymId.stringsDownBow);

import QtQuick 2.2
import MuseScore 3.0

MuseScore {
   version: "1.0"
   description: "ADD UP/DOWN BOW FOR FIDDLE"
   title: "Add Up Down Bow Notation"
   categoryCode: "composing-arranging-tools"
   thumbnailName: "up_down_bow_fiddle.png"

   // Small note name size is fraction of the full font size.
   property real fontSizeMini: 0.7;

   //--------------------------------------------------------------------------------------
   onRun: {
      curScore.startCmd()

      var cursor = curScore.newCursor();
      var startStaff;
      var endStaff;
      var endTick;
      var fullScore = false;
      cursor.rewind(1);
      if (!cursor.segment) { // no selection
         fullScore = true;
         startStaff = 0; // start with 1st staff
         endStaff  = curScore.nstaves - 1; // and end with last
      } else {
         startStaff = cursor.staffIdx;
         cursor.rewind(2);
         if (cursor.tick === 0) {
            // this happens when the selection includes
            // the last measure of the score.
            // rewind(2) goes behind the last segment (where
            // there's none) and sets tick=0
            endTick = curScore.lastSegment.tick + 1;
         } else {
            endTick = cursor.tick;
         }
         endStaff = cursor.staffIdx;
      }
      console.log(startStaff + " - " + endStaff + " - " + endTick)

      for (var staff = startStaff; staff <= endStaff; staff++) {

         cursor.rewind(1); // beginning of selection
         cursor.staffIdx = staff;

         var c = 0;  // ARCADA even=DOWN odd=UP

         if (fullScore)  // no selection
            cursor.rewind(0); // beginning of score

         while (cursor.segment && (fullScore || cursor.tick < endTick)) {

            if (cursor.element && (
                  cursor.element.type === Element.CHORD || 
                  cursor.element.type === Element.REST ||
                  cursor.element.type === Element.TIE  ||
                  cursor.element.type === Element.TIE_SEGMENT ||
                  cursor.element.type === Element.SLUR ||
                  cursor.element.type === Element.SLUR_SEGMENT
                  ) ) {
               var text = newElement(Element.STAFF_TEXT);      // Make a STAFF_TEXT

               if ((c%2)==0) {
                  console.log("DOWN");
                  text.text = "<font face='ScoreText'/><sym>stringsDownBow</sym>"+ text.text;
                  text.fontSize = 25;
                  
               } else {
                  console.log("UP");
                  text.text = "<font face='ScoreText'/><sym>stringsUpBow</sym>"+ text.text;
                  text.fontSize = 20;
               }
 
               //thisNoteTied = (cursor.element.notes[0].tieForward != null);
               //lastNoteTied = (cursor.element.notes[0].tieBack    != null);
               //text.color = "red";

               if (cursor.element.type === Element.CHORD ) {
                  if (cursor.element.notes[0].tieBack == null) { // NOT TIED
                     if (text.text) {
                        cursor.add(text);
                        c++;
                     }
                  }
               } else {
                  c=0;
               }
            } // end if CHORD
            cursor.next();
         } // end while segment
      } // end for staff

      curScore.endCmd()
      quit();
   } // end onRun
}
