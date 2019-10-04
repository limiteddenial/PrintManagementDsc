# Changelog

## Unreleased

* Added Unit and Integration tests
* Changed the default for _SNMPEnabled_ to `$false` for resource _Printer_
* Changed resource from cPrinterManagement to PrintManagementDsc to meet updated naming convention
* Converted cPrinter resource to a PowerShell class
* Added tests for cPrinter resource
* Added Appveyor testing
* **Breaking Change** Changed cPrinter parameter _lprQueue_ to _lprQueueName_ to match Get-PrinterPort returned properties
* **Breaking Change** Changed cPrinter parameter _SNMPCommunityName_ to _SNMPCommunity_ to match Get-PrinterPort returned properties
* **Breaking Change** Removed cPrintDriverSet resource
* Added cPrintDriver to specify multiple drivers from the same source instead of using the cPrintDriverSet resource
* Added Purge parameter to cPrintDriver
* Added Codecov

## 1.0.0.0

* Initial release with the following resources
  * cPrinter
  * cPrintDriver
  * cPrintDriverSet
