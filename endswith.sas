%Macro EndsWith(DSN,Suffix);
   %local dsid varlist rc whr lib ds;
   /* Self documentation */
   %if (&DSN= and &Suffix= ) %then %let DSN=!HELP;
   %if %qupcase(%qsubstr(&DSN,1,5))=!HELP 
   %then %do;
      %PUT NOTE: EndsWith Macro Help ********************************;
   %put;
   %PUT NOTE- SYNTAX: %NRSTR(%endswith%(DSN,Suffix%));
   %put;
   %PUT NOTE- DSN: Name of dataset containing vairable names of interest;
   %PUT NOTE-      %NRSTR(Default is &SYSLAST);
   %put;
   %PUT NOTE- Suffix: Text with which the variable names end (required);
   %PUT NOTE- Examples: ;
   %PUT NOTE- Get names of variables that end with "ght" from sashelp.class: ;
   %PUT NOTE-    %NRSTR(%%EndsWith%(sashelp.class,ght%));
   %put;
   %PUT NOTE: End EndsWith Macro Help ****************************;
   %return;
   %end;
   /* Parameter Validation */
   %if &suffix= %then %do;
      /* Suffix is required */
      %PUT ERROR: You must specify a variable name suffix;
      %PUT ERROR- SYNTAX: %NRSTR(%endswith%(DSN,Suffix%));
      %GoTo EndMacro;
   %end;
   %if &DSN= %then %let DSN=&SYSLAST;
   %let ds=%QSCAN(%QUPCASE(%SUPERQ(DSN)),2);
   %if &ds= %then %do;
      %let lib=WORK;
      %let ds=%QUPCASE(%SUPERQ(DSN));
   %end;
   %else %let lib=%qscan(%QUPCASE(&DSN),1);
   %if not %sysfunc(exist(&lib..&ds)) %then %do;
      /* Specified data set does not exist */
      %PUT ERROR: Dataset &DSN does not exist.;
      %PUT ERROR- SYNTAX: %NRSTR(%endswith%(DSN,Suffix%));
      %GoTo EndMacro;
   %end;
   /* Open SASHELP.VCOLUMN subset for the desired dataset */
   %let whr=(WHERE=(LIBNAME="&lib" AND MEMNAME="&ds" AND UPCASE(NAME) like %STR(%')%nrstr(%%)%str(%QUPCASE(%SUPERQ(suffix))%')));
   %let dsid=%sysfunc(open(sashelp.vcolumn&whr));
   %if &dsid=0 %then %do;
      %PUT ERROR: Could not retrieve variable names for &DSN from;
      %put ERROR- sashelp.vcolumn&whr;
      %PUT ERROR- &sysmsg;
      %GoTo EndMacro;
   %end;
   %let rc=0;
   /* Retrieve each variable name observation from SASHELP.VCOLUMN */
   /* and add it to the list of variables                          */
   %do %while (&rc=0);
      %let rc=%sysfunc(fetch(&dsid));
      %if &rc=0 %then %do;
         %let varlist=&varlist %sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,NAME))));
      %end;
   %end;
   /* Return the variable names to the input stack by resolving VARLIST */
   &varlist
%Endmacro:
   /* Close SASHELP.VCOLUMN */
   %let rc=%sysfunc(close(&dsid)); 
%mend;
