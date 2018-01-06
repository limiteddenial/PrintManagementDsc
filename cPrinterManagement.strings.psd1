# culture="en-US"
ConvertFrom-StringData @'
    NotInDesiredState={0} does not match desired state. Current value: {1} - Desired Value: {2}
    NewPrinterPort=Created {0} Port {1}
    PrinterDoesNotExist=Printer {0} does not exist
    PrinterPortDoesNotExist=PrinterPort {0} does not exist
    PrinterNoDriver=Driver {0} does not exist. Printer {1} cannot be added
    UpdatedDesiredState={0} will be updated to match desired state. New value: {1} - Old Value: {2}
'@