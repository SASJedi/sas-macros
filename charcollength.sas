%macro charColLength(dsn, col);
   %local length msgtype;
   %let msgtype=NOTE;
   %if %superq(dsn)= %then %do;
      %let msgtype=ERROR;
      %put &msgtype: You must specify a data set name;
      %put;
   %syntax:
      %put &msgtype: &SYSMACRONAME macro help document:;
      %put &msgtype- Purpose: Shortens a specified character column;
      %put &msgtype-          to fit the largest actual value.;
      %put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(dsn);
      %put &msgtype- dsn:    Name of the dataset to modified.;
      %put;
      %put NOTE:   &SYSMACRONAME cannot be used in-line - it generates code.;
      %put NOTE-   Use ? to print these notes.;
      %return;
   %end; 
   %if %qsubstr(%SUPERQ(dsn),1,1)=! or %superq(dsn)=? %then %goto syntax;
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
