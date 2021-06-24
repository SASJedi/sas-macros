%macro unpackZIP(
    mainPath     /* Top-level path to start unzipping */
   ,zipFileName  /* ZIP File name */  
   ,zipSubFolder /* Subfolder where ZIP is found, if applicable */
                );

  /***************************************************************************
   Created by Mark Jordan: http://go.sas.com/jedi or Twitter @SASJedi
   This macro program can be placed in your AUTOCALL path. 
  ***************************************************************************/
%local MSGTYPE rc fid fileref fnum memname big_zip big_zip_found data_zip data_zip_found zipPath;
%global unpackZIP_RC;
%let unpackZIP_RC=0;
%let MSGTYPE=NOTE;

%if %superq(mainPath)=? %then %do;
   %PUT &MSGTYPE:  *&SYSMACRONAME Documentation *******************************;
%syntax: %put;
   %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&SYSMACRONAME(mainPath,zipFileName,zipSubFolder);
   %PUT &MSGTYPE-     mainPath     = Top-level directory where unzipped files are sent.;
   %PUT &MSGTYPE-     zipFileName  = Name of the ZIP file, including extension(.zip).;   
   %PUT &MSGTYPE-     zipSubFolder = Subfolder where ZIP file is stored (optional).;
   %PUT ;
   %let MSGTYPE=NOTE;
   %PUT &MSGTYPE-  Examples:;
   %PUT &MSGTYPE-  Unpacking a zip file to s:/workshop, with ZIP file saved in;
   %PUT &MSGTYPE-  s:/workshop:;
   %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(s:/workshop,myZip.zip);
   %PUT ;
   %PUT &MSGTYPE-  Unpacking a zip file to s:/workshop, with ZIP file saved in;
   %PUT &MSGTYPE-  in a subdirectory named "data":;
   %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname(s:/workshop,myZip.zip,data);
   %PUT &MSGTYPE-  *************************************************************;
   %PUT ;
   %PUT NOTE:  Use %NRSTR(%%)&SYSMACRONAME%nrstr(%(?%)) for help.;
   %PUT ;
   %RETURN;
%end;
%if %SUPERQ(mainPath)= %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %PUT &MSGTYPE-  You must specify the top-level directory.;
   %PUT ;
   %goto Syntax;
%end;
%if %SUPERQ(zipFileName)= %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %PUT &MSGTYPE-  You must specify the name of the ZIP file to be unpacked.;
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

%if %superq(zipSubFolder) = %then 
   %let zipPath=%superq(mainPath);
%else 
   %let zipPath=%superq(mainPath)/%superq(zipSubFolder);

%let fileref=zipPath;  
%let rc=%sysfunc(filename(fileref,%superq(zipPath)));
%let path_found=%sysfunc(fileref(zipPath));
%if &path_found ne 0 %then %do;
   %put %sysfunc(sysmsg());
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %put ERROR- Path to ZIP file is not valid.;
   %put ERROR- %superq(zipPath); 
   %put ;
   %put NOTE: Path values in UNIX and LINUX are case sensitive. ;
   %put ;
   %let rc=%sysfunc(filename(fileref));
   %return;
%end;
%let rc=%sysfunc(filename(fileref));

%let fileref=mainPath;  
%let rc=%sysfunc(filename(fileref,%superq(mainPath)));
%let path_found=%sysfunc(fileref(mainPath));
%if &path_found ne 0 %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %put &MSGTYPE- Top-level path specified is not valid.;
   %put &MSGTYPE- %superq(mainPath); 
   %put %sysfunc(sysmsg());
   %put ;
   %put NOTE: Path values in UNIX and LINUX are case sensitive. ;
   %put ;
   %let rc=%sysfunc(filename(fileref));
   %return;
%end;

/* Test for the presence of the main ZIP file in the path */
%let fileref=bigzip;
%let rc=%sysfunc(filename(fileref,%superq(zipPath)/%superq(zipfilename),zip));
%let big_zip_found=%sysfunc(fileref(bigzip));
%if &big_zip_found ne 0 %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %put &MSGTYPE- %superq(zipfilename) was not not found in %superq(zipPath).;
   %put  ;
   %put NOTE: Filenames in UNIX and LINUX are case sensitive. ;
   %put  ;
      %let rc=%sysfunc(filename(fileref));
      %return;
   %end;

options dlcreatedir;
libname xx "%superq(mainPath)";
libname xx clear;
libname xx "%superq(zipPath)";
libname xx clear;

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
         pathname=cats("&mainPath/",scan(memname,-2,"\/"));
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

%do i=1 %to &filecount;
   filename out "%superq(mainPath)/%qsubstr(%superq(out&i),%sysevalf(%qsysfunc(find(%superq(out&i),/,2))+1))";    
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

filename bigzip;
filename out;
filename mainPath;
%mend unpackZIP;
