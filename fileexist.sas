%macro fileexist(fname);
   /***************************************************************************
    Created by Mark Jordan - http://go.sas.com/jedi
    This macro program (fileexist.sas) should be placed in your AUTOCALL path.
   ***************************************************************************/
   %let type=NOTE;
   %if %superq(fname)= %then
      %do;
         0
         %let type=ERROR;
         %PUT &TYPE:  *&SYSMACRONAME *********************************************;
         %PUT &TYPE-  You must specify a file name.;
         %PUT;

   %syntax:
         %PUT &TYPE:  *&SYSMACRONAME Documentation *******************************;
         %PUT &TYPE-;
         %PUT &TYPE-  Returns 1 if the external file exists, 0 if not;
         %PUT &TYPE-;
         %PUT &TYPE-  SYNTAX: %NRSTR(%%FILEEXIST%(fname%));
         %PUT &TYPE-     fname=fully qualified file name;
         %PUT;
         %PUT &TYPE-  Example:;
         %PUT &TYPE-  %NRSTR(%%filexist%(/home/myid/myfile.csv%));
         %PUT;
         %PUT &TYPE-  *************************************************************;

         %RETURN;
      %end;
   %if %superq(fname)=? %then %goto syntax;

   %sysfunc(fileexist(%superq(fname)))
%mend fileexist;