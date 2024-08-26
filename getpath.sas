%macro getPath(help);
%local MsgType fileName myPath;
%let MsgType=NOTE;
%if %SUPERQ(help) ne %then %do;
%Syntax:
   %put &MsgType- ;
   %put &MsgType: &SYSMACRONAME documentation:;
   %put &MsgType- Purpose: Returns the file system path to the current program file.;
   %put &MsgType- Syntax: %nrstr(%%)&SYSMACRONAME(help);
   %put &MsgType- help:  Any value here prints syntax to the log;
   %put &MsgType- ;
   %put &MsgType- Example: %nrstr(%%)&SYSMACRONAME();;
   %put &MsgType- ;
   %return;
%end; 
/* Do the work */
%let fileName =  %scan(&_sasprogramfile,-1,'/\');
%let myPath = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));
&myPath
%mend getPath;