%macro deletetree(dir);
	%local msgtype;
	%let msgtype=NOTE;

/****** Begin self-documentation code ********/
	%if %superq(dir)=? %then
		%do;
%syntax:
			%let msgtype=NOTE;
			%put %nrstr();
			%put &msgtype: * &SYSMACRONAME HELP *************************************;
			%put %nrstr();
			%put &msgtype- Purpose: Deletes a directory, including all files and subdirectories.;
			%put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(dir);
			%put &msgtype- dir:  Full path to the directory you want to delete. Required.;
			%put %nrstr();
			%put &MSGTYPE:	&SYSMACRONAME does not require X command permissions, but the SAS Administrator;
			%put &MSGTYPE-	can disable the functions required for this macro using LOCKDOWN mode.;
			%put &MSGTYPE-	This macro requires the following "helper" macros in order to work:;
			%put &MSGTYPE-	%nrstr(%%findfiles);
			%put &MSGTYPE-	%nrstr(%%translate);
			%put &MSGTYPE-	%nrstr(%%exist);
			%put &MSGTYPE-	%nrstr(%%fileattribs);
			%put %nrstr();
			%PUT &MSGTYPE-  Example:;
			%put &MSGTYPE-  Delete the PG1V2 including all files and subdirectories from your home directory:;
			%PUT &MSGTYPE-  		%NRSTR(%%)&sysmacroname(~/PG1V2);
			%PUT &MSGTYPE-  *************************************************************;
			%put %nrstr();
			%return;
		%end; 
/****** End self-documentation code ********/

/****** Begin parameter validation code ********/
	%if %superq(dir)= %then
		%do;
			%let msgtype=ERROR;
			%put &msgtype: * &SYSMACRONAME ERROR ************************************;
			%put &msgtype: You must specify the directory to be deleted.;
			%put &msgtype: * &SYSMACRONAME ERROR ************************************;
			%goto syntax;
		%end;

	/* Check that directory exists */
	%let fileref=fromdir;
	%let rc=%sysfunc(filename(fileref,%superq(dir)));
	%let did=%sysfunc(dopen(%superq(fileref)));

	/* If source directory does not exist, error and exit.*/
	%if &did=0 %then 
	%do;
		%let rc=%sysfunc(filename(fileref));
		%put ERROR: The specified directory %qupcase(%superq(dir)) does not exist.;
		%goto Syntax;
	%end;
	%else %do;
		%let rc=%sysfunc(dclose(&did));
		%let rc=%sysfunc(filename(fileref));
	%end;
/****** End parameter validation code ********/

/****** Main processing begins here ********/
/* Create a dataset of all files and folders in the structure */
%FindFiles(%superq(dir),,work.deleteMe)

%if %exist(work.deleteMe) %then %do;
	/* Add the top-level directory to the data */
	proc sql;
	insert into deleteme (path, filename)
		values('~',"%qscan(%superq(dir),-1,/\)");
	title "Files to be deleted";
	select * from deleteme;
	quit;
	title;

	/* Delete all files and create a data set with folder names and tree level */
	data folders;
		set work.deleteMe(keep=Path Filename Size);
		file=catx('/',path,filename);
		level=countc(file,'/')-1;
		if missing(size) then output;
		else do;
			 fname="axeme";
			 rc=filename(fname,file);
			 if rc = 0 and fexist(fname) then rc=fdelete(fname);
			 rc=filename(fname);
		end;
		keep file level;
	run;

	/* Sort by descending tree level so de delete the deepest folders first */
	proc sort data=folders;
		by descending level;
	run;

	/* Delete the folders */
	data _null_;
		set work.folders;
		 fname="axeme";
		 rc=filename(fname,file);
		 if rc = 0 and fexist(fname) then rc=fdelete(fname);
		 rc=filename(fname);
	run;
%end;
%else %do;
	data _null_;
		 fname="axeme";
		 rc=filename(fname,%tslit(&dir));
		 if rc = 0 and fexist(fname) then rc=fdelete(fname);
		 rc=filename(fname);
	run;
%end;
/* Clean up the system (hide the evidence :-) */
proc fedsql;
	drop table deleteme force;
	drop table folders force;
quit;
%mend deletetree;
