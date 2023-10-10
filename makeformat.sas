%macro makeformat(formatName,fromDataSet,start,end,label,report);
	/* Self-documentation and robust parameter validation added  2023-09-14 by Mark Jordan */
	/* Setup */
	%local MsgType fmtType foundStart typeStart foundLabel typeLabel foundEnd typeEnd;
	%let MsgType=NOTE;

	/* Self-documentation */
	%if %SUPERQ(formatName)=? %then
		%do;
%Syntax:
			%put;
			%put &MsgType: &SYSMACRONAME documentation:;
			%put &MsgType- Purpose: Created a SAS format from a SAS dataset. ;
			%put &MsgType- %nrstr(This macro utility generates SAS code, so cannot be used in-line with other code.);
			%put &MsgType-;
			%put &MsgType- Syntax: %nrstr(%%)&SYSMACRONAME(formatName,fromDataSet,start<,end>,label<,report>);
			%put &MsgType-;
			%put &MsgType-  formatName: Valid user-defined format name;
			%put &MsgType- fromDataSet: Dataset name from which the format is to be created;
			%put &MsgType-       start: Dataset variable containing the value to be looked up;
			%put &MsgType-              or the starting value of a range;
			%put &MsgType-         end: *Variable containing end of range value;
			%put &MsgType-       label: Dataset variable containing the value to be displayed;
			%put &MsgType-      report: *(N|Y) Create a format report? Default is No;
			%put &MsgType-;
			%put &MsgType-  *Optional;
			%put &MsgType-;
			%put &MsgType- Example: %nrstr(%%)&SYSMACRONAME($fmtCFCC,sashelp.ltheme,CFCC,,Name,Y);
			%put &MsgType-;
			%put &MsgType- Use ? to print documentation to the SAS log.;
			%put &MsgType-;
			%return;
		%end; 
	
	/* Parameter validation */
	/* Do all required parameters have values provided? */
	%if %superq(formatName)= or 
		 %superq(fromDataSet)= or 
		 %superq(start)= or 
		 %superq(label)= %then 
		%do; 
			%let MsgType=ERROR;
			%put;
			%put &MsgType: &SYSMACRONAME Error:;
			%put &MsgType- formatName, fromDataSet, START, and LABLE are required arguments.;
			%goto Syntax; 
		%end;
	/* Set Report default value if necessary, standardize input */
	%if %superq(report)= %then %let report=N;
	%let report=%qsubstr(%qupcase(%superq(report)),1,1);

	/* If end is not specified, set END to START value */
	%if %superq(end)= %then %let end=%superq(start);

	/* Is the specified format name valid? */
	%if %qsubstr(%superq(formatName),1,1)=$ %then %do;
		%let formatName=%qsubstr(%superq(formatName),2);
		%let fmtType=$;
	%end;

	%if %sysfunc(notname(%superq(formatName)))>0 %then 
		%do; 
			%let MsgType=ERROR;
			%put;
			%put &MsgType: &SYSMACRONAME Error:;
			%put &MsgType- %superq(formatName) is not a valid format name.;
			%put;
			%goto Syntax; 
		%end;

	/* Does the specified dataset exist? */
	%if %sysfunc(exist(%superq(fromDataSet)))=0 %then 
		%do; 
			%let MsgType=ERROR;
			%put;
			%put &MsgType: &SYSMACRONAME Error:;
			%put &MsgType- Data set %superq(fromDataSet) does not exist.;
			%put;
			%goto Syntax; 
		%end;

	/* Variable check */
	%let fromDataSet=%qupcase(%superq(fromDataSet));
	%let lib=%qscan(%superq(fromDataSet),1,.);
	%let mem=%qscan(%superq(fromDataSet),-1,.);
	%if %superq(lib)=%superq(mem) %then %let lib=WORK;
	/* Look up columns and evaluate type */
	data _null_;
		retain fmtType 'num ' S E L 'Not Found';
		if _n_ =1 then do;
			if "&fmtType"="$" then fmtType='char';
			if fmtType='N' then putlog "NOTE:Numeric format &fmtType&formatName requested."; 
			if fmtType='C' then putlog "NOTE: Character format &fmtType&formatName requested."; 
		end;
		set sashelp.vcolumn(keep=LIBNAME MEMNAME NAME TYPE);
		where libname="%superq(lib)" and memname="%superq(mem)";
		count+1;
		if upcase(Name)=upcase("%superq(Start)") then do;
			S='Found';
			call symputx('foundStart','OK','L');
			if Type=fmtType then do;
				call symputx('typeStart','OK','L');
				putlog "NOTE- Start variable type matches format type.";
			end;
		end;
		if S='Found' and upcase("%superq(Start)")=upcase("%superq(End)")
			or upcase(Name)=upcase("%superq(End)") then 
			do;
				E='Found';
				call symputx('foundEnd','OK','L');
				if Type=fmtType then do;
					call symputx('typeEnd','OK','L');
					putlog "NOTE- End variable type matches format type.";
			end;
		end;
		if upcase(Name)=upcase("%superq(Label)") then do;
			L='Found';
			call symputx('foundLabel','OK','L');
		end;
	run;

	%put _local_;
	/* Does the specified Start variable exist? */
	%if &foundStart= %then 
		%do;
			%let MsgType=ERROR;
			%put;
			%put &MsgType: &SYSMACRONAME Error:;
			%put &MsgType- The specified START variable, %superq(Start), does not exist in %superq(fromDataSet).;
			%put;
			%return; 
		%end;

	/* Does the specified Lable variable exist? */
	%if &foundLabel= %then 
		%do;
			%let MsgType=ERROR;
			%put;
			%put &MsgType: &SYSMACRONAME Error:;
			%put &MsgType- The specified LABEL variable, %superq(Label), does not exist in %superq(fromDataSet).;
			%put;
			%return; 
		%end;

	/* Does the variable data type match the specified format type? */
	%if &typeStart= %then 
		%do;  
			%if &fmtType=%str($) %then 
			%do;
				%let MsgType=ERROR;
				%put;
				%put &MsgType: &SYSMACRONAME Error:;
				%put &MsgType- Character format specified, but Start variable is numeric.;
				%put;
				%return; 
			%end;
		%else 
			%do;
				%let MsgType=ERROR;
				%put;
				%put &MsgType: &SYSMACRONAME Error:;
				%put &MsgType- Numeric format specified, but Start variable is character.;
				%put;
				%return; 
			%end;
		%end;

	/* If specified, does the END variable exist? */
	%if not(%superq(End)=) %then 
		%do;
			%if &foundEnd= %then
				%do;
					%let MsgType=ERROR;
					%put;
					%put &MsgType: &SYSMACRONAME Error:;
					%put &MsgType- The specified END variable, %superq(End), does not exist in %superq(fromDataSet).;
					%put;
					%return; 
				%end;
			%if &typeEnd= %then 
				%do;  
					%if &fmtType=%str($) %then 
					%do;
						%let MsgType=ERROR;
						%put;
						%put &MsgType: &SYSMACRONAME Error:;
						%put &MsgType- Character format specified, but End variable is numeric.;
						%put;
						%return; 
					%end;
					%else 
						%do;
							%let MsgType=ERROR;
							%put;
							%put &MsgType: &SYSMACRONAME Error:;
							%put &MsgType- Numeric format specified, but End variable is character.;
							%put;
							%return; 
						%end;
				%end;
		%end;

	/* Do the work */
	proc fedsql;
		drop table %superq(formatName) force;
	quit;
	
	proc sql;
	create table %superq(formatName) as
	select "&fmtType%superq(formatName)" as fmtname
			,%superq(Start) as Start
			,%superq(End) as End
			,%superq(Label) as Label
		from %superq(fromDataSet)
		order by 2
	;
	quit;

	%if %superq(report)= Y %then %do;
	title "%qupcase(%superq(formatName)) format based on %upcase(&fromDataSet)";
	proc format cntlin=%superq(formatName) fmtlib;
	%end;
	%else %do;
	ods exclude FORMAT;
	proc format cntlin=%superq(formatName);
	%end;
		select &fmtType%superq(formatName);
	run;
	title;
	
	proc fedsql;
		drop table %superq(formatName) force;
	quit;
%mend makeformat;
