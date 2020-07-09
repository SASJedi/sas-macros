# sas-macros
<h2>Selected useful macros from my personal SAS macro library</h2> 
1. Clone this repository to a local path.<br>
2. Add the local path to your SASAUTOS autocall path. <br>
3. Call the macro by name with ? or !help as the parameter to get syntax help in the log.<br> 
   For example:<br>
      <b>%data2datastep(?)</b><br><br>
      <b>%data2datastep(!help)</b><br><br>
   Produces this text in the SAS log:<br><br>
   NOTE: DATA2DATASTEP macro help document:<br>
      Purpose: Converts a data set to a SAS DATA step.<br>
      Syntax: %DATA2DATASTEP(dsn<,lib,outlib,file,obs,fmt,lbl>)<br>
      dsn:    Name of the dataset to be converted. Required.<br>
      lib:    LIBREF of the original dataset. (Optional - if DSN is not fully qualified)<br>
      outlib: LIBREF for the output dataset. (Optional - default is WORK)<br>
      file:   Fully qualified filename for the DATA step code produced. (Optional)<br>
              Default is create_&outlib._&dsn._data.sas in the SAS default directory.<br>
      obs:    Max observations to include the created dataset.<br>
              (Optional) Default is MAX (all observations)<br>
      fmt:    Format the numeric variables in the output dataset like the original data set?<br>
              (YES|NO - Optional) Default is YES<br>
      lbl:    Reproduce column labels in the output dataset?<br>
              (YES|NO - Optional) Default is YES<br>
<br>
<b>NOTE:</b>   DATA2DATASTEP cannot be used in-line - it generates code.<br>
        Every FORMAT in the original data must have a corresponding INFORMAT of the same name.<br>
        Data set label is automatically re-created.<br>
        Only numeric column formats can be re-created, character column formats are ingnored.<br>
        Use !HELP to print these notes.
