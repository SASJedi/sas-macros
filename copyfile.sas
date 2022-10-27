%macro copyfile(src, tgt);
	%let msgtype=NOTE;
/****** Begin self-documentation code ********/
	%if %superq(src)=? %then
		%do;
%syntax:
			%let msgtype=NOTE;
			%put %nrstr();
			%put &msgtype: * &SYSMACRONAME HELP *************************************;
			%put %nrstr();
			%put &msgtype- Purpose: Copies a source file to another location.;
			%put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(src,tgt);
			%put &msgtype- src:  Full path to the source file. Required.;
			%put &msgtype- tgt:  Full path to the target file. Required.;
			%put %nrstr();
			%put &MSGTYPE:	&SYSMACRONAME does not require X command permissions, but the SAS Administrator;
			%put &MSGTYPE-	can disable the functions required for this macro using LOCKDOWN mode.;
			%put %nrstr();
			%put &MSGTYPE-  Example:;
			%put &MSGTYPE-		%NRSTR(%%)&sysmacroname(~/dir1/myfile.sas,~/dir2/newname.sas);
			%put &MSGTYPE-  *************************************************************;
			%put %nrstr();
			%return;
		%end; 
/****** End self-documentation code ********/

/****** Begin parameter validation code ********/
	%if %superq(src)= %then
		%do;
			%let msgtype=ERROR;
			%put &msgtype: * &SYSMACRONAME ERROR ************************************;
			%put &msgtype: You must specify a source file.;
			%put &msgtype: * &SYSMACRONAME ERROR ************************************;
			%goto syntax;
		%end;

	%if %superq(tgt)= %then
		%do;
			%let msgtype=ERROR;
			%put &msgtype: * &SYSMACRONAME ERROR ************************************;
			%put &msgtype: You must specify a target file.;
			%put &msgtype: * &SYSMACRONAME ERROR ************************************;
			%goto syntax;
		%end;
/****** End parameter validation code ********/

/****** Main processing begins here ********/
	/* Copy the file */
	/* Assign fileref to source and verify it exists */
	%let fileref=copyfrom;
	%let rc=%sysfunc(filename(fileref,%superq(src),,recfm=n));
	%if not(&rc=0) %then 
	%do;
		%put ERROR: Source file %superq(src) does not exist.;
		%put ERROR- &=rc &=sysmsg;
		%goto Syntax;
	%end;
	/* Assign fileref to target */
	%let fileref=copyto;
	%let rc=%sysfunc(filename(fileref,%superq(tgt),,recfm=n));
	/* Copy source to target */
	%let rc=%sysfunc(fcopy(copyfrom,copyto));
	/* Clear filerefs */
	%let fileref=copyfrom;
	%let rc=%sysfunc(filename(fileref));
	%let fileref=copyto;
	%let rc=%sysfunc(filename(fileref));
	%put NOTE- Copied  %superq(src) to %superq(tgt);
/****** End main processing ********/

/****** System cleanup and restoration ********/
	%let fileref=fromdir;
	%let rc=%qsysfunc(filename(fileref));
	%let fileref=todir;
	%let rc=%qsysfunc(filename(fileref));
%mend copyfile;
