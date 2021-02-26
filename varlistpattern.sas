%macro varListPattern(dsn, pattern, varType,runType);
/********************************************************************
By Bruno Mueller - 2017-08
Self-documentation and mode selection by Mark Jordan
Get a list of variable names from a data set,
that match a certain pattern.

Placeholder for pattern
"*", 0 - n characters
"?", 1 character
All other letters and numbers are used accordingly

Program uses these DATA Step functions:
OPEN, CLOSE, ATTRN, VARNAME, VARTYPE, PRXMATCH, GETOPTION

Benefits:
Can be used on any SAS data set
No SAS code is generated - can be used in-line
**********************************************************************/
%local dsid prxPattern prxMatch rc nVars varname i _varType varlist ls;

%let MSGTYPE=NOTE;
%if %sysevalf( %superq(dsn) = , boolean ) = 1 %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %PUT &MSGTYPE-  You must specify a data set name;
   %goto Syntax;
%end;
%if %qsubstr(%SUPERQ(dsn),1,1)=! or %superq(dsn)=? 
   %then %do;
   %PUT &MSGTYPE:  *&SYSMACRONAME Documentation *******************************;
%syntax: %put;
   %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&SYSMACRONAME%NRSTR(%(dsn,pattern,varType,runType%));
   %PUT &MSGTYPE-     DSN:     Data set name (Required);
   %PUT &MSGTYPE-     pattern: Pattern describing the desired names;
   %PUT &MSGTYPE-              (Optional - Default is ?*);
   %PUT &MSGTYPE-              Wildcard characters:;
   %PUT &MSGTYPE-                 * = 0 or more characters;
   %PUT &MSGTYPE-                 ? = Exactly one character;
   %PUT &MSGTYPE-     varType: A|C|N Variable type(s) (Optional - Default: All);
   %PUT &MSGTYPE-             (All, Char, Num);
   %PUT &MSGTYPE-     runType: P|D - Production/Debug (Optional- Default: P);
   %PUT &MSGTYPE-              Production - writes the variable list into your SAS code;
   %PUT &MSGTYPE-              Debug      - writes the variable list to your SAS log;
   %PUT ;
   %PUT &MSGTYPE-  Example:;
   %PUT &MSGTYPE-  %NRSTR(%%)&SYSMACRONAME%NRSTR(%(sashelp.mon1001,*9,N,D%));
   %PUT &MSGTYPE-  %NRSTR(%%)&SYSMACRONAME%NRSTR(%(sashelp.class,?e?%));
   %PUT &MSGTYPE-  *************************************************************;
   %PUT ;
   %RETURN;
%end;

/* If pattern not specified, get all variables */
%if %sysevalf( %superq(pattern) = , boolean ) = 1 or %superq(pattern)= %str(*)  %then %do;
  %let pattern=?*;
%end;

/* If variable type not specified, get all variable types */
%if %sysevalf( %superq(varType) = , boolean ) = 1 %then %let varType =CN;
%else %let varType=%qupcase(%superq(varType));
%if %superq(varType) =A %then %let varType =CN;

/* If incorrect variable type specification, throw ERROR */
%if not(%index(ACN,%superq(varType))) %then 
%do;
   %let MSGTYPE=ERROR;
   %put &MSGTYPE: (&sysmacroname) Invalid VARTYPE %superq(VARTYPE) ;
   %put &MSGTYPE- Valid VARTYPE is A(ll), C(har) or N(um);
   %goto Syntax;
%end;

/* If data set doesn't exist, throw ERROR */
%if %eval( %sysfunc( exist(&dsn, DATA) ) or %sysfunc( exist(&dsn, VIEW) ) ) = 0 %then 
%do;
   %let MSGTYPE=ERROR;
   %put &MSGTYPE: (&sysmacroname) &dsn does not exist;
   %RETURN;
%end;

/* Open the data set, find number of variables */
%let dsid = %sysfunc(open(&dsn));
%let nvars = %sysfunc( attrn(&dsid, NVARS) );

/* Get all of the variable names, keep those of interest */
%let prxPattern = %sysfunc( tranwrd(&pattern, *, .*) );
%let prxPattern = %sysfunc( tranwrd(&prxPattern, ?, .) );
%let prxPattern = %upcase(&prxPattern);

%do i = 1 %to &nvars;
   %let varname = %upcase(%sysfunc( varname(&dsid, &i) ));
   %let t_varType = %upcase(%sysfunc( vartype(&dsid, &i) ));
   %let prxMatch = %sysfunc(prxmatch(/^&prxPattern$/, &varname ));
   %if &prxMatch > 0 and %index(&varType, &t_varType) %then
      %let varlist = &varlist &varname;
%end;

/* Close the data set! */
%let dsid = %sysfunc( close(&dsid) );

/* If no variables of interest found, issue WARNING */
%if %sysevalf( %superq(Varlist) = , boolean ) = 1 %then 
   %put WARNING: (&sysmacroname) No variables matching your criteria were found in %superq(dsn).;
/* If in DEBUG mode, just write the list to the SAS log */
%else %if %superq(runType)=D %then 
%do;
   %put NOTE: (&sysmacroname) &=i &=dsn &=varname &=t_varType &=prxPattern &=prxMatch;
   %put NOTE- &=varlist;
%end;
/* Otherwise, in PRODUCTION mode - produce the list in-line with the SAS code */
%else %superq(varlist);
%mend;
