%macro Benchmark(ProgramFile1,ProgramFile2,TimesToRun,Details);
  /***************************************************************************
   Created by Mark Jordan: http://go.sas.com/jedi or Twitter @SASJedi
   This macro program (benchmark.sas) should be placed in your AUTOCALL path, 
   along with the supporting macro programs:
   1. benchmarkreport.sas
   2. logparse.sas
   3. passinfo.sas 
  ***************************************************************************/
%let MSGTYPE=NOTE;
%if %superq(ProgramFile1)=? %then %do;
   %PUT &MSGTYPE:  *&SYSMACRONAME Documentation *******************************;
%syntax: %put;
   %PUT &MSGTYPE-  SYNTAX: %NRSTR(%benchmark%(ProgramFile1,ProgramFile2,TimesToRun,Details%));
   %PUT &MSGTYPE-     ProgramFile1=Fully qualified filename of first program;
   %PUT &MSGTYPE-     ProgramFile2=Fully qualified filename of second program;
   %PUT &MSGTYPE-     TimesToRun=number of times to run program (integers only);
   %PUT &MSGTYPE-         Default: 5;
   %PUT &MSGTYPE-     Detals=Include detailed data report (Y or N);
   %PUT &MSGTYPE-         Default: N;
   %PUT ;
   %PUT &MSGTYPE-  Example:;
   %PUT &MSGTYPE-  Benchmarking a program:;
   %PUT &MSGTYPE-  %NRSTR(%benchmark%(s:\workshop\MyProgram1.sas);
   %PUT &MSGTYPE-  %NRSTR(           ,s:\workshop\MyProgram2.sas,6,Y%));
   %PUT &MSGTYPE-  *************************************************************;
   %PUT ;
   %PUT NOTE:  Use %NRSTR(%%)&SYSMACRONAME%nrstr(%(?%) or %%)&SYSMACRONAME%nrstr(%(!HELP%)) for help.;
   %PUT ;
   %RETURN;
%end;
%if %qupcase(%qsubstr(%superq(ProgramFile1),1,5))=!HELP %then goto Syntax;
%if %SUPERQ(ProgramFile1)= %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %PUT &MSGTYPE-  You must specify the name of the first SAS program file;
   %PUT &MSGTYPE-  If not in the default directory, include full path;
   %goto Syntax;
%end;
%if %SUPERQ(ProgramFile2)= %then %do;
   %let MSGTYPE=ERROR;
   %PUT &MSGTYPE:  *&sysmacroname ERROR ***************************************;
   %PUT &MSGTYPE-  You must specify the name of the second SAS program file;
   %PUT &MSGTYPE-  If not in the default directory, include full path;
   %goto Syntax;
%end;
   %if %SUPERQ(Details) = %then   %let Details=N;
   %if %SUPERQ(TimesToRun)= %then %let TimesToRun=5;
   %put NOTE: BENCHMARK MACRO:;
   %PUT NOTE- Benchmarking program %superq(ProgramFile1) vs. %superq(ProgramFile2);
   %PUT NOTE- Running each program &TimesToRun times;
   %PUT ;
  /* Capture the path to the SAS executable file - this works ONLY on WINDOWS */
   %let StartSAS="%sysget(SASROOT)\sas.exe";
  /* Identify the WORK library's physical location - we'll write our temp files there */
   %let TempPath=%qsysfunc(PATHNAME(WORK));
   %Let FileName1=%qscan(%superq(ProgramFile1),-1,/\);
   %Let FileName2=%qscan(%superq(ProgramFile2),-1,/\);

/* The work starts here */
/*First, add calls to the passinfo macro and OPTIONS FULLSTIMER to pgrgram file*/
data _null_;
   infile "&ProgramFile1" ;
   file "&TempPath\test1.sas";
   if _n_=1 then do;
      PUT "OPTIONS FULLSTIMER NOMPRINT NOSOURCE NOMLOGIC NOSYMBOLGEN SPOOL;";
      PUT '%PASSINFO';
   end;
   input;
   put _infile_;
