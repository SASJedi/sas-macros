%macro putn(value,format);
  /***************************************************************************
   Created by Mark Jordan: http://go.sas.com/jedi or Twitter @SASJedi
   This macro program (putn.sas) should be placed in your AUTOCALL path.
  ***************************************************************************/
   %local MSGTYPE;
   %let msgtype=NOTE;
   %if %qsubstr(%SUPERQ(value),1,1)=! or %superq(value)=? %then %do;
   %syntax:
      %put;
      %put &msgtype: *&SYSMACRONAME macro help *****************************;
      %put &msgtype- Purpose: Formats a numeric value in SAS macro code.;
      %put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(value,format);
      %put &msgtype- value:  Required. Numeric value to format.;
      %put &msgtype- format: Required. Numeric format to apply to the value.;
      %put;
      %put NOTE-   Only numeric values and formats can be specified.;
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
   %if %datatyp(%superq(value))=CHAR %then
   %do;
      %let msgtype=ERROR;
      %put &msgtype: %nrstr(%%)&SYSMACRONAME cannot format character values.;
      %put;
      %goto syntax;
   %end;
   %if %index(%superq(format),$) %then 
   %do;
      %let msgtype=ERROR;
      %put &msgtype: %nrstr(%%)&SYSMACRONAME cannot accept the character format %superq(format).;
      %put;
      %goto syntax;
   %end;
   %if not (%index(%superq(format),.)) %then %let format=%superq(format).;
   %qsysfunc(strip(%qsysfunc(putn(%superq(value),%superq(format)))));
   %if &syscc ne 0 %then 
   %do;
      %let msgtype=WARNING;
      %put &MSGTYPE: (&SYSMACRONAME) Warning probably due to specifying bad format name.;
      %let SYSCC=0;
   %end;
%mend;
 
