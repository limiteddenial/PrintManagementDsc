# culture="en-US"
ConvertFrom-StringData @'
    CheckingForRemovalConflicts=Verifying that there are no drivers that are adding using INF of {0}
    DriverDoesNotExistMessage=Driver {0} was not found in the driver store.
    DriverRemovedSuccessfullyMessage=Driver {0} was successfully removed.
    ErrorRemovingDriverMessage=Unable to remove driver.
    FailedToStageDriver=Failed to stage print driver from source {0}
    FoundConflicts={0} print drivers are using {1}. Driver will not be removed til all conflicts are resolved
    FoundStagedDriverMessage=Found staged driver path of {0}.
    PurgingDriverMessage=Purging driver from system.
    NotInDesiredState={0} does not match desired state. Current value: {1} - Desired Value: {2}
    NotInDesiredStateMultipleObjects={0} does not match desired state for {1}. Current value: {2} - Desired Value: {3}
    NewPrinterPort=Created {0} Port {1}
    RemovingDriverMessage=Removing driver {0}.
    RemovingPrintDriver=Removing Print Driver {0}.
    SourceNotFound=Source {0} does not exist.
    UpdatedDesiredState={0} will be updated to match desired state. New value: {1} - Old Value: {2}
'@
