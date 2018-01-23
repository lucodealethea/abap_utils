@AbapCatalog.sqlViewName: 'ZBI_PROTYPET'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@ClientDependent: true
@EndUserText.label: 'Projection on Process Types'
define view ZTV_PROCTYP_CT as select from bbpc_proc_type as PR
inner join bbpc_proc_type_t as TX
    on PR.client = TX.client
    and PR.process_type = TX.process_type {
    
    PR.client,
PR.process_type,
PR.process_blocked,
PR.number_range_int,
PR.number_range_ext,
PR.user_stat_proc,
PR.object_type,
PR.po_ind,
PR.ctr_ind,
PR.subtype,
PR.bup_schema_id,
PR.text_scheme_id,
PR.event_schema_id,
PR.sig_conf_opt,
TX.langu,
TX.p_description_20,
TX.p_description
    
}