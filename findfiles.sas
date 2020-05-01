%macro findfiles(dir, ext,sub,dsn) / minoperator;
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   This macro program (findfiles.sas) should be placed in your AUTOCALL path.
 ***************************************************************************/
%local fileref rc did i n memname didc cmd nummem rootdirlen;
%let type=NOTE;
   %if %qupcase(%superq(dir))=!HELP 
   %then %do;
   %let type=NOTE;
%syntax:
   %PUT ;
   %PUT &TYPE:  *&SYSMACRONAME Documentation *******************************;
   %PUT &TYPE-;
   %PUT &TYPE-  Produces a list of files with a specified extension in the log;
   %PUT &TYPE-  or optionally writes them to a dataset.;
   %PUT &TYPE-;
   %PUT &TYPE-  SYNTAX: %NRSTR(%%FindFiles%(dir,ext<,sub,dsn>%));
   %PUT &TYPE-     dir=fully qualified directory path;
   %PUT &TYPE-     ext=Space delimited list of file extensions;
   %PUT &TYPE-     sub=look in subfolders? (1=yes);
   %PUT &TYPE-     dsn=name of data set to store filenames (Optional);
   %PUT ;
   %PUT &TYPE-  Example: ;
   %PUT &TYPE-  %NRSTR(%%FindFiles%(c:\temp, csv%));
   %PUT &TYPE-  %NRSTR(%%FindFiles%(\\server\folder\, xls xlsx xlsm, work.myfiles%));
   %PUT ;
   %PUT &TYPE-  *************************************************************;
   %PUT ;
   %RETURN;
%end;
   %let rc=%sysfunc(filename(fileref,%superq(dir)));
   %let did=%sysfunc(dopen(%superq(fileref)));
   %if &did=0 %then %do;
      %put ERROR: Directory %qupcase(%superq(dir)) does not exist.;
      %return;
   %end;
   %let nummem=0;
   %if %superq(sub)= %then %let sub=1;
   %if %datatyp(%superq(sub)) ^= NUMERIC %then %let sub=1;
   %if %superq(sub)=1 %then %let rootdirlen=%eval(%length(%superq(dir))+1);
   %else %let rootdirlen=%eval(%length(%superq(dir))+&sub);;
   %do n=1 %to %qsysfunc(dnum(&did));
      %let memname=%qsysfunc(dread(&did,&n));
      %if %qscan(&memname,2,.)= and %superq(sub)^= %then %do;
          /* This is subfolder - read it too */
          %findfiles(%superq(dir)/%superq(memname),%superq(ext),%length(%superq(dir)),%superq(dsn));
      %end;
      %else %if %qupcase(%qscan(%superq(memname),-1,.)) in %qupcase(%superq(ext)) %then %do;
         %let nummem=%eval(&nummem+1);
         %let mem&nummem=%superq(memname);
         %local sz&nummem cr&nummem mod&nummem;
         %fileattribs(%superq(dir)\%superq(memname),sz&nummem,cr&nummem,mod&nummem);
      %end;
   %end;
   %let didc=%qsysfunc(dclose(%superq(did)));
   %let rc=%qsysfunc(filename(fileref));
/*   %put _local_;*/
/*   %return;*/
   %if %superq(dsn) ^= and &nummem > 0 %then %do;
   data this;
      length Item 8 Path SubDir $512 Filename $124 Size CRDate CRTime ModDate ModTime 8; 
      format Size comma16. CRDate ModDate mmddyy10. CRTime ModTime time.;
      label Size='Size (Bytes)';
      %do i=1 %to &nummem;
      Path="%superq(dir)";
      SubDir=SUBSTR("%superq(dir)",%superq(rootdirlen));
      Item=&i;
      Filename="&&mem&i";
      Size=&&sz&i;
      CRDate=datepart(input("&&cr&i",datetime.));
      CRTime=timepart(input("&&cr&i",datetime.));
      ModDate=datepart(input("&&mod&i",datetime.));
      ModTime=timepart(input("&&mod&i",datetime.));
      output;
      %end;
   run;
   proc append base=%superq(dsn) data=this;
   run;
   proc delete data=this;
   run;
   %end;
   %else %do ;
      %put;
      %put NOTE: &nummem files found in %superq(dir):;
      %do i=1 %to &nummem;
      %put NOTE- &&mem&i &&bytes&i bytes,created &&created&i, modifed &&modifed&i  ;
      %end;
      %put;
   %end;
   proc sort data=%superq(dsn);
      by path filename;
   run;
   data %superq(dsn);
      modify %superq(dsn);
      subdir=tranwrd(path,"%superq(dir)",'');
   run;
%mend findfiles;