RUN;
data _null_;
   infile "&ProgramFile2" ;
   file "&TempPath\test2.sas";
   if _n_=1 then do;
      PUT "OPTIONS FULLSTIMER NOMPRINT NOSOURCE NOMLOGIC NOSYMBOLGEN SPOOL;";
      PUT '%PASSINFO';
   end;
   input;
   put _infile_;
RUN;

proc delete data=Logparse_data;
run;
options xwait;

%LET COMMAND=%str(&StartSAS -sysin "&TempPath\test1.sas" -log "&TempPath\test_1.log" -print "&TempPath\test_1.lst" -nosplash -fullstimer -noterminal -ICON);
%PUT NOTE: Executing command: &command;
%sysexec %bquote(&COMMAND);

%do i=1 %to &TimesToRun;
   %LET COMMAND=%str(&StartSAS -sysin "&TempPath\test1.sas" -log "&TempPath\test1_&I..log" -print "&TempPath\test1_&I..lst" -nosplash -fullstimer -noterminal -ICON);
   %sysexec %bquote(&COMMAND);
   %BenchmarkParse(%qscan(%SUPERQ(ProgramFile1),-1,%str(/\)),%str(&TempPath\test1_&i..log),append=YES)
%end;

%do i=1 %to &TimesToRun;
   %LET COMMAND=%str(&StartSAS -sysin "&TempPath\test2.sas" -log "&TempPath\test2_&I..log" -print "&TempPath\test2_&I..lst" -nosplash -fullstimer -noterminal -ICON);
   %sysexec %bquote(&COMMAND);
   %BenchmarkParse(%qscan(%SUPERQ(ProgramFile2),-1,%str(/\)),%str(&TempPath\test2_&i..log),append=YES)
%end;

%BenchmarkReport(work.logparse_data,%qscan(%SUPERQ(ProgramFile1),-1,%str(/\)),%qscan(%SUPERQ(ProgramFile2),-1,%str(/\)),%SUPERQ(TimesToRun))
%mend BenchMark;
/******************************************************************
*
* The %PASSINFO macro prints session information to the SAS log
* for performance analysis.
* 
* See the README file for instructions.
*
*******************************************************************/


%macro passinfo;
  %if ( &SYSSCP = OS ) %then /* MVS platform */
     %mvsname;

  data _null_;
    length  hostname $ 80;
    hostname=' ';  /* avoid message about uninitialized */
    temp=datetime();
    temp2=lowcase(trim(left(put(temp,datetime16.))));
    call symput('datetime', trim(temp2));

  %if ( &SYSSCP = WIN )                            /* windows platforms */
  %then %do;
    call symput('host', "%sysget(computername)");
  %end;
  %else %if ( &SYSSCP = OS )                            /* MVS platform */
  %then %do;
    call symput('host', "&syshost");
  %end;
  %else %if ( &SYSSCP = VMS ) or ( &SYSSCP = VMS_AXP )  /* VMS platform */
  %then %do;
    hostname = nodename();
    call symput('host', hostname);
  %end;
  %else %do;              /* all UNIX platforms */
    filename gethost pipe 'uname -n';
    infile gethost length=hostnamelen;
    input hostname $varying80. hostnamelen;
    call symput('host', hostname);
  %end;

  run;

  %put PASS HEADER BEGIN;
  %put PASS HEADER os=&sysscp;
  %put PASS HEADER os2=&sysscpl;
  %put PASS HEADER host=&host;
  %put PASS HEADER ver=&sysvlong;
  %put PASS HEADER date=&datetime;
  %put PASS HEADER parm=&sysparm;

  proc options option=MEMSIZE; run;
  proc options option=SUMSIZE; run;
  proc options option=SORTSIZE; run;

  %put PASS HEADER END;

%mend passinfo;