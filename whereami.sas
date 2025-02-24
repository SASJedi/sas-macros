%macro whereAmI(help);
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   Last Modified: 2025-02-04
   This macro program (whereami.sas) should be placed in your AUTOCALL path.
   Dependencies on other custom macros:
    - compress.sas
    - translate.sas
 ***************************************************************************/
%local curfile curdir;
%let MsgType=NOTE;
%if %superq(help)=?  %then 
   %do;
      %PUT &MsgType-;
      %PUT &MsgType:  *&SYSMACRONAME Documentation *******************************;
      %PUT &MsgType-;
%syntax:
      %PUT &MsgType-  Returns the path to the currently executing SAS program.;
      %PUT &MsgType-  If the path cannot be determined, returns an error message.;
      %PUT &MsgType-;
      %PUT &MsgType-  SYNTAX: %NRSTR(%%)&sysmacroname(<help>);
      %PUT &MsgType-     help= Optional: use ? to get help in the log;
      %PUT &MsgType-;
      %PUT &MsgType-  Examples: ;
      %PUT &MsgType-  %NRSTR(%%)&sysmacroname(?);
      %PUT &MsgType-  %NRSTR(%%put %%)&sysmacroname()%str(;);
      %PUT &MsgType-;
      %PUT &MsgType-  *************************************************************;
      %PUT &MsgType-  All back slashes are converted to forward slashes in the path;
      %PUT &MsgType-  text for cross-platform compatibilty. Windows accepts either ;
      %PUT &MsgType-  type of slash, but Linux and UNIX accept only forward slashes.;
      %PUT &MsgType-  *************************************************************;
      %PUT &MsgType-;
      %RETURN;
   %end;

   %if %sysfunc(getoption(sysin)) ne %then 
      %do;
         /* Batch Execution */
         %LET curfile = %sysfunc(getoption(sysin));
      %end;
   %else %if %sysfunc(sysexist(SAS_EXECFILEPATH)) %then 
      /* Interactive Execution - Windowing System*/
      %LET curfile = %sysget(SAS_EXECFILEPATH);
   %else %if %sysfunc(symexist(_CLIENTAPP)) %then %do; 
         %if %compress(&_CLIENTAPP,,ksn)=SAS Enterprise Guide  
         /* SAS Studio */
         or %compress(&_CLIENTAPP,,ksn)=SAS Studio %then 
         /* SAS Studio */
         %let curfile=&_SASPROGRAMFILE;
      %end;
   %else %if %sysfunc(sysexist(SAS_EXECFILEPATH)) %then 
      /* Interactive Execution - Windowing System*/
      %LET curfile = %sysget(SAS_EXECFILEPATH);

   %if %superq(curfile)= %then 
      %do;
         %put ERROR: Could not obtain file name.;
         ERROR: Could not obtain file name.
         %return;
      %end;
   %if %qscan(%superq(curfile),1,/\)=%superq(curfile) %then
      %do;
         %put ERROR: Program file not yet saved.;
         %put ERROR- Could not obtain file name.;
         ERROR: Program file not yet saved.
         %return;
      %end;
   
   %let curfile=%translate(%superq(curfile),/,\);
   %let curpath=%qsubstr(%superq(curfile),1,%sysevalf(%sysfunc(find(%superq(curfile),/,-99999))-1));
   %superq(curpath)
%mend whereAmI;
