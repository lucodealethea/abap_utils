*&---------------------------------------------------------------------*
*& Report  ZKSH_UTIL_EXPORT2HANA
*& https://blogs.sap.com/2013/06/16/
*& simple-sql-table-export-in-abap-for-hana/
*& Author: Konstantin Anikeev
*&---------------------------------------------------------------------*
*& Table export to HANA
*&
*&---------------------------------------------------------------------*
REPORT  zksh_util_export2hana.

TABLES dd02l.
TYPE-POOLS abap.

CONSTANTS:  gc_txt_schema   TYPE char80 VALUE 'Schema',
            gc_txt_create   TYPE char80 VALUE 'Create new schema',
            gc_txt_tab      TYPE char80 VALUE 'Tables',
            gc_txt_data     TYPE char80 VALUE 'Extract data',
            gc_txt_send     TYPE char80 VALUE 'Send per mail',
            gc_txt_dwnld    TYPE char80 VALUE 'Download',
            gc_txt_mail     TYPE char80 VALUE 'eMail',
            gc_txt_path     TYPE char80 VALUE 'Path'.

DATA: gt_tables TYPE TABLE OF tabname,
      gt_file TYPE stringtab,
      gv_zip  TYPE xstring,
      gv_index TYPE i VALUE 0,
      gv_current_table TYPE string.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (20) txt_schm FOR FIELD p_schema.
PARAMETERS p_schema TYPE char32 OBLIGATORY DEFAULT 'ZKSH_EXPORT'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_create TYPE abap_bool AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN COMMENT 2(35) txt_crt FOR FIELD p_create.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (17) txt_tab FOR FIELD s_tab.
SELECT-OPTIONS s_tab FOR dd02l-tabname NO INTERVALS.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_data   TYPE xfeld DEFAULT abap_on. " With Inserts
SELECTION-SCREEN COMMENT 2(35) txt_data FOR FIELD p_data.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN ULINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_send   TYPE abap_bool RADIOBUTTON GROUP r1 DEFAULT 'X' USER-COMMAND act.
SELECTION-SCREEN COMMENT 2(35) txt_send FOR FIELD p_send.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_dwnld  TYPE abap_bool RADIOBUTTON GROUP r1.
SELECTION-SCREEN COMMENT 2(35) txt_dwn FOR FIELD p_dwnld.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (20) txt_mail FOR FIELD p_mail MODIF ID m.
PARAMETERS p_mail   TYPE ad_smtpadr DEFAULT 'Konstantin@Anikeev.eu' MODIF ID m.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (20) txt_path FOR FIELD p_path MODIF ID d.
PARAMETERS p_path   TYPE string DEFAULT '' MODIF ID d.
SELECTION-SCREEN END OF LINE.

INITIALIZATION.
  txt_schm = gc_txt_schema.
  txt_crt  = gc_txt_create.
  txt_tab  = gc_txt_tab.
  txt_data = gc_txt_data.
  txt_send = gc_txt_send.
  txt_dwn  = gc_txt_dwnld.
  txt_mail = gc_txt_mail.
  txt_path = gc_txt_path.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'M'.
        IF abap_true = p_send.
          screen-invisible = 0.
          screen-active    = 1.
          screen-input     = 1.
          screen-output    = 1.
        ELSE.
          screen-invisible = 1.
          screen-active    = 0.
          screen-input     = 0.
          screen-output    = 0.
        ENDIF.
      WHEN 'D'.
        IF abap_true = p_dwnld.
          screen-invisible = 0.
          screen-active    = 1.
          screen-input     = 1.
          screen-output    = 1.
        ELSE.
          screen-invisible = 1.
          screen-active    = 0.
          screen-input     = 0.
          screen-output    = 0.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    CHANGING
      selected_folder      = p_path
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
  ENDIF.
START-OF-SELECTION.
  REFRESH: gt_tables[], gt_file[].
  PERFORM get_tables_list.
END-OF-SELECTION.
  PERFORM get_script_file.
  IF abap_true = p_send.
    PERFORM send_script_file.
  ELSE.
    PERFORM download_script_file.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  get_tables_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_tables_list .
  CHECK s_tab[] IS NOT INITIAL.
  SELECT tabname
    FROM dd02l
    INTO TABLE gt_tables
    FOR ALL ENTRIES IN s_tab
    WHERE tabname  = s_tab-low
    AND tabclass = 'TRANSP'.
