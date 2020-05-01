%macro fileexist(fname);
   %local fileref rc did n memname didc file dir FileDate type;
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   This macro program (fileexist.sas) should be placed in your AUTOCALL path.
 ***************************************************************************/
%let type=NOTE;
   %if %qupcase(%superq(fname))=!HELP 
   %then %do;
   %let type=NOTE;
%syntax:
   %PUT &TYPE:  *&SYSMACRONAME Documentation *******************************;
   %PUT &TYPE-;
   %PUT &TYPE-  Returns 1 if the external file exists, 0 if not;
   %PUT &TYPE-;
   %PUT &TYPE-  SYNTAX: %NRSTR(%%FILEEXIST%(fname%));
   %PUT &TYPE-     fname=fully qualified file name;
   %PUT ;
   %PUT &TYPE-  Example: ;
   %PUT &TYPE-  %NRSTR(%%filexist%(\\server\folder\MyFile.csv%));
   %PUT ;
   %PUT &TYPE-  *************************************************************;
   %RETURN;
%end;
   /* Validate the filename */
   %if %superq(fname)= %then %do;
    0
    %return;
   %end;
   %else %do; 
      %sysfunc(fileexist(%superq(fname))) 
   %end;
%mend fileexist;
