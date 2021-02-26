%macro deletemacvars(Prefix,Keep);
/********************************************************************
 Created by Mark Jordan @SASJedi http://go.sas.com/jedi
 Save the macro source code file (deletemacvars.sas) in the AUTOCALL path. 
 Call the macro with ? as the parameter for usage and syntax
 Published 2/18/2019
 https://raw.githubusercontent.com/SASJedi/jedi-sas-tricks/master/deletemacvars.sas
********************************************************************/
%local UserMacroVariables ls;
%let Prefix=%qupcase(%superq(Prefix));
%let MsgType=NOTE;
%let ls=%qsysfunc(getoption(ls));
options ls=100;
%if %SUPERQ(Prefix)=? %then %do;
%Syntax:
   %put &MsgType: *&SYSMACRONAME Documentation: ***************************************;
   %put;
   %put &MsgType- Purpose: Deletes macro variables from the global symbol table.;
   %put;
   %put &MsgType- Syntax: %nrstr(%%)&SYSMACRONAME(<Prefix,Keep>);
   %put;
   %put &MsgType- Prefix: The first few letters of a series of macro names.;
   %put &MsgType-         If null, deletes all global scope macro variables;
   %put &MsgType-         except those created by the SAS system.;
   %put &MsgType-         (? produces this syntax help in the SAS log);
   %put;
   %put &MsgType-   Keep: If not null, keeps the variables for the specified prefix.;
   %put &MsgType-         Otherwise, deletes only variables for the specified prefix.;
   %put;
   %return;
%end; 
%if %superq(Keep) ne %then %let Keep=%str( NOT );
proc sql noprint;
   select name 
   into :UserMacroVariables SEPARATED BY " "
   from dictionary.macros
   where scope='GLOBAL'
         and Name not LIKE ('~_%') escape '~'
         and Name not LIKE 'STUDIO%'
         and Name not LIKE 'SYS%'
         and Name not LIKE 'SQL%'
         and Name not in ('CLIENTMACHINE','GRAPHINIT','GRAPHTERM','OLDPREFS','OLDSNIPPETS','OLDTASKS'
                          ,'SASWORKLOCATION','USERDIR','AFDSID','AFDSNAME','AFLIB','AFSTR1','AFSTR2','FSPBDV')
   %if %superq(Prefix) ne %then %do;
     AND Name %superq(keep) LIKE "%superq(Prefix)%nrstr(%%)"
   %end;
;
quit;
%if &sqlobs=0 %then %do;
   %put;
   %put NOTE: &SYSMACRONAME did not delete any macro variables because;
   %put NOTE- none met the selection criteria.;
   %put;
   %return;
%end;

%SYMDEL &UserMacroVariables;

%if %superq(Prefix) ne %then %do;
   %put &MsgType: (&SYSMACRONAME) Deleted user-defined macro variables with names starting with "%superq(Prefix)";
%end;
%else %do;
   %put &MsgType: (&SYSMACRONAME) Deleted all user-created macro variables;
%end;
%put &MsgType- &UserMacroVariables;

%put &MsgType: (&SYSMACRONAME) Remaining Global macro variables:;
%put _global_;
options ls=&ls;
%mend deletemacvars;
