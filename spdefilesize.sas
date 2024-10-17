%macro spdeFileSize(libref,dsn);
%local MsgType;
%let MsgType=NOTE;
%if %SUPERQ(source)= ? %then %do;
%Syntax:
   %put &MsgType- ;
   %put &MsgType: &SYSMACRONAME documentation:;
   %put &MsgType- Purpose: For an SPDE library dataset, fined the filesize for each;
   %put &MsgType-          individual sub-file, and the overall total size;
   %put &MsgType- ;
   %put &MsgType- Syntax: %nrstr(%%)&SYSMACRONAME(libref,dsn);
   %put &MsgType- libref: Libref of the SPDE library;
   %put &MsgType- dsn:    Name of the dataset in the SPDE library;
   %put &MsgType- ;
   %put &MsgType- Example: %nrstr(%%)&SYSMACRONAME(spdelib,myTable);
   %put &MsgType- Result:  ;
   %put &MsgType- ;
   %put &MsgType- |----------------------------------------------------------|;
   %put &MsgType- |File                                    |File size (bytes)|;
   %put &MsgType- |----------------------------------------------------------|;
   %put &MsgType- |/home/myID/spde1/test.dpf.a86.2.22.spds9|       98,572,032|;
   %put &MsgType- |/home/myID/spde2/test.dpf.a86.0.22.spds9|      134,217,216|;
   %put &MsgType- |/home/myID/spde3/test.dpf.a86.1.22.spds9|      134,217,216|;
   %put &MsgType- |Total for all segments:                 |      367,006,464|;
   %put &MsgType- |----------------------------------------------------------|;
   %put &MsgType- ;
   %put &MsgType- Use ? to print this documentation to the SAS log.;
   %put &MsgType- ;
   %return;
%end; 
%else %if %superq(libref)= %then %do; 
   %let MsgType=ERROR;
   %put;
   %put &MsgType: &SYSMACRONAME Error:;
   %put &MsgType- You must supply the libref of the SPDE library.;
   %put;
   %goto Syntax; 
%end;
%else %if %superq(dsn)= %then %do; 
   %let MsgType=ERROR;
   %put;
   %put &MsgType: &SYSMACRONAME Error:;
   %put &MsgType- You must supply the name of the dataset in the SPDE library.;
   %put;
   %goto Syntax; 
%end;

%if %exist(work.files) %then 
%do;
	proc delete data=files; run;
%end;

%if %exist(work.spde_dir) %then 
%do;
	proc delete data=spde_dir; run;
%end;

/* Get information about the SPDE library file locations */
ods output Directory=work.spde_dir; 
proc contents data=&libref.._all_ nods;
run;
ods output close;
proc sql noprint;
   select compress(cValue1,"'")
   	into :paths
   from work.spde_dir
	where label1="Datapath"
;
quit;
/* %put NOTE: %superq(paths); */

/* Work through the SPDE data directories to get file names */
%let i=1;
%do %until (&thisPath=);
	%let thisPath=%qscan(%superq(paths),&i,%str( ));
	%if not (&thisPath=) %then 
	%do; 
		%PUT NOTE: &=I &=thisPath;
		%findfiles(%superq(thisPath),,work.files,N);
   %end;
	%let i=%sysevalf(&i+1);
%end;

/* Summarize the data from e */
proc sql;
create table work.file_size as
select cats(Path,Filename) as File
	   ,Size format=comma32. label='File size (bytes)' as FileSize
	from work.files
	where lowcase(Filename) like %tslit(%qlowcase(&dsn..%nrstr(%%)))
union all
select "Total for all segments:" as File
	   ,sum(Size) format=comma32. label='File size (bytes)' as FileSize
	from work.files
	where lowcase(Filename) like %tslit(%qlowcase(&dsn..%nrstr(%%)))
;
title "File Size Report for &libref..&dsn";
select * from work.file_size;
quit;
proc delete data=files; run;
proc delete data=spde_dir; run;
%mend spdeFileSize;
