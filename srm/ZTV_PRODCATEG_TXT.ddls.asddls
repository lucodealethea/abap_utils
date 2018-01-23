@AbapCatalog.sqlViewName: 'ZBIPROD_CATEGT'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Textos de categoria do produto'
@ClientDependent: false
define view ZTV_PRODCATEG_TXT as select from comm_prprdcatr as pc
left outer join comm_category as cat
on pc.client  =      cat.client
and pc.category_guid = cat.category_guid
left outer join comm_applcatgrpr as app on app.client  =  cat.client
and app.hierarchy   =   cat.hierarchy_guid
and app.application = '02'
left outer join comm_product as pro on pc.client = pro.client
and pc.product_guid = pro.product_guid
left outer join comm_hierarchy as ph on ph.client = pc.client
and ph.hierarchy_guid = pc.hierarchy_guid
left outer join comm_prshtext as prot on pro.client = prot.client
and prot.product_guid = pro.product_guid
and prot.langu = 'P'
left outer join comm_categoryt as pct on pct.client = cat.client
and pct.category_guid = cat.category_guid
and pct.langu = 'P'
left outer join zsrmt0133 as ZS on ZS.categoria_id = pc.category_id
{
pc.client,
key pc.category_id,
key pro.product_guid,
key pro.product_id,
ZS.dcod_categ_id,
ZS.desc_categ_id,
pct.category_guid,
cat.parent_guid,
cat.hierarchy_guid,
ph.hierarchy_id,
pct.category_text,
case substring(pc.category_id,1,1)
when '0'
then 'SESISENAI' 
when '1'
then 'SESISENAI' 
when '2'
then 'SESISENAI' 
when '3'
then 'SESISENAI' 
when '4'
then 'SESISENAI' 
when '5'
then 'SESISENAI' 
when '6'
then 'SESISENAI' 
when '7'
then 'SESISENAI' 
when '8'
then 'SESISENAI' 
when '9'
then 'SESISENAI' 
else
'OTHER'
end 
as categ,
prot.short_text,
prot.shtext_large

}
