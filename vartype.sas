%macro vartype(dsn,var);
	/* Setup */
	%local MsgType dsid varnum position;
	%let MsgType=NOTE;
	
	/* Self-documentation */
	%if %SUPERQ(dsn)= ? %then %do;
	%Syntax:
	   %put;
	   %put &MsgType: &SYSMACRONAME documentation:;
	   %put &MsgType- Purpose: Check the type of a variable  in the specified dataset;
	   %put &MsgType- Syntax: %nrstr(%%)&SYSMACRONAME(dsn,var);
	   %put &MsgType- dsn:    Name of the dataset;
	   %put &MsgType- var:    Name of the variable;
	   %put ;
	   %put &MsgType- Example: %nrstr(%%)&SYSMACRONAME(sashelp.cars,MSRP);;
	   %put ;
	   %put &MsgType- Use ? to print documentation to the SAS log.;
	   %put;
	   %if %superq(dsn) ne and %superq(var) ne %then goto exit;
	   %return;
	%end; 
	
	/* Parameter validation */
	/* Is dataset specified? */
	%if %superq(dsn)= %then %do; 
	   %let MsgType=ERROR;
	   %put;
	   %put &MsgType: &SYSMACRONAME Error:;
	   %put &MsgType- You must supply a dataset name.;
	   %put;
		errorNoDatasetName
	   %goto Syntax; 
	%end;
	
	/* Is variable name specified? */
	%if %superq(var)= %then %do; 
	   %let MsgType=ERROR;
	   %put;
	   %put &MsgType: &SYSMACRONAME Error:;
	   %put &MsgType- You must supply a variable name.;
	   %put;
		errorNoVariableName
	   %goto Syntax; 
	%end;
	
   /* Open the specified dataset */
   %let dsid=%sysfunc(open(&dsn));

   /* If dataset won't open, return error */
   %if &dsid=0 %then %do;
      errorDataSet
      %put ERROR: Cannot open dataset: %upcase(&dsn).;
      %return;
   %end;

   /* If Variable not specified, return error */
   %if &var=  %then %do;
      errorNoVariablespecified
      %put WARNING: Missing VAR parameter;
      %goto exit;
   %end;

   /* If the variable name is not a valid, return error */
   %if %sysfunc(nvalid(&var))=0 %then %do;
      errorInvalidVariableName
      %put ERROR: Invalid variable name: %upcase(&var).;
      %goto exit;
   %end;

   /* Find position or the specified variable */   
   %let position=%sysfunc(varnum(&dsid,&var));

   /* If variable not found, return error */
   %if &position=0 %then %do;
      errorVariableNotExist
      %put ERROR: Variable %upcase(&var) not in %upcase(&dsn).;
      %goto exit;
   %end;
   
   /* All good, return variable type (N)umeric or (C)haracter */
   %sysfunc(vartype(&dsid,&position))

    /* Exit gracefully */
   %exit: %let dsid=%sysfunc(close(&dsid));

%mend vartype;
