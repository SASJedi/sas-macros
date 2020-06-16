%macro droplist(dsn,listvar,delim);
/******************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   Last Modified: 2020-06-16
   This macro program (fileattribs.sas) should be placed in your AUTOCALL path.
   Dependencies on other custom macros:
    - none
******************************************************************************/
   %local DropList DS LIB Rows;
   %global &listvar;
   %let MSGTYPE=NOTE;
   %if %SUPERQ(dsn)= %then
      %do;
         %let MSGTYPE=ERROR;
         %PUT;
         %PUT &MSGTYPE:  *&SYSMACRONAME MACRO ERROR ***************************************;
         %PUT &MSGTYPE-  You must specify a data set name.;

   %syntax:
         %PUT;
         %PUT &MSGTYPE:  *&SYSMACRONAME MACRO Documentation *******************************;
         %PUT;
         %PUT &MSGTYPE- This macro returns a delimited list containing the names of all;
         %PUT &MSGTYPE- variables in a data with all values missing.;
         %PUT;
         %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&sysmacroname(DSN<,delim=>);
         %PUT &MSGTYPE-         DSN = Data Set Name;
         %PUT &MSGTYPE-     listvar = Name of global macro variable to hold the list.;
         %PUT &MSGTYPE-       delim = (Optional) List delimiter. S for SPACE (default) C for comma.;
         %PUT;
         %PUT &MSGTYPE-  Example:;
         %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(orion.customer_dim,mylist);
         %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(orion.customer_dim,varlist,C);
         %PUT &MSGTYPE-  *************************************************************;
         %PUT;
         %return;
      %end;
   %if %superq(dsn)=? or %qupcase(%superq(dsn))=!HELP %then
      %goto syntax;
   %if %SUPERQ(listvar)= %then
      %do;
         %let MSGTYPE=ERROR;
         %PUT;
         %PUT &MSGTYPE:  *&SYSMACRONAME MACRO ERROR ***************************************;
         %PUT &MSGTYPE-  You must specify a global macro variable name to contain the list.;
         %goto syntax;
      %end;


   %if %QUPCASE(&delim)=C %then
      %let delim=%str(,);
   %else %let delim=%str( );

   %let DSN=%qupcase(&dsn);
   %let DS=%qscan(&dsn,-1);
   %if &ds=&dsn %then
      %let LIB=WORK;
   %else %let LIB=%qscan(&dsn,1);

   proc sql noprint;
      select Name
         into :Var1- 
         from dictionary.columns
         where LIBNAME="&LIB" and MEMNAME="&DS"
      ;
      %let Rows=&SQLOBS;
      select catx("%superq(delim)"
         %do i=1 %to &rows;
         ,
         case 
            when sum(missing(&&Var&i)) then "&&Var&i" 
            else " " 
         end
         %end;
         )
      into :&listvar
      from test
      ;
   quit;
%mend;