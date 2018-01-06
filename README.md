# cPrinterManagement

The **cPrinterManagement** module contains the following resources:

- **cPrintDriver**: Add or remove print drivers
- **cPrintDriverSet**: Add or remove multiple print drivers from the same source file
- **cPrinter**: Add pr remove printers

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/k8mfwp3easg4n5au/branch/master?svg=true)](https://ci.appveyor.com/project/limiteddenial/cprintermanagement/branch/master)

This is the branch containing the latest release - no contributions should be made directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/k8mfwp3easg4n5au/branch/dev?svg=true)](https://ci.appveyor.com/project/limiteddenial/cprintermanagement/branch/dev)

This is the development branch to which contributions should be proposed by contributors as pull requests.

## cPrintDriver

cPrintDriver resource has the following properties:

- **Name**: The driver name
- **Version**: The version of the driver
- **Source**: Where the source .inf file is located

### cPrintDriver Examples

- [Add a printer driver](/Examples/Sample_cPrintDriver.ps1)

## cPrintDriverSet

cPrintDriverSet resource has the following properties:

- **Name**: A list of driver names
- **Version**: The version of the driver
- **Source**: Where the source .inf file is located

### cPrintDriverSet Examples

- [Add a printer driver set](/Examples/Sample_cPrintDriverSet.ps1)

## cPrinter

cPrinter resource has the following properties:

- **Name**: The desired printer name
- **PortType**: *Possible values: ("TCPIP","Papercut","LPR")* - The desired printer port type
- **PortName**: The desired printer port name
- **Address**: The desired printer address
- **DriverName**: The desired driver name to be used
- **LprQueue**: The desired queue name used if PortType is LPR
- **Shared**: *Default Value is $true* - Sets the desired shared state of the printer 
- **SNMPEnabled**: Enables or disables SNMP on the printer port
- **SNMPCommunityName**: *Default Value is "public"* - Sets the desired community name used for SNMP communication if SNMP is enabled. 
- **SNMPIndex**: *Default Value is 1* - Sets the desired index used for SNMP communication if SNMP is enabled. 
- **PermissionsSDDL**: The desired permissions of a printer

### cPrinter Examples

- [Add a printer](/Examples/Sample_cPrinter.ps1)
