FUNCTION ZRSAX_BIW_GET_DATA.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_REQUNR) TYPE  SBIWA_S_INTERFACE-REQUNR
*"     VALUE(I_ISOURCE) TYPE  SBIWA_S_INTERFACE-ISOURCE OPTIONAL
*"     VALUE(I_MAXSIZE) TYPE  SBIWA_S_INTERFACE-MAXSIZE OPTIONAL
*"     VALUE(I_INITFLAG) TYPE  SBIWA_S_INTERFACE-INITFLAG OPTIONAL
*"     VALUE(I_UPDMODE) TYPE  SBIWA_S_INTERFACE-UPDMODE OPTIONAL
*"     VALUE(I_DATAPAKID) TYPE  SBIWA_S_INTERFACE-DATAPAKID OPTIONAL
*"     VALUE(I_PRIVATE_MODE) OPTIONAL
*"     VALUE(I_CALLMODE) LIKE  ROARCHD200-CALLMODE OPTIONAL
*"     VALUE(I_REMOTE_CALL) TYPE  SBIWA_FLAG DEFAULT SBIWA_C_FLAG_OFF
*"  TABLES
*"      I_T_SELECT TYPE  SBIWA_T_SELECT OPTIONAL
*"      I_T_FIELDS TYPE  SBIWA_T_FIELDS OPTIONAL
*"      E_T_DATA OPTIONAL
*"      E_T_SOURCE_STRUCTURE_NAME OPTIONAL
*"  EXCEPTIONS
*"      NO_MORE_DATA
*"      ERROR_PASSED_TO_MESS_HANDLER
*"--------------------------------------------------------------------

* The input parameter I_DATAPAKID is not supported yet !

* Example: InfoSource containing TADIR objects
  TABLES: tadir.

* Auxiliary Selection criteria structure
  DATA: l_s_select TYPE sbiwa_s_select.

* Maximum number of lines for DB table
  STATICS: l_maxsize TYPE sbiwa_s_interface-maxsize.

* Select ranges
  RANGES: l_r_pgmid  FOR tadir-pgmid,
          l_r_object FOR tadir-object.

* Parameter I_PRIVATE_MODE:
* Some applications might want to use this function module for other
* purposes as well (e.g. data supply for OLTP reporting tools). If the
* processing logic has to be different in this case, use the optional
* parameter I_PRIVATE_MODE (not supplied by BIW !) to distinguish
* between BIW calls (I_PRIVATE_MODE = SPACE) and other calls
* (I_PRIVATE_MODE = X).
* If the message handling has to be different as well, define Your own
* messaging macro which interprets parameter I_PRIVATE_MODE. When
* called by BIW, it should use the LOG_WRITE macro, otherwise do what
* You want.

* Initialization mode (first call by SAPI) or data transfer mode
* (following calls) ?
  IF i_initflag = sbiwa_c_flag_on.

************************************************************************
* Initialization: check input parameters
*                 buffer input parameters
*                 prepare data selection
************************************************************************

* The input parameter I_DATAPAKID is not supported yet !

* Invalid second initialization call -> error exit
    IF NOT g_flag_interface_initialized IS INITIAL.

      IF 1 = 2. MESSAGE e008(r3). ENDIF.
      log_write 'E'                    "message type
                'R3'                   "message class
                '008'                  "message number
                ' '                    "message variable 1
                ' '.                   "message variable 2
      RAISE error_passed_to_mess_handler.
    ENDIF.

* Check InfoSource validity
    CASE i_isource.
      WHEN 'X'.
      WHEN 'Y'.
      WHEN 'Z'.
      WHEN OTHERS.
        IF 1 = 2. MESSAGE e009(r3). ENDIF.
        log_write 'E'                  "message type
                  'R3'                 "message class
                  '009'                "message number
                  i_isource            "message variable 1
                  ' '.                 "message variable 2
        RAISE error_passed_to_mess_handler.
    ENDCASE.

* Check for supported update mode
    CASE i_updmode.
      WHEN 'F'.
      WHEN OTHERS.
        IF 1 = 2. MESSAGE e011(r3). ENDIF.
        log_write 'E'                  "message type
                  'R3'                 "message class
                  '011'                "message number
                  i_updmode            "message variable 1
                  ' '.                 "message variable 2
        RAISE error_passed_to_mess_handler.
    ENDCASE.

* Check for obligatory selection criteria
    READ TABLE i_t_select INTO l_s_select WITH KEY fieldnm = 'PGMID'.
    IF sy-subrc <> 0.
      IF 1 = 2. MESSAGE e010(r3). ENDIF.
      log_write 'E'                    "message type
                'R3'                   "message class
                '010'                  "message number
                'PGMID'                "message variable 1
                ' '.                   "message variable 2
      RAISE error_passed_to_mess_handler.
    ENDIF.

    APPEND LINES OF i_t_select TO g_t_select.

* Fill parameter buffer for data extraction calls
    g_s_interface-requnr    = i_requnr.
    g_s_interface-isource   = i_isource.
    g_s_interface-maxsize   = i_maxsize.
    g_s_interface-initflag  = i_initflag.
    g_s_interface-updmode   = i_updmode.
    g_s_interface-datapakid = i_datapakid.
    g_flag_interface_initialized = sbiwa_c_flag_on.

* Fill field list table for an optimized select statement
* (in case that there is no 1:1 relation between InfoSource fields
* and database table fields this may be far from beeing trivial)
    APPEND LINES OF i_t_fields TO g_t_segfields.

*   Start tracing of extraction
    bice_trace_open g_r_tracer i_t_fields.

  ELSE.                 "Initialization mode or data extraction ?

************************************************************************
* Data transfer: First Call      OPEN CURSOR + FETCH
*                Following Calls FETCH only
************************************************************************

* First data package -> OPEN CURSOR
    IF g_counter_datapakid = 0.

* Fill range tables for fixed InfoSources. In the case of generated
* InfoSources, the usage of a dynamical SELECT statement might be
* more reasonable. BIW will only pass down simple selection criteria
* of the type SIGN = 'I' and OPTION = 'EQ' or OPTION = 'BT'.
      LOOP AT g_t_select INTO l_s_select WHERE fieldnm = 'PGMID'.
        MOVE-CORRESPONDING l_s_select TO l_r_pgmid.
        APPEND l_r_pgmid.
      ENDLOOP.

      LOOP AT g_t_select INTO l_s_select WHERE fieldnm = 'OBJECT'.
        MOVE-CORRESPONDING l_s_select TO l_r_object.
        APPEND l_r_object.
      ENDLOOP.

* Determine number of database records to be read per FETCH statement
* from input parameter I_MAXSIZE. If there is a one to one relation
* between InfoSource table lines and database entries, this is trivial.
* In other cases, it may be impossible and some estimated value has to
* be determined.
      l_maxsize = g_s_interface-maxsize.

      OPEN CURSOR WITH HOLD g_cursor FOR
      SELECT (g_t_fields) FROM tadir
                               WHERE pgmid  IN l_r_pgmid AND
                                     object IN l_r_object.    "#EC CI_GENBUFF
    ENDIF.                             "First data package ?

* Fetch records into interface table. There are two different options:
* - fixed interface table structure for fixed InfoSources have to be
*   named E_T_'Name of assigned source structure in table ROIS'.
* - for generating applications like LIS and CO-PA, the generic table
*   E_T_DATA has to be used.
* Only one of these interface types should be implemented in one API !
    FETCH NEXT CURSOR g_cursor
               APPENDING CORRESPONDING FIELDS
               OF TABLE e_t_source_structure_name
               PACKAGE SIZE l_maxsize.

    IF sy-subrc <> 0.
      CLOSE CURSOR g_cursor.
      bice_trace_close g_r_tracer.
      RAISE no_more_data.
    ENDIF.
    bice_collect_table g_r_tracer e_t_data.
    g_counter_datapakid = g_counter_datapakid + 1.

  ENDIF.              "Initialization mode or data extraction ?

ENDFUNCTION.
