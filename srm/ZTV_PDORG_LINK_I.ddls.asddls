@AbapCatalog.sqlViewName: 'ZBI_LKPDORG_I'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Linkage to BBP_PDORG at Item Level'
//not tested yet - expect crmd_orderadm_i.header join
define view ZTV_PDORG_LINK_I as select from bbp_pdorg as org
inner join crmd_link as link
    on org.set_guid = link.guid_set 
    and link.objtype_hi ='06' // is it ?
    and link.objtype_set =  '21'
    {
    key link.guid_hi,
    org.proc_group,
    org.proc_org,
    org.proc_org_resp,
    1 as org_ctr
    
}