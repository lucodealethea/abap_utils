@AbapCatalog.sqlViewName: 'ZBIRFXRFQ_SC_AGR'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Itens do Carinho de Compras Agrupados por SC - base rateio'
@ClientDependent: true
define view ZTV_RFX_RFQ_SC_AGR as select distinct 

from zbi_rfx_un as rfx
inner join zbi_sc_agrup as ag
//left outer join zbi_sc_agrup as ag
on rfx.rfx_guid = ag.hdr_agrupador
and rfx.rfx_item_guid = ag.item_agrupador
and rfx.ordered_prod = ag.ordered_prod_agrupado
{
key rfx.rep_objid as rep_objid,
key ag.object_id_agrupador as object_id_agrupador,
key ag.object_id_agrupado as object_id_agrupado,
key rfx.rep_no_int as rep_no_int,
key rfx.rep_guid as rep_no,
key rfx.rfx_guid, // added 10/10
key rfx.rep_item_guid,
rfx.rep_type,
rfx.rfx_type,
rfx.rfx_objid,
ag.item_agrupador as item_agrupador,
ag.hdr_agrupador as hdr_agrupador,
ag.hdr_agrupado as hdr_agrupado,
ag.item_agrupado as item_agrupado,
ag.number_int,
ag.guid,
rfx.rep_lote,
rfx.rep_grouping_handling,
rfx.rep_co_code,
ag.shc_logo_agrupado as shc_logo_agrupado,
rfx.version_type,
rfx.description,
rfx.posting_date,
//commented out as this brings from shopping cart document...
//rfx.zz_desccgu,
//rfx.zz_lic_natur_obj,
//rfx.zzlic_etapa_processo_wf,
//rfx.zzlic_critjul,
//rfx.zz_lic_compart,
//rfx.zzlic_datahomolagacao,
//rfx.zzlic_flaghomologacao,
//rfx.zz_tipo_aditivo,
// caso do left outer join

case 
when ag.object_id_agrupador is null
then
''
else
'X'
end as flag_grouping,
case 
when ag.object_id_agrupador is null
then
rfx.ordered_prod
else
ag.ordered_prod_agrupado
end as ordered_product,
rfx.product,
rfx.category_id,

max(ag.ctr) as ag_ctr,
max(ag.quantity) as quantity,
// o join traz tanto registro do agrupador que tem agrupados na ZSRMT_AGRUPA_SC 
//max(rfx.sc_price) as sc_price,
//max(rfx.sc_quantity) as sc_quantity,
//max(rfx.sc_total_value) as sc_ttl_value,
max(rfx.counter) as ctr, //para obter a quantidade do agrupador sc_quantity / ctr

case ag.co_code_agrupado
when '1000'
then
max(ag.quantity)
else
0
end as sesi_quantity,

case ag.co_code_agrupado
when '1000'
then
max(ag.value)
else
0
end as sesi_value,

case ag.co_code_agrupado
when '2000'
then
max(ag.quantity)
else
0
end as senai_quantity,

case ag.co_code_agrupado
when '2000'
then
max(ag.value)
else
0
end as senai_value
}
where rfx.rep_type = 'BUS2200' 

group by
rfx.rep_objid,
ag.object_id_agrupador,
ag.object_id_agrupado,
rfx.rep_no_int,
rfx.rep_guid,
rfx.rfx_guid, // added 10/10
rfx.rep_item_guid,
rfx.rep_type,
rfx.rfx_type,
rfx.rfx_objid,
ag.item_agrupador,
ag.hdr_agrupador,
ag.hdr_agrupado,
ag.item_agrupado,
ag.number_int,
ag.guid,
rfx.rep_lote,
rfx.rep_grouping_handling,
rfx.rep_co_code,
ag.shc_logo_agrupado,
rfx.version_type,
rfx.description,
rfx.posting_date,
ag.object_id_agrupador,
ag.ordered_prod_agrupado,
rfx.ordered_prod,
rfx.product,
rfx.category_id,
ag.co_code_agrupado
