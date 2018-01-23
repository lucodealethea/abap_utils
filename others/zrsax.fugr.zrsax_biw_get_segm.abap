FUNCTION ZRSAX_BIW_GET_SEGM.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_REQUNR) TYPE  SBIWA_S_INTERFACE-REQUNR
*"     VALUE(I_RLOGSYS) TYPE  ROOSGEN-RLOGSYS OPTIONAL
*"     VALUE(I_UPDMODE) TYPE  SBIWA_S_INTERFACE-UPDMODE OPTIONAL
*"     VALUE(I_ISOURCE) TYPE  SBIWA_S_INTERFACE-ISOURCE OPTIONAL
*"     VALUE(I_S_PARAMS) TYPE  ROEXTRPRMS OPTIONAL
*"     VALUE(I_INITFLAG) TYPE  SBIWA_S_INTERFACE-INITFLAG OPTIONAL
*"     VALUE(I_DATAPAKID) TYPE  SBIWA_S_INTERFACE-DATAPAKID OPTIONAL
*"     VALUE(I_READ_ONLY) OPTIONAL
*"     VALUE(I_REMOTE_CALL) TYPE  SBIWA_FLAG DEFAULT SBIWA_C_FLAG_OFF
*"  TABLES
*"      I_T_SELECT TYPE  SBIWA_T_SELECT OPTIONAL
*"      I_T_FIELDS STRUCTURE  RSSEGFDSEL OPTIONAL
*"      E_T_DATA OPTIONAL
*"  EXCEPTIONS
*"      NO_MORE_DATA
*"      ERROR_PASSED_TO_MESS_HANDLER
*"--------------------------------------------------------------------

* ==== Macro to count sizes
  DEFINE mycount.
    describe table &1 lines l_lines.
    add l_lines to l_lines_total.
    l_size = l_lines * g_s_length-&2 / 1000.
    add l_size to l_size_total.
  END-OF-DEFINITION.

* The input parameter I_DATAPAKID is not supported yet !

  DATA: l_t_roosource  TYPE TABLE OF roosource WITH HEADER LINE,
        l_t_roosourcet TYPE TABLE OF roosourcet WITH HEADER LINE,
        l_t_roosseg    TYPE TABLE OF roosseg WITH HEADER LINE,
        l_t_roosfield  TYPE TABLE OF roosfield WITH HEADER LINE,
        l_t_roohiecom  TYPE TABLE OF roohiecom WITH HEADER LINE,
        l_t_roohiecat  TYPE TABLE OF roohiecat WITH HEADER LINE.

  DATA: l_s_data      TYPE rover_datasource,
        l_lines       TYPE i,
        l_size        TYPE i,
        l_lines_total TYPE i,
        l_size_total  TYPE i.

* Auxiliary Selection criteria structure
  DATA: l_s_select TYPE sbiwa_s_select.

* Maximum number of lines for DB table
  STATICS: l_maxsize TYPE sbiwa_s_interface-maxsize.

* Select ranges
  RANGES: l_r_osource  FOR roosource-oltpsource,
          l_r_objvers  FOR roosource-objvers.

* Initialization mode (first call by SAPI) or data transfer mode
* (following calls) ?
  IF i_initflag = sbiwa_c_flag_on.

************************************************************************
* Initialization: check input parameters
*                 buffer input parameters
*                 prepare data selection
************************************************************************

* The input parameter I_DATAPAKID is not supported yet !
    CLEAR: g_no_more_data,
           g_counter_datapakid,
           g_s_interface,
           g_flag_interface_initialized.

    REFRESH: g_t_select,
             g_t_fields1,
             g_t_fields2,
             g_t_fields3,
             g_t_fields4,
             g_t_fields5,
             g_t_fields6.

* The cursor is closed if it is open (because this is a new init or
*     the previous extraction failed and did not reach "no_more_data)
    IF NOT g_cursor IS INITIAL.
      CLOSE CURSOR g_cursor.
      CLEAR g_cursor.
    ENDIF.

* Check InfoSource validity
    CASE i_isource.
      WHEN '0VER_DATASOURCE_SEGM'.
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
*    READ TABLE i_t_select INTO l_s_select WITH KEY fieldnm = 'OBJVERS'.
*    IF sy-subrc <> 0.
*      IF 1 = 2. MESSAGE e010(r3). ENDIF.
*      log_write 'E'                    "message type
*                'R3'                   "message class
*                '010'                  "message number
*                'OBJVERS'              "message variable 1
*                ' '.                   "message variable 2
*      RAISE error_passed_to_mess_handler.
*    ENDIF.

    APPEND LINES OF i_t_select TO g_t_select.

* Fill parameter buffer for data extraction calls
    MOVE-CORRESPONDING i_s_params TO g_s_params.

    g_s_interface-requnr    = i_requnr.
    g_s_interface-isource   = i_isource.
    g_s_interface-initflag  = i_initflag.
    g_s_interface-updmode   = i_updmode.
    g_s_interface-datapakid = i_datapakid.

* ??? wat soll dat ???
    g_flag_interface_initialized = sbiwa_c_flag_on.

* Calculate current width
    uc_describe_field_length_bmode l_t_roosource  g_s_length-roosource.
    uc_describe_field_length_bmode l_t_roosourcet g_s_length-roosourcet.
    uc_describe_field_length_bmode l_t_roosseg    g_s_length-roosseg.
    uc_describe_field_length_bmode l_t_roosfield  g_s_length-roosfield.
    uc_describe_field_length_bmode l_t_roohiecat  g_s_length-roohiecat.
    uc_describe_field_length_bmode l_t_roohiecom  g_s_length-roohiecom.

* Fill field list table for an optimized select statement
* (in case that there is no 1:1 relation between InfoSource fields
* and database table fields this may be far from beeing trivial)

    DATA: l_s_fields TYPE rssegfdsel,
          l_s_fieldx TYPE sbiwa_s_select.

    LOOP AT i_t_fields INTO l_s_fields.
      l_s_fieldx-fieldnm = l_s_fields-fieldnm.
      CASE l_s_fields-segid.
        WHEN '0001'.
          APPEND l_s_fieldx TO g_t_fields1.
        WHEN '0002'.
          APPEND l_s_fieldx TO g_t_fields2.
        WHEN '0003'.
          APPEND l_s_fieldx TO g_t_fields3.
        WHEN '0004'.
          APPEND l_s_fieldx TO g_t_fields4.
        WHEN '0005'.
          APPEND l_s_fieldx TO g_t_fields5.
        WHEN '0006'.
          APPEND l_s_fieldx TO g_t_fields6.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

*   Open tracing for segmented data
    bice_trace_open_segm g_r_tracer i_t_fields.

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
      LOOP AT g_t_select INTO l_s_select WHERE fieldnm = 'OLTPSOURCE'.
        MOVE-CORRESPONDING l_s_select TO l_r_osource.
        APPEND l_r_osource.
      ENDLOOP.

      LOOP AT g_t_select INTO l_s_select WHERE fieldnm = 'OBJVERS'.
        MOVE-CORRESPONDING l_s_select TO l_r_objvers.
        APPEND l_r_objvers.
      ENDLOOP.

* Determine number of database records to be read per FETCH statement
* from input parameter I_MAXSIZE. If there is a one to one relation
* between InfoSource table lines and database entries, this is trivial.
* In other cases, it may be impossible and some estimated value has to
* be determined.
      l_maxsize = g_s_params-maxsize / 10.

      IF l_maxsize GT g_s_params-maxlines.
        l_maxsize = g_s_params-maxlines.
      ENDIF.

      OPEN CURSOR WITH HOLD g_cursor FOR
      SELECT (g_t_fields1) FROM roosource
                           WHERE oltpsource IN l_r_osource AND
                                 objvers    IN l_r_objvers.    "#EC CI_GENBUFF
    ENDIF.                             "First data package ?


*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#
*    IF g_counter_datapakid GT 1.
*      CLOSE CURSOR g_cursor.
*      RAISE no_more_data.
*    ENDIF.
*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#

    IF NOT g_no_more_data IS INITIAL.
      RAISE no_more_data.
    ENDIF.

* ==== Create Data Packages
    DO.

      REFRESH: l_t_roosource.

      FETCH NEXT CURSOR g_cursor
                 APPENDING CORRESPONDING FIELDS
                 OF TABLE l_t_roosource
                 PACKAGE SIZE l_maxsize.

      IF sy-subrc <> 0.
        CLOSE CURSOR g_cursor.
        CLEAR g_cursor.
*       Stop tracing
        bice_trace_close g_r_tracer.
        g_no_more_data = 'X'.
        EXIT.
      ENDIF.

* ---- Get the other tables!
* .... 2
      IF NOT g_t_fields2[] IS INITIAL.
        SELECT (g_t_fields2) FROM roosourcet
               INTO TABLE l_t_roosourcet
               FOR ALL ENTRIES IN l_t_roosource
               WHERE oltpsource = l_t_roosource-oltpsource AND
                     objvers = l_t_roosource-objvers.

* .... Count size and lines
        mycount l_t_roosourcet roosourcet.

      ENDIF.

* .... 3
      IF NOT g_t_fields3[] IS INITIAL.
        SELECT (g_t_fields3) FROM roosseg
               INTO TABLE l_t_roosseg
               FOR ALL ENTRIES IN l_t_roosource
               WHERE oltpsource = l_t_roosource-oltpsource AND
                     objvers = l_t_roosource-objvers.

* .... Count size and lines
        mycount l_t_roosseg roosseg.

      ENDIF.

* .... 4
      IF NOT g_t_fields4[] IS INITIAL.
        SELECT (g_t_fields4) FROM roosfield
               INTO TABLE l_t_roosfield
               FOR ALL ENTRIES IN l_t_roosource
               WHERE oltpsource = l_t_roosource-oltpsource AND
                     objvers = l_t_roosource-objvers.

* .... Count size and lines
        mycount l_t_roosfield roosfield.

      ENDIF.

* .... 5
      IF NOT g_t_fields5[] IS INITIAL.
        SELECT (g_t_fields5) FROM roohiecat
               INTO TABLE l_t_roohiecat
               FOR ALL ENTRIES IN l_t_roosource
               WHERE oltpsource = l_t_roosource-oltpsource AND
                     objvers = l_t_roosource-objvers.      "#EC CI_GENBUFF

* .... Count size and lines
        mycount l_t_roohiecat roohiecat.
      ENDIF.

* .... 6
      IF NOT g_t_fields6[] IS INITIAL.
        SELECT (g_t_fields6) FROM roohiecom
               INTO TABLE l_t_roohiecom
               FOR ALL ENTRIES IN l_t_roosource
               WHERE oltpsource = l_t_roosource-oltpsource AND
                     objvers = l_t_roosource-objvers.

* .... Count size and lines
        mycount l_t_roohiecom roohiecom.

      ENDIF.

* ---- Build objects
      LOOP AT l_t_roosource.
        CLEAR l_s_data.
* .... 1
        l_s_data-seg_0001 = l_t_roosource.
*       Collect a single (header) record for 1st segment of current data object
        bice_collect_segm_lines g_r_tracer 1 l_s_data-seg_0001 1.
* .... 2
        LOOP AT l_t_roosourcet
             WHERE oltpsource EQ l_t_roosource-oltpsource AND
                   objvers EQ l_t_roosource-objvers.
          APPEND l_t_roosourcet TO l_s_data-seg_0002.
        ENDLOOP.
*       Collect all records for 2nd segment of current data object
        bice_collect_segm_table g_r_tracer 2 l_s_data-seg_0002.
* .... 3
        LOOP AT l_t_roosseg
             WHERE oltpsource EQ l_t_roosource-oltpsource AND
                   objvers EQ l_t_roosource-objvers.
          APPEND l_t_roosseg TO l_s_data-seg_0003.
        ENDLOOP.
*       Collect all records for 3rd segment of current data object
        bice_collect_segm_table g_r_tracer 3 l_s_data-seg_0003.
* .... 4
        LOOP AT l_t_roosfield
             WHERE oltpsource EQ l_t_roosource-oltpsource AND
                   objvers EQ l_t_roosource-objvers.
          APPEND l_t_roosfield TO l_s_data-seg_0004.
        ENDLOOP.
*       Collect all records for 4th segment of current data object
        bice_collect_segm_table g_r_tracer 4 l_s_data-seg_0004.
* .... 5
        LOOP AT l_t_roohiecat
             WHERE oltpsource EQ l_t_roosource-oltpsource AND
                   objvers EQ l_t_roosource-objvers.
          APPEND l_t_roohiecat TO l_s_data-seg_0005.
        ENDLOOP.
*       Collect all records for 5th segment of current data object
        bice_collect_segm_table g_r_tracer 5 l_s_data-seg_0005.
* .... 6
        LOOP AT l_t_roohiecom
             WHERE oltpsource EQ l_t_roosource-oltpsource AND
                   objvers EQ l_t_roosource-objvers.
          APPEND l_t_roohiecom TO l_s_data-seg_0006.
        ENDLOOP.
*       Collect all records for 6th segment of current data object
        bice_collect_segm_table g_r_tracer 6 l_s_data-seg_0006.

* .... Append Object
        APPEND l_s_data TO e_t_data.

      ENDLOOP.

* ---- Exit, if package size reached
      IF l_lines_total GE g_s_params-maxlines OR
         l_size_total  GE g_s_params-maxsize.
*       Flush current trace resulte to db
        bice_trace_flush g_r_tracer.
        EXIT.
      ENDIF.

    ENDDO.

    g_counter_datapakid = g_counter_datapakid + 1.

  ENDIF.              "Initialization mode or data extraction ?

ENDFUNCTION.
