# cPrinterManagement

The **cPrinterManagement** module contains DSC resources for deployment and configuration of printers. 

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/k8mfwp3easg4n5au/branch/master?svg=true)](https://ci.appveyor.com/project/limiteddenial/cprintermanagement/branch/master)
[![Build status](https://codecov.io/gh/limiteddenial/cPrinterManagement/branch/master/graph/badge.svg)](https://codecov.io/gh/limiteddenial/cPrinterManagement/branch/master/graph/badge.svg)

This is the branch containing the latest release - no contributions should be made directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/k8mfwp3easg4n5au/branch/dev?svg=true)](https://ci.appveyor.com/project/limiteddenial/cprintermanagement/branch/dev)
[![Build status](https://codecov.io/gh/limiteddenial/cPrinterManagement/branch/dev/graph/badge.svg)](https://codecov.io/gh/limiteddenial/cPrinterManagement/branch/dev/graph/badge.svg)


This is the development branch to which contributions should be proposed by contributors as pull requests.

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

* [**cPrintDriver**](#cprintdriver) Manages what print drivers are installed on a host
* [**cPrinter**](#cprinter) Manages printers installed on a host

### cPrintDriver

Manages what print drivers are installed on a host.

#### Parameters for cPrintDriver:

* **`[String]` Ensure** _(Write)_: Specifies if the printer should exist or not.  { Present | Absent }.
* **`[String[]]` Name** _(Required)_: The desired driver name used in the INF file.
* **`[String]` Version** _(Required)_: Specifies the version of the driver that whould be used.
* **`[String]` Source** _(Required)_: The location where the INF file is located to install the driver.
* **`[Boolean]` Purge** _(Write)_: Allows the removal the driver from the driver store after all printers are no longer using it. This is only used when Ensure is set to Absent. 

#### cPrintDriver Examples

* [Add a printer driver](/Examples/Sample_cPrintDriver.ps1)


### cPrinter

Manages printers installed on a host.

#### Parameters for cPrinter:

* **`[String]` Name** _(Key)_: The desired name of the printer.
* **`[String]` Ensure** _(Write)_: Specifies if the printer should exist or not.  { Present | Absent }.
* **`[PortType]` PortType** _(Write)_: The desired type of printer port needed. 
The defalut value is TCPIP. { *TCPIP* | Papercut | LPR }
* **`[String]` PortName** _(Required)_: The desired port name.
* **`[String]` Address** _(Required)_: The desired address of the printer.
* **`[String]` DriverName** _(Required)_: The desired driver of the printer.
* **`[String]` LprQueueName** _(Write)_: The desired LPR queue name. Used only if PortType is set to LPR.
* **`[Boolean]` Shared** _(Write)_: The desired shared state of the printer. 
The default value is $true.
* **`[Boolean]` SNMPEnabled** _(Write)_: The disired state for SNMP enablement on the printer port 
The defalut value is $true.
* **`[String]` SNMPCommunity**: The desired SNMPCommunity used for SNMP communication, only set if SNMP is enabled on the port.
The default value is _Public_.
* **`[UInt32]` SNMPIndex** _(Write)_: The desired index used for SNMP communication, only set if SNMP is enabled on the port. 
The default value is 1.
* **`[String]` PermissionsSDDL** _(Write)_: The desired permissions of a printer

#### Examples cPrinter

* [Add a printer](/Examples/Sample_cPrinter.ps1)
