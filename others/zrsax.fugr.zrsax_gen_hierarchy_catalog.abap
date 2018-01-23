FUNCTION ZRSAX_GEN_HIERARCHY_CATALOG.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_DATASOURCE) TYPE  RSAOT_OLTPSOURCE
*"     VALUE(I_S_HIEBAS) TYPE  RSAP_S_HIEBAS
*"     VALUE(I_S_HIEFLAG) TYPE  RSAP_S_HIEFLAG
*"     VALUE(I_S_HIERSEL) TYPE  RSAP_S_HIER_LIST
*"  TABLES
*"      I_T_LANGU TYPE  SBIWA_T_LANGU
*"      E_T_HIERS TYPE  RSAP_T_HIERS
*"  EXCEPTIONS
*"      INVALID_CHABASNM_HCLASS
*"      INVALID_HIERARCHY_FLAG
*"      INVALID_HIERARCHY_SELECT
*"      LANGU_NOT_SUPPORTED
*"      HIERARCHY_NOT_FOUND
*"      APPLICATION_ERROR
*"--------------------------------------------------------------------


ENDFUNCTION.
*---------------------------------------------------------------------*
* Vorgehensweise für die Katalog-Funktion:
* 1) Benennen der Funktion/FG/EK (BW Content)
* 2) Schnittstelle der Funktion: (keine Änderung zu BW 2.0)
*    Imput:  I_S_HIEBAS  TYPE  RSAP_S_HIEBAS
*    Imput:  I_S_HIEFLAG TYPE  RSAP_S_HIEFLAG
*    Imput:  I_S_HIERSEL TYPE  RSAP_S_HIER_LIST (OPTIONAL)
*    Imput:  I_T_LANGU   TYPE  SBIWA_T_LANGU
*    Output: E_T_HIERS   TYPE  RSAP_T_HIERS
* -> Ab BW 30 neue INPUT-Parameter
*    Imput:  I_OLTPSOURCE TYPE RSAOT_OLTPSOURCE
*    Mit diesem Parameter hat man die Möglichkeit, die komplette
*    Eigenschaften der DataSource I_OLTPSOURCE zu erhalten.
*    (Aufruf der Funktion RSA1_SINGLE_OLTPSOURCE_GET)
* 3) Pflege der DataSource mit der Transaktion RSA2
*---------------------------------------------------------------------*
