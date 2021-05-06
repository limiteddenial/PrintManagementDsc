# Changelog

## unreleased

- Moved CI to use **Github Actions** - [issue #21](https://github.com/limiteddenial/PrintManagementDsc/issues/21)
- Cast type _lprQueueName_ as [string] to support Ansible Win_DSC module
- Added additional printer properties for deployments
  - Location
  - Comment
  - Published

## 2.0.0.0

- Fixed examples for deployment
- Added deploy step
- Added Unit and Integration tests
- Changed the default for _SNMPEnabled_ to `$false` for resource _Printer_
- **Breaking Change** Changed resource from cPrinterManagement to PrintManagementDsc to meet updated naming convention
  - `cPrinter` -> `Printer`
  - `cPrintDriver` -> `PrinterDriver`
- Converted cPrinter resource to a PowerShell class
- Added tests for cPrinter resource
- Added Appveyor testing
- **Breaking Change** Changed cPrinter parameter _lprQueue_ to _lprQueueName_ to match Get-PrinterPort returned properties
- **Breaking Change** Changed cPrinter parameter _SNMPCommunityName_ to _SNMPCommunity_ to match Get-PrinterPort returned properties
- **Breaking Change** Removed cPrintDriverSet resource
- Added cPrintDriver to specify multiple drivers from the same source instead of using the cPrintDriverSet resource
- Added Purge parameter to cPrintDriver
- Added Codecov

## 1.0.0.0

- Initial release with the following resources
  - cPrinter
  - cPrintDriver
  - cPrintDriverSet
