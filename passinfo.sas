  /******************************************************************
   The %PASSINFO macro prints session information to the SAS log
   for performance analysis.  Downloaded from http://support.sas.com
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

