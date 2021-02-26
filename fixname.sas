%macro fixname(badname);
%local MsgType;
%let MsgType=NOTE;
%if %superq(badname)= %then %do; 
   %let MsgType=ERROR;
   %put;
   %PUT &MsgType: *&SYSMACRONAME ERROR *******************************;
   %put &MsgType- You must supply a name.;
   %put;
   %goto Syntax; 
%end;
%if %SUPERQ(badname)=%str(?)  %then %do;
   %PUT &MsgType: *&SYSMACRONAME Documentation *******************************;
%Syntax:
   %PUT &MsgType-;
   %put &MsgType- Purpose: Create a valid SAS name from an input text string;
   %put &MsgType- Syntax: %nrstr(%%)&SYSMACRONAME(badname);
   %put &MsgType- badname: Text to be processed;
   %put ;
   %put &MsgType- Example: %nrstr(%%)&SYSMACRONAME(1 bad table name!);;
   %put ;
   %put &MsgType- Use ? to print documentation to the SAS log.;
   %put;
   %return;
%end; 

   %if %datatyp(%substr(%superq(badname),1,1))=NUMERIC 
		%then %let badname=_%superq(badname);
   %let badname=
		%qsysfunc(compress(
			%qsysfunc(translate(%superq(badname),_,%str( ))),,kn));
    %if %length(%superq(badname))>32 %then %let badname=%substr(%superq(badname),1,32);
	%superq(badname)
%mend fixname;