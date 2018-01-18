# Change log for cPrinterManagement

## Unreleased

* Converted cPrinter resource to a PowerShell class
* Added tests for cPrinter resouce
* Added Appveyor testing
* **Breaking Change** Changed cPrinter paramater _lprQueue_ to _lprQueueName_ to match get-printerport returned properties
* **Breaking Change** Changed cPrinter paramater _SNMPCommunityName_ to _SNMPCommunity_ to match get-printerport returned properties


## 1.0.0.0

* Initial release with the following resources
  * cPrinter
  * cPrintDriver
  * cPrintDriverSet
