%macro translate(text,to,from);
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   Save the macro source code file (translate.sas) in the AUTOCALL path. 
  ***************************************************************************/
   %if %superq(text)=!HELP or %superq(text)=!DOC %then %do;
         %let MsgType=NOTE;
         %PUT &MSGTYPE:  &SYSMACRONAME MACRO &MSGTYPE ********************************;
   %Syntax:
         %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&sysmacroname%str(%(text,to,from%));
         %PUT &MSGTYPE-     text=Text to be processed; 
         %PUT &MSGTYPE-     to=FROM is character changed to this value; 
         %PUT &MSGTYPE-     from=this character will be changed; 
         %PUT &MSGTYPE-     !HELP produces this syntax help in the SAS log;
         %PUT ;
         %PUT &MSGTYPE-  Example: ;
         %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname%str(%(Mr. Julia,s,r%));
         %PUT &MSGTYPE-  Result: Ms. Julia;
         %PUT ;
         %PUT &MSGTYPE-  *************************************************************;
         %RETURN;
   %end;
   /* Produce the translated text*/
   %qsysfunc(translate(%superq(text),%superq(to),%superq(from)))
%mend;
