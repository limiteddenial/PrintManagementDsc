# culture="en-US"
ConvertFrom-StringData @'
    NotInDesiredState={0} does not match desired state. Current value: {1} - Desired Value: {2}
    NotInDesiredStateMultipleObjects={0} does not match desired state for {1}. Current value: {2} - Desired Value: {3}
    NewPrinter=Created Printer {0}
    NewPrinterPort=Created {0} Port {1}
    NewPrinterPortNeededMessage=Port does not exist, will create a {0} port with then name {1}
    PrinterDoesNotExist=Printer {0} does not exist
    PrinterPortDoesNotExist=PrinterPort {0} does not exist
    PrinterNoDriver=Driver {0} does not exist. Printer {1} cannot be added
'@
