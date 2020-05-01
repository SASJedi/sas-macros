/* The DSNATTR Macro Returns a Numeric or Character Attribute. */

%macro dsnattr(dsn, attr, type);
  %local dsid attrn dsidc;
  %let dsid=%sysfunc(open(&dsn)); 
  %let attr&type=%sysfunc(attr&type(&dsid,&attr)); 
  %let dsidc=%sysfunc(close(&dsid));
  &&attr&type
%mend dsnattr;
