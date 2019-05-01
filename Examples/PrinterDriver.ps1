<#
    .EXAMPLE
        Installs a print driver. 
#>
Configuration Example {
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName PrintManagementDsc

    Node $NodeName 
    {
        PrinterDriver XeroxGlobal 
        {
            Ensure = "Present"
            Name = "Xerox Global Print Driver PCL6"
            Version = "1.2.3.4"
            Source = "C:\Drivers\Xerox\x2UNiVX.inf"
        } # End PrinterDriver
    } # End Node
} # End Configuration
