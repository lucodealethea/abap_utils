@AbapCatalog.sqlViewName: 'ZBI_RFX_ITM'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Relação Carinhos#Sol de Quot'
@ClientDependent: true
//RFX is RFQ REP is shopping cart -- into left outer joins for RFQ without Shopping carts
// bridge to other document is src_guid
define view ZTV_BIS_RFX_ITM as 
select from crmd_orderadm_h as rfx_header
inner join bbpc_proc_type_t as proct on proct.client = rfx_header.client and proct.process_type = rfx_header.process_type and proct.langu = 'P'
inner join crmd_orderadm_i as rfx on rfx.header = rfx_header.guid
left outer join bbp_pdhgp as rfx_hgp on rfx_header.guid = rfx_hgp.guid
left outer join bbp_pdigp as rfx_igp on rfx_igp.guid = rfx.guid
left outer join bbp_pdhsc as rfx_hsc on rfx_hsc.guid = rfx_header.guid
left outer join bbp_pdisc as rfx_isc on rfx_isc.guid = rfx.guid
left outer join crmd_orderadm_i as rep on rep.guid  = rfx_igp.src_guid  --//src_guid
left outer join crmd_orderadm_h as rep_header on rep_header.guid = rep.header 
left outer join bbp_pdhgp as rep_hgp on rep_hgp.guid = rep_header.guid 
left outer join bbp_pdigp as rep_igp on rep_igp.guid = rep.guid 
left outer join crmd_orderadm_i on crmd_orderadm_i.guid = rep_igp.guid and crmd_orderadm_i.header = rep_header.guid 
                                
           {
           
  key
 case
  when rfx_igp.src_object_type = 'BUS2000136' then 'CTR'
  when rfx_igp.src_object_type = 'BUS2121001' then 'SCA'
  when rfx_igp.src_object_type = 'BUS2121001' then 'RFQ'
  when rfx_igp.src_object_type = '' then 'NUL'
  else 'NUL'
 end as flag_nosc,
 key rfx_igp.guid as rep_item_guid, //rfq_item_guid,
 key rep_igp.src_guid as rfx_item_guid, //sc_item_guid,

 rfx.header as rep_guid, //rfq_guid,

 rfx_header.object_id as rfx_objid, //rfq_objid
 rfx_header.object_type as rfx_type, //rfq_type

 rep_header.object_id as rep_objid, //sc_objid,
 rep_header.object_type as rep_type, //rfx_type

 rfx.number_int as rfx_no_int,  //rfq_no_int,
 rep.number_int  as rep_no_int, //sc_no_int,
 rfx_igp.exlin as rfx_exlin, //rfq_exlin,
 rep_igp.exlin as rep_exlin, //useless-sc-does not have exlin,
 
 case substring( rfx_igp.exlin , 5, 1) when '.' then 'H'
 else 'N'
 end
 as grouping_handling,
 substring( rfx_igp.exlin , 1, 4) as lote,
 substring( rfx_igp.exlin , 6, 4) as sqn_lote,
 
 rfx.header as rfx_guid, //sc_guid,
 rfx_header.description,
 rfx_header.process_type, 
 rfx_header.posting_date,
 case rfx_header.process_type 
when 'ZINX'
then 
case 
when rfx_hsc.zz_desccgu = '' then 'Inexigibilidade'
else rfx_hsc.zz_desccgu
end
when 'ZDDS'
then 
case 
 when rfx_hsc.zz_desccgu = '' then 'Demais Situações'
else rfx_hsc.zz_desccgu
end
else proct.p_description_20 end as zz_desccgu,

case
when rfx_hsc.zzlic_datahomolagacao = '00000000' then rfx_header.posting_date
else rfx_hsc.zzlic_datahomolagacao end
as data_homologacao,

case when rfx_hsc.zzlic_etapa_processo_wf  = '3'
 then 'X'
  else ''
end as flag_homo,
rfx_hsc.zzshc_logo as shc_logo_agrupado,
rfx_hsc.zz_lic_compart,
rfx_hsc.zz_lic_natur_obj,
rfx_hsc.zzlic_etapa_processo_wf,
rfx_hsc.zzlic_critjul,
rfx_isc.zz_be_co_code as REP_CO_CODE,
rfx.description_uc,
rfx.ordered_prod as ordered_prod,
rfx.product as product,
rfx_igp.category_id,
rfx_igp.src_object_type,

rfx_hgp.version_type,
rfx_hgp.doc_closed,

rep_igp.unit as rep_unit,
rep_igp.quantity as rep_quantity,
rep_igp.price as rep_price,
rep_igp.value as rep_value,

case 
when rfx_isc.zzlic_price = 0 then rep_igp.price
else rfx_isc.zzlic_price
end as zzlic_price,

case 
when rfx_isc.zzlic_totalprice = 0 then rep_igp.value
else rfx_isc.zzlic_totalprice
end as zzlic_totalprice,

rep_igp.gross_price as rep_gross_price,
rfx_hsc.zzlic_totalestimado,
rfx_hgp.total_value as rfx_total_value,//ie. RFQ total Value
rep_hgp.total_value as rep_total_value, 

1 as counter
}
where not rep_header.object_type is null 
//rfx_header.object_type = 'BUS2200' 
//and rep_header.object_type = 'BUS2121'
//rfx_igp.del_ind <> 'X' and rfx_igp.del_ind <> 'X' and ( not rfx_hgp.doc_closed = 'X' or not rfx_hgp.version_type = 'C' )
