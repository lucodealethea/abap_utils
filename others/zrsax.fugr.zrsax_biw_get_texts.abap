FUNCTION ZRSAX_BIW_GET_TEXTS.
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
*"      I_T_LANGU TYPE  SBIWA_T_LANGU OPTIONAL
*"      I_T_SELECT TYPE  SBIWA_T_SELECT OPTIONAL
*"      E_T_TEXTS TYPE  SBIWA_T_TEXTS OPTIONAL
*"  EXCEPTIONS
*"      NO_MORE_DATA
*"      ERROR_PASSED_TO_MESS_HANDLER
*"--------------------------------------------------------------------

************************************************************************
************************************************************************
*  Do not use as template for extractors for BW 2.0 and higher.
*  Use the template for master data instead.
************************************************************************
************************************************************************


* The input parameters I_DATAPAKID and I_S_TIMEINT are not supported
* yet !

* For general program logic see RSAX_BIW_GET_DATA. Quite the same logic
* can be applied here.

* Special features:

* Table I_T_LANGU contains a list of the required languages. In case
* of language independent texts (e.g. company code description) this
* table can be ignored.

* Table E_T_TEXTS will contain the texts in a standard transfer
* structure. In case of language independent texts, field LANGU should
* be left blank. The same holds for DATEFROM and DATETO if texts are
* not time dependent.
* The field COMKEY must contain the concatenated key fields according
* to the description in table RODIOBJCMP.

ENDFUNCTION.
