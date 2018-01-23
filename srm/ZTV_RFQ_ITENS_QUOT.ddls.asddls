@AbapCatalog.sqlViewName: 'ZBI_RFQ_ITENSQUT'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Get RFQ with n-quotations and their RFQ associated details'
@ClientDependent: true
// RFX is QUOTATION and REP is RFQ
define view ZTV_RFQ_ITENS_QUOT 
//with parameters p_date_from:dats, p_date_to:dats 
as 
select from zbi_guidsrfqt as rfq
{
key rfq.mandt,
key rfq.origin,
key rfq.rfx_item_guid,
key rfq.rfx_guid,
key rfq.rep_item_guid,
key rfq.rep_guid,
key rfq.homol_year,
key rfq.homol_period,
rfq.rfx_objid,
rfq.rfx_type,
rfq.rep_objid,
rfq.rep_type,
rfq.rfx_no_int,
rfq.rep_no_int,
case 
when rfq.rep_exlin is null then substring(rfq.rep_no_int,7,4)
when rfq.rep_exlin = '' then substring(rfq.rep_no_int,7,4)
else rfq.rfx_exlin end as rep_exlin,
rfq.rfx_exlin,
rfq.rep_grouping_level,
rfq.rfx_grouping_level,
rfq.rfx_grouping_handling,// used for Flag iTem Aceito A ou Nao : R 
rfq.rep_grouping_handling,
rfq.rep_lote,
rfq.rep_sqn_lote,
rfq.description,
rfq.zz_descge,
rfq.process_type,
rfq.posting_date,
rfq.zz_desccgu,
rfq.data_homologacao,
rfq.flag_homo,
rfq.shc_logo_agrupado,
rfq.zz_lic_compart,
rfq.zz_lic_natur_obj,
rfq.zzlic_etapa_processo_wf,
rfq.zzlic_critjul,
rfq.rep_co_code,
rfq.description_uc,
rfq.ordered_prod,
rfq.product,
rfq.category_id,
rfq.src_object_type,
rfq.del_ind,
rfq.version_type,
rfq.doc_closed,
rfq.status_u,
rfq.rep_unit,
rfq.rep_quantity,
rfq.rep_price,
rfq.rep_value,
rfq.zzlic_price,
rfq.zzlic_totalprice,
rfq.rep_gross_price,
rfq.zzlic_totalestimado,
rfq.rfx_total_value,
rfq.rep_total_value,
rfq.rfx_unit,
rfq.rfx_quantity,
rfq.rfx_price,
rfq.rfx_value,
rfq.rfx_gross_price,
rfq.counter
}
 where rfq.version_type <> 'H' and rfq.version_type <> 'C' 
 //and rfq.doc_closed <> 'X' 
 and rfq.del_ind <> 'X'
 and rfq.rep_grouping_level <> 'L';
