*&---------------------------------------------------------------------*
*& Program ZREPLICATE_NPL_TO_HXE
*&---------------------------------------------------------------------*
*& This program is used to replicate table records from ABAP (NPL) over
*& to a HANA database (HXE)
*& The versions used to code this program and test were:
*& - SAP NW AS ABAP 751 SP02 Developer Edition (NPL)
*& - SAP HANA Express 2.0 (HXE)
*& https://blogs.sap.com/2017/10/28/
*& replicating-data-into-hana-using-abap-adbc-native-sql/
*& Author: Alban Leong
*&---------------------------------------------------------------------*
PROGRAM zreplicate_npl_to_hxe.
*&---------------------------------------------------------------------*
* CLASS DEFINITION
*&---------------------------------------------------------------------*
CLASS lcl_local DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor   IMPORTING im_dbcon  TYPE dbcon-con_name
                              im_table  TYPE tabname16
                              im_schema type char10
                              im_batch  TYPE i
                              im_test   TYPE c,
      get_ddic_map,
      drop_table,
      create_table,
      select_and_load_data.

  PRIVATE SECTION.
    DATA:
      gv_table         TYPE tabname16,
      gv_batch         TYPE i,
      gv_test_mode     TYPE c,
      gv_schema        TYPE char10,
      gr_struct_descr  TYPE REF TO cl_abap_structdescr,
      gt_table_fields  TYPE ddfields,
      gv_message       TYPE string,
      gv_sql_stmt      TYPE string,
      gv_sql           TYPE string,
      gv_pkey          TYPE string,
      gv_value         TYPE string,
      gv_values        TYPE string,
      gv_num_recs      TYPE i,
      gv_processed     TYPE i,
      gv_mod           TYPE i,
      gv_tabix         TYPE sy-tabix,
      go_sql_statement TYPE REF TO cl_sql_statement,
      go_exception     TYPE REF TO cx_sql_exception,
      gw_fcat          TYPE lvc_s_fcat,
      gt_fcat          TYPE lvc_t_fcat,
      gd_table         TYPE REF TO data,
      gd_line          TYPE REF TO data,
      gt_stringtab     TYPE stringtab,
      gt_ddic_to_hana  TYPE STANDARD TABLE OF tvarvc.

ENDCLASS.

*&---------------------------------------------------------------------*
* SELECTION SCREEN
*&---------------------------------------------------------------------*
PARAMETERS: p_table TYPE tabname16 OBLIGATORY.
PARAMETERS: p_dbcon TYPE dbcon-con_name DEFAULT 'HANA_HXE' OBLIGATORY.
PARAMETERS: p_schema TYPE char10 DEFAULT 'NPLDATA' OBLIGATORY.
PARAMETERS: p_batch TYPE i DEFAULT 1000 OBLIGATORY.
PARAMETERS: p_test  AS CHECKBOX DEFAULT 'X'.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
* Validate that the entered connection is a connection to HANA
  SELECT SINGLE con_name INTO @DATA(gv_con_name) FROM dbcon
    WHERE con_name = @p_dbcon
      AND dbms     = 'HDB'.     " HANA
  IF sy-subrc NE 0.
    MESSAGE 'Invalid HANA DB connection'(001) TYPE 'E'.
  ENDIF.

*&---------------------------------------------------------------------*
* START OF SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  DATA(lo_class) = NEW lcl_local( im_dbcon = p_dbcon  im_table = p_table
                                 im_schema = p_schema im_batch = p_batch
                                  im_test  = p_test ).
  lo_class->get_ddic_map( ).
  lo_class->drop_table( ).
  lo_class->create_table( ).
  lo_class->select_and_load_data( ).

*&---------------------------------------------------------------------*
* CLASS IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS lcl_local IMPLEMENTATION.
  METHOD constructor.
    gv_table     = im_table.
    gv_schema    = im_schema.
    gv_batch     = im_batch.
    gv_test_mode = im_test.

    TRY.
        go_sql_statement = NEW cl_sql_statement( con_ref = cl_sql_connection=>get_connection( im_dbcon ) ).
      CATCH cx_sql_exception INTO go_exception.
        gv_message = go_exception->get_text( ).
    ENDTRY.

*   Get structure of ABAP table
    gr_struct_descr ?= cl_abap_structdescr=>describe_by_name( im_table ).
    gt_table_fields = gr_struct_descr->get_ddic_field_list( ).
  ENDMETHOD.

  METHOD get_ddic_map.
    SELECT low, high INTO CORRESPONDING FIELDS OF TABLE @gt_ddic_to_hana FROM tvarvc
      WHERE name = 'DDIC_TO_HANA'.
  ENDMETHOD.

  METHOD drop_table.
    CLEAR: gv_sql_stmt, gv_message.
    gv_sql_stmt = |DROP TABLE "{ gv_schema }"."{ gv_table }"|.
    TRY.
        go_sql_statement->execute_ddl( gv_sql_stmt ).
      CATCH cx_sql_exception INTO go_exception.
        gv_message = go_exception->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD create_table.
    CLEAR: gv_sql, gv_sql_stmt, gv_message.

    LOOP AT gt_table_fields REFERENCE INTO DATA(gr_table_fields).
      DATA(gw_ddic_to_hana) = gt_ddic_to_hana[ low = gr_table_fields->datatype ].
      CHECK sy-subrc = 0.
      gv_sql = gv_sql &&
        |"{ gr_table_fields->fieldname }" { gw_ddic_to_hana-high }|.
      CASE gw_ddic_to_hana-high.
        WHEN 'NVARCHAR' OR 'FLOAT'.
          gv_sql = gv_sql && |({ gr_table_fields->leng })|.
        WHEN 'TINYINT'.
        WHEN 'DECIMAL'.
          gv_sql = gv_sql && |({ gr_table_fields->leng },{ gr_table_fields->decimals })|.
      ENDCASE.

      gv_sql = gv_sql && ','.

      IF gr_table_fields->keyflag EQ 'X'.
        IF gv_pkey IS NOT INITIAL.
          gv_pkey = gv_pkey && ','.
        ENDIF.
        gv_pkey = gv_pkey && |"{ gr_table_fields->fieldname }"|.
      ENDIF.
    ENDLOOP.

    gv_sql_stmt =
      |CREATE COLUMN TABLE "{ gv_schema }"."{ gv_table }" | &&
      |( { gv_sql } PRIMARY KEY ({ gv_pkey }))|.

    TRY.
        go_sql_statement->execute_ddl( gv_sql_stmt ).
      CATCH cx_sql_exception INTO go_exception.
        gv_message = go_exception->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD select_and_load_data.
    FIELD-SYMBOLS:
      <dyn_table> TYPE STANDARD TABLE,
      <dyn_wa>    TYPE any,
      <dyn_field> TYPE any.

    DATA(gt_components) = gr_struct_descr->components[].

    LOOP AT gt_components REFERENCE INTO DATA(gr_components).
      CLEAR gw_fcat.
      gw_fcat-fieldname = gr_components->name .
      CASE gr_components->type_kind.
        WHEN 'C'.
          gw_fcat-datatype = 'CHAR'.
        WHEN 'N'.
          gw_fcat-datatype = 'NUMC'.
        WHEN 'D'.
          gw_fcat-datatype = 'DATE'.
        WHEN 'P'.
          gw_fcat-datatype = 'PACK'.
        WHEN OTHERS.
          gw_fcat-datatype = gr_components->type_kind.
      ENDCASE.
      gw_fcat-inttype  = gr_components->type_kind.
      gw_fcat-intlen   = gr_components->length.
      gw_fcat-decimals = gr_components->decimals.
      APPEND gw_fcat TO gt_fcat.
    ENDLOOP.

    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        it_fieldcatalog  = gt_fcat
        i_length_in_byte = 'X'
      IMPORTING
        ep_table         = gd_table.

    ASSIGN gd_table->* TO <dyn_table>.
    CREATE DATA gd_line LIKE LINE OF <dyn_table>.
    ASSIGN gd_line->* TO <dyn_wa>.

    gv_message = |Selecting data from table { gv_table }|.
    CALL FUNCTION 'PROGRESS_INDICATOR'
      EXPORTING
        i_text               = gv_message
        i_output_immediately = 'X'.

    IF gv_test_mode IS NOT INITIAL.
      SELECT * INTO TABLE <dyn_table> FROM (gv_table) UP TO 10 ROWS.
    ELSE.
      SELECT * INTO TABLE <dyn_table> FROM (gv_table).
    ENDIF.

    IF <dyn_table> IS NOT INITIAL.
      gv_num_recs  = lines( <dyn_table> ).
      gv_processed = 0.

      REFRESH: gt_stringtab.

      LOOP AT <dyn_table> ASSIGNING <dyn_wa>.
        gv_tabix = sy-tabix.

        CLEAR: gv_sql, gv_values.

        LOOP AT gt_table_fields REFERENCE INTO DATA(gr_table_fields).
          ASSIGN COMPONENT gr_table_fields->fieldname OF STRUCTURE <dyn_wa> TO <dyn_field>.
          DATA(gw_ddic_to_hana) = gt_ddic_to_hana[ low = gr_table_fields->datatype ].
          CHECK sy-subrc = 0.

          IF gv_values IS NOT INITIAL.
            gv_values = gv_values && ','.
          ENDIF.

          CASE gw_ddic_to_hana-high.
            WHEN 'NVARCHAR'.
              gv_value = <dyn_field>.
              REPLACE ALL OCCURRENCES OF `'` IN gv_value WITH `''`.
              gv_values = gv_values && |'{ gv_value }'|.

            WHEN 'DECIMAL' OR 'INTEGER' OR 'TINYINT' OR 'FLOAT' OR 'SMALLINT'.
              IF <dyn_field> IS NOT INITIAL.
                gv_values = gv_values && |{ <dyn_field> }|.
              ELSE.
                gv_values = gv_values && |NULL|.
              ENDIF.
            WHEN OTHERS.
              gv_values = gv_values && |{ <dyn_field> }|.
          ENDCASE.
        ENDLOOP.

        gv_sql = |INSERT INTO "{ gv_schema }"."{ gv_table }" VALUES ({ gv_values })|.
        APPEND gv_sql TO gt_stringtab.
        DELETE <dyn_table> INDEX gv_tabix.
      ENDLOOP.

      UNASSIGN <dyn_table>. " We no longer need this

      CLEAR gv_processed.
      LOOP AT gt_stringtab REFERENCE INTO DATA(gr_stringtab).
        gv_tabix = sy-tabix.
        ADD 1 TO gv_processed.
        TRY.
            go_sql_statement->execute_update( gr_stringtab->* ).
          CATCH cx_sql_exception INTO go_exception.
            gv_message = go_exception->get_text( ).
        ENDTRY.

        DELETE gt_stringtab INDEX gv_tabix.

*       Perform a COMMIT WORK when we hit the "batch" number
        gv_mod = gv_processed MOD gv_batch.
        IF gv_mod IS INITIAL.
          COMMIT WORK AND WAIT.
        ENDIF.

*       Show progress on screen for every 1000 records
        gv_mod = gv_processed MOD 1000.
        IF gv_mod IS INITIAL.
          IF sy-batch IS INITIAL.
            gv_message = |Processed "{ gv_processed }" records out of "{ gv_num_recs }".|.
            CALL FUNCTION 'PROGRESS_INDICATOR'
              EXPORTING
                i_text               = gv_message
                i_processed          = gv_processed
                i_total              = gv_num_recs
                i_output_immediately = 'X'.
          ENDIF.
        ENDIF.
      ENDLOOP.

      gv_message = |Processed a total of { gv_processed } records into { gv_schema }.{ gv_table }.|.
      MESSAGE gv_message TYPE 'S'.
    ELSE.
      gv_message = |No data selected|.
      MESSAGE gv_message TYPE 'S'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
