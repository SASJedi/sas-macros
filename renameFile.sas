%macro renameFile(dir,oldname, newname);
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   The macro program (renameFiles.sas) should be placed in your AUTOCALL path.
   Also requires macro program translate.sas in autocall path.
 ***************************************************************************/
 %local command rc slash;
   %let MSGTYPE=NOTE;
   %if %superq(dir)= %then
      %do;
         %let MSGTYPE=ERROR;
         %PUT;
         %PUT &MSGTYPE: &SYSMACRONAME ERROR: DIR parameter is required.;
         %put &MSGTYPE- &=dir &=oldname &=newname;

   %syntax:
         %PUT;
         %PUT &MSGTYPE: *&SYSMACRONAME Documentation *******************************;
         %PUT &MSGTYPE-;
         %PUT &MSGTYPE-  Renames a file in a directory.;
         %PUT &MSGTYPE-;
         %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)%superq(sysmacroname)(dir,oldname,newname%));
         %PUT &MSGTYPE-     dir     = fully qualified directory path;
         %PUT &MSGTYPE-     oldname = current name of file;
         %PUT &MSGTYPE-     newname = file new name;
         %PUT;
         %PUT &MSGTYPE-  Example:;
         %PUT &MSGTYPE-  %NRSTR(%%)%superq(sysmacroname)(c:\temp,myfile.txt,yourfile.txt);
         %PUT;
         %PUT &MSGTYPE- *************************************************************;
         %PUT;

         %RETURN;
      %end;
   %if %qsubstr(%SUPERQ(dir),1,1)=! or %superq(dir)=? %then %goto syntax;
   %if %superq(oldname)= %then
      %do;
         %let MSGTYPE=ERROR;
         %PUT;
         %PUT &MSGTYPE: &SYSMACRONAME ERROR: OLDNAME parameter is required.;
         %put &MSGTYPE- &=dir &=oldname &=newname;
         %goto syntax;
      %end;
   %if %superq(newname)= %then
      %do;
         %let MSGTYPE=ERROR;
         %PUT;
         %PUT &MSGTYPE: &SYSMACRONAME ERROR: NEWNAME parameter is required.;
         %put &MSGTYPE- &=dir &=oldname &=newname;
         %goto syntax;
      %end;
   %if %superq(sysscp)=WIN %then
      %let slash=\;
   %else %let slash=/;
   %if not %fileexist(%superq(dir)%superq(slash)%superq(oldname)) %then
      %do;
         %put ERROR: &SYSMACRONAME reports file %superq(dir)%superq(slash)%superq(oldname) does not exist.;

         %return;
      %end;

   %let command=rename "%superq(dir)%superq(slash)%superq(oldname)" "%superq(newname)";
   options noxwait;

   %sysexec(%superq(command));
   options xwait;
   %if &SYSRC ne 0 %then
      %do;
         %put ERROR: &SYSMACRONAME reports command=%superq(command) produced return code &SYSRC;
         %put ERROR- %superq(oldname) probably did not get renamed properly.;
         %put;
      %end;
%mend renameFile;