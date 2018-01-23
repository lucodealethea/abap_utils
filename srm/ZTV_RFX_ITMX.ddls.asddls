@AbapCatalog.sqlViewName: 'ZBI_RFX_ITMX'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Get the RFQ with n-quotations and their qty details'
@ClientDependent: true

define view ZTV_RFX_ITMX
//with parameters p_date_from:dats, p_date_to:dats 
as select from crmd_orderadm_h as rfx_header
inner join bbpc_proc_type_t as proct on proct.client = rfx_header.client and proct.process_type = rfx_header.process_type and proct.langu = 'P'
inner join crmd_orderadm_i as rfx on rfx_header.guid = rfx.header
inner join bbp_pdhgp as rfx_hgp on rfx_header.guid = rfx_hgp.guid
inner join bbp_pdigp as rep_igp on rep_igp.src_guid = rfx.guid
inner join bbp_pdhsc as hsc on hsc.guid = rfx_header.guid
inner join bbp_pdisc as isc on rep_igp.src_guid = isc.guid                                                                                                 
inner join crmd_orderadm_i as rep on rep_igp.guid = rep.guid  
inner join crmd_orderadm_h as rep_header on rep_header.guid = rep.header 
inner join crm_jest as jest on rep_header.guid = jest.objnr and jest.stat = 'I1014'
inner join bbp_pdhgp as rep_hgp on  rep_header.guid = rep_hgp.guid
inner join bbp_pdigp as igp on rfx.guid = igp.src_guid 
inner join crmd_orderadm_i on crmd_orderadm_i.guid = igp.guid and crmd_orderadm_i.header = rep_header.guid
                                
           {
           
           key igp.guid as  q_igp_guid ,
           key rep_igp.guid as rep_igp_guid,
           key rep_igp.src_guid,
           key rfx.header as rfx_no ,
           rfx_header.description,
           rfx_header.process_type,
           rfx_header.posting_date,
          
           case rfx_header.process_type 
             when 'ZINX'
             then 
             case 
              when hsc.zz_desccgu = '' then 'Inexigibilidade'
             else hsc.zz_desccgu
             end
             when 'ZDDS'
             then 
             case 
              when hsc.zz_desccgu = '' then 'Demais Situações'
             else hsc.zz_desccgu
             end
           else proct.p_description_20 end as zz_desccgu,
           hsc.zzshc_logo as shc_logo_agrupado,
           rfx_hgp.version_type,
           hsc.zz_lic_natur_obj,
           hsc.zzlic_etapa_processo_wf,
           hsc.zzlic_critjul,
case
when hsc.zzlic_datahomolagacao = '00000000' then rfx_header.posting_date
else hsc.zzlic_datahomolagacao end
as data_homologacao,

case when hsc.zzlic_etapa_processo_wf  = '3'
 then 'X'
  else ''
end as flag_homo,

           hsc.zz_lic_compart,
          
           rfx_header.object_id as rfx_objid,
           rfx_header.object_type as rfx_type,
           key rep.header as rep_no,
           rep_header.object_id as rep_objid,
           rep_header.object_type as rep_type,
           key rfx.number_int as rfx_no_int,
           igp.grouping_level as zzlote_flag,
           isc.zzlote,
           rep.number_int  as rep_no_int,
           rfx.product,
           rfx.product_kind,
           rfx.ordered_prod as ordered_prod,
           igp.category_id,
           igp.src_object_type,
           igp.unit as q_unit,
           max(igp.quantity) as q_quantity, 
           max(igp.price) as q_price,
           max(igp.value) as q_value,
           max(igp.gross_price) as q_gross_price,
           max(rfx_hgp.total_value) as rfq_total_value,
           max(rep_hgp.total_value) as q_total_value,
           
           case rfx_hgp.co_code
           when '1000'
           then max(igp.quantity) 
            else 0
           end as sesi_q_quantity,
           case rfx_hgp.co_code
           when '2000'
           then max(igp.quantity) 
            else 0
           end as senai_q_quantity,
 
           case rfx_hgp.co_code
           when '1000'
           then max(igp.value) 
            else 0
           end as sesi_q_value,
           case rfx_hgp.co_code
           when '2000'
           then max(igp.value)
            else 0
           end as senai_q_value,
           1 as ctr
           
}
//where igp.del_ind <> 'X' and rep_igp.del_ind <> 'X' and ( not rep_hgp.doc_closed = 'X' or not rep_hgp.version_type = 'C' )
group by
igp.guid,
rep_igp.guid,
rep_igp.src_guid,
rfx.header,
rfx_header.description,
rfx_header.process_type,
rfx_header.posting_date,
proct.p_description_20,
hsc.zz_desccgu,
hsc.zzshc_logo,
rfx_hgp.version_type,
hsc.zz_lic_natur_obj,
hsc.zzlic_etapa_processo_wf,
hsc.zzlic_critjul,
hsc.zzlic_datahomolagacao,
hsc.zzlic_flaghomologacao,
hsc.zz_lic_compart,
rfx_header.object_id,
rfx_header.object_type,
rep.header,
rep_header.object_id,
rep_header.object_type,
rfx.number_int,
igp.grouping_level,
isc.zzlote,
rep.number_int,
rfx.product,
rfx.product_kind,
rfx.ordered_prod,
igp.category_id,
igp.src_object_type,
igp.unit,
rfx_hgp.co_code,
igp.quantity, 
igp.price,
igp.value,
igp.gross_price,
rfx_hgp.total_value
