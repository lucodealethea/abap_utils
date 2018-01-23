@AbapCatalog.sqlViewName: 'ZBI_CRMJEST'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Inactive DDLS (missing data foundation) to abapgit'
@ClientDependent: false
define view ZTV_CRM_JEST
as select from crmd_orderadm_h as rfx_header
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
 