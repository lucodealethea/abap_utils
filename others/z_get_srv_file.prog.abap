REPORT z_get_srv_file .
* example from tcode /al11

PARAMETERS: file TYPE SAPB-SAPPFAD
default '/usr/sap/trans/cofiles/K900072.W10'. "W10K900067

PARAMETERS: lfile TYPE SAPB-SAPPFAD
default 'c:\Temp\K900072.W10'.


START-OF-SELECTION.
  CALL FUNCTION 'ARCHIVFILE_SERVER_TO_CLIENT'
    EXPORTING
      path             = file
     TARGETPATH        = lfile
 EXCEPTIONS
   ERROR_FILE       = 1
   OTHERS           = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
