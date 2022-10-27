%macro copyfiles(srcdir, tgtdir, subdirs)/minoperator;
	%local nmem numfiles numdir thisext fileref msgtype;
	%let msgtype=NOTE;

/****** Begin self-documentation code ********/
	%if %superq(srcdir)=? %then
		%do;
%syntax:
			%let msgtype=NOTE;
		   %put %nrstr();
			%put &msgtype: * &SYSMACRONAME HELP *************************************;
		   %put %nrstr();
			%put &msgtype- Purpose: Copies files from one directory to another.;
			%put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(srcdir,tgtdir<,subdirs,ext>);
		   %put &msgtype- srcdir:  Full path to the source directory. Required.;
		   %put &msgtype- tgtdir:  Full path to the target directory. Required.;
		   %put &msgtype-          If the target does not exist, it will be created;
		   %put &msgtype- subdirs: Copy subdirectories too?;
		   %put &msgtype-          (Optional - YES|NO) Default is YES;
		   %put &msgtype- ext:     Space-delimited list of file extensions.;
		   %put &msgtype-          (Optional) Default is to copy all files.;
		   %put %nrstr();
		   %put &MSGTYPE:   &SYSMACRONAME does not require X command permissions, but the SAS Administrator;
		   %put &MSGTYPE-   can disable the functions required for this macro using LOCKDOWN mode.;
		   %put &MSGTYPE-   This macro uses the associated %nrstr(%%)copyfile macro to copy individual files.;
		   %put %nrstr();
	      %PUT &MSGTYPE-  Examples:;
		   %put &MSGTYPE-  Copy everything including subdirectories to a backup location:;
	      %PUT &MSGTYPE-  	   %NRSTR(%%)&sysmacroname(~/data/dir1,~/backups/dir1);
		   %put &MSGTYPE-  Copy everything to a backup location, ignore subdirectories:;
	      %PUT &MSGTYPE-       %NRSTR(%%)&sysmacroname(~/data/mySourceDir,~/data/myTargetDir,NO);
		   %put &MSGTYPE-  Copy only .sas and .csv files to a backup location, include subdirectories:;
	      %PUT &MSGTYPE-  		%NRSTR(%%)&sysmacroname(~/data/mySourceDir,~/data/myTargetDir,,sas csv);
	      %PUT &MSGTYPE-  *************************************************************;
		   %put %nrstr();
		   %return;
		%end; 
/****** End self-documentation code ********/

/****** Begin parameter validation code ********/
	%if %superq(srcdir)= %then
		%do;
			%let msgtype=ERROR;
			%put &msgtype: * &SYSMACRONAME ERROR ************************************;
			%put &msgtype: You must specify a source directory.;
			%put &msgtype: * &SYSMACRONAME ERROR ************************************;
			%goto syntax;
		%end;

	%if %superq(tgtdir)= %then
		%do;
			%let msgtype=ERROR;
			%put &msgtype: * &SYSMACRONAME ERROR ************************************;
			%put &msgtype: You must specify a target directory.;
			%put &msgtype: * &SYSMACRONAME ERROR ************************************;
			%goto syntax;
		%end;

	/* Set Defaults */
	%if %superq(subdirs)= %then %let subdirs=YES;
		%else %let subdirs=%qupcase(&subdirs);
	%if not (%superq(subdirs) in YES NO) %then
	%do;
		%let msgtype=ERROR;
		%put &msgtype: * &SYSMACRONAME ERROR ************************************;
		%put &msgtype: Acceptable values for subdirs is YES or NO. You specified %superq(subdirs).;
		%put &msgtype: * &SYSMACRONAME ERROR ************************************;
		%goto syntax;
	%end;

	/* Check for source directory */
	%let fileref=fromdir;
	%let rc=%sysfunc(filename(fileref,%superq(srcdir)));
   %let did=%sysfunc(dopen(%superq(fileref)));
	/* If source directory does not exist, error and exit.*/
   %if &did=0 %then 
	%do;
      %put ERROR: Source directory %qupcase(%superq(srcdir)) does not exist.;
      %goto Syntax;
   %end;

	/* Check for target directory */
   %let fileref=todir;
   %let rc=%sysfunc(filename(fileref,%superq(tgtdir)));
   %let did2=%sysfunc(dopen(%superq(fileref)));
   %let rc=%sysfunc(dclose(&did2));

	/* Target directory does not exist - try to create */
   %if &did2=0 %then 
	%do;
		%local newDir tgtPath;
  	 	%let newDir=%qscan(%superq(tgtdir),-1,%nrstr(\/));
		%let l=%eval(%length(%superq(tgtdir))-%length(%superq(newDir)));
	  	%let tgtPath=%qsubstr(%superq(tgtdir),1,&l);
	  	%let rc=%sysfunc(dcreate(%superq(newDir),%superq(tgtPath)));	
		/* Check for target directory again */
   	%let did2=%sysfunc(dopen(%superq(fileref)));
   	%let rc=%sysfunc(dclose(&did2));
		/* If target directory still does not exist, error and exit */
   	%if &did2=0 %then 
		%do;
      	%put ERROR: Target directory %qupcase(%superq(tgtdir)) could not be created.;
      	%put ERROR- Verify that the parent directory already exists.;
      	%goto Syntax;
	   %end;
   %end;
