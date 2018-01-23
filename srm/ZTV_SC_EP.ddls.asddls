@AbapCatalog.sqlViewName: 'ZBI_SC_EP'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Solicitação de Cotação - Detalhes  Empresa Participantes'
@ClientDependent: true
define view ZTV_SC_EP as select from crmd_orderadm_h as rfx_header 
left outer join crmd_orderadm_i as rfx on rfx_header.guid = rfx.header
left outer join crmd_link as link on  rfx_header.client = link.client  and  rfx_header.guid = link.guid_hi and ( link.objtype_hi = '05' or link.objtype_hi = '06') and link.objtype_set = '07'
left outer join bbpc_proc_type_t as proc on  rfx_header.client = proc.client and  rfx_header.process_type = proc.process_type and proc.langu = 'P'
left outer join  zbi_butcrm as rfx_partner on link.guid_set = rfx_partner.guid and link.client = rfx_partner.client  and (rfx_partner.partner_fct = '00000017' or  rfx_partner.partner_fct = '00000018')  
left outer join bbp_pdhgp as hgp on rfx_header.client = hgp.client and rfx_header.guid = hgp.guid and hgp.version_type <> 'H' and hgp.version_type <> 'C'
left outer join bbp_pdigp as rep_igp on rep_igp.src_guid = rfx.guid
left outer join bbp_pdhsc as hsc on rfx_header.client = hsc.client and rfx_header.guid = hsc.guid
left outer join bbpv_pd_org as org on org.client =  rfx_header.client and org.guid_hi =  rfx_header.guid
left outer join zbi_butcrmp as adrtax on adrtax.client = rfx_partner.client and adrtax.partner = rfx_partner.partner
//inner join crmd_orderadm_i as rep on rep_igp.guid = rep.guid  
//inner join crmd_orderadm_h as rep_header on rep_header.guid = rep.header 
//inner join crm_jest as jest on rep_header.guid = jest.objnr // and jest.stat = 'I1014'

  {
key  rfx_header.client,
key  rfx_header.guid,
key  rfx_header.object_id,
 rfx_header.process_type,
 rfx_header.created_at,
 rfx_header.created_by,
 rfx_header.changed_at,
 rfx_header.changed_by,
 rfx_header.head_changed_at,
//hsb.bid_type,
 rfx_header.description as rfx_description,
//hsb.quot_dead_time,
//hsb.start_time,
//hsb.comp_multi_bid,
//hsb.bi_version_guid,
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
where rfx_header.object_type = 'BUS2200'
;