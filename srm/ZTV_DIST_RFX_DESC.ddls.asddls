@AbapCatalog.sqlViewName: 'ZBI_BIDRFXDESC'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Select Distinct Description - Edital'
define view ZTV_DIST_RFX_DESC as select distinct from crmd_orderadm_h as hdr
{
key hdr.client,    
key hdr.guid,
SUBSTRING( hdr.description, 1, 14 )as RFX_DESC,
hdr.description,
hdr.description_uc,
hdr.object_id
//INSTR( hdr.description, char(47)) as test,
//instr(replace(hdr.description, '0', 'a'), '/') as test2,
}
where hdr.description = hdr.description_uc
and hdr.description like '%/20%'
and object_type = 'BUS2200'
