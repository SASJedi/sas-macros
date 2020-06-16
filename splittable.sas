%macro SplitTable(table,column,keep,outlib);
   %local msgtype libname memname type prefix maxval stop;
   /* Begin Self-documentation parameter validation code */
   %let MSGTYPE=NOTE;
   %if %superq(table)= %then
      %do;
         %let MSGTYPE=ERROR;
         %put &MSGTYPE: &SYSMACRONAME Syntax Error ***********;
         %put &MSGTYPE- No table specified. Both table and column are required.;

   %syntax:
         %put &MSGTYPE: &SYSMACRONAME Syntax *****************;
         %put &MSGTYPE- Purpose: Splits a table into subsets based on the;
         %put &MSGTYPE- values found in a column.;
         %put;
         %put &MSGTYPE- Syntax: %nrstr(%%)&SYSMACRONAME(table,column<,keep,outlib>);
         %put;
         %put &MSGTYPE- Arguments:;
         %put &MSGTYPE-    table: Source table name;
         %put &MSGTYPE-   column: Column values used to subset the data. Character columns;
         %put &MSGTYPE-           must contain valid SAS names. Numeric columns prefixed with;
         %put &MSGTYPE-           a portion of the column name must produce a valid SAS name.;
         %put &MSGTYPE-     keep: Keep the split column in output? (DROP|KEEP);
         %put &MSGTYPE-           Optional - default is DROP;
         %put &MSGTYPE-   outlib: Output libref. Optional - default is WORK;
         %put;
         %put &MSGTYPE- Use !HELP to print these notes.;
         %put;
         %PUT &MSGTYPE-  Example:;
         %PUT &MSGTYPE-  %NRSTR(%%)&SYSMACRONAME%NRSTR(%(sashelp.iris,species));
         %PUT;
         %put &MSGTYPE- &SYSMACRONAME ************************;
         %put;

         %return;
      %end;
   %if %superq(table)=? or %qupcase(%superq(table))=!HELP %then
      %goto syntax;
   %if %superq(column)= %then
      %do;
         %let MSGTYPE=ERROR;
         %put &MSGTYPE: &SYSMACRONAME Syntax Error ***********;
         %put &MSGTYPE- Table was "%superq(table)" / column was blank.;
         %put &MSGTYPE- Both table and column are required.;
         %put;
         %goto syntax;
      %end;
   %if %qupcase(%superq(keep)) ne DROP 
      and %qupcase(%superq(keep)) ne KEEP 
      and %qupcase(%superq(keep)) ne %then
      %do;
         %let MSGTYPE=ERROR;
         %put &MSGTYPE: &SYSMACRONAME Syntax Error ***********;
         %put &MSGTYPE- KEEP value of "%superq(keep)" is invalid;
         %put &MSGTYPE- Use DROP or KEEP. If left blank, default is DROP;
         %put;
         %goto syntax;
      %end;
   %if not(%sysfunc(exist(%superq(table)))) %then
      %do;
         %let MSGTYPE=ERROR;
         %put &MSGTYPE: &SYSMACRONAME Syntax Error ***********;
         %put &MSGTYPE- Table "%superq(table)" does not exist.;
         %put;
         %goto syntax;
      %end;
   /* End Self-documentation and parameter validation code */
   /* Begin parameter normalization */
   %let table=%qupcase(%superq(table));
   %if %qscan(%superq(table),1)=%superq(table) %then
      %do;
         %let libname=WORK;
         %let memname=%superq(table);
      %end;
   %else
      %do;
         %let libname=%qscan(%superq(table),1);
         %let memname=%qscan(%superq(table),2);
      %end;
   %if %superq(outlib)= %then
      %do;
         %let outlib=WORK;
      %end;
   %if %qupcase(%superq(keep)) = %then
      %do;
         %let keep=DROP;
      %end;
   /* End parameter normalization */
   option nonotes;

   proc sql noprint;
      select type into :type
         from dictionary.columns
            where libname="&libname" 
               and memname="&memname" 
               and upcase(name)="%qupcase(%superq(column))" 
      ;
   quit;

   %if &type=num %then
      %do;

         proc sql noprint;
            select max (%superq(column)) into :maxval trimmed
               from %superq(table);
         quit;

         %if %index(&maxval,E) %then
            %do;
               %let stop=%eval(32-%qscan(&maxval,-1,E));
            %end;
         %else
            %do;
               %let stop=%eval(32-%length(&maxval));
            %end;

         %let prefix=%qupcase(%qsysfunc(substrn(%superq(column),1,&stop)));
      %end;

   proc sql noprint;
      select distinct %superq(column)
         into :Table1-
            from %superq(table)
      ;
   quit;

   option notes;
   %if &sqlobs=0 %then
      %do;
         %let MSGTYPE=ERROR;
         %put &MSGTYPE: &SYSMACRONAME Syntax Error ***********;
         %put &MSGTYPE- Column %qupcase(%superq(column)) not found in table %superq(table).;
         %put;
         %goto syntax;
      %end;

   %do i=1 %to &sqlobs;
      %if not(%sysfunc(nvalid(&prefix%superq(Table&i)))) %then
         %do;
            %let MSGTYPE=ERROR;
            %put &MSGTYPE: &SYSMACRONAME Syntax Error ***********;
            %put &MSGTYPE- Cannot produce a valid SAS name from values in %qupcase(%superq(column)).;
            %put;
            %goto syntax;
         %end;
   %end;

   data 
      %do i=1 %to &sqlobs;
         %unquote(%superq(outlib).&prefix%superq(Table&i))
      %end;
   ;
   set %superq(table);
   select(%superq(column));
      %if %superq(type)=num %then
         %do i=1 %to &sqlobs;
            when (%superq(Table&i)) output %unquote(%superq(outlib).&prefix%superq(Table&i));
         %end;
      %else
         %do i=1 %to &sqlobs;
            when ("%superq(Table&i)") output %unquote(%superq(outlib).&prefix%superq(Table&i));
         %end;
   end;
   %if %qupcase(%superq(keep))=DROP %then
      %do;
         drop %superq(column);
      %end;
   run;

%mend SplitTable;