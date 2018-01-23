@AbapCatalog.sqlViewName: 'ZBIDOBJIDDESC'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Select Distinct Description - Edital by OBJECT_ID'
define view ZTV_DIST_RFX_DESC_BY_OBJECT_ID as select distinct from crmd_orderadm_h as hdr
{
key hdr.client,    
key hdr.object_id,
SUBSTRING( hdr.description, 1, 14 )as RFX_DESC,
hdr.guid
//INSTR( hdr.description, char(47)) as test,
//instr(replace(hdr.description, '0', 'a'), '/') as test2,
}
where hdr.description = hdr.description_uc
and hdr.description like '%/20%'
and object_type = 'BUS2200'
--group by hdr.client, hdr.object_id, hdr.description, hdr.guid