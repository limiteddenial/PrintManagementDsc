<#PSScriptInfo
.VERSION 2.0.0.0
.GUID 29a5af75-b176-4b70-8872-7d557f5fc1ee
#>

<#
    .DESCRIPTION
        Adds a printer using LPR for communication
#>
configuration Example
{
    param
    (
        [Parameter()]
        [System.String[]]
        $NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName PrintManagementDsc

    node $NodeName
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
