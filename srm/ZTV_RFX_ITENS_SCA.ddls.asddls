@AbapCatalog.sqlViewName: 'ZBI_RFX_ITENSCA'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Inner Join Carinho SC com RFQ'
@ClientDependent: true
// rfx_objid is Shopping Cart rep_objid is RFQ
define view ZTV_RFX_ITENS_SCA as 
select from zbi_guidscrfq as rfx
inner join bbp_pdhgp as rfx_hgp on rfx_hgp.guid = rfx.rep_guid 
inner join bbp_pdigp as rfx_igp on rfx_igp.guid = rfx.rfx_item_guid
{
key rfx.flag_nosc as origin,
key rfx.rep_item_guid, //rfq_item_guid,
key rfx.rep_guid, //rfq_guid,
key rfx.rfx_item_guid,//sc_item_guid,
key rfx.rfx_guid, //sc_guid,
rfx.rfx_objid, //sc_objid,
rfx.rfx_type, //rfx_sc_type BUS2121
rfx.rep_objid, //rfq_objid
rfx.rep_type,//rep_rfq_type BUS2200
rfx.rfx_no_int,//sc_no_int,
rfx.rep_no_int,//rfq_no_int,
rfx_igp.exlin as rfx_exlin, // but shopping cart does not have lote handling
rfx.rep_exlin,//rfq_exlin,

case substring( rfx_igp.exlin , 5, 1) when '.' then 'H'
 else 'N'
 end
 as rfx_grouping_handling,
rfx.grouping_handling as rep_grouping_handling,

 substring( rfx_igp.exlin , 1, 4) as rfx_lote,
 substring( rfx_igp.exlin , 6, 4) as rfx_sqn_lote,
rfx.lote as rep_lote,
rfx.sqn_lote as rep_sqn_lote,

rfx.description,
rfx.process_type,
rfx.posting_date,
rfx.zz_desccgu,
rfx.data_homologacao,
rfx.flag_homo,
rfx.shc_logo_agrupado,
rfx.zz_lic_compart,
rfx.zz_lic_natur_obj,
rfx.zzlic_etapa_processo_wf,
rfx.zzlic_critjul,
rfx.rep_co_code,
rfx.description_uc,
rfx.ordered_prod,
rfx.product,
rfx.category_id,
rfx.src_object_type,
rfx.version_type,
rfx.doc_closed,
rfx.rep_unit,
rfx.rep_quantity,
rfx.rep_price,
rfx.rep_value,
rfx.zzlic_price,
rfx.zzlic_totalprice,
rfx.rep_gross_price,
rfx.zzlic_totalestimado,
rfx.rfx_total_value,
rfx.rep_total_value,
rfx_igp.unit as rfx_unit,
rfx_igp.quantity as rfx_quantity,
rfx_igp.price as rfx_price,
rfx_igp.value as rfx_value,
rfx_igp.gross_price as rfx_gross_price,
1 as counter
}

where rfx_hgp.version_type <> 'H' and rfx_hgp.version_type <> 'C' and rfx_hgp.doc_closed <> 'X' and rfx_igp.del_ind <> 'X';