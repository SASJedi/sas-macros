  /*  Create series of macro variables that contain */
  /*  the names of all data sets in a given library */

%macro dsnlist(lib);
   %if %sysfunc(libref(&lib)) ne 0 %then %do;
      %put ERROR: the libref &lib has not been assigned.;
	  %put ERROR- The macro will stop execution now.;
	  %return;
   %end;
   %let lib=%upcase(&lib);
   data _null_;
      set sashelp.vtable end=last;
      where libname = "&lib";
      call symputx(cats('dsn',_n_), memname,'G'); 
      if last then call symputx('n', _n_,'G');
   run;
%mend dsnlist;
