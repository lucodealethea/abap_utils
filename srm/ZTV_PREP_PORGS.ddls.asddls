@AbapCatalog.sqlViewName: 'ZBI_PORGS'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@ClientDependent: true
@EndUserText.label: 'Prepare for Description Join with InfoType 1000'
define view ZTV_PREP_PORGS as select distinct from bbpv_pd_org as po
{
    substring(po.proc_org_resp,3,8) as PROC_ORG_RESP,
    substring(po.proc_org,3,8) as PROC_ORG,
    substring(po.proc_group,3,8) as PROC_GROUP
}