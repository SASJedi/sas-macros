%macro filedate(fname,format);
   /***************************************************************************
    Created by Mark Jordan - http://go.sas.com/jedi
    This macro program (filedate.sas) should be placed in your AUTOCALL path.
   ***************************************************************************/
   %local fileref rc did n memname didc file dir FileDate type;
   %let type=NOTE;
   %if %superq(fname)= %then
      %do;
         %let type=ERROR;
         %put;
         %put &TYPE:  *&SYSMACRONAME ***************************************************;
         %put &type: (filedate) You must supply a fully qualified file name.;
         %put;

   %syntax:
         %PUT &TYPE:  *&SYSMACRONAME Documentation *************************************;
         %PUT &TYPE-;
         %PUT &TYPE-  Returns the date an external file was last modified;
         %PUT &TYPE-;
         %PUT &TYPE-  SYNTAX: %NRSTR(%FILEDATE%(fname<,format>%));
         %PUT &TYPE-     fname=fully qualified file name;
         %PUT &TYPE-     format=format for the date value returned;
         %PUT &TYPE-         Default: 5.;
         %PUT;
         %PUT &TYPE-  Examples:;
         %PUT &TYPE-  %NRSTR(%filename%(C:\temp\MyProgram.sas%));
         %PUT &TYPE-  %NRSTR(%filename%(/home/myID/myfile.csv,date9.%));
         %PUT;
         %PUT &TYPE-  *************************************************************;

         %RETURN;
      %end;
   %if %superq(fname)=? %then %goto syntax;

   %let file=%qscan(%superq(fname),-1,%str(\/));
   %if %length(&file)=%length(&fname) %then
      %let dir=.;
   %else %let dir=%qsubstr(%superq(fname),1,%eval(%length(&fname)-%length(&file)-1));
   /* Validate the directory */
   %let rc=%sysfunc(filename(fileref,&dir));
   %let did=%sysfunc(dopen(&fileref));
   %if &did=0 %then
      %do;
         ERROR
            %let type=ERROR;
         %put;
         %put &TYPE: (filedate) Directory %superq(dir) does not exist;
         %put &TYPE- Filename provided: %superq(fname);
         %put;
         %goto syntax;
      %end;

   %let rc=%sysfunc(dclose(&did));
   %let rc=%sysfunc(filename(fileref));
   /* Validate the filename */
   %if NOT %sysfunc(fileexist(%superq(fname))) %then
      %do;
         ERROR
            %let type=ERROR;
         %put;
         %put &TYPE: (filedate) File %superq(file) does not exist;
         %put &TYPE- Directory searched: %superq(dir);
         %put;
         %goto syntax;
      %end;
   /* Open file for output */
   %let rc=%sysfunc(filename(fileref,&fname));
   %let fid=%sysfunc(fopen(&fileref,i));
   %if &fid=0 %then
      %do;
         %put;
         %let type=ERROR;
         %put &TYPE: (filedate) File %superq(file) failed to open;
         %put &TYPE- Filename provided: %superq(fname);
         %put;
         %goto syntax;
      %end;
   %if &format= %then
      %let format=5.;
   %let FileDate=%sysfunc(datepart(
      %sysfunc(inputn(
      %sysfunc(finfo(&fid,Last Modified)),ANYDTDTM32.
      ))
      )
      ,&format
      );
   %let rc=%sysfunc(fclose(&fid));
   %let rc=%sysfunc(filename(fileref));
   %put &TYPE: &=fname &=FileDate;
   &Filedate
%mend filedate;