ENDFORM.                    " get_tables_list
*&---------------------------------------------------------------------*
*&      Form  get_script_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_script_file .
  DATA: file_lines TYPE stringtab,
        lv_table TYPE tabname,
        lv_string TYPE string.
  IF abap_true = p_create.
    CONCATENATE 'CREATE SCHEMA' p_schema ';' INTO lv_string SEPARATED BY space.
    APPEND lv_string TO gt_file.
  ENDIF.
  CONCATENATE 'SET SCHEMA' p_schema ';' INTO lv_string SEPARATED BY space.
  APPEND lv_string TO gt_file.
  LOOP AT gt_tables INTO lv_table.
    gv_current_table = lv_table.
    REPLACE ALL OCCURRENCES OF '/' IN gv_current_table WITH '_'. " for the case of /SAPSRM/....
    PERFORM table2file USING lv_table
                       CHANGING file_lines.
    IF file_lines[] IS NOT INITIAL.
      APPEND LINES OF file_lines TO gt_file.
    ENDIF.
  ENDLOOP.
  CLEAR gv_current_table.
ENDFORM.                    " get_script_file
*&---------------------------------------------------------------------*
*&      Form  send_script_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM send_script_file .
  CHECK lines( gt_file[] ) > 1.
  ADD 1 TO gv_index.
  PERFORM zip_file.
  PERFORM send_as_attach.
ENDFORM.                    " send_script_file
*&---------------------------------------------------------------------*
*&      Form  download_script_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM download_script_file .
  CHECK lines( gt_file[] ) > 1.
  ADD 1 TO gv_index.
  PERFORM zip_file.
  PERFORM download_file.
ENDFORM.                    "download_script_file
*&---------------------------------------------------------------------*
*&      Form  table2file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TABLE       text
*      -->P_FILE_LINES  text
*----------------------------------------------------------------------*
FORM table2file  USING    p_table
                 CHANGING p_file_lines TYPE stringtab.
  REFRESH p_file_lines[].
  PERFORM get_table_definition USING p_table
                               CHANGING p_file_lines.
ENDFORM.                    " table2file
*&---------------------------------------------------------------------*
*&      Form  get_table_definition
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TABLE       text
*      -->P_FILE_LINES  text
*----------------------------------------------------------------------*
FORM get_table_definition  USING    p_table
                           CHANGING p_file_lines TYPE stringtab.
  DATA lt_field_def TYPE TABLE OF dd03l.
  DATA lt_indexes TYPE TABLE OF dd17s.
  DATA lv_string  TYPE string.
  DATA lv_string2 TYPE string.
  DATA lv_len TYPE i.
  FIELD-SYMBOLS: <fs_field> TYPE dd03l,
                 <fs_index> TYPE dd17s.
  SELECT * FROM  dd03l
    INTO TABLE lt_field_def
    WHERE tabname = p_table
  ORDER BY position ASCENDING.
