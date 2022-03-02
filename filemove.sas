%macro fileMove(fileName, sourcePath, targetPath,newFileName);
%local MsgType;
%let MsgType=NOTE;
%if %SUPERQ(fileName)= ? %then %do;
%Syntax:
   %put;
   %put &MsgType: &SYSMACRONAME documentation:;
   %put &MsgType- Purpose: Move a file from one directory to another;
   %put &MsgType- Syntax: %nrstr(%%)&SYSMACRONAME(fileName, sourcePath,targetPath<,newFileName>);
   %put &MsgType- fileName:    Name of the file to be copied;
   %put &MsgType- sourcePath:  path where the source file is located;
   %put &MsgType- targetPath:  path to which the file will be moved;
   %put &MsgType- newFileName: OPTIONAL: New name for the copied file;
   %put ;
   %put &MsgType- Examples:;
   %put &MsgType- %nrstr(%%)&SYSMACRONAME(abc.txt,c:\temp\source,c:\temp\target);
   %put &MsgType- %nrstr(%%)&SYSMACRONAME(old.csv,c:\temp\source,c:\temp\target,new.csv);
   %put ;
   %put &MsgType- Use ? to print documentation to the SAS log.;
   %put;
   %return;
%end; 
%if %superq(fileName)= %then %do; 
   %let MsgType=ERROR;
   %put;
   %put &MsgType: &SYSMACRONAME Error:;
   %put &MsgType- You must supply the name of the file to be copied.;
   %put;
   %goto Syntax; 
%end;
%if %superq(sourcePath)= %then %do; 
   %let MsgType=ERROR;
   %put;
   %put &MsgType: &SYSMACRONAME Error:;
   %put &MsgType- You must supply a source path value.;
   %put;
   %goto Syntax; 
%end;
%if %superq(targetPath)= %then %do; 
   %let MsgType=ERROR;
   %put;
   %put &MsgType: &SYSMACRONAME Error:;
   %put &MsgType- You must supply a target path value.;
   %put;
   %goto Syntax; 
%end;

/* forward slashes are compatible with both Windows and Linux */
%let sourcePath=%qsysfunc(translate(%superq(sourcePath),/,\));
%let targetPath=%qsysfunc(translate(%superq(targetPath),/,\));

/* Assign the filerefs */
%let filrf=source;
%let rc=%sysfunc(filename(filrf,%superq(sourcePath)/%superq(fileName)));
%if &rc ne 0 %then %do;
   %put %sysfunc(sysmsg());
   %return;
%end;

%let filrf=target;
%if %superq(newFileName)= %then %let newFileName=%superq(filename);
%let rc=%sysfunc(filename(filrf,%superq(targetPath)/%superq(newFileName)));
%if &rc ne 0 %then %do;
   %put %sysfunc(sysmsg());
   %let filrf=source;
   %let rc=%sysfunc(filename(filrf));
   %return;
%end;

/* Move the file */
%put;
%put NOTE: &SYSMACRONAME - Moving file:;
%put NOTE- SOURCE=%qsysfunc(pathname(source));
%put NOTE- TARGET=%qsysfunc(pathname(target));
%put;

/* Copy to the new location */
%let rc=%sysfunc(fcopy(source,target));
/* If the copy went well, delete the original file */
%if &rc ne 0 %then %put %sysfunc(sysmsg());
%else %do;
%let rc=%sysfunc(fdelete(source));
%end;

/* Clear the filerefs */
%let filrf=source;
%let rc=%sysfunc(filename(filrf));
%let filrf=target;
%let rc=%sysfunc(filename(filrf));
%mend;
