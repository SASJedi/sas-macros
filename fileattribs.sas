%macro fileattribs(filename)/minoperator;
   /******************************************************************************
     Created by Mark Jordan - http://go.sas.com/jedi
     Last Modified: 2020-06-8
     This macro program (fileattribs.sas) should be placed in your AUTOCALL path.
     Dependencies on other custom macros:
      - translate.sas
   ******************************************************************************/
   %local rc did fid fidc type thisfile response;
   %let type=NOTE;
   %if %superq(filename)= %then
      %do;
         %let type=ERROR;
         %PUT &TYPE:  *&SYSMACRONAME Error ***************************************;
         %put &TYPE: (&SYSMACRONAME) Fully-qualified file name required.;
         %nrstr(ERROR)
   %syntax:
         %PUT;
         %PUT &TYPE:  *&SYSMACRONAME Documentation *******************************;
         %PUT &TYPE-  SYNTAX: %NRSTR(%fileattribs%(filename%));
         %PUT &TYPE-     filename=fully qualified filename;
         %PUT &TYPE-     Use ? for syntax help;
         %PUT &TYPE-;
         %PUT &TYPE-  Returns:;
         %PUT &TYPE-  ERROR if an error occurred;
         %PUT &TYPE-  DIR if a directory is specified;
         %PUT &TYPE-  byte size|created datetime|modified datetime if a file is specified.;
         %PUT &TYPE-;
         %PUT &TYPE-  Example:;
         %PUT &TYPE-  %NRSTR(%%fileattribs%(c:\no_such_folder%));
         %PUT &TYPE-  returns ERROR;
         %PUT &TYPE-  %NRSTR(%%fileattribs%(c:\temp%));
         %PUT &TYPE-  returns DIR;
         %PUT &TYPE-  %NRSTR(%%fileattribs%(c:\temp\test.csv%));
         %PUT &TYPE-  returns 255|16JUN2020:00:00:00|16JUN2020:00:00:00;
         %PUT &TYPE-  *************************************************************;
         %PUT;

         %RETURN;
      %end;
   %if %superq(filename)=? %then %goto Syntax;

   %let filename=%translate(%superq(filename),/,\);
   %let rc=%sysfunc(filename(thisfile,&filename));
   %if &rc = 0 %then
      %do;
         %let did=%sysfunc(dopen(&thisfile));
         %if &did %then
            %do;
               %let rc=%sysfunc(dclose(&did));
               %let rc=%sysfunc(filename(thisfile));
               %nrstr(DIR)
                  %return;
            %end;
      %end;

   %let rc=%sysfunc(filename(thisfile,&filename));
   %if &rc ^= 0 %then
      %do;
         %let type=ERROR;
         %put &TYPE: (&SYSMACRONAME) Unable to assign fileref to %superq(filename).;
         %nrstr(ERROR)
            %goto syntax;
      %end;

%openFile:
   %let fid=%sysfunc(fopen(&thisfile));
   %if &fid=0 %then
      %do;
         %let type=ERROR;
         %put &TYPE: (&SYSMACRONAME) Unable to open %superq(filename).;
         %nrstr(ERROR)
            %goto syntax;
      %end;

   %let response=%qsysfunc(finfo(&fid,%nrstr(File Size %(bytes%))))|%qsysfunc(finfo(&fid,Create Time))|%qsysfunc(finfo(&fid,Last Modified));

   %superq(response)
   %let fidc=%sysfunc(fclose(&fid));
   %let rc=%sysfunc(filename(thisfile));
%mend FileAttribs;