/****** End parameter validation code ********/

/****** Main processing begins here ********/
	%let numdir=0;
	%let numfiles=0;

   %let fileref=todir;
	%let rc=%sysfunc(filename(fileref,%superq(tgtdir)));
	%let nmem= %sysfunc(dnum(&did));
   %put NOTE: ***************************************;
   %put NOTE- &nmem items found in %superq(srcdir).;

   %do n=1 %to &nmem;
      %let memname=%qsysfunc(dread(&did,&n));
		/* If no extension, assume directory */
		%if %qscan(%superq(memname),-1,.)=%superq(memname) %then
			%do;
		      %let numdir=%eval(&numdir+1);
		      %local dir&numdir;
		      %let dir&numdir=%superq(memname);
	      	%put NOTE-  dir&numdir=%superq(dir&numdir);
			%end;
		/* Otherwise, it is a file */
		%else
			%do;
		      %let numfiles=%eval(&numfiles+1);
		      %local mem&numfiles;
		      %let mem&numfiles=%superq(memname);
	      	%put NOTE- mem&numfiles=%superq(mem&numfiles);
			%end;
   %end;

	/* Copy the files first */
   %put NOTE: Copying &numfiles files:;
   %do i=1 %to &numfiles;
		%copyfile(%superq(srcdir)/%superq(mem&i),%superq(tgtdir)/%superq(mem&i));
   %end;
   %put;

	/* If subdirectories are found, call this macro for each subdirectory */
	%if %superq(subdirs)=YES and &numdir > 0 %then 
		%do;
		   %put NOTE: Copying &numdir subfolders:;
		   %do i=1 %to &numdir;
				   %put NOTE- Copying subfolder %superq(srcdir)/%superq(dir&i) to %superq(tgtdir)/%superq(dir&i);
					/* Executing a direct macro call causes an endless loop, creating subdir within subdir infinitely */
					/* Using DOSUBL here avoids the over-iteration. */
					%let command=%nrstr(%%)copyfiles(%superq(srcdir)/%superq(dir&i),%superq(tgtdir)/%superq(dir&i));
				   %let rc=%sysfunc(dosubl(%superq(command)));
		   %end;
	   %end;
   %put;
   %let rc=%qsysfunc(dclose(%superq(did)));
   %put NOTE: ***************************************;
/****** End main processing ********/

/****** System cleanup and restoration ********/
	%let fileref=fromdir;
   %let rc=%qsysfunc(filename(fileref));
	%let fileref=todir;
   %let rc=%qsysfunc(filename(fileref));
%mend copyfiles;
