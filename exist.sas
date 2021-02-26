%macro exist(dsn) /minoperator;
%local MsgType;
%let MsgType=NOTE;
%if %superq(dsn)= %then %do; 
   %let MsgType=ERROR;
   %put;
   %put &MsgType: &SYSMACRONAME Error:;
   %put &MsgType- You must supply a dataset name.;
   %put;
   %goto Syntax; 
%end;
%if %SUPERQ(dsn)= ? %then %do;
%Syntax:
   %put;
   %put &MsgType: &SYSMACRONAME documentation:;
   %put &MsgType- Purpose: Check if a SAS data set exists;
   %put &MsgType- Syntax: %nrstr(%%)&SYSMACRONAME(dsn);
   %put &MsgType- dsn:    Name of the dataset;
   %put ;
   %put &MsgType- Example: %nrstr(%%)&SYSMACRONAME(sashelp.cars);;
   %put ;
   %put &MsgType- Use ? to print documentation to the SAS log.;
   %put;
   %return;
%end; 
%sysfunc(exist(&dsn))
%mend exist;