* Deletes any .INCLUDE and similar statements
  DELETE lt_field_def WHERE fieldname+0(1) = '.'.
  CONCATENATE 'DROP TABLE' p_table ';' INTO lv_string SEPARATED BY space.
  APPEND lv_string TO p_file_lines.
  CONCATENATE 'CREATE COLUMN TABLE' p_table '(' INTO lv_string SEPARATED BY space.
  APPEND lv_string TO p_file_lines.
  LOOP AT lt_field_def ASSIGNING <fs_field>.
    CONCATENATE <fs_field>-fieldname '' INTO lv_string.
    REPLACE ALL OCCURRENCES OF '/' IN lv_string WITH '_'. " some field are called as /BWI/DATA -> _BWI_DATA
    CASE <fs_field>-inttype.
      WHEN 'C'. " Charakter
        CONCATENATE 'NVARCHAR(' <fs_field>-leng ')' INTO lv_string2.
        CONCATENATE lv_string lv_string2 INTO lv_string SEPARATED BY space.
      WHEN 'N'. " Natural Zahl -> 'C'
        CONCATENATE 'NVARCHAR(' <fs_field>-leng ')' INTO lv_string2.
        CONCATENATE lv_string lv_string2 INTO lv_string SEPARATED BY space.
      WHEN 'D'. " DATUM
        CONCATENATE lv_string 'DATE' INTO lv_string SEPARATED BY space.
      WHEN 'T'. " Zeit
        CONCATENATE lv_string 'TIME' INTO lv_string SEPARATED BY space.
      WHEN 'X'. " Binary -> CHAR
        lv_len = <fs_field>-leng + <fs_field>-leng.
        lv_string2 = lv_len.
        CONCATENATE 'NVARCHAR(' lv_string2 ')' INTO lv_string2.
        CONCATENATE lv_string lv_string2 INTO lv_string SEPARATED BY space.
      WHEN 'P'. " Decimal
        CONCATENATE 'DECIMAL(' <fs_field>-leng ',' <fs_field>-decimals ')' INTO lv_string2.
        CONCATENATE lv_string lv_string2 INTO lv_string SEPARATED BY space.
      WHEN 'g'. " String -> LONGTEXT
        CONCATENATE lv_string 'NCLOB' INTO lv_string SEPARATED BY space.
      WHEN 'y'. " XString -> BLOB
        CONCATENATE lv_string 'NCLOB' INTO lv_string SEPARATED BY space.
      WHEN OTHERS.
    ENDCASE.
    IF <fs_field>-inttype CA 'CXg'.
      CONCATENATE lv_string 'DEFAULT ''''' INTO lv_string SEPARATED BY space.
    ENDIF.
    IF <fs_field>-notnull = abap_true.
      CONCATENATE lv_string 'NOT NULL' INTO lv_string SEPARATED BY space.
    ENDIF.
    CONCATENATE lv_string ',' INTO lv_string.
    APPEND lv_string TO p_file_lines.
  ENDLOOP.
  UNASSIGN <fs_field>.
  CLEAR lv_string.
  LOOP AT lt_field_def ASSIGNING <fs_field> WHERE keyflag = abap_true.
    AT FIRST.
      CONCATENATE 'PRIMARY KEY (' <fs_field>-fieldname '' INTO lv_string.
      CONTINUE.
    ENDAT.
    CONCATENATE lv_string ',' <fs_field>-fieldname '' INTO lv_string.
  ENDLOOP.
  CONCATENATE lv_string '));' INTO lv_string.
  UNASSIGN <fs_field>.
  APPEND lv_string TO p_file_lines.
  CLEAR lv_string.
  APPEND lv_string TO p_file_lines.
  IF p_data = abap_on.
    PERFORM get_table_data USING p_table
                           CHANGING p_file_lines.
  ENDIF.
ENDFORM.                    " get_table_definition
*&---------------------------------------------------------------------*
*&      Form  get_table_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TABLE       text
*      -->P_FILE_LINES  text
*----------------------------------------------------------------------*
FORM get_table_data  USING    p_table
                     CHANGING p_file_lines TYPE stringtab.
  DATA db_cur TYPE cursor.
  DATA lv_package TYPE i VALUE 0.
  DATA lv_act_package TYPE i VALUE 0.
  DATA : idetails TYPE abap_compdescr_tab,
         xdetails TYPE abap_compdescr,
         xfc      TYPE lvc_s_fcat,
         ifc      TYPE lvc_t_fcat,
         dy_table TYPE REF TO data,
         dy_line  TYPE REF TO data.
  DATA lv_string TYPE string.
  DATA lv_string2 TYPE string.
  DATA lv_datum TYPE datum.
  DATA lv_time  TYPE uzeit.
  DATA : ref_table_des TYPE REF TO cl_abap_structdescr.
  FIELD-SYMBOLS: <dyn_table> TYPE ANY TABLE,
                 <dyn_wa>,
                 <dyn_field>.
  ref_table_des ?= cl_abap_typedescr=>describe_by_name( p_table ).
  idetails[] = ref_table_des->components[].
  LOOP AT idetails INTO xdetails.
    CLEAR xfc.
    xfc-fieldname = xdetails-name .
    xfc-datatype = xdetails-type_kind.
    xfc-inttype = xdetails-type_kind.
    xfc-intlen = xdetails-length.
    xfc-decimals = xdetails-decimals.
    APPEND xfc TO ifc.
  ENDLOOP.
  CREATE DATA dy_table TYPE STANDARD TABLE OF (p_table)
                            WITH NON-UNIQUE DEFAULT KEY.
  ASSIGN dy_table->* TO <dyn_table>.
* Create dynamic work area and assign to FS
  CREATE DATA dy_line LIKE LINE OF <dyn_table>.
  ASSIGN dy_line->* TO <dyn_wa>.
* Select Data from table.
  DO.
    ADD 1 TO lv_package.
    OPEN CURSOR db_cur FOR
      SELECT * FROM (p_table).
    DO lv_package TIMES.
      FETCH NEXT CURSOR db_cur INTO TABLE <dyn_table> PACKAGE SIZE 65535.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
    ENDDO.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    CLOSE CURSOR db_cur.
*   Write out data from table.
    LOOP AT <dyn_table> INTO <dyn_wa>.
      CONCATENATE 'INSERT INTO' p_table 'VALUES (' INTO lv_string SEPARATED BY space.
      DO.
        ASSIGN COMPONENT sy-index
           OF STRUCTURE <dyn_wa> TO <dyn_field>.
        IF sy-subrc <> 0. EXIT. ENDIF.
        READ TABLE ifc INTO xfc INDEX sy-index.
        IF sy-subrc <> 0. EXIT. ENDIF.
        IF sy-index <> 1. CONCATENATE lv_string ',' INTO lv_string. ENDIF.
        CASE xfc-inttype.
          WHEN 'C' OR 'X' OR 'P' OR 'g'.
            lv_string2 = <dyn_field>.
            CONDENSE lv_string2.
            IF xfc-inttype = 'P'. " Decimal
              IF <dyn_field> < 0.
                <dyn_field> = 0 - <dyn_field>.
                lv_string2 = <dyn_field>.
                CONDENSE lv_string2.
                CONCATENATE '-' lv_string2 INTO lv_string2.
                <dyn_field> = 0 - <dyn_field>.
              ENDIF.
            ENDIF.
            REPLACE ALL OCCURRENCES OF '''' IN lv_string2 WITH ''''''.
            CONCATENATE lv_string '''' lv_string2 '''' INTO lv_string.
          WHEN 'y'.
            lv_string2 = <dyn_field>.
            CONCATENATE lv_string '0x' lv_string2 INTO lv_string.
          WHEN 'D'.
            lv_datum = <dyn_field>.
            IF lv_datum = ''.
              CLEAR lv_datum.
            ENDIF.
            CONCATENATE lv_datum(4) '-' lv_datum+4(2) '-' lv_datum+6(2)
              INTO  lv_string2.
            CONCATENATE lv_string '''' lv_string2 '''' INTO lv_string.
          WHEN 'T'.
            lv_time = <dyn_field>.
            CONCATENATE lv_time(2) ':' lv_time+2(2) ':' lv_time+4(2)
              INTO  lv_string2.
            CONCATENATE lv_string '''' lv_string2 '''' INTO lv_string.
          WHEN OTHERS.
            lv_string2 = <dyn_field>.
            REPLACE ALL OCCURRENCES OF '''' IN lv_string2 WITH ''''''.
            CONCATENATE lv_string '''' lv_string2 '''' INTO lv_string.
        ENDCASE.
      ENDDO.
      CONCATENATE lv_string ');' INTO lv_string.
      APPEND lv_string TO p_file_lines.
    ENDLOOP.
    APPEND LINES OF p_file_lines TO gt_file.
    IF abap_true = p_send.
      PERFORM send_script_file.
    ELSE.
      PERFORM download_script_file.
    ENDIF.
    REFRESH: p_file_lines, gt_file.
    CONCATENATE 'SET SCHEMA' p_schema ';' INTO lv_string SEPARATED BY space.
    APPEND lv_string TO gt_file.
  ENDDO.
  CLOSE CURSOR db_cur.
ENDFORM.                    " get_table_data
*&---------------------------------------------------------------------*
*&      Form  zip_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zip_file .
  DATA lo_zip TYPE REF TO cl_abap_zip.
  DATA lo_conv TYPE REF TO cl_abap_conv_out_ce.
  DATA text_len TYPE i.
  DATA lv_filename TYPE string.
  FIELD-SYMBOLS: <fs_line> TYPE string.
  lo_conv = cl_abap_conv_out_ce=>create( ).
  LOOP AT gt_file ASSIGNING <fs_line>.
    text_len = strlen( <fs_line> ).
    lo_conv->write( n    = text_len
                    data = <fs_line> ).
    lo_conv->write( data = cl_abap_char_utilities=>cr_lf ).
  ENDLOOP.
  gv_zip = lo_conv->get_buffer( ).
  CREATE OBJECT lo_zip.
  IF gv_current_table IS NOT INITIAL.
    lv_filename = gv_index.
    CONDENSE lv_filename.
    CONCATENATE 'hana_script_' lv_filename '_' gv_current_table '.sql' INTO lv_filename.
  ELSE.
    CONCATENATE 'hana_script_' lv_filename '.sql' INTO lv_filename.
  ENDIF.
  lo_zip->add( name    = lv_filename
               content = gv_zip ).
  gv_zip = lo_zip->save( ).
ENDFORM.                    " zip_file
*&---------------------------------------------------------------------*
*&      Form  send_as_attach
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_as_attach .
  DATA: lo_send_request TYPE REF TO cl_bcs VALUE IS INITIAL.
  DATA: lo_sender TYPE REF TO if_sender_bcs VALUE IS INITIAL.
  DATA: lo_recipient TYPE REF TO if_recipient_bcs VALUE IS INITIAL.
  DATA: lo_document TYPE REF TO cl_document_bcs VALUE IS INITIAL.
  DATA: lt_content TYPE solix_tab.
  DATA: lv_len TYPE i.
  DATA: message_body TYPE bcsy_text.
  DATA: lv_subject TYPE so_obj_des.
  lv_subject = gv_index.
  CONDENSE lv_subject.
  CONCATENATE 'HANA Script' lv_subject INTO lv_subject SEPARATED BY space.
  lo_send_request = cl_bcs=>create_persistent( ).
  lo_document = cl_document_bcs=>create_document(  i_type     = 'HTM'
                                                   i_text     = message_body
                                                   i_subject  = lv_subject ).
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = gv_zip
    IMPORTING
      output_length = lv_len
    TABLES
      binary_tab    = lt_content.
  lo_document->add_attachment( i_attachment_type    = 'ZIP'
                               i_attachment_subject = 'hana_script.zip'
                               i_att_content_hex    = lt_content ).
* Pass the document to send request
  lo_send_request->set_document( lo_document ).
  lo_sender = cl_sapuser_bcs=>create( sy-uname ).
  lo_recipient = cl_cam_address_bcs=>create_internet_address( p_mail ).
  lo_send_request->set_sender( lo_sender ).
  lo_send_request->add_recipient( i_recipient = lo_recipient
                                  i_express = 'X' ).
  lo_send_request->send( ).
  COMMIT WORK.
ENDFORM.                    " send_as_attach
*&---------------------------------------------------------------------*
*&      Form  download_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM download_file.
  DATA: lv_filename TYPE string.
  DATA: lv_len      TYPE i.
  DATA: lt_content  TYPE solix_tab.
  IF gv_current_table IS NOT INITIAL.
    lv_filename = gv_index.
    CONDENSE lv_filename.
    CONCATENATE 'hana_script_' lv_filename '_' gv_current_table '.zip' INTO lv_filename.
  ELSE.
    CONCATENATE 'hans_script_' lv_filename '.zip' INTO lv_filename.
  ENDIF.
  CONCATENATE p_path '\' lv_filename INTO lv_filename.
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = gv_zip
    IMPORTING
      output_length = lv_len
    TABLES
      binary_tab    = lt_content.
  cl_gui_frontend_services=>gui_download(
    EXPORTING
      bin_filesize              = lv_len
      filename                  = lv_filename
      filetype                  = 'BIN'    " File type (ASCII, binary ...)
      no_auth_check             = abap_true    " Switch off Check for Access Rights
    CHANGING
      data_tab                  = lt_content
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      not_supported_by_gui      = 22
      error_no_gui              = 23
      OTHERS                    = 24
  ).
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.                    "download_file
