@AbapCatalog.sqlViewName: 'ZBI_SC_AGRUP'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Itens dos Carinhos agrupados'
@ClientDependent: true
define view ZTV_SC_AGRUPAMENTOS as select from crmd_orderadm_h as rfx_header
left outer join crmd_orderadm_i as rfx on rfx_header.guid = rfx.header and rfx_header.object_type = 'BUS2121'
left outer join bbp_pdhgp     as hgp              on   rfx_header.guid = hgp.guid
left outer join bbp_pdigp     as igp               on  rfx.guid = igp.guid  
left outer join bbp_pdhsc     as hsc               on  rfx_header.guid = hsc.guid
left outer join bbp_pdbei     as pdbei               on  rfx.guid = pdbei.guid
left outer join bbp_pdisc     as isc               on  rfx.guid = isc.guid
left outer join zsrmt_agrupa_sc as ag on  rfx.header = ag.hdr_agrupado and rfx.guid = ag.item_agrupado and ag.cod_material = rfx.ordered_prod
inner join crmd_orderadm_h as h on h.guid = ag.hdr_agrupador 
inner join crmd_orderadm_i as i on i.guid = ag.item_agrupador //and i.ordered_prod = ag.cod_material
//left outer join bbp_pdhgp     as hhgp              on   h.guid = hhgp.guid  and h.object_type = 'BUS2121')
    {
key h.object_id as object_id_agrupador,    
key rfx_header.object_id as object_id_agrupado,
key rfx.ordered_prod as ordered_prod_agrupado,
key rfx.number_int,
key i.guid as guid, //sc agrupador item guid
key ag.hdr_agrupador as hdr_agrupador,
key ag.item_agrupador as item_agrupador,
key ag.hdr_agrupado as hdr_agrupado,
key igp.guid as item_agrupado,
pdbei.be_co_code as co_code_agrupado,
hsc.zzshc_logo as shc_logo_agrupado,
//ZZLIC_LOGO
igp.del_ind,
hgp.doc_closed,
hgp.version_type,
igp.unit,
max(igp.price) as price,
sum(igp.quantity) as quantity, //quantidade do agrupado
sum(igp.value) as value, //value do agrupado
count(*) as ctr
}
group by 
h.object_id,    
rfx_header.object_id,
rfx.ordered_prod,
rfx.number_int,
i.guid,
ag.hdr_agrupador,
ag.item_agrupador,
ag.hdr_agrupado,
igp.guid,
pdbei.be_co_code,
hsc.zzshc_logo,
igp.del_ind,
hgp.doc_closed,
hgp.version_type,
igp.unit

