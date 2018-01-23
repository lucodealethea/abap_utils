@AbapCatalog.sqlViewName: 'ZBI_DISTUNIDG'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'ZTV_DIST_UNIDADES_G'
define view ZTV_DIST_UNIDADES_G as select from zbi_distunid 
{
key client, rep_guid, rep_objid, ctr,
case 
when ctr >= 10 then 'V' 
when ctr < 10 then 'I'
else ''
end as FLAG_DIV   
}