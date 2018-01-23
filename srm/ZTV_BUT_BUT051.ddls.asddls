@AbapCatalog.sqlViewName: 'ZBI_BUT051'
@ClientDependent: true
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Partner Pessoas Contact Person'
define view ZTV_BUT_BUT051 as select from 
but000 as T0 inner join zbi_butcrm as rfx_partner 
on  T0.client = rfx_partner.client 
and T0.partner = rfx_partner.partner
left outer join but051 as T1
on T1.client = T0.client
and T1.partner1 = T0.partner 
{
key T0.client   as  CLIENT,
key T0.partner  as  PARTNER,
key T1.partner2 as  PARTNER2,
//T1.PARTNER1 AS  PARTNER1,
T0.name_last    as  NAME_LAST,
T0.name_first   as  NAME_FIRST,
T0.mc_name1 as  MC_NAME1,
T0.mc_name2 as  MC_NAME2,
T0.name_org1    as  NAME_ORG1,
T0.name_org2    as  NAME_ORG2,
T1.tel_number   as  TEL_NUMBER,
T1.tel_extens   as  TEL_EXTENS,
T1.smtp_address as  SMTP_ADDRESS
//T0.TYPE AS  TYPE,
//T0.BPKIND   AS  BPKIND,
//T0.BU_GROUP AS  BU_GROUP,
//T0.BPEXT    AS  BPEXT,
//T0.BU_SORT1 AS  BU_SORT1,
//T0.BU_SORT2 AS  BU_SORT2,
//T0.SOURCE   AS  SOURCE,
//T0.TITLE    AS  TITLE,
//T0.XDELE    AS  XDELE,
//T0.XBLCK    AS  XBLCK,
//T0.AUGRP    AS  AUGRP,
//T0.TITLE_LET    AS  TITLE_LET,
//T0.BU_LOGSYS    AS  BU_LOGSYS,
//T0.CONTACT  AS  CONTACT,
//T0.NOT_RELEASED AS  NOT_RELEAS,
//T0.NOT_LG_COMPETENT AS  NOT_LG_COM,
//T0.PRINT_MODE   AS  PRINT_MODE,
//T0.BP_EEW_DUMMY AS  BP_EEW_DUM,
//T0.NAPR AS  NAPR,
//T0.BBP_IPISP    AS  BBP_IPISP,
//T0.NAME_ORG3    AS  NAME_ORG3,
//T0.NAME_ORG4    AS  NAME_ORG4,
//T0.LEGAL_ENTY   AS  LEGAL_ENTY,
//T0.IND_SECTOR   AS  IND_SECTOR,
//T0.LEGAL_ORG    AS  LEGAL_ORG,
//T0.FOUND_DAT    AS  FOUND_DAT,
//T0.LIQUID_DAT   AS  LIQUID_DAT,
//T0.LOCATION_1   AS  LOCATION_1,
//T0.LOCATION_2   AS  LOCATION_2,
//T0.LOCATION_3   AS  LOCATION_3,
//T0.NAME_LST2    AS  NAME_LST2,
//T0.NAME_LAST2   AS  NAME_LAST2,
//T0.NAMEMIDDLE   AS  NAMEMIDDLE,
//T0.TITLE_ACA1   AS  TITLE_ACA1,
//T0.TITLE_ACA2   AS  TITLE_ACA2,
//T0.TITLE_ROYL   AS  TITLE_ROYL,
//T0.PREFIX1  AS  PREFIX1,
//T0.PREFIX2  AS  PREFIX2,
//T0.NAME1_TEXT   AS  NAME1_TEXT,
//T0.NICKNAME AS  NICKNAME,
//T0.INITIALS AS  INITIALS,
//T0.NAMEFORMAT   AS  NAMEFORMAT,
//T0.NAMCOUNTRY   AS  NAMCOUNTRY,
//T0.LANGU_CORR   AS  LANGU_CORR,
//T0.XSEXM    AS  XSEXM,
//T0.XSEXF    AS  XSEXF,
//T0.BIRTHPL  AS  BIRTHPL,
//T0.MARST    AS  MARST,
//T0.EMPLO    AS  EMPLO,
//T0.JOBGR    AS  JOBGR,
//T0.NATIO    AS  NATIO,
//T0.CNTAX    AS  CNTAX,
//T0.CNDSC    AS  CNDSC,
//T0.PERSNUMBER   AS  PERSNUMBER,
//T0.XSEXU    AS  XSEXU,
//T0.XUBNAME  AS  XUBNAME,
//T0.BU_LANGU AS  BU_LANGU,
//T0.BIRTHDT  AS  BIRTHDT,
//T0.DEATHDT  AS  DEATHDT,
//T0.PERNO    AS  PERNO,
//T0.CHILDREN AS  CHILDREN,
//T0.MEM_HOUSE    AS  MEM_HOUSE,
//T0.PARTGRPTYP   AS  PARTGRPTYP,
//T0.NAME_GRP1    AS  NAME_GRP1,
//T0.NAME_GRP2    AS  NAME_GRP2,
//T0.CRUSR    AS  CRUSR,
//T0.CRDAT    AS  CRDAT,
//T0.CRTIM    AS  CRTIM,
//T0.CHUSR    AS  CHUSR,
//T0.CHDAT    AS  CHDAT,
//T0.CHTIM    AS  CHTIM,
//T0.PARTNER_GUID AS  PARTNER_GU,
//T0.ADDRCOMM AS  ADDRCOMM,
//T0.TD_SWITCH    AS  TD_SWITCH,
//T0.IS_ORG_CENTRE    AS  IS_ORG_CEN,
//T0.DB_KEY   AS  DB_KEY,
//T0.VALID_FROM   AS  VALID_FROM,
//T0.VALID_TO AS  VALID_TO,
//T0.XPCPT    AS  XPCPT,
//T0.NATPERS  AS  NATPERS,
//T1.CLIENT   AS  CLIENT,
//T1.RELNR    AS  RELNR,
//T1.DATE_TO  AS  DATE_TO,
//T1.RELTYP   AS  RELTYP,
//T1.XRF  AS  XRF,
//T1.FNCTN    AS  FNCTN,
//T1.PAFKT    AS  PAFKT,
//T1.DPRTMNT  AS  DPRTMNT,
//T1.ABTNR    AS  ABTNR,
//T1.PAAUTH   AS  PAAUTH,
//T1.PAVIP    AS  PAVIP,
//T1.PAREM    AS  PAREM,
//T1.REL_PER  AS  REL_PER,
//T1.REL_AMO  AS  REL_AMO,
//T1.REL_CUR  AS  REL_CUR,
//T1.CALL_RULEID  AS  CALL_RULEI,
//T1.VISIT_RULEID AS  VISIT_RULE,
//T1.CALL_GUID    AS  CALL_GUID,
//T1.VISIT_GUID   AS  VISIT_GUID,
//T1.BP_EEW_BUT051    AS  BP_EEW_BUT
}
group by 
T0.client,
T0.partner,
T1.partner2,
T0.name_last,
T0.name_first,
T0.mc_name1,
T0.mc_name2,
T0.name_org1,
T0.name_org2,
T1.tel_number,
T1.tel_extens,
T1.smtp_address;