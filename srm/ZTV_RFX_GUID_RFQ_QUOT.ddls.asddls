@AbapCatalog.sqlViewName: 'ZBI_GUIDSRFQT'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Get the Guids out of Join between RFQ and QUOT'
@ClientDependent: true
// RFX is QUOTATION and REP is RFQ
define view ZTV_RFX_GUID_RFQ_QUOT as 
select from crmd_orderadm_h as rfx_header
left outer join crmd_orderadm_i as rfx on rfx.header = rfx_header.guid
and rfx_header.object_type = 'BUS2202' 
inner join crm_jest as jest on rfx_header.guid = jest.objnr and jest.stat = 'I1014'
left outer join bbp_pdhgp as rfx_hgp on rfx_header.guid = rfx_hgp.guid
left outer join bbp_pdigp as rfx_igp on rfx_igp.guid = rfx.guid
left outer join crmd_orderadm_i as rep on rep.guid  = rfx_igp.src_guid  --//src_guid
left outer join crmd_orderadm_h as rep_header on rep_header.guid = rep.header and rep_header.object_type = 'BUS2200'
left outer join bbpc_proc_type_t as proct on proct.client = rep_header.client and proct.process_type = rep_header.process_type and proct.langu = 'P'
left outer join bbp_pdhsc as rep_hsc on rep_hsc.guid = rep_header.guid
left outer join bbp_pdisc as rep_isc on rep_isc.guid = rep.guid
left outer join bbp_pdhgp as rep_hgp on rep_hgp.guid = rep_header.guid 
left outer join bbp_pdigp as rep_igp on rep_igp.guid = rep.guid
left outer join zsrmtb0001 as categ on categ.category_id = rep_igp.category_id 
left outer join crmd_orderadm_i on crmd_orderadm_i.guid = rep_igp.guid and crmd_orderadm_i.header = rep_header.guid 
    
// todos valores são do Lance - Quotation and RFQ mais RFQ Valor Total rfx_total_value/.zzlic_totalestimado, QUOT rep_total_value,  
    {
           key 'QUT' as origin,
           key rfx_igp.guid as rfx_item_guid,//Guid do Item do Lance - Cotação 
           key rfx.header as rfx_guid,// Guid do Lance - Quotation
           key rep_igp.guid as rep_item_guid,//Guid do Item da RFQ - Solicitação
           key rep.header as rep_guid ,//Guid da Solicitação
           key
           case
             when rep_hsc.zzlic_datahomolagacao = '00000000' then substring(rfx_header.posting_date,1,4)
             when rep_hsc.zzlic_datahomolagacao is null then substring(rfx_header.posting_date,1,4)
             when rep_hsc.zzlic_datahomolagacao = '' then substring(rfx_header.posting_date,1,4)
              else substring(rep_hsc.zzlic_datahomolagacao,1,4) end
             as homol_year,
           key
           case
             when rep_hsc.zzlic_datahomolagacao = '00000000' then substring(rfx_header.posting_date,1,6)
             when rep_hsc.zzlic_datahomolagacao is null then substring(rfx_header.posting_date,1,6)
             when rep_hsc.zzlic_datahomolagacao = '' then substring(rfx_header.posting_date,1,6)
              else substring(rep_hsc.zzlic_datahomolagacao,1,6) end
             as homol_period,

           rfx_header.object_id as rfx_objid,
           rfx_header.object_type as rfx_type,
           rep_header.object_id as rep_objid,
           rep_header.object_type as rep_type,
           case categ.servico
           when '' then rfx.number_int
           else '0000000001'
           end as rfx_no_int,
           rep.number_int as rep_no_int,
           rep_igp.exlin as rep_exlin, //q_exlin ?
           rfx_igp.exlin as rfx_exlin, //useless
 rfx_igp.grouping_level as rfx_grouping_level,
 rep_igp.grouping_level as rep_grouping_level,
 case 
 when rfx_igp.deduct_ind is null then 'A'
 when rfx_igp.deduct_ind = '' then 'A'
 when rfx_igp.deduct_ind = ' ' then 'A'
 else 'R' 
 end as rfx_grouping_handling, //used for item do lance aceito
 case substring( rep_igp.exlin , 5, 1) when '.' then 'H'
 else 'N'
 end
 as rep_grouping_handling,
 
 case substring( rep_igp.exlin , 5, 1) 
 when '.' then substring( rep_igp.exlin , 1, 4)
 else ''
 end as rep_lote,

 case substring( rep_igp.exlin , 5, 1) 
 when '.' then substring( rep_igp.exlin , 6, 4) 
 else substring( rep_igp.exlin , 1, 4)
 end as rep_sqn_lote,
 
 //substring( rep_igp.exlin , 1, 4) as rep_lote,
 //substring( rep_igp.exlin , 6, 4) as rep_sqn_lote,
 
 rep_header.description,
 rep_header.process_type, 
 rep_header.posting_date,
 rep_hsc.zz_descge,
case rfx_header.process_type 
when 'ZINX'
then 
case 
when rep_hsc.zz_desccgu = '' then 'Inexigibilidade'
else rep_hsc.zz_desccgu
end
when 'ZDDS'
then 
case 
 when rep_hsc.zz_desccgu = '' then 'Demais Situações'
else rep_hsc.zz_desccgu
end
else proct.p_description_20 end as zz_desccgu,

case
when rep_hsc.zzlic_datahomolagacao = '00000000' then rfx_header.posting_date
when rep_hsc.zzlic_datahomolagacao is null then rfx_header.posting_date
when rep_hsc.zzlic_datahomolagacao = '' then rfx_header.posting_date
else rep_hsc.zzlic_datahomolagacao end
as data_homologacao,

case when rep_hsc.zzlic_etapa_processo_wf  = '3'
 then 'X'
  else ''
end as flag_homo,
rep_hsc.zzlic_logo as shc_logo_agrupado,
rep_hsc.zz_lic_compart,
rep_hsc.zz_lic_natur_obj,
rep_hsc.zzlic_etapa_processo_wf,
rep_hsc.zzlic_critjul,
rep_isc.zz_be_co_code as REP_CO_CODE,
rfx.description_uc,
rfx.ordered_prod as ordered_prod,
rfx.product as product,
rep_igp.category_id,
rep_igp.src_object_type,
rep_igp.del_ind,
rep_hgp.version_type,
rep_hgp.doc_closed,
rep_hsc.zzlic_user_status as status_u,

rep_igp.unit as rep_unit,
rep_igp.quantity as rep_quantity,
rep_igp.price as rep_price,
case 
when rep_hgp.doc_closed = 'X' then 0
else rep_igp.value 
end as rep_value,

case 
when rep_isc.zzlic_price = 0 then rep_igp.price
else rep_isc.zzlic_price
end as zzlic_price,

case 
when rep_hgp.doc_closed = 'X' then 0
else rep_isc.zzlic_totalprice
end as zzlic_totalprice,

rep_igp.gross_price as rep_gross_price,

case 
when rep_hgp.doc_closed = 'X' then 0
else rep_hsc.zzlic_totalestimado
end as zzlic_totalestimado,

case 
when rep_hgp.doc_closed = 'X' then 0
else rfx_hgp.total_value 
end as rfx_total_value, //ie. QUOT total Value

case 
when rep_hgp.doc_closed = 'X' then 0
else rep_hgp.total_value 
end as rep_total_value,  //ie. RFQ total Value    

rfx_igp.unit as rfx_unit,
rfx_igp.quantity as rfx_quantity,
rfx_igp.price as rfx_price,

case 
when rep_hgp.doc_closed = 'X' then 0
else rfx_igp.value 
end as rfx_value,

rfx_igp.gross_price as rfx_gross_price,      
    
1 as counter
}
