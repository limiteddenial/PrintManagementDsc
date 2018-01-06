# culture="en-US"
ConvertFrom-StringData @'
    NotInDesiredState={0} does not match desired state. Current value: {1} - Desired Value: {2}
    NewPrinterPort=Created {0} Port {1}
    PrinterDoesNotExist=Printer {0} does not exist
    PrinterPortDoesNotExist=PrinterPort {0} does not exist
    PrinterNoDriver=Driver {0} does not exist. Printer {1} cannot be added
'@