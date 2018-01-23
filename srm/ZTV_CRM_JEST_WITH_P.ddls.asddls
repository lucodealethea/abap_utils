@AbapCatalog.sqlViewName: 'ZBI_CRMJESTP'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Statuses'
@ClientDependent: false
define view ZTV_CRM_JEST_WITH_P
with parameters  
in_object_type_l:CRMT_SUBOBJECT_CATEGORY_DB,
in_objectid_fr:CRMT_OBJECT_ID_DB,
in_objectid_to:CRMT_OBJECT_ID_DB,
p_status:CRM_J_STATUS
as select from ZTVP_CRMD_ORDERH
(p_object_type :  $parameters.in_object_type_l,
p_objectid_fr : $parameters.in_objectid_fr,
p_objectid_to : $parameters.in_objectid_to) as rfx_header
inner join crm_jest as jestfx on rfx_header.guid = jestfx.objnr
inner join tj02t as txs on txs.istat = jestfx.stat
//inner join tj30t as txu on txu.estat = jestfx.stat
//and txu.mandt = jestfx.mandt)  
{

key rfx_header.object_id,
key jestfx.stat,
rfx_header.object_type,
txs.txt04,
txs.txt30,
rfx_header.guid


//txu.txt04 as f_user_status
/*
,
case
SUBSTRING( jestfx.stat, 1, 1) 
when 'E' then 'U'
when 'I' then 'S'
else 'X'
end
as flag
    
}

and txu.spras = 'P'*/
}
where txs.spras = 'P'
and jestfx.inact <> 'X'
and jestfx.stat = :p_status