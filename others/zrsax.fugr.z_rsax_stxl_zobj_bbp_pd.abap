FUNCTION Z_RSAX_STXL_ZOBJ_BBP_PD.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REQUNR) TYPE  SRSC_S_IF_SIMPLE-REQUNR
*"     REFERENCE(I_DSOURCE) TYPE  SRSC_S_IF_SIMPLE-DSOURCE
*"     REFERENCE(I_MAXSIZE) TYPE  SRSC_S_IF_SIMPLE-MAXSIZE
*"     REFERENCE(I_INITFLAG) TYPE  SRSC_S_IF_SIMPLE-INITFLAG
*"     REFERENCE(I_READ_ONLY) TYPE  SRSC_S_IF_SIMPLE-READONLY
*"     REFERENCE(I_REMOTE_CALL) TYPE  SBIWA_FLAG DEFAULT
*"       SBIWA_C_FLAG_OFF
*"  TABLES
*"      I_T_SELECT TYPE  SRSC_S_IF_SIMPLE-T_SELECT OPTIONAL
*"      I_T_FIELDS TYPE  SRSC_S_IF_SIMPLE-T_FIELDS OPTIONAL
*"      E_T_DATA STRUCTURE  ZBI_SRM_BID_STXL OPTIONAL
*"  EXCEPTIONS
*"      NO_MORE_DATA
*"      ERROR_PASSED_TO_MESS_HANDLER
*"----------------------------------------------------------------------
* Example: DataSource for table STXL
  tables: zbi_srm_bid_stxl.

  types: s_line           type tline,
         t_lines          type standard table of tline,
         t_extracted_data type zbi_srm_bid_stxl.

  data: l_tabix  like sy-tabix,
        l_count  type sytabix,
        i_t_data type t_extracted_data,
        it_lines type t_lines,
        it_text  type t_lines,
        l_line   type s_line,
        it_ctab  type tdtab_c132,
        v_sep    type c length 1 value ' ',
        s_zcds_text_guid type zbi_srm_bid_stxl.

  data: g_t_stxl_guid type zbi_srm_bid_stxl occurs 1.

  data: g_fin.
  data: g_count type sytabix.

* Auxiliary Selection criteria structure
  data: l_s_select type srsc_s_select.
*
* Maximum number of lines for DB table
  statics: s_s_if              type srsc_s_if_simple,

** counter
           s_counter_datapakid like sy-tabix.
*
** cursor
*
* Select ranges
  ranges: sdno for zbi_srm_bid_stxl-guid.

  field-symbols: <fs_zcds_text_guid> type zbi_srm_bid_stxl,
                 <text_line>         type s_line.
* Initialization mode (first call by SAPI) or data transfer mode
* (following calls) ?
  if i_initflag = sbiwa_c_flag_on.

************************************************************************
* Initialization: check input parameters
*                 buffer input parameters
*                 prepare data selection
************************************************************************

* Check DataSource validity
    case i_dsource.
      when 'ZBI_SRM_BID_STXL'.
      when others.
        if 1 = 2. message e009(r3). endif.
* this is a typical log call. Please write every error message like this
        log_write 'E'                  "message type
                  'R3'                 "message class
                  '009'                "message number
                  i_dsource   "message variable 1
                  ' '.                 "message variable 2
        raise error_passed_to_mess_handler.
    endcase.

    append lines of i_t_select to s_s_if-t_select.

  else.                 "Initialization mode or data extraction ?

************************************************************************
* Data transfer: First Call      OPEN CURSOR + FETCH
*                Following Calls FETCH only
************************************************************************
    if not g_fin is initial.
      raise no_more_data.
    endif.

* First data package -> OPEN CURSOR
    if s_counter_datapakid = 0.

* Fill range tables BW will only pass down simple selection criteria
* of the type SIGN = 'I' and OPTION = 'EQ' or OPTION = 'BT'.
      loop at s_s_if-t_select into l_s_select where fieldnm = 'GUID'.
        move-corresponding l_s_select to sdno.
        append sdno.
      endloop.
      perform read_stxl tables g_t_stxl_guid
                               sdno.

    endif.                             "First data package ?


    loop at g_t_stxl_guid assigning <fs_zcds_text_guid>.
* we should REPLACE the below FM WITH READ_TEXT_MULTIPLE
      call function 'READ_TEXT'
        exporting
          client                  = <fs_zcds_text_guid>-mandt
          id                      = 'ZOBJ'
*<fs_zcds_text_guid>-tdid
          language                = <fs_zcds_text_guid>-tdspras
          name                    = <fs_zcds_text_guid>-guid
          object                  = 'BBP_PD'
