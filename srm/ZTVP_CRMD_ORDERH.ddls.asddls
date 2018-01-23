@AbapCatalog.sqlViewName: 'ZBI_SRM_ORDERH'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@ClientDependent: false
@EndUserText.label: 'Select with param on CRMD_ORDERADM_H'
define view ZTVP_CRMD_ORDERH
    with parameters 
    p_object_type:CRMT_SUBOBJECT_CATEGORY_DB, 
    p_objectid_fr:CRMT_OBJECT_ID_DB, 
    p_objectid_to:CRMT_OBJECT_ID_DB
as select from crmd_orderadm_h as hdr
inner join zsrmtb0029 as Txt
//on hdr.mandt = txt.mandt
on hdr.guid = Txt.guid
{
hdr.object_id,
hdr.object_type,
hdr.description,
hdr.process_type,
Txt.ztdline,
hdr.guid

}
where hdr.object_type = :p_object_type
and ( hdr.object_id >= :p_objectid_fr 
and hdr.object_id <= :p_objectid_to )
and Txt.tdid = 'ZOBJ'
and Txt.tdspras = 'P'

