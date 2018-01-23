FUNCTION ZRSAX_BIW_GET_DATA_WITH_ARCHIV.
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
*"     VALUE(I_CALLMODE) TYPE  RSAZT_CALLMODE OPTIONAL
*"     VALUE(I_REMOTE_CALL) TYPE  SBIWA_FLAG DEFAULT SBIWA_C_FLAG_OFF
*"  TABLES
*"      I_T_SELECT TYPE  SBIWA_T_SELECT OPTIONAL
*"      I_T_FIELDS TYPE  SBIWA_T_FIELDS OPTIONAL
*"      E_T_DATA STRUCTURE  SBOOK OPTIONAL
*"      E_T_SELECT STRUCTURE  RSSELECT OPTIONAL
*"  EXCEPTIONS
*"      NO_MORE_DATA
*"      ERROR_PASSED_TO_MESS_HANDLER
*"      CANCELED_BY_USER
*"--------------------------------------------------------------------

* The input parameter I_DATAPAKID is not supported yet !

* Example: InfoSource containing SBOOK objects
  TABLES: SBOOK.

* Auxiliary Selection criteria structure
  DATA:
    L_LINES          TYPE I,
    L_ARCHIVE_HANDLE TYPE I,
    L_T_SELECT       LIKE I_T_SELECT[],
    L_S_SELECT       TYPE SBIWA_S_SELECT,
    L_T_ARCHRANGE    LIKE RNG_ARCHIV OCCURS 0,
    L_T_DATA        LIKE E_T_DATA[].

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

  CASE I_CALLMODE.

    WHEN RSAZT_C_CALLMODE-SELSCREEN OR
         RSAZT_C_CALLMODE-SELCHECK.

      E_T_SELECT[] = I_T_SELECT[].
      CALL FUNCTION 'RSAP_ADK_ADMIN_POPUP'
           EXPORTING
                I_OBJECT         = 'BC_SBOOK'
                I_CHECK_FILES    = SBIWA_C_FLAG_OFF
                I_CALLMODE       = I_CALLMODE
           TABLES
*               I_T_OBJECTS      =
                C_T_SELECT       = E_T_SELECT
           EXCEPTIONS
                CANCELED_BY_USER             = 1
                ERROR_PASSED_TO_MESS_HANDLER = 2.
      CASE SY-SUBRC.
        WHEN 1.  RAISE CANCELED_BY_USER.
        WHEN 2.  RAISE ERROR_PASSED_TO_MESS_HANDLER.
      ENDCASE.

    WHEN RSAZT_C_CALLMODE-EXTRACTION.

* Initialization mode (first call by SAPI) or data transfer mode
* (following calls) ?
      IF I_INITFLAG = SBIWA_C_FLAG_ON.

************************************************************************
* Initialization: check input parameters
*                 buffer input parameters
*                 prepare data selection
************************************************************************

* The input parameter I_DATAPAKID is not supported yet !

* Invalid second initialization call -> error exit
        IF NOT G_FLAG_INTERFACE_INITIALIZED IS INITIAL.

          IF 1 = 2. MESSAGE E008(R3). ENDIF.
          LOG_WRITE 'E'                "message type
                    'R3'               "message class
                    '008'              "message number
                    ' '                "message variable 1
                    ' '.               "message variable 2
          RAISE ERROR_PASSED_TO_MESS_HANDLER.
        ENDIF.

* Check InfoSource validity
        CASE I_ISOURCE.
          WHEN '0BC_SBOOK'.
          WHEN OTHERS.
            IF 1 = 2. MESSAGE E009(R3). ENDIF.
            LOG_WRITE 'E'              "message type
                      'R3'             "message class
                      '009'            "message number
                      I_ISOURCE        "message variable 1
                      ' '.             "message variable 2
            RAISE ERROR_PASSED_TO_MESS_HANDLER.
        ENDCASE.

* Check for supported update mode
        CASE I_UPDMODE.
          WHEN 'F'.
          WHEN OTHERS.
            IF 1 = 2. MESSAGE E011(R3). ENDIF.
            LOG_WRITE 'E'              "message type
                      'R3'             "message class
                      '011'            "message number
                      I_UPDMODE        "message variable 1
                      ' '.             "message variable 2
            RAISE ERROR_PASSED_TO_MESS_HANDLER.
        ENDCASE.

* Check for obligatory selection criteria
       READ TABLE I_T_SELECT INTO L_S_SELECT
                  WITH KEY FIELDNM = 'CARRID'.
        IF SY-SUBRC <> 0.
          IF 1 = 2. MESSAGE E010(R3). ENDIF.
          LOG_WRITE 'E'                "message type
                    'R3'               "message class
                    '010'              "message number
                    'PGMID'            "message variable 1
                    ' '.               "message variable 2
          RAISE ERROR_PASSED_TO_MESS_HANDLER.
        ENDIF.

* Fill parameter buffer for data extraction calls
        G_S_INTERFACE-REQUNR    = I_REQUNR.
        G_S_INTERFACE-ISOURCE   = I_ISOURCE.
        G_S_INTERFACE-MAXSIZE   = I_MAXSIZE.
        G_S_INTERFACE-INITFLAG  = I_INITFLAG.
        G_S_INTERFACE-UPDMODE   = I_UPDMODE.
        G_S_INTERFACE-DATAPAKID = I_DATAPAKID.
        G_FLAG_INTERFACE_INITIALIZED = SBIWA_C_FLAG_ON.

* Fill field list table for an optimized select statement
* (in case that there is no 1:1 relation between InfoSource fields
* and database table fields this may be far from beeing trivial)
        APPEND LINES OF I_T_FIELDS TO G_T_FIELDS.


*       Prepare selection from archive via ADK
        L_T_SELECT = I_T_SELECT[].
        CALL FUNCTION 'RSAP_ADK_OPEN_FOR_READ'
             IMPORTING
                  E_HANDLE                     = G_HANDLE
                  E_EXTRMODE                   = G_EXTRMODE
             TABLES
                  C_T_SELECT                   = L_T_SELECT
             EXCEPTIONS
                  ERROR_PASSED_TO_MESS_HANDLER = 1.
        IF SY-SUBRC NE 0.
          RAISE ERROR_PASSED_TO_MESS_HANDLER.
        ENDIF.
* Fill range tables for fixed InfoSources. In the case of generated
* InfoSources, the usage of a dynamical SELECT statement might be
* more reasonable. BIW will only pass down simple selection criteria
* of the type SIGN = 'I' and OPTION = 'EQ' or OPTION = 'BT'.
        LOOP AT L_T_SELECT INTO L_S_SELECT WHERE FIELDNM = 'CARRID'.
          MOVE-CORRESPONDING L_S_SELECT TO G_R_CARRID.
          APPEND G_R_CARRID.
        ENDLOOP.

        LOOP AT L_T_SELECT INTO L_S_SELECT WHERE FIELDNM = 'CONNID'.
          MOVE-CORRESPONDING L_S_SELECT TO G_R_CONNID.
          APPEND G_R_CONNID.
        ENDLOOP.

        LOOP AT L_T_SELECT INTO L_S_SELECT WHERE FIELDNM = 'FLDATE'.
          MOVE-CORRESPONDING L_S_SELECT TO G_R_FLDATE.
          APPEND G_R_FLDATE.
        ENDLOOP.

        LOOP AT L_T_SELECT INTO L_S_SELECT WHERE FIELDNM = 'BOOKID'.
          MOVE-CORRESPONDING L_S_SELECT TO G_R_BOOKID.
          APPEND G_R_BOOKID.
        ENDLOOP.

      ELSE.                 "Initialization mode or data extraction ?

************************************************************************
* Data transfer: First Call      OPEN CURSOR + FETCH
*                Following Calls FETCH only
************************************************************************

        REFRESH L_T_DATA.

        IF G_COUNTER_DATAPAKID = 0.

*         Start with extraction from archive
          G_STEP_EXTRMODE = RSAZT_C_EXTRMODE-ARCHIVE.

        ENDIF.

        CASE G_STEP_EXTRMODE.

          WHEN RSAZT_C_EXTRMODE-ARCHIVE.

*           Process archive selection

*           Check if extraction from archive is requested
            IF G_STEP_EXTRMODE CP G_EXTRMODE.

*             Read data objects from arhcive files
              WHILE G_S_INTERFACE-MAXSIZE GT L_LINES OR
                    G_S_INTERFACE-MAXSIZE EQ 0.

                CALL FUNCTION 'RSAP_ADK_GET_NEXT_OBJECT'
                     EXPORTING
                          I_HANDLE                = G_HANDLE
                     IMPORTING
                          E_ARCHIVE_HANDLE        = L_ARCHIVE_HANDLE
                     EXCEPTIONS
                          END_OF_FILES            = 1
                          INVALID_HANDLE          = 2
                          NO_RECORD_FOUND         = 3
                          FILE_ALREADY_OPEN       = 4
                          FILE_IO_ERROR           = 5
                          INTERNAL_ERROR          = 6
                          NO_FILES_AVAILABLE      = 7
                          OPEN_ERROR              = 8
                          WRONG_ACCESS_TO_ARCHIVE = 9
                          NOT_AUTHORIZED          = 10
                          FILE_NOT_FOUND          = 11.
                CASE SY-SUBRC.
                  WHEN 0.
                    CALL FUNCTION 'ARCHIVE_GET_TABLE'
                         EXPORTING
                             ARCHIVE_HANDLE          = L_ARCHIVE_HANDLE
                              RECORD_STRUCTURE        = 'BC_SBOOK'
                              ALL_RECORDS_OF_OBJECT   = 'X'
*                             AUTOMATIC_CONVERSION    = 'X'
*                        IMPORTING
*                             RECORD_CURSOR           =
*                             RECORD_FLAGS            =
*                             RECORD_LENGTH           =
                         TABLES
                              TABLE                   = L_T_DATA
                         EXCEPTIONS
                              END_OF_OBJECT           = 1
                              INTERNAL_ERROR          = 2
                              WRONG_ACCESS_TO_ARCHIVE = 3
                              OTHERS                  = 4.
                    DELETE L_T_DATA
                            WHERE NOT ( CARRID IN G_R_CARRID AND
                                        CONNID IN G_R_CONNID AND
                                        FLDATE IN G_R_FLDATE AND
                                        BOOKID IN G_R_BOOKID ).
                    APPEND LINES OF L_T_DATA TO E_T_DATA.
                    DESCRIBE TABLE E_T_DATA LINES L_LINES.
                  WHEN 1.
*                   Start with selection from database at next fetch
                    G_STEP_EXTRMODE = RSAZT_C_EXTRMODE-DB.
                    EXIT.              "WHILE
                  WHEN OTHERS.
                    LOG_WRITE_FULL SY-MSGTY         "message type
                                   SY-MSGID         "message class
                                   SY-MSGNO         "message number
                                   SY-MSGV1         "message variable 1
                                   SY-MSGV2         "message variable 2
                                   SY-MSGV3         "message variable 3
                                   SY-MSGV4.        "message variable 4
                    RAISE ERROR_PASSED_TO_MESS_HANDLER.
                ENDCASE.
              ENDWHILE.
            ELSE.
*             Start with selection from database at next fetch
              G_STEP_EXTRMODE = RSAZT_C_EXTRMODE-DB.
            ENDIF.

          WHEN RSAZT_C_EXTRMODE-DB.

*           Process database selection

*           Check if extraction from database is requested
            IF G_STEP_EXTRMODE CP G_EXTRMODE.

* Open database cursor on first fetch to allow a database commit of
* Service API between initialization call and first fetch.
              IF G_CURSOR IS INITIAL.  "First fetch?
                OPEN CURSOR WITH HOLD G_CURSOR FOR
                SELECT (G_T_FIELDS) FROM SBOOK
                                         WHERE CARRID IN G_R_CARRID
                                           AND CONNID IN G_R_CONNID
                                           AND FLDATE IN G_R_FLDATE
                                           AND BOOKID IN G_R_BOOKID.
              ENDIF.

* Fetch records into interface table.
              FETCH NEXT CURSOR G_CURSOR
                         APPENDING CORRESPONDING FIELDS
                         OF TABLE E_T_DATA
                         PACKAGE SIZE G_S_INTERFACE-MAXSIZE.

              IF SY-SUBRC <> 0.
                CLOSE CURSOR G_CURSOR.
                CLEAR G_CURSOR.
                RAISE NO_MORE_DATA.
              ENDIF.
            ELSE.
              RAISE NO_MORE_DATA.
            ENDIF.

        ENDCASE.

        ADD 1 TO G_COUNTER_DATAPAKID.

      ENDIF.              "Initialization mode or data extraction ?

  ENDCASE.

ENDFUNCTION.
