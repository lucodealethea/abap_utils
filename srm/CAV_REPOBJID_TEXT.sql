BEGIN 
var_crmd_partner=
SELECT DISTINCT 
"LINK"."GUID_HI" as crm_order_guid,
"T1"."CLIENT" AS MANDT,
"T1"."PARTNER",
case when "ZUN"."NAME_1" is null then "T1"."MC_NAME1" else "ZUN"."NAME_1" end as mc_name1,
case when "ZUN"."NAME_2" is null then "T1"."MC_NAME2" else "ZUN"."NAME_2" end as mc_name2,
case when "ZUN".name_1 is null then '' else 'X' end as alterado,
1 AS COUNTER
FROM "SAPABAP1"."ZSRMTB0030" as ZUN 
RIGHT OUTER JOIN "SAPABAP1"."CRMD_PARTNER" as T2
on "ZUN"."MANDT" = "T2"."CLIENT" 
and "ZUN"."GUID" = "T2"."PARTNER_GUID"
INNER JOIN "SAPABAP1"."BUT000" as T1 
ON  "T1"."CLIENT" = "T2"."CLIENT" AND
"T1"."PARTNER_GUID" = "T2"."PARTNER_NO"
inner join "SAPABAP1"."CRMD_LINK" as link
on "T2"."GUID" = "LINK"."GUID_SET"
and ( "T2"."DISABLED" <> 'X' and  "T2"."PARTNER_FCT" = '00000775' or "T2"."PARTNER_FCT" = '00000075')
and ( "LINK"."OBJTYPE_HI" ='05' or "LINK"."OBJTYPE_HI" ='06' )
and "LINK"."OBJTYPE_SET" =  '07';

var_diversas =
SELECT "DISTUNID"."CLIENT", "DISTUNID"."REP_GUID", "DISTUNID"."REP_OBJID", 
case 
when "DISTUNID"."CTR" > 10 then 'V' 
when "DISTUNID"."CTR" <= 10 then 'I'
end as FLAG_DIV
FROM "SAPABAP1"."ZBI_DISTUNID" AS DISTUNID; 

var_dist_quot=
SELECT DISTINCT
"QT"."MANDT",
"QT"."REP_GUID",
"QT"."REP_OBJID",
TO_DATE("QT"."DATA_HOMOLOGACAO") as DATE_SQL,
case  
when "QT"."PROCESS_TYPE" = 'ZINX' then "QT"."ZZ_DESCCGU"||' nº '||"QT"."REP_OBJID"||' - '||REPLACE(LTRIM(REPLACE("QT"."DESCRIPTION", '0', ' ')), ' ', '0')||char(10)||char(10)||"QT"."ZZ_DESCGE"||char(10)||char(10)
when "QT"."PROCESS_TYPE" = 'ZDDS' then "QT"."ZZ_DESCCGU"||' nº '||"QT"."REP_OBJID"||' - '||REPLACE(LTRIM(REPLACE("QT"."DESCRIPTION", '0', ' ')), ' ', '0')||char(10)||char(10)||"QT"."ZZ_DESCGE"||char(10)||char(10)
else "QT"."ZZ_DESCCGU"||' nº '||"QT"."REP_OBJID"||' - '||REPLACE(LTRIM(REPLACE("QT"."DESCRIPTION", '0', ' ')), ' ', '0')||char(10)||char(10)
end as DESCRIPT,
'Lic: '||TO_NUMBER("QT"."REP_OBJID")-3000000000 as NEW_REP_OBJID,
"QT"."DESCRIPTION",
REPLACE(LTRIM(REPLACE("QT"."DESCRIPTION", '0', ' ')), ' ', '0') as SHORT_RFX,
"QT"."RFX_OBJID",
TO_NUMBER(CASE when "QT"."RFX_OBJID" = '' then '6000000000' else "QT"."RFX_OBJID" end)-6000000000 as NEW_RFX_OBJID
FROM "SAPABAP1"."ZBI_QT_SCALLE" AS QT
WHERE 
--"QT"."REP_OBJID" = '3000004002' AND
"QT"."DEL_IND" <> 'X'
AND "QT"."FLAG_HOMO" = 'X'
GROUP BY 
"QT"."MANDT",
"QT"."REP_GUID",
"QT"."REP_OBJID",
"QT"."DATA_HOMOLOGACAO",
"QT"."PROCESS_TYPE",
"QT"."ZZ_DESCGE",
"QT"."RFX_OBJID",
"QT"."ZZ_DESCCGU",
"QT"."DESCRIPTION"
ORDER BY "QT"."REP_OBJID";

var_dist_rfq=
select 
"QT"."MANDT",
"QT"."REP_GUID",
"QT"."REP_OBJID",
"ZA"."TDID",
"QT"."DATE_SQL",
-- to use html would have to use line break
--'<!DOCTYPE html><html><head><title>'||"DISTQ"."TITLE"||'</title></head><body>'||"DISTQ"."ZTDLINE2"||'</body></html>'
--"QT"."ZZ_DESCCGU"||' nº '||"QT"."SHORT_RFX"||'<br />'||"QT"."NEW_REP_OBJID"||' Lances: '||STRING_AGG("QT"."NEW_RFX_OBJID",'-')||char(10)||"ZA"."ZTDLINE"
--"QT"."ZZ_DESCCGU"||' nº '||"QT"."SHORT_RFX"||' - '||"QT"."NEW_REP_OBJID"
--||' - '||"ZA"."ZTDLINE"
--AS ZTDLINE2,
case 
when "ZA"."TDID" = 'ZOBJ' then "QT"."DESCRIPT"||"ZA"."ZTDLINE"
when "ZA"."TDID" = 'ZOBC' then "ZA"."ZTDLINE"       
else "QT"."DESCRIPT"
end AS ZTDLINE2,
1 as COUNTER
 from :var_dist_quot AS QT
INNER JOIN "SAPABAP1"."ZSRMTB0029" AS ZA
ON "ZA"."MANDT"="QT"."MANDT"  
AND "ZA"."GUID"="QT"."REP_GUID" 
AND ("ZA"."TDID"='ZOBJ' OR "ZA"."TDID" = 'ZOBC')
GROUP BY 
"QT"."MANDT",
"QT"."REP_GUID",
"QT"."REP_OBJID",
"ZA"."TDID",
"QT"."DATE_SQL",
"QT"."DESCRIPT",
"ZA"."ZTDLINE"
UNION
SELECT 
"QT"."MANDT",
"QT"."REP_GUID",
"QT"."REP_OBJID",
"ZA"."TDID",
"QT"."DATE_SQL",
-- to use html would have to use line break
--'<!DOCTYPE html><html><head><title>'||"DISTQ"."TITLE"||'</title></head><body>'||"DISTQ"."ZTDLINE2"||'</body></html>'
--"QT"."ZZ_DESCCGU"||' nº '||"QT"."SHORT_RFX"||'<br />'||"QT"."NEW_REP_OBJID"||' Lances: '||STRING_AGG("QT"."NEW_RFX_OBJID",'-')||char(10)||"ZA"."ZTDLINE"
--"QT"."ZZ_DESCCGU"||' nº '||"QT"."SHORT_RFX"||' - '||"QT"."NEW_REP_OBJID"
--||' - '||"ZA"."ZTDLINE"
--AS ZTDLINE2,
"QT"."DESCRIPT" AS ZTDLINE2,
1 as COUNTER
 from :var_dist_quot AS QT
LEFT OUTER JOIN "SAPABAP1"."ZSRMTB0029" AS ZA
ON "ZA"."MANDT"="QT"."MANDT"  
AND "ZA"."GUID"="QT"."REP_GUID" 
AND "ZA"."TDID"='ZOBJ'
WHERE "ZA"."ZTDLINE" is null
GROUP BY 
"QT"."MANDT",
"QT"."REP_GUID",
"QT"."REP_OBJID",
"ZA"."TDID",
"QT"."DATE_SQL",
"QT"."DESCRIPT",
"ZA"."ZTDLINE"
ORDER BY "QT"."REP_OBJID";


var_dist_partner = SELECT 
DISTINCT "LICQT"."MANDT", 
"LICQT"."REP_GUID",
"LICQT"."REP_OBJID",
TO_DATE("LICQT"."DATA_HOMOLOGACAO") as DATE_SQL,
"UN"."PARTNER",
--REPLACE(LTRIM(REPLACE("UN"."PARTNER", '0', ' ')), ' ', '0')||' : '||"UN"."MC_NAME1"||' '||"UN"."MC_NAME2"||char(10) as MC_NAME1,
"UN"."MC_NAME2"||char(10)||char(10) as MC_NAME1,
1 as COUNTER,
0 as COUNTER2
FROM "SAPABAP1"."ZBI_QT_SCALLE" as LICQT
--INNER JOIN "SAPABAP1"."ZBI_LKPRTNR75" AS UN
INNER JOIN :var_crmd_partner  AS UN
ON "LICQT"."REP_ITEM_GUID" = "UN"."CRM_ORDER_GUID"
ORDER BY "LICQT"."REP_OBJID","UN"."PARTNER";

var_unidade= 
SELECT 
"DISTP"."MANDT",
"DISTP"."REP_GUID",
"DISTP"."REP_OBJID",
"DISTP"."DATE_SQL",
CASE "DIV"."FLAG_DIV"
WHEN 'I' THEN
STRING_AGG("DISTP"."MC_NAME1",'' ORDER BY "DISTP"."MC_NAME1" )
WHEN 'V' THEN 'Diversas Unidades' 
end 
as ZTDLINE,
sum("DISTP"."COUNTER") as COUNTER,
sum("DISTP"."COUNTER2") as COUNTER2
FROM :var_dist_partner as distp
INNER JOIN  :var_diversas as div
ON "DIV"."CLIENT" = "DISTP"."MANDT"
AND "DIV"."REP_GUID" = "DISTP"."REP_GUID"
GROUP BY "DISTP"."MANDT","DISTP"."REP_GUID", "DISTP"."REP_OBJID","DISTP"."DATE_SQL","DIV"."FLAG_DIV";

var_abas=
SELECT 
"DISTQ"."MANDT",
"DISTQ"."REP_GUID",
"DISTQ"."REP_OBJID",
COALESCE("DISTQ"."TDID",'ZOBJ') as TDID,
"DISTQ"."DATE_SQL",
"DISTQ"."ZTDLINE2" as ZTDLINE2,
0 as COUNTER,
"DISTQ"."COUNTER" as COUNTER2
FROM :var_dist_rfq as distq;
--GROUP BY "DISTQ"."MANDT","DISTQ"."REP_GUID", "DISTQ"."REP_OBJID", "DISTQ"."TDID","DISTQ"."ZTDLINE2";

var_out=
SELECT 
"ABAS"."MANDT",
"ABAS"."REP_GUID",
"ABAS"."REP_OBJID",
"ABAS"."TDID",
"ABAS"."DATE_SQL",
"UNI"."ZTDLINE" as ZTDLINE,
"ABAS"."ZTDLINE2" as ZTDLINE2,
"UNI"."COUNTER" as COUNTER,
"ABAS"."COUNTER2" as COUNTER2
FROM :var_abas as abas
INNER JOIN :var_unidade as uni
ON "ABAS"."MANDT" = "UNI"."MANDT"
AND "ABAS"."REP_GUID" = "UNI"."REP_GUID"
AND "ABAS"."REP_OBJID" = "UNI"."REP_OBJID";


END /********* End Procedure Script ************/
