%macro today(fmt);
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   Save the macro source code file (today.sas) in the AUTOCALL path. 
  ***************************************************************************/
   /* Set format to DATE9. default if user did not supply a format */
   %if %superq(fmt)= %then %let fmt=date9.;
   /* If the user requests help, supply documentation in the SAS log */
   %if %superq(fmt)=!HELP or %superq(fmt)=!DOC %then %do;
         %let MsgType=NOTE;
         %PUT &MSGTYPE:  &SYSMACRONAME MACRO &MSGTYPE ********************************;
   %Syntax:
         %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&sysmacroname%str(%(<format>%));
         %PUT &MSGTYPE-     format=Date format for displaying the date; 
         %PUT &MSGTYPE-     !HELP produces this syntax help in the SAS log;
         %PUT &MSGTYPE-     If left blank, the date is returnd using date9. format;
         %PUT ;
         %PUT &MSGTYPE-  Example: ;
         %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname%str(%(MMDDYY10.%));
         %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname%str(%(downame.%));
         %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname%str(%(%));
         %PUT ;
         %PUT &MSGTYPE-  *************************************************************;
         %RETURN;
   %end;
   /* Validate that FMT is a valid SAS name */
   %if %qsysfunc(notname(%qsysfunc(compress(%superq(fmt),'.')))) %then %do;
      %let MsgType=ERROR;
      %PUT &MSGTYPE:  &SYSMACRONAME MACRO &MSGTYPE ********************************;
      %PUT &MSGTYPE-  %superq(fmt) is not valid as a SAS numeric format name.;
      %goto Syntax;
   %end;

   /* Produce today's date in the requested format */
   %qsysfunc(strip(%qsysfunc(today(),%superq(fmt))))
%mend;
