Configuration PrinterDriver_Config
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName PrintManagementDsc

    Node $NodeName
    {
        PrinterDriver Integration_Test {
            Ensure = $Node.Ensure
            Name = $Node.Name
            Version = $Node.Version
            Source = $Node.Source
        } # End PrinterDriver
    } # End Node
} # End Configuration
