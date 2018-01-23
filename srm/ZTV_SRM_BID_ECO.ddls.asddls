@AbapCatalog.sqlViewName: 'ZBI_SRM_BID_ECO'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Solicitação de Cotação - Empr Convidadas Pessoas de Contato'
@ClientDependent: true
define view ZTV_SRM_BID_ECO as select distinct from crmd_orderadm_h as rfx_header 
inner join bbpc_proc_type_t as proc on rfx_header.client = proc.client and rfx_header.process_type = proc.process_type 
and proc.langu = 'P' and rfx_header.object_type = 'BUS2200' 
inner join bbp_pdhgp as hgp on rfx_header.client = hgp.client and rfx_header.guid = hgp.guid
and hgp.version_type <> 'H' and hgp.version_type <> 'C'
inner join bbp_pdview_bup as bup on rfx_header.guid = bup.guid_hi
inner join bbp_pdhsc as hsc on rfx_header.client = hsc.client and rfx_header.guid = hsc.guid
inner join bbpv_pd_org as org on org.client = rfx_header.client and org.guid_hi = rfx_header.guid 
and bup.partner_fct =  '00000017'
inner join zbi_butcrm as but on but.partner_no = bup.partner_no
inner join but051 as cqum on cqum.partner2 = but.partner
inner join dfkkbptaxnum as df on but.client = df.client and cqum.partner1 = df.partner
inner join but000 as main on main.partner = cqum.partner1
 
    {
key rfx_header.client as mandt,
key rfx_header.guid,
key rfx_header.description as RFX_DESC,
key rfx_header.object_id,
'BBP_PD' as ZCHTDOBJT,
'ZOBJ' as ZCHTDID,
rfx_header.process_type,
rfx_header.changed_by,
'' as DOC_CLOSED,
rfx_header.posting_date as DATA_HOMOL, // zzlic_homologacao nao relevante neste contexto
case when hsc.zzlic_etapa_processo_wf  = '3'
 then 'X'
  else ''
end as flag_homo,
key cqum.partner1 as partner,
key cqum.partner2 as partner2,
proc.p_description_20 as PROC_TYPE_DESC,
org.proc_group,
org.proc_org,
org.proc_org_resp,
REPLACE(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT( CONCAT( main.name_org1, '|-| |-|'), main.name_org2), '|-| |-|'), main.name_org3), '|-| |-|'),main.name_org4), '|-| |-|'),'|-|', '') as MC_NAME1,
//was substring(main.name_org1,1,35) as MC_NAME1,
//main.name_org2 as ct_name2,
but.mc_name1 as CT_NAME1,
but.mc_name2 as CT_NAME2,
cqum.tel_number,
cqum.smtp_address,
df.taxtype,
df.taxnum,
1 as SQNR
//,
//rfx_header.created_at,
//rfx_header.created_by,
//rfx_header.changed_at,
//rfx_header.head_changed_at,
//proc.p_description_20 as proc_type_desc,
//but.partner_no as partner_no,
//but.partner_fct,
//but.partner_guid,
//but.addr_nr,
//but.addr_np,
//but.addr_type,
//rfx_header.addr_origin,
//rfx_header.disabled,
//adr.addrnumber,
//adrtax.tel_extens,
//adr.mc_name1,
   
}
where df.taxtype = 'BR1' or df.taxtype = 'BR2'