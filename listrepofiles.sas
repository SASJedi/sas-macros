%macro listRepoFiles(user,repo,branch,extension);
 /***************************************************************************
   Created by Mark Jordan: http://go.sas.com/jedi or Twitter @SASJedi
   This macro program can be placed in your AUTOCALL path. 
  ***************************************************************************/
%local MSGTYPE RC parm1 parm2 parm3 parm4;
%let MSGTYPE=NOTE;
%let parm1=user;
%let parm2=repo;
%let parm3=branch;
%let parm4=extension;

%if %superq(&parm1)=? %then %do;
   %PUT &MSGTYPE:  *&SYSMACRONAME Documentation *******************************;
%syntax: %put;
   %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&SYSMACRONAME(&parm1,&parm2,&parm3,&parm4);
   %PUT &MSGTYPE-     &parm1 = Username for repo owner (Case sensitive);
   %PUT &MSGTYPE-     &parm2 = Repo name (Case sensitive);
   %PUT &MSGTYPE-     &parm3 = branch (Optional, default is master);
   %PUT &MSGTYPE-     &parm4 = file extension (Optional, default gets all);
   %PUT %str( );
   %let MSGTYPE=NOTE;
   %PUT &MSGTYPE-  Examples:;
   %PUT &MSGTYPE-  Retrieve a list of all files in the master branch of;
   %PUT &MSGTYPE-  SASJedi repo named sas-macros:;
   %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(SASJedi,sas-macros);
   %PUT %str( );
   %PUT &MSGTYPE-  Retrieve a list of SAS files in the master branch of;
   %PUT &MSGTYPE-  SASJedi repo named sas-macros:;
   %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(SASJedi,sas-macros,,sas);
   %PUT %str( );
   %PUT &MSGTYPE-  *************************************************************;
   %PUT %str( );
   %PUT NOTE:  Use %NRSTR(%%)&SYSMACRONAME%nrstr(%(?%)) for help.;
   %PUT %str( );
   %RETURN;
%end;
%if %SUPERQ(&parm1)= %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %PUT &MSGTYPE-  You must specify a value for &parm1..;
   %PUT %str( );
   %goto Syntax;
%end;
%if %SUPERQ(&parm2)= %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %PUT &MSGTYPE-  You must specify a value for &parm2..;
   %PUT %str( );
   %goto Syntax;
%end;

%if %superq(branch)= %then %let branch=master;
filename repolist temp;
proc http url="https://api.github.com/repos/&user/&repo/git/trees/&branch"
     query=("recursive"="1")
     out=repolist
     ;
run;

libname repolist json automap=reuse;
proc fedSQL;
   drop table work.files force;
quit;

data work.files;
   set repolist.tree(keep= path size url);
%if %superq(extension) ne %then %do;
   where lowcase(path) like %tslit(%.%qlowcase(%superq(extension)));
%end;
run;

libname repolist;
filename repolist;
title "List of %superq(extension) files in the &repo repository &branch branch";
proc print data=work.files;
run;
title;
%mend listRepoFiles;

