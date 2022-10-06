%macro tranwrd(text,from,to);
  /***************************************************************************
   Created by Mark Jordan - http://go.sas.com/jedi
   Save the macro source code file (translate.sas) in the AUTOCALL path. 
  ***************************************************************************/
   %let MsgType=NOTE;
   %if %superq(text)=? %then %do;
         %PUT &MSGTYPE:  &SYSMACRONAME MACRO &MSGTYPE ********************************;
   %Syntax:
         %PUT &MSGTYPE-  SYNTAX: %NRSTR(%%)&sysmacroname%str(%(text,from,to%));
         %PUT &MSGTYPE-     text=Text to be processed; 
         %PUT &MSGTYPE-     from=the character string to be replaced; 
         %PUT &MSGTYPE-     to= the character string which replaces the FROM character string; 
         %PUT &MSGTYPE-     ? produces this syntax help in the SAS log;
         %PUT ;
         %PUT &MSGTYPE-  Example: ;
         %PUT &MSGTYPE-  %NRSTR(%%)&sysmacroname%str(%(The lazy fox,lazy,sly%));
         %PUT &MSGTYPE-  Result: The sly fox;
         %PUT ;
         %PUT &MSGTYPE-  *************************************************************;
         %RETURN;
   %end;
   %if %superq(text)=? %then %goto syntax;
   /* Produce the translated text*/
   %qsysfunc(tranwrd(%superq(text),%superq(from),%superq(to)))
%mend;
