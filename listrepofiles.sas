%macro listRepoFiles(user,repo,branch,extension,proxyhost=,proxyport=,proxyusername=,proxypassword=);
 /***************************************************************************
   Created by Mark Jordan: http://go.sas.com/jedi or Twitter @SASJedi
	Updated 2/4/2022 to add proxy options
   This macro program can be placed in your AUTOCALL path. 
  ***************************************************************************/
%local MSGTYPE RC parm1 parm2 parm3 parm4 parm5 parm6 parm7 parm8 parm9;
%let MSGTYPE=NOTE;
%let parm1=user;
%let parm2=repo;
%let parm3=branch;
%let parm4=extension;
%let parm5=proxyhost;
%let parm6=proxyport;
%let parm7=proxyusername;
%let parm8=proxypassword;

%if %superq(&parm1)=? %then %do;
   %PUT &MSGTYPE:  *&SYSMACRONAME Documentation *******************************;
%syntax: %put;
   %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&SYSMACRONAME(&parm1,&parm2<,&parm3,&parm4,&parm5=,&parm6=,&parm7=,&parm8=>);
   %PUT %str( );
   %PUT &MSGTYPE-     Required parameters: (Case sensitive!);
   %PUT &MSGTYPE-       &parm1 = Username for repo owner ;
   %PUT &MSGTYPE-       &parm2 = Repo name ;
   %PUT %str( );
   %PUT &MSGTYPE-     Optional parameters:;
   %PUT &MSGTYPE-       &parm3 = branch                             (default: master);
   %PUT &MSGTYPE-       &parm4 = file extension                  (default: all files);
   %PUT &MSGTYPE-       &parm5 = Proxy server host name          (default: option not used);
   %PUT &MSGTYPE-       &parm6 = Proxy server port number        (default: option not used);
   %PUT &MSGTYPE-       &parm7 = Your proxy server user name (default: option not used);
   %PUT &MSGTYPE-       &parm8 = Your proxy server password  (default: option not used);
   %PUT %str( );
   %let MSGTYPE=NOTE;
   %PUT &MSGTYPE-  Examples:;
   %PUT &MSGTYPE-  Retrieve a list of all files in the master branch of the;
   %PUT &MSGTYPE-  SASJedi repo named sas-macros:;
   %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(SASJedi,sas-macros);
   %PUT %str( );
   %PUT &MSGTYPE-  Retrieve a list of SAS files in the master branch of the;
   %PUT &MSGTYPE-  SASJedi repo named sas-macros:;
   %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(SASJedi,sas-macros,,sas);
   %PUT %str( );
   %PUT &MSGTYPE-  Proxy-related parameters are keyword parameters. For example,;
   %PUT &MSGTYPE-  to retrieve a list of all files in the master branch of the;
   %PUT &MSGTYPE-  SASJedi repo named sas-macros using a proxy server:;
   %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(SASJedi,sas-macros,proxyhost=myhost.example.com,proxyport=898);
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
	  %if %superq(proxyhost) ne %then proxyhost="&proxyhost";
	  %if %superq(proxyport) ne %then proxyport=&proxyport;
	  %if %superq(proxyusername) ne %then proxyusername="&proxyusername";
	  %if %superq(proxypassword) ne %then proxypassword="&proxypassword";
     ;
run;
%if &syserr ne 0 %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %PUT &MSGTYPE-  Failed to retrive the repo information. Exiting the macro.;
   %put %str( );
   %return;
%end;
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
