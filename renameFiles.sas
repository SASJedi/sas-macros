%macro renameFiles(dir,regex,ext,sub,test)/ minoperator;
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   The macro program (renameFiles.sas) should be placed in your AUTOCALL path.
   Also requires macro program renameFile.sas in autocall path.
 ***************************************************************************/
   %local fileref rc did i n memname didc cmd nummem slash;
   %let MSGTYPE=NOTE;
   %if %superq(dir)= %then %do;
      %let MSGTYPE=ERROR;
      %PUT ;
      %PUT &MSGTYPE: &SYSMACRONAME ERROR: DIR parameter is required.;
   %syntax:
      %PUT ;
      %PUT &MSGTYPE: *&SYSMACRONAME Documentation *******************************;
      %PUT &MSGTYPE-;
      %PUT &MSGTYPE-  Renames files in the specified directory.;
      %PUT &MSGTYPE-;
      %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)%superq(sysmacroname)(dir,regex<,ext,sub,test>%));
      %PUT &MSGTYPE-     dir   = fully qualified directory path;
      %PUT &MSGTYPE-     regex = regex describing text to find & replace in the filename;
      %PUT &MSGTYPE-     ext   = a single file extension (Optional); 
      %PUT &MSGTYPE-     sub   = look in subfolders? (Y/N, default is N);
      %PUT &MSGTYPE-     test  = Write (T)est values to log, or (E)xecute (T/E, default is T);
      %PUT ;
      %PUT &MSGTYPE-  ** Members without extensions are considered folders and are not renamed.**;
      %PUT ;
      %PUT &MSGTYPE-  Example: ;
      %PUT &MSGTYPE-  Rename all .sas filenames starting with "crs0" to start with "cr0" instead:;
      %PUT &MSGTYPE-  starting in S:\workshop and including all subdirectories:;
      %PUT &MSGTYPE-  %NRSTR(%%)%superq(sysmacroname)(s:\workshop,s/(^crs0)(\w*\.\w*)/cr0$2/,sas,Y,E);
      %PUT ;
      %PUT &MSGTYPE-  Test renaming files beginning with "abc" to begin with "XYZ" instead;
      %PUT &MSGTYPE-  disregard extension. Do not include files in subdirectories:;
      %PUT &MSGTYPE-  %NRSTR(%%)%superq(sysmacroname)(\\server\folder\,s/(^abc)(\w*\.sas)/XYZ$2/);
      %PUT ;
      %PUT &MSGTYPE- Notes: ******************************************************;
      %PUT &MSGTYPE- Test your regular expressions at http://regex101.com;
      %PUT ;
      %PUT &MSGTYPE- *************************************************************;
      %PUT ;
      %RETURN;
   %end;
   %if %superq(dir)=? or %qupcase(%superq(dir))=!HELP %then %goto syntax;
   %if %superq(regex)= %then %do;
      %let MSGTYPE=ERROR;
      %PUT ;
      %PUT &MSGTYPE: &SYSMACRONAME ERROR: REGEX parameter is required.;
      %goto syntax;
   %end;
   %if %superq(sub)= %then %let sub=N;
   %if %superq(test)= %then %let test=T;
   %let test=%qupcase(%superq(test));
   %if not (&test in T E) %then %do;
      %let MSGTYPE=ERROR;
      %PUT ;
      %PUT &MSGTYPE: &SYSMACRONAME %superq(test) is an invalid valid value for TEST.;
      %goto syntax;
   %end;
   %if %superq(sysscp)=WIN %then %let slash=\;
     %else %let slash=/;
   %let dir =%translate(%superq(dir),%superq(slash)%superq(slash),\/);
   %let sub=%qupcase(%superq(sub));
   %let rc=%sysfunc(filename(fileref,%superq(dir)));
   %let did=%sysfunc(dopen(%superq(fileref)));
   %if &did=0 %then %do;
      %put ERROR: Directory %qupcase(%superq(dir)) does not exist.;
      %return;
   %end;
   %let nummem=0;
   %if %superq(sub)= %then %let sub=Y;
   %let sub=%qupcase(%superq(sub));
   %do n=1 %to %qsysfunc(dnum(&did));
      %let memname=%qsysfunc(dread(&did,&n));
      %if %qscan(&memname,2,.)= %then %do;
           %if %superq(sub)=Y %then %do;
          /* This is subfolder - read it too */
          %renameFiles(%superq(dir)%superq(slash)%superq(memname),%superq(regex),%superq(ext),%superq(sub));
         %end;
      %end;
      %else %if %qupcase(%superq(ext)) ne 
            and %qupcase(%qscan(%superq(memname),-1,.)) = %qupcase(%superq(ext)) 
            %then %do;
         %let nummem=%eval(&nummem+1);
         %local mem&nummem newmem&nummem; 
         %let mem&nummem=%superq(memname);
         %let newmem&nummem=%qsysfunc(prxchange(%superq(regex),-1,%superq(mem&nummem)));
         %if %superq(mem&nummem)=%superq(newmem&nummem) %then %let nummem=%eval(&nummem-1);
      %end;
      %else %if %qupcase(%superq(ext)) eq 
            and %qupcase(%qscan(%superq(memname),-1,.)) ne  
            %then %do;
         %let nummem=%eval(&nummem+1);
         %local mem&nummem newmem&nummem; 
         %let mem&nummem=%superq(memname);
         %let newmem&nummem=%qsysfunc(prxchange(%superq(regex),-1,%superq(mem&nummem)));
         %if %superq(mem&nummem)=%superq(newmem&nummem) %then %let nummem=%eval(&nummem-1);
      %end;
   %end;

   %let didc=%qsysfunc(dclose(%superq(did)));
   %let rc=%qsysfunc(filename(fileref));

   %if &nummem=0%then %do;
      %put;
      %put NOTE: &SYSMACRONAME - no files meeting the criteria were found in %superq(dir);
      %put;
      %return;
   %end;

   %if %superq(test) = T %then %do;
   %PUT NOTE: &SYSMACRONAME in TEST mode - no changes were actually made to these files:;
   %end;
   %else %do;
   %PUT NOTE: &SYSMACRONAME in EXECUTE mode, The following changes were made:;
   %end;
   %do i=1 %to &nummem;
      %put NOTE- Name=%superq(mem&i) NewName=%superq(newmem&i);
      %if %superq(test) ne T %then %do;
         %renamefile(%superq(dir),%superq(mem&i),%superq(newmem&i))
      %end;
   %end;
%mend renameFiles;
