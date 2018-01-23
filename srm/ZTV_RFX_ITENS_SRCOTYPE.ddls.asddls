@AbapCatalog.sqlViewName: 'ZBI_RFXITSRCOT'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Solicitação de Cotação outer join SC by SRC_OBJECT_TYPE'
define view ZTV_RFX_ITENS_SRCOTYPE as
select
from crmd_orderadm_h as rep_header
inner join crmd_orderadm_i as rfx on rep_header.guid = rfx.header
inner join bbp_pdigp as rep_igp on rep_igp.guid = rfx.guid
inner join bbp_pdhgp as rep_hgp on rep_hgp.guid = rfx.header  
left outer join zbi_rfx_itensca as zsc  
on rep_header.guid = zsc.rep_guid
and rfx.client = zsc.mandt
and rfx.header = zsc.rep_guid
and rfx.guid = zsc.rep_item_guid
and rep_header.client = zsc.mandt

{
key rep_header.client,
key rep_header.guid as rep_guid,
key rfx.guid as rep_item_guid,
key rep_header.object_id,
key rep_header.object_type,
key rep_igp.src_object_type,
zsc.rep_objid, //rfq_objid
zsc.rfx_objid, //sc_objid,
zsc.rep_item_guid as zrep_item_guid,//rfq_item_guid
rep_hgp.version_type,
rep_hgp.doc_closed,
rep_igp.del_ind,
rep_igp.exlin as rep_exlin,
case substring( rep_igp.exlin , 5, 1) when '.' then 'H'
 else 'N'
 end as rep_grouping_handling,
rep_igp.grouping_level,
substring( rep_igp.exlin , 1, 4) as rep_lote,
substring( rep_igp.exlin , 6, 4) as rep_sqn_lote,
case when rfx.guid = zsc.rep_item_guid then
case when rep_igp.src_object_type = 'BUS2000136' then 'CTR'
when rep_igp.src_object_type = 'BUS2121001' then 'SCA'
when rep_igp.src_object_type = 'BUS2200001' then 'RFQ'
else '---'
end
else 
case when rep_igp.src_object_type = 'BUS2000136' then 'CTR'
//when rep_igp.src_object_type = 'BUS2121001' then 'SCA'
when rep_igp.src_object_type = 'BUS2200001' then 'RFQ'
else 'NUL'
end 
end as flag_nosc,
1 as counter
}
where rep_header.object_type = 'BUS2200'