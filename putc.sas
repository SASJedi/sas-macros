%macro putc(value,format);
  /***************************************************************************
   Created by Mark Jordan: http://go.sas.com/jedi or Twitter @SASJedi
   This macro program (putc.sas) should be placed in your AUTOCALL path.
  ***************************************************************************/
   %local MSGTYPE;
   %let msgtype=NOTE;
   %if %superq(value)=? or %qupcase(%superq(value))=!HELP %then %do;
   %syntax:
      %put;
      %put &msgtype: *&SYSMACRONAME macro help *****************************;
      %put &msgtype- Purpose: Formats a character value in SAS macro code.;
      %put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(value,format);
      %put &msgtype- value:  Required. Character value to format.;
      %put &msgtype- format: Required. Character format to apply to the value.;
      %put;
      %put NOTE-   Only character values and formats can be specified.;
      %put &msgtype- *******************************************************;
      %put;
      %return;
   %end;
	%if %superq(value)= or %superq(format)= %then
   %do;
      %let msgtype=ERROR;
      %put &msgtype: %nrstr(%%)&SYSMACRONAME requires you to supply values for both parameters.;
      %put;
      %goto syntax;
   %end;
   %if not(%index(%superq(format),$)) %then 
   %do;
      %let msgtype=ERROR;
      %put &msgtype: %nrstr(%%)&SYSMACRONAME cannot accept the numeric format %superq(format).;
      %put;
      %goto syntax;
   %end;
   %if not (%index(%superq(format),.)) %then %let format=%superq(format).;
   %qsysfunc(strip(%qsysfunc(putc(%superq(value),%superq(format)))))
   %if &syscc ne 0 %then 
   %do;
      %let msgtype=WARNING;
      %put &MSGTYPE: (&SYSMACRONAME) Warning probably due to specifying bad format name.;
      %let SYSCC=0;
   %end;
%mend;
 
