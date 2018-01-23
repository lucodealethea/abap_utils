@AbapCatalog.sqlViewName: 'ZBI_RFX_ITENSRFQ'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Then Union as Outer Join where RFX is also RFQ'
@ClientDependent: true
// rfx here is here RFQ -not- SC but either RFQ either CTR
define view ZTV_RFX_ITENS_RFQ as 
select from crmd_orderadm_h as rfx_header
inner join zbi_rfxitsrcot as srct on rfx_header.guid = srct.rep_guid and rfx_header.client = srct.client and srct.flag_nosc = 'RFQ'
inner join crmd_orderadm_i as rfx on srct.rep_item_guid = rfx.guid //rfx_header.guid = rfx.header and
inner join bbp_pdhsc as hsc on hsc.guid = rfx_header.guid and hsc.client = rfx_header.client

inner join bbp_pdhgp as rfx_hgp on rfx_header.client = rfx_hgp.client and rfx_header.guid = rfx_hgp.guid
inner join bbpc_proc_type_t as proct
on  rfx_header.client = proct.client
and  proct.process_type = rfx_header.process_type and proct.langu = 'P'

inner join bbp_pdigp as rep_igp on rep_igp.src_guid = rfx.guid
inner join crmd_orderadm_i as rep on rep_igp.guid = rep.guid  
inner join crmd_orderadm_h as rep_header on rep_header.guid = rep.header
inner join bbp_pdigp as igp on rfx.guid = igp.src_guid 
inner join crmd_orderadm_i as i on i.guid = igp.guid and i.header = rep_header.guid

left outer join bbp_pdisc as isc on rep_igp.guid = isc.guid

inner join bbp_pdhgp as rep_hgp on rep_header.client = rep_hgp.client and rep_header.guid = rep_hgp.guid
{ 
key 'RFQ' as origin,
key igp.guid as rep_item_guid , // item da RFQ
key rep_header.guid as rep_guid, // guid da RFQ 
key rep_igp.src_guid as rfx_item_guid, //guid do item da RFQ fonte = rfx_objid
key rfx.header as rfx_guid , //guid da RFQ fonte 
rfx_header.object_id as rfx_objid, //RFQ fonte rfx_objid
rfx_header.object_type as rfx_type, //BUS2200
rep_header.object_id as rep_objid,// RFQ objectt_id
rep_header.object_type as rep_type, //BUS2200
rfx.number_int as rfx_no_int,
rep.number_int  as rep_no_int,
'0000000000000000000000000000000000000000' as rfx_exlin,
rep_igp.exlin as rep_exlin,
' ' as rfx_grouping_handling,
case substring( rep_igp.exlin , 5, 1) when '.' then 'H'
 else 'N'
 end
as rep_grouping_handling,
'    ' as rfx_lote,
'    ' as rfx_sqn_lote,
substring( rep_igp.exlin , 1, 4) as rep_lote,
substring( rep_igp.exlin , 6, 4) as rep_sqn_lote,

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
i.description_uc,
rfx.ordered_prod as ordered_prod,
rfx.product as product,
igp.category_id,
igp.src_object_type,
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
rfx_hgp.total_value as rfx_total_value, // Total Value of Source RFQ
rep_hgp.total_value as rep_total_value, //Total Value of Main RFQ

igp.unit as rfx_unit,
igp.quantity as rfx_quantity,
igp.price as rfx_price,
igp.value as rfx_value,
igp.gross_price as rfx_gross_price,

1 as counter
}

where 
rep_header.object_type = 'BUS2200' and
rfx_header.object_type = 'BUS2200' 
and srct.grouping_level <> 'L' and srct.version_type <> 'C' 
//and srct.doc_closed <> 'X' 
and srct.del_ind <> 'X';