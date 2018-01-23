@AbapCatalog.sqlViewName: 'ZBI_LKPRTNR'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Linkage to CRMD_PARTNER'

define view ZTV_PRTNR_LINK as select from zbi_butcrm as partner
inner join crmd_link as link
    on partner.guid = link.guid_set
    and partner.disabled <> 'X' 
    and ( link.objtype_hi ='05'
    // or link.objtype_hi ='06'
    )
    and link.objtype_set =  '07'
    {
    key link.guid_hi as crm_order_guid,
    key 'QUT' as origin,
    partner.partner,
    partner.partner_no,
    partner.guid,
    partner.type,
    partner.bpkind,
    partner.name_last,
    partner.name_first,
    partner.namemiddle,
    partner.name1_text,
    partner.persnumber,
    //partner.mc_name1,
    REPLACE(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT( CONCAT( partner.name_org1, '|-| |-|'), partner.name_org2), '|-| |-|'), partner.name_org3), '|-| |-|'),partner.name_org4), '|-| |-|'),'|-|', '') as MC_NAME1,
    partner.mc_name2,
    partner.name_org1,
    partner.name_org2,
    partner.name_org3,
    partner.name_org4,
    partner.chusr,
    partner.addrcomm,
    partner.partner_fct,
    partner.addr_nr,
    partner.addr_np,
    partner.mainpartner,
    partner.addr_type,
    partner.disabled,
    1 as partner_ctr   
}
//where partner.partner_fct = '00000019' 