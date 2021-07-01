%macro charColLengths(dsn);
   %local lib i msgtype;
   %let msgtype=NOTE;
   %if %superq(dsn)= %then %do;
      %let msgtype=ERROR;
      %put &msgtype: You must specify a data set name;
      %put;
   %syntax:
      %put;
      %put &msgtype: &SYSMACRONAME macro help document:;
      %put &msgtype- Purpose: Shortens the lengths of all character columns;
      %put &msgtype-          in a table to fit largest actual value.;
      %put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(dsn);
      %put &msgtype- dsn:    Name of the dataset to modified.;
      %put;
      %put NOTE: &SYSMACRONAME cannot be used in-line - it generates code.;
      %put NOTE- Requires the %nrstr(%%)charcollength macro to work.;
      %put NOTE- Use ? to print these notes.;
      %put;
      %return;
   %end; 
   %if %qsubstr(%SUPERQ(dsn),1,1)=! or %superq(dsn)=? %then %goto syntax;
   %let lib=%qscan(%superq(dsn),1,.);
   %if %superq(dsn)=%superq(lib) %then %let lib="WORK";
   %let dsn=%qscan(%superq(dsn),-1,.);
   %let dsn=%qupcase(%superq(dsn));
   %let lib=%qupcase(%superq(lib));
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
   %charColLength(&lib..&dsn,&&name&i)
   %end;
%mend;
