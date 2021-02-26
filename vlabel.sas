%macro vlabel(dsn,var);
  /***************************************************************************
   Created by Mark Jordan: http://go.sas.com/jedi or Twitter @SASJedi
   This macro program (vlabel.sas) should be placed in your AUTOCALL path.
  ***************************************************************************/
%let MSGTYPE=NOTE;
%if %SUPERQ(dsn)= %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***********************************************;
   %PUT &MSGTYPE-  You must specify the name of the data set from which to copy;
   %PUT &MSGTYPE-  the variable label;
   %goto Syntax;
%end;
%if %superq(dsn)=? 
   %then %do;
   %PUT &MSGTYPE:  *&SYSMACRONAME Documentation ***************************************;
   %PUT &MSGTYPE-  This macro returns the text of the lable associates with ;
   %PUT &MSGTYPE-  a variable or, if there is no lable, the variable name;
%syntax: %put;
   %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&sysmacroname%nrstr(%(dsn,var%));
   %PUT &MSGTYPE-     dsn=data set name;
   %PUT &MSGTYPE-     var=variable name for which to retrieve the label;
   %PUT ;
   %PUT &MSGTYPE-  Example:;
   %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname%nrstr(%(sashelp.cars,weight%));
   %PUT &MSGTYPE-  *************************************************************;
   %RETURN;
%end;
%if %qsubstr(%SUPERQ(dsn),1,1)=! or %superq(dsn)=? %then %goto Syntax; 

   %local dsid vnum label rc i;
   %if %sysfunc(exist( %superq(dsn)))=0 %then %do;
      %put ERROR: (vlabel) Data set %superq(dsn) does not exist.;
      %return;
   %end;
   %let dsid=%sysfunc(open(%superq(dsn)));
   %if &dsid=0 %then %do;
      %put ERROR: (vlabel) Data set %superq(dsn) cannot be opened.;
      %return;
   %end;
   %let vnum=%sysfunc(varnum(&dsid,%superq(var)));
   %if &vnum=0 %then %do;
      %put ERROR: (vlabel) Variable %superq(var) does not exist in data set %superq(dsn).;
      %GoTo Exit;
   %end;
   %qsysfunc(VARLABEL(&dsid, &vnum));
   %Exit:
   %let rc=%sysfunc(close(&dsid));
%mend;
