FUNCTION ZRSAX_BIW_GET_DATA_SIMPLE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_REQUNR) TYPE  SRSC_S_IF_SIMPLE-REQUNR
*"     VALUE(I_DSOURCE) TYPE  SRSC_S_IF_SIMPLE-DSOURCE OPTIONAL
*"     VALUE(I_MAXSIZE) TYPE  SRSC_S_IF_SIMPLE-MAXSIZE OPTIONAL
*"     VALUE(I_INITFLAG) TYPE  SRSC_S_IF_SIMPLE-INITFLAG OPTIONAL
*"     VALUE(I_READ_ONLY) TYPE  SRSC_S_IF_SIMPLE-READONLY OPTIONAL
*"     VALUE(I_REMOTE_CALL) TYPE  SBIWA_FLAG DEFAULT SBIWA_C_FLAG_OFF
*"  TABLES
*"      I_T_SELECT TYPE  SRSC_S_IF_SIMPLE-T_SELECT OPTIONAL
*"      I_T_FIELDS TYPE  SRSC_S_IF_SIMPLE-T_FIELDS OPTIONAL
*"      E_T_DATA STRUCTURE  SFLIGHT OPTIONAL
*"  EXCEPTIONS
*"      NO_MORE_DATA
*"      ERROR_PASSED_TO_MESS_HANDLER
*"--------------------------------------------------------------------

* Example: DataSource for table SFLIGHT
  TABLES: SFLIGHT.

* Auxiliary Selection criteria structure
  DATA: L_S_SELECT TYPE SRSC_S_SELECT.

* Maximum number of lines for DB table
  STATICS: S_S_IF TYPE SRSC_S_IF_SIMPLE,

* counter
          S_COUNTER_DATAPAKID LIKE SY-TABIX,

* cursor
          S_CURSOR TYPE CURSOR.
* Select ranges
  RANGES: L_R_CARRID  FOR SFLIGHT-CARRID,
          L_R_CONNID  FOR SFLIGHT-CONNID.

* Initialization mode (first call by SAPI) or data transfer mode
* (following calls) ?
  IF I_INITFLAG = SBIWA_C_FLAG_ON.

************************************************************************
* Initialization: check input parameters
*                 buffer input parameters
*                 prepare data selection
************************************************************************

* Check DataSource validity
    CASE I_DSOURCE.
      WHEN '0SAPI_SFLIGHT_SIMPLE'.
      WHEN OTHERS.
        IF 1 = 2. MESSAGE E009(R3). ENDIF.
* this is a typical log call. Please write every error message like this
        LOG_WRITE 'E'                  "message type
                  'R3'                 "message class
                  '009'                "message number
                  I_DSOURCE   "message variable 1
                  ' '.                 "message variable 2
        RAISE ERROR_PASSED_TO_MESS_HANDLER.
    ENDCASE.

    APPEND LINES OF I_T_SELECT TO S_S_IF-T_SELECT.

* Fill parameter buffer for data extraction calls
    S_S_IF-REQUNR    = I_REQUNR.
    S_S_IF-DSOURCE = I_DSOURCE.
    S_S_IF-MAXSIZE   = I_MAXSIZE.

* Fill field list table for an optimized select statement
* (in case that there is no 1:1 relation between InfoSource fields
* and database table fields this may be far from beeing trivial)
    APPEND LINES OF I_T_FIELDS TO S_S_IF-T_FIELDS.

  ELSE.                 "Initialization mode or data extraction ?

************************************************************************
* Data transfer: First Call      OPEN CURSOR + FETCH
*                Following Calls FETCH only
************************************************************************

* First data package -> OPEN CURSOR
    IF S_COUNTER_DATAPAKID = 0.

* Fill range tables BW will only pass down simple selection criteria
* of the type SIGN = 'I' and OPTION = 'EQ' or OPTION = 'BT'.
      LOOP AT S_S_IF-T_SELECT INTO L_S_SELECT WHERE FIELDNM = 'CARRID'.
        MOVE-CORRESPONDING L_S_SELECT TO L_R_CARRID.
        APPEND L_R_CARRID.
      ENDLOOP.

      LOOP AT S_S_IF-T_SELECT INTO L_S_SELECT WHERE FIELDNM = 'CONNID'.
        MOVE-CORRESPONDING L_S_SELECT TO L_R_CONNID.
        APPEND L_R_CONNID.
      ENDLOOP.

* Determine number of database records to be read per FETCH statement
* from input parameter I_MAXSIZE. If there is a one to one relation
* between DataSource table lines and database entries, this is trivial.
* In other cases, it may be impossible and some estimated value has to
* be determined.
      OPEN CURSOR WITH HOLD S_CURSOR FOR
      SELECT (S_S_IF-T_FIELDS) FROM SFLIGHT
                               WHERE CARRID  IN L_R_CARRID AND
                                     CONNID  IN L_R_CONNID.
    ENDIF.                             "First data package ?

* Fetch records into interface table.
*   named E_T_'Name of extract structure'.
    FETCH NEXT CURSOR S_CURSOR
               APPENDING CORRESPONDING FIELDS
               OF TABLE E_T_DATA
               PACKAGE SIZE S_S_IF-MAXSIZE.

    IF SY-SUBRC <> 0.
      CLOSE CURSOR S_CURSOR.
      RAISE NO_MORE_DATA.
    ENDIF.

    S_COUNTER_DATAPAKID = S_COUNTER_DATAPAKID + 1.

  ENDIF.              "Initialization mode or data extraction ?

ENDFUNCTION.
