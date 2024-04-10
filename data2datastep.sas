%macro data2datastep(dsn,lib,outlib,file,obs,fmt,lbl);
	%local varlist fmtlist inputlist msgtype;

	%if %superq(obs)= %then
		%let obs=MAX;
	%let msgtype=NOTE;

	%if %superq(dsn)= %then
		%do;
			%let msgtype=ERROR;
			%put &msgtype: * &SYSMACRONAME ERROR ************************************;
			%put &msgtype: You must specify a data set name;

	%syntax:
			%put %str( );
			%put &msgtype- Purpose: Writes a SAS DATA step that re-creates a data set.;
			%put %str( );
			%put &msgtype- Syntax: %nrstr(%%)&SYSMACRONAME(dsn<,lib,outlib,file,obs,fmt,lbl>);
			%put %str( );
			%put &msgtype- dsn:    Name of the dataset to be converted. Required.;
			%put &msgtype- lib:    LIBREF of the original dataset. (Optional);
			%put &msgtype- outlib: LIBREF for the output dataset. (Optional);
			%put &msgtype- file:   Fully qualified filename for DATA step code. (Optional);
			%put &msgtype-         Default is %nrstr(create_&outlib._&dsn._data.sas);
			%put &msgtype-         in the SAS default directory.;
			%put &msgtype- obs:    Max observations to include the created dataset.;
			%put &msgtype-         (Optional) Default is MAX (all observations);
			%put &msgtype- fmt:    Copy numeric variable formats?;
			%put &msgtype-         (YES|NO - Optional) Default is YES;
			%put &msgtype- lbl:    Copy column labels?;
			%put &msgtype-         (YES|NO - Optional) Default is YES;
			%put %str( );
			%put &msgtype- CAVEATS:;
			%put &msgtype- &SYSMACRONAME generates code and cannot be used in-line.;
			%put &msgtype- Character formats are ignored.;
			%put %str( );
			%put NOTE- Examples:;
			%put NOTE- Create a DATA step program in my home folder named make_class.sas;
			%put NOTE- that recreates the CLASS dataset from the SASHELP library (SASHLEP.CLASS);
			%put NOTE- WORK library (WORK.CLASS), containing only 5 observations:;
			%put %str( );
			%put NOTE- %nrstr(%%)Data2DataStep(class,sashelp,work,~/make_class.sas,5);
			%put %str( );
			%put NOTE- Use ? to print these notes.;
			%put %str( );

			%return;
		%end;

	%let dsn=%qupcase(%superq(dsn));

	%if %superq(dsn)=? %then
		%do;
			%put &msgtype: * &SYSMACRONAME help ************************************;
			%goto Syntax;
		%end;

	%if %superq(fmt)= %then
		%let fmt=YES;
	%let fmt=%qupcase(&fmt);

	%if %superq(lbl)= %then
		%let lbl=YES;
	%let lbl=%qupcase(&lbl);

	%if %superq(lib)= %then
		%do;
			%let lib=%qscan(%superq(dsn),1,.);

			%if %superq(lib) = %superq(dsn) %then
				%let lib=WORK;
			%else %let dsn=%qscan(&dsn,2,.);
		%end;

	%if %superq(outlib)= %then
		%let outlib=WORK;
	%let lib=%qupcase(%superq(lib));
	%let dsn=%qupcase(%superq(dsn));

	%if %sysfunc(exist(&lib..&dsn)) ne 1 %then
		%do;
			%put ERROR: (&SYSMACRONAME) - Dataset &lib..&dsn does not exist.;
			%let msgtype=NOTE;
			%GoTo syntax;
		%end;

	%if %superq(file)= %then
		%do;
			%let file=create_&outlib._&dsn._data.sas;

			%if %symexist(USERDIR) %then
				%let file=&userdir/&file;
		%end;

	%if %symexist(USERDIR) %then
		%do;
			%if %qscan(%superq(file),-1,/\)=%superq(file) %then
				%let file=&userdir/&file;
		%end;

	proc sql noprint;
		select Name
			into :varlist separated by ' '
				from dictionary.columns
					where libname="&lib"
						and memname="&dsn"
		;
		select 
			case type
				when 'num' then cats(Name,':32.')
				else cats(Name,':$',length,'.')
			end
		into :inputlist separated by ' '
			from dictionary.columns
				where libname="&lib"
					and memname="&dsn"
		;

		%if %qsubstr(%superq(lbl),1,1)=Y %then
			%do;
				select strip(catx('=',Name,put(label,$quote.)))
					into : lbllist separated by ' '
						from dictionary.columns 
							where libname="&lib"
								and memname="&dsn"
								and label is not null 
				;
			%end;
		%else %let lbllist=;
		select memlabel 
			into :memlabel trimmed
				from dictionary.tables
					where libname="&lib"
						and memname="&dsn"
		;

		%if %qsubstr(%superq(fmt),1,1)=Y %then
			%do;
				select strip(catx(' ',Name,format))
					into :fmtlist separated by ' '
						from dictionary.columns
							where libname="&lib"
								and memname="&dsn"
								and format is not null 
								and format not like '$%'
				;
			%end;
		%else %let fmtlist=;
	quit;

	data temp;
		set  &lib..&dsn(obs=&obs);
	run;

	proc datasets library=work nolist;
		modify temp;
		format _all_;
	run;

	data _null_;
		file "%superq(file)" dsd;

		if _n_ =1 then
			do;
				%if %superq(memlabel)= %then
					%do;
						put "data &outlib..&dsn;";
					%end;
				%else
					%do;
						put "data &outlib..&dsn(label=%tslit(%superq(memlabel)));";
					%end;

				put @3 "infile datalines dsd truncover;";
				put @3 "input %superq(inputlist);";

				%if not (%superq(fmtlist)=) %then
					%do;
						put @3 "format %superq(fmtlist);";
					%end;

				%if not (%superq(lbllist)=) %then
					%do;
						put @3 "label %superq(lbllist);";
					%end;

				put "datalines4;";
			end;

		set temp end=__last;
		format _NUMERIC_;
		put &varlist @;

		if __last then
			do;
				put;
				put ';;;;';
			end;
		else put;
	run;

	proc fedsql;
		drop table temp force;
	quit;

%mend;