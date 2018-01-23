@AbapCatalog.sqlViewName: 'ZBI_SC_EC'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Solicitação de Cotação - Detalhes Parceiro'
@ClientDependent: true
// criado visão se11 zbi_butcrm (but000 inner crmd_partner guid = partner_no) 
//e DDLS ZTV_BUT_CRMD_PARTNER_17_18 > visão ABAP CDS zbi_butcrmp ( zbi_butcrm as B inner join but051 as C )
define view ZTV_SC_EC 
//with parameters p_object_id:CRMT_OBJECT_ID_DB
as select from
(( crmd_orderadm_h as h inner join bbp_pdhsb as hsb 
on h.guid = hsb.guid and h.client = hsb.client and  h.object_type = 'BUS2200' 
// :p_object_id
//and ( h.object_id = :p_object_id)
//taken out 24/10 left outer 
inner join crmd_link as link on h.client = link.client  and h.guid = link.guid_hi 
and link.objtype_hi = '05' and link.objtype_set = '07'
inner join bbpc_proc_type_t as proc on h.client = proc.client and h.process_type = proc.process_type and proc.langu = 'P')
inner join  zbi_butcrm as rfx_partner on link.guid_set = rfx_partner.guid and link.client = rfx_partner.client  
and (
rfx_partner.partner_fct = '00000017'  
//  or rfx_partner.partner_fct = '00000018'
)  
inner join bbp_pdhgp as hgp on hsb.client = hgp.client and hsb.guid = hgp.guid 
and hgp.version_type <> 'H' and hgp.version_type <> 'C'
inner join bbp_pdhsc as hsc on hsb.client = hsc.client and hsb.guid = hsc.guid
inner join bbpv_pd_org as org on org.client = h.client and org.guid_hi = h.guid
inner join zbi_butcrmp as adrtax on adrtax.client = rfx_partner.client and adrtax.partner = rfx_partner.partner)

  {
key h.client,
key h.guid,
key h.object_id,
h.process_type,
h.created_at,
h.created_by,
h.changed_at,
h.changed_by,
h.head_changed_at,
hsb.bid_type,
h.description as rfx_description,
hsb.quot_dead_time,
hsb.start_time,
hsb.comp_multi_bid,
hsb.bi_version_guid,
hgp.doc_closed,
hgp.tzone,
hgp.version_type,
hgp.version_no,
hgp.ext_version_no as bi_version_no,
hsc.zzlic_datahomolagacao as data_homologacao,
case when hsc.zzlic_datahomolagacao = '00000000'
  then ''
  else 'X'
end as flag_homo,
rfx_partner.partner,
adrtax.partner2,
proc.p_description_20 as proc_type_desc,
rfx_partner.partner_no as partner_no,
rfx_partner.partner_fct,
rfx_partner.partner_guid,
//rfx_partner.kind_of_entry,
//rfx_partner.display_type,
//rfx_partner.no_type,
//rfx_partner.mainpartner,
//rfx_partner.relation_partner,
key rfx_partner.addr_nr,
key rfx_partner.addr_np,
key rfx_partner.addr_type,
//rfx_partner.addr_origin,
//rfx_partner.disabled,
org.proc_group,
org.proc_org,
org.proc_org_resp,
//adr.addrnumber,
rfx_partner.mc_name1,
//rfx_partner.mc_name2,
adrtax.tel_number,
//adrtax.tel_extens,
//adr.mc_name1,
adrtax.smtp_address,
adrtax.taxtype,
adrtax.taxnum
//adrtax.text,
}
;
