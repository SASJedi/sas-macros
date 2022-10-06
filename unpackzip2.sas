%macro unpackZIP2(
    zipFileName  /* fully qualified ZIP File name */  
   ,unzipPath    /* Path to send unipped files*/
                );

  /***************************************************************************
   Created by Mark Jordan: http://go.sas.com/jedi or Twitter @SASJedi
   This macro program can be placed in your AUTOCALL path. 
  ***************************************************************************/
%local MSGTYPE rc fid fileref fnum memname big_zip big_zip_found data_zip data_zip_found zipPath;
%global unpackZIP_RC;
%let unpackZIP_RC=0;
%let MSGTYPE=NOTE;

%if %superq(zipFileName)=? %then %do;
   %PUT &MSGTYPE:  *&SYSMACRONAME Documentation *******************************;
%syntax: %put;
   %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&SYSMACRONAME(zipFileName,unzipPath);
   %PUT &MSGTYPE-     *zipFileName = Fully-qualified ZIP file name, including path and extension(.zip).;   
   %PUT &MSGTYPE-      unzipPath   = Full path where unzipped files will be written.;
   %PUT &MSGTYPE-                    Default is current SAS directory.;
   %PUT &MSGTYPE-     *Required;
   %PUT ;
   %let MSGTYPE=NOTE;
   %PUT &MSGTYPE-  Examples:;
   %PUT &MSGTYPE-  Unpacking s:/workshop/downloads/my.zip to s:/workshop/unzipped:;
   %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(s:/workshop/downloads/my.zip;
   %PUT &MSGTYPE-                         ,s:/workshop/unzipped);
   %PUT &MSGTYPE-  *************************************************************;
   %PUT ;
   %PUT NOTE:  Use %NRSTR(%%)&SYSMACRONAME%nrstr(%(?%)) for help.;
   %PUT ;
   %RETURN;
%end;
%if %SUPERQ(zipFileName)= %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %PUT &MSGTYPE-  You must specify the ZIP file name and location.;
   %PUT ;
   %goto Syntax;
%end;
%if %qscan(%SUPERQ(zipFileName),1,.)=%SUPERQ(zipFileName) %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %PUT &MSGTYPE-  The name of the ZIP file to be unpacked must include the extension.;
   %PUT ;
   %goto Syntax;
%end;
/* Test for the presence of the ZIP file*/
%let fileref=bigzip;
%let rc=%sysfunc(filename(fileref,%superq(zipfilename),zip));
%let big_zip_found=%sysfunc(fileref(bigzip));
%if &big_zip_found ne 0 %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %put &MSGTYPE- %superq(zipfilename) was not not found.;
   %put  ;
   %put NOTE: Remember that UNIX and Linux filenames are case sensitive. ;
   %put  ;
      %let rc=%sysfunc(filename(fileref));
      %return;
   %end;

	option nosource nonotes;
	options dlcreatedir;
%if %SUPERQ(unzipPath)= %then %do;
	libname _x_ '.';
	%let unzipPath=%qsysfunc(pathname(_x_));
	libname _x_ clear;
   %let MSGTYPE=NOTE;
   %PUT &MSGTYPE:  *&sysmacroname ***************************************;
   %PUT &MSGTYPE-  Unzip path not specified. Writing unzipped filed to;
   %PUT &MSGTYPE-  %SUPERQ(unzipPath).;
   %PUT ;
   %goto Syntax;
%end;

%let fileref=unzipTO;  
%let rc=%sysfunc(filename(fileref,%superq(unzipPath)));
%let path_found=%sysfunc(fileref(unzipTO));
%let rc=%sysfunc(filename(fileref));
%if &path_found ne 0 %then %do;
	libname _X_ "%superq(unzipPath)";
	libname _X_ clear;
	%let fileref=unzipTO;  
	%let rc=%sysfunc(filename(fileref,%superq(unzipPath)));
	%let path_found=%sysfunc(fileref(unzipTO));
	%let rc=%sysfunc(filename(fileref));
	%if &path_found ne 0 %then %do;
		libname _X_ ".";
		%let unzipPath=%qsysfunc(pathname(_X_));
		libname _X_ clear;
	%end;
%end;
options notes source;
%let MSGTYPE=NOTE;
%PUT &MSGTYPE: *&sysmacroname: Files will be unzipped to ;
%put &MSGTYPE- %superq(unzipPath); 

/* Read the "members" (files) from the ZIP file */
/* Create the data folder structure and get a list of files in macro variables */
data _null_;
   length memname pathname $500;
   fid=dopen("bigzip");
   if fid=0 then stop;
   memcount=dnum(fid);
   do i=1 to memcount;
      memname=dread(fid,i);
      /* Create and empty folder for each folder in the ZIP file */
      /* check for trailing / in folder name */
      isFolder = (first(reverse(trim(memname)))='/');
      if isfolder then do;
         pathname=cats("&unzipPath/",scan(memname,-2,"\/"));
         put "NOTE: Creating path " pathname;
         rc1=libname('xx',pathname);
         rc2=libname('xx');
      end;
      else do;
         put "NOTE: Found file " memname;
         filecount+1;
         call symputx(cats('out',filecount),memname,'L');
      end;
   end;
   rc=dclose(fid);
   call symputx('filecount',filecount,'L');
run;
%put _local_;
%do i=1 %to &filecount;
   filename out "%superq(unzipPath)/%superq(out&i)";
   %put NOTE: Writing %superq(out&i) to %qsysfunc(pathname(out));
   data _null_;
      infile bigzip(%superq(out&i))
      lrecl=256 recfm=F length=length eof=eof unbuf;
      file out  lrecl=256 recfm=N;
      input;
      put _infile_ $varying256. length;
      return;
    eof:
      stop;
   run;
%end;

options nodlcreatedir;
filename bigzip;
filename out;
%mend unpackZIP2;
