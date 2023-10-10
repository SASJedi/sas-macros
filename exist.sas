%macro exist(memname,memtype)/minoperator mindelimiter='|';
	/* Setup */
	%local MsgType dsid memtypenum position;
	%let MsgType=NOTE;
	
	/* Self-documentation */
	%if %SUPERQ(memname)= ? %then %do;
	%Syntax:
	   %put &MsgType- ;
	   %put &MsgType: &SYSMACRONAME documentation:;
	   %put &MsgType- ;
	   %put &MsgType- Purpose: Check that a dataset exists.;
	   %put &MsgType- ;
	   %put &MsgType- Syntax: %nrstr(%%)&SYSMACRONAME(memname<,memtype>);
	   %put &MsgType- ;
	   %put &MsgType- memname:    Name of the dataset or other library member;
	   %put &MsgType- memtype:    OPTIONAL - Type (DATA|CATALOG|ITEMSTOR|MDDB|VIEW);
	   %put &MsgType-                        default is DATA;
	   %put &MsgType- ;
	   %put &MsgType- Returns:;
	   %put &MsgType- 1 - Dataset or member exists.;
	   %put &MsgType- 0 - Dataset or member does not exist.;
	   %put &MsgType- . - An error occurred during processing.;
	   %put &MsgType- ;
	   %put &MsgType- Examples: %nrstr(%%)&SYSMACRONAME(sashelp.cars);
	   %put &MsgType-           %nrstr(%%)&SYSMACRONAME(sashelp.vmacro,VIEW);
	   %put &MsgType-           %nrstr(%%)&SYSMACRONAME(work.sasmacr,CATALOG);
	   %put &MsgType- ;
	   %put &MsgType- Use ? to print documentation to the SAS log.;
	   %put &MsgType- ;
	   %return;
	%end; 
	
	/* Set memtype default */
	%if %superq(memtype)= %then %let memtype=DATA;
	%let memtype=%qupcase(%superq(memtype));

	/* Parameter validation */
	/* Is dataset specified? */
	%if %superq(memname)= %then %do; 
	   %let MsgType=ERROR;
	   %put;
	   %put &MsgType: &SYSMACRONAME Error:;
	   %put &MsgType- You must supply a dataset or library member name.;
	   %put;
		.
	   %goto Syntax; 
	%end;

	/* Is memtype specified? */
	%if not(%superq(memtype) in CATALOG|DATA|ITEMSTOR|MDDB|VIEW) %then %do; 
	   %let MsgType=ERROR;
	   %put;
	   %put &MsgType: &SYSMACRONAME Error:;
	   %put &MsgType- %superq(memtype) is not a valid member type.;
	   %put &MsgType- Leave blank for DATA, or specify CATALOG, ITEMSTOR, MDDB, or VIEW.;
	   %put;
		.
	   %goto Syntax; 
	%end;
	
	/* Do the work */
   %sysfunc(exist(&memname,&memtype))

%mend exist;
