%Macro EndsWith(DSN,Suffix);
/******************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   Last Modified: 2020-06-16
   This macro program (fileattribs.sas) should be placed in your AUTOCALL path.
   Dependencies on other custom macros:
    - exist.sas
******************************************************************************/
   %local dsid varlist rc whr lib ds MSGTYPE;
   /* Self documentation */
   %if &DSN= %then
      %let DSN=&SYSLAST;
   %let MSGTYPE=NOTE;
   %if %superq(DSN)=? or %qupcase(%superq(DSN))=!HELP %then
      %do;
   %Syntax:
         %put;
         %PUT &MSGTYPE: *&SYSMACRONAME Documentation ********************************;
         %put;
         %PUT &MSGTYPE- SYNTAX: %NRSTR(%endswith%(DSN,Suffix%));
         %put;
         %PUT &MSGTYPE- DSN: Name of dataset containing variable names of interest;
         %PUT &MSGTYPE-      %NRSTR(Default is &SYSLAST);
         %PUT &MSGTYPE- Suffix: Text with which the variable names end (required);
         %PUT &MSGTYPE- Examples:;
         %PUT &MSGTYPE- Get names of variables that end with "ght" from sashelp.class:;
         %PUT &MSGTYPE-    %NRSTR(%%EndsWith%(sashelp.class,ght%));
         %put;
         %PUT &MSGTYPE- ***************************************************************;

         %return;
      %end;
   /* Parameter Validation */
   %if &suffix= %then
      %do;
         /* Suffix is required */
         %let MSGTYPE=ERROR;
         %PUT &MSGTYPE: *&SYSMACRONAME Error *****************************************;
         %PUT &MSGTYPE: You must specify a variable name suffix;
         %GoTo Syntax;
      %end;

   %let ds=%QSCAN(%QUPCASE(%SUPERQ(DSN)),2);
   %if &ds= %then
      %do;
         %let lib=WORK;
         %let ds=%QUPCASE(%SUPERQ(DSN));
      %end;
   %else %let lib=%qscan(%QUPCASE(&DSN),1);
   %if not (%exist(&lib..&ds)) %then
      %do;
         /* Specified data set does not exist */
         %let MSGTYPE=ERROR;
         %PUT &MSGTYPE: *&SYSMACRONAME Error *****************************************;
         %PUT &MSGTYPE: SAS data set &DSN does not exist.;
         %GoTo Syntax;
      %end;
   /* Open SASHELP.VCOLUMN subset for the desired dataset */
   %let whr=(WHERE=(LIBNAME="&lib" AND MEMNAME="&ds" AND UPCASE(NAME) like %STR(%')%nrstr(%%)%str(%QUPCASE(%SUPERQ(suffix))%')));
   %let dsid=%sysfunc(open(sashelp.vcolumn&whr));
   %if &dsid=0 %then
      %do;
         %let MSGTYPE=ERROR;
         %PUT &MSGTYPE: *&SYSMACRONAME Error *****************************************;
         %PUT &MSGTYPE: Could not retrieve variable names for &DSN from;
         %put &MSGTYPE- sashelp.vcolumn&whr;
         %PUT &MSGTYPE- &sysmsg;
         %GoTo EndMacro;
      %end;

   %let rc=0;
   /* Retrieve each variable name observation from SASHELP.VCOLUMN */
   /* and add it to the list of variables                          */
   %do %while (&rc=0);
      %let rc=%sysfunc(fetch(&dsid));
      %if &rc=0 %then
         %do;
            %let varlist=&varlist %sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,NAME))));
         %end;
   %end;
   /* Return the variable names to the input stack by resolving VARLIST */
   &varlist
      %Endmacro:
      /* Close SASHELP.VCOLUMN */
   %let rc=%sysfunc(close(&dsid));
%mend;