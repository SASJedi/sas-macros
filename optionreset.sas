%macro OptionReset(opt);
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   August 14, 2012
   This macro is intended to reset any SAS system options which have been 
   changed during the SAS session back to the values they had at startup.  
   To see syntax help in the SAS log, submit: 
      %OptionReset(!HELP) 
  ***************************************************************************/
%local where;
%if %qupcase(%SUPERQ(opt))=!HELP 
   %then %do;
   %PUT ;
   %PUT NOTE:  *&SYSMACRONAME MACRO Documentation *******************************;
   %PUT NOTE-  This macro resets modified SAS system option values back to;
   %PUT NOTE-  the original startup values.;  
   %PUT ;
   %PUT NOTE-  >>>>> Tested on Windows only <<<<<;
   %PUT NOTE-  ;
   %PUT NOTE-  SYNTAX: %NRSTR(%%OptionReset%(<opt>%));
   %PUT NOTE-     opt: standard name of the SAS System option you want to reset;
   %PUT NOTE-     OPTIONAL - if not specified, resets any option with a current;
   %PUT NOTE-                value different from the startup value.;
   %PUT ;
   %PUT NOTE-  Examples: ;
   %PUT NOTE-     To reset only the LINESIZE option:;
   %PUT NOTE-        %NRSTR(%%OptionReset%(LINESIZE%));
   %PUT ;
   %PUT NOTE-     To reset all options:;
   %PUT NOTE-        %NRSTR(%%OptionReset%(%));
   %PUT ;
   %PUT NOTE-  ********************************************************************;
   %RETURN;
%end;

   %if &opt ne %then 
   %do;
      /* Normalize the input parameter value */
      %let opt=%qupcase(&opt);
      /* Look up the option name in the dictionary tables */
      proc sql noprint;
         select count(*) into :found
            from dictionary.options
            where optname="&opt"
      ;
      quit;
      %if not &found %then 
      %do;
      /* Option not listed in the dictionary tables */
         %put ERROR: (OptionReset Macro) &opt is not a valid SAS option;
         %return;
      %end;
      %else 
      %do;
      /* Option WAS listed - select only that option */
         %let WHERE=where optname ="&opt";
      %end;
   %end;
   %else 
   %do;
      /* No option specified                                     */
      /* Exclude options you can't change while SAS is executing */
      %let WHERE=where optstart ne 'startup' and optname not in ('AWSDEF','FONT');
   %end;

/* Reset those options that differ from the startup values */
data _null_;
   length statement startup current $1024;
   set sashelp.voption;
   &where;
   startup=getoption(optname,'startupvalue');
   current=getoption(optname);
   if startup ne current then do;
      PUTLOG "NOTE: OptionReset Macro Resetting " optname " from " current " to " startup ".";
      statement =cat('OPTIONS ',getoption(optname,'keyword, startupvalue'),';');
      call execute(statement );   
   end;
run;
%mend;

