<#
    .DESCRIPTION
        Adds a printer using LPR for communication
#>
Configuration Example
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
        Printer NewLPRPrinter {
            Ensure       = 'Present'
            Name         = 'ExampleLPRPrinter'
            PortType     = 'LPR'
            PortName     = 'ExamplePort'
            Address      = 'Example.local'
            DriverName   = 'fake'
            LprQueueName = 'testQueue'
            Shared       = $false
        } # End Printer
    } # End Node
} # End Configuration
