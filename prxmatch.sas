%macro prxmatch(regex, /*The regular expression*/
                string /*The string to test*/);
%let msgtype=NOTE;

%if %superq(regex)= %then %do;
   %let msgtype=ERROR;
   %put &msgtype: You must specify a regular expression.;
   %put;
   %goto syntax;
%end;
%if %superq(ref)=? %then %do;
%syntax:
   %put &msgtype: &SYSMACRONAME macro help document:;
   %put &msgtype- Purpose: Tests a string for a PERL regular expression match.;
   %put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(regex,string);
   %put &msgtype- regex:  The PERL regular expression. Required.;
   %put &msgtype- string: The text to search for a match. Required.;
   %put &msgtype-         Returns 0 for no match or character # where match starts;
   %put;
   %PUT &MSGTYPE-  Example:;
   %PUT &MSGTYPE-  %NRSTR(%prxmatch%(/\d\d\d/,abc123%));
   %put NOTE-   Use ? to print these notes.;
   %return;
%end;
%if %superq(string)= %then %do;
   %let msgtype=ERROR;
   %put &msgtype: You must specify a string to test.;
   %put;
   %goto syntax;
%end;

%sysfunc(prxmatch(%superq(regex),%superq(string)))
%mend prxmatch;
