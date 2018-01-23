@AbapCatalog.sqlViewName: 'ZBI_SC_ELIM'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Base para derivar Guids para ZSRMTB0010'
@ClientDependent: true
//RFX is RFQ REP is shopping cart -- into left outer joins for RFQ without Shopping carts
// bridge to other document is src_guid
define view ZTV_SC_ELIMINADOS as 
select from zsrmtb0010 as eli 
inner join crmd_orderadm_h as rfx_header on rfx_header.client = eli.mandt 
and rfx_header.guid = eli.zzlic_guid_cab_rfx_act
inner join bbpc_proc_type_t as proct on proct.client = rfx_header.client and proct.process_type = rfx_header.process_type and proct.langu = 'P'
inner join crmd_orderadm_i as rfx on rfx.guid = eli.zzlic_guid_item_rfx_act 
inner join bbp_pdhgp as rfx_hgp on rfx_hgp.guid = eli.zzlic_guid_cab_rfx_act
inner join bbp_pdigp as rfx_igp on rfx_igp.guid = eli.zzlic_guid_item_rfx_act
--or and rfx_igp.guid = eli.zzlic_guid_item_rfx 
--and rfx.ordered_prod = eli.zzlic_produtoeliminado
--and rfx_igp.guid = eli.zzlic_guid_item_rfx 
inner join bbp_pdhsc as rfx_hsc on rfx_hsc.guid = rfx_header.guid
inner join bbp_pdisc as rfx_isc on rfx_isc.guid = rfx.guid
//inner join crmd_orderadm_i on crmd_orderadm_i.guid = eli.zzlic_guid_item_rfx_act
// or rfx_igp.guid = eli.zzlic_guid_item_rfx_act
//and crmd_orderadm_i.header = rfx_header.guid 
//and crmd_orderadm_i.ordered_prod = eli.zzlic_produtoeliminado and crmd_orderadm_i.number_int = eli.zzlic_itemcareliminado
           {
           
 
           key 'ELI' as origin,
           key rfx.product as rfx_item_guid, //null da erro na uniao
           key eli.zzlic_guid_cab_rfx_act as rfx_guid, // //Guid da Solicitação
           //key rfx.header as rfx_guid,// //Guid da Solicitação
           //key rfx_igp.guid as rep_item_guid,//Guid do Item da RFQ - Solicitação
           key eli.zzlic_guid_item_rfx_act as rep_item_guid,//Guid do Item da RFQ - Solicitação
           key rfx.header as rep_guid ,//Guid da Solicitação
           key
           case
             when rfx_hsc.zzlic_datahomolagacao = '00000000' then substring(rfx_header.posting_date,1,4)
             when rfx_hsc.zzlic_datahomolagacao is null then substring(rfx_header.posting_date,1,4)
             when rfx_hsc.zzlic_datahomolagacao = '' then substring(rfx_header.posting_date,1,4)
              else substring(rfx_hsc.zzlic_datahomolagacao,1,4) end
             as homol_year,
           key
           case
             when rfx_hsc.zzlic_datahomolagacao = '00000000' then substring(rfx_header.posting_date,1,6)
             when rfx_hsc.zzlic_datahomolagacao is null then substring(rfx_header.posting_date,1,6)
             when rfx_hsc.zzlic_datahomolagacao = '' then substring(rfx_header.posting_date,1,6)
              else substring(rfx_hsc.zzlic_datahomolagacao,1,6) end
             as homol_period,
           'X' as FLAG_ELIMIN,  
           '' as rfx_objid,
           concat(rfx_header.object_id,rfx.number_int) as CONCAT_REP_OBJ,
           concat(rfx_header.object_id,'6999999999') as CONCAT_RFX_OBJ,
           '' as rfx_type,
           rfx_header.object_id as rep_objid,
           rfx_header.object_type as rep_type,

           '6999999999' as rfx_no_int,
           rfx.number_int as rep_no_int,
           rfx_isc.zzlic_exlin as rep_exlin,
           //rfx_igp.exlin as rep_exlin, //q_exlin ?
           rfx_igp.exlin as rfx_exlin, //useless
           rfx_igp.grouping_level as rep_grouping_level,
 
 rfx_igp.grouping_level as rfx_grouping_level, 
 //rfx_grouping_handling will be used for-i/o deduct_in to track itens rejeitado no lance
 case 
 when rfx_igp.deduct_ind is null then 'A'
 when rfx_igp.deduct_ind = '' then 'A'
 when rfx_igp.deduct_ind = ' ' then 'A'
 else 'R' 
 end as rfx_grouping_handling, //used for item do lance aceito
 case substring( rfx_igp.exlin , 5, 1) when '.' then 'H'
 else 'N'
 end
 as rep_grouping_handling,
 case substring( rfx_isc.zzlic_exlin , 5, 1) 
 when '.' then substring( rfx_isc.zzlic_exlin , 1, 4)
 else ''
 end as rep_lote,

 case substring( rfx_isc.zzlic_exlin , 5, 1) 
 when '.' then substring( rfx_isc.zzlic_exlin , 6, 4) 
 else substring( rfx_isc.zzlic_exlin , 1, 4)
 end as rep_sqn_lote,
 
 rfx_header.description,
 rfx_hsc.zz_descge,
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
when rfx_hsc.zzlic_datahomolagacao is null then rfx_header.posting_date
when rfx_hsc.zzlic_datahomolagacao = '' then rfx_header.posting_date
else rfx_hsc.zzlic_datahomolagacao end
as data_homologacao,

case when rfx_hsc.zzlic_etapa_processo_wf  = '3'
 then 'X'
  else ''
end as flag_homo,
rfx_hsc.zzlic_logo as shc_logo_agrupado,
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
rfx_igp.del_ind,
rfx_hgp.version_type,
rfx_hgp.doc_closed,
rfx_hsc.zzlic_user_status as status_u,
rfx_igp.unit as rep_unit,
rfx_igp.quantity as rep_quantity,
eli.zzlic_quantideeliminado,
rfx_igp.price as rep_price,
rfx_igp.value as rep_value,

case 
when rfx_isc.zzlic_price = 0 then rfx_igp.price
else rfx_isc.zzlic_price
end as zzlic_price,

case 
when rfx_isc.zzlic_totalprice = 0 then rfx_igp.value
else rfx_isc.zzlic_totalprice
end as zzlic_totalprice,

rfx_igp.gross_price as rep_gross_price,
rfx_hsc.zzlic_totalestimado,
0.000 as rfx_total_value, --ie. QUOT total Value
rfx_hgp.total_value as rep_total_value,  --ie. RFQ total Value    

rfx_igp.unit as rfx_unit,
0 as rfx_quantity,
rfx_igp.price as rfx_price,
0.000 as rfx_value,
rfx_igp.gross_price as rfx_gross_price,    
1 as counter
}
where rfx_igp.grouping_level <> 'L'
//rfx_header.object_id = '3000004002';