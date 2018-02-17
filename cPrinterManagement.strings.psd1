# culture="en-US"
ConvertFrom-StringData @'
    NotInDesiredState={0} does not match desired state. Current value: {1} - Desired Value: {2}
    NotInDesiredStateMultipleObjects={0} does not match desired state for {1}. Current value: {2} - Desired Value: {3}
    NewPrinterPort=Created {0} Port {1}
    PrinterDoesNotExist=Printer {0} does not exist
    PrinterPortDoesNotExist=PrinterPort {0} does not exist
    PrinterNoDriver=Driver {0} does not exist. Printer {1} cannot be added
    SourceNotFound=Source {0} does not exist
    UpdatedDesiredState={0} will be updated to match desired state. New value: {1} - Old Value: {2}
    CheckingForRemovalConflicts=Verifying that there are no drivers that are adding using INF of {0}
    FoundConflicts={0} print drivers are using {1}. Driver will not be removed til all conflicts are resolved
'@
