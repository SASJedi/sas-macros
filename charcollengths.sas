%macro charColLengths(dsn);
   %local lib i msgtype;
   %let msgtype=NOTE;
   %if %superq(dsn)= %then %do;
      %let msgtype=ERROR;
      %put &msgtype: You must specify a data set name;
      %put;
   %syntax:
      %put &msgtype: &SYSMACRONAME macro help document:;
      %put &msgtype- Purpose: Shortens all character columns in a table to fit largest actual value.;
      %put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(dsn);
      %put &msgtype- dsn:    Name of the dataset to modified. Required.;
      %put;
      %put NOTE:   &SYSMACRONAME cannot be used in-line - it generates code.;
      %put NOTE-   Use ? or !HELP to print these notes.;
      %return;
   %end; 
   %if %superq(dsn)=%str(?) %then %goto syntax;
   %let dsn=%qupcase(%superq(dsn));
   %if %superq(dsn)=%str(!HELP) %then %goto syntax;
   %let lib=%qscan(%superq(dsn),1,.);
   %if %superq(dsn)=%superq(lib) %then %let lib="WORK";
   %let dsn=%qscan(%superq(dsn),-1,.);
   proc sql noprint;
   select name 
     into: name1- 
     from dictionary.columns
     where libname="&lib"
       and memname="&dsn"
       and type ='char' 
   ;
   quit;
   %do i=1 %to &sqlobs;
   %charVarLength(&lib..&dsn,&&name&i)
   %end;
%mend;
