%macro BenchmarkReport(dsn,FileName1,FileName2,TimesToRun,Details);
  /***************************************************************************
   Created by Mark Jordan: http://go.sas.com/jedi or Twitter @SASJedi
   This macro program (benchmarkreport.sas) should be placed in your AUTOCALL 
   path. It is required to suport the %benchmark macro. It is not designed
   to be called by itself, so has minimal parameter checking and error
   message capability.
  ***************************************************************************/
   %let MSGTYPE=NOTE;
   %if %superq(dsn)=? %then
      %do;
         %PUT &MSGTYPE:  *BenchmarkReport MACRO Documentation *******************************;
         %PUT &MSGTYPE-  %NRSTR(SYNTAX: %%BenchmarkReport%(dsn,FileName1,FileNam2,TimesToRun%));
         %PUT &MSGTYPE-     DSN=Name of the data set produced by the benchmarkparse macro;
         %PUT &MSGTYPE-         Default: work.;
         %PUT &MSGTYPE-         Example: work.MyData;
         %PUT &MSGTYPE-     FileName1=First program file name;
         %PUT &MSGTYPE-         Example: MyProgram1;
         %PUT &MSGTYPE-     FileName2=Second program file name;
         %PUT &MSGTYPE-         Example: MyProgram2;
         %PUT &MSGTYPE-     TimesRun=Number of times the original program was run (integers only);
         %PUT &MSGTYPE-         Default: 5;
         %PUT &MSGTYPE-     Detals=Include detailed data report (Y or N);
         %PUT &MSGTYPE-         Default: N;
         %PUT;
         %PUT &MSGTYPE-  Example:;
         %PUT &MSGTYPE-  Benchmarking a program: ;
         %PUT &MSGTYPE-  %NRSTR(%%BenchmarkReport%(work.MyParsedData);
         %PUT &MSGTYPE-  %NRSTR(           ,test1.sas);
         %PUT &MSGTYPE-  %NRSTR(           ,test2.sas);
         %PUT &MSGTYPE-  %NRSTR(           ,5%));
         %PUT &MSGTYPE-  *************************************************************;
         %PUT ;
         %PUT NOTE:  Designed to be called by the %NRSTR(%%)benchmark macro. Not intended for stand-alone use.;
         %PUT NOTE:  Use %NRSTR(%%)&SYSMACRONAME%nrstr(%(?%)) for help.;
         %PUT ;
         %RETURN;
      %end;
   %if %qsubstr(%SUPERQ(dsn),1,1)=! or %superq(dsn)=? %then goto Syntax;
   %if %SUPERQ(DSN)= %then
      %do;
         %let DSN=work.logparse_data;
         %put NOTE: BenchmarkReport MACRO:;
         %PUT NOTE- Using default dataset work.logparse_data;
      %end;
   %if %SUPERQ(Details) = %then   %let Details=N;
   %if %SUPERQ(TimesToRun)= %then %let TimesToRun=5;
   %macro auto_outliers(
   Dsn=,      /* Data set name                        */
   ID=,       /* Name of ID variable                  */
   Var_list=, /* List of variables to chec k          */
              /* separate names with spaces           */
   Trim=.1,   /* Integer 0 to n = number to trim      */
              /* from each tail; if between 0 and .5, */
              /* proportion to trim in each tail      */
   N_sd=2     /* Number of standard deviations        */);
   options VARINITCHK=NOTE;
   ods output TrimmedMeans=trimmed(keep=VarName Mean Stdmean DF);
   ods select TrimmedMeans;
   proc univariate data=&Dsn trim=&Trim;
     var &Var_list;
   run;
   ods output close;
   data restructure;
      set &Dsn;
      length Varname $ 32;
      array vars[*] &Var_list;
      do i = 1 to dim(vars);
         Varname = vname(vars[i]);
         Value = vars[i];
         output;
      end;
      keep &ID Varname Value;
   run;

   proc sort data=trimmed;
      by Varname;
   run;

   proc sort data=restructure;
      by Varname;
   run;

   data GoodData (keep=&ID) 
        Outliers;
      merge restructure trimmed;
      by Varname;
      Std = StdMean*sqrt(DF + 1);
      if Value lt Mean - &N_sd*Std and not missing(Value) 
         then do;
            Reason = 'Low  ';
            output outliers ;
         end;
      else if Value gt Mean + &N_sd*Std
         then do;
         Reason = 'High';
         output outliers ;
      end;
      else output GoodData;
   run;

   proc sort data=outliers;
      by &ID;
   run;

   title "Outliers Excluded from Comparison";
   proc print data=outliers;
      id &ID;
      var Varname Value Reason;
   run;

   proc datasets nolist library=work;
      delete trimmed;
      delete restructure;
      *Note: work data set outliers not deleted;
   run;
   quit;
%mend auto_outliers;

   title;footnote;

   proc sql noprint;
      create table Run_Summary_Stats as
         select
              Program
            , input(SCAN(logfile,-2,'_. '),4.) as Run
            , stepname 'Process' as Process
            , realtime 'Elapsed' format=comma10.3 as Elapsed
            , cputime 'CPU Time' format=comma10.3 as CPU_Total
            , osmem 'Memory' format=comma12. as Memory_Total
            , Score  format=comma10.3 
            from &dsn 
            where stepname='SAS' 
            Order by 1,2
      ;
quit;
%auto_outliers(Dsn=Run_summary_stats
              ,ID=Program Run
              ,Var_list=Elapsed CPU_Total Memory_Total
              ,Trim=.1
              ,N_sd=2.5);
proc sort data=Run_Summary_Stats;
   by Program Run;
run;
proc sort data=GoodData nodupkey;
   by Program Run;
run;
    
data ReportMe;
   merge Run_Summary_Stats 
         GoodData(in=good);
   by Program Run;
   if good;
run;

proc sql noprint;
      select MIN(Score) as Min
           , MAX(Score) as Max
      into :MinScore1-, :MaxScore1-
         from ReportMe
         group by Program
         order by Min, Max
   ;
quit;

   ods proclabel='Scores';
   proc sql;
   title "Benchmark Score for ";
   title2 "&FileName1 vs. &FileName2";
/*   footnote "Score=(2*CPU Time)+Clock Time";*/
   select 
      Program
      ,avg(Elapsed) "Clock Time" format=comma10.2
      ,AVG(CPU_Total)  "CPU Time" format=comma10.2
      ,AVG(Memory_Total)  "Memory" format=comma12.
/*      ,AVG(Score) "Score" format=comma10.2*/
      from ReportMe
      group by Program
   ;
   quit;
   footnote;
   title "Summaries for each run";
   ods proclabel="Run Summaries";
   proc sql;
   select 
         Program
         ,Run
         ,Elapsed "Clock Time" format=comma10.2
         ,CPU_Total  "CPU Time" format=comma10.2
         ,Memory_Total  "Memory" format=comma12.
/*         ,Score format=comma12.2*/
      from ReportME
      order by Program, Run
   ;
   quit;
   footnote;
   %if %superq(details)=Y %then %do;
   ods proclabel='Detail Data';
   title "Detailed Data for each run";
   proc sql;
   select 
          Program
         ,INPUT(SCAN(Logfile,-2,'._'),4.) as Run
         ,stepcnt
         ,stepname
         ,platform
         ,Score
         ,realtime
         ,usertime
         ,systime
         ,cputime
         ,obsin
         ,obsout
         ,varsout
         ,osmem
      from &dsn
   ;
   quit;
   footnote;
   %end;
   title;
%mend BenchmarkReport;
