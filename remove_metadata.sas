%macro remove_metadata(dsn,attribs);
   /***************************************************************************
     Created by Mark Jordan: http://go.sas.com/jedi or Twitter @SASJedi
     This macro program (remove_metadata.sas) should be placed in your 
     AUTOCALL path
   ***************************************************************************/
   %let MSGTYPE=NOTE;
   %if %SUPERQ(dsn)= %then
      %do;
         %let MSGTYPE=ERROR;
         %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
         %PUT &MSGTYPE-  You must specify the name of the data set to be modified;
         %PUT;

   %syntax:
         %PUT;
         %PUT &MSGTYPE:  *&SYSMACRONAME Documentation *******************************;
         %put;
         %PUT &MSGTYPE-  SYNTAX: %NRSTR(%remove_metadata%(dsn,attribs%));
         %PUT &MSGTYPE-        DSN=data set to be modified;
         %PUT &MSGTYPE-    attribs=(optional) attributes to be modified, default is FIL;
         %PUT &MSGTYPE-            F=formats;
         %PUT &MSGTYPE-            I=informats;
         %PUT &MSGTYPE-            L=Labels;
         %PUT;
         %PUT &MSGTYPE-  Example:;
         %PUT &MSGTYPE-  Remove all formats, informats and labels;
         %PUT &MSGTYPE-  %NRSTR(%remove_metadata%(work.cars%));
         %PUT;
         %PUT &MSGTYPE-  Remove informats and labels only;
         %PUT &MSGTYPE-  %NRSTR(%remove_metadata%(work.cars,LI%));
         %PUT;
         %PUT &MSGTYPE-  Remove only labels;
         %PUT &MSGTYPE-  %NRSTR(%remove_metadata%(work.cars,L%));
         %PUT;
         %PUT;
         %PUT &MSGTYPE-  *************************************************************;

         %RETURN;
      %end;
   %if %superq(dsn)=? or %qupcase(%superq(dsn))=!HELP %then
      %goto Syntax;
   %if %superq(attribs)= %then
      %let attribs=FIL;
   %else %let attribs=%qupcase(%superq(attribs));
   %let lib=%scan(%superq(dsn),1);
   %if %superq(lib)=%superq(dsn) %then
      %do;
         %let lib=WORK;
      %end;
   %else
      %do;
         %let dsn=%scan(%superq(dsn),-1);
      %end;

   proc datasets library=&lib nolist;
      modify &dsn;
      %if %index(%superq(attribs),F) %then
         %do;
            attrib _all_ format=;
         %end;
      %if %index(%superq(attribs),I) %then
         %do;
            attrib _all_ informat=;
         %end;
      %if %index(%superq(attribs),L) %then
         %do;
            attrib _all_ label="";
         %end;
   run;

   quit;

%mend;