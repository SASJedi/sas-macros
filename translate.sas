%macro translate(text,to,from);
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   Save the macro source code file (translate.sas) in the AUTOCALL path. 
  ***************************************************************************/
   %let MsgType=NOTE;
   %if %superq(text)=? %then %do;
         %PUT &MSGTYPE:  &SYSMACRONAME MACRO &MSGTYPE ********************************;
   %Syntax:
         %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&sysmacroname%str(%(text,to,from%));
         %PUT &MSGTYPE-     text=Text to be processed; 
         %PUT &MSGTYPE-     to= the character which replaces the FROM character; 
         %PUT &MSGTYPE-     from=the character to be replaced; 
         %PUT &MSGTYPE-     ? or !HELP produces this syntax help in the SAS log;
         %PUT ;
         %PUT &MSGTYPE-  Example: ;
         %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname%str(%(Mr. Julia,s,r%));
         %PUT &MSGTYPE-  Result: Ms. Julia;
         %PUT ;
         %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname%str(%(angle,pp,ng%));
         %PUT &MSGTYPE-  Result: apple;
         %PUT ;
         %PUT &MSGTYPE-  *************************************************************;
         %RETURN;
   %end;
   %if %qupcase(%superq(text))=!HELP %then %goto syntax;
   /* Produce the translated text*/
   %qsysfunc(translate(%superq(text),%superq(to),%superq(from)))
%mend;
