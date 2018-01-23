# abap_utils
Utilities used in former projects

## srm

Contains ABAP CDS and Hana Calculated Views to bring in memory flow to IDT and Webi

### ERM in SRM is highly versatile for in-memory views and flows due to the OO approach

(Shopping Cart, RFQ, Quotation, Contract and Order ) are modeled as different Business Object Types 
in a limited number of joined tables, making it a perfect fit for high grain data foundation modeling in ABAP CDS.

https://wiki.scn.sap.com/wiki/display/SRM/SRM+Tables?preview=/44272/190906502/Main%20SRM%20Tables.jpg

Due to restriction to ABAP 740 SPS11 (no table function available yet), it has been required to further model with hana table functions (canonical equivalent of scripted calculated view). 

### the current repository could be replicated in any SRM based Netweaver >= ABAP 740 SPS9 using ABAPGIT

