FUNCTION ZRSAX_HIERARCHY_CATALOG_HCLASS .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_S_HIEBAS) TYPE  RSAP_S_HIEBAS
*"     VALUE(I_S_HIEFLAG) TYPE  RSAP_S_HIEFLAG
*"     VALUE(I_S_HIERSEL) TYPE  RSAP_S_HIER_LIST OPTIONAL
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
* Vorgehen:
* (1) Benennen der Funktion: FG_hierarchy_catalog_HC
*     Diese Funktion FG_hierarchy_catalog_HC wird in der FG BHIE und
*     in dem Unterprogramm FG_hierarchy_catalog_HC aufgerufen.
* (2) Schnittstelle:
*     Imput:  I_S_HIEBAS  TYPE  RSAP_S_HIEBAS
*     Imput:  I_S_HIEFLAG TYPE  RSAP_S_HIEFLAG
*     Imput:  I_S_HIERSEL TYPE  RSAP_S_HIER_LIST (OPTIONAL)
*     Imput:  I_T_LANGU   TYPE  SBIWA_T_LANGU
*     Output: E_T_HIERS   TYPE  RSAP_T_HIERS
* (3) Pflegen der Tabelle RODCHABAS-RSSHIE (I_S_HIEFLAG)
*     Hierarchiesteuerkennzeichen zu Basismerkmalen
* (4) Pflegen der Tabelle ROHIEBAS         (I_S_HIEBAS)
*     Zuordnung Hierarchieklasse/Domäne/Datenelement zu Basismerkmal
* (5) Verzeichnis von Hierarchien:       trsthv - trsthvt?
* (6) Applikationspezifische Tabellen für Hierarchien?
*---------------------------------------------------------------------*
