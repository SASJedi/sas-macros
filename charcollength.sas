%macro charColLength(dsn, col);
   %local length msgtype;
   %let msgtype=NOTE;
   %if %superq(dsn)= %then %do;
      %let msgtype=ERROR;
      %put &msgtype: You must specify a data set name;
      %put;
   %syntax:
      %put &msgtype: &SYSMACRONAME macro help document:;
      %put &msgtype- Purpose: Shortens a specified character column to fit the largest actual value.;
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
   %if %superq(col)= %then %do;
      %let msgtype=ERROR;
      %put &msgtype: You must specify a column name;
      %put;
      %goto syntax;
   %end;
proc sql noprint;
select max(length(&col)) 
   into :Length
  from &dsn
;
quit;

proc sql;
alter table &dsn
  modify &col char(&length);
quit;
%mend;
