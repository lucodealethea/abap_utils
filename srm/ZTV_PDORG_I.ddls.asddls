@AbapCatalog.sqlViewName: 'ZBI_PDORG_I'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Relações CRM Order Item e Org'
define view ZTV_PDORG_I as select distinct from crmd_orderadm_h as hdr
inner join crmd_orderadm_i as itm on hdr.guid = itm.header
inner join bbp_pdigp as igp on itm.guid = igp.guid
inner join bbp_pdhgp as hgp on hdr.guid = hgp.guid
left outer join crmd_link as link on  (hdr.guid = link.guid_hi and link.objtype_hi ='05' and link.objtype_set =  '21')
left outer join bbp_pdorg as org on  link.guid_set = org.set_guid

 {
 itm.header as header,
 itm.guid as igp_guid,
 org.set_guid,
 org.del_ind,
 org.proc_org_resp,
 org.proc_org,
 org.proc_group
 
 }
