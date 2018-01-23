@AbapCatalog.sqlViewName: 'ZBI_RFX_ITENSNUL'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'ZTV_RFX_ITENS_NUL'
define view ZTV_RFX_ITENS_NUL as 
select from (( zbi_rfxitsrcot as srct 
inner join crmd_orderadm_h as rfx_header on rfx_header.guid = srct.rep_guid and rfx_header.client = srct.client and srct.flag_nosc = 'NUL')
inner join crmd_orderadm_i as rfx on rfx.guid = srct.rep_item_guid and rfx.header = srct.rep_guid)
inner join bbp_pdhsc as hsc on hsc.guid = srct.rep_guid and hsc.client = srct.client
inner join bbp_pdhgp as rfx_hgp on rfx_hgp.client = srct.client and rfx_hgp.guid = srct.rep_guid 
inner join bbpc_proc_type_t as proct on proct.client = srct.client and proct.process_type = rfx_header.process_type and proct.langu = 'P'
inner join bbp_pdigp as rep_igp on rep_igp.guid = srct.rep_item_guid //not src_guid 
left outer join bbp_pdisc as isc on isc.guid = srct.rep_item_guid

{   key srct.flag_nosc as origin,
    key rfx.guid as rep_item_guid, //rfq_item_guid
    key rfx_header.guid as rep_guid, //rfq_guid,
    key srct.rep_guid as rfx_item_guid,// filled in equallly to allow union
    key rfx.guid as rfx_guid, // filled in equally to allow union
'' as rfx_objid, //RFQ fonte rfx_objid
'' as rfx_type, //BUS2200
rfx_header.object_id as rep_objid,// RFQ objectt_id
rfx_header.object_type as rep_type, //BUS2200
'0000000000' as rfx_no_int,
rfx.number_int  as rep_no_int,
'0000000000000000000000000000000000000000' as rfx_exlin,
rep_igp.exlin as rep_exlin,
' ' as rfx_grouping_handling,
case substring( rep_igp.exlin , 5, 1) when '.' then 'H'
 else 'N'
 end as rep_grouping_handling,
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
rfx.description_uc,
rfx.ordered_prod as ordered_prod,
rfx.product as product,
rep_igp.category_id,
rep_igp.src_object_type,
rfx_hgp.version_type,
rfx_hgp.doc_closed,

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
0 as rep_total_value, //Total Value of Main RFQ

'   ' as rfx_unit,
0 as rfx_quantity,
0 as rfx_price,
0 as rfx_value,
0 as rfx_gross_price,

1 as counter

}
where srct.grouping_level <> 'L' and srct.version_type <> 'C' and srct.doc_closed <> 'X' and srct.del_ind <> 'X';
