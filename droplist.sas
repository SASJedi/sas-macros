%macro droplist(dsn,delim=S);
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
  ***************************************************************************/
%global DropList;
%let MSGTYPE=NOTE;
%if %QUPCASE(&delim)=S %then %let delim=%str( );
   %else %let delim=%str(,);

%if %SUPERQ(dsn)= %then %do;
   %let MSGTYPE=ERROR;
   %PUT;
   %PUT &MSGTYPE:  *&SYSMACRONAME MACRO ERROR ***************************************;
   %PUT &MSGTYPE-  You must specify a data set name.;
   %goto Syntax;
%end;

%let DSN=%qupcase(&dsn);
%let len=%sysfunc(max(%length(&dsn),4));
%if &len > 4 %then %do;
%if %qsubstr(&dsn,1,1)=! %then %do;
   %PUT;
   %PUT &MSGTYPE:  *&SYSMACRONAME MACRO Documentation *******************************;
   %PUT;
%syntax:   %PUT &MSGTYPE- This macro creates a global macro variable named DROPLIST listing;
   %PUT &MSGTYPE- the names of all variables for which all observations have missing;
   %PUT &MSGTYPE- values.  The default list delimiter is a space.;
   %PUT;
   %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&sysmacroname(DSN<,delim=>);
   %PUT &MSGTYPE-     DSN=Data Set Name;
   %PUT &MSGTYPE-     delim=S (default) for SPACE delimited list;
   %PUT &MSGTYPE-     delim=C for comma delimited list;
   %PUT;
   %PUT &MSGTYPE-  Example: ;
   %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(orion.customer_dim);
   %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(orion.customer_dim,delim=C);
   %PUT &MSGTYPE-  *************************************************************;
   %PUT;
   %Return;
%end;
%end;

%let DS=%qscan(&dsn,-1);
%if &ds=&dsn %then %let LIB=WORK;
%else %let LIB=%qscan(&dsn,1);

proc sql noprint;
select Name, IFC(Type='char','""','.')
   into :Var1- ,:Expr1-
   from dictionary.columns
   where LIBNAME="&LIB" and MEMNAME="&DS"
;
/*%put _local_;*/
%let Rows=&SQLOBS;
select CATX(' '
%do i=1 %to &Rows;
, case (sum(&&Var&i=&&Expr&i))
         when count(*) then "&&Var&i"
         else ''
        end
%end;
)
      into :DropList
    from &DSN
    ;
quit;
%mend;
