# sas-macros
Selected useful macros from my personal SAS macro library 
1. Download the files an save them to a folder in your SASAUTOS autocall path. 
2. call the macro by name with !help at the parameter to get syntax help in the log. 
   For example:
      %data2datastep(!help)
   Produces this text in the SAS log:
   NOTE: DATA2DATASTEP macro help document:
      Purpose: Converts a data set to a SAS DATA step.
      Syntax: %DATA2DATASTEP(dsn<,lib,outlib,file,obs,fmt,lbl>)
      dsn:    Name of the dataset to be converted. Required.
      lib:    LIBREF of the original dataset. (Optional - if DSN is not fully qualified)
      outlib: LIBREF for the output dataset. (Optional - default is WORK)
      file:   Fully qualified filename for the DATA step code produced. (Optional)
              Default is create_&outlib._&dsn._data.sas in the SAS default directory.
      obs:    Max observations to include the created dataset.
              (Optional) Default is MAX (all observations)
      fmt:    Format the numeric variables in the output dataset like the original data set?
              (YES|NO - Optional) Default is YES
      lbl:    Reproduce column labels in the output dataset?
              (YES|NO - Optional) Default is YES

NOTE:   DATA2DATASTEP cannot be used in-line - it generates code.
        Every FORMAT in the original data must have a corresponding INFORMAT of the same name.
        Data set label is automatically re-created.
        Only numeric column formats can be re-created, character column formats are ingnored.
        Use !HELP to print these notes.

