%macro VarNumList(dsn,cols);
%LOCAL DSID RC MSGTYPE VARNUM I ThisName NameList;
%LET MSGTYPE=NOTE;
%if %SUPERQ(DSN)= %then 
%do;
   %LET MSGTYPE=ERROR;
   %PUT &MSGTYPE: (&SYSMACRONAME) - Data set name required.;
   %PUT &MSGTYPE: (&SYSMACRONAME) - This macro creates a list of variable names you choose by column number.;
   %Syntax:
   %PUT;
   %PUT &MSGTYPE- Syntax: %NRSTR(%%)&SYSMACRONAME(DSN,cols);
   %PUT &MSGTYPE- DSN  - fully-qualified data set name (LIBREF.DATASET);
   %PUT &MSGTYPE- cols - a list of column numbers separated by spaces.;
   %PUT ;
   %PUT &MSGTYPE- This function uses OPEN to get a DSID for the data set named;
   %PUT;
   %PUT &MSGTYPE- Example: %NRSTR(%%)&SYSMACRONAME(sashelp.cars,1 2 5);
   %PUT;
   %GoTo Exit;
%end;
%if %SUPERQ(DSN)=? or %qupcase(%SUPERQ(DSN))=!HELP %then %goto Syntax;
%let DSN=%qupcase(%superq(dsn));
%if %superq(cols)= %then 
%do;
   %LET MSGTYPE=ERROR;
   %PUT &MSGTYPE: (&SYSMACRONAME) - You must list the column numbers of the variables you want to list.;
   %goto Syntax;
%end;

%let DSID=%sysfunc(open(&dsn));
%if &DSID=0 %then 
%do;
   %LET MSGTYPE=ERROR;
   %PUT &MSGTYPE: (&SYSMACRONAME) - &DSN does not exist.;
   %goto Syntax;
%end;

%do i=1 %to %sysfunc(countw(%superq(cols)));
   %let varnum=%qscan(%superq(cols),&i);
   %let ThisName=%sysfunc(varname(&dsid,&varnum));
   %if %superq(thisname) ne %then %do;
      %let NameList=&Namelist &ThisName;
   %end;
%end;
/* Do the deed */
&NameList

%Exit:
%if &DSID >0 %then %do;
   %let RC=%sysfunc(close(&dsid));
   %if &RC ne 0 %then %do;
      %PUT WARNING: (&SYSMACRONAME) When closing the data set, return code was &RC.;
      %PUT WARNING- %superq(DSN) may still be locked.;
   %end;
%end;
%mend;

