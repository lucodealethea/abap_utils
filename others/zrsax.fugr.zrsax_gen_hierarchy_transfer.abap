FUNCTION ZRSAX_GEN_HIERARCHY_TRANSFER.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_REQUNR) TYPE  SBIWA_S_INTERFACE-REQUNR OPTIONAL
*"     VALUE(I_OSOURCE) TYPE  SBIWA_S_INTERFACE-ISOURCE OPTIONAL
*"     VALUE(I_MAXSIZE) TYPE  SBIWA_S_INTERFACE-MAXSIZE OPTIONAL
*"     VALUE(I_INITFLAG) TYPE  SBIWA_S_INTERFACE-INITFLAG OPTIONAL
*"     VALUE(I_S_HIEBAS) TYPE  RSAP_S_HIEBAS OPTIONAL
*"     VALUE(I_S_HIEFLAG) TYPE  RSAP_S_HIEFLAG OPTIONAL
*"     VALUE(I_S_HIERSEL) TYPE  RSAP_S_HIER_LIST OPTIONAL
*"     VALUE(I_RLOGSYS) TYPE  RSAP_S_REQUEST-RCVPRN OPTIONAL
*"  EXPORTING
*"     VALUE(E_PACKAGES) TYPE  SBIWA_FLAG
*"     VALUE(E_S_HEADER)
*"  TABLES
*"      I_T_LANGU TYPE  SBIWA_T_LANGU OPTIONAL
*"      E_T_HIETEXT TYPE  RSAP_T_HIETEXT OPTIONAL
*"      E_T_HIENODE OPTIONAL
*"      E_T_FOLDERT TYPE  RSAP_T_FOLDERT OPTIONAL
*"      E_T_HIEINTV OPTIONAL
*"  EXCEPTIONS
*"      INVALID_CHABASNM_HCLASS
*"      INVALID_HIERARCHY_FLAG
*"      INVALID_HIERARCHY_SELECT
*"      LANGU_NOT_SUPPORTED
*"      HIERARCHY_TAB_NOT_FOUND
*"      APPLICATION_ERROR
*"--------------------------------------------------------------------


ENDFUNCTION.

*---------------------------------------------------------------------*
* Vorgehensweise für die Transfer-Funktion:
* 1) Benennen der Funktion: (keine Namekonvention)
* 2) Schnittstelle: (keine große Änderung zu BW 2.0)
*  ->Imput:  I_OLTPSOURCE -> Funktion RSA1_SINGLE_OLTPSOURCE_GET
*  ->Paketierungsmöglichkeit für Hierarchien
*    Imput:  I_MAXSIZE  (OPTIONAL) -> ' ' keine Paketierung möglich
*                                     'X' für die Paketierung
*    Imput:  I_INITFLAG (OPTIONAL) -> ' ' Paketierung -> Initial
*                                     'X' Paketierung -> Beginn
*    Output: E_MOREDATA (OPTIONAL) -> ' ' keine Daten mehr
*                                     'X' Daten kommt
*  ->Übertragung der gen. Methode mit den Attribute
*    TABLES:  E_T_HIENODE STRUCTURE  ROVERFNOD2
*    TABLES:  E_T_HIEINTV STRUCTURE  ROVERFHIN2 OPTIONAL
*  ->
*     TABLES: I_T_LANGU
*     TABLES: E_T_HIETEXT
*     TABLES: E_T_FOLDERT

*     mit diesem Parameter hat man die Möglichkeit komplette Attributen
*     der DataSource I_OLTPSOURCE zu bekommen.
*     -> Mit Hilfe der Funktion RSA1_SINGLE_OLTPSOURCE_GET
*     Imput:  I_S_HIEBAS  TYPE  RSAP_S_HIEBAS
*     Imput:  I_S_HIEFLAG TYPE  RSAP_S_HIEFLAG
*     Imput:  I_S_HIERSEL TYPE  RSAP_S_HIER_LIST (OPTIONAL)
*     Imput:  I_T_LANGU   TYPE  SBIWA_T_LANGU
*     Output: E_T_HIERS   TYPE  RSAP_T_HIERS
* (3) Pflegen der DataSource mit der Transaktion RSA2
*---------------------------------------------------------------------*
