CREATE FUNCTION "_SYS_BIC"."LEILAO_LIC_COT::TABLE_FUNCTION_CAV_PROC_ORGS" ("TIPO" VARCHAR(13))
RETURNS TABLE ("MANDT" VARCHAR (3), "OBJID" NVARCHAR (14), "PROC_ORG_RESP" NVARCHAR (14), "PROC_ORG" NVARCHAR (14), "PROC_GROUP" NVARCHAR (14), "DEL_IND" NVARCHAR (1), "TIPO" VARCHAR (13), "SHORT" NVARCHAR (12), "STEXT" NVARCHAR (40), "CTR" INTEGER)
LANGUAGE SQLSCRIPT
SQL SECURITY DEFINER
  AS 

 
 /********* Begin Procedure Script ************/ 
 BEGIN 
 	 var_out = 
 	 select distinct
 	 hr.mandt,
 REPLACE(CONCAT( CONCAT( hr.otype, '|-| |-|'),hr.objid),'|-|', '')as objid,
 --   substring(org.proc_org_resp,3,8) as PROC_ORG_RESP,
 --   substring(org.proc_org,3,8) as PROC_ORG,
 --   substring(org.proc_group,3,8) as PROC_GROUP,
 --itm.header as header,
 --itm.guid as igp_guid,
 --org.set_guid,
 org.proc_org_resp,
 org.proc_org,
 org.proc_group,
 org.del_ind,

 'PROC_GROUP' as tipo,

 hr.short,
 hr.stext,
1 as ctr 
from sapabap1.crmd_orderadm_h as hdr
inner join sapabap1.crmd_orderadm_i as itm on hdr.guid = itm.header
inner join sapabap1.bbp_pdigp as igp on itm.guid = igp.guid
inner join sapabap1.bbp_pdhgp as hgp on hdr.guid = hgp.guid
left outer join sapabap1.crmd_link as link on  (hdr.guid = link.guid_hi and link.objtype_hi ='05' and link.objtype_set =  '21')
left outer join sapabap1.bbp_pdorg as org on  link.guid_set = org.set_guid
inner join sapabap1.hrp1000 as hr on substring(org.proc_group,3,8) = hr.objid
 where hr.plvar = '01'
and hr.langu = 'P'
and hr.endda = '99991231'
and hr.mandt = '300'
union
 select distinct
 hr.mandt,
 REPLACE(CONCAT( CONCAT( hr.otype, '|-| |-|'),hr.objid),'|-|', '')as objid,

 --   substring(org.proc_org_resp,3,8) as PROC_ORG_RESP,
 --   substring(org.proc_org,3,8) as PROC_ORG,
 --   substring(org.proc_group,3,8) as PROC_GROUP,
 --itm.header as header,
 --itm.guid as igp_guid,
 --org.set_guid,
 org.proc_org_resp,
 org.proc_org,
 org.proc_group,
 org.del_ind,

 'PROC_ORG' as tipo,
 hr.short,
 hr.stext,
 1 as ctr 
from sapabap1.crmd_orderadm_h as hdr
inner join sapabap1.crmd_orderadm_i as itm on hdr.guid = itm.header
inner join sapabap1.bbp_pdigp as igp on itm.guid = igp.guid
inner join sapabap1.bbp_pdhgp as hgp on hdr.guid = hgp.guid
left outer join sapabap1.crmd_link as link on  (hdr.guid = link.guid_hi and link.objtype_hi ='05' and link.objtype_set =  '21')
left outer join sapabap1.bbp_pdorg as org on  link.guid_set = org.set_guid
inner join sapabap1.hrp1000 as hr on substring(org.proc_org,3,8) = hr.objid
 where hr.plvar = '01'
and hr.langu = 'P'
and hr.endda = '99991231'
and hr.mandt = '300'
union
 select distinct
 hr.mandt,
 REPLACE(CONCAT( CONCAT( hr.otype, '|-| |-|'),hr.objid),'|-|', '')as objid,

 --   substring(org.proc_org_resp,3,8) as PROC_ORG_RESP,
 --   substring(org.proc_org,3,8) as PROC_ORG,
 --   substring(org.proc_group,3,8) as PROC_GROUP,
 --itm.header as header,
 --itm.guid as igp_guid,
 --org.set_guid,
 org.proc_org_resp,
 org.proc_org,
 org.proc_group,
 org.del_ind,
 'PROC_ORG_RESP' as tipo,
 hr.short,
 hr.stext, 
 1 as ctr
from sapabap1.crmd_orderadm_h as hdr
inner join sapabap1.crmd_orderadm_i as itm on hdr.guid = itm.header
inner join sapabap1.bbp_pdigp as igp on itm.guid = igp.guid
inner join sapabap1.bbp_pdhgp as hgp on hdr.guid = hgp.guid
left outer join sapabap1.crmd_link as link on  (hdr.guid = link.guid_hi and link.objtype_hi ='05' and link.objtype_set =  '21')
left outer join sapabap1.bbp_pdorg as org on  link.guid_set = org.set_guid
inner join sapabap1.hrp1000 as hr on substring(org.proc_org_resp,3,8) = hr.objid
 where hr.plvar = '01'
and hr.langu = 'P'
and hr.mandt = '300'
and hr.endda = '99991231'; 


return :var_out;
END;