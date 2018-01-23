@AbapCatalog.sqlViewName: 'ZBI_GUIDSCRFQ'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Relações SC e RFQ Guid E Item Guid'
@ClientDependent: true
define view ZTV_RFX_GUID_SC_RFQ as select distinct from crmd_orderadm_h as rfx_header
left outer join bbpc_proc_type_t as proct on rfx_header.client = proct.client and proct.process_type = rfx_header.process_type and proct.langu = 'P'
left outer join crmd_orderadm_i as rfx on rfx_header.guid = rfx.header
left outer join bbp_pdhgp as rfx_hgp on rfx_header.guid = rfx_hgp.guid
left outer join bbp_pdigp as rep_igp on rep_igp.src_guid = rfx.guid
left outer join bbp_pdhsc as hsc on hsc.guid = rfx_header.guid
left outer join bbp_pdisc as isc on rep_igp.src_guid = isc.guid       
left outer join crmd_orderadm_i as rep on rep.guid = rep_igp.guid 
left outer join crmd_orderadm_h as rep_header on rep.header = rep_header.guid
left outer join bbp_pdhgp as rep_hgp on rep_hgp.guid = rep_header.guid 
left outer join bbp_pdigp as igp on igp.src_guid = rfx.guid //gets items da RFQ
left outer join crmd_orderadm_i on crmd_orderadm_i.guid = igp.guid and crmd_orderadm_i.header = rep_header.guid

 { key
 case
  when rep_igp.src_object_type = 'BUS2000136' then 'CTR'
  when rep_igp.src_object_type = 'BUS2121001' then 'SCA'
  when rep_igp.src_object_type = 'BUS2121001' then 'RFQ'
  when rep_igp.src_object_type = '' then 'NUL'
  else 'NUL'
 end as flag_nosc,
 key rep_igp.guid as rep_item_guid, //rfq_item_guid,
 key rep_igp.src_guid as rfx_item_guid, //sc_item_guid,
 
 rfx_header.object_id as rfx_objid, //sc_objid,
 rfx_header.object_type as rfx_type, //rfx_sc_type
 rep.header as rep_guid, //rfq_guid,
 rep_header.object_id as rep_objid, //rfq_objid
 rep_header.object_type as rep_type, //rep_rfq_type
 rfx.number_int as rfx_no_int, //sc_no_int,
 rep.number_int  as rep_no_int, //rfq_no_int,
 rep_igp.exlin as rep_exlin, //rfq_exlin,
 
 case substring( rep_igp.exlin , 5, 1) when '.' then 'H'
 else 'N'
 end
 as grouping_handling,
 substring( rep_igp.exlin , 1, 4) as lote,
 substring( rep_igp.exlin , 6, 4) as sqn_lote,
 
 rfx.header as rfx_guid, //sc_guid,
 rfx_header.description,
 rfx_header.process_type, 
 rfx_header.posting_date,
 case rfx_header.process_type 
when 'ZINX'
then 
case 
when hsc.zz_desccgu = '' then 'Inexigibilidade'
else hsc.zz_desccgu
end
when 'ZDDS'
then 
case 
 when hsc.zz_desccgu = '' then 'Demais Situações'
else hsc.zz_desccgu
end
else proct.p_description_20 end as zz_desccgu,

case
when hsc.zzlic_datahomolagacao = '00000000' then rfx_header.posting_date
else hsc.zzlic_datahomolagacao end
as data_homologacao,

case when hsc.zzlic_etapa_processo_wf  = '3'
 then 'X'
  else ''
end as flag_homo,
hsc.zzshc_logo as shc_logo_agrupado,
hsc.zz_lic_compart,
hsc.zz_lic_natur_obj,
hsc.zzlic_etapa_processo_wf,
hsc.zzlic_critjul,
isc.zz_be_co_code as REP_CO_CODE,
rfx.description_uc,
rfx.ordered_prod as ordered_prod,
rfx.product as product,
rep_igp.category_id,
rep_igp.src_object_type,

rep_hgp.version_type,
rep_hgp.doc_closed,

rep_igp.unit as rep_unit,
rep_igp.quantity as rep_quantity,
rep_igp.price as rep_price,
rep_igp.value as rep_value,

case 
when isc.zzlic_price = 0 then rep_igp.price
else isc.zzlic_price
end as zzlic_price,

case 
when isc.zzlic_totalprice = 0 then rep_igp.value
else isc.zzlic_totalprice
end as zzlic_totalprice,

rep_igp.gross_price as rep_gross_price,
hsc.zzlic_totalestimado,
rfx_hgp.total_value as rfx_total_value,
rep_hgp.total_value as rep_total_value, //ie. RFQ total Value

1 as counter
 }
 where rfx_header.object_type = 'BUS2121' and rep_header.object_type = 'BUS2200'
 //and rep_hgp.version_type <> 'H' and rep_hgp.version_type <> 'C' and rep_hgp.doc_closed <> 'X' and rep_igp.del_ind <> 'X';