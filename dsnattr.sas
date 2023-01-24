%macro dsnattr(dsn, attr)/minoperator mindelimiter=',';
  %local MsgType charattrs numattrs type;
  %let MsgType=NOTE;
%let charattrs=%nrstr(CHARSET,COMPRESS,DATAREP,ENCODING,ENCRYPT,ENGINE,LABEL,LIB,MEM,MODE,MTYPE,SORTEDBY,SORTLVL,SORTSEQ,TYPE); 
%let numattrs=%nrstr(ALTERPW,ANOBS,ANY,AUDIT,CRDTE,ICONST,ISINEX,ISSUBSET,LRECL,LRID,MODTE,NDEL,NLOBS,NLOBSF,NOBS,NVARS,PW,READPW,REUSE,TAPE,WHSTMT,WRITEPW);

%if %SUPERQ(dsn)= ? %then %do;
%Syntax:
   %put;
   %put &MsgType: &SYSMACRONAME documentation:;
   %put &MsgType- Purpose: Get a dataset attribute;
   %put &MsgType- Syntax: %nrstr(%%)&SYSMACRONAME(dsn,attr);
   %put &MsgType- dsn:     dataset of interest;
   %put &MsgType- attr:    attribute to get;
   %put ;
  	%put &MsgType- Valid attribute names include:;
	%put &MSGTYPE- %superq(charattrs) %superq(numattrs);
  	%put;
   %put &MsgType- Examples: ;
   %put &MsgType- %nrstr(%%)put sashelp.cars has %nrstr(%%)&SYSMACRONAME(sashelp.cars,nlobs) observations.;
   %put &MsgType- %nrstr(%%)put sashelp.cars is encoded as %nrstr(%%)&SYSMACRONAME(sashelp.cars,encoding).;
   %put ;
   %put;
   %return;
%end; 
%if %SUPERQ(dsn)= %then %do;
	ERROR
  	%let MsgType=ERROR;
  	%put;
  	%put &MsgType: (&sysmacroname) You must specify a data set name.;
  	%put;
	%goto Syntax;
%end; 

%if %SUPERQ(attr)=  %then %do;
	ERROR
  	%let MsgType=ERROR;
  	%put;
  	%put &MsgType: (&sysmacroname) You must specify the name of the attribute to retrieve.;
  	%put;
	%goto Syntax;
%end; 
%let attr=%qupcase(%superq(attr));

%if %SUPERQ(attr) in %superq(charattrs) %then %let type=C;
%else %if %SUPERQ(attr) in %superq(numattrs) %then %let type=N;
%else %do;
	ERROR
  	%let MsgType=ERROR;
  	%put;
  	%put &MsgType: (&sysmacroname) %superq(ATTR) is not a supported attribute name.;
  	%put;
	%goto Syntax;
%end; 

%if not (%exist(&dsn)) %then %do;
  	%let MsgType=ERROR;
  	%put;
  	%put &MsgType: (&sysmacroname) Specified Data set does not exist;
  	%put;
	ERROR
	%return;
%end;

/* Do the work */
  %local dsid attrn dsidc;
  %let dsid=%sysfunc(open(&dsn)); 
  %let attr&type=%sysfunc(attr&type(&dsid,&attr)); 
  %let dsidc=%sysfunc(close(&dsid));
  &&attr&type
%mend dsnattr;