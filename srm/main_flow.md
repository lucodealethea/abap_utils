Data Foundations for Transactionals:
crmd_orderadm_h, crmd_orderadm_i, crm_jest, bbp_pdhgp, bbp_pdigp, bbpc_proc_type_t, bbp_pdhsc, bbp_pdisc,...

The following flow is on business object type BUS2202 many to one BUS2200:

(ZTV_RFX_GUID_RFQ_QUOT)				            (ZTV_SC_ELIMINADOS)

ZBI_GUIDSRFQT					                    ZBI_SC_ELIM

>
(ZTV_RFQ_ITENS_QUOT)
ZBI_RFQ_ITENSQUT

>

ZBI_QT_SCALLE     (union of ZBI_RFQ_ITENSQUT and ZBI_SC_ELIM )

> Scripted for Ranking

LEILAO_LIC_COT.CAV_SC_RFQ_QT_RK_SCRIPTED


> Calculation View: LEILAO_LIC_COT.CAV_SC_RFQ_Q_ANALITICO

using

LEILAO_LIC_COT.CAV_SC_RFQ_QT_RK_SCRIPTED

- Table: _SYS_BI.M_TIME_DIMENSION
- View: SAPABAP1.ZBI_LKPRTNR
- View: SAPABAP1.ZBI_LKPDORG


IDT will join:
 
LEILAO_LIC_COT.CAV_SC_RFQ_Q_ANALITICO

CAV_STXL_BY_REP_OBJID

using context in case long text (as per CAV_STXL_BY_REP_OBJID ) is not required

IDT will also have list of values in its universes querying mainly ABAP CDS for prompts in WebI
