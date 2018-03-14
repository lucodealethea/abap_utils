# abap_utils
Utilities used in former projects

## srm

Contains ABAP CDS and Hana Calculated Views to bring in memory flow to IDT and Webi

### ERM in SAP SRM is highly versatile for in-memory views and flows due to the OO approach

(Shopping Cart, RFQ, Quotation, Contract and Order ) are modeled as different Business Object Types 
in a limited number of joined tables, making it a perfect fit for high grain data foundation modeling in ABAP CDS.

https://wiki.scn.sap.com/wiki/display/SRM/SRM+Tables?preview=/44272/190906502/Main%20SRM%20Tables.jpg

Due to restriction to ABAP 740 SPS11 (no ABAP CDS table function available yet), it has been required to further model with plain hana table functions (canonical equivalent of scripted calculated view). 

Note: ABAP CDS Table Function are database procedures directly in the ABAP layer:
https://github.com/lucodealethea/abap_utils/blob/master/srm/CDS_vs_AMDP.png

### the current repository could be replicated in any SRM based Netweaver >= ABAP 740 SPS9 using ABAPGIT



