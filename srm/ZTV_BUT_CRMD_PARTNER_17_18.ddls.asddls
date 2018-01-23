@AbapCatalog.sqlViewName: 'ZBI_BUTCRMP'
@AbapCatalog.compiler.CompareFilter: true
@AccessControl.authorizationCheck: #CHECK
@ClientDependent: true
@EndUserText.label: 'Distinct Values on BUT000-CRMD_PARTNER - FCT 17-18'
define view ZTV_BUT_CRMD_PARTNER_17_18 as select from 
(zbi_butcrm as B inner join but051 as C
on B.client = C.client
and B.partner = C.partner1 
and ( 
//B.partner_fct = '00000017' or 
B.partner_fct = '00000018'))
//left outer 
inner join dfkkbptaxnum as D 
on B.client = D.client and B.partner = D.partner
  {
D.client,
D.partner,
D.taxtype,
D.taxnum,
//T.text,
C.partner2,
C.smtp_address,
C.tel_number,
//C.xdfrel, não existe na 051 so na BUT050
B.partner_no,
B.type,
B.bpkind,
B.name_last,
B.name_first,
B.namemiddle,
B.name1_text,
B.persnumber,
B.mc_name1,
B.mc_name2,
B.name_org1,
B.name_org2,
B.name_org3,
B.name_org4,
B.chusr,
B.addrcomm,
B.partner_guid,
B.partner_fct,
1 as counter
}
group by D.client,
D.partner,
D.taxtype,
D.taxnum,
C.partner2,
C.smtp_address,
C.tel_number,
B.partner_no,
B.type,
B.bpkind,
B.name_last,
B.name_first,
B.namemiddle,
B.name1_text,
B.persnumber,
B.mc_name1,
B.mc_name2,
B.name_org1,
B.name_org2,
B.name_org3,
B.name_org4,
B.chusr,
B.addrcomm,
B.partner_guid,
B.partner_fct;