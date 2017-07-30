# cPrinterManagement
The **cPrinterManagement** module contains the following resources:
* cPrintDriver - allows you to stage and import print drivers
* cPrintDriverSet - allows you to stage and import multiple print drivers from the same source file
* cPrinter - allows you add printers      

## cPrintDriver 
cPrintDriver resource has the following properties:
* Name: The driver name
* Version: The version of the driver
* Source: Where the source .inf file is located

### cPrintDriver Examples

* [Add a printer driver](/Examples/Sample_cPrintDriver.ps1)

## cPrintDriverSet 
cPrintDriverSet resource has the following properties:
* Name: A list of driver names
* Version: The version of the driver
* Source: Where the source .inf file is located

### cPrintDriverSet Examples

* [Add a printer driver set](/Examples/Sample_cPrintDriverSet.ps1)

## cPrinter
cPrinter resource has the following properties:
* Name: The desired printer name
* PortType: The desired printer port type. Possible values: "TCPIP","Papercut","LPR"
* PortName: The desired printer port name
* Address: The desired printer address
* DriverName: The desired driver name to be used
* LprQueue: The desired queue name used if PortType is LPR
* Shared: Sets the desired shared state of the printer
* SNMPEnabled: Enables or disables SNMP on the printer port
* SNMPCommunityName: Sets the desired community name used for SNMP communication if SNMP is enabled. Defaults to "public"
* SNMPIndex: Sets the desired index used for SNMP communication if SNMP is enabled. Defaults to 1
* PermissionsSDDL: The desired permissions of a printer

### cPrinter Examples

* [Add a printer](/Examples/Sample_cPrinter.ps1)

