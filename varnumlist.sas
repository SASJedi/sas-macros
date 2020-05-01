%macro VarNumList(dsn,cols);
%LOCAL DSID RC MSGTYPE VARNUM I VARLIST;
%if %SUPERQ(DSN)=!HELP %then 
%do;
   %LET MSGTYPE=NOTE;
   %PUT &MSGTYPE: (&SYSMACRONAME) - This macro creates a list of variable names you choose by column number.;
   %Syntax:
   %PUT;
   %PUT &MSGTYPE- Syntax: %NRSTR(%%)VARLIST(DSN,cols);
   %PUT &MSGTYPE- DSN  - fully-qualified data set name (LIBREF.DATASET);
   %PUT &MSGTYPE- cols - a list of column numbers.;
   %PUT ;
   %PUT &MSGTYPE- This function uses OPEN to get a DSID for the data set named;
   %PUT;
   %PUT &MSGTYPE- Example: %NRSTR(%%)VarList(sashelp.cars,1 2 5);
   %PUT;
   %GoTo Exit;
%end;
%let DSN=%qupcase(%superq(dsn));
%if %SUPERQ(DSN)= %then 
%do;
   %LET MSGTYPE=ERROR;
   %PUT &MSGTYPE: (&SYSMACRONAME) - Data set name required.;
   %goto Syntax;
%end;
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
%let i=1;
%let varnum=%qscan(%superq(cols),&i);
%do %while (&varnum ne );
   %let varlist=&varlist %sysfunc(varname(&dsid,&varnum));
   %let i=%EVAL(&i+1);
   %let varnum=%qscan(%superq(cols),&i);
%end;
/* Do the deed */
&varlist

%Exit:
%if &DSID >0 %then %do;
   %let RC=%sysfunc(close(&dsid));
   %if &RC ne 0 %then %do;
      %PUT WARNING: (&SYSMACRONAME) When closing the data set, return code was &RC.;
      %PUT WARNING- %superq(DSN) may still be locked.;
   %end;
%end;
%mend;

