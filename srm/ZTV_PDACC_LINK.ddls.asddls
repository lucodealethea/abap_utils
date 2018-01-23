@AbapCatalog.sqlViewName: 'ZBI_LKPDACC'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Linkage to BBP_PDACCC Account Determination via IGP'
define view ZTV_PDACC_LINK as select from crmd_orderadm_h as hdr 
inner join crmd_orderadm_i as itm on hdr.guid = itm.header
inner join bbp_pdigp as igp on itm.guid = igp.guid
inner join bbp_pdhgp as hgp on hdr.guid = hgp.guid
inner join crmd_link as link on (itm.guid = link.guid_hi and link.objtype_hi = '06' and link.objtype_set = '07' )
left outer join crmd_link  as igp_link_dep on igp.guid = igp_link_dep.guid_hi 
inner join bbp_pdacc as acc on (igp_link_dep.guid_set = acc.set_guid and igp_link_dep.objtype_hi = '06' and igp_link_dep.objtype_set = '31')
                                          
    {
    key igp_link_dep.guid_hi,
    acc.distr_perc,
    acc.acc_no,
    acc.acc_cat,
    acc.del_ind,
    acc.src_guid,
    acc.g_l_acct,
    acc.gl_acc_origin,
    acc.bus_area,
    acc.cost_ctr,
    acc.sd_doc,
    acc.sdoc_item,
    acc.sched_line,
    acc.asset_no,
    acc.sub_number,
    acc.order_no,
    acc.co_area,
    acc.prof_segm,
    acc.profit_ctr,
    acc.wbs_elem_e,
    acc.network,
    1 as acc_ctr
    
}
