%macro sysinfo(help);
/******************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   Last Modified: 2020-11-11
   This macro program (sysinfo.sas) should be placed in your AUTOCALL path.
   Dependencies on other custom macros:
    - none
******************************************************************************/
   %let MSGTYPE=NOTE;
   %if %SUPERQ(help) ne %then
      %do;
   %syntax:
         %PUT;
         %PUT &MSGTYPE:  *&SYSMACRONAME MACRO Documentation *******************************;
         %PUT;
         %PUT &MSGTYPE- This macro reports on SAS sytem information.;
         %PUT;
         %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&sysmacroname(<help>);
         %PUT &MSGTYPE-     help = (Optional) print these instructions in the log.;
         %PUT;
         %PUT &MSGTYPE-  Example:;
         %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname();
         %PUT &MSGTYPE-  *************************************************************;
         %PUT;
         %return;
      %end;
ods proclabel "SAS System Info";
proc sql;
title "Site Number: &SYSSITE";
title2 "SAS Version: &SYSVER - OS: &SYSSCP";
select Name, Value
   from dictionary.macros
   where name in
      (
       'SYSENCODING'
      ,'SYSENV'
      ,'SYSHOSTINFOLONG'
      ,'SYSPROCESSMODE'
      ,'SYSPROCESSNAME'
      ,'SYSSCPL'
      ,'SYSSITE'
      ,'SYSVLONG4'
      )
   ;
title;
quit;
%mend;
