# PrintManagementDsc

![main](https://github.com/limiteddenial/PrintManagementDSC/actions/workflows/main.yml/badge.svg)
[![Build status](https://codecov.io/gh/limiteddenial/printmanagementdsc/branch/master/graph/badge.svg)](https://codecov.io/gh/limiteddenial/printmanagementdsc/branch/master/graph/badge.svg)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PrintManagementDsc?label=PrintManagementDsc)](https://www.powershellgallery.com/packages/PrintManagementDsc)

The **PrintManagementDsc** module contains DSC resources for deployment and configuration of printers.

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

- [**PrinterDriver**](#printerDriver) Manages what print drivers are installed on a host
- [**Printer**](#printer) Manages printers installed on a host

### PrinterDriver

Manages what print drivers are installed on a host.

#### Parameters for PrinterDriver

- **`[String]` Ensure** _(Write)_: Specifies if the printer should exist or not. { Present | Absent }.
- **`[String[]]` Name** _(Required)_: The desired driver name used in the INF file.
- **`[String]` Version** _(Required)_: Specifies the version of the driver that would be used.
- **`[String]` Source** _(Required)_: The location where the INF file is located to install the driver.
- **`[Boolean]` Purge** _(Write)_: Allows the removal the driver from the driver store after all printers are no longer using it. This is only used when Ensure is set to Absent.

#### PrinterDriver Examples

- [Add a driver](Examples/PrinterDriver_AddDriver_Config.ps1)
- [Add multiple drivers from the same driver pack](Examples/PrinterDriver_AddMultipleDrivers_Config.ps1)

### Printer

Manages printers installed on a host.

#### Parameters for Printer

- **`[String]` Name** _(Key)_: The desired name of the printer.
- **`[String]` Ensure** _(Write)_: Specifies if the printer should exist or not. { Present | Absent }.
- **`[PortType]` PortType** _(Write)_: The desired type of printer port needed.
  The default value is TCPIP. { _TCPIP_ | Papercut | LPR }
- **`[String]` PortName** _(Required)_: The desired port name.
- **`[String]` Address** _(Required)_: The desired address of the printer.
- **`[String]` DriverName** _(Required)_: The desired driver of the printer.
- **`[String]` LprQueueName** _(Write)_: The desired LPR queue name. Used only if PortType is set to LPR.
- **`[Boolean]` Shared** _(Write)_: The desired shared state of the printer.
  The default value is $true.
- **`[String]` SNMPCommunity**: The desired SNMPCommunity used for SNMP communication. Requires SNMPIndex to also be set. This will enable SNMP on the port
  The default value is _Public_.
- **`[UInt32]` SNMPIndex** _(Write)_: The desired index used for SNMP communication. Requires SNMPCommunity to also be set. This will enable SNMP on the port
  The default value is 1.
- **`[String]` PermissionsSDDL** _(Write)_: The desired permissions of a printer

#### Examples Printer

- [Add a printer using LPR](Examples/Printer_AddLPRPrinter_Config.ps1)
- [Add a printer using TCPIP](Examples/Printer_AddTCPIPPrinter_Config.ps1)
