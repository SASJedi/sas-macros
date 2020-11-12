%macro FixSASProgramFiles(dir,findme,fixme,inencoding,outencoding)/minoperator;
%local type i;
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   Last Modified: 2020-06-03
   This macro program (findfiles.sas) should be placed in your AUTOCALL dir.
   Dependencies on other custom macros:
    - exist.sas
    - fileattribs.sas
    - findfiles.sas
    - translate.sas
 ***************************************************************************/
%let type=NOTE;
%if %qsubstr(%superq(dir),1,1) in ! ?  %then 
   %do;
      %let type=NOTE;
%syntax:
      %PUT ;
      %PUT &TYPE:  *&SYSMACRONAME Documentation *******************************;
      %PUT &TYPE-;  
      %PUT &TYPE-  For SAS program files within an folder and all sub folders,;
      %PUT &TYPE-  finds existing text you specify (findme) and replaces it ;
      %PUT &TYPE-  with alternate text you specify (fixme).;
      %PUT &TYPE-;
      %PUT &TYPE-  SYNTAX: %NRSTR(%%FindFiles%(dir,findme,fixme,<inencoding>%));
      %PUT &TYPE-    dir        =fully qualified starting directory dir;
      %PUT &TYPE-    findme     =the text string you wish to find in SAS program files;
      %PUT &TYPE-    fixme      =the text to insert in place of the existing text.;
      %PUT &TYPE-    inencoding =(optional) encoding of the input file.;
      %PUT &TYPE-    outencoding=(optional) encoding of the output file.;
      %PUT ;
      %PUT &TYPE-  Example: ;
      %PUT &TYPE-  %NRSTR(%%FindFiles%(c:\temp,bad text,good text,WLATIN1,UTF-8));
      %PUT ;
      %PUT &TYPE-  *************************************************************;
      %PUT ;
      %RETURN;
   %end;
%if %superq(dir) = %then %do;
   %let type=ERROR;
   %put &TYPE: (&sysmacroname) You must specify a directory.;
   %goto Syntax;
%end;
%if %superq(findme) = %then %do;
   %let type=ERROR;
   %put &TYPE: (&sysmacroname) You must specify the text string you are searching for.;
   %goto Syntax;
%end;
%if %superq(fixme) = %then %do;
   %let type=ERROR;
   %put &TYPE: (&sysmacroname) You must specify the replacement text string.;
   %goto Syntax;
%end;
%if %superq(inencoding) ne %then %do;
   %let inencoding=encoding="%superq(inencoding)";
%end;
%if %superq(outencoding) ne %then %do;
   %let outencoding=encoding="%superq(outencoding)";
%end;

%FindFiles(%superq(dir),sas,work.pgm_files)

proc sql noprint;
select catx('/',path,filename)
      ,catx('/',path,cats(scan(filename,1,'.'),'_mod.sas'))
      into :readme1-
          ,:writeme1-
   from work.pgm_files
;
quit;
%do i=1 %to &sqlobs;
filename readme "&&readme&i" &inencoding;
filename writeme "&&writeme&i" &outencoding;
data _null_;
   infile readme;
   file   writeme;
   input ;
   _infile_ =prxchange("s~c:\\workshop\\winsas\\bfex~&dir~i", -1, _infile_);
   put _infile_;
run;

filename readme clear;
filename writeme clear;
%end;
%mend;