*<fs_zcds_text_guid>-TDOBJECT
*         ARCHIVE_HANDLE          = 0
*         LOCAL_CAT               = ' '
* IMPORTING
*         HEADER                  =
*         OLD_LINE_COUNTER        =
        tables
          lines                   = it_lines
        exceptions
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          others                  = 8.
      if sy-subrc <> 0.
* Implement suitable error handling here
      else.

* initially specs were to
* read table it_lines into l_line index 1.
        clear: s_zcds_text_guid-txtlg,
               s_zcds_text_guid-seqnr.

        loop at it_lines ASSIGNING <text_line>.

        replace all occurrences of '<p>' in <text_line>-tdline with ''.
        replace all occurrences of '</p>' in <text_line>-tdline with ''.
        replace all occurrences of '<span>' in <text_line>-tdline with ''.
        replace all occurrences of '</span>' in <text_line>-tdline with ''.
        replace all occurrences of '<br/>' in <text_line>-tdline with ''.
        replace all occurrences of '</em>' in <text_line>-tdline with ''.
        replace all occurrences of '<em>' in <text_line>-tdline with ''.
        replace all occurrences of '<h1>' in <text_line>-tdline with ''.
        replace all occurrences of '</h1>' in <text_line>-tdline with ''.
        replace all occurrences of '<h2>' in <text_line>-tdline with ''.
        replace all occurrences of '</h2>' in <text_line>-tdline with ''.
        replace all occurrences of '<blockquote>' in <text_line>-tdline with ''.
        replace all occurrences of '</blockquote>' in <text_line>-tdline with ''.
        replace all occurrences of '</block>' in <text_line>-tdline with ''.
        replace all occurrences of '<ul>' in <text_line>-tdline with ''.
        replace all occurrences of '</ul>' in <text_line>-tdline with ''.
        replace all occurrences of '<div>' in <text_line>-tdline with ''.
        replace all occurrences of '</div>' in <text_line>-tdline with ''.
        replace all occurrences of '<li>' in <text_line>-tdline with ''.
        replace all occurrences of '</li>' in <text_line>-tdline with ''.
        replace all occurrences of '<strong>' in <text_line>-tdline with ''.
        replace all occurrences of '</strong>' in <text_line>-tdline with ''.
        replace all occurrences of '</stro' in <text_line>-tdline with ''.
        replace all occurrences of '</' in <text_line>-tdline with ''.
* CONCATENATE <fs_zcds_text_guid>-txtlg l_line-tdline INTO <fs_zcds_text_guid>-txtlg SEPARATED BY v_sep.
*        endloop.
* Do the concatenation in BW transformation where max-field length InfoObject is 1332 long
* REMOVE HTML TAGS with
* ( if someone explain me how to make it work in minutes )
*          call function 'CONVERT_ITF_TO_ASCII'
*            exporting
*              language          = 'P'
*            importing
*              c_datatab         = it_ctab
*            tables
*              itf_lines         = it_lines
*            exceptions
*              invalid_tabletype = 1
*              others            = 2.

        s_zcds_text_guid-SEQNR = s_zcds_text_guid-seqnr + 1.
        move <text_line>-tdline to <fs_zcds_text_guid>-txtlg.
        append <fs_zcds_text_guid> to g_t_stxl_guid.
        endloop.
      endif.
    endloop.

    if sy-subrc <> 0.
      raise no_more_data.
    endif.

    if i_maxsize is initial.
      e_t_data[] = g_t_stxl_guid[].
      move 'X' to g_fin.
    else.
      describe table g_t_stxl_guid lines l_tabix.
      compute l_tabix = l_tabix - g_count.
      if l_tabix <= i_maxsize.
        add 1 to g_count.
        l_count = g_count + i_maxsize.
        loop at g_t_stxl_guid into i_t_data
           from g_count to l_count.
          e_t_data = i_t_data.
          append e_t_data.
        endloop.
        move 'X' to g_fin.
      else.
        add 1 to g_count.
        l_count = g_count + i_maxsize.
        loop at g_t_stxl_guid into i_t_data
           from g_count to l_count.
          e_t_data = i_t_data.
          append e_t_data.
        endloop.
        g_count = l_count.
      endif.
    endif.

    s_counter_datapakid = s_counter_datapakid + 1.

  endif.              "Initialization mode or data extraction ?

endfunction.



form read_stxl tables g_t_stxl_guid
                         sdno.
  select
    mandt
    tdname as guid
    tdspras
    tdobject
    tdid
*    '1' as SEQNR
  from stxl
  into table g_t_stxl_guid
  where tdobject = 'BBP_PD'
  and tdname in sdno
  and tdid = 'ZOBJ'  .


endform.                    "read_stxl
