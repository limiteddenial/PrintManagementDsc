<#
    .EXAMPLE
        Adds two printers, one using TCPIP port and other using LPR for communication
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

        Printer NewLPRPrinter {
            Ensure     = 'Present'
            Name       = 'ExampleTCPIPPrinter'
            PortType   = 'TCPIP'
            PortName   = 'ExampleTCPIPPort'
            Address    = 'tcpip.local'
            DriverName = 'fake'
            Shared     = $true
        } # End Printer

    } # End Node
} # End Configuration
