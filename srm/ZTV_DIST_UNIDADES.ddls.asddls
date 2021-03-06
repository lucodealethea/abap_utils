@AbapCatalog.sqlViewName: 'ZBI_DISTUNID'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'ZTV_DIST_UNIDADES - IDT List of Values'
define view ZTV_DIST_UNIDADES 
as 
select from crmd_orderadm_h as rfx_header
left outer join crmd_orderadm_i as rfx on rfx.header = rfx_header.guid
and rfx_header.object_type = 'BUS2202' 
--inner join crm_jest as jest on rfx_header.guid = jest.objnr and jest.stat = 'I1014'
left outer join bbp_pdhgp as rfx_hgp on rfx_header.guid = rfx_hgp.guid
left outer join bbp_pdigp as rfx_igp on rfx_igp.guid = rfx.guid
left outer join crmd_orderadm_i as rep on rep.guid  = rfx_igp.src_guid  --//src_guid
left outer join crmd_orderadm_h as rep_header on rep_header.guid = rep.header and rep_header.object_type = 'BUS2200'
left outer join bbpc_proc_type_t as proct on proct.client = rep_header.client and proct.process_type = rep_header.process_type and proct.langu = 'P'
left outer join bbp_pdhsc as rep_hsc on rep_hsc.guid = rep_header.guid
left outer join bbp_pdisc as rep_isc on rep_isc.guid = rep.guid
left outer join bbp_pdhgp as rep_hgp on rep_hgp.guid = rep_header.guid 
left outer join bbp_pdigp as rep_igp on rep_igp.guid = rep.guid
inner join zbi_lkprtnr75 as UN on UN.crm_order_guid = rep_igp.guid    
{
key rfx_header.client,
key rep_header.guid as rep_guid,//Guid do Item da RFQ - Solicitação
--key rep_igp.guid as rep_item_guid,
key rep_header.object_id as rep_objid,
--key UN.partner, 
--,REPLACE(CONCAT( CONCAT( UN.mc_name1, '|-| |-|'),UN.mc_name2),'|-|', '') as mc_name1
count(distinct UN.partner) as ctr
}
group by
rfx_header.client,
rep_header.guid,
--key rep_igp.guid as rep_ikey UN.partner,em_guid,
rep_header.object_id
--UN.partner
--,
--UN.mc_name1,
--UN.mc_name2
 