%macro findfiles(dir,ext,dsn,sub) / minoperator;
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   Last Modified: 2020-06-03
   This macro program (findfiles.sas) should be placed in your AUTOCALL path.
   Dependencies on other custom macros:
    - exist.sas
    - fileattribs.sas
    - translate.sas
 ***************************************************************************/
%local fileref rc did i n memname didc cmd nummem rootdirlen;
%let MsgType=NOTE;
%if %superq(dir)=?  %then 
   %do;
      %PUT ;
      %PUT &MsgType:  *&SYSMACRONAME Documentation *******************************;
      %PUT &MsgType-;
%syntax:
      %PUT &MsgType-  Produces a list of files with a specified extension in the log;
      %PUT &MsgType-  or optionally writes them to a dataset.;
      %PUT &MsgType-;
      %PUT &MsgType-  SYNTAX: %NRSTR(%%FindFiles%(dir,<ext,dsn,sub>%));
      %PUT &MsgType-     dir=fully qualified directory path;
      %PUT &MsgType-     ext=Space delimited list of file extensions (Optional, default is ALL);
      %PUT &MsgType-     dsn=name of data set to store filenames (Optional, otherwise writes to log.);
      %PUT &MsgType-     sub=look in subfolders? (Y|N default is Y);
      %PUT ;
      %PUT &MsgType-  Example: ;
      %PUT &MsgType-  %NRSTR(%%FindFiles%(c:\temp, csv%));
      %PUT &MsgType-  %NRSTR(%%FindFiles%(\\server\folder\, xls xlsx xlsm, work.myfiles%));
      %PUT &MsgType-  %NRSTR(%%FindFiles%(s:/workshop,sas,work.pgm_files,N%));
      %PUT ;
      %PUT &MsgType-  *************************************************************;
      %PUT ;
      %RETURN;
   %end;
%if %superq(dir) = %then %do;
   %let MsgType=ERROR;
      %PUT &MsgType:  *&SYSMACRONAME Error *******************************;
   %put &MsgType: You must specify a directory.;
   %goto Syntax;
%end;
%if %superq(ext) = %then %let ext=ALL;
%if %superq(sub) = %then %let sub=Y;
%let dir=%translate(%superq(dir),/,\);
   %let rc=%sysfunc(filename(fileref,%superq(dir)));
   %let did=%sysfunc(dopen(%superq(fileref)));
   %if &did=0 %then %do;
      %put ERROR: Directory %qupcase(%superq(dir)) does not exist.;
      %return;
   %end;
   %if %SYSMEXECDEPTH=1 and %superq(dsn) ^= %then %do;
      %if %exist(%superq(dsn)) %then %do;
         proc fedsql;
            drop table %superq(dsn) force;
            drop table this force;
         quit;
      %end;
   %end;
   %let nummem=0;
   %if %superq(sub)= %then %let sub=Y;
   %do n=1 %to %sysfunc(dnum(&did));
      %let memname=%qsysfunc(dread(&did,&n));
      %if %fileattribs(%superq(dir)/%superq(memname))=DIR and &sub=Y %then %do;
          /* This is subfolder - read it too */
          %findfiles(%superq(dir)/%superq(memname),%superq(ext),%superq(dsn),%superq(sub));
      %end;
      %if %fileattribs(%superq(dir)/%superq(memname))=ERROR %then %do;
          %PUT ERROR: Unable to retrieve attributeds for %superq(dir)/%superq(memname);
      %end;
      %else %if %superq(ext) ^= %then %do;
         %if %qupcase(%superq(ext))=ALL %then 
         %do;
            %let nummem=%eval(&nummem+1);
            %local mem&nummem fileinfo&nummem;
            %let mem&nummem=%superq(memname);
            %let fileinfo&nummem=%fileattribs(%superq(dir)/%superq(memname));
         %end;
         %else %if %qupcase(%qscan(%superq(memname),-1,.)) in %qupcase(%superq(ext)) %then %do;
            %let nummem=%eval(&nummem+1);
            %local mem&nummem fileinfo&nummem;
            %let mem&nummem=%superq(memname);
            %let fileinfo&nummem=%fileattribs(%superq(dir)/%superq(memname));
         %end;
      %end;
   %end;
   %let didc=%qsysfunc(dclose(%superq(did)));
   %let rc=%qsysfunc(filename(fileref));
   %if %superq(dsn) ^= and &nummem > 0 %then %do;
   ;
   data this;
      length Item 8 Path $512 Filename $124 Size CRDate CRTime ModDate ModTime 8; 
      keep   Item   Path      Filename      Size CRDate CRTime ModDate ModTime; 
      format Size comma16. CRDate ModDate mmddyy10. CRTime ModTime time.;
      label Size='Size (Bytes)';
      retain Path "%superq(dir)";
      array f  [&nummem] $512 _temporary_ (%do i=1 %to &nummem;"&&mem&i"%str( ) %end;);
      array fi [&nummem] $550 _temporary_ (%do i=1 %to &nummem;"&&fileinfo&i"%str( ) %end;);
      do item=1 to &nummem;
         Filename=f[item];
         Size=input(scan(fi[item],1,'|'),best32.);
         CRDate=datepart(input(scan(fi[item],2,'|'),datetime.));
         CRTime=timepart(input(scan(fi[item],2,'|'),datetime.));
         ModDate=datepart(input(scan(fi[item],3,'|'),datetime.));
         ModTime=timepart(input(scan(fi[item],3,'|'),datetime.));
         output;
      end;
   run;
   proc append base=%superq(dsn) data=this;
   run;
   proc sort data=%superq(dsn);
      by path filename;
   run;
   proc fedsql;
      drop table work.this force;
   quit;

   %end;
   %else %do ;
      %put;
      %put NOTE: &nummem files found in %superq(dir):;
      %put NOTE- File Name | Bytes | Created | Modified:;
      %do i=1 %to &nummem;
      %put NOTE- &&mem&i|&&fileinfo&i;
      %end;
      %put;
   %end;
%mend findfiles;
