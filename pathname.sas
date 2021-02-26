%macro pathname(ref,mod);
/********************************************************************
 PATHNAME macro - by Mark Jordan 
********************************************************************/
%local MSGTYPE path engine;
%let MSGTYPE=NOTE;

%if %superq(ref)=? %then %do;
%Syntax:
   %put;
   %put &MSGTYPE: &SYSMACRONAME macro help document:;
   %put &MSGTYPE- Purpose: Returns system path info for a LIBREF or FILEREF;
   %put &MSGTYPE- Syntax: %nrstr(%%)&SYSMACRONAME(ref<,mod>);
   %put &MSGTYPE-    ref: Required - a valid LIBREF or FILEREF.;
   %put &MSGTYPE-    mod: Optional - L to specify LIBREF, F to specify FILEREF.;
   %put &MSGTYPE- Use ? to print these notes.;
   %put;
   %put &MSGTYPE- Example:;
   %put &MSGTYPE- %nrstr(%%)&SYSMACRONAME(WORK);
   %put;
   %return;
%end; 

%if %SUPERQ(ref)=  %then %do;
   %let MSGTYPE=ERROR;
   %put;
   %put &MSGTYPE: (&SYSMACRONAME) You must provide a FILEREF or LIBREF value.;
   %put;
   %goto Syntax;
   %return;
%end; 

%let ref=%qupcase(%superq(ref));
%if %qsysfunc(fileref(%superq(ref))) AND %qsysfunc(libref(%superq(ref))) %then %do;
   %let MSGTYPE=ERROR;
   %put;
   %put &MSGTYPE: (&SYSMACRONAME) %superq(ref) is not a valid FILEREF or LIBREF.;
   %put;
   %goto Syntax;
%end; 

%let mod=%qupcase(%superq(mod));

%if not (%index(F L,%superq(mod)) or %superq(mod)= ) %then %do;
   %let MSGTYPE=ERROR;
   %put;
   %put &MSGTYPE: (&SYSMACRONAME) mod must be F (for FILEREF) or L (for LIBREF).;
   %put &MSGTYPE- You specfied %superq(mod).;
   %put;
   %goto Syntax;
%end; 

 %let dsid=%sysfunc(open(sashelp.vlibnam(where=(libname="%superq(ref)")),i));
 %if (&dsid ^= 0) %then %do;  
   %let engnum=%sysfunc(varnum(&dsid,ENGINE));
   %let rc=%sysfunc(fetch(&dsid));
   %let engine=%sysfunc(getvarc(&dsid,&engnum));
   %let rc= %sysfunc(close(&dsid.));
 %end;

%if not (%qsubstr(%superq(engine),1,1)=V)%then %do;
   %let MSGTYPE=WARNING;
   %put;
   %put &MSGTYPE: (&SYSMACRONAME) A FILEREF or SAS library LIBREF is required ;
   %put &MSGTYPE- to retrieve an O/S  path for use in your SAS code.;
   %put &MSGTYPE- You specfied %superq(ref), which uses the %superq(engine) engine.;
   %put;
%end; 

%if %superq(mod)= %then %let path=%qsysfunc(pathname(%superq(ref)));
%else %let path=%qsysfunc(pathname(%superq(ref),%superq(mod)));
%superq(path)
%mend;
