@AbapCatalog.sqlViewName: 'ZBIDOMTXT_ZZ'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Textos dos Dominios ZZ'
define view ZTV_DOMTXT_ZFIELDS as select distinct from dd07t as dot
inner join tadir as tad 
on tad.obj_name = dot.domname
and dot.ddlanguage = tad.masterlang
{
key valpos,
key domname,

ddtext
  
}
where ddlanguage = 'P'
and ( tad.devclass = 'ZBI_RELOP_SRM'
or tad.devclass = 'ZBW_CONTENT'
or tad.devclass = 'ZSIG_BW'
or tad.devclass = 'ZSIG_GW'
or tad.devclass = 'ZSIG_SRM'
or tad.devclass = 'ZSRM')
