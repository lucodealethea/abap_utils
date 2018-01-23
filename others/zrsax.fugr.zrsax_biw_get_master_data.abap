FUNCTION ZRSAX_BIW_GET_MASTER_DATA.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_REQUNR) TYPE  SBIWA_S_INTERFACE-REQUNR
*"     VALUE(I_CHABASNM) TYPE  SBIWA_S_INTERFACE-CHABASNM OPTIONAL
*"     VALUE(I_MAXSIZE) TYPE  SBIWA_S_INTERFACE-MAXSIZE OPTIONAL
*"     VALUE(I_INITFLAG) TYPE  SBIWA_S_INTERFACE-INITFLAG OPTIONAL
*"     VALUE(I_UPDMODE) TYPE  SBIWA_S_INTERFACE-UPDMODE OPTIONAL
*"     VALUE(I_DATAPAKID) TYPE  SBIWA_S_INTERFACE-DATAPAKID OPTIONAL
*"     VALUE(I_S_TIMEINT) TYPE  SBIWA_S_TIMEINT OPTIONAL
*"     VALUE(I_REMOTE_CALL) TYPE  SBIWA_FLAG DEFAULT SBIWA_C_FLAG_OFF
*"  TABLES
*"      I_T_SELECT TYPE  SBIWA_T_SELECT OPTIONAL
*"      I_T_FIELDS TYPE  SBIWA_T_FIELDS OPTIONAL
*"      E_T_SOURCE_STRUCTURE_NAME OPTIONAL
*"  EXCEPTIONS
*"      NO_MORE_DATA
*"      ERROR_PASSED_TO_MESS_HANDLER
*"--------------------------------------------------------------------

* The input parameters I_DATAPAKID and I_S_TIMEINT are not supported
* yet !

* Table E_T_'Source Structure Name as in table RODCHABAS' must have
* the following field structure:
* Key field (or key fields in case of composite InfoObjects)
* DATETO    in case of time dependent master data
* DATEFROM  in case of time dependent master data
* attributes

* For program logic see RSAX_BIW_GET_DATA. Exactly the same logic
* should be applied here.

ENDFUNCTION